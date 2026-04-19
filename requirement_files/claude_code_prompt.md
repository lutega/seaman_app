# Claude Code Prompt — SeaReady Mobile App

> **Cara pakai:** Copy seluruh isi file ini ke Claude Code di awal sesi. Untuk menambah fitur baru, cukup tambahkan section baru di bagian **8. Feature Specs** — bagian lain tidak perlu diubah.

---

## 1. Project Context

**Product name:** SeaReady
**Target users:** Pelaut Indonesia (individual), lembaga diklat maritim (PMTC dll sebagai partner)
**Business model:** Marketplace — komisi 7-10% per pendaftaran kursus
**Development constraints:**
- Solo developer dengan skill "sedikit-sedikit"
- Budget operasional < Rp 5 juta/bulan
- Timeline MVP: 3 bulan
- Scope awal: Indonesia saja

**Design partner:** Pertamina Marine Training Center (PMTC)
**Core value proposition:** Certificate wallet + smart expiry reminder + one-tap course registration

---

## 2. Tech Stack (Non-negotiable)

| Layer | Tech | Alasan |
|---|---|---|
| **Client** | Flutter 3.x (Dart) | Satu codebase untuk Android/iOS/Web/Windows |
| **State management** | Riverpod 2.x | Modern, testable, compile-time safe |
| **Navigation** | `go_router` | Deep linking native — krusial untuk referral URL ke PMTC |
| **Backend** | Supabase | Auth + Postgres + Storage + Edge Functions dalam 1 platform, hemat waktu coding |
| **HTTP / API** | `dio` + Supabase client | Interceptor untuk retry, logging, auth token |
| **Local storage** | `hive` untuk cache, `flutter_secure_storage` untuk token |
| **Notifikasi** | Firebase Cloud Messaging + local notifications |
| **Payment** | Midtrans Snap (web view) |
| **Error tracking** | Sentry (free tier 5k errors/month) |
| **CI/CD** | GitHub Actions |

**Jangan gunakan:**
- Bloc / Provider / GetX (biar konsisten dengan Riverpod)
- Custom backend (cukup Supabase + Edge Functions)
- SQLite lokal (pakai Hive saja)
- Auto-generated UI code (masking readability)

---

## 3. Architecture Principles

### 3.1 Feature-first folder structure

Setiap fitur **self-contained** — tidak ada cross-dependency antar feature kecuali via event bus atau shared service.

```
lib/
├── core/                      # Infrastructure global
│   ├── config/                # env, constants, feature flags
│   ├── network/               # dio setup, interceptors
│   ├── storage/               # Hive, secure storage wrappers
│   ├── theme/                 # design tokens, ThemeData
│   ├── router/                # go_router config
│   ├── errors/                # Failure classes, error handlers
│   └── utils/                 # formatters, validators, extensions
├── features/                  # Setiap folder = 1 fitur
│   ├── auth/
│   │   ├── data/
│   │   │   ├── models/        # DTO dari/ke Supabase
│   │   │   └── repositories/  # Implementasi repository
│   │   ├── domain/
│   │   │   ├── entities/      # Model domain murni
│   │   │   └── repositories/  # Interface abstract
│   │   └── presentation/
│   │       ├── providers/     # Riverpod providers
│   │       ├── screens/       # Full-page widgets
│   │       └── widgets/       # Reusable widget khusus auth
│   ├── courses/               # Sama struktur
│   ├── certificates/
│   ├── quest/
│   ├── rewards/
│   ├── profile/
│   └── map/
├── shared/                    # Widget lintas-feature
│   ├── widgets/               # SrButton, SrCard, SrTextField dll
│   └── layouts/               # Scaffold templates
└── main.dart
```

### 3.2 Core patterns

**Repository pattern** — semua akses data wajib lewat repository interface di `domain/`. Implementation di `data/` bisa di-swap (misal ganti Supabase → REST API di masa depan) tanpa touch UI.

**Riverpod conventions:**
- `FutureProvider` untuk data yang fetched sekali
- `StreamProvider` untuk data real-time (supabase subscriptions)
- `StateNotifierProvider` untuk form state, multi-step flow
- `Provider` untuk service/singleton (repository, API client)
- Setiap provider punya nama suffix jelas: `authControllerProvider`, `coursesStreamProvider`, `courseRepositoryProvider`

