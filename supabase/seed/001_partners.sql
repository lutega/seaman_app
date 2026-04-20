-- Seed: Partners
-- Run after 001_initial_schema.sql

insert into public.partners (name, full_name, logo_url, referral_slug, commission_rate, is_active)
values
  (
    'PMTC',
    'Pertamina Marine Training Center',
    null,  -- upload logo ke partner-assets bucket, update setelah upload
    'pmtc',
    8.00,
    true
  )
on conflict (referral_slug) do nothing;
