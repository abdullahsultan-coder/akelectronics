-- =========================================================
-- AK ELECTRONICS PRO — ROUND 27: COMBINED "FULL AGENT" ROLE
-- Run this in Supabase SQL Editor, AFTER round26_agent_messages.sql.
--
-- Gives a new role, 'full_agent', the SAME combined access that
-- products_agent + projects_agent have together — full a-to-z
-- control of both Products and Exhibition Projects sections,
-- in one single login.
--
-- To create this agent: Authentication > Users > Add user (their
-- own email/password), then run assign_agent_roles.sql's
-- full_agent block for that email.
-- =========================================================

-- ---------------------------------------------------------
-- PRODUCTS (both product-type and project-type rows)
-- ---------------------------------------------------------
create policy "Full agent can insert products"
  on public.products for insert
  with check ((auth.jwt() -> 'user_metadata' ->> 'role') = 'full_agent');

create policy "Full agent can update products"
  on public.products for update
  using ((auth.jwt() -> 'user_metadata' ->> 'role') = 'full_agent');

create policy "Full agent can delete products"
  on public.products for delete
  using ((auth.jwt() -> 'user_metadata' ->> 'role') = 'full_agent');

-- ---------------------------------------------------------
-- CUSTOM INQUIRIES (both types)
-- ---------------------------------------------------------
create policy "Full agent can view all inquiries"
  on public.custom_inquiries for select
  using ((auth.jwt() -> 'user_metadata' ->> 'role') = 'full_agent');

create policy "Full agent can update all inquiries"
  on public.custom_inquiries for update
  using ((auth.jwt() -> 'user_metadata' ->> 'role') = 'full_agent');

-- ---------------------------------------------------------
-- ORDER_ITEMS + ORDERS (both types, reuses existing helper function)
-- ---------------------------------------------------------
create policy "Full agent can view all order items"
  on public.order_items for select
  using ((auth.jwt() -> 'user_metadata' ->> 'role') = 'full_agent');

create policy "Full agent can view all orders"
  on public.orders for select
  using ((auth.jwt() -> 'user_metadata' ->> 'role') = 'full_agent');

create policy "Full agent can update all orders"
  on public.orders for update
  using ((auth.jwt() -> 'user_metadata' ->> 'role') = 'full_agent');

-- ---------------------------------------------------------
-- COUPONS (both applies_to types)
-- ---------------------------------------------------------
create policy "Full agent can view all coupons"
  on public.coupons for select
  using ((auth.jwt() -> 'user_metadata' ->> 'role') = 'full_agent');

create policy "Full agent can insert coupons"
  on public.coupons for insert
  with check ((auth.jwt() -> 'user_metadata' ->> 'role') = 'full_agent');

create policy "Full agent can update coupons"
  on public.coupons for update
  using ((auth.jwt() -> 'user_metadata' ->> 'role') = 'full_agent');

create policy "Full agent can delete coupons"
  on public.coupons for delete
  using ((auth.jwt() -> 'user_metadata' ->> 'role') = 'full_agent');

-- ---------------------------------------------------------
-- MESSAGES (forwarded to either agent)
-- ---------------------------------------------------------
create policy "Full agent can view all forwarded messages"
  on public.messages for select
  using (
    (sent_to_products_agent = true or sent_to_projects_agent = true)
    and (auth.jwt() -> 'user_metadata' ->> 'role') = 'full_agent'
  );

-- ---------------------------------------------------------
-- STORAGE (product/project images — same as both agents can already do)
-- ---------------------------------------------------------
create policy "Full agent can upload images"
  on storage.objects for insert
  with check (
    bucket_id = 'product-images'
    and (auth.jwt() -> 'user_metadata' ->> 'role') = 'full_agent'
  );

-- =========================================================
-- DONE. full_agent now has the same combined reach as
-- products_agent + projects_agent together.
-- =========================================================
