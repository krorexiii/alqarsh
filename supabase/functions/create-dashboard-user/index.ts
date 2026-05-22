import { createClient } from "npm:@supabase/supabase-js@2";

type CreateDashboardUserPayload = {
  shop_id?: string;
  name?: string;
  username?: string;
  email?: string;
  password?: string;
  role?: string;
  location_id?: number;
};

const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers":
    "authorization, x-client-info, apikey, content-type",
  "Access-Control-Allow-Methods": "POST, OPTIONS",
};

const json = (body: Record<string, unknown>, status = 200) =>
  new Response(JSON.stringify(body), {
    status,
    headers: {
      "Content-Type": "application/json",
      ...corsHeaders,
    },
  });

Deno.serve(async (req) => {
  if (req.method === "OPTIONS") {
    return new Response("ok", { headers: corsHeaders });
  }

  try {
    const supabaseUrl = Deno.env.get("SUPABASE_URL");
    const supabaseAnonKey = Deno.env.get("SUPABASE_ANON_KEY");
    const supabaseServiceRoleKey = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY");

    if (!supabaseUrl || !supabaseAnonKey || !supabaseServiceRoleKey) {
      return json({ error: "Missing Supabase environment secrets." }, 500);
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

    const payload = (await req.json()) as CreateDashboardUserPayload;
    const shopId = payload.shop_id?.trim();
    const name = payload.name?.trim();
    const username = payload.username?.trim().toLowerCase();
    const email = payload.email?.trim().toLowerCase();
    const password = payload.password ?? "";
    const role = payload.role?.trim().toLowerCase();
    const locationId = Number(payload.location_id);

    if (!shopId || !name || !username || !email || !role || !password) {
      return json({ error: "Missing required fields." }, 400);
    }

    if (!["admin", "staff"].includes(role)) {
      return json({ error: "Invalid role." }, 400);
    }

    if (!Number.isInteger(locationId) || locationId <= 0) {
      return json({ error: "Invalid location_id." }, 400);
    }

    if (password.length < 8) {
      return json({ error: "Password must be at least 8 characters." }, 400);
    }

    const { data: callerProfile, error: callerProfileError } = await serviceClient
      .from("shop_users")
      .select("shop_id, role")
      .eq("user_id", callerUser.id)
      .maybeSingle();

    if (
      callerProfileError ||
      !callerProfile ||
      callerProfile.shop_id !== shopId ||
      !["owner", "admin"].includes((callerProfile.role ?? "").toString())
    ) {
      return json({ error: "Only owner/admin can create dashboard users." }, 403);
    }

    const { data: location, error: locationError } = await serviceClient
      .from("sotre_location")
      .select("id")
      .eq("id", locationId)
      .eq("shop_id", shopId)
      .maybeSingle();

    if (locationError || !location) {
      return json({ error: "Selected location does not belong to this shop." }, 400);
    }

    const { data: existingUsername } = await serviceClient
      .from("shop_users")
      .select("id")
      .eq("shop_id", shopId)
      .eq("username", username)
      .maybeSingle();

    if (existingUsername) {
      return json({ error: "Username is already used in this shop." }, 409);
    }

    const { data: createdAuthUser, error: createAuthError } =
      await serviceClient.auth.admin.createUser({
        email,
        password,
        email_confirm: true,
        user_metadata: {
          dashboard_username: username,
          display_name: name,
        },
      });

    if (createAuthError || !createdAuthUser.user) {
      const message = createAuthError?.message ?? "Unable to create auth user.";
      return json({ error: message }, 400);
    }

    const { error: insertProfileError } = await serviceClient.from("shop_users").insert({
      shop_id: shopId,
      user_id: createdAuthUser.user.id,
      role,
      name,
      location_id: locationId,
      username,
    });

    if (insertProfileError) {
      await serviceClient.auth.admin.deleteUser(createdAuthUser.user.id);
      return json({ error: insertProfileError.message }, 400);
    }

    return json({
      user_id: createdAuthUser.user.id,
      email,
      username,
      role,
      shop_id: shopId,
      location_id: locationId,
    });
  } catch (error) {
    const message =
      error instanceof Error ? error.message : "Unexpected server error.";
    return json({ error: message }, 500);
  }
});
