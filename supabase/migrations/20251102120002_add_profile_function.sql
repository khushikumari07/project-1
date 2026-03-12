-- Create a secure function to handle profile creation
CREATE OR REPLACE FUNCTION create_profile_for_user(
  user_id uuid,
  user_email text,
  user_full_name text,
  user_role text
)
RETURNS void
LANGUAGE plpgsql
SECURITY DEFINER -- This makes the function run with elevated privileges
SET search_path = public -- Security best practice
AS $$
BEGIN
  INSERT INTO public.profiles (id, email, full_name, role)
  VALUES (user_id, user_email, user_full_name, user_role);
END;
$$;

-- Grant execute permission to authenticated users
GRANT EXECUTE ON FUNCTION create_profile_for_user TO authenticated;

-- Add an RLS policy that allows any authenticated user to execute this function
CREATE POLICY "Allow authenticated users to create their profile"
ON profiles FOR INSERT
TO authenticated
WITH CHECK (
  -- This ensures users can only create their own profile
  auth.uid() = id
);