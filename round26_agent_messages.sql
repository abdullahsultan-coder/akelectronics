-- =========================================================
-- AK ELECTRONICS PRO — ROUND 26: AGENT MESSAGES (personal notes)
-- Run this in Supabase SQL Editor.
-- Lets Admin send a personal message to Products Agent or
-- Projects Agent (optionally linked to a specific product/
-- project), separate from the existing customer-inquiry
-- forwarding in the "messages" table.
-- =========================================================

create table if not exists public.agent_messages (
  id uuid primary key default gen_random_uuid(),
  from_role text not null,        -- 'admin' | 'products_agent' | 'projects_agent' | 'full_agent'
  to_role text not null,          -- who this message is FOR: 'admin' | 'products_agent' | 'projects_agent'
  item_id uuid references public.products(id) on delete set null,  -- optional: the product/project this is about
  message text not null,
  is_read boolean not null default false,
  created_at timestamptz not null default now()
);

create index if not exists agent_messages_to_role_idx on public.agent_messages (to_role);
create index if not exists agent_messages_created_at_idx on public.agent_messages (created_at);

alter table public.agent_messages enable row level security;

-- Admin (by email) can insert and read everything
create policy "Admin full access to agent_messages"
  on public.agent_messages for all
  using (auth.jwt() ->> 'email' = 'abdullahsultan6@gmail.com')
  with check (auth.jwt() ->> 'email' = 'abdullahsultan6@gmail.com');

-- Products agent can insert messages (replies) and read only
-- messages addressed to (or sent by) products_agent
create policy "Products agent can send agent_messages"
  on public.agent_messages for insert
  with check (
    (auth.jwt() -> 'user_metadata' ->> 'role') in ('products_agent','full_agent')
  );

create policy "Products agent can read own agent_messages"
  on public.agent_messages for select
  using (
    (auth.jwt() -> 'user_metadata' ->> 'role') = 'products_agent'
    and to_role = 'products_agent'
  );

-- Projects agent — same pattern
create policy "Projects agent can send agent_messages"
  on public.agent_messages for insert
  with check (
    (auth.jwt() -> 'user_metadata' ->> 'role') in ('projects_agent','full_agent')
  );

create policy "Projects agent can read own agent_messages"
  on public.agent_messages for select
  using (
    (auth.jwt() -> 'user_metadata' ->> 'role') = 'projects_agent'
    and to_role = 'projects_agent'
  );

-- Full (combined) agent — reads messages addressed to EITHER agent role
create policy "Full agent can read all agent messages"
  on public.agent_messages for select
  using (
    (auth.jwt() -> 'user_metadata' ->> 'role') = 'full_agent'
    and to_role in ('products_agent','projects_agent')
  );

-- Agents can mark their own incoming messages as read
create policy "Agents can update read status"
  on public.agent_messages for update
  using (
    (auth.jwt() -> 'user_metadata' ->> 'role') in ('products_agent','projects_agent','full_agent')
  )
  with check (
    (auth.jwt() -> 'user_metadata' ->> 'role') in ('products_agent','projects_agent','full_agent')
  );
