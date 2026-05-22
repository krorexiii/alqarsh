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

const sha256 = async (value: string) => {
  const bytes = new TextEncoder().encode(value);
  const digest = await crypto.subtle.digest("SHA-256", bytes);
  return Array.from(new Uint8Array(digest))
    .map((b) => b.toString(16).padStart(2, "0"))
    .join("");
};

const generateResetToken = () => crypto.randomUUID() + crypto.randomUUID();

Deno.serve(async (req) => {
  if (req.method === "OPTIONS") {
    return new Response("ok", { headers: corsHeaders });
  }

  try {
    const supabaseUrl = Deno.env.get("SUPABASE_URL");
    const supabaseServiceRoleKey = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY");

    if (!supabaseUrl || !supabaseServiceRoleKey) {
      return json({ error: "Missing Supabase environment secrets." }, 500);
    }

    const payload = await req.json();
    const email = normalizeEmail(String(payload?.email ?? ""));
    const otp = String(payload?.otp ?? "").trim();

    if (!email || !otp) {
      return json({ error: "Email and OTP are required." }, 400);
    }

    const serviceClient = createClient(supabaseUrl, supabaseServiceRoleKey);
    const nowIso = new Date().toISOString();

    const { data: rows, error: fetchError } = await serviceClient
      .from("password_reset_otps")
      .select("*")
      .eq("email", email)
      .is("consumed_at", null)
      .order("created_at", { ascending: false })
      .limit(1);

    if (fetchError) {
      return json({ error: fetchError.message }, 500);
    }

    const otpRow = rows?.[0];
    if (!otpRow) {
      return json({ error: "رمز الاستعادة غير صالح أو منتهي الصلاحية." }, 400);
    }

    if (new Date(otpRow.expires_at).getTime() < Date.now()) {
      return json({ error: "رمز الاستعادة غير صالح أو منتهي الصلاحية." }, 400);
    }

    if ((otpRow.attempts ?? 0) >= 5) {
      return json({ error: "تم تجاوز عدد المحاولات المسموح بها." }, 400);
    }

    const otpHash = await sha256(otp);
    if (otpHash !== otpRow.otp_hash) {
      await serviceClient
        .from("password_reset_otps")
        .update({
          attempts: (otpRow.attempts ?? 0) + 1,
          updated_at: nowIso,
        })
        .eq("id", otpRow.id);

      return json({ error: "رمز الاستعادة غير صالح أو منتهي الصلاحية." }, 400);
    }

    const resetToken = generateResetToken();
    const resetTokenHash = await sha256(resetToken);
    const resetTokenExpiresAt = new Date(
      Date.now() + 10 * 60 * 1000,
    ).toISOString();

    const { error: updateError } = await serviceClient
      .from("password_reset_otps")
      .update({
        verified_at: nowIso,
        reset_token_hash: resetTokenHash,
        reset_token_expires_at: resetTokenExpiresAt,
        updated_at: nowIso,
      })
      .eq("id", otpRow.id);

    if (updateError) {
      return json({ error: updateError.message }, 500);
    }

    return json({
      success: true,
      reset_token: resetToken,
      message: "تم التحقق من الرمز بنجاح.",
    });
  } catch (error) {
    const message =
      error instanceof Error ? error.message : "Unexpected server error.";
    return json({ error: message }, 500);
  }
});
