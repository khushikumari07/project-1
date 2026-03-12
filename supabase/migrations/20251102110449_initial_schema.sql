/*
  # Food Waste Monitoring System - Initial Schema

  1. New Tables
    - `profiles`
      - `id` (uuid, primary key, references auth.users)
      - `email` (text)
      - `full_name` (text)
      - `role` (text) - 'admin', 'staff', 'manager'
      - `created_at` (timestamp)
    
    - `meal_categories`
      - `id` (uuid, primary key)
      - `name` (text) - breakfast, lunch, dinner, snacks
      - `typical_time` (text)
      - `created_at` (timestamp)
    
    - `meal_preparations`
      - `id` (uuid, primary key)
      - `meal_category_id` (uuid, foreign key)
      - `date` (date)
      - `quantity_prepared` (numeric) - in kg or portions
      - `estimated_servings` (integer)
      - `unit` (text) - 'kg', 'portions'
      - `notes` (text)
      - `prepared_by` (uuid, foreign key to profiles)
      - `created_at` (timestamp)
    
    - `meal_distributions`
      - `id` (uuid, primary key)
      - `meal_preparation_id` (uuid, foreign key)
      - `quantity_served` (numeric)
      - `servings_count` (integer)
      - `recorded_by` (uuid, foreign key to profiles)
      - `recorded_at` (timestamp)
    
    - `waste_records`
      - `id` (uuid, primary key)
      - `meal_preparation_id` (uuid, foreign key)
      - `waste_quantity` (numeric) - in kg or portions
      - `waste_type` (text) - 'plate_waste', 'preparation_excess', 'spoilage'
      - `reason` (text)
      - `recorded_by` (uuid, foreign key to profiles)
      - `recorded_at` (timestamp)
    
    - `daily_summaries`
      - `id` (uuid, primary key)
      - `date` (date, unique)
      - `total_prepared` (numeric)
      - `total_served` (numeric)
      - `total_wasted` (numeric)
      - `waste_percentage` (numeric)
      - `updated_at` (timestamp)

  2. Security
    - Enable RLS on all tables
    - Add policies for authenticated users based on roles
    - Admins and managers can view all data
    - Staff can record data and view their own records
*/

CREATE TABLE IF NOT EXISTS profiles (
  id uuid PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  email text NOT NULL,
  full_name text NOT NULL,
  role text NOT NULL DEFAULT 'staff',
  created_at timestamptz DEFAULT now()
);

CREATE TABLE IF NOT EXISTS meal_categories (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  name text UNIQUE NOT NULL,
  typical_time text NOT NULL,
  created_at timestamptz DEFAULT now()
);

CREATE TABLE IF NOT EXISTS meal_preparations (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  meal_category_id uuid REFERENCES meal_categories(id) NOT NULL,
  date date NOT NULL,
  quantity_prepared numeric NOT NULL,
  estimated_servings integer NOT NULL,
  unit text NOT NULL DEFAULT 'kg',
  notes text DEFAULT '',
  prepared_by uuid REFERENCES profiles(id) NOT NULL,
  created_at timestamptz DEFAULT now()
);

CREATE TABLE IF NOT EXISTS meal_distributions (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  meal_preparation_id uuid REFERENCES meal_preparations(id) ON DELETE CASCADE NOT NULL,
  quantity_served numeric NOT NULL,
  servings_count integer NOT NULL,
  recorded_by uuid REFERENCES profiles(id) NOT NULL,
  recorded_at timestamptz DEFAULT now()
);

CREATE TABLE IF NOT EXISTS waste_records (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  meal_preparation_id uuid REFERENCES meal_preparations(id) ON DELETE CASCADE NOT NULL,
  waste_quantity numeric NOT NULL,
  waste_type text NOT NULL,
  reason text DEFAULT '',
  recorded_by uuid REFERENCES profiles(id) NOT NULL,
  recorded_at timestamptz DEFAULT now()
);

CREATE TABLE IF NOT EXISTS daily_summaries (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  date date UNIQUE NOT NULL,
  total_prepared numeric DEFAULT 0,
  total_served numeric DEFAULT 0,
  total_wasted numeric DEFAULT 0,
  waste_percentage numeric DEFAULT 0,
  updated_at timestamptz DEFAULT now()
);

ALTER TABLE profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE meal_categories ENABLE ROW LEVEL SECURITY;
ALTER TABLE meal_preparations ENABLE ROW LEVEL SECURITY;
ALTER TABLE meal_distributions ENABLE ROW LEVEL SECURITY;
ALTER TABLE waste_records ENABLE ROW LEVEL SECURITY;
ALTER TABLE daily_summaries ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view own profile"
  ON profiles FOR SELECT
  TO authenticated
  USING (auth.uid() = id);

CREATE POLICY "Users can update own profile"
  ON profiles FOR UPDATE
  TO authenticated
  USING (auth.uid() = id)
  WITH CHECK (auth.uid() = id);

CREATE POLICY "Admins can view all profiles"
  ON profiles FOR SELECT
  TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM profiles
      WHERE profiles.id = auth.uid()
      AND profiles.role IN ('admin', 'manager')
    )
  );

CREATE POLICY "Anyone can view meal categories"
  ON meal_categories FOR SELECT
  TO authenticated
  USING (true);

CREATE POLICY "Admins can manage meal categories"
  ON meal_categories FOR ALL
  TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM profiles
      WHERE profiles.id = auth.uid()
      AND profiles.role = 'admin'
    )
  );

CREATE POLICY "Authenticated users can view meal preparations"
  ON meal_preparations FOR SELECT
  TO authenticated
  USING (true);

CREATE POLICY "Staff can create meal preparations"
  ON meal_preparations FOR INSERT
  TO authenticated
  WITH CHECK (
    auth.uid() = prepared_by
  );

CREATE POLICY "Staff can update own meal preparations"
  ON meal_preparations FOR UPDATE
  TO authenticated
  USING (auth.uid() = prepared_by)
  WITH CHECK (auth.uid() = prepared_by);

CREATE POLICY "Authenticated users can view distributions"
  ON meal_distributions FOR SELECT
  TO authenticated
  USING (true);

CREATE POLICY "Staff can create distributions"
  ON meal_distributions FOR INSERT
  TO authenticated
  WITH CHECK (
    auth.uid() = recorded_by
  );

CREATE POLICY "Authenticated users can view waste records"
  ON waste_records FOR SELECT
  TO authenticated
  USING (true);

CREATE POLICY "Staff can create waste records"
  ON waste_records FOR INSERT
  TO authenticated
  WITH CHECK (
    auth.uid() = recorded_by
  );

CREATE POLICY "Staff can update own waste records"
  ON waste_records FOR UPDATE
  TO authenticated
  USING (auth.uid() = recorded_by)
  WITH CHECK (auth.uid() = recorded_by);

CREATE POLICY "Authenticated users can view daily summaries"
  ON daily_summaries FOR SELECT
  TO authenticated
  USING (true);

CREATE POLICY "System can manage daily summaries"
  ON daily_summaries FOR ALL
  TO authenticated
  USING (true)
  WITH CHECK (true);

INSERT INTO meal_categories (name, typical_time) VALUES
  ('Breakfast', '07:00 - 09:00'),
  ('Lunch', '12:00 - 14:00'),
  ('Dinner', '19:00 - 21:00'),
  ('Snacks', '16:00 - 17:00')
ON CONFLICT (name) DO NOTHING;