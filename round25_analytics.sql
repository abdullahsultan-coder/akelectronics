-- =========================================================
-- AK ELECTRONICS PRO — ROUND 25: WEBSITE ANALYTICS
-- Run this in Supabase SQL Editor.
-- Tracks page visits and important clicks (WhatsApp, Add to
-- Cart, Order Placed) so the Admin Panel can show real traffic
-- numbers instead of guessing from Search Console/social media.
-- =========================================================

create table if not exists public.analytics_events (
  id uuid primary key default gen_random_uuid(),
  event_type text not null,       -- 'page_view' | 'whatsapp_click' | 'add_to_cart' | 'order_placed' | 'product_view'
  page_path text,                 -- e.g. '/' or '/index.html'
  product_id uuid,                -- filled only for product_view / add_to_cart
  referrer text,                  -- document.referrer (google, facebook, instagram, direct, etc.)
  device_type text,               -- 'mobile' | 'desktop'
  session_id text,                -- random id generated per browser visit, lets us count unique visitors
  created_at timestamptz not null default now()
);

create index if not exists analytics_events_created_at_idx on public.analytics_events (created_at);
create index if not exists analytics_events_event_type_idx on public.analytics_events (event_type);

alter table public.analytics_events enable row level security;

-- Anyone (even not logged in) can INSERT an event — this is how the
-- public website reports a visit/click. No one can read/update/delete
-- from the client except admins (checked in admin.js via the agent
-- login, same pattern as other admin-only tables).
create policy "Anyone can log an analytics event"
  on public.analytics_events for insert
  with check (true);

create policy "Only admins can read analytics"
  on public.analytics_events for select
  using (auth.jwt() ->> 'email' = 'abdullahsultan6@gmail.com');
