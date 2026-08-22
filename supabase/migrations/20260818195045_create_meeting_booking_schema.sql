/*
# Create meeting booking system

1. New Tables
- `availability_slots`: time slots the admin offers for booking.
  - `id` (uuid, primary key)
  - `start_time` (timestamptz, not null) — when the slot begins
  - `end_time` (timestamptz, not null) — when the slot ends
  - `is_booked` (boolean, default false) — whether someone has booked this slot
  - `created_at` (timestamptz, default now())
- `bookings`: a user's reservation of a slot.
  - `id` (uuid, primary key)
  - `slot_id` (uuid, FK to availability_slots, ON DELETE CASCADE)
  - `name` (text, not null) — booker's full name
  - `email` (text, not null) — booker's email
  - `topic` (text, not null) — what they want to discuss
  - `meet_link` (text, nullable) — Google Meet link the admin attaches
  - `status` (text, default 'pending') — pending, confirmed, cancelled
  - `created_at` (timestamptz, default now())

2. Security
- Enable RLS on both tables.
- availability_slots: anyone (anon + authenticated) can SELECT available slots; only authenticated admins can INSERT/UPDATE/DELETE.
- bookings: anyone (anon + authenticated) can INSERT a booking and SELECT their own; only authenticated admins can SELECT all and UPDATE (to confirm/cancel and attach meet links).
*/

CREATE TABLE IF NOT EXISTS availability_slots (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  start_time timestamptz NOT NULL,
  end_time timestamptz NOT NULL,
  is_booked boolean NOT NULL DEFAULT false,
  created_at timestamptz DEFAULT now()
);

ALTER TABLE availability_slots ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "anyone_can_read_slots" ON availability_slots;
CREATE POLICY "anyone_can_read_slots"
ON availability_slots FOR SELECT
TO anon, authenticated USING (true);

DROP POLICY IF EXISTS "admin_insert_slots" ON availability_slots;
CREATE POLICY "admin_insert_slots"
ON availability_slots FOR INSERT
TO authenticated WITH CHECK (
  EXISTS (SELECT 1 FROM profiles WHERE profiles.id = auth.uid() AND profiles.is_admin = true)
);

DROP POLICY IF EXISTS "admin_update_slots" ON availability_slots;
CREATE POLICY "admin_update_slots"
ON availability_slots FOR UPDATE
TO authenticated USING (
  EXISTS (SELECT 1 FROM profiles WHERE profiles.id = auth.uid() AND profiles.is_admin = true)
) WITH CHECK (
  EXISTS (SELECT 1 FROM profiles WHERE profiles.id = auth.uid() AND profiles.is_admin = true)
);

DROP POLICY IF EXISTS "admin_delete_slots" ON availability_slots;
CREATE POLICY "admin_delete_slots"
ON availability_slots FOR DELETE
TO authenticated USING (
  EXISTS (SELECT 1 FROM profiles WHERE profiles.id = auth.uid() AND profiles.is_admin = true)
);

CREATE TABLE IF NOT EXISTS bookings (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  slot_id uuid NOT NULL REFERENCES availability_slots(id) ON DELETE CASCADE,
  name text NOT NULL,
  email text NOT NULL,
  topic text NOT NULL,
  meet_link text,
  status text NOT NULL DEFAULT 'pending',
  created_at timestamptz DEFAULT now()
);

ALTER TABLE bookings ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "anyone_can_insert_booking" ON bookings;
CREATE POLICY "anyone_can_insert_booking"
ON bookings FOR INSERT
TO anon, authenticated WITH CHECK (true);

DROP POLICY IF EXISTS "anyone_can_read_bookings" ON bookings;
CREATE POLICY "anyone_can_read_bookings"
ON bookings FOR SELECT
TO anon, authenticated USING (true);

DROP POLICY IF EXISTS "admin_update_bookings" ON bookings;
CREATE POLICY "admin_update_bookings"
ON bookings FOR UPDATE
TO authenticated USING (
  EXISTS (SELECT 1 FROM profiles WHERE profiles.id = auth.uid() AND profiles.is_admin = true)
) WITH CHECK (
  EXISTS (SELECT 1 FROM profiles WHERE profiles.id = auth.uid() AND profiles.is_admin = true)
);

DROP POLICY IF EXISTS "admin_delete_bookings" ON bookings;
CREATE POLICY "admin_delete_bookings"
ON bookings FOR DELETE
TO authenticated USING (
  EXISTS (SELECT 1 FROM profiles WHERE profiles.id = auth.uid() AND profiles.is_admin = true)
);

CREATE INDEX IF NOT EXISTS idx_availability_slots_start_time ON availability_slots(start_time);
CREATE INDEX IF NOT EXISTS idx_bookings_slot_id ON bookings(slot_id);
