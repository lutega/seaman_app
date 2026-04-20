-- Migration 005: Atomic redeem RPC (replaces client-side multi-step in RewardRepositoryImpl)

create or replace function public.redeem_reward(
  p_user_id    uuid,
  p_reward_id  text,
  p_reward_name text,
  p_cost       int,
  p_prefix     text
)
returns jsonb
language plpgsql
security definer
as $$
declare
  v_current_points int;
  v_code           text;
  v_expires_at     timestamptz;
begin
  -- Lock the row so concurrent redeems can't race
  select total_points into v_current_points
    from public.user_points
    where user_id = p_user_id
    for update;

  if v_current_points is null then
    return jsonb_build_object('ok', false, 'error', 'no points record');
  end if;

  if v_current_points < p_cost then
    return jsonb_build_object('ok', false, 'error', 'insufficient points');
  end if;

  -- Deduct points
  update public.user_points
    set total_points = total_points - p_cost,
        updated_at   = now()
    where user_id = p_user_id;

  -- Record transaction
  insert into public.point_transactions (user_id, points, reason)
    values (p_user_id, -p_cost, 'Redeem: ' || p_reward_name);

  -- Generate voucher code
  v_code       := p_prefix || '-' || upper(substr(md5(random()::text), 1, 6));
  v_expires_at := now() + interval '30 days';

  return jsonb_build_object(
    'ok',          true,
    'code',        v_code,
    'reward_name', p_reward_name,
    'expires_at',  v_expires_at
  );
end;
$$;
