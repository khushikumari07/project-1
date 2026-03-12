-- Step 1: Remove existing RLS policies that might interfere
DROP POLICY IF EXISTS "Users can view own profile" ON profiles;
DROP POLICY IF EXISTS "Users can update own profile" ON profiles;
DROP POLICY IF EXISTS "Admins can view all profiles" ON profiles;
DROP POLICY IF EXISTS "Allow authenticated users to create their profile" ON profiles;

-- Step 2: Create a new, permissive policy for profiles
CREATE POLICY "Enable all access for authenticated users" ON profiles
  FOR ALL
  TO authenticated
  USING (true)
  WITH CHECK (true);

-- Step 3: Create a test user directly in the database
INSERT INTO auth.users (
  instance_id,
  id,
  aud,
  role,
  email,
  encrypted_password,
  email_confirmed_at,
  raw_app_meta_data,
  raw_user_meta_data,
  created_at
) VALUES (
  '00000000-0000-0000-0000-000000000000',
  gen_random_uuid(),
  'authenticated',
  'authenticated',
  'demo@example.com',
  crypt('password123', gen_salt('bf')),
  now(),
  '{"provider":"email","providers":["email"]}',
  '{"full_name":"Demo User"}',
  now()
);

-- Step 4: Add profile for the test user
WITH new_user AS (
  SELECT id, email FROM auth.users WHERE email = 'demo@example.com' LIMIT 1
)
INSERT INTO public.profiles (id, email, full_name, role)
SELECT id, email, 'Demo User', 'staff'
FROM new_user;