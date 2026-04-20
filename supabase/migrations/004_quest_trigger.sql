-- Migration 004: Auto-generate quest steps when enrollment is created

create or replace function public.create_quest_steps()
returns trigger
language plpgsql
security definer
as $$
begin
  insert into public.quests (enrollment_id, step_key, step_label, status, points_awarded)
  values
    (new.id, 'payment_done',         'Konfirmasi Pembayaran',    'current', 10),
    (new.id, 'docs_uploaded',        'Upload Dokumen',           'locked',  25),
    (new.id, 'partner_verified',     'Verifikasi Partner',       'locked',  20),
    (new.id, 'briefing_attended',    'Hadiri Briefing',          'locked',  30),
    (new.id, 'checked_in',           'Check-in Hari Pertama',    'locked',  15),
    (new.id, 'class_attended',       'Selesai Kelas',            'locked',  20),
    (new.id, 'exam_passed',          'Lulus Ujian',              'locked',  30),
    (new.id, 'certificate_received', 'Terima Sertifikat',        'locked', 100);
  return new;
end;
$$;

create trigger on_enrollment_created
  after insert on public.enrollments
  for each row
  execute function public.create_quest_steps();

-- ─── RPC: advance quest step (called from Edge Function award-points) ─────────

create or replace function public.complete_quest_step(
  p_quest_id uuid,
  p_user_id  uuid
)
returns jsonb
language plpgsql
security definer
as $$
declare
  v_quest      public.quests%rowtype;
  v_enrollment public.enrollments%rowtype;
  v_next_quest public.quests%rowtype;
  v_points     int;
begin
  -- Load quest
  select * into v_quest from public.quests where id = p_quest_id;
  if not found then
    return jsonb_build_object('ok', false, 'error', 'quest not found');
  end if;

  -- Verify ownership via enrollment
  select * into v_enrollment from public.enrollments
    where id = v_quest.enrollment_id and user_id = p_user_id;
  if not found then
    return jsonb_build_object('ok', false, 'error', 'unauthorized');
  end if;

  if v_quest.status = 'done' then
    return jsonb_build_object('ok', false, 'error', 'already completed');
  end if;

  v_points := coalesce(v_quest.points_awarded, 0);

  -- Mark current step done
  update public.quests
    set status = 'done', completed_at = now()
    where id = p_quest_id;

  -- Unlock next step (if any)
  select * into v_next_quest from public.quests
    where enrollment_id = v_quest.enrollment_id
      and status = 'locked'
    order by created_at
    limit 1;

  if found then
    update public.quests set status = 'current' where id = v_next_quest.id;
  end if;

  -- Award points
  insert into public.point_transactions (user_id, quest_id, points, reason)
    values (p_user_id, p_quest_id, v_points, 'Quest: ' || v_quest.step_label);

  insert into public.user_points (user_id, total_points, streak_count, updated_at)
    values (p_user_id, v_points, 1, now())
    on conflict (user_id) do update
      set total_points = user_points.total_points + v_points,
          streak_count = user_points.streak_count + 1,
          updated_at   = now();

  return jsonb_build_object('ok', true, 'points_awarded', v_points);
end;
$$;
