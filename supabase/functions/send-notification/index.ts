import { createClient } from "npm:@supabase/supabase-js@2";
import { SignJWT, importPKCS8 } from "npm:jose@5";

type Audience = "broadcast" | "customer";

type SendNotificationPayload = {
  audience?: Audience;
  shop_id?: string;
  topic?: string;
  customer_id?: number;
  title?: string;
  body?: string;
  type?: string;
  image_url?: string | null;
  payload?: Record<string, unknown> | null;
  order_id?: number | null;
  order_status?: string | null;
};

type FirebaseServiceAccount = {
  project_id: string;
  client_email: string;
  private_key: string;
};

type CallerProfile = {
  shop_id: string;
  role: string;
  location_id: number | null;
};

type NormalizedNotification = {
  audience: Audience;
  shopId: string;
  topic: string | null;
  customerId: number | null;
  type: string;
  title: string;
  body: string;
  imageUrl: string | null;
  payload: Record<string, unknown>;
  orderId: number | null;
  orderStatus: string | null;
};

type FcmTarget =
  | { topic: string; token?: never }
  | { token: string; topic?: never };

type FcmSuccess = {
  ok: true;
  messageId: string;
  target: string;
};

type FcmFailure = {
  ok: false;
  target: string;
  status: number;
  error: string;
  unregistered: boolean;
};

const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers":
    "authorization, x-client-info, apikey, content-type",
  "Access-Control-Allow-Methods": "POST, OPTIONS",
};

const TOPIC_SUFFIX = "_all";
const GOOGLE_OAUTH_TOKEN_URL = "https://oauth2.googleapis.com/token";
const GOOGLE_MESSAGING_SCOPE =
  "https://www.googleapis.com/auth/firebase.messaging";

const json = (body: Record<string, unknown>, status = 200) =>
  new Response(JSON.stringify(body), {
    status,
    headers: {
      "Content-Type": "application/json",
      ...corsHeaders,
    },
  });

function normalizeShopTopic(shopId: string): string {
  const normalized = shopId
    .trim()
    .toLowerCase()
    .replace(/[^a-z0-9_-]/g, "_");
  return `shop_${normalized}${TOPIC_SUFFIX}`;
}

function isAdminRole(role: string): boolean {
  return role === "owner" || role === "admin";
}

function isStaffRole(role: string): boolean {
  return role === "owner" || role === "admin" || role === "staff";
}

function asPositiveInt(value: unknown): number | null {
  const parsed = Number(value);
  if (!Number.isInteger(parsed) || parsed <= 0) {
    return null;
  }
  return parsed;
}

function normalizeNotificationPayload(
  rawPayload: SendNotificationPayload,
  callerProfile: CallerProfile,
): NormalizedNotification {
  const audience = rawPayload.audience ?? "broadcast";
  const shopId = String(rawPayload.shop_id ?? callerProfile.shop_id).trim();
  const type = String(rawPayload.type ?? "").trim().toLowerCase();
  const title = String(rawPayload.title ?? "").trim();
  const body = String(rawPayload.body ?? "").trim();
  const imageUrl = rawPayload.image_url
    ? String(rawPayload.image_url).trim()
    : null;
  const orderId = asPositiveInt(rawPayload.order_id);
  const orderStatus = rawPayload.order_status
    ? String(rawPayload.order_status).trim().toLowerCase()
    : null;
  const payload =
    rawPayload.payload && typeof rawPayload.payload === "object"
      ? rawPayload.payload
      : {};

  if (!shopId) {
    throw new Error("Missing shop_id.");
  }

  if (shopId !== callerProfile.shop_id) {
    throw new Error("You can only send notifications for your own shop.");
  }

  if (!title || !body || !type) {
    throw new Error("Title, body, and type are required.");
  }

  if (audience !== "broadcast" && audience !== "customer") {
    throw new Error("Invalid audience.");
  }

  if (audience === "broadcast") {
    if (!["promotion", "announcement"].includes(type)) {
      throw new Error(
        "Broadcast notifications only allow promotion or announcement types.",
      );
    }

    return {
      audience,
      shopId,
      topic: normalizeShopTopic(shopId),
      customerId: null,
      type,
      title,
      body,
      imageUrl,
      payload,
      orderId,
      orderStatus,
    };
  }

  const customerId = asPositiveInt(rawPayload.customer_id);
  if (!customerId) {
    throw new Error(
      "A valid customer_id is required for customer notifications.",
    );
  }

  if (!["order_status", "announcement", "welcome", "promotion"].includes(type)) {
    throw new Error("Invalid customer notification type.");
  }

  return {
    audience,
    shopId,
    topic: null,
    customerId,
    type,
    title,
    body,
    imageUrl,
    payload,
    orderId,
    orderStatus,
  };
}

