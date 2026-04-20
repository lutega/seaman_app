# SeaReady — Project Plan

> Status legend: `not yet` · `in progress` · `tested` · `review` · `done`

---

## Fase 0 — Flutter MVP App
> Target: App bisa dijalankan di emulator/device, semua fitur core berjalan

| # | Item | Status |
|---|---|---|
| 0.1 | Project setup, folder structure, dependencies | `done` |
| 0.2 | Design system (colors, spacing, typography) | `done` |
| 0.3 | Shared widgets (SrButton, SrTextField, SrCard, SrBadge, SrLoadingView, SrEmptyState) | `done` |
| 0.4 | Auth flow (login, register, forgot password, email verification) | `done` |
| 0.5 | Profile setup & edit (NIK encrypt, upload KTP/selfie) | `done` |
| 0.6 | Course catalog (search, filter, infinite scroll, enrollment) | `done` |
| 0.7 | Certificate wallet (CRUD, upload dokumen, status tracking) | `done` |
| 0.8 | Quest system (8 steps per enrollment, points display) | `done` |
| 0.9 | Rewards & gamification (points dashboard, redeem voucher) | `done` |
| 0.10 | Home screen (greeting, urgent cert alert, quick actions) | `done` |
| 0.11 | Bottom nav shell + routing (go_router) | `done` |
| 0.12 | `flutter analyze` 0 errors 0 warnings | `done` |
| 0.13 | Push ke GitHub `lutega/seaman_app` | `done` |

---

## Fase 1 — Supabase Setup
> Target: Backend hidup, app connect ke Supabase real, data tersimpan

### 1.1 Project & Credentials

| # | Item | Status |
|---|---|---|
| 1.1.1 | Buat Supabase project baru | `done` |
| 1.1.2 | Simpan `SUPABASE_URL` dan `SUPABASE_ANON_KEY` ke `.env` / launch config | `done` |
| 1.1.3 | Update `app_config.dart` dengan credentials | `done` |

### 1.2 Database Schema

| # | Item | Status |
|---|---|---|
| 1.2.1 | Run `001_initial_schema.sql` (8 tables + RLS) | `done` |
| 1.2.2 | Run `002_storage_policies.sql` (bucket user-documents) | `done` |
| 1.2.3 | Run `003_admin_roles.sql` (app_metadata admin bypass) | `done` |
| 1.2.4 | Verifikasi RLS semua tabel di SQL Editor | `not yet` |

### 1.3 Auth Config

| # | Item | Status |
|---|---|---|
| 1.3.1 | Aktifkan Email provider + custom SMTP (opsional, gunakan Supabase default) | `not yet` |
| 1.3.2 | Kustomisasi email template (Bahasa Indonesia: confirm, reset password) | `not yet` |
| 1.3.3 | Set Site URL dan redirect URLs (untuk deep link post-verifikasi) | `not yet` |
| 1.3.4 | Aktifkan Google OAuth (Client ID + Secret dari Google Cloud Console) | `not yet` |

### 1.4 Storage

| # | Item | Status |
|---|---|---|
| 1.4.1 | Buat bucket `user-documents` (private) | `not yet` |
| 1.4.2 | Buat bucket `partner-assets` (public, untuk logo partner) | `not yet` |
| 1.4.3 | Apply RLS policy: user hanya akses folder `{user_id}/` | `not yet` |

### 1.5 Seed Data

| # | Item | Status |
|---|---|---|
| 1.5.1 | Run `seed/001_partners.sql` (PMTC data) | `not yet` |
| 1.5.2 | Run `seed/002_pmtc_courses.sql` (kursus aktif PMTC Q2 2026) | `not yet` |
| 1.5.3 | Verifikasi data tampil di app (CourseCatalogScreen) | `not yet` |

### 1.6 App Integration Test

| # | Item | Status |
|---|---|---|
| 1.6.1 | Register akun baru → data masuk ke `profiles` | `not yet` |
| 1.6.2 | Upload dokumen → file muncul di Storage bucket | `not yet` |
| 1.6.3 | Add certificate → row masuk ke `certificates` | `not yet` |
| 1.6.4 | Enrollment kursus → row masuk ke `enrollments` | `not yet` |
| 1.6.5 | Redeem poin → `user_points` berkurang, `point_transactions` tercatat | `not yet` |

---

## Fase 2 — Core Backend Features
> Target: Fitur backend kritis berjalan: notifikasi, quest server-side, tracking referral

### 2.1 Edge Functions

| # | Item | Status |
|---|---|---|
| 2.1.1 | `notify-expiry` — cron harian, cek sertifikat expired 30/14/7/1 hari, trigger FCM | `not yet` |
| 2.1.2 | `track-referral` — generate referral URL dengan param tracking, log ke `enrollments` | `not yet` |
| 2.1.3 | `award-points` — validasi quest step completion server-side, update `user_points` | `not yet` |
| 2.1.4 | `reconcile-commissions` — cron bulanan, match enrollment dengan laporan partner | `not yet` |

