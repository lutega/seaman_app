-- Migration 003: Admin role setup
-- Admin is identified by app_metadata->>'role' = 'admin'
-- Set via Supabase Dashboard: Authentication > Users > Edit User > app_metadata
-- Or via service key: supabase.auth.admin.updateUserById(id, { app_metadata: { role: 'admin' } })

-- Helper function to check admin role
create or replace function public.is_admin()
returns boolean
language sql
security definer
stable
as $$
  select coalesce(
    (auth.jwt() -> 'app_metadata' ->> 'role') = 'admin',
    false
  )
$$;

-- ─── Admin RLS policies ───────────────────────────────────────────────────────

-- Admin can read ALL profiles (for verification workflow)
create policy "profiles_admin_select"
  on public.profiles for select
  using (public.is_admin());

-- Admin can update ANY profile (approve/reject verification)
create policy "profiles_admin_update"
  on public.profiles for update
  using (public.is_admin());

-- Admin can read ALL certificates (for verification)
create policy "certificates_admin_select"
  on public.certificates for select
  using (public.is_admin());

-- Admin can update ANY certificate (mark as verified)
create policy "certificates_admin_update"
  on public.certificates for update
  using (public.is_admin());

-- Admin can manage partners (CRUD)
create policy "partners_admin_all"
  on public.partners for all
  using (public.is_admin())
  with check (public.is_admin());

-- Admin can manage courses (CRUD)
create policy "courses_admin_all"
  on public.courses for all
  using (public.is_admin())
  with check (public.is_admin());

-- Admin can read ALL enrollments (for commission tracking)
create policy "enrollments_admin_select"
  on public.enrollments for select
  using (public.is_admin());

-- Admin can update enrollments (confirm/cancel)
create policy "enrollments_admin_update"
  on public.enrollments for update
  using (public.is_admin());

-- Admin can manage quests
create policy "quests_admin_all"
  on public.quests for all
  using (public.is_admin())
  with check (public.is_admin());

-- Admin can read ALL point transactions
create policy "point_transactions_admin_select"
  on public.point_transactions for select
  using (public.is_admin());

-- Admin can insert point transactions (manual award)
create policy "point_transactions_admin_insert"
  on public.point_transactions for insert
  with check (public.is_admin());

-- Admin can read ALL user points
create policy "user_points_admin_select"
  on public.user_points for select
  using (public.is_admin());

-- Admin can read documents in user-documents bucket
create policy "user_documents_admin_read"
  on storage.objects for select
  using (
    bucket_id = 'user-documents'
    and public.is_admin()
  );

-- ─── Useful admin views ───────────────────────────────────────────────────────

-- View: profiles pending verification
create or replace view public.admin_pending_profiles as
  select
    p.id,
    p.full_name,
    p.birth_date,
    p.nik_last_4,
    p.seafarer_number,
    p.verification_status,
    p.created_at,
    u.email
  from public.profiles p
  join auth.users u on u.id = p.id
  where p.verification_status = 'pending'
  order by p.created_at asc;

-- View: enrollment summary for commission tracking
create or replace view public.admin_enrollments_summary as
  select
    e.id,
    e.created_at,
    e.referral_clicked_at,
    e.partner_confirmed_at,
    e.partner_confirmed_status,
    e.commission_amount_idr,
    p.full_name as user_name,
    u.email as user_email,
    c.name as course_name,
    c.price_idr,
    pt.name as partner_name,
    pt.referral_slug
  from public.enrollments e
  join public.profiles p on p.id = e.user_id
  join auth.users u on u.id = e.user_id
  join public.courses c on c.id = e.course_id
  join public.partners pt on pt.id = c.partner_id
  order by e.created_at desc;
