-- Seed: PMTC Courses Q2 2026
-- Sumber: jadwal PMTC (update manual setiap kuartal)
-- Jalankan setelah 001_partners.sql

do $$
declare
  v_partner_id uuid;
begin
  select id into v_partner_id from public.partners where referral_slug = 'pmtc';

  insert into public.courses
    (partner_id, name, code, category, duration_days, price_idr, description,
     external_url, starts_at, registration_deadline, quota, is_active)
  values
    -- BST Renewal
    (
      v_partner_id,
      'Basic Safety Training (BST) Renewal',
      'SAT-REN/001/IV/2026',
      'renewal',
      5,
      2500000,
      'Pelatihan pembaruan sertifikat BST sesuai STCW 2010 Manila Amendments. Wajib bagi seluruh pelaut yang sertifikat BST-nya akan habis masa berlaku.',
      'https://pmtc-registrasi-training.com/register',
      '2026-05-05 08:00:00+07',
      '2026-04-28 17:00:00+07',
      30,
      true
    ),
    -- SCRB Renewal
    (
      v_partner_id,
      'Survival Craft & Rescue Boats (SCRB) Renewal',
      'SAT-REN/002/IV/2026',
      'renewal',
      3,
      1800000,
      'Pelatihan pembaruan kompetensi penggunaan sekoci penolong dan perahu penyelamat.',
      'https://pmtc-registrasi-training.com/register',
      '2026-05-12 08:00:00+07',
      '2026-05-05 17:00:00+07',
      25,
      true
    ),
    -- AFF Renewal
    (
      v_partner_id,
      'Advanced Fire Fighting (AFF) Renewal',
      'SAT-REN/003/IV/2026',
      'renewal',
      4,
      2200000,
      'Pelatihan pemadaman kebakaran tingkat lanjut untuk perwira kapal. Termasuk praktik menggunakan SCBA dan sistem sprinkler.',
      'https://pmtc-registrasi-training.com/register',
      '2026-05-19 08:00:00+07',
      '2026-05-12 17:00:00+07',
      20,
      true
    ),
    -- MEFA Renewal
    (
      v_partner_id,
      'Medical Emergency First Aid (MEFA) Renewal',
      'SAT-REN/004/V/2026',
      'renewal',
      3,
      1500000,
      'Pelatihan pertolongan pertama medis darurat di atas kapal. Termasuk CPR, penanganan luka, dan evakuasi medis.',
      'https://pmtc-registrasi-training.com/register',
      '2026-06-02 08:00:00+07',
      '2026-05-26 17:00:00+07',
      30,
      true
    ),
    -- BST Initial (bukan renewal)
    (
      v_partner_id,
      'Basic Safety Training (BST) — Initial',
      'SAT-INT/005/V/2026',
      'initial',
      5,
      3000000,
      'Pelatihan BST untuk pelaut baru yang belum memiliki sertifikat. Mencakup 4 elemen: personal survival, fire prevention, elementary first aid, dan personal safety.',
      'https://pmtc-registrasi-training.com/register',
      '2026-06-09 08:00:00+07',
      '2026-06-02 17:00:00+07',
      30,
      true
    ),
    -- Rating Certificate
    (
      v_partner_id,
      'Able Seafarer Deck (ASD) Rating',
      'SAT-RAT/006/VI/2026',
      'rating',
      10,
      5500000,
      'Pelatihan untuk meningkatkan rating menjadi Able Seafarer Deck. Sesuai STCW Regulation II/5.',
      'https://pmtc-registrasi-training.com/register',
      '2026-06-16 08:00:00+07',
      '2026-06-09 17:00:00+07',
      20,
      true
    );

end $$;
