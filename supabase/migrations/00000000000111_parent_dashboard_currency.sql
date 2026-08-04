-- Exposes the child's own currency (00000000000110_profile_currency.sql) on
-- the parent dashboard rollup, so ChildRollupCard can format wallet/goal
-- amounts in the child's selected currency instead of assuming USD.
drop view parent_dashboard_children;

create view parent_dashboard_children
with (security_invoker = true)
as
select
  p.id as profile_id,
  p.parent_id,
  p.display_name,
  p.tier,
  p.currency,
  coalesce(xp.total_xp, 0) as total_xp,
  mastery.avg_mastery_pct,
  coalesce(wallet.wallet_balance_cents, 0) as wallet_balance_cents,
  coalesce(goals.savings_goals, '[]'::jsonb) as savings_goals,
  coalesce(interviews.interview_sessions, '[]'::jsonb) as interview_sessions
from profiles p
left join (
  select profile_id, sum(xp_delta) as total_xp
  from xp_events
  group by profile_id
) xp on xp.profile_id = p.id
left join (
  select
    profile_id,
    round(avg(rolling_accuracy) * 100, 2) as avg_mastery_pct
  from skill_mastery
  group by profile_id
) mastery on mastery.profile_id = p.id
left join (
  select profile_id, balance_cents as wallet_balance_cents
  from account_balances
  where type = 'student_wallet'
) wallet on wallet.profile_id = p.id
left join (
  select
    profile_id,
    jsonb_agg(
      jsonb_build_object(
        'account_id', account_id,
        'name', name,
        'balance_cents', balance_cents,
        'target_amount_cents', target_amount_cents,
        'percent_complete', percent_complete
      )
    ) as savings_goals
  from savings_goal_progress
  group by profile_id
) goals on goals.profile_id = p.id
left join (
  select
    profile_id,
    jsonb_agg(
      jsonb_build_object(
        'session_id', id,
        'firm_style', firm_style,
        'rubric_scores', rubric_scores,
        'created_at', created_at
      )
      order by created_at desc
    ) as interview_sessions
  from interview_sessions
  where rubric_scores != '{}'::jsonb
  group by profile_id
) interviews on interviews.profile_id = p.id
where p.role = 'student';

comment on view parent_dashboard_children is
  'Read-only aggregate rollup for the parent dashboard: one row per student '
  'profile the caller can see (own linked children, per RLS on profiles, '
  'skill_attempts, xp_events, accounts/postings, interview_sessions -- all '
  'via is_own_or_linked_profile). security_invoker = true, so it never '
  'bypasses RLS. A parent with exactly one linked child gets exactly one '
  'row back; a child with no savings goals / interview sessions gets '
  'empty-array jsonb columns rather than a broken row. currency is the '
  'child''s own display currency (see 00000000000110_profile_currency.sql).';
