begin;

drop policy if exists password_reset_blocked on public.password_reset_otps;

create policy password_reset_blocked
on public.password_reset_otps
for all
to anon, authenticated
using (false)
with check (false);

revoke update on table public.order_status_history from authenticated;
revoke update on table public.favorites from authenticated;

commit;