function buildFcmData(
  notification: NormalizedNotification,
): Record<string, string> {
  const data: Record<string, string> = {
    audience: notification.audience,
    shop_id: notification.shopId,
    type: notification.type,
    title: notification.title,
    body: notification.body,
    payload_json: JSON.stringify(notification.payload ?? {}),
  };

  if (notification.customerId != null) {
    data.customer_id = String(notification.customerId);
  }

  if (notification.orderId != null) {
    data.order_id = String(notification.orderId);
  }

  if (notification.orderStatus) {
    data.order_status = notification.orderStatus;
  }

  if (notification.imageUrl) {
    data.image_url = notification.imageUrl;
  }

  return data;
}

async function getGoogleAccessToken(
  serviceAccount: FirebaseServiceAccount,
): Promise<string> {
  const now = Math.floor(Date.now() / 1000);
  const signingKey = await importPKCS8(serviceAccount.private_key, "RS256");
  const assertion = await new SignJWT({ scope: GOOGLE_MESSAGING_SCOPE })
    .setProtectedHeader({ alg: "RS256", typ: "JWT" })
    .setIssuer(serviceAccount.client_email)
    .setAudience(GOOGLE_OAUTH_TOKEN_URL)
    .setIssuedAt(now)
    .setExpirationTime(now + 3600)
    .sign(signingKey);

  const response = await fetch(GOOGLE_OAUTH_TOKEN_URL, {
    method: "POST",
    headers: {
      "Content-Type": "application/x-www-form-urlencoded",
    },
    body: new URLSearchParams({
      grant_type: "urn:ietf:params:oauth:grant-type:jwt-bearer",
      assertion,
    }),
  });

  const data = await response.json();
  if (!response.ok || !data.access_token) {
    throw new Error("Unable to obtain Firebase access token.");
  }

  return String(data.access_token);
}

function isUnregisteredTokenError(data: unknown): boolean {
  if (!data || typeof data !== "object") {
    return false;
  }

  const details = Array.isArray(
      (data as { error?: { details?: unknown[] } }).error?.details,
    )
    ? (data as { error?: { details?: unknown[] } }).error?.details ?? []
    : [];

  return details.some((detail) => {
    if (!detail || typeof detail !== "object") {
      return false;
    }
    return (
      String((detail as { errorCode?: unknown }).errorCode ?? "") ===
      "UNREGISTERED"
    );
  });
}

async function sendFcmMessage(
  accessToken: string,
  serviceAccount: FirebaseServiceAccount,
  target: FcmTarget,
  notification: NormalizedNotification,
): Promise<FcmSuccess | FcmFailure> {
  const targetValue = "topic" in target ? target.topic : target.token;
  const requestBody = {
    message: {
      notification: {
        title: notification.title,
        body: notification.body,
        ...(notification.imageUrl ? { image: notification.imageUrl } : {}),
      },
      data: buildFcmData(notification),
      android: {
        priority: "HIGH",
        notification: {
          channelId: "general_notifications",
          sound: "default",
          ...(notification.imageUrl ? { image: notification.imageUrl } : {}),
        },
      },
      apns: {
        headers: {
          "apns-priority": "10",
        },
        payload: {
          aps: {
            sound: "default",
          },
        },
        fcm_options: notification.imageUrl
          ? { image: notification.imageUrl }
          : undefined,
      },
      webpush: {
        headers: {
          Urgency: "high",
        },
      },
      ...target,
    },
  };

  const response = await fetch(
    `https://fcm.googleapis.com/v1/projects/${serviceAccount.project_id}/messages:send`,
    {
      method: "POST",
      headers: {
        Authorization: `Bearer ${accessToken}`,
        "Content-Type": "application/json",
      },
      body: JSON.stringify(requestBody),
    },
  );

  const data = await response.json();
  if (response.ok && data.name) {
    return {
      ok: true,
      messageId: String(data.name),
      target: targetValue,
    };
  }

  const errorMessage = String(
    (data?.error && typeof data.error === "object" && "message" in data.error
      ? data.error.message
      : "FCM send failed.") ?? "FCM send failed.",
  );

  return {
    ok: false,
    target: targetValue,
    status: response.status,
    error: errorMessage,
    unregistered: isUnregisteredTokenError(data),
  };
}

