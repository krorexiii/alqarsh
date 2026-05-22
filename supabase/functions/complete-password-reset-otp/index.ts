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
    const resetToken = String(payload?.reset_token ?? "").trim();
    const newPassword = String(payload?.new_password ?? "");

    if (!email || !resetToken || !newPassword) {
      return json(
        { error: "Email, reset token, and new password are required." },
        400,
      );
    }

    if (newPassword.length < 8) {
      return json({ error: "كلمة المرور يجب أن تكون 8 أحرف على الأقل." }, 400);
    }

    const serviceClient = createClient(supabaseUrl, supabaseServiceRoleKey);

    const { data: rows, error: fetchError } = await serviceClient
      .from("password_reset_otps")
      .select("*")
      .eq("email", email)
      .is("consumed_at", null)
      .not("verified_at", "is", null)
      .order("verified_at", { ascending: false })
      .limit(1);

    if (fetchError) {
      return json({ error: fetchError.message }, 500);
    }

    const otpRow = rows?.[0];
    if (!otpRow || !otpRow.reset_token_hash || !otpRow.user_id) {
      return json({ error: "جلسة استعادة كلمة المرور غير صالحة." }, 400);
    }

    if (
      !otpRow.reset_token_expires_at ||
      new Date(otpRow.reset_token_expires_at).getTime() < Date.now()
    ) {
      return json({ error: "جلسة استعادة كلمة المرور انتهت صلاحيتها." }, 400);
    }

    const resetTokenHash = await sha256(resetToken);
    if (resetTokenHash !== otpRow.reset_token_hash) {
      return json({ error: "جلسة استعادة كلمة المرور غير صالحة." }, 400);
    }

    const { error: updateUserError } = await serviceClient.auth.admin
      .updateUserById(otpRow.user_id, {
        password: newPassword,
      });

    if (updateUserError) {
      return json({ error: updateUserError.message }, 400);
    }

    const nowIso = new Date().toISOString();

    await serviceClient
      .from("password_reset_otps")
      .update({
        consumed_at: nowIso,
        updated_at: nowIso,
      })
      .eq("id", otpRow.id);

    return json({
      success: true,
      message: "تم تحديث كلمة المرور بنجاح.",
    });
  } catch (error) {
    const message =
      error instanceof Error ? error.message : "Unexpected server error.";
    return json({ error: message }, 500);
  }
});
