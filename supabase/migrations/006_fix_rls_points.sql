-- Migration 006: Add missing INSERT/UPDATE RLS policies for points tables

-- user_points: allow user to insert and update their own row
create policy "user_points_insert_own"
  on public.user_points for insert
  with check (auth.uid() = user_id);

create policy "user_points_update_own"
  on public.user_points for update
  using (auth.uid() = user_id);

-- point_transactions: allow user to insert their own transactions
create policy "point_transactions_insert_own"
  on public.point_transactions for insert
  with check (auth.uid() = user_id);
