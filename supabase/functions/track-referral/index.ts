// Edge Function: track-referral
// POST { user_id, course_id }
// Returns { enrollment_id, tracking_url }

import { serve } from 'https://deno.land/std@0.177.0/http/server.ts'
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'

serve(async (req) => {
  if (req.method !== 'POST') {
    return new Response('Method not allowed', { status: 405 })
  }

  const supabase = createClient(
    Deno.env.get('SUPABASE_URL')!,
    Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!,
  )

  const { user_id, course_id } = await req.json()
  if (!user_id || !course_id) {
    return json({ ok: false, error: 'missing fields' }, 400)
  }

  // Get course + partner info
  const { data: course, error: courseErr } = await supabase
    .from('courses')
    .select('id, external_url, partner_id, partners(referral_slug)')
    .eq('id', course_id)
    .single()

  if (courseErr || !course) {
    return json({ ok: false, error: 'course not found' }, 404)
  }

  // Prevent duplicate enrollment
  const { data: existing } = await supabase
    .from('enrollments')
    .select('id')
    .eq('user_id', user_id)
    .eq('course_id', course_id)
    .maybeSingle()

  let enrollmentId: string

  if (existing) {
    enrollmentId = existing.id
  } else {
    const { data: enrollment, error: enrollErr } = await supabase
      .from('enrollments')
      .insert({ user_id, course_id })
      .select('id')
      .single()

    if (enrollErr || !enrollment) {
      return json({ ok: false, error: 'enrollment failed' }, 500)
    }
    enrollmentId = enrollment.id
  }

  // Build tracking URL
  const partner = (course as any).partners
  const slug = partner?.referral_slug ?? 'seaready'
  const uid = user_id.substring(0, 8)
  const base = (course as any).external_url

  const trackingUrl = new URL(base)
  trackingUrl.searchParams.set('ref', 'seaready')
  trackingUrl.searchParams.set('partner', slug)
  trackingUrl.searchParams.set('uid', uid)
  trackingUrl.searchParams.set('eid', enrollmentId.substring(0, 8))

  return json({ ok: true, enrollment_id: enrollmentId, tracking_url: trackingUrl.toString() })
})

function json(data: unknown, status = 200) {
  return new Response(JSON.stringify(data), {
    status,
    headers: { 'Content-Type': 'application/json' },
  })
}