**Error handling** — gunakan sealed class `Failure` di `core/errors/`. Setiap repository return `Either<Failure, T>` (pakai package `fpdart` atau `dartz`). UI tampilkan error via widget `SrErrorView`.

**Naming conventions:**
- File: `snake_case.dart`
- Class: `PascalCase`
- Variable/method: `camelCase`
- Constants: `camelCase` (pakai `const`), bukan `SCREAMING_CASE`
- Widget prefix: `Sr` untuk shared (SrButton), `Auth_` untuk feature-specific

### 3.3 Testing strategy (untuk solo dev)

- **Unit tests** wajib untuk: validators, formatters, domain use cases
- **Widget tests** wajib untuk: custom reusable widgets di `shared/widgets/`
- **Integration tests** skip untuk MVP (butuh waktu maintain)
- Gunakan `mocktail` untuk mocking
- Target coverage: 40% di MVP (cukup untuk menghindari regression di core logic)

---

## 4. Backend (Supabase) Setup

### 4.1 Database schema (MVP)

```sql
-- Users handled by Supabase Auth (auth.users)

create table public.profiles (
  id uuid references auth.users primary key,
  full_name text not null,
  birth_date date not null,
  nik_encrypted text not null,        -- enkripsi pakai pgcrypto
  nik_last_4 text not null,           -- untuk display
  address text not null,
  seafarer_number text,               -- nullable
  verification_status text default 'pending',  -- pending/verified/rejected
  created_at timestamptz default now(),
  updated_at timestamptz default now()
);

create table public.partners (
  id uuid primary key default gen_random_uuid(),
  name text not null,                 -- e.g. "PMTC"
  full_name text not null,
  logo_url text,
  referral_slug text unique not null, -- untuk referral URL
  commission_rate decimal(5,2),
  is_active boolean default true,
  created_at timestamptz default now()
);

create table public.courses (
  id uuid primary key default gen_random_uuid(),
  partner_id uuid references partners not null,
  name text not null,
  code text not null,                 -- e.g. "SAT-REN/014/IV/2026"
  category text not null,             -- renewal/rating/initial
  duration_days int,
  price_idr bigint not null,
  description text,
  external_url text not null,         -- URL pendaftaran di sistem partner
  starts_at timestamptz not null,
  registration_deadline timestamptz not null,
  quota int,
  is_active boolean default true,
  created_at timestamptz default now()
);

create table public.certificates (
  id uuid primary key default gen_random_uuid(),
  user_id uuid references auth.users not null,
  name text not null,
  type text not null,                 -- STCW category
  issued_date date not null,
  expiry_date date not null,
  issuer text,                        -- e.g. "PMTC"
  document_url text,                  -- scan di Supabase Storage
  is_verified boolean default false,
  created_at timestamptz default now()
);

create table public.enrollments (
  id uuid primary key default gen_random_uuid(),
  user_id uuid references auth.users not null,
  course_id uuid references courses not null,
  referral_clicked_at timestamptz default now(),
  partner_confirmed_at timestamptz,
  partner_confirmed_status text,      -- confirmed/cancelled
  commission_amount_idr bigint,
  created_at timestamptz default now()
);

create table public.quests (
  id uuid primary key default gen_random_uuid(),
  enrollment_id uuid references enrollments not null,
  step_key text not null,             -- payment_done, docs_uploaded, etc
  step_label text not null,
  status text not null,               -- locked/current/done
  points_awarded int,
  hint_location text,
  hint_contact text,
  hint_deadline timestamptz,
  completed_at timestamptz
);

create table public.user_points (
  user_id uuid references auth.users primary key,
  total_points int default 0,
  streak_count int default 0,
  updated_at timestamptz default now()
);

create table public.point_transactions (
  id uuid primary key default gen_random_uuid(),
  user_id uuid references auth.users not null,
  quest_id uuid references quests,
  points int not null,                -- positive = earn, negative = redeem
  reason text not null,
  created_at timestamptz default now()
);
```

### 4.2 Row Level Security (RLS) — WAJIB

Setiap table di atas harus aktif RLS dan punya policy. Prinsip: user hanya bisa read/write data miliknya sendiri. `courses` dan `partners` boleh public read.

### 4.3 Edge Functions

