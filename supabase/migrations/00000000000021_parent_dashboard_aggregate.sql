-- Phase 8: Parent dashboard aggregate rollup.
--
-- A single read-only view, one row per student profile, aggregating
-- everything a parent's dashboard needs to show for a linked child: tier,
-- total XP, overall mastery %, pocket money wallet/savings-goal progress,
-- and any scored Interview Coach sessions. Nothing here is stored -- it is
-- all derived on read from the existing xp_events/skill_mastery/
-- account_balances/savings_goal_progress/interview_sessions sources, same
-- "never store what can be computed" principle as the rest of the schema
-- (see BACKEND.md).

-- skill_mastery (migration 002) was created without `security_invoker`.
-- Views created by migrations run as the `postgres` role, which has
-- BYPASSRLS in Supabase, so a plain view silently runs with the owner's
-- privileges instead of the querying user's -- the same trap
-- account_balances/savings_goal_progress (migration 011) called out and
-- avoided. Without this fix, skill_mastery leaks every profile's mastery
-- data to any authenticated caller, and the aggregate view below would
-- inherit that leak. This flips it to the already-established convention;
-- it does not change what skill_mastery returns for a caller who already
-- had legitimate access via skill_attempts' `is_own_or_linked_profile`
-- select policy.
alter view skill_mastery set (security_invoker = true);

-- One row per (linked) student profile. security_invoker = true is
-- required for the same reason as skill_mastery above -- without it this
-- view would bypass every underlying RLS policy and leak all students'
-- data to all parents.
create view parent_dashboard_children
with (security_invoker = true)
as
select
  p.id as profile_id,
  p.parent_id,
  p.display_name,
  p.tier,
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
  'empty-array jsonb columns rather than a broken row.';
