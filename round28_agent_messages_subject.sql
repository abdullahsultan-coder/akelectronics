-- =========================================================
-- AK ELECTRONICS PRO — ROUND 28: PROFESSIONAL AGENT MESSAGES
-- Run this AFTER round26_agent_messages.sql.
-- Adds a "subject" (professional category) field so messages
-- read like real business communication instead of plain chat.
-- =========================================================

alter table public.agent_messages
  add column if not exists subject text not null default 'General Update';