- `notify-expiry` — cron harian, push notif untuk sertifikat expired 30/14/7 hari
- `track-referral` — generate signed referral URL ke partner dengan tracking param
- `award-points` — hitung poin saat quest step complete (server-side, anti-gaming)
- `reconcile-commissions` — cron bulanan, match enrollment dengan laporan partner

---

## 5. Design System Integration

Pakai design tokens dari `claude_design_prompt.md`. Di `core/theme/`:

```dart
// app_colors.dart
class SrColors {
  static const primary = Color(0xFF065A82);
  static const primaryDark = Color(0xFF21295C);
  static const teal = Color(0xFF1C7293);
  static const success = Color(0xFF0F6E56);
  static const warning = Color(0xFF854F0B);
  static const danger = Color(0xFFA32D2D);
  // ... semua token dari design prompt
}

// app_spacing.dart
class SrSpacing {
  static const xs = 4.0;
  static const sm = 8.0;
  static const md = 16.0;
  static const lg = 24.0;
  static const xl = 32.0;
}

// app_typography.dart — pakai Cambria + Calibri fallback
```

Shared widgets yang **wajib dibuat di awal** (sebelum screen apapun):
- `SrButton` — primary/secondary/danger variants
- `SrTextField` — dengan validation state
- `SrCard` — container standard
- `SrBadge` — status labels (valid/warning/expired)
- `SrLoadingView`, `SrErrorView`, `SrEmptyState`
- `SrStepIndicator` — 3-step progress bar
- `SrPhoneFrame` — untuk preview/screenshot mode

---

## 6. Feature Flags (Extensibility Foundation)

Setiap fitur opsional harus behind flag di `core/config/feature_flags.dart`:

```dart
class FeatureFlags {
  static const enableMap = true;
  static const enableRewards = true;
  static const enableMerchandiseRedeem = false;     // Fase 2
  static const enableCourseDiscountRedeem = false;  // Fase 3
  static const enableDigitalTwin3D = false;         // Fase 2
  static const enableSeafarerBookAssist = false;    // Future
}
```

UI wajib check flag sebelum render feature. Testing flag combination adalah basic MVP requirement.

---

## 7. MVP Scope (In Order)

Build dengan urutan ini. Tidak boleh lompat:

1. **Week 1-2:** Project setup, design system, auth flow (email/password + Google)
2. **Week 3-4:** Profile (buku pelaut form), NIK encryption, admin verification view
3. **Week 5-6:** Course catalog (read from Supabase, manual sync from PMTC Google Sheet), course detail, deep-link to partner URL
4. **Week 7-8:** Certificate wallet, expiry reminder logic, push notifications
5. **Week 9-10:** Quest flow (8 steps), points earning, points dashboard
6. **Week 11-12:** Basic rewards (MVP tier 1 & 2 only), testing, soft launch

**Out of MVP scope (eksplisit):**
- E-KYC otomatis
- Real-time API integration dengan PMTC
- Merchandise/diskon kursus redemption
- Map digital twin
- Manajemen kapal / vessel
- Full ERP

---

## 8. Feature Specs

> **Ini section yang akan berkembang.** Setiap tambah fitur baru, append section di sini. Jangan edit section di atas.

### 8.1 Auth

**Screens:** LoginScreen, RegisterScreen, ForgotPasswordScreen, EmailVerificationScreen
**State:** `authControllerProvider` (StateNotifier)
**API:** `supabase.auth.signInWithPassword`, `signUp`, `signInWithOAuth(google)`
**Deep link:** `app://auth/callback` untuk OAuth return

### 8.2 Profile (Buku Pelaut)

**Screens:** ProfileSetupScreen (3-step wizard), ProfileViewScreen, ProfileEditScreen
**Fields:** full_name, birth_date, nik (encrypted), address, seafarer_number (optional)
**Validation:**
- NIK: 16 digit numeric, validator cek format
- Birth date: min 17 tahun dari tanggal register
- Seafarer number: jika diisi, validasi format 6-8 digit alphanumeric
**UI rules:**
- NIK tampilkan sebagai `1234 **** **** ****` default, eye icon untuk toggle full
- Full NIK hanya terlihat saat button "Tampilkan" ditekan dan auto-hide setelah 5 detik
- Document upload (KTP + selfie) di step 3

