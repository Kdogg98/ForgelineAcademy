/*
# Create app_config table for server-side secrets

1. New Tables
- `app_config`: a simple key-value store for server-side configuration like API keys.
  - `key` (text, primary key) — the config name (e.g. 'OPENAI_API_KEY')
  - `value` (text, not null) — the config value
  - `updated_at` (timestamptz, default now())
2. Security
- Enable RLS on `app_config`.
- NO policies for anon or authenticated — the table is completely locked down.
- Only the service role (used by edge functions) can read/write, since it bypasses RLS.
*/

CREATE TABLE IF NOT EXISTS app_config (
  key text PRIMARY KEY,
  value text NOT NULL,
  updated_at timestamptz DEFAULT now()
);

ALTER TABLE app_config ENABLE ROW LEVEL SECURITY;
