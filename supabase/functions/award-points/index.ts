// Edge Function: award-points
// POST { user_id, quest_id }
// Validates and advances quest step server-side (anti-gaming)
// Calls RPC complete_quest_step which is atomic

import { serve } from 'https://deno.land/std@0.177.0/http/server.ts'
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'

serve(async (req) => {
  if (req.method !== 'POST') {
    return new Response('Method not allowed', { status: 405 })
  }

  // Verify JWT — user must be authenticated
  const authHeader = req.headers.get('Authorization')
  if (!authHeader) return json({ ok: false, error: 'unauthorized' }, 401)

  const supabase = createClient(
    Deno.env.get('SUPABASE_URL')!,
    Deno.env.get('SUPABASE_ANON_KEY')!,
    { global: { headers: { Authorization: authHeader } } },
  )

  const { data: { user }, error: userErr } = await supabase.auth.getUser()
  if (userErr || !user) return json({ ok: false, error: 'unauthorized' }, 401)

  const { quest_id } = await req.json()
  if (!quest_id) return json({ ok: false, error: 'missing quest_id' }, 400)

  // Call atomic RPC
  const { data, error } = await supabase.rpc('complete_quest_step', {
    p_quest_id: quest_id,
    p_user_id: user.id,
  })

  if (error) return json({ ok: false, error: error.message }, 500)

  return json(data)
})

function json(data: unknown, status = 200) {
  return new Response(JSON.stringify(data), {
    status,
    headers: { 'Content-Type': 'application/json' },
  })
}