### 2.2 Push Notifications

| # | Item | Status |
|---|---|---|
| 2.2.1 | Setup Firebase project (Android + iOS) | `not yet` |
| 2.2.2 | Integrasikan `firebase_messaging` di Flutter | `not yet` |
| 2.2.3 | Simpan FCM token ke Supabase (`profiles.fcm_token`) | `not yet` |
| 2.2.4 | Local notification untuk foreground messages | `not yet` |
| 2.2.5 | Deep link dari notifikasi ke screen relevan | `not yet` |
| 2.2.6 | Test notif expiry sertifikat end-to-end | `not yet` |

### 2.3 Google OAuth

| # | Item | Status |
|---|---|---|
| 2.3.1 | Setup Google Cloud OAuth credentials (Web + Android + iOS) | `not yet` |
| 2.3.2 | Konfigurasi di Supabase Auth dashboard | `not yet` |
| 2.3.3 | Test sign in with Google di Android emulator | `not yet` |
| 2.3.4 | Handle deep link OAuth callback | `not yet` |

### 2.4 Quest Server-Side

| # | Item | Status |
|---|---|---|
| 2.4.1 | Generate `quests` rows saat enrollment dibuat (via DB trigger atau Edge Function) | `not yet` |
| 2.4.2 | Step transition validation di Edge Function `award-points` | `not yet` |
| 2.4.3 | Hapus placeholder fallback di `quest_repository_impl.dart` | `not yet` |

### 2.5 Admin Workflow

| # | Item | Status |
|---|---|---|
| 2.5.1 | Dokumentasi SOP verifikasi profil via Supabase Dashboard | `not yet` |
| 2.5.2 | SQL query shortcut untuk admin (view profil pending, approve batch) | `not yet` |
| 2.5.3 | Notifikasi ke user saat status verifikasi berubah (via Edge Function) | `not yet` |

---

## Fase 3 — Product Quality & Growth
> Target: App production-ready, bisa onboard user real

### 3.1 Testing

| # | Item | Status |
|---|---|---|
| 3.1.1 | Unit test: validators (`SrValidators`) | `not yet` |
| 3.1.2 | Unit test: formatters & extensions (`DateTimeX`, `CurrencyX`) | `not yet` |
| 3.1.3 | Unit test: certificate status computation | `not yet` |
| 3.1.4 | Widget test: `SrButton`, `SrTextField`, `SrBadge` | `not yet` |
| 3.1.5 | Widget test: `SrStepIndicator` | `not yet` |
| 3.1.6 | Reach 40% coverage target | `not yet` |

### 3.2 CI/CD

| # | Item | Status |
|---|---|---|
| 3.2.1 | GitHub Actions: `flutter analyze` on PR | `not yet` |
| 3.2.2 | GitHub Actions: `flutter test` on PR | `not yet` |
| 3.2.3 | GitHub Actions: build APK on push to `main` | `not yet` |
| 3.2.4 | Artifact upload APK ke GitHub Releases | `not yet` |

### 3.3 Error Tracking & Observability

| # | Item | Status |
|---|---|---|
| 3.3.1 | Integrasikan Sentry Flutter SDK | `not yet` |
| 3.3.2 | Capture uncaught exceptions + Failure events | `not yet` |
| 3.3.3 | Sentry release tracking (version per build) | `not yet` |
| 3.3.4 | Supabase Logs monitoring (auth errors, DB errors) | `not yet` |

### 3.4 Performance & UX

| # | Item | Status |
|---|---|---|
| 3.4.1 | Hive cache untuk course list (offline read) | `not yet` |
| 3.4.2 | connectivity_plus: banner "Tidak ada koneksi" saat offline | `not yet` |
| 3.4.3 | Cached network images untuk logo partner | `not yet` |
| 3.4.4 | Skeleton shimmer konsisten di semua screen | `not yet` |
| 3.4.5 | Pull-to-refresh di semua list screen | `not yet` |

### 3.5 More Partners

| # | Item | Status |
|---|---|---|
| 3.5.1 | Onboard partner ke-2 (selain PMTC) | `not yet` |
| 3.5.2 | Seed data kursus partner ke-2 | `not yet` |
| 3.5.3 | Logo + info halaman masing-masing partner | `not yet` |

---

## Fase 4 — Monetisasi & Admin Panel
> Target: Revenue flow aktif, commission tracking, admin panel mandiri

### 4.1 Payment Integration

