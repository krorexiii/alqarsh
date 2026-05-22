import { createClient } from "npm:@supabase/supabase-js@2";

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

const normalizeEmail = (value: string) => value.trim().toLowerCase();

const localPart = (email: string) => email.split("@")[0]?.trim().toLowerCase() ?? "";

const sha256 = async (value: string) => {
  const bytes = new TextEncoder().encode(value);
  const digest = await crypto.subtle.digest("SHA-256", bytes);
  return Array.from(new Uint8Array(digest))
    .map((b) => b.toString(16).padStart(2, "0"))
    .join("");
};

const generateOtp = () =>
  String(Math.floor(10000000 + Math.random() * 90000000));

const sendEmail = async ({
  apiKey,
  from,
  to,
  otp,
}: {
  apiKey: string;
  from: string;
  to: string;
  otp: string;
}) => {
  const response = await fetch("https://api.resend.com/emails", {
    method: "POST",
    headers: {
      Authorization: `Bearer ${apiKey}`,
      "Content-Type": "application/json",
    },
    body: JSON.stringify({
      from,
      to,
      subject: "رمز استعادة كلمة المرور",
      html: `
        <div dir="rtl" style="font-family:Arial,sans-serif;line-height:1.8;color:#16312D">
          <h2 style="margin:0 0 12px">رمز استعادة كلمة المرور</h2>
          <p style="margin:0 0 16px">أدخل هذا الرمز داخل التطبيق لإكمال استعادة كلمة المرور:</p>
          <div style="font-size:36px;font-weight:700;letter-spacing:8px;margin:12px 0 20px">${otp}</div>
          <p style="margin:0;color:#60746F">صلاحية الرمز 15 دقيقة، وأي طلب جديد يلغي الرمز السابق.</p>
        </div>
      `,
      text: `رمز استعادة كلمة المرور: ${otp}\nصلاحية الرمز 15 دقيقة، وأي طلب جديد يلغي الرمز السابق.`,
    }),
  });

  if (!response.ok) {
    const message = await response.text();
    throw new Error(`Resend error: ${response.status} ${message}`);
  }
};

Deno.serve(async (req) => {
  if (req.method === "OPTIONS") {
    return new Response("ok", { headers: corsHeaders });
  }

  try {
    const supabaseUrl = Deno.env.get("SUPABASE_URL");
    const supabaseServiceRoleKey = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY");
    const resendApiKey = Deno.env.get("RESEND_API_KEY");
    const fromEmail = Deno.env.get("PASSWORD_RESET_FROM_EMAIL");

    if (!supabaseUrl || !supabaseServiceRoleKey) {
      return json({ error: "Missing Supabase environment secrets." }, 500);
    }

    if (!resendApiKey || !fromEmail) {
      return json(
        {
          error:
            "Missing RESEND_API_KEY or PASSWORD_RESET_FROM_EMAIL secret.",
        },
        500,
      );
    }

    const payload = await req.json();
    const email = normalizeEmail(String(payload?.email ?? ""));
    if (!email) {
      return json({ error: "Email is required." }, 400);
    }

    const serviceClient = createClient(supabaseUrl, supabaseServiceRoleKey);
    const usernameVariants = [email, localPart(email)].filter(Boolean);

    const { data: shopUser, error: shopUserError } = await serviceClient
      .from("shop_users")
      .select("user_id, username")
      .in("username", usernameVariants)
      .limit(1)
      .maybeSingle();

    if (shopUserError) {
      return json({ error: shopUserError.message }, 500);
    }

    if (!shopUser?.user_id) {
      return json({
        success: true,
        message:
          "إذا كان الحساب موجوداً فسيصل رمز استعادة كلمة المرور إلى البريد الإلكتروني.",
      });
    }

    const { data: authUser, error: authUserError } =
      await serviceClient.auth.admin.getUserById(shopUser.user_id);

    if (authUserError || !authUser?.user?.email) {
      return json({
        success: true,
        message:
          "إذا كان الحساب موجوداً فسيصل رمز استعادة كلمة المرور إلى البريد الإلكتروني.",
      });
    }

    const resolvedEmail = normalizeEmail(authUser.user.email);
    const otp = generateOtp();
    const otpHash = await sha256(otp);
    const now = new Date();
    const expiresAt = new Date(now.getTime() + 15 * 60 * 1000).toISOString();

    await serviceClient
      .from("password_reset_otps")
      .update({ consumed_at: now.toISOString(), updated_at: now.toISOString() })
      .eq("email", resolvedEmail)
      .is("consumed_at", null);

    const { error: insertError } = await serviceClient
      .from("password_reset_otps")
      .insert({
        user_id: shopUser.user_id,
        email: resolvedEmail,
        otp_hash: otpHash,
        expires_at: expiresAt,
      });

    if (insertError) {
      return json({ error: insertError.message }, 500);
    }

    await sendEmail({
      apiKey: resendApiKey,
      from: fromEmail,
      to: resolvedEmail,
      otp,
    });

    return json({
      success: true,
      message:
        "إذا كان الحساب موجوداً فسيصل رمز استعادة كلمة المرور إلى البريد الإلكتروني.",
    });
  } catch (error) {
    const message =
      error instanceof Error ? error.message : "Unexpected server error.";
    return json({ error: message }, 500);
  }
});
