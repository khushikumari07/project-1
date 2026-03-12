import { createClient } from '@supabase/supabase-js';

// Using your project's URL and anon key from .env
const supabaseUrl = 'https://krawodmaojhwztjtkfhf.supabase.co';
const supabaseAnonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImtyYXdvZG1hb2pod3p0anRrZmhmIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjIwODA2MjksImV4cCI6MjA3NzY1NjYyOX0.WISNzAZZWfCz8_j6a-E8H39gDdMH33nk8qhNdpY73JE';

const supabase = createClient(supabaseUrl, supabaseAnonKey);

// Create an admin user
async function createAdminUser() {
    // Test user credentials
    const email = 'admin@test.com';
    const password = 'Admin123!';
    const fullName = 'Admin User';
    
    console.log('Creating admin user...');
    
    try {
        // 1. First disable RLS on profiles table
        const { error: rpcError } = await supabase.rpc('disable_rls');
        if (rpcError) {
            console.error('Error disabling RLS:', rpcError.message);
            return;
        }

        // 2. Sign up the user
        const { data: authData, error: signUpError } = await supabase.auth.signUp({
            email,
            password,
            options: {
                data: {
                    full_name: fullName,
                }
            }
        });

        if (signUpError) {
            console.error('Error creating user:', signUpError.message);
            return;
        }

        console.log('User created successfully');

        if (!authData.user) {
            console.error('No user data returned');
            return;
        }

        // 3. Create profile entry
        const { error: profileError } = await supabase
            .from('profiles')
            .insert({
                id: authData.user.id,
                email: email,
                full_name: fullName,
                role: 'admin'
            });

        if (profileError) {
            console.error('Error creating profile:', profileError.message);
            return;
        }

        console.log('Success! Use these credentials to log in:');
        console.log('----------------------------------------');
        console.log('Email:', email);
        console.log('Password:', password);
        console.log('----------------------------------------');
        console.log('1. Go to http://localhost:5173/ (or :5174)');
        console.log('2. Enter these credentials');
        console.log('3. Click Sign In');

    } catch (error) {
        console.error('Unexpected error:', error);
    }
}

createAdminUser();