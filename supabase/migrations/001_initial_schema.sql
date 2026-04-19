-- SeaReady MVP Schema
-- Run in Supabase SQL Editor

-- Enable pgcrypto for NIK encryption
create extension if not exists pgcrypto;

-- Profiles (linked to auth.users)
create table public.profiles (
  id uuid references auth.users primary key,
  full_name text not null,
  birth_date date not null,
  nik_encrypted text not null,
  nik_last_4 text not null,
  address text not null,
  seafarer_number text,
  phone text,
  verification_status text default 'pending' check (verification_status in ('pending', 'verified', 'rejected')),
  created_at timestamptz default now(),
  updated_at timestamptz default now()
);

-- Partners (training institutions)
create table public.partners (
  id uuid primary key default gen_random_uuid(),
  name text not null,
  full_name text not null,
  logo_url text,
  referral_slug text unique not null,
  commission_rate decimal(5,2),
  is_active boolean default true,
  created_at timestamptz default now()
);

-- Courses
create table public.courses (
  id uuid primary key default gen_random_uuid(),
  partner_id uuid references partners not null,
  name text not null,
  code text not null,
  category text not null check (category in ('renewal', 'rating', 'initial')),
  duration_days int,
  price_idr bigint not null,
  description text,
  external_url text not null,
  starts_at timestamptz not null,
  registration_deadline timestamptz not null,
  quota int,
  is_active boolean default true,
  created_at timestamptz default now()
);

-- Certificates (wallet)
create table public.certificates (
  id uuid primary key default gen_random_uuid(),
  user_id uuid references auth.users not null,
  name text not null,
  type text not null,
  issued_date date not null,
  expiry_date date not null,
  issuer text,
  document_url text,
  is_verified boolean default false,
  created_at timestamptz default now()
);

-- Enrollments (track referral clicks)
create table public.enrollments (
  id uuid primary key default gen_random_uuid(),
  user_id uuid references auth.users not null,
  course_id uuid references courses not null,
  referral_clicked_at timestamptz default now(),
  partner_confirmed_at timestamptz,
  partner_confirmed_status text check (partner_confirmed_status in ('confirmed', 'cancelled')),
  commission_amount_idr bigint,
  created_at timestamptz default now()
);

-- Quest steps per enrollment
create table public.quests (
  id uuid primary key default gen_random_uuid(),
  enrollment_id uuid references enrollments not null,
  step_key text not null,
  step_label text not null,
  status text not null default 'locked' check (status in ('locked', 'current', 'done')),
  points_awarded int,
  hint_location text,
  hint_contact text,
  hint_deadline timestamptz,
  completed_at timestamptz
);

-- User points balance
create table public.user_points (
  user_id uuid references auth.users primary key,
  total_points int default 0,
  streak_count int default 0,
  updated_at timestamptz default now()
);

-- Point transaction ledger
create table public.point_transactions (
  id uuid primary key default gen_random_uuid(),
  user_id uuid references auth.users not null,
  quest_id uuid references quests,
  points int not null,
  reason text not null,
  created_at timestamptz default now()
);

-- ─── Row Level Security ────────────────────────────────────────────────────────

alter table public.profiles enable row level security;
alter table public.partners enable row level security;
alter table public.courses enable row level security;
alter table public.certificates enable row level security;
alter table public.enrollments enable row level security;
alter table public.quests enable row level security;
alter table public.user_points enable row level security;
alter table public.point_transactions enable row level security;

-- Profiles: users can only read/write their own
create policy "profiles_select_own" on public.profiles for select using (auth.uid() = id);
create policy "profiles_insert_own" on public.profiles for insert with check (auth.uid() = id);
create policy "profiles_update_own" on public.profiles for update using (auth.uid() = id);

-- Partners: public read
create policy "partners_public_read" on public.partners for select using (true);

-- Courses: public read for active courses
create policy "courses_public_read" on public.courses for select using (is_active = true);

-- Certificates: own only
create policy "certificates_select_own" on public.certificates for select using (auth.uid() = user_id);
create policy "certificates_insert_own" on public.certificates for insert with check (auth.uid() = user_id);
create policy "certificates_update_own" on public.certificates for update using (auth.uid() = user_id);
create policy "certificates_delete_own" on public.certificates for delete using (auth.uid() = user_id);

-- Enrollments: own only
create policy "enrollments_select_own" on public.enrollments for select using (auth.uid() = user_id);
create policy "enrollments_insert_own" on public.enrollments for insert with check (auth.uid() = user_id);

-- Quests: via enrollment ownership
create policy "quests_select_own" on public.quests for select using (
  exists (select 1 from public.enrollments e where e.id = enrollment_id and e.user_id = auth.uid())
);

-- User points: own only
create policy "user_points_select_own" on public.user_points for select using (auth.uid() = user_id);

-- Point transactions: own only
create policy "point_transactions_select_own" on public.point_transactions for select using (auth.uid() = user_id);

-- ─── Seed data: PMTC partner ──────────────────────────────────────────────────
insert into public.partners (name, full_name, logo_url, referral_slug, commission_rate, is_active)
values ('PMTC', 'Pertamina Marine Training Center', null, 'pmtc', 8.00, true);