### 8.3 Courses

**Screens:** CourseCatalogScreen, CourseDetailScreen, CourseFilterSheet
**Data source:** Supabase table `courses` (sync dari PMTC Google Sheet via Edge Function nightly)
**Flow tap-to-register:**
1. User tap "Daftar" di CourseDetailScreen
2. Call Edge Function `track-referral` dengan user_id + course_id
3. Receive signed URL partner (e.g. `https://pmtc-registrasi-training.com/register?ref=seaready&token=xxx`)
4. Open in external browser / in-app webview
5. Record enrollment row dengan `referral_clicked_at`

### 8.4 Certificates

**Screens:** CertificateListScreen, CertificateDetailScreen, CertificateAddScreen
**Logic reminder:**
- Cron harian cek `expiry_date - today`
- Trigger notif di 30, 14, 7, 1 hari
- Notif deeplink ke CertificateDetailScreen + suggest related course
**Status computation:**
- valid: expiry > 30 days
- warning: 7 < expiry ≤ 30 days
- urgent: 0 < expiry ≤ 7 days
- expired: expiry ≤ 0 days

### 8.5 Quest

**Screens:** QuestOverviewScreen, QuestDetailScreen
**Steps (8 total):**
1. `payment_done` (+10 pts)
2. `docs_uploaded` (+25 pts)
3. `partner_verified` (+20 pts)
4. `briefing_attended` (+30 pts)
5. `checked_in` (+15 pts, bonus if before 08:30)
6. `class_attended` (+20 pts)
7. `exam_passed` (+30 pts)
8. `certificate_received` (+100 pts — reward)

**Hint fields per step:** location, route, contact_person, deadline, start_time
**Anti-gaming:** status transition hanya bisa via Edge Function `award-points` yang verify timestamp + partner confirmation

### 8.6 Rewards

**Screens:** PointsDashboardScreen, RewardCatalogScreen, RedeemConfirmScreen, RedeemHistoryScreen
**MVP rewards (tier 1 & 2 only):**
- Digital badges (auto-awarded, no redeem)
- Voucher cafetaria Rp 25rb (50 pts)
- Voucher parkir 1 hari (30 pts)
**Locked (flag off):** PMTC T-shirt, Course discount
**Redemption flow:**
1. User tap "Tukar"
2. Confirm dialog dengan cost breakdown
3. Generate voucher code, decrement points via Edge Function
4. Show voucher detail (QR + code) in RedeemHistoryScreen

### 8.7 Map (Basic 2D)

**Screens:** VenueMapScreen
**Data:** Hardcoded JSON per partner (PMTC only di MVP)
**Features:** Static 2D map, pin lokasi kelas, tap gedung untuk detail
**Out of scope:** Real navigation, 3D view, real-time room status

---

## 9. How to Add a New Feature

Ketika butuh fitur baru (misal "Vessel Management"):

1. **Tambah section 8.X di prompt ini** dengan: screens, state, API, flow, edge cases
2. **Tambah feature flag** di `core/config/feature_flags.dart`
3. **Scaffold folder** `features/vessel/` dengan struktur standard (data/domain/presentation)
4. **Migration SQL** di `supabase/migrations/NNN_vessels.sql` dengan RLS policies
5. **Provider registration** di `core/providers/global_providers.dart`
6. **Route registration** di `core/router/app_router.dart`
7. **Navigation entry** di Profile/Home screen
8. **Update test coverage target**

Prinsip: **Tidak boleh modify feature existing** untuk menambah feature baru. Kalau perlu shared logic, extract ke `core/` atau `shared/`.

---

## 10. Current Task

**[ISI SESI INI: jelaskan tugas yang Anda mau Claude kerjakan sekarang]**

Contoh:
- "Buatkan struktur folder project dan setup core/theme berdasarkan design tokens di claude_design_prompt.md"
- "Implementasikan feature 8.2 Profile, termasuk SQL migration, repository, providers, dan 3 screens-nya"
- "Review code di `lib/features/auth/` dan saran refactor"

**Penting:**
- Jangan generate code untuk fitur yang di luar scope MVP
- Jangan ubah arsitektur tanpa diskusi
- Jika butuh decision yang tidak ada di prompt, tanya dulu sebelum implementasi

---

**End of prompt.**
