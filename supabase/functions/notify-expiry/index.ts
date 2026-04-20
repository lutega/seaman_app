// Edge Function: notify-expiry
// Schedule: setiap hari jam 07:00 WIB via Supabase Cron
// Cek sertifikat yang akan expired dalam 30, 14, 7, 1 hari → kirim FCM push notification

import { serve } from 'https://deno.land/std@0.177.0/http/server.ts'
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'

const DAYS_TO_CHECK = [30, 14, 7, 1]

serve(async () => {
  const supabase = createClient(
    Deno.env.get('SUPABASE_URL')!,
    Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!,
  )

  const today = new Date()
  today.setHours(0, 0, 0, 0)

  for (const days of DAYS_TO_CHECK) {
    const target = new Date(today)
    target.setDate(target.getDate() + days)
    const targetStr = target.toISOString().split('T')[0]

    // Get certificates expiring exactly on target date
    const { data: certs, error } = await supabase
      .from('certificates')
      .select('id, user_id, name, expiry_date')
      .eq('expiry_date', targetStr)

    if (error || !certs?.length) continue

    for (const cert of certs) {
      // Get user FCM token from profiles
      const { data: profile } = await supabase
        .from('profiles')
        .select('fcm_token')
        .eq('id', cert.user_id)
        .single()

      const fcmToken = (profile as any)?.fcm_token
      if (!fcmToken) continue

      await sendFcmNotification({
        token: fcmToken,
        title: days === 1
          ? `⚠️ ${cert.name} habis besok!`
          : `Sertifikat ${cert.name} expired dalam ${days} hari`,
        body: `Segera perbarui sebelum ${targetStr}. Buka SeaReady untuk cari kursus renewal.`,
        data: {
          screen: '/certificates/${cert.id}',
          cert_id: cert.id,
        },
      })
    }
  }

  return new Response(JSON.stringify({ ok: true }), {
    headers: { 'Content-Type': 'application/json' },
  })
})

async function sendFcmNotification(payload: {
  token: string
  title: string
  body: string
  data: Record<string, string>
}) {
  const fcmUrl = 'https://fcm.googleapis.com/v1/projects/' +
    Deno.env.get('FCM_PROJECT_ID') + '/messages:send'

  await fetch(fcmUrl, {
    method: 'POST',
    headers: {
      'Authorization': 'Bearer ' + Deno.env.get('FCM_SERVER_KEY'),
      'Content-Type': 'application/json',
    },
    body: JSON.stringify({
      message: {
        token: payload.token,
        notification: { title: payload.title, body: payload.body },
        data: payload.data,
        android: { priority: 'high' },
        apns: { payload: { aps: { sound: 'default' } } },
      },
    }),
  })
}
