import { createClient } from '@supabase/supabase-js';

// IMPORTANT: these values come from the project's .env
const supabaseUrl = 'https://krawodmaojhwztjtkfhf.supabase.co';
const supabaseAnonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImtyYXdvZG1hb2pod3p0anRrZmhmIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjIwODA2MjksImV4cCI6MjA3NzY1NjYyOX0.WISNzAZZWfCz8_j6a-E8H39gDdMH33nk8qhNdpY73JE';

const supabase = createClient(supabaseUrl, supabaseAnonKey);

const email = 'demo+app@test.invalid';
const password = 'Password123!';

async function run() {
  console.log('Creating user:', email);
  const { data: signupData, error: signupError } = await supabase.auth.signUp({ email, password });
  if (signupError) {
    console.error('Sign-up error:', signupError.message || signupError);
  } else {
    console.log('Sign-up response:', signupData);
  }

  console.log('Attempting sign-in...');
  const { data, error } = await supabase.auth.signInWithPassword({ email, password });
  if (error) {
    console.error('Sign-in error:', error.message || error);
    process.exitCode = 2;
  } else {
    console.log('Sign-in success. Session user id:', data.session?.user?.id);
  }
}

run().catch((err) => {
  console.error('Unexpected error:', err);
  process.exit(1);
});