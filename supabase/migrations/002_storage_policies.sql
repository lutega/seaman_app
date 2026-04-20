-- Migration 002: Storage bucket policies
-- Run AFTER creating buckets manually in Supabase Dashboard:
--   1. "user-documents" (private)
--   2. "partner-assets" (public)

-- ─── user-documents: private, users only access their own folder ──────────────

-- Users can upload to their own folder (user_id/*)
create policy "user_documents_insert_own"
  on storage.objects for insert
  with check (
    bucket_id = 'user-documents'
    and auth.uid()::text = (storage.foldername(name))[1]
  );

-- Users can read their own documents
create policy "user_documents_select_own"
  on storage.objects for select
  using (
    bucket_id = 'user-documents'
    and auth.uid()::text = (storage.foldername(name))[1]
  );

-- Users can update (re-upload) their own documents
create policy "user_documents_update_own"
  on storage.objects for update
  using (
    bucket_id = 'user-documents'
    and auth.uid()::text = (storage.foldername(name))[1]
  );

-- Users can delete their own documents
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