Deno.serve(async (req) => {
  if (req.method === "OPTIONS") {
    return new Response("ok", { headers: corsHeaders });
  }

  try {
    const supabaseUrl = Deno.env.get("SUPABASE_URL");
    const supabaseAnonKey = Deno.env.get("SUPABASE_ANON_KEY");
    const supabaseServiceRoleKey = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY");
    const firebaseServiceAccountRaw = Deno.env.get(
      "FIREBASE_SERVICE_ACCOUNT_JSON",
    );

    if (!supabaseUrl || !supabaseAnonKey || !supabaseServiceRoleKey) {
      return json({ error: "Missing Supabase environment secrets." }, 500);
    }

    if (!firebaseServiceAccountRaw) {
      return json({ error: "Missing FIREBASE_SERVICE_ACCOUNT_JSON secret." }, 500);
    }

    const firebaseServiceAccount = JSON.parse(
      firebaseServiceAccountRaw,
    ) as FirebaseServiceAccount;

    if (
      !firebaseServiceAccount.project_id ||
      !firebaseServiceAccount.client_email ||
      !firebaseServiceAccount.private_key
    ) {
      return json({ error: "Invalid Firebase service account secret." }, 500);
    }

    const authHeader = req.headers.get("Authorization");
    if (!authHeader) {
      return json({ error: "Missing authorization header." }, 401);
    }

    const callerClient = createClient(supabaseUrl, supabaseAnonKey, {
      global: { headers: { Authorization: authHeader } },
    });
    const serviceClient = createClient(supabaseUrl, supabaseServiceRoleKey);

    const {
      data: { user: callerUser },
      error: callerError,
    } = await callerClient.auth.getUser();

    if (callerError || !callerUser) {
      return json({ error: "Unauthorized caller." }, 401);
    }

    const { data: callerProfileData, error: profileError } = await serviceClient
      .from("shop_users")
      .select("shop_id, role, location_id")
      .eq("user_id", callerUser.id)
      .maybeSingle();

    const callerProfile = callerProfileData as CallerProfile | null;

    if (profileError || !callerProfile) {
      return json({ error: "Dashboard profile not found." }, 403);
    }

    if (!isStaffRole(String(callerProfile.role ?? "").toLowerCase())) {
      return json({ error: "Only shop staff can send notifications." }, 403);
    }

    const rawPayload = (await req.json()) as SendNotificationPayload;
    const notification = normalizeNotificationPayload(rawPayload, {
      shop_id: callerProfile.shop_id,
      role: String(callerProfile.role ?? "").toLowerCase(),
      location_id: callerProfile.location_id ?? null,
    });

    if (
      notification.audience === "broadcast" &&
      !isAdminRole(String(callerProfile.role ?? "").toLowerCase())
    ) {
      return json({ error: "Only owner/admin can send broadcast notifications." }, 403);
    }

    const accessToken = await getGoogleAccessToken(firebaseServiceAccount);

    if (notification.audience === "broadcast") {
      const { data: insertedRow, error: insertError } = await serviceClient
        .from("broadcast_notifications")
        .insert({
          shop_id: notification.shopId,
          topic: notification.topic,
          type: notification.type,
          title: notification.title,
          body: notification.body,
          image_url: notification.imageUrl,
          payload: notification.payload,
          sent_by_user_id: callerUser.id,
        })
        .select("id")
        .single();

      const insertedBroadcastRow = insertedRow as { id: number } | null;

      if (insertError || !insertedBroadcastRow) {
        return json(
          { error: insertError?.message ?? "Unable to create broadcast log." },
          400,
        );
      }

      const sendResult = await sendFcmMessage(
        accessToken,
        firebaseServiceAccount,
        { topic: notification.topic ?? normalizeShopTopic(notification.shopId) },
        notification,
      );

      const deliveryMeta = {
        audience: "broadcast",
        topic: notification.topic,
        sent_by_role: callerProfile.role,
      };

      if (!sendResult.ok) {
        await serviceClient
          .from("broadcast_notifications")
          .update({
            delivery_meta: {
              ...deliveryMeta,
              error: sendResult.error,
              status: sendResult.status,
            },
          })
          .eq("id", insertedBroadcastRow.id);

        return json(
          {
            error: sendResult.error,
            notification_id: insertedBroadcastRow.id,
            topic: notification.topic,
          },
          502,
        );
      }

      await serviceClient
        .from("broadcast_notifications")
        .update({
          is_sent_fcm: true,
          sent_at: new Date().toISOString(),
          fcm_message_id: sendResult.messageId,
          delivery_meta: {
            ...deliveryMeta,
            message_id: sendResult.messageId,
          },
        })
        .eq("id", insertedBroadcastRow.id);

      return json({
        ok: true,
        audience: "broadcast",
        notification_id: insertedBroadcastRow.id,
        topic: notification.topic,
        message_id: sendResult.messageId,
      });
    }

    const { data: customerData, error: customerError } = await serviceClient
      .from("customers")
      .select("id, shop_id, name")
      .eq("id", notification.customerId as number)
      .eq("shop_id", notification.shopId)
      .maybeSingle();

    const customer = customerData as
      | { id: number; shop_id: string; name: string }
      | null;

    if (customerError || !customer) {
      return json({ error: "Customer not found in this shop." }, 404);
    }

    if (notification.orderId != null) {
      const { data: orderData, error: orderError } = await serviceClient
        .from("orders")
        .select("id, customer_id, shop_id")
        .eq("id", notification.orderId)
        .eq("shop_id", notification.shopId)
        .maybeSingle();

      const order = orderData as
        | { id: number; customer_id: number; shop_id: string }
        | null;

      if (orderError || !order || order.customer_id !== notification.customerId) {
        return json({ error: "Order does not belong to the selected customer." }, 400);
      }
    }

    const {
      data: insertedCustomerNotificationData,
      error: insertNotificationError,
    } =
      await serviceClient
        .from("customer_notifications")
        .insert({
          shop_id: notification.shopId,
          customer_id: notification.customerId,
          type: notification.type,
          title: notification.title,
          body: notification.body,
          image_url: notification.imageUrl,
          payload: notification.payload,
          order_id: notification.orderId,
          order_status: notification.orderStatus,
          sent_by_user_id: callerUser.id,
        })
        .select("id")
        .single();

    const insertedCustomerNotification = insertedCustomerNotificationData as {
      id: number;
    } | null;

    if (insertNotificationError || !insertedCustomerNotification) {
      return json(
        { error: insertNotificationError?.message ?? "Unable to create customer notification." },
        400,
      );
    }

    const { data: tokenRows, error: tokensError } = await serviceClient
      .from("fcm_tokens")
      .select("id, token")
      .eq("shop_id", notification.shopId)
      .eq("customer_id", notification.customerId as number)
      .eq("is_active", true);

    if (tokensError) {
      return json({ error: tokensError.message }, 400);
    }

    const tokens = Array.from(
      new Set(
        (tokenRows ?? [])
          .map((row) => String(row.token ?? "").trim())
          .filter((token) => token.length > 0),
      ),
    );

    if (tokens.length === 0) {
      await serviceClient
        .from("customer_notifications")
        .update({
          delivery_meta: {
            audience: "customer",
            attempted_tokens: 0,
            successful_tokens: 0,
            failed_tokens: 0,
          },
        })
        .eq("id", insertedCustomerNotification.id);

      return json({
        ok: true,
        audience: "customer",
        notification_id: insertedCustomerNotification.id,
        customer_id: notification.customerId,
        customer_name: customer.name,
        attempted_tokens: 0,
        successful_tokens: 0,
        failed_tokens: 0,
      });
    }

    const sendResults = await Promise.all(
      tokens.map((token) =>
        sendFcmMessage(
          accessToken,
          firebaseServiceAccount,
          { token },
          notification,
        ),
      ),
    );

    const successful = sendResults.filter((result) => result.ok);
    const failed = sendResults.filter((result) => !result.ok);
    const invalidTokens = failed
      .filter((result) => result.unregistered)
      .map((result) => result.target);

    if (invalidTokens.length > 0) {
      await serviceClient
        .from("fcm_tokens")
        .update({ is_active: false, updated_at: new Date().toISOString() })
        .in("token", invalidTokens);
    }

    await serviceClient
      .from("customer_notifications")
      .update({
        is_sent_fcm: successful.length > 0,
        sent_at: new Date().toISOString(),
        fcm_message_id: successful[0]?.messageId ?? null,
        delivery_meta: {
          audience: "customer",
          attempted_tokens: tokens.length,
          successful_tokens: successful.length,
          failed_tokens: failed.length,
          invalidated_tokens: invalidTokens.length,
          errors: failed.slice(0, 5).map((result) => ({
            target: result.target,
            status: result.status,
            error: result.error,
          })),
        },
      })
      .eq("id", insertedCustomerNotification.id);

    return json({
      ok: true,
      audience: "customer",
      notification_id: insertedCustomerNotification.id,
      customer_id: notification.customerId,
      customer_name: customer.name,
      attempted_tokens: tokens.length,
      successful_tokens: successful.length,
      failed_tokens: failed.length,
      invalidated_tokens: invalidTokens.length,
    });
  } catch (error) {
    const message =
      error instanceof Error ? error.message : "Unexpected server error.";
    return json({ error: message }, 500);
  }
});
