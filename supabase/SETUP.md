# Supabase Setup Guide

## Langkah-langkah setup (jalankan berurutan)

### 1. Buat Project Supabase
1. Buka https://supabase.com/dashboard
2. New Project → isi nama "seaready-prod" (atau "seaready-dev" untuk development)
3. Pilih region: Southeast Asia (Singapore)
4. Catat: `Project URL` dan `anon public key`

### 2. Konfigurasi App
Edit file `lib/core/config/app_config.dart`:
```dart
static const supabaseUrl = 'https://XXXX.supabase.co';
static const supabaseAnonKey = 'eyJhbGc...';
```

Atau pakai `--dart-define` di launch config VS Code / run command:
```bash
flutter run \
  --dart-define=SUPABASE_URL=https://XXXX.supabase.co \
  --dart-define=SUPABASE_ANON_KEY=eyJhbGc...
```

### 3. Run Migrations (Supabase SQL Editor)
Jalankan file berikut **berurutan**:
```
supabase/migrations/001_initial_schema.sql
supabase/migrations/002_storage_policies.sql  ← setelah buat bucket
supabase/migrations/003_admin_roles.sql
supabase/migrations/004_quest_trigger.sql
supabase/migrations/005_redeem_rpc.sql
```

### 4. Buat Storage Buckets
Di Supabase Dashboard → Storage → New Bucket:
| Bucket name | Public | Max file size |
|---|---|---|
| `user-documents` | No (private) | 10 MB |
| `partner-assets` | Yes (public) | 2 MB |

Lalu jalankan `002_storage_policies.sql`.

### 5. Auth Config
Di Supabase Dashboard → Authentication → Settings:
- **Site URL:** `io.supabase.seaready://login-callback/` (untuk mobile deep link)
- **Redirect URLs:** tambahkan `io.supabase.seaready://login-callback/`

Email Templates (Authentication → Email Templates):
- Ganti subject dan body ke Bahasa Indonesia (opsional)

### 6. Google OAuth (Fase 2)
1. Buat OAuth credentials di [Google Cloud Console](https://console.cloud.google.com)
2. Di Supabase → Authentication → Providers → Google
3. Isi Client ID + Client Secret
4. Tambahkan Authorized redirect URI: `https://XXXX.supabase.co/auth/v1/callback`

### 7. Run Seed Data
```
supabase/seed/001_partners.sql
supabase/seed/002_pmtc_courses.sql
```

### 8. Set Admin User
Setelah register akun admin, jalankan di SQL Editor:
```sql
-- Ganti dengan email admin
update auth.users
set raw_app_meta_data = raw_app_meta_data || '{"role": "admin"}'
where email = 'admin@seaready.id';
```

### 9. Deploy Edge Functions (Fase 2)
Install Supabase CLI:
```bash
npm install -g supabase
supabase login
supabase link --project-ref XXXX
```

Deploy:
```bash
supabase functions deploy notify-expiry
supabase functions deploy track-referral
supabase functions deploy award-points
```

Set secrets untuk Edge Functions:
```bash
supabase secrets set FCM_PROJECT_ID=your-project-id
supabase secrets set FCM_SERVER_KEY=your-server-key
```

Setup cron `notify-expiry` (di Supabase Dashboard → Database → Extensions → pg_cron):
```sql
select cron.schedule(
  'notify-expiry-daily',
  '0 0 * * *',   -- setiap hari jam 00:00 UTC = 07:00 WIB
  $$select net.http_post(
    url := 'https://XXXX.supabase.co/functions/v1/notify-expiry',
    headers := '{"Authorization": "Bearer SERVICE_KEY"}'::jsonb
  )$$
);
```

---

## Checklist Sebelum Launch

- [ ] Semua migrations berhasil dijalankan
- [ ] Storage buckets dibuat + policies aktif
- [ ] Seed data PMTC kursus terlihat di app
- [ ] Register akun → profil tersimpan di `profiles`
- [ ] Upload KTP → file muncul di Storage `user-documents`
- [ ] Add certificate → data di `certificates`
- [ ] Enrollment kursus → row di `enrollments` + 8 rows di `quests`
- [ ] Redeem poin → `user_points` berkurang, `point_transactions` tercatat
- [ ] Admin bisa lihat `admin_pending_profiles` view
