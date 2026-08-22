/*
# Complete service_requests pipeline
- Add admin_notes, updated_at columns
- Expand status check to include quoted/booked
- Auto-update updated_at on row change
*/

ALTER TABLE service_requests
  ADD COLUMN IF NOT EXISTS admin_notes text,
  ADD COLUMN IF NOT EXISTS updated_at timestamptz NOT NULL DEFAULT now();

-- Expand status constraint to include quoted/booked
ALTER TABLE service_requests DROP CONSTRAINT IF EXISTS service_requests_status_check;
ALTER TABLE service_requests ADD CONSTRAINT service_requests_status_check
  CHECK (status IN ('new','contacted','quoted','booked','closed'));

-- Auto-update updated_at on row change
DROP TRIGGER IF EXISTS service_requests_updated_at ON service_requests;
CREATE TRIGGER service_requests_updated_at
  BEFORE UPDATE ON service_requests
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