| # | Item | Status |
|---|---|---|
| 4.1.1 | Midtrans Snap — setup merchant account | `not yet` |
| 4.1.2 | Edge Function: create Midtrans transaction | `not yet` |
| 4.1.3 | In-app WebView untuk Midtrans Snap | `not yet` |
| 4.1.4 | Webhook handler: konfirmasi pembayaran → update enrollment | `not yet` |
| 4.1.5 | Receipt screen & email otomatis | `not yet` |

### 4.2 Commission Tracking

| # | Item | Status |
|---|---|---|
| 4.2.1 | Partner dashboard sederhana (laporan enrollment + komisi) | `not yet` |
| 4.2.2 | Cron `reconcile-commissions` bulanan | `not yet` |
| 4.2.3 | Export laporan komisi ke CSV | `not yet` |

### 4.3 Admin Panel Web

| # | Item | Status |
|---|---|---|
| 4.3.1 | Setup Flutter Web project atau Next.js admin | `not yet` |
| 4.3.2 | Screen: daftar user pending verifikasi + approve/reject | `not yet` |
| 4.3.3 | Screen: manajemen kursus (CRUD) | `not yet` |
| 4.3.4 | Screen: laporan enrollment & revenue | `not yet` |
| 4.3.5 | Role-based access (super admin vs partner admin) | `not yet` |

### 4.4 Merchandise Redemption (Feature Flag: enableMerchandiseRedeem)

| # | Item | Status |
|---|---|---|
| 4.4.1 | Inventory system sederhana (tabel `merchandise`) | `not yet` |
| 4.4.2 | Redemption flow dengan OTP konfirmasi | `not yet` |
| 4.4.3 | QR code voucher untuk pickup di counter PMTC | `not yet` |

---

## Fase 5 — Scale & Advance Features
> Target: Diferensiasi produk, AI, ecosystem expansion

### 5.1 AI & Smart Features

| # | Item | Status |
|---|---|---|
| 5.1.1 | Rekomendasi kursus berdasarkan sertifikat expired (rule-based dulu) | `not yet` |
| 5.1.2 | Smart reminder: waktu optimal kirim notif per user | `not yet` |
| 5.1.3 | Chatbot asisten Buku Pelaut (Anthropic API) | `not yet` |

### 5.2 Digital Twin / Map (Feature Flag: enableDigitalTwin3D)

| # | Item | Status |
|---|---|---|
| 5.2.1 | 2D map interaktif venue PMTC (Flutter CustomPaint) | `not yet` |
| 5.2.2 | Pin kelas per jadwal enrollment | `not yet` |
| 5.2.3 | Navigasi dalam gedung (basic) | `not yet` |

### 5.3 Vessel Management

| # | Item | Status |
|---|---|---|
| 5.3.1 | Schema: `vessels`, `vessel_crew` | `not yet` |
| 5.3.2 | Screen: daftar kapal, tambah kapal, link crew | `not yet` |
| 5.3.3 | Crew certificate tracking per vessel | `not yet` |

### 5.4 Real-time Partner API

| # | Item | Status |
|---|---|---|
| 5.4.1 | PMTC API integration (ganti manual sync Google Sheet) | `not yet` |
| 5.4.2 | Real-time enrollment confirmation dari partner | `not yet` |
| 5.4.3 | E-KYC otomatis (integrasi Dukcapil atau vendor) | `not yet` |

### 5.5 Course Discount Redemption (Feature Flag: enableCourseDiscountRedeem)

| # | Item | Status |
|---|---|---|
| 5.5.1 | Generate discount code unik per user | `not yet` |
| 5.5.2 | Validasi kode di sisi partner saat checkout | `not yet` |
| 5.5.3 | Tracking penggunaan diskon di `point_transactions` | `not yet` |

---

## Catatan Arsitektur

### Keputusan yang sudah dibuat
- Flutter monorepo, satu codebase Android/iOS/Web
- Riverpod 2.x (bukan Bloc/Provider/GetX)
- Repository pattern + fpdart `Either<Failure, T>`
- Feature-first folder structure
- Supabase all-in-one (Auth + DB + Storage + Edge Functions)
- go_router dengan ShellRoute bottom nav

### Technical debt yang perlu diselesaikan sebelum launch
- [ ] `RewardRepositoryImpl.redeemReward()` tidak atomic — perlu wrap dalam Supabase RPC/transaction
- [ ] `CourseRepositoryImpl.getCourses()` belum ada pagination cursor-based (saat ini offset)
- [ ] `QuestRepositoryImpl` masih pakai placeholder fallback jika DB kosong
- [ ] Auth redirect di router tidak reactive (perlu `StreamProvider` untuk `authStateChanges`)
- [ ] Tidak ada retry logic untuk upload dokumen yang gagal di tengah jalan

### Dependencies yang perlu diaktifkan (ada di pubspec tapi belum dipakai)
- `hive_flutter` — local cache
- `firebase_core` + `firebase_messaging` — push notifications
- `sentry_flutter` — error tracking
- `connectivity_plus` — offline detection
