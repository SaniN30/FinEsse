-- College content-depth followup: backfill `difficulty` for content that
-- existed before migration 046 added the column (everything got the
-- column's 'medium' default at add-time; this assigns a real spread
-- instead of leaving every legacy row at the same value). New content added
-- in migrations 047/048 already has deliberately-authored difficulty values
-- per question and is explicitly excluded here so this backfill can't
-- clobber it.
--
-- quiz_questions: tiered by each quiz's own `order_index` (ntile(3) per
-- quiz) -- this repo's quizzes are already written recall-first,
-- application/scenario-later (see BACKEND.md's "at least half
-- application/scenario" convention), so position within a quiz is a
-- reasonable, non-arbitrary proxy for difficulty: first third easy, middle
-- third medium, last third hard.
--
-- interview_questions: no ordering column exists to lean on the same way,
-- so this assigns an even round-robin spread (easy/medium/hard) within each
-- `category`, rather than claiming to have graded each question's actual
-- difficulty -- an honest, non-arbitrary default rather than leaving every
-- row at 'medium'.

with new_college_quiz_ids as (
  select ('00000000-0000-0000-0003-' || lpad(n::text, 12, '0'))::uuid as id
  from generate_series(109, 121) n
),
tiered as (
  select
    qq.id,
    ntile(3) over (partition by qq.quiz_id order by qq.order_index) as tier
  from quiz_questions qq
  where qq.quiz_id not in (select id from new_college_quiz_ids)
)
update quiz_questions
set difficulty = case tiered.tier
  when 1 then 'easy'
  when 2 then 'medium'
  else 'hard'
end
from tiered
where quiz_questions.id = tiered.id;

with numbered as (
  select id, row_number() over (partition by category order by created_at, id) as rn
  from interview_questions
)
update interview_questions
set difficulty = case mod(numbered.rn - 1, 3)
  when 0 then 'easy'
  when 1 then 'medium'
  else 'hard'
end
from numbered
where interview_questions.id = numbered.id;
