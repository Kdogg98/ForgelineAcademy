/*
# Service requests table
Stores on-site training and troubleshooting support requests from the public Services page.
*/

CREATE TABLE service_requests (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  name text NOT NULL,
  company text,
  email text NOT NULL,
  phone text,
  service_type text NOT NULL CHECK (service_type IN ('onsite_training','troubleshooting','both')),
  message text,
  status text NOT NULL DEFAULT 'new' CHECK (status IN ('new','contacted','closed')),
  created_at timestamptz NOT NULL DEFAULT now()
);

CREATE INDEX idx_service_requests_status ON service_requests(status);
CREATE INDEX idx_service_requests_created ON service_requests(created_at DESC);

ALTER TABLE service_requests ENABLE ROW LEVEL SECURITY;

-- Anyone (including anon) can submit a request
CREATE POLICY "anyone_insert_service_requests" ON service_requests
  FOR INSERT TO anon, authenticated WITH CHECK (true);

-- Only authenticated admins can read/update
CREATE POLICY "admins_read_service_requests" ON service_requests
  FOR SELECT TO authenticated USING (
    EXISTS (SELECT 1 FROM profiles p WHERE p.id = auth.uid() AND p.is_admin = true)
  );

CREATE POLICY "admins_update_service_requests" ON service_requests
  FOR UPDATE TO authenticated USING (
    EXISTS (SELECT 1 FROM profiles p WHERE p.id = auth.uid() AND p.is_admin = true)
  ) WITH CHECK (
    EXISTS (SELECT 1 FROM profiles p WHERE p.id = auth.uid() AND p.is_admin = true)
  );
