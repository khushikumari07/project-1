-- Function to safely disable RLS
create or replace function disable_rls()
returns void
language plpgsql
security definer
as $$
begin
  alter table profiles disable row level security;
end;
$$;