import { createClient } from '@supabase/supabase-js';

const supabaseUrl = 'https://krawodmaojhwztjtkfhf.supabase.co';
const supabaseAnonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImtyYXdvZG1hb2pod3p0anRrZmhmIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjIwODA2MjksImV4cCI6MjA3NzY1NjYyOX0.WISNzAZZWfCz8_j6a-E8H39gDdMH33nk8qhNdpY73JE';

const supabase = createClient(supabaseUrl, supabaseAnonKey);

async function createTestUser() {
  const email = 'test@example.com';
  const password = 'Password123!';
  const fullName = 'Test User';
  
  console.log('Creating test user...');
  
  // 1. Sign up the user
  const { data: authData, error: signUpError } = await supabase.auth.signUp({
    email,
    password,
    options: {
      data: {
        full_name: fullName
      }
    }
  });

  if (signUpError) {
    console.error('Error creating user:', signUpError.message);
    return;
  }

  if (!authData.user) {
    console.error('No user data returned');
    return;
  }

  console.log('User created successfully:', authData.user.id);

  // 2. Insert the profile with service role
  const { error: profileError } = await supabase
    .from('profiles')
    .insert({
      id: authData.user.id,
      email: email,
      full_name: fullName,
      role: 'staff'
    });

  if (profileError) {
    console.error('Error creating profile:', profileError.message);
    return;
  }

  console.log('Success! Use these credentials to log in:');
  console.log('Email:', email);
  console.log('Password:', password);
}

createTestUser().catch(console.error);