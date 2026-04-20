-- Migration 002: Storage bucket policies (idempotent)
-- Run AFTER creating buckets manually in Supabase Dashboard:
--   1. "user-documents" (private)
--   2. "partner-assets" (public)

-- ─── Drop existing policies first (safe re-run) ───────────────────────────────
drop policy if exists "user_documents_insert_own" on storage.objects;
drop policy if exists "user_documents_select_own" on storage.objects;
drop policy if exists "user_documents_update_own" on storage.objects;
drop policy if exists "user_documents_delete_own" on storage.objects;
drop policy if exists "partner_assets_public_read" on storage.objects;
drop policy if exists "user_documents_admin_read"  on storage.objects;

-- ─── user-documents: private, users only access their own folder ──────────────

create policy "user_documents_insert_own"
  on storage.objects for insert
  with check (
    bucket_id = 'user-documents'
    and auth.uid()::text = (storage.foldername(name))[1]
  );

create policy "user_documents_select_own"
  on storage.objects for select
  using (
    bucket_id = 'user-documents'
    and auth.uid()::text = (storage.foldername(name))[1]
  );

create policy "user_documents_update_own"
  on storage.objects for update
  using (
    bucket_id = 'user-documents'
    and auth.uid()::text = (storage.foldername(name))[1]
  );

create policy "user_documents_delete_own"
  on storage.objects for delete
  using (
    bucket_id = 'user-documents'
    and auth.uid()::text = (storage.foldername(name))[1]
  );

-- ─── partner-assets: public read, admin write only ────────────────────────────

create policy "partner_assets_public_read"
  on storage.objects for select
  using (bucket_id = 'partner-assets');
