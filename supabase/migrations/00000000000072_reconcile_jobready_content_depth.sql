-- Reconciliation: Job-Ready content-depth PR (#29) never actually reached
-- the live project. Its schema migration
-- (00000000000043_quiz_case_study_badges_schema.sql) was recorded live
-- under version 00000000000043, but the live bookkeeping row at that
-- version is actually "sticky_notes" -- an unrelated, still-unmerged
-- branch pushed its migration directly to the live project under that same
-- version number, silently overwriting the tracking row without ever
-- running Job-Ready's DDL. As a direct consequence,
-- 00000000000044_expand_jobready_quizzes_to_ten.sql and
-- 00000000000045_seed_jobready_case_studies.sql (which depend on that
-- schema) never applied either, and
-- 00000000000046_interview_questions_difficulty_and_guides.sql collided on
-- its own version number with College's
-- 00000000000046_college_depth_schema_extensions.sql (College's won the
-- live slot). Verified directly against
-- supabase_migrations.schema_migrations and information_schema.columns,
-- not assumed from migration-list output alone -- see AGENTS.md.
--
-- Rather than re-run the original files verbatim (which would collide with
-- College's now-live schema: quiz_questions.difficulty/question_type/
-- grading_keywords/min_keyword_matches/scenario_context and the generic
-- badges/profile_badges/award_badge(profile_id, criteria_type) already
-- exist, added by College's own 046-049 pass), this migration reconciles
-- Job-Ready's intent against that current reality:
--
-- 1. quizzes.quiz_type/scenario_body/context_tag -- College's schema pass
--    never added these (case studies weren't part of its scope), so they're
--    still missing. Added here, additive only.
-- 2. The 044 quiz-expansion inserts are pure multiple_choice content with
--    no schema dependency beyond difficulty (already live) -- copied
--    forward verbatim from 00000000000044, guarded so it can't
--    double-insert if partially run.
-- 3. The 045 case-study skill/lesson/quizzes/questions are copied forward
--    from 00000000000045 verbatim, except the quiz_questions insert is
--    reshaped into an insert-select over the original VALUES list so
--    `grading_keywords`/`min_keyword_matches` (College's live column
--    names/threshold-column design) are populated from the same original
--    `keywords` values via a SQL expression
--    (greatest(1, ceil(array_length * 0.5))) instead of hand-computed
--    literals -- matching the >=50% threshold 043's original
--    grade_quiz_attempt hard-coded, with no risk of transcription error.
--    No grade_quiz_attempt change is needed: the live (College-authored)
--    version already grades any quiz generically via
--    grading_keywords/min_keyword_matches, without checking quiz_type at
--    all -- quiz_type/scenario_body/context_tag are presentation-only,
--    consumed by components/quiz/QuizRunner.tsx's scenario banner.
-- 4. A `first-mock-interview` badge row, reusing the live generic
--    criteria_type-based badges/award_badge design instead of
--    reintroducing 043's incompatible award_badge(profile_id, slug)
--    signature (which would collide with College's already-live,
--    already-in-use function of the same name). The first three Job-Ready
--    badges 043 intended (first lesson, first quiz, tier completed) need no
--    new rows: the live generic badges already fire for any tier via
--    mark_lesson_complete/grade_quiz_attempt/check_and_award_tier_completed.
--    The score-interview-session Edge Function is updated in the same pass
--    (not a DB migration) to call award_badge with p_criteria_type instead
--    of the p_slug parameter name it was written against, which currently
--    makes every award attempt fail silently (best-effort, caught and
--    logged, never surfaced).
-- 5. interview_questions.improvement_guide -- genuinely missing (College's
--    pass never touched interview_questions beyond difficulty). The 115
--    per-question UPDATEs from 00000000000046 are copied forward verbatim,
--    including its safety-net check and final not-null/check-length
--    constraints. Its `difficulty` ADD COLUMN is changed to IF NOT EXISTS
--    since College's own 046 already added that column (with the same
--    default/check) and its 049 already assigned every existing row a
--    round-robin placeholder spread -- this backfill's hand-authored
--    per-question values intentionally supersede that placeholder for
--    these same 115 rows.

-- ===================== 1. Case-study schema on quizzes =====================

alter table quizzes
  add column if not exists scenario_body text,
  add column if not exists context_tag text,
  add column if not exists quiz_type text not null default 'standard';

do $$
begin
  if not exists (
    select 1 from pg_constraint
    where conname = 'quizzes_quiz_type_check' and conrelid = 'quizzes'::regclass
  ) then
    alter table quizzes
      add constraint quizzes_quiz_type_check check (quiz_type in ('standard', 'case_study'));
  end if;
end $$;

-- ===================== 2. Job-Ready quiz expansion to 10 questions =====================
-- Copied forward verbatim from 00000000000044 (pure multiple_choice
-- inserts, no schema dependency beyond `difficulty`, already live).
-- Guarded by a single representative row check so this can't
-- double-insert.

do $$
begin
  if not exists (
    select 1 from quiz_questions
    where quiz_id = '00000000-0000-0000-0003-000000000201' and order_index = 10
  ) then
    insert into quiz_questions (quiz_id, question, options, correct_answer, order_index, difficulty) values
      -- ===================== Interview Fundamentals (201) =====================
      ('00000000-0000-0000-0003-000000000201', 'What does a "fit" question (e.g. "why this company?") primarily reward, per the lesson?',
        '["A generic answer that could apply to any company", "Genuine, researched reasons specific to that company", "Reciting the company''s mission statement word for word", "Avoiding answering directly"]'::jsonb,
        'Genuine, researched reasons specific to that company', 5, 'easy'),
      ('00000000-0000-0000-0003-000000000201', 'What should you do before answering an interview question well, per the lesson?',
        '["Recognize which type of question -- behavioral, technical, or fit -- it is", "Ask the interviewer to repeat the question twice", "Assume every question is behavioral", "Give the same answer you gave in your last interview"]'::jsonb,
        'Recognize which type of question -- behavioral, technical, or fit -- it is', 6, 'medium'),
      ('00000000-0000-0000-0003-000000000201', 'What common mistake does the lesson warn against when preparing for interviews?',
        '["Preparing a few real stories for behavioral questions", "Memorising a single script and using it regardless of the question type", "Practicing concise explanations for technical concepts", "Researching the company in advance"]'::jsonb,
        'Memorising a single script and using it regardless of the question type', 7, 'medium'),
      ('00000000-0000-0000-0003-000000000201', 'Why does a rambling personal anecdote fail as a response to a technical question, per the lesson?',
        '["Technical questions need a precise, structured explanation, not a personal story", "Personal stories are never appropriate in any interview", "Technical questions are always trick questions", "Interviewers never listen to personal anecdotes"]'::jsonb,
        'Technical questions need a precise, structured explanation, not a personal story', 8, 'hard'),
      ('00000000-0000-0000-0003-000000000201', 'What is the core purpose of a job interview, per the lesson?',
        '["Giving the interviewer enough evidence, in a short window, to believe you can do the job and work well with the team", "Testing how well you can talk for a long time", "Finding a candidate who agrees with everything the interviewer says", "Filling a scheduled time slot"]'::jsonb,
        'Giving the interviewer enough evidence, in a short window, to believe you can do the job and work well with the team', 9, 'easy'),
      ('00000000-0000-0000-0003-000000000201', 'In the worked example, what makes the strong answer to "tell me about a time you handled a disagreement" better than the weak one?',
        '["It uses more impressive vocabulary", "It gives one specific real situation with concrete actions and an outcome, not just a claim about yourself", "It is much longer", "It avoids mentioning the disagreement directly"]'::jsonb,
        'It gives one specific real situation with concrete actions and an outcome, not just a claim about yourself', 10, 'medium'),

      -- ===================== Resume & Behavioral Basics (202) =====================
      ('00000000-0000-0000-0003-000000000202', 'What is a resume''s primary job, per the lesson?',
        '["To describe your entire life in detail", "To get you the interview, not to describe your entire life", "To list every task you have ever performed", "To match a template exactly"]'::jsonb,
        'To get you the interview, not to describe your entire life', 5, 'easy'),
      ('00000000-0000-0000-0003-000000000202', 'What should every resume line help a reader do, per the lesson?',
        '["Quickly see what you can do", "See how long you have worked somewhere", "Understand your personal hobbies", "Guess your salary expectations"]'::jsonb,
        'Quickly see what you can do', 6, 'easy'),
      ('00000000-0000-0000-0003-000000000202', 'What does the "R" in the STAR structure stand for?',
        '["Reason", "Review", "Result", "Recommendation"]'::jsonb,
        'Result', 7, 'easy'),
      ('00000000-0000-0000-0003-000000000202', 'What does the lesson say ideally accompanies the Result in a STAR answer?',
        '["A number or clear before/after outcome", "A list of everyone else who was involved", "An apology for the situation", "A restatement of the Situation"]'::jsonb,
        'A number or clear before/after outcome', 8, 'medium'),
      ('00000000-0000-0000-0003-000000000202', 'What kind of resume bullet does the lesson identify as weakest?',
        '["One that includes a measurable result", "One that just lists a responsibility with no evidence of impact", "One that mentions a team size", "One that mentions a deadline"]'::jsonb,
        'One that just lists a responsibility with no evidence of impact', 9, 'easy'),
      ('00000000-0000-0000-0003-000000000202', 'What does STAR keep a behavioral answer from doing, per the lesson?',
        '["Being too specific", "Trailing off into vague generalities", "Mentioning any numbers", "Being memorable"]'::jsonb,
        'Trailing off into vague generalities', 10, 'medium'),

      -- ===================== Case-Method Basics (203) =====================
      ('00000000-0000-0000-0003-000000000203', 'What kind of problem does a case-method interview typically present, per the lesson?',
        '["A trivia question with one memorised correct answer", "An open-ended business problem", "A pure math exam question", "A yes/no question about the company"]'::jsonb,
        'An open-ended business problem', 6, 'easy'),
      ('00000000-0000-0000-0003-000000000203', 'Per the lesson''s recommended structure, what comes right after clarifying and restating the question?',
        '["Immediately stating a final number", "Breaking the problem into a small number of clear components", "Asking the interviewer for the answer", "Ending the interview"]'::jsonb,
        'Breaking the problem into a small number of clear components', 7, 'medium'),
      ('00000000-0000-0000-0003-000000000203', 'Why does the lesson say you should state your assumptions "out loud"?',
        '["So the interviewer can follow and evaluate your reasoning, not just your final number", "Because silent assumptions are against the rules", "It has no real purpose", "So you can change them later without anyone noticing"]'::jsonb,
        'So the interviewer can follow and evaluate your reasoning, not just your final number', 8, 'medium'),
      ('00000000-0000-0000-0003-000000000203', 'Using the lesson''s coffee-shop assumptions (30% of the population drinks coffee, averaging 1.2 coffees/day) on a city of 2,000,000 people, roughly how many coffees are sold per day?',
        '["360,000", "600,000", "720,000", "900,000"]'::jsonb,
        '720,000', 9, 'hard'),
      ('00000000-0000-0000-0003-000000000203', 'What is a case-method interview explicitly NOT testing, per the lesson?',
        '["Structured thinking under uncertainty", "Whether you can guess the interviewer''s expected exact answer immediately", "Whether you can state clear assumptions", "Whether you can reason step by step"]'::jsonb,
        'Whether you can guess the interviewer''s expected exact answer immediately', 10, 'easy'),

      -- ===================== Technical Interview Prep (204) =====================
      ('00000000-0000-0000-0003-000000000204', 'What are the three recurring technical-question themes named in the lesson?',
        '["Valuation, accounting/statement linkage, and markets basics", "History, geography, and current events", "Salary, benefits, and vacation policy", "Grammar, spelling, and punctuation"]'::jsonb,
        'Valuation, accounting/statement linkage, and markets basics', 7, 'easy'),
      ('00000000-0000-0000-0003-000000000204', 'What happens to bond prices when interest rates rise, per the lesson''s anchor explanation?',
        '["They rise", "They fall -- there is an inverse relationship", "They stay exactly the same", "They become impossible to value"]'::jsonb,
        'They fall -- there is an inverse relationship', 8, 'medium'),
      ('00000000-0000-0000-0003-000000000204', 'What is the purpose of practicing anchor explanations "out loud," not just reading them, per the lesson?',
        '["It prevents freezing when asked to explain live under pressure", "It has no real effect on interview performance", "It is required by most interviewers", "It replaces the need to understand the underlying concept"]'::jsonb,
        'It prevents freezing when asked to explain live under pressure', 9, 'medium'),
      ('00000000-0000-0000-0003-000000000204', 'In the worked example (depreciation up £10, 25% tax rate), what is the net effect on total assets?',
        '["Assets rise by £10", "Assets fall by £7.50 net (cash +£2.50, fixed assets -£10)", "Assets are unaffected", "Assets fall by £10"]'::jsonb,
        'Assets fall by £7.50 net (cash +£2.50, fixed assets -£10)', 10, 'hard'),

      -- ===================== Market Sizing & Case Interviews (205) =====================
      ('00000000-0000-0000-0003-000000000205', 'What general structure does this lesson say Case-Method Basics already covered?',
        '["The clarify, break down, assume, calculate, sanity-check process", "A fixed script to memorise for every case", "A rule requiring you to always guess low", "A requirement to never state assumptions"]'::jsonb,
        'The clarify, break down, assume, calculate, sanity-check process', 7, 'easy'),
      ('00000000-0000-0000-0003-000000000205', 'In the bank-branch worked example, what average annual revenue per account is assumed?',
        '["£80", "£120", "£150", "£200"]'::jsonb,
        '£120', 8, 'medium'),
      ('00000000-0000-0000-0003-000000000205', 'Why is a finance-flavored case interviewer also watching your structure, not just your final number, per the lesson?',
        '["Because they want to see whether your structure would actually support a real recommendation", "Because the final number is never checked", "Because structure is only relevant for non-finance cases", "Because interviewers are required to ignore the final number"]'::jsonb,
        'Because they want to see whether your structure would actually support a real recommendation', 9, 'medium'),
      ('00000000-0000-0000-0003-000000000205', 'If the branch''s capture rate were 2% instead of 4% (all else equal), what does the lesson say happens to its year-one economics?',
        '["It stays exactly break-even", "Revenue drops to £84,000 against £150,000 cost, a loss", "Revenue rises above £168,000", "Costs automatically fall to match revenue"]'::jsonb,
        'Revenue drops to £84,000 against £150,000 cost, a loss', 10, 'hard'),

      -- ===================== Ethics & Compliance in Finance (206) =====================
      ('00000000-0000-0000-0003-000000000206', 'What is a conflict of interest, per the lesson?',
        '["A situation where your interests, or your firm''s, could improperly influence advice given to a client", "Any disagreement between two coworkers", "A legal requirement to disclose your salary", "A type of insider trading"]'::jsonb,
        'A situation where your interests, or your firm''s, could improperly influence advice given to a client', 7, 'easy'),
      ('00000000-0000-0000-0003-000000000206', 'Why do interviewers, especially at banks, often ask an ethics/compliance-flavored question, per the lesson?',
        '["To see how a candidate reasons about the issue, not to test memorised rules", "Because it is required by law to ask this exact question", "To eliminate every candidate who answers at all", "Because ethics questions have no real answer"]'::jsonb,
        'To see how a candidate reasons about the issue, not to test memorised rules', 8, 'medium'),
      ('00000000-0000-0000-0003-000000000206', 'What three concepts does the lesson say come up repeatedly in finance ethics questions?',
        '["Conflicts of interest, insider trading, and fiduciary duty", "Marketing, sales, and advertising", "Hiring, firing, and promotion", "Budgeting, saving, and investing"]'::jsonb,
        'Conflicts of interest, insider trading, and fiduciary duty', 9, 'medium'),
      ('00000000-0000-0000-0003-000000000206', 'Why does the lesson say deciding alone and acting quickly is generally the wrong move in a gray-area ethics situation?',
        '["Because escalating to compliance or a manager is the safer default in a regulated industry", "Because acting quickly is always illegal", "Because gray-area situations never actually occur", "Because only senior staff are allowed opinions"]'::jsonb,
        'Because escalating to compliance or a manager is the safer default in a regulated industry', 10, 'hard'),

      -- ===================== Advanced Behavioral: Leadership, Failure & Conflict (207) =====================
      ('00000000-0000-0000-0003-000000000207', 'What does STARL add on top of the STAR structure, per the lesson?',
        '["A second Situation", "Learning -- a concrete statement of what you do differently now", "A list of every team member''s name", "A restatement of the Task"]'::jsonb,
        'Learning -- a concrete statement of what you do differently now', 7, 'easy'),
      ('00000000-0000-0000-0003-000000000207', 'Per the lesson, what are the two most common ways candidates answer failure questions badly?',
        '["Picking a disguised strength, or stopping at the mistake without showing what changed", "Speaking too quietly and too slowly", "Refusing to answer entirely", "Giving too many examples at once"]'::jsonb,
        'Picking a disguised strength, or stopping at the mistake without showing what changed', 8, 'medium'),
      ('00000000-0000-0000-0003-000000000207', 'What does a conflict behavioral question specifically test, distinct from a leadership question, per the lesson?',
        '["Whether you can resolve tension productively without becoming a pushover or combative", "Whether you have ever led a formal team", "Whether you avoid all workplace disagreement", "Whether you always win every argument"]'::jsonb,
        'Whether you can resolve tension productively without becoming a pushover or combative', 9, 'medium'),
      ('00000000-0000-0000-0003-000000000207', 'In the STARL worked example, what specific ongoing behavior change did the candidate describe?',
        '["Never working in groups again", "Asking each teammate to restate their part back and checking in at the halfway point", "Always doing every part of a group project alone", "Assigning someone else to check in instead"]'::jsonb,
        'Asking each teammate to restate their part back and checking in at the halfway point', 10, 'hard'),

      -- ===================== Negotiating a Job Offer (208) =====================
      ('00000000-0000-0000-0003-000000000208', 'What tone does the lesson recommend when making a counter-offer?',
        '["Polite and enthusiastic, while still naming a specific number", "Apologetic about asking for more", "Firm and confrontational", "Vague, to avoid committing to a number"]'::jsonb,
        'Polite and enthusiastic, while still naming a specific number', 5, 'easy'),
      ('00000000-0000-0000-0003-000000000208', 'In the worked example, what number does the candidate counter with, and why?',
        '["$62,000, the original offer", "$70,000, the very top of any range", "$68,000, grounded in the stated $60,000-$70,000 market range", "$100,000, an arbitrary round number"]'::jsonb,
        '$68,000, grounded in the stated $60,000-$70,000 market range', 6, 'medium'),
      ('00000000-0000-0000-0003-000000000208', 'What sources does the lesson suggest for researching a realistic market range?',
        '["Published salary surveys, professional networks, or ranges companies may be required to disclose", "Guessing based on rent prices in the area", "Asking a stranger on the street", "Only the company''s own recruiter"]'::jsonb,
        'Published salary surveys, professional networks, or ranges companies may be required to disclose', 7, 'medium'),
      ('00000000-0000-0000-0003-000000000208', 'What does declining to negotiate at all typically mean, per the lesson?',
        '["Leaving value on the table that the employer had already budgeted for", "Guaranteeing the best possible offer", "Signaling strong negotiating skill", "Having no effect on the final offer either way"]'::jsonb,
        'Leaving value on the table that the employer had already budgeted for', 8, 'hard'),
      ('00000000-0000-0000-0003-000000000208', 'Which of these is explicitly named by the lesson as negotiable besides base salary?',
        '["The interviewer''s personal schedule", "Signing bonus", "The company''s stock price", "The company''s holiday calendar for all staff"]'::jsonb,
        'Signing bonus', 9, 'easy'),
      ('00000000-0000-0000-0003-000000000208', 'Why is asking for "as much as possible" with no anchor considered a weak approach, per the lesson?',
        '["It is illegal in most jurisdictions", "It isn''t a specific, defensible number grounded in research", "It always results in a lower offer", "Employers are required to reject it"]'::jsonb,
        'It isn''t a specific, defensible number grounded in research', 10, 'medium'),

      -- ===================== Understanding Your Compensation Package (209) =====================
      ('00000000-0000-0000-0003-000000000209', 'Which compensation component is described as "fixed, predictable pay," per the lesson?',
        '["Bonus", "Equity", "Base salary", "Benefits"]'::jsonb,
        'Base salary', 5, 'easy'),
      ('00000000-0000-0000-0003-000000000209', 'Why can comparing two offers by base salary alone be misleading, per the lesson?',
        '["Because base salary is always identical across companies", "Because their other components (bonus, equity, benefits) may differ substantially", "Because base salary is not actually part of compensation", "Because only the highest base salary ever matters"]'::jsonb,
        'Because their other components (bonus, equity, benefits) may differ substantially', 6, 'medium'),
      ('00000000-0000-0000-0003-000000000209', 'What kind of value does a benefit like employer-paid health insurance carry, per the lesson, even though it isn''t cash?',
        '["No value at all", "Real monetary value comparable to what it would cost to buy individually", "Only symbolic value", "Negative value, since it reduces take-home pay"]'::jsonb,
        'Real monetary value comparable to what it would cost to buy individually', 7, 'medium'),
      ('00000000-0000-0000-0003-000000000209', 'In the worked example, roughly how much is Offer B''s employer-paid health insurance worth per year?',
        '["Roughly $600", "Roughly $6,000", "Roughly $16,000", "Roughly $60,000"]'::jsonb,
        'Roughly $6,000', 8, 'hard'),
      ('00000000-0000-0000-0003-000000000209', 'What determines whether a bonus target is actually paid out in full, per the lesson?',
        '["Hitting performance targets, which aren''t fully in your control", "The employee''s tenure alone", "Whether the bonus is mentioned in the offer letter", "Nothing -- bonus targets are always paid in full"]'::jsonb,
        'Hitting performance targets, which aren''t fully in your control', 9, 'easy'),
      ('00000000-0000-0000-0003-000000000209', 'What is the lesson''s overall recommendation when comparing job offers?',
        '["Compare total package value, not just base salary", "Only ever compare base salary", "Ignore benefits entirely", "Always take the offer with the highest signing bonus"]'::jsonb,
        'Compare total package value, not just base salary', 10, 'medium'),

      -- ===================== Reading a Pay Stub & Taxes (210) =====================
      ('00000000-0000-0000-0003-000000000210', 'What are voluntary deductions, per the lesson?',
        '["Deductions you elected yourself, like retirement contributions or a share of health premiums", "Deductions required by federal law with no exceptions", "A synonym for gross pay", "Deductions taken only from bonus pay"]'::jsonb,
        'Deductions you elected yourself, like retirement contributions or a share of health premiums', 5, 'easy'),
      ('00000000-0000-0000-0003-000000000210', 'What life changes does the lesson say can affect how much tax should be withheld going forward?',
        '["A raise, a second job, or marriage", "Changing your commute route", "Moving to a new desk at the same job", "Getting a new phone number"]'::jsonb,
        'A raise, a second job, or marriage', 6, 'medium'),
      ('00000000-0000-0000-0003-000000000210', 'What happens if too much tax was withheld across the year, per the lesson?',
        '["You owe an additional penalty", "You get a refund", "Nothing changes at tax-filing time", "Your employer keeps the difference"]'::jsonb,
        'You get a refund', 7, 'easy'),
      ('00000000-0000-0000-0003-000000000210', 'In the worked example, what is the total of federal, payroll, and state tax withheld (before the voluntary 401(k) deduction)?',
        '["$505", "$585", "$630", "$755"]'::jsonb,
        '$585', 8, 'hard'),
      ('00000000-0000-0000-0003-000000000210', 'What is a W-4, per the lesson''s US-context example?',
        '["A form of ID required to start a job", "Information you provide that determines estimated tax withholding", "A tax refund check", "A retirement account statement"]'::jsonb,
        'Information you provide that determines estimated tax withholding', 9, 'easy'),
      ('00000000-0000-0000-0003-000000000210', 'Why does the lesson say someone who budgets against their quoted salary will "consistently overspend"?',
        '["Because deductions mean actual net pay is meaningfully less than the gross figure", "Because quoted salaries are usually inflated by employers", "Because net pay is always higher than gross pay", "Because budgeting is unrelated to pay stubs"]'::jsonb,
        'Because deductions mean actual net pay is meaningfully less than the gross figure', 10, 'medium'),

      -- ===================== Employer Retirement Matching (211) =====================
      ('00000000-0000-0000-0003-000000000211', 'What US retirement plan does the lesson use as its main example?',
        '["A 401(k)", "A Roth IRA only", "A pension with no employee contribution", "A health savings account"]'::jsonb,
        'A 401(k)', 5, 'easy'),
      ('00000000-0000-0000-0003-000000000211', 'What does "matching 50% of your contribution, up to 6% of your salary" mean, per the lesson?',
        '["The employer pays your full salary in retirement contributions", "The employer adds 50 cents for every dollar you contribute, up to a contribution of 6% of salary", "You must contribute exactly 50% of your salary", "The employer only matches after 6 years of employment"]'::jsonb,
        'The employer adds 50 cents for every dollar you contribute, up to a contribution of 6% of salary', 6, 'medium'),
      ('00000000-0000-0000-0003-000000000211', 'Contributions in these retirement accounts usually grow how, per the lesson?',
        '["Tax-advantaged, without being taxed each year the way ordinary account gains might be", "Fully taxed every year at the highest rate", "Only in cash with no growth at all", "Exactly the same as a regular checking account"]'::jsonb,
        'Tax-advantaged, without being taxed each year the way ordinary account gains might be', 7, 'medium'),
      ('00000000-0000-0000-0003-000000000211', 'Priya earns $50,000/year with a 50%-match-up-to-6% plan. If she contributes 4% instead of the full 6%, how much employer match does she receive?',
        '["$1,500", "$1,000", "$2,000", "$500"]'::jsonb,
        '$1,000', 8, 'hard'),
      ('00000000-0000-0000-0003-000000000211', 'What does the lesson call skipping a full employer retirement match?',
        '["A smart, risk-free choice", "Leaving free money -- guaranteed extra pay -- on the table", "A legal requirement for new employees", "Something with no real cost either way"]'::jsonb,
        'Leaving free money -- guaranteed extra pay -- on the table', 9, 'easy'),
      ('00000000-0000-0000-0003-000000000211', 'Why does the lesson say to check your own plan''s specific match formula rather than assume a standard one?',
        '["Because match formulas vary by employer, and the plan''s actual terms determine how much you should contribute to capture it fully", "Because all plans are legally required to be identical", "Because match formulas never affect take-home pay", "Because checking the formula is optional and has no real benefit"]'::jsonb,
        'Because match formulas vary by employer, and the plan''s actual terms determine how much you should contribute to capture it fully', 10, 'medium'),

      -- ===================== Health Insurance Basics (212) =====================
      ('00000000-0000-0000-0003-000000000212', 'What is a premium, per the lesson?',
        '["What you must pay out of pocket before insurance covers a larger share", "What you pay regularly, usually deducted from each paycheck, regardless of whether you use care", "A one-time signup fee", "A tax withheld from your paycheck"]'::jsonb,
        'What you pay regularly, usually deducted from each paycheck, regardless of whether you use care', 5, 'easy'),
      ('00000000-0000-0000-0003-000000000212', 'What is a deductible, per the lesson?',
        '["What you must pay out of pocket for care before insurance starts covering a larger share", "A monthly fee paid regardless of care used", "A synonym for premium", "A tax credit for buying insurance"]'::jsonb,
        'What you must pay out of pocket for care before insurance starts covering a larger share', 6, 'easy'),
      ('00000000-0000-0000-0003-000000000212', 'Who might prefer a low-premium, high-deductible plan, per the lesson?',
        '["Someone who rarely needs medical care and wants to minimize guaranteed monthly cost", "Someone who expects frequent, ongoing medical care", "Someone who wants the lowest possible deductible", "Someone with no interest in cost at all"]'::jsonb,
        'Someone who rarely needs medical care and wants to minimize guaranteed monthly cost', 7, 'medium'),
      ('00000000-0000-0000-0003-000000000212', 'In the worked example, what is Plan A''s total cost (premiums + deductible) if a $4,000 medical expense occurs?',
        '["$600", "$1,800", "$3,000", "$3,600"]'::jsonb,
        '$3,600', 8, 'hard'),
      ('00000000-0000-0000-0003-000000000212', 'What is the general relationship between premium and deductible across health plans, per the lesson?',
        '["They always move in the same direction", "Lower premium typically means higher deductible, and vice versa", "They are set independently with no typical pattern", "Deductibles are fixed by law and never vary"]'::jsonb,
        'Lower premium typically means higher deductible, and vice versa', 9, 'easy'),
      ('00000000-0000-0000-0003-000000000212', 'What should ultimately determine which health plan is the "right" choice for a given person, per the lesson?',
        '["Always the lowest premium available", "How much medical care you realistically expect to use in a given year", "Whichever plan a coworker picked", "Always the lowest deductible available"]'::jsonb,
        'How much medical care you realistically expect to use in a given year', 10, 'medium'),

      -- ===================== Workplace Financial Etiquette (213) =====================
      ('00000000-0000-0000-0003-000000000213', 'What is generally required to submit a proper expense report, per the lesson?',
        '["An itemized receipt, a stated business purpose, and timely submission", "Just a verbal request to a manager", "Nothing -- all expenses are automatically reimbursed", "Only a credit card statement total"]'::jsonb,
        'An itemized receipt, a stated business purpose, and timely submission', 5, 'easy'),
      ('00000000-0000-0000-0003-000000000213', 'What does a per diem replace the need for, per the lesson?',
        '["Itemized receipts for every small purchase like meals during travel", "Any kind of expense reporting at all", "A manager''s approval", "A stated business purpose"]'::jsonb,
        'Itemized receipts for every small purchase like meals during travel', 6, 'medium'),
      ('00000000-0000-0000-0003-000000000213', 'Is it acceptable to treat a generous per diem as personal spending money, per the lesson?',
        '["Yes, per diems are unrestricted personal funds", "No, spending is still expected to stay reasonable and business-related", "Yes, as long as no receipts are requested", "Only during international travel"]'::jsonb,
        'No, spending is still expected to stay reasonable and business-related', 7, 'medium'),
      ('00000000-0000-0000-0003-000000000213', 'In the worked example, what specifically made the vague expense submission problematic?',
        '["It was for too small a dollar amount", "No receipts, no clear business purpose, and submission six weeks late", "It was submitted using the wrong software", "It included too much detail"]'::jsonb,
        'No receipts, no clear business purpose, and submission six weeks late', 8, 'hard'),
      ('00000000-0000-0000-0003-000000000213', 'What is commonly required alongside a credit card statement total for reimbursement, per the lesson?',
        '["Nothing further is ever required", "An itemized receipt, not just the statement total", "A notarized letter", "Approval from two separate managers"]'::jsonb,
        'An itemized receipt, not just the statement total', 9, 'easy'),
      ('00000000-0000-0000-0003-000000000213', 'What does careful, well-documented expense reporting do, per the lesson?',
        '["Guarantees a promotion", "Builds trust with a manager or finance team early in a role", "Has no effect on workplace relationships", "Automatically increases your salary"]'::jsonb,
        'Builds trust with a manager or finance team early in a role', 10, 'medium'),

      -- ===================== Budgeting on Your First Salary (214) =====================
      ('00000000-0000-0000-0003-000000000214', 'What is the first correction the lesson recommends for a first budget?',
        '["Building it around net pay, not the headline salary figure", "Spending exactly what you earn each month", "Ignoring taxes entirely", "Budgeting only once a year"]'::jsonb,
        'Building it around net pay, not the headline salary figure', 5, 'easy'),
      ('00000000-0000-0000-0003-000000000214', 'What percentage of net pay does the 50/30/20 framework allocate to wants?',
        '["20%", "30%", "50%", "70%"]'::jsonb,
        '30%', 6, 'medium'),
      ('00000000-0000-0000-0003-000000000214', 'On $3,200/month net pay, roughly how much does the 50/30/20 framework suggest for savings and extra debt paydown?',
        '["$320", "$480", "$640", "$960"]'::jsonb,
        '$640', 7, 'hard'),
      ('00000000-0000-0000-0003-000000000214', 'Why is 50/30/20 described as a starting benchmark rather than a rigid rule, per the lesson?',
        '["Because cost of living varies enormously by location", "Because it only applies to people over 30", "Because it is a legal requirement in some states", "Because savings percentages are fixed by law"]'::jsonb,
        'Because cost of living varies enormously by location', 8, 'medium'),
      ('00000000-0000-0000-0003-000000000214', 'What is "lifestyle inflation," per the lesson?',
        '["A government policy that raises minimum wage", "Scaling up spending immediately to match a new, larger gross salary figure", "A type of tax withholding", "An annual cost-of-living raise from an employer"]'::jsonb,
        'Scaling up spending immediately to match a new, larger gross salary figure', 9, 'easy'),
      ('00000000-0000-0000-0003-000000000214', 'What should be decided deliberately, rather than left to whatever remains at month''s end, per the lesson?',
        '["How much of net pay goes to needs, wants, and savings", "The exact date rent is due", "Your employer''s pay schedule", "The name of your bank"]'::jsonb,
        'How much of net pay goes to needs, wants, and savings', 10, 'medium'),

      -- ===================== Building an Emergency Fund (215) =====================
      ('00000000-0000-0000-0003-000000000215', 'What kinds of expenses is an emergency fund meant to absorb, per the lesson?',
        '["Planned monthly bills like rent", "Unplanned, necessary expenses like a job loss, medical bill, or urgent car repair", "Vacations and discretionary purchases", "Retirement contributions"]'::jsonb,
        'Unplanned, necessary expenses like a job loss, medical bill, or urgent car repair', 5, 'easy'),
      ('00000000-0000-0000-0003-000000000215', 'Why is an emergency fund kept separate from everyday spending and other savings goals, per the lesson?',
        '["So it isn''t accidentally spent on something else", "Because banks require separate accounts by law", "So it can be invested more aggressively", "Because it earns a different interest rate automatically"]'::jsonb,
        'So it isn''t accidentally spent on something else', 6, 'medium'),
      ('00000000-0000-0000-0003-000000000215', 'What commonly cited target range does the lesson give for an emergency fund?',
        '["1-2 weeks of essential expenses", "3-6 months of essential expenses", "1-2 years of full income", "A fixed $10,000 for everyone"]'::jsonb,
        '3-6 months of essential expenses', 7, 'medium'),
      ('00000000-0000-0000-0003-000000000215', 'In the worked example, saving $200/month starting from $0, roughly how long does it take to reach the 6-month target of $10,800?',
        '["27 months", "36 months", "54 months", "90 months"]'::jsonb,
        '54 months', 8, 'hard'),
      ('00000000-0000-0000-0003-000000000215', 'What determines whether someone should target the lower or higher end of the 3-6 month range, per the lesson?',
        '["Job stability and other safety nets", "The current stock market''s performance", "Their employer''s size", "How much they enjoy saving money"]'::jsonb,
        'Job stability and other safety nets', 9, 'easy'),
      ('00000000-0000-0000-0003-000000000215', 'Why does the lesson recommend keeping an emergency fund in something accessible and low-risk rather than invested?',
        '["So it isn''t at risk of losing value right when it''s needed", "Because investing is illegal for personal savings", "Because low-risk accounts always outperform investments", "Because emergency funds are never actually used"]'::jsonb,
        'So it isn''t at risk of losing value right when it''s needed', 10, 'medium'),

      -- ===================== Startup Equity & Stock Options (216) =====================
      ('00000000-0000-0000-0003-000000000216', 'What is a strike price, per the lesson?',
        '["The current public market price of a stock", "The fixed price set now at which you can later buy company shares", "A fee charged for exercising options", "The company''s annual revenue"]'::jsonb,
        'The fixed price set now at which you can later buy company shares', 5, 'easy'),
      ('00000000-0000-0000-0003-000000000216', 'What does "dilution" mean, per the lesson?',
        '["Your number of shares automatically decreases over time", "As a startup issues more shares in later funding rounds, each existing share represents a smaller percentage of the company", "Options become worth more as more shares are issued", "A company reducing its total valuation"]'::jsonb,
        'As a startup issues more shares in later funding rounds, each existing share represents a smaller percentage of the company', 6, 'medium'),
      ('00000000-0000-0000-0003-000000000216', 'What is a common vesting schedule structure named in the lesson?',
        '["4 years with a 1-year cliff", "1 year with no cliff", "10 years with no cliff", "Immediate vesting on the first day"]'::jsonb,
        '4 years with a 1-year cliff', 7, 'medium'),
      ('00000000-0000-0000-0003-000000000216', 'In the worked example, what is the pre-tax value of 10,000 vested options at a $1 strike price if shares are later worth $5 each?',
        '["$10,000", "$40,000", "$50,000", "$60,000"]'::jsonb,
        '$40,000', 8, 'hard'),
      ('00000000-0000-0000-0003-000000000216', 'Why do startups sometimes offer equity as part of a compensation package, per the lesson?',
        '["Because cash salary is often lower than at an established company", "Because it is required by law for all startups", "Because equity always guarantees higher total pay", "Because cash compensation is illegal at startups"]'::jsonb,
        'Because cash salary is often lower than at an established company', 9, 'easy'),
      ('00000000-0000-0000-0003-000000000216', 'Why does the lesson recommend treating startup equity as speculative upside rather than a cash substitute?',
        '["Because most startups fail or are acquired for modest amounts, so most employee equity ends up worth little or nothing", "Because equity is always worth more than cash", "Because equity cannot legally be included in an offer", "Because options vest immediately with no risk"]'::jsonb,
        'Because most startups fail or are acquired for modest amounts, so most employee equity ends up worth little or nothing', 10, 'medium'),

      -- ===================== Professional Networking Basics (217) =====================
      ('00000000-0000-0000-0003-000000000217', 'What does the lesson identify as the lowest-pressure, most effective form of networking for someone early in their career?',
        '["The informational interview", "Cold-calling company executives", "Mass-messaging as many strangers as possible", "Attending only large public job fairs"]'::jsonb,
        'The informational interview', 5, 'easy'),
      ('00000000-0000-0000-0003-000000000217', 'What does an informational interview explicitly NOT ask for, per the lesson?',
        '["Someone''s perspective on their field", "A job", "15 minutes of someone''s time", "Advice on a career path"]'::jsonb,
        'A job', 6, 'medium'),
      ('00000000-0000-0000-0003-000000000217', 'Why does an informational interview cost the other person "little," per the lesson?',
        '["Because it doesn''t put them on the spot to make a hiring decision", "Because it is always shorter than 5 minutes", "Because it is anonymous", "Because it requires no response at all"]'::jsonb,
        'Because it doesn''t put them on the spot to make a hiring decision', 7, 'medium'),
      ('00000000-0000-0000-0003-000000000217', 'In the worked example outreach message, what three qualities make it effective, per the lesson?',
        '["Long, formal, and generic", "Specific, time-bounded, and low-pressure", "Vague, urgent, and demanding", "Anonymous, brief, and impersonal"]'::jsonb,
        'Specific, time-bounded, and low-pressure', 8, 'hard'),
      ('00000000-0000-0000-0003-000000000217', 'What keeps a networking relationship "genuinely alive," per the lesson?',
        '["Only reaching out when you need something", "Following up and staying in touch over time", "Sending the same message to everyone once", "Never contacting the person again after the first meeting"]'::jsonb,
        'Following up and staying in touch over time', 9, 'easy'),
      ('00000000-0000-0000-0003-000000000217', 'Why does the lesson warn against every message to a contact feeling like a "one-off ask"?',
        '["Because it prevents building a genuine, ongoing professional relationship", "Because one-off messages are against LinkedIn''s rules", "Because it makes messages too short", "Because contacts expect a new ask every single time"]'::jsonb,
        'Because it prevents building a genuine, ongoing professional relationship', 10, 'medium'),

      -- ===================== Personal Branding & LinkedIn Basics (218) =====================
      ('00000000-0000-0000-0003-000000000218', 'What does the lesson identify as the highest-leverage piece of an early-career professional''s public presence?',
        '["A personal website", "LinkedIn", "A physical business card", "A printed resume alone"]'::jsonb,
        'LinkedIn', 5, 'easy'),
      ('00000000-0000-0000-0003-000000000218', 'What should a strong LinkedIn headline state, beyond just a job title, per the lesson?',
        '["What you actually do or are looking for", "Your exact salary expectations", "Your home address", "A list of every course you have taken"]'::jsonb,
        'What you actually do or are looking for', 6, 'medium'),
      ('00000000-0000-0000-0003-000000000218', 'How should a LinkedIn summary be written, per the lesson?',
        '["As a bare list of skills with no context", "In your own voice, stating background and goals", "Copy-pasted from a template with no changes", "As short as physically possible, with zero detail"]'::jsonb,
        'In your own voice, stating background and goals', 7, 'medium'),
      ('00000000-0000-0000-0003-000000000218', 'Why does the lesson warn against copy-pasting official job descriptions into LinkedIn experience entries?',
        '["Because job descriptions are copyrighted and cannot legally be referenced", "Because entries should follow the same context/action/result pattern as strong resume bullets", "Because LinkedIn automatically deletes copied text", "Because experience entries are optional and rarely read"]'::jsonb,
        'Because entries should follow the same context/action/result pattern as strong resume bullets', 8, 'hard'),
      ('00000000-0000-0000-0003-000000000218', 'What does the lesson call the consistent impression your public professional presence creates?',
        '["A resume summary", "A personal brand", "A cover letter", "A reference list"]'::jsonb,
        'A personal brand', 9, 'easy'),
      ('00000000-0000-0000-0003-000000000218', 'Why does consistency across resume, LinkedIn, and interview story matter, per the lesson?',
        '["Discrepancies (mismatched dates, different framings) are a quiet red flag to anyone checking closely", "LinkedIn automatically flags any inconsistency to employers", "Consistency is legally required for all job applicants", "It has no real effect on how a candidate is perceived"]'::jsonb,
        'Discrepancies (mismatched dates, different framings) are a quiet red flag to anyone checking closely', 10, 'medium'),

      -- ===================== Benefits Enrollment (219) =====================
      ('00000000-0000-0000-0003-000000000219', 'What is open enrollment, per the lesson?',
        '["A one-time signup available only to new hires", "A defined annual window to choose or change benefit elections", "An ongoing process available at any time of year", "A window for negotiating base salary"]'::jsonb,
        'A defined annual window to choose or change benefit elections', 5, 'easy'),
      ('00000000-0000-0000-0003-000000000219', 'What can allow a benefit election change outside the open enrollment window, per the lesson?',
        '["A qualifying life event, like marriage or a new child", "Simply asking HR at any time", "Nothing -- elections can never change outside the window", "Changing job titles within the same company"]'::jsonb,
        'A qualifying life event, like marriage or a new child', 6, 'medium'),
      ('00000000-0000-0000-0003-000000000219', 'What is an HSA typically available alongside, per the lesson?',
        '["Any health plan, with no restrictions", "Certain high-deductible health plans", "Only employer-paid plans with no premium", "Dental insurance exclusively"]'::jsonb,
        'Certain high-deductible health plans', 7, 'medium'),
      ('00000000-0000-0000-0003-000000000219', 'In the worked example, how much of a $2,000 HSA contribution rolls over if only $600 is used that year?',
        '["$0", "$600", "$1,400", "$2,000"]'::jsonb,
        '$1,400', 8, 'hard'),
      ('00000000-0000-0000-0003-000000000219', 'What does "use it or lose it" describe, per the lesson?',
        '["An HSA''s permanent, rolling-over balance", "A standard FSA''s typical rule that unused balance is forfeited at year-end", "A rule that applies to base salary", "A rule requiring immediate spending of any bonus"]'::jsonb,
        'A standard FSA''s typical rule that unused balance is forfeited at year-end', 9, 'easy'),
      ('00000000-0000-0000-0003-000000000219', 'Why does the lesson recommend understanding benefit choices before the enrollment window, not during it?',
        '["Because most elections are locked in for a full year absent a qualifying life event", "Because the window is only open for one hour each year", "Because benefits information disappears once the window opens", "Because elections made during the window are non-binding anyway"]'::jsonb,
        'Because most elections are locked in for a full year absent a qualifying life event', 10, 'medium'),

      -- ===================== Credit Cards & Building Credit (220) =====================
      ('00000000-0000-0000-0003-000000000220', 'What does a credit score summarize, per the lesson?',
        '["Your total account balance across all banks", "How reliably you have repaid borrowed money in the past", "Your annual income", "Your employer''s credit rating"]'::jsonb,
        'How reliably you have repaid borrowed money in the past', 5, 'easy'),
      ('00000000-0000-0000-0003-000000000220', 'Besides credit approvals, what else can a credit score influence, per the lesson?',
        '["Apartment applications and car loan interest rates", "Your eligibility to vote", "Your passport renewal", "Your employer''s stock price"]'::jsonb,
        'Apartment applications and car loan interest rates', 6, 'medium'),
      ('00000000-0000-0000-0003-000000000220', 'What happens if you carry a credit card balance instead of paying it in full, per the lesson?',
        '["Nothing -- there is no cost to carrying a balance", "You typically pay interest, often 20%+ APR, on top of the underlying debt", "Your credit limit is automatically reduced to zero", "Your credit score always improves"]'::jsonb,
        'You typically pay interest, often 20%+ APR, on top of the underlying debt', 7, 'medium'),
      ('00000000-0000-0000-0003-000000000220', 'What is "credit utilization," per the lesson?',
        '["The number of credit cards you own", "The share of your available credit limit you are actually using", "The interest rate charged on a loan", "The number of years you have had credit"]'::jsonb,
        'The share of your available credit limit you are actually using', 8, 'hard'),
      ('00000000-0000-0000-0003-000000000220', 'What does the lesson identify as typically the single most damaging action to a credit score?',
        '["Having a high credit limit", "Missing a payment, even by a few days", "Opening a first credit card at all", "Using a credit card for everyday purchases"]'::jsonb,
        'Missing a payment, even by a few days', 9, 'easy'),
      ('00000000-0000-0000-0003-000000000220', 'In the worked example, how can spreading spending more evenly across the month help, even without changing total spending?',
        '["It keeps reported utilization lower at the moment the issuer reports the balance", "It automatically lowers the interest rate charged", "It increases the credit limit", "It has no effect on the score at all"]'::jsonb,
        'It keeps reported utilization lower at the moment the issuer reports the balance', 10, 'medium'),

      -- ===================== Student Loan Repayment Basics (221) =====================
      ('00000000-0000-0000-0003-000000000221', 'How long is a typical loan grace period after graduation, per the lesson?',
        '["Around 6 months", "Around 2 weeks", "Around 5 years", "There is no grace period"]'::jsonb,
        'Around 6 months', 5, 'easy'),
      ('00000000-0000-0000-0003-000000000221', 'What do federal loans generally offer that private loans typically do not, per the lesson?',
        '["More repayment plan options, including income-driven plans in some cases", "A guaranteed lower interest rate in all cases", "Automatic forgiveness after one year", "No grace period at all"]'::jsonb,
        'More repayment plan options, including income-driven plans in some cases', 6, 'medium'),
      ('00000000-0000-0000-0003-000000000221', 'What does a standard repayment plan set, per the lesson?',
        '["A fixed monthly payment over a fixed period, often 10 years", "A payment that changes every month at random", "No monthly payment until the balance is due in full", "A payment based only on discretionary income"]'::jsonb,
        'A fixed monthly payment over a fixed period, often 10 years', 7, 'medium'),
      ('00000000-0000-0000-0003-000000000221', 'In the worked example, roughly what is the fixed monthly payment on a $30,000 loan at 5% interest over a standard 10-year plan?',
        '["Roughly $150", "Roughly $320", "Roughly $500", "Roughly $1,000"]'::jsonb,
        'Roughly $320', 8, 'hard'),
      ('00000000-0000-0000-0003-000000000221', 'What does an income-driven repayment plan set the payment as, per the lesson?',
        '["A fixed dollar amount for everyone", "A percentage of discretionary income", "A percentage of total loan balance paid upfront", "Whatever amount the lender chooses randomly"]'::jsonb,
        'A percentage of discretionary income', 9, 'easy'),
      ('00000000-0000-0000-0003-000000000221', 'What is the main trade-off of an income-driven plan compared to a standard plan, per the lesson?',
        '["It has no trade-off -- it is strictly better in every way", "Lower near-term payments, but usually a longer repayment period and more total interest paid", "Higher near-term payments but a shorter repayment period", "It is only available for private loans"]'::jsonb,
        'Lower near-term payments, but usually a longer repayment period and more total interest paid', 10, 'medium'),

      -- ===================== Workplace Communication & Professionalism (222) =====================
      ('00000000-0000-0000-0003-000000000222', 'Why are workplace communication norms easy to get wrong early in a career, per the lesson?',
        '["They are usually never explicitly taught", "They are identical at every company", "They are written into every employee handbook in detail", "They never change between workplaces"]'::jsonb,
        'They are usually never explicitly taught', 5, 'easy'),
      ('00000000-0000-0000-0003-000000000222', 'What is the lesson''s recommended default for norms like response speed and channel choice?',
        '["Matching the tone and channel your current team already uses", "Always using the most formal channel available", "Copying exactly what your previous school or internship did", "Ignoring norms entirely and doing whatever feels natural"]'::jsonb,
        'Matching the tone and channel your current team already uses', 6, 'medium'),
      ('00000000-0000-0000-0003-000000000222', 'Where should a disagreement with a manager''s decision generally be raised first, per the lesson?',
        '["In a large team meeting for visibility", "Privately, with the relevant person", "Anonymously through a suggestion box", "Never -- disagreements should not be raised at all"]'::jsonb,
        'Privately, with the relevant person', 7, 'medium'),
      ('00000000-0000-0000-0003-000000000222', 'In the worked example, what made the stronger response to a disagreement effective, per the lesson?',
        '["It avoided stating any actual concern", "It raised a clear, reasoned concern privately and offered to help rather than just criticize", "It was delivered in a team meeting for visibility", "It simply agreed with the manager regardless of the concern"]'::jsonb,
        'It raised a clear, reasoned concern privately and offered to help rather than just criticize', 8, 'hard'),
      ('00000000-0000-0000-0003-000000000222', 'What does the lesson warn against assuming transfers directly between workplaces?',
        '["Communication norms from school or a previous internship", "Your job title", "Your salary expectations", "Your resume format"]'::jsonb,
        'Communication norms from school or a previous internship', 9, 'easy'),
      ('00000000-0000-0000-0003-000000000222', 'Why does raising a disagreement in a group setting tend to be worse than raising it privately first, per the lesson?',
        '["It is more likely to read as combative and can damage the relationship even when the concern is valid", "Group settings are against company policy everywhere", "Managers never respond in group settings", "It takes longer to raise a concern privately"]'::jsonb,
        'It is more likely to read as combative and can damage the relationship even when the concern is valid', 10, 'medium');
  end if;
end $$;

-- ===================== 3. Job-Ready case-study skill/lesson/quizzes/questions =====================
-- Copied forward verbatim from 00000000000045, except the quiz_questions
-- insert is reshaped (see header) so grading_keywords/min_keyword_matches
-- are derived automatically from the original keywords values.

do $$
begin
  if not exists (select 1 from skills where id = '00000000-0000-0000-0001-000000000223') then

    insert into skills (id, tier, slug, title, prerequisite_skill_id, mastery_threshold) values
      ('00000000-0000-0000-0001-000000000223', 'job_ready', 'case-study-practice', 'Case Study Practice: Real-World Scenarios',
        '00000000-0000-0000-0001-000000000222', 0.8);

    insert into lessons (id, skill_id, content_type, content_body, order_index) values
      ('00000000-0000-0000-0002-000000000223', '00000000-0000-0000-0001-000000000223', 'article',
       'The lessons so far each covered one concept at a time -- negotiating an offer, reading a pay stub, workplace ethics. Real situations rarely arrive that neatly separated: a single job offer decision might involve negotiation, compensation structure, and equity risk all at once. Case studies below present a realistic scenario once, then ask several questions about it -- some multiple-choice, some asking you to type a short answer in your own words.

    Typed answers aren''t graded by matching your exact wording -- they''re checked for whether your answer touches the key concepts a strong response should cover (similar to how a manager skimming a written answer would check for the right ideas, not a specific script). Answering in a few clear sentences that name the relevant concepts directly tends to score better than a vague answer that talks around the topic without naming it.

    Recap: case studies combine multiple concepts from earlier lessons into one realistic scenario. For typed questions, name the specific concepts your answer relies on directly and concretely, rather than writing generally around the topic.',
       1);

    insert into quizzes (id, skill_id, title, pass_threshold, quiz_type, context_tag, scenario_body) values
      ('00000000-0000-0000-0003-000000000223', '00000000-0000-0000-0001-000000000223',
       'Case Study: Evaluating a Job Offer', 0.7, 'case_study',
       'Job Offer Evaluation -- Series B Fintech Startup, Business Analyst Role',
       'You''ve just graduated and received a job offer from Nimbus Pay, a Series B fintech startup, for a Business Analyst role. The offer: $68,000 base salary, a 10% target annual bonus (not guaranteed), 8,000 stock options at a $2 strike price vesting over 4 years with a 1-year cliff, and health insurance with the company covering 70% of the premium (your share: $120/month). You also have a competing offer from a large, established bank for the same type of role: $78,000 base salary, no bonus, no equity, and the bank covering 100% of your health insurance premium. Both roles start in one month.'),
      ('00000000-0000-0000-0003-000000000224', '00000000-0000-0000-0001-000000000223',
       'Case Study: Reading a Pay Stub', 0.7, 'case_study',
       'Pay Stub Literacy -- First Job, Retail Management Trainee',
       'Jordan just started as a Retail Management Trainee and received their first pay stub for a two-week pay period: gross pay $2,200; federal income tax withheld $310; state tax withheld $88; payroll taxes (Social Security + Medicare) $168; voluntary 401(k) contribution $110; health insurance premium share $75.'),
      ('00000000-0000-0000-0003-000000000225', '00000000-0000-0000-0001-000000000223',
       'Case Study: A Workplace Ethics Dilemma', 0.7, 'case_study',
       'Workplace Ethics -- Financial Services Compliance Scenario',
       'You''re a junior analyst at an asset management firm. While reviewing expense reports, you notice a senior colleague submitted a client dinner receipt for $450 with a vague note ("business development"), and you happen to know from a group chat that the dinner was actually a birthday celebration for the colleague''s spouse, with no client present. Separately, that same week, a friend at another firm mentions -- before any public announcement -- that their company is about to be acquired.'),
      ('00000000-0000-0000-0003-000000000226', '00000000-0000-0000-0001-000000000223',
       'Case Study: Startup Equity vs. a Stable Corporate Offer', 0.7, 'case_study',
       'Compensation Trade-offs -- Early-Stage Startup vs. Established Corporation',
       'Amara has two offers six months after graduating. Offer 1, at an early-stage (Series A) startup: $58,000 base, 15,000 stock options at a $0.50 strike price, 4-year vesting with a 1-year cliff, no 401(k) match, standard health insurance. Offer 2, at a large established corporation: $72,000 base, no equity, a 401(k) with a 50%-match-up-to-6% formula, and a strong health plan with a low deductible. The startup has raised two funding rounds and has 18 months of cash remaining at its current spending rate.');
    insert into quiz_questions (quiz_id, question, options, correct_answer, order_index, difficulty, question_type, grading_keywords, min_keyword_matches)
    select quiz_id::uuid, question, options, correct_answer, order_index::integer, difficulty, question_type, keywords,
      case when keywords is null then 1 else greatest(1, ceil(jsonb_array_length(keywords) * 0.5))::integer end
    from (values
      -- ===================== Case Study: Evaluating a Job Offer (223) =====================
      ('00000000-0000-0000-0003-000000000223', 'What is Nimbus Pay''s stated bonus target, and is it guaranteed?',
        '["10%, guaranteed regardless of performance", "10%, not guaranteed and dependent on performance", "20%, guaranteed", "There is no bonus at all"]'::jsonb,
        '10%, not guaranteed and dependent on performance', 1, 'easy', 'multiple_choice', null),
      ('00000000-0000-0000-0003-000000000223', 'Which offer has the lower guaranteed base salary?',
        '["Nimbus Pay''s offer ($68,000 vs. $78,000)", "The established bank''s offer", "They are exactly equal", "Cannot be determined from the scenario"]'::jsonb,
        'Nimbus Pay''s offer ($68,000 vs. $78,000)', 2, 'medium', 'multiple_choice', null),
      ('00000000-0000-0000-0003-000000000223', 'Nimbus Pay''s options only have value once the share price exceeds the strike price. What would need to happen for these options to be worth anything?',
        '["The share price would need to rise above $2", "The share price would need to fall below $2", "The options are worthless no matter what the share price does", "The options convert to guaranteed cash after 1 year"]'::jsonb,
        'The share price would need to rise above $2', 3, 'hard', 'multiple_choice', null),
      ('00000000-0000-0000-0003-000000000223', 'Besides base salary, name at least two other factors from this scenario that meaningfully affect the true value of each offer, and briefly explain why each matters.',
        '[]'::jsonb, '(graded via grading_keywords, not correct_answer)', 4, 'medium', 'free_response',
        '["bonus", "equity", "options", "vesting", "health insurance", "premium", "cliff"]'::jsonb),
      ('00000000-0000-0000-0003-000000000223', 'Given the 1-year cliff on Nimbus Pay''s options, what risk would you take by leaving that job after 8 months, and how should that risk factor into your decision between the two offers?',
        '[]'::jsonb, '(graded via grading_keywords, not correct_answer)', 5, 'hard', 'free_response',
        '["forfeit", "cliff", "1 year", "unvested", "risk", "leave early", "no equity"]'::jsonb),

      -- ===================== Case Study: Reading a Pay Stub (224) =====================
      ('00000000-0000-0000-0003-000000000224', 'What is Jordan''s gross pay for this pay period?',
        '["$1,449", "$1,559", "$2,200", "$2,310"]'::jsonb,
        '$2,200', 1, 'easy', 'multiple_choice', null),
      ('00000000-0000-0000-0003-000000000224', 'What is Jordan''s net pay for this pay period, after all deductions?',
        '["$1,449", "$1,559", "$1,890", "$2,200"]'::jsonb,
        '$1,449', 2, 'hard', 'multiple_choice', null),
      ('00000000-0000-0000-0003-000000000224', 'Which of Jordan''s deductions is voluntary, not required by law?',
        '["Federal income tax", "The 401(k) contribution", "Payroll taxes (Social Security + Medicare)", "State tax"]'::jsonb,
        'The 401(k) contribution', 3, 'medium', 'multiple_choice', null),
      ('00000000-0000-0000-0003-000000000224', 'Jordan was planning to budget based on the $2,200 gross figure. Explain what''s wrong with that plan and what Jordan should budget against instead.',
        '[]'::jsonb, '(graded via grading_keywords, not correct_answer)', 4, 'hard', 'free_response',
        '["net pay", "gross pay", "deductions", "budget", "less than", "actual"]'::jsonb),
      ('00000000-0000-0000-0003-000000000224', 'What does it mean that Jordan''s tax withholding is an "estimated prepayment" rather than a final bill?',
        '[]'::jsonb, '(graded via grading_keywords, not correct_answer)', 5, 'easy', 'free_response',
        '["estimate", "reconciled", "tax return", "refund", "owe", "final"]'::jsonb),

      -- ===================== Case Study: A Workplace Ethics Dilemma (225) =====================
      ('00000000-0000-0000-0003-000000000225', 'What is the core issue with the colleague''s expense report, as described?',
        '["It misrepresents a personal expense as a legitimate business expense", "It is for too small a dollar amount", "It was submitted using the wrong software", "There is no issue at all"]'::jsonb,
        'It misrepresents a personal expense as a legitimate business expense', 1, 'easy', 'multiple_choice', null),
      ('00000000-0000-0000-0003-000000000225', 'What is the friend''s tip about the acquisition, before any public announcement, an example of?',
        '["Material non-public information", "Public knowledge already available to everyone", "A rumor that is illegal for anyone to hear", "Fiduciary duty"]'::jsonb,
        'Material non-public information', 2, 'medium', 'multiple_choice', null),
      ('00000000-0000-0000-0003-000000000225', 'If you traded on the acquisition tip, or told someone else who traded on it, what would that be?',
        '["Insider trading, a serious securities law violation", "A normal, low-risk trading strategy", "Only a problem if you personally profit from it", "Legal, as long as it came from a close friend"]'::jsonb,
        'Insider trading, a serious securities law violation', 3, 'hard', 'multiple_choice', null),
      ('00000000-0000-0000-0003-000000000225', 'What should you actually do about the expense report irregularity you noticed, and why is staying silent risky?',
        '[]'::jsonb, '(graded via grading_keywords, not correct_answer)', 4, 'hard', 'free_response',
        '["report", "escalate", "compliance", "manager", "flag", "risk", "silence"]'::jsonb),
      ('00000000-0000-0000-0003-000000000225', 'What should you do with the acquisition tip you received, even though you didn''t ask for it?',
        '[]'::jsonb, '(graded via grading_keywords, not correct_answer)', 5, 'medium', 'free_response',
        '["do not trade", "not share", "report", "compliance", "exposure", "received"]'::jsonb),

      -- ===================== Case Study: Startup Equity vs. a Stable Corporate Offer (226) =====================
      ('00000000-0000-0000-0003-000000000226', 'What is the base salary difference between the two offers?',
        '["$14,000, in favor of the established corporation", "$14,000, in favor of the startup", "There is no difference", "$58,000"]'::jsonb,
        '$14,000, in favor of the established corporation', 1, 'easy', 'multiple_choice', null),
      ('00000000-0000-0000-0003-000000000226', 'If Amara contributes 6% of her $72,000 salary at the established corporation (50%-match-up-to-6%), how much does the employer add via the match?',
        '["$2,160", "$4,320", "$1,080", "$6,480"]'::jsonb,
        '$2,160', 2, 'hard', 'multiple_choice', null),
      ('00000000-0000-0000-0003-000000000226', 'Given the startup has 18 months of cash remaining and Amara''s options have a 1-year cliff, what is a realistic risk to weigh?',
        '["The company could run out of funding or fail before her options meaningfully vest or gain value", "The options are guaranteed to be worth millions", "There is no real risk since funding rounds guarantee success", "Her salary at the startup would automatically increase every quarter"]'::jsonb,
        'The company could run out of funding or fail before her options meaningfully vest or gain value', 3, 'medium', 'multiple_choice', null),
      ('00000000-0000-0000-0003-000000000226', 'Name at least two guaranteed, cash-equivalent benefits Amara would be giving up by choosing the startup offer over the corporate offer.',
        '[]'::jsonb, '(graded via grading_keywords, not correct_answer)', 4, 'medium', 'free_response',
        '["401(k) match", "retirement match", "health insurance", "deductible", "salary", "guaranteed"]'::jsonb),
      ('00000000-0000-0000-0003-000000000226', 'How should Amara weigh the startup''s speculative equity upside against the corporation''s guaranteed compensation, based on how most startup equity tends to turn out?',
        '[]'::jsonb, '(graded via grading_keywords, not correct_answer)', 5, 'hard', 'free_response',
        '["most startups fail", "speculative", "upside", "guaranteed", "cash", "little or nothing", "risk"]'::jsonb)
    ) as v(quiz_id, question, options, correct_answer, order_index, difficulty, question_type, keywords);
  end if;
end $$;

-- ===================== 4. First-mock-interview badge =====================
-- Reuses the live generic badges/award_badge(profile_id, criteria_type)
-- design (from College's 046) rather than reintroducing 043's
-- incompatible award_badge(profile_id, slug) signature. `criteria_type` is
-- a closed 4-value enum (badges_criteria_type_check) plus a unique
-- constraint -- extended here to admit a 5th value rather than reusing an
-- existing one, since "first mock interview" is a distinct milestone from
-- the other four.

do $$
begin
  if not exists (
    select 1 from pg_constraint
    where conname = 'badges_criteria_type_check'
      and conrelid = 'badges'::regclass
      and pg_get_constraintdef(oid) like '%first_mock_interview%'
  ) then
    alter table badges drop constraint badges_criteria_type_check;
    alter table badges add constraint badges_criteria_type_check check (
      criteria_type = any (array[
        'first_lesson_completed', 'first_quiz_passed', 'first_modeling_exercise_passed',
        'tier_completed', 'first_mock_interview'
      ])
    );
  end if;
end $$;

insert into badges (slug, title, description, criteria_type)
values ('first-mock-interview', 'First Rehearsal', 'Completed your first AI mock interview.', 'first_mock_interview')
on conflict (slug) do nothing;

-- ===================== 5. interview_questions.improvement_guide backfill =====================
-- Copied forward verbatim from 00000000000046 (all 115 per-question
-- UPDATEs, its safety-net check, and its final not-null/check-length
-- constraints). Only the leading ADD COLUMN is changed to IF NOT EXISTS,
-- since College's own 046 already added `difficulty` with the same
-- default/check constraint.

alter table interview_questions
  add column if not exists difficulty text not null default 'medium' check (difficulty in ('easy', 'medium', 'hard')),
  add column if not exists improvement_guide text;

-- ===================== 00000000000019 (9 questions) =====================

update interview_questions set difficulty = 'easy', improvement_guide =
  'Treat this as a highlight reel, not a full recitation -- pick 3-4 experiences that build toward why you want this specific role, spending most time on the most relevant ones, and end by connecting your background to this job. Common pitfall: reciting every resume line verbatim with no narrative thread, which makes the interviewer scan the page instead of listening to you.'
  where firm_style = 'JPMorgan Chase' and question_text = 'Walk me through your resume.';

update interview_questions set difficulty = 'medium', improvement_guide =
  'A strong answer names a specific, personal reason for the industry (not just prestige or pay) and layers on genuine, researched reasons for this specific firm -- a person you spoke with, a deal or practice area, the culture. Common pitfall: an answer generic enough to copy-paste into any bank''s interview, which signals you haven''t done real research.'
  where firm_style = 'JPMorgan Chase' and question_text = 'Why investment banking, and why JPMorgan specifically?';

update interview_questions set difficulty = 'medium', improvement_guide =
  'Name all three statements and explain the linkages precisely: net income flows into retained earnings on the balance sheet and is the starting line of the cash flow statement, and ending cash from the cash flow statement becomes the balance sheet''s cash line. Common pitfall: naming the three statements but failing to explain how a change actually flows between them, which is usually the real point of the question.'
  where firm_style = 'JPMorgan Chase' and question_text = 'Walk me through the three financial statements and how they link together.';

update interview_questions set difficulty = 'medium', improvement_guide =
  'Use STAR and be explicit about what information was actually missing and how you handled that gap -- a reasonable assumption, a clarifying question, prioritizing what mattered most -- rather than skipping straight to the result. Common pitfall: focusing only on the time pressure and never addressing the "limited information" half of the question.'
  where firm_style = 'Goldman Sachs' and question_text = 'Tell me about a time you worked under a tight deadline with limited information.';

update interview_questions set difficulty = 'medium', improvement_guide =
  'Answer both halves distinctly: name 1-2 concrete qualities you value in a team (not a vague "good communication"), then walk through a real example of resolving a disagreement productively. Common pitfall: answering only the first half of a two-part question and forgetting to address disagreement at all.'
  where firm_style = 'Goldman Sachs' and question_text = 'What do you look for in a team, and how do you handle disagreement within one?';

update interview_questions set difficulty = 'hard', improvement_guide =
  'Cover the full mechanics in order: project free cash flows, discount them to present value using a discount rate (WACC), sum the discounted cash flows plus a discounted terminal value, and explain the result estimates intrinsic value from the company''s own projected cash generation, independent of market sentiment. Common pitfall: naming "discounted cash flow" without explaining why cash flows are discounted (time value of money) or what the terminal value represents.'
  where firm_style = 'Goldman Sachs' and question_text = 'Walk me through a DCF and what it tells you about a company''s valuation.';

update interview_questions set difficulty = 'medium', improvement_guide =
  'Focus on the reasoning you used to persuade them, not just that you eventually succeeded -- what evidence or framing changed their mind, and how you stayed respectful of their original position. Common pitfall: describing the disagreement in detail while glossing over the actual persuasion technique, leaving no evidence of your influencing skill.'
  where firm_style = 'Morgan Stanley' and question_text = 'Describe a time you had to persuade someone who disagreed with you.';

update interview_questions set difficulty = 'medium', improvement_guide =
  'Name something specific to Morgan Stanley -- a group, a recent deal, a value, a conversation with someone there -- rather than reasons that would apply to any bank equally. Common pitfall: an answer built entirely around prestige or compensation, which reads as interchangeable with any competitor.'
  where firm_style = 'Morgan Stanley' and question_text = 'Why do you want to work at Morgan Stanley over other banks?';

update interview_questions set difficulty = 'hard', improvement_guide =
  'Trace the full mechanic: net income falls by $10 x (1 - tax rate) since depreciation is tax-deductible, but depreciation itself is non-cash, so it is added back on the cash flow statement -- meaning cash flow from operations actually rises overall (by the tax-shield amount) even though net income fell. Common pitfall: stopping at "net income falls" without completing the add-back step, which is the actual point of the question.'
  where firm_style = 'Morgan Stanley' and question_text = 'What happens to a company''s cash flow statement if depreciation increases by $10?';

-- ===================== General Behavioral (15) =====================

update interview_questions set difficulty = 'easy', improvement_guide =
  'This is an elevator-pitch question, not an invitation for a full biography -- structure it as present (what you do now), past (relevant experience that led here), future (why this role specifically), in under two minutes. Common pitfall: starting from childhood or unrelated personal details instead of building toward why you''re a fit for this role.'
  where firm_style = 'General Behavioral' and question_text = 'Tell me about yourself.';

update interview_questions set difficulty = 'easy', improvement_guide =
  'Name one or two strengths and immediately back each with a specific example of it in action, not just an adjective. Common pitfall: naming a generic strength like "hard worker" with no concrete evidence, which is forgettable and unverifiable.'
  where firm_style = 'General Behavioral' and question_text = 'What are your greatest strengths, and how have they shown up in your work?';

update interview_questions set difficulty = 'medium', improvement_guide =
  'Name a real, specific weakness (not a disguised strength like "I work too hard") and describe a concrete action you''ve taken to address it, with evidence of progress. Common pitfall: picking a fake weakness that''s actually a strength in disguise, which reads as evasive rather than self-aware.'
  where firm_style = 'General Behavioral' and question_text = 'What is a weakness you''re actively working to improve, and what have you done about it?';

update interview_questions set difficulty = 'medium', improvement_guide =
  'Use STAR, being specific about exactly what you had to learn and the concrete steps you took to get up to speed quickly, not just "I studied hard." Common pitfall: emphasizing the time pressure and stress without showing the actual learning process or method used.'
  where firm_style = 'General Behavioral' and question_text = 'Tell me about a time you had to learn something completely new under time pressure.';

update interview_questions set difficulty = 'medium', improvement_guide =
  'Describe the specific feedback, your honest initial reaction, and then the concrete change you made afterward -- this question tests whether you actually adjust, not just whether you can take criticism gracefully. Common pitfall: saying feedback was "appreciated" with no description of what actually changed in your behavior as a result.'
  where firm_style = 'General Behavioral' and question_text = 'Describe a time you received critical feedback. How did you respond?';

update interview_questions set difficulty = 'easy', improvement_guide =
  'Pick a goal with a clear, ideally measurable outcome, and walk through the specific steps and any obstacles you overcame, not just the end result. Common pitfall: describing the goal and outcome but skipping the actual process, leaving no evidence of how you achieve things.'
  where firm_style = 'General Behavioral' and question_text = 'Tell me about a goal you set for yourself and how you achieved it.';

update interview_questions set difficulty = 'medium', improvement_guide =
  'Explain the specific criteria you used to decide what came first -- impact, urgency, dependencies -- rather than just saying you "stayed organized." Common pitfall: describing the stress of multiple deadlines without explaining the actual decision-making process used to prioritize them.'
  where firm_style = 'General Behavioral' and question_text = 'Describe a time you had to prioritize among multiple competing deadlines.';

update interview_questions set difficulty = 'medium', improvement_guide =
  'Own the mistake directly and specifically, then spend most of your answer on the concrete correction and what you changed afterward to prevent it recurring. Common pitfall: deflecting blame onto circumstances or other people rather than taking ownership of your own error.'
  where firm_style = 'General Behavioral' and question_text = 'Tell me about a time you made a mistake at work or school. What did you do next?';

update interview_questions set difficulty = 'easy', improvement_guide =
  'Name something specific and genuine that motivates you, then explicitly connect it to a real aspect of this role rather than restating the job description back. Common pitfall: a generic answer like "I''m motivated by success" that never actually connects to why this specific role fits that motivation.'
  where firm_style = 'General Behavioral' and question_text = 'What motivates you, and how does this role fit into that?';

update interview_questions set difficulty = 'easy', improvement_guide =
  'Show realistic ambition connected to growth within this field or firm, without over-committing to a specific title or over-promising loyalty you can''t guarantee. Common pitfall: an answer disconnected from this role or industry entirely, which raises doubts about genuine interest in the path.'
  where firm_style = 'General Behavioral' and question_text = 'Where do you see yourself in five years?';

update interview_questions set difficulty = 'medium', improvement_guide =
  'Focus on the specific adjustment you made to work well with that person -- communication style, meeting cadence, division of tasks -- not just that the difference existed. Common pitfall: describing the personality clash in detail while glossing over what you personally did to adapt and make the collaboration work.'
  where firm_style = 'General Behavioral' and question_text = 'Tell me about a time you had to work with someone whose working style was very different from yours.';

update interview_questions set difficulty = 'medium', improvement_guide =
  'Pick a specific instance where you did something beyond your formal responsibility, and be clear about the tangible impact it had. Common pitfall: describing normal, expected effort as if it were exceptional, which undersells what "above and beyond" should actually mean.'
  where firm_style = 'General Behavioral' and question_text = 'Describe a situation where you went above and beyond what was expected of you.';

update interview_questions set difficulty = 'medium', improvement_guide =
  'Explain the reasoning behind the no clearly and how you communicated it respectfully, ideally including any alternative you offered. Common pitfall: an answer that sounds like simple refusal with no diplomatic framing or explanation, which can read as inflexible.'
  where firm_style = 'General Behavioral' and question_text = 'Tell me about a time you had to say no to a request. How did you handle it?';

update interview_questions set difficulty = 'hard', improvement_guide =
  'Walk through the actual trade-offs you weighed, not just the final choice -- the interviewer wants to see your reasoning process under genuine uncertainty. Common pitfall: describing a decision that wasn''t actually difficult or high-stakes, which undermines the premise of the question.'
  where firm_style = 'General Behavioral' and question_text = 'What is the most difficult decision you''ve had to make recently, and how did you approach it?';

update interview_questions set difficulty = 'hard', improvement_guide =
  'Describe specifically how you framed the request or concern to the senior person -- with clear reasoning and respect for their time and authority -- and what the outcome was. Common pitfall: describing frustration with not getting support, without showing the specific, professional approach you took to actually get it.'
  where firm_style = 'General Behavioral' and question_text = 'Tell me about a time you had to manage up -- get support or a decision from someone more senior than you.';

-- ===================== General Situational (8) =====================

update interview_questions set difficulty = 'medium', improvement_guide =
  'Show you''d address the misunderstanding immediately and directly -- flagging it to whoever owns the requirement -- rather than either quietly redoing the work alone or continuing on the wrong path to avoid an awkward conversation. Common pitfall: focusing only on how you''d fix the output without mentioning that you''d proactively surface the misunderstanding first.'
  where firm_style = 'General Situational' and question_text = 'You realize partway through a project that you misunderstood a key requirement. What do you do?';

update interview_questions set difficulty = 'medium', improvement_guide =
  'Describe a specific, direct but respectful conversation with the teammate first, before escalating -- and be clear about what you''d actually say. Common pitfall: jumping straight to "I''d tell my manager" without first attempting to resolve it directly with the teammate.'
  where firm_style = 'General Situational' and question_text = 'A teammate is consistently missing deadlines and it''s affecting your work. How do you handle it?';

update interview_questions set difficulty = 'medium', improvement_guide =
  'Show you''d raise the concern proactively and specifically -- which parts are unrealistic and why -- rather than either silently accepting an impossible deadline or refusing outright. Common pitfall: an answer that either complains without proposing anything, or simply agrees without flagging the real risk.'
  where firm_style = 'General Situational' and question_text = 'Your manager gives you a task with an unrealistic deadline. What do you do?';

update interview_questions set difficulty = 'medium', improvement_guide =
  'Describe raising it privately and promptly with the colleague (or the right owner) before it reaches the client, framed as catching an error together rather than an accusation. Common pitfall: describing silently fixing it yourself without telling anyone, which hides a process problem that could recur.'
  where firm_style = 'General Situational' and question_text = 'You notice a colleague appears to have made an error in a client-facing document. What do you do?';

update interview_questions set difficulty = 'hard', improvement_guide =
  'Show you''d raise the disagreement directly and constructively with the decision-maker, ideally with a specific reason or new information, while still being willing to fully execute the team''s decision if it stands. Common pitfall: describing quietly undermining or slow-walking a decision you disagree with instead of raising the concern openly.'
  where firm_style = 'General Situational' and question_text = 'You disagree with a decision your team has already made and started implementing. How do you handle it?';

update interview_questions set difficulty = 'medium', improvement_guide =
  'Describe quickly clarifying true urgency and dependencies with both people rather than guessing, and being transparent with both about the conflict rather than silently choosing one. Common pitfall: picking one task arbitrarily without communicating the conflict to either senior person.'
  where firm_style = 'General Situational' and question_text = 'You are given two urgent tasks by two different senior people at the same time. What do you do?';

update interview_questions set difficulty = 'hard', improvement_guide =
  'Name that you''d pause, ask clarifying questions about the reasoning, and escalate to a manager or compliance rather than either complying silently or refusing dramatically on the spot. Common pitfall: an answer that skips escalation entirely, either from over-compliance or from unilaterally refusing without raising it properly.'
  where firm_style = 'General Situational' and question_text = 'You''re asked to do something you believe is ethically questionable, but not clearly against any written policy. What do you do?';

update interview_questions set difficulty = 'medium', improvement_guide =
  'Show that you''d listen fully to the specific concern before responding, acknowledge what''s valid, and propose a concrete next step or revision, rather than getting defensive. Common pitfall: an answer focused on explaining or justifying the original work instead of first genuinely hearing out the stakeholder''s concern.'
  where firm_style = 'General Situational' and question_text = 'A client or stakeholder is unhappy with a deliverable you produced. How do you handle the conversation?';

-- ===================== JPMorgan Chase (6, from 00000000000035) =====================

update interview_questions set difficulty = 'medium', improvement_guide =
  'Pick a specific instance, describe the simplifying analogy or framing you used, and ideally reference how you confirmed the person actually understood. Common pitfall: describing the technical content in as much jargon as you''d use with a technical audience, which misses what the question is testing.'
  where firm_style = 'JPMorgan Chase' and question_text = 'Describe a time you had to explain something technical to someone without a technical background.';

update interview_questions set difficulty = 'easy', improvement_guide =
  'Show genuine, current engagement with the industry -- name a specific story or trend and explain why it matters to this business or role, not just that you "read the news." Common pitfall: a vague or outdated reference that suggests you didn''t prepare anything specific for this question.'
  where firm_style = 'JPMorgan Chase' and question_text = 'What recent market or industry news has caught your attention, and why?';

update interview_questions set difficulty = 'hard', improvement_guide =
  'Move away from P/E-style multiples (which break down with negative earnings) toward revenue multiples, EBITDA multiples if EBITDA is positive, or a DCF based on projected future cash flows/earnings rather than current ones. Common pitfall: defaulting to a standard P/E multiple without acknowledging why it doesn''t work when earnings are negative.'
  where firm_style = 'JPMorgan Chase' and question_text = 'How would you value a company with negative earnings?';

update interview_questions set difficulty = 'medium', improvement_guide =
  'Define both precisely: equity value is what shareholders own (market cap); enterprise value adds debt and subtracts cash, representing the whole operating business regardless of capital structure. Use enterprise value to compare companies with different debt levels, and equity value for questions specifically about shareholder returns. Common pitfall: defining one correctly but not naming a concrete situation where you''d use each.'
  where firm_style = 'JPMorgan Chase' and question_text = 'What is the difference between enterprise value and equity value, and when would you use each?';

update interview_questions set difficulty = 'hard', improvement_guide =
  'Walk through the mechanic precisely: enterprise value itself doesn''t change (EV = equity value + debt - cash is unaffected by shifting value between debt and equity), but the split changes -- debt rises, cash falls (used to buy back stock), and equity value falls by the amount repurchased. Common pitfall: assuming issuing debt changes enterprise value itself, rather than just its composition.'
  where firm_style = 'JPMorgan Chase' and question_text = 'Walk me through what happens to enterprise value if a company issues new debt to buy back stock.';

update interview_questions set difficulty = 'medium', improvement_guide =
  'Define WACC as the blended cost of a company''s debt and equity financing, weighted by their proportions, and explain it''s used as the discount rate in a DCF because it represents the return investors require given the company''s specific capital mix -- the appropriate "hurdle rate" for its projected cash flows. Common pitfall: naming the formula without explaining why that rate is the appropriate one to discount cash flows by.'
  where firm_style = 'JPMorgan Chase' and question_text = 'What is WACC, and why is it used as a discount rate?';

-- ===================== Goldman Sachs (6, from 00000000000035) =====================

update interview_questions set difficulty = 'medium', improvement_guide =
  'Focus on the specific action that built credibility quickly -- delivering on a small commitment first, being transparent about constraints, asking good questions -- rather than a vague claim of "good people skills." Common pitfall: describing the relationship''s importance without naming any specific trust-building action you actually took.'
  where firm_style = 'Goldman Sachs' and question_text = 'Tell me about a time you had to build trust with someone quickly.';

update interview_questions set difficulty = 'medium', improvement_guide =
  'Describe a concrete instance where you identified a need nobody assigned to you and acted on it, with a clear outcome. Common pitfall: describing something that was actually assigned or expected, which undercuts the "without being asked" premise of the question.'
  where firm_style = 'Goldman Sachs' and question_text = 'Describe a time you took initiative without being asked.';

update interview_questions set difficulty = 'hard', improvement_guide =
  'Name one or two specific, differentiated strengths or experiences -- not generic traits every candidate would claim -- and connect them concretely to what this specific role needs. Common pitfall: an answer built on generic positive adjectives with nothing distinctive or role-specific.'
  where firm_style = 'Goldman Sachs' and question_text = 'Why should we hire you over another candidate with a similar background?';

update interview_questions set difficulty = 'hard', improvement_guide =
  'Build a case around alternatives to public comps: precedent private transactions if available, a DCF grounded in the company''s own projected cash flows, and possibly a build-up from the closest available public proxies with explicit adjustments for size/liquidity differences. Common pitfall: saying "you can''t value it without comparables," which avoids answering rather than reasoning through the alternatives.'
  where firm_style = 'Goldman Sachs' and question_text = 'Walk me through how you would value a private company with no public comparables.';

update interview_questions set difficulty = 'medium', improvement_guide =
  'Trading comps are faster and market-grounded but only as good as the comparable set and current sentiment; a DCF is more independent of market mood but highly sensitive to long-term assumptions -- name when each weakness matters most (comps in a volatile or comp-poor market, DCF for a company with few good peers). Common pitfall: describing only one method''s strengths without addressing when the other approach is actually preferable.'
  where firm_style = 'Goldman Sachs' and question_text = 'What factors would make you choose a trading comparables approach over a DCF, or vice versa?';

update interview_questions set difficulty = 'medium', improvement_guide =
  'Explain the mechanism: higher rates raise the discount rate used to value future cash flows/earnings, which lowers the present value of those future cash flows -- so equity valuations generally fall, all else equal, when rates rise. Common pitfall: stating the directional relationship (rates up, valuations down) without explaining the discounting mechanism that causes it.'
  where firm_style = 'Goldman Sachs' and question_text = 'How does an increase in interest rates generally affect equity valuations?';

-- ===================== Morgan Stanley (6, from 00000000000035) =====================

update interview_questions set difficulty = 'medium', improvement_guide =
  'Show you''d recognize the error early (what tipped you off) and pivoted concretely, rather than persisting with a flawed approach out of sunk cost. Common pitfall: spending the whole answer on why the initial approach seemed reasonable, with little detail on the actual pivot and its outcome.'
  where firm_style = 'Morgan Stanley' and question_text = 'Tell me about a time your initial approach to a problem turned out to be wrong. What did you do?';

update interview_questions set difficulty = 'medium', improvement_guide =
  'Describe the specific, respectful way you framed the feedback -- a concrete example, focused on behavior not character -- and how the person responded. Common pitfall: describing that feedback was "necessary" without detailing how you actually delivered it constructively.'
  where firm_style = 'Morgan Stanley' and question_text = 'Describe a time you had to give someone difficult feedback.';

update interview_questions set difficulty = 'easy', improvement_guide =
  'Name a concrete system -- a prioritization framework, a specific tool, a weekly review habit -- rather than a vague claim of being "naturally organized." Common pitfall: a generic answer with no specific method, which gives the interviewer nothing to evaluate.'
  where firm_style = 'Morgan Stanley' and question_text = 'How do you stay organized when managing several projects with different priorities?';

update interview_questions set difficulty = 'hard', improvement_guide =
  'Walk through the mechanic precisely: inventory rises by $10 on the balance sheet, funded by a $10 cash decrease (if paid cash) or a $10 accounts-payable increase (if on credit); the income statement is unaffected until the inventory is sold (then it becomes cost of goods sold); the cash flow statement shows a $10 operating use of cash (or no effect if bought on credit). Common pitfall: assuming the income statement changes immediately, when inventory purchases don''t hit it until the goods are actually sold.'
  where firm_style = 'Morgan Stanley' and question_text = 'Walk me through the impact of a $10 increase in inventory on the three financial statements.';

update interview_questions set difficulty = 'medium', improvement_guide =
  'Book value is the accounting value of equity on the balance sheet (assets minus liabilities, at historical/depreciated cost); market value is what investors are actually willing to pay today, reflecting expectations book value doesn''t capture. Common pitfall: describing one without contrasting it against the other, or treating them as if they should always be similar.'
  where firm_style = 'Morgan Stanley' and question_text = 'What is the difference between a company''s book value and its market value?';

update interview_questions set difficulty = 'medium', improvement_guide =
  'Name concrete sources of divergence: different assumptions (growth rates, discount rates, terminal value), different methodologies (DCF vs. comps vs. precedent transactions), or different judgment on qualitative factors (management quality, competitive risk). Common pitfall: saying valuation is "subjective" without naming any specific driver of the disagreement.'
  where firm_style = 'Morgan Stanley' and question_text = 'Why might two analysts arrive at very different valuations for the exact same company?';

-- ===================== BlackRock (6) =====================

update interview_questions set difficulty = 'medium', improvement_guide =
  'Show your process for deciding despite the gap -- what you did know, what reasonable assumption you made, how you''d have adjusted if new information arrived. Common pitfall: implying you had full information when you didn''t, instead of directly addressing how you handled the actual gap.'
  where firm_style = 'BlackRock' and question_text = 'Tell me about a time you had to make a decision with incomplete information.';

update interview_questions set difficulty = 'medium', improvement_guide =
  'Be specific about what the new evidence was and exactly how it changed your view -- this question rewards intellectual honesty, not consistency for its own sake. Common pitfall: describing a minor preference change rather than a genuine, substantive change of mind, which undersells the point of the question.'
  where firm_style = 'BlackRock' and question_text = 'Describe a time you changed your mind about something after new evidence came in.';

update interview_questions set difficulty = 'easy', improvement_guide =
  'Define diversification as spreading investments across assets that don''t all move together, and explain the mechanism: losses in some holdings are offset by gains or stability in others, so overall portfolio volatility falls even if individual holdings are still risky. Common pitfall: saying diversification "reduces risk" without explaining the actual mechanism -- imperfect correlation between holdings.'
  where firm_style = 'BlackRock' and question_text = 'What is diversification, and why does it reduce risk in a portfolio?';

update interview_questions set difficulty = 'medium', improvement_guide =
  'Systematic risk affects the whole market (a recession, rate changes) and can''t be diversified away; idiosyncratic risk is specific to one company (a product recall) and can be reduced by holding a diversified portfolio. Common pitfall: naming the two terms without being able to say which one diversification actually addresses -- idiosyncratic, not systematic.'
  where firm_style = 'BlackRock' and question_text = 'What is the difference between systematic and idiosyncratic (company-specific) risk?';

update interview_questions set difficulty = 'medium', improvement_guide =
  'Use a plain-language mechanism: a bond pays a fixed rate, so when new bonds are issued at higher prevailing rates, existing lower-rate bonds become less attractive and must sell at a discount to compete -- so bond prices fall when rates rise, and rise when rates fall. Common pitfall: stating the inverse relationship as a fact to memorize without giving the requested plain-language explanation of why it happens.'
  where firm_style = 'BlackRock' and question_text = 'How would you explain the relationship between bond prices and interest rates to someone with no finance background?';

update interview_questions set difficulty = 'medium', improvement_guide =
  'Define the Sharpe ratio as risk-adjusted return: excess return (over a risk-free rate) divided by the investment''s volatility (standard deviation), so a higher Sharpe ratio means more return per unit of risk taken. Common pitfall: describing it as just "a return measure" without mentioning that it specifically adjusts for risk taken, which is the entire point of the metric.'
  where firm_style = 'BlackRock' and question_text = 'What is a Sharpe ratio, and what does it measure?';

-- ===================== McKinsey & Company (6) =====================

update interview_questions set difficulty = 'medium', improvement_guide =
  'Describe the specific approach you used to build buy-in -- data, framing the shared benefit, finding an ally -- rather than relying on your role or title. Common pitfall: describing a situation where you actually did have some authority, which misses the point of the question.'
  where firm_style = 'McKinsey & Company' and question_text = 'Tell me about a time you had to influence someone without having formal authority over them.';

update interview_questions set difficulty = 'medium', improvement_guide =
  'Explain the specific criteria used to split work -- skills, availability, task dependencies -- and how you tracked progress against the deadline, not just that the team "worked hard." Common pitfall: describing the deadline pressure vividly while skipping the actual division-of-labor logic, which is what''s being tested.'
  where firm_style = 'McKinsey & Company' and question_text = 'Describe a time you worked on a team with a very tight deadline. How did you divide the work?';

update interview_questions set difficulty = 'hard', improvement_guide =
  'Since revenue is stable but profit fell, the issue must be on the cost or margin side -- structure the investigation around cost categories (COGS, labor, rent, marketing) and margin per unit/store, checking for a specific driver like rising input costs or new-store underperformance rather than jumping to a conclusion. Common pitfall: guessing a single cause immediately instead of laying out a structured framework of possible cost/margin drivers first.'
  where firm_style = 'McKinsey & Company' and question_text = 'A retail client''s profits have declined for two straight years despite stable revenue. How would you investigate why?';

update interview_questions set difficulty = 'medium', improvement_guide =
  'Cover market attractiveness (size, growth, competition), the client''s right to win (existing capabilities, brand fit), entry-mode options (build, acquire, partner) and their trade-offs, and regulatory/cultural factors specific to that market. Common pitfall: listing only market size and growth while ignoring the client''s actual fit and realistic entry-mode options.'
  where firm_style = 'McKinsey & Company' and question_text = 'A client wants to know whether they should enter a new international market. What factors would you consider?';

update interview_questions set difficulty = 'medium', improvement_guide =
  'Use a structured build-up: estimate the number of relevant stores in the city, average daily customers per store, average ticket size, and operating days per year, stating each assumption explicitly before multiplying through. Common pitfall: guessing a round final number without showing the structured build-up the question is actually testing.'
  where firm_style = 'McKinsey & Company' and question_text = 'Estimate the annual revenue of a mid-sized coffee shop chain in a major city.';

update interview_questions set difficulty = 'hard', improvement_guide =
  'Frame it as a cost/capacity trade-off: estimate the capital cost and lead time of each option, the capacity gain each provides, and the risk profile (new factory adds capacity but more risk/lead time; expansion is faster and lower-risk but capped) before landing on assumptions that would tip the decision. Common pitfall: picking one option immediately without laying out the comparative cost/capacity/risk framework first.'
  where firm_style = 'McKinsey & Company' and question_text = 'A manufacturer is considering whether to build a new factory or expand an existing one. How would you structure that decision?';

-- ===================== Boston Consulting Group (5) =====================

update interview_questions set difficulty = 'hard', improvement_guide =
  'Describe specifically what evidence or reframing changed the group''s mind mid-project, and how you managed the disruption of changing course partway through, not just that you were eventually right. Common pitfall: focusing on being right in hindsight rather than the actual process of persuading a group already committed to a different path.'
  where firm_style = 'Boston Consulting Group' and question_text = 'Tell me about a time you had to persuade a group to change its approach mid-project.';

update interview_questions set difficulty = 'medium', improvement_guide =
  'Name the specific data sources, method, and how the analysis directly led to a decision or recommendation someone acted on -- complexity should be shown through the reasoning, not data volume. Common pitfall: describing a large dataset without explaining the actual analytical method or how it changed a real decision.'
  where firm_style = 'Boston Consulting Group' and question_text = 'Describe the most complex analysis you''ve done to reach a decision or recommendation.';

update interview_questions set difficulty = 'medium', improvement_guide =
  'Structure hypotheses around competitors (a rival out-innovating, undercutting on price, or out-marketing you) and the company''s own execution (product gaps, distribution issues, customer service problems) before picking one to investigate. Common pitfall: naming only one possible cause instead of laying out a structured set of competitor-side and company-side hypotheses first.'
  where firm_style = 'Boston Consulting Group' and question_text = 'A company''s market share is shrinking even as the overall market grows. What could explain this?';

update interview_questions set difficulty = 'medium', improvement_guide =
  'Build up from a clear population base: estimate the relevant city/region population, the share who''d realistically use a bike subscription, and an average annual subscription price, stating each assumption before multiplying through. Common pitfall: guessing a large round number without showing the population-based build-up the question is testing.'
  where firm_style = 'Boston Consulting Group' and question_text = 'How would you estimate the total addressable market for a new electric bike subscription service?';

update interview_questions set difficulty = 'hard', improvement_guide =
  'Weigh cost and speed to market (acquisition is faster but expensive and carries integration risk; building in-house is slower but avoids overpaying and integration issues), and each option''s effect on competitive dynamics. Common pitfall: focusing only on price/cost while ignoring integration risk and competitive-dynamics considerations.'
  where firm_style = 'Boston Consulting Group' and question_text = 'A client is deciding whether to acquire a competitor or build a competing product in-house. What would you weigh?';

-- ===================== Bain & Company (4) =====================

update interview_questions set difficulty = 'medium', improvement_guide =
  'Focus on the specific trade-off decisions you made under the resource constraint -- what you cut, reprioritized, or did differently -- rather than just describing the shortage itself. Common pitfall: dwelling on how limited the resources were without explaining the concrete adjustments that let you still deliver.'
  where firm_style = 'Bain & Company' and question_text = 'Tell me about a time you had to deliver results with fewer resources than you thought you needed.';

update interview_questions set difficulty = 'medium', improvement_guide =
  'Describe the specific method you used to filter and structure a large amount of information quickly -- a framework, prioritizing by relevance, grouping into themes -- and how that led directly to your recommendation. Common pitfall: describing the volume of information without explaining the actual synthesis method used to cut through it.'
  where firm_style = 'Bain & Company' and question_text = 'Describe a time you had to synthesize a large amount of information quickly to make a recommendation.';

update interview_questions set difficulty = 'medium', improvement_guide =
  'Since revenue is stable but churn is rising (masked by roughly offsetting new signups), structure hypotheses around product/service issues, pricing or a competitor''s new offer, and onboarding/engagement problems -- then describe narrowing down using cohort or survey data. Common pitfall: jumping to a single explanation (usually "price") without laying out multiple hypotheses to test first.'
  where firm_style = 'Bain & Company' and question_text = 'A subscription business has stable revenue but rising customer churn. How would you diagnose the cause?';

update interview_questions set difficulty = 'easy', improvement_guide =
  'Build up from population: estimate the share of the 2,000,000 population with an active gym membership (a stated percentage assumption), multiply through, and sanity-check the result against a plausible per-capita gym membership rate. Common pitfall: giving a number with no visible build-up or stated assumption behind it.'
  where firm_style = 'Bain & Company' and question_text = 'Estimate how many gym memberships are active in a city of two million people.';

-- ===================== Investment Banking Analyst (7) =====================

update interview_questions set difficulty = 'medium', improvement_guide =
  'Name all three statements and trace one concrete example through all of them -- e.g. a revenue increase raises net income, which raises retained earnings on the balance sheet and is the starting point of the cash flow statement. Common pitfall: naming the three statements correctly but failing to actually trace a change through all of them when asked.'
  where firm_style = 'Investment Banking Analyst' and question_text = 'Walk me through the three financial statements and how a change in one flows through the others.';

update interview_questions set difficulty = 'easy', improvement_guide =
  'A merger combines two companies of relatively similar size into a new combined entity; an acquisition is one company purchasing and absorbing another, which typically ceases to exist independently. Common pitfall: using the terms interchangeably without naming the actual distinction -- relative size/structure of the resulting entity.'
  where firm_style = 'Investment Banking Analyst' and question_text = 'What is the difference between a merger and an acquisition?';

update interview_questions set difficulty = 'medium', improvement_guide =
  'Debt doesn''t dilute existing shareholders'' ownership, interest payments are tax-deductible (a "tax shield"), and debt is typically cheaper than equity since lenders take less risk than shareholders -- but it must be repaid regardless of performance, unlike equity. Common pitfall: naming only "debt is cheaper" without mentioning tax deductibility or the dilution trade-off.'
  where firm_style = 'Investment Banking Analyst' and question_text = 'Why would a company choose to raise capital through debt instead of issuing new equity?';

update interview_questions set difficulty = 'hard', improvement_guide =
  'An LBO is buying a company primarily with borrowed money, using the target''s own future cash flows to pay down that debt over time -- returns are amplified because the buyer put in relatively little of their own equity, so a modest overall gain in company value produces a much larger percentage return on that smaller equity investment. Common pitfall: describing "buying a company with debt" without explaining why leverage specifically amplifies equity returns.'
  where firm_style = 'Investment Banking Analyst' and question_text = 'What is an LBO, in simple terms, and why does debt matter so much to its returns?';

update interview_questions set difficulty = 'medium', improvement_guide =
  'Name a specific, repeatable checking method -- re-deriving key numbers a second way, checking a balance sheet still balances, having a colleague spot-check -- rather than a vague "I''m careful." Common pitfall: claiming to always catch every error without describing an actual verification method or process.'
  where firm_style = 'Investment Banking Analyst' and question_text = 'Tell me about a time you had to double-check your own work under a tight deadline. How did you catch errors?';

update interview_questions set difficulty = 'medium', improvement_guide =
  'Describe the specific steps you took to move fast without sacrificing accuracy -- triaging what mattered most, checking in on scope early, a final quality pass -- rather than just describing the long hours. Common pitfall: focusing on effort/hours worked rather than the actual process that produced a polished result under time pressure.'
  where firm_style = 'Investment Banking Analyst' and question_text = 'Describe a time you had to produce a polished deliverable overnight or on very short notice.';

update interview_questions set difficulty = 'medium', improvement_guide =
  'Name specific, genuine reasons tied to the actual work -- pace, deal exposure, analytical rigor, mentorship structure -- rather than generic reasons like prestige or pay that could apply to any high-paying job. Common pitfall: an answer indistinguishable from "why finance in general," which misses the "specifically" in the question.'
  where firm_style = 'Investment Banking Analyst' and question_text = 'Why investment banking specifically, rather than another area of finance?';

-- ===================== Quantitative Analyst (6) =====================

update interview_questions set difficulty = 'medium', improvement_guide =
  'Correlation means two variables move together; causation means one actually produces a change in the other -- confusing them in a model risks building a predictive relationship on a coincidental or confounded pattern that won''t hold up out of sample. Common pitfall: defining the terms correctly without explaining the actual modeling risk -- spurious relationships -- of conflating them.'
  where firm_style = 'Quantitative Analyst' and question_text = 'What is the difference between correlation and causation, and why does that distinction matter in modeling?';

update interview_questions set difficulty = 'easy', improvement_guide =
  'Standard deviation measures how spread out values are around the average; in a risk context, a higher standard deviation of returns means more volatility/uncertainty around the expected outcome, a common proxy for risk. Common pitfall: defining standard deviation mathematically without connecting it to what it actually implies about risk.'
  where firm_style = 'Quantitative Analyst' and question_text = 'Explain what standard deviation measures and why it matters for evaluating risk.';

update interview_questions set difficulty = 'hard', improvement_guide =
  'Resist over-interpreting a small sample: 8/10 heads is well within normal variation for a fair coin, so this single result alone provides very weak evidence of unfairness -- you''d want many more flips before drawing a real conclusion. Common pitfall: concluding the coin is likely unfair based on one small sample, which shows a misunderstanding of statistical variation.'
  where firm_style = 'Quantitative Analyst' and question_text = 'You flip a fair coin 10 times and get 8 heads. What does this tell you, if anything, about the coin''s fairness?';

update interview_questions set difficulty = 'medium', improvement_guide =
  'Overfitting is when a model fits the noise/idiosyncrasies of its training data too closely, so it performs well on data it''s already seen but poorly on new data; recognize it by strong training performance paired with much weaker validation/out-of-sample performance. Common pitfall: defining overfitting only as "too complex a model" without mentioning the actual diagnostic -- a training/validation performance gap.'
  where firm_style = 'Quantitative Analyst' and question_text = 'What is overfitting in a statistical model, and how would you recognize it?';

update interview_questions set difficulty = 'medium', improvement_guide =
  'Describe specifically how you noticed the discrepancy -- a sanity check, an unexpected result, cross-checking against another source -- and what the error turned out to be and its impact once corrected. Common pitfall: stating that you "found an error" without describing the specific method that led you to catch it.'
  where firm_style = 'Quantitative Analyst' and question_text = 'Tell me about a time you found an error in a model or dataset that others had missed.';

update interview_questions set difficulty = 'medium', improvement_guide =
  'Describe the specific simplification or analogy you used to convey the result''s practical implication, focused on what the result meant for a decision rather than the statistical method itself. Common pitfall: over-explaining the technical method to a non-technical audience instead of focusing on the practical implication of the result.'
  where firm_style = 'Quantitative Analyst' and question_text = 'Describe a project where you had to translate a mathematical or statistical result into a plain-language explanation for a non-technical audience.';

-- ===================== Risk Analyst (6) =====================

update interview_questions set difficulty = 'medium', improvement_guide =
  'Market risk is the risk of loss from broad market movements (rates, prices, currencies) affecting many holdings at once; credit risk is the risk that a specific borrower or counterparty fails to repay what they owe. Common pitfall: defining one but not clearly distinguishing it from the other.'
  where firm_style = 'Risk Analyst' and question_text = 'What is the difference between market risk and credit risk?';

update interview_questions set difficulty = 'medium', improvement_guide =
  'Value at risk estimates, at a given confidence level over a given time period, the maximum loss a portfolio is expected not to exceed under normal market conditions -- e.g. a 1-day 95% VaR of $1M means a 5% chance of losing more than $1M in a single day. Common pitfall: describing VaR as "the maximum possible loss" without the confidence-level and time-horizon caveats, a common and important misunderstanding of what VaR actually says.'
  where firm_style = 'Risk Analyst' and question_text = 'What does "value at risk" attempt to measure, in simple terms?';

update interview_questions set difficulty = 'medium', improvement_guide =
  'Hedging lets a firm keep the underlying business or exposure it wants (holding foreign revenue, extending credit to customers) while offsetting the specific risk that exposure carries, rather than giving up a valuable activity entirely just because it carries risk. Common pitfall: implying hedging and avoiding risk are interchangeable, missing that hedging preserves the underlying opportunity.'
  where firm_style = 'Risk Analyst' and question_text = 'Why might a firm choose to hedge a risk rather than simply avoid taking it on in the first place?';

update interview_questions set difficulty = 'medium', improvement_guide =
  'Describe the specific signal that tipped you off -- an assumption nobody had questioned, a stress scenario not yet considered -- and how you raised it and what happened as a result. Common pitfall: stating you found a risk others missed without describing the specific reasoning or check that surfaced it.'
  where firm_style = 'Risk Analyst' and question_text = 'Tell me about a time you identified a risk that others on your team had overlooked.';

update interview_questions set difficulty = 'hard', improvement_guide =
  'Explain the specific trade-off you weighed -- the potential benefit vs. the specific downside scenario and its likelihood/severity -- and how you communicated the "no" constructively, ideally with an alternative. Common pitfall: describing the refusal without explaining the actual risk/benefit reasoning behind it.'
  where firm_style = 'Risk Analyst' and question_text = 'Describe a time you had to say no to a proposal because the risk outweighed the potential benefit.';

update interview_questions set difficulty = 'easy', improvement_guide =
  'Use a plain-language analogy: not putting all your eggs in one basket -- spreading money across different, not-perfectly-correlated investments so a loss in one area is likely offset by stability or gains elsewhere. Common pitfall: using technical terms like "correlation" or "variance" when the question specifically asks for a non-technical explanation.'
  where firm_style = 'Risk Analyst' and question_text = 'How would you explain the concept of diversification to someone with no finance background?';

-- ===================== Operations Analyst (5) =====================

update interview_questions set difficulty = 'medium', improvement_guide =
  'Describe the specific inefficiency or error source you identified, the concrete change you made, and ideally a measurable before/after (time saved, errors reduced). Common pitfall: describing a process change without quantifying or clearly stating what actually improved as a result.'
  where firm_style = 'Operations Analyst' and question_text = 'Describe a process you improved to make it faster or less error-prone.';

update interview_questions set difficulty = 'medium', improvement_guide =
  'Walk through your actual troubleshooting method -- isolating variables, checking recent changes, reproducing the issue -- rather than jumping straight to the fix, since the question is testing your diagnostic process. Common pitfall: skipping straight to how the problem was resolved without describing how you actually found the root cause.'
  where firm_style = 'Operations Analyst' and question_text = 'Tell me about a time you had to troubleshoot a problem when you didn''t immediately know the cause.';

update interview_questions set difficulty = 'medium', improvement_guide =
  'Describe a structured approach: isolate the specific transactions/records causing the mismatch, check for a systematic pattern (timing difference, a specific data field) rather than one-off errors, fix the root cause, and add a control to catch recurrences going forward. Common pitfall: describing only fixing the current mismatch without addressing why it''s recurring or how to prevent it next time.'
  where firm_style = 'Operations Analyst' and question_text = 'What steps would you take if you noticed a recurring reconciliation error between two systems?';

update interview_questions set difficulty = 'easy', improvement_guide =
  'Operations errors compound and often surface downstream -- in reporting, client-facing documents, financial statements -- where they''re costly or embarrassing to unwind, whereas a strategic misjudgment is usually caught and corrected earlier in a review process. Common pitfall: giving a generic "details matter" answer without explaining the specific downstream-consequence reasoning the question is asking for.'
  where firm_style = 'Operations Analyst' and question_text = 'Why does attention to detail matter more in operations roles than it might in a purely strategic role?';

update interview_questions set difficulty = 'hard', improvement_guide =
  'Describe the specific downstream impact clearly -- who was affected and how -- then focus most of the answer on the fix and, ideally, the process change that prevents recurrence, not just an apology. Common pitfall: focusing on how bad the downstream problem was without explaining what you specifically did to fix it and prevent it recurring.'
  where firm_style = 'Operations Analyst' and question_text = 'Tell me about a time a process failure caused a downstream problem for someone else. How did you fix it?';

-- ===================== Fintech Product Manager (6) =====================

update interview_questions set difficulty = 'medium', improvement_guide =
  'Use an explicit framework -- weighing user impact/reach against estimated engineering effort and strategic alignment -- rather than a gut-feel ranking, and be ready to name a specific trade-off you''d make. Common pitfall: listing desirable features without naming any actual prioritization criteria or framework.'
  where firm_style = 'Fintech Product Manager' and question_text = 'How would you prioritize which feature to build next with limited engineering resources?';

update interview_questions set difficulty = 'medium', improvement_guide =
  'Name specific, measurable behavioral metrics tied to the feature''s actual goal -- e.g. savings-goal completion rate, deposit frequency, balance growth over time -- rather than vanity metrics like page views. Common pitfall: proposing a metric like "user satisfaction" with no concrete, measurable definition of what that means or how it''s tracked.'
  where firm_style = 'Fintech Product Manager' and question_text = 'Describe how you would measure whether a new savings feature is actually helping users.';

update interview_questions set difficulty = 'medium', improvement_guide =
  'Describe the specific data or reasoning you used to explain the "no" -- competing priorities, low expected impact, technical risk -- and how you kept the stakeholder relationship constructive. Common pitfall: describing that you said no without explaining how you framed and justified that decision to the stakeholder.'
  where firm_style = 'Fintech Product Manager' and question_text = 'Tell me about a time you had to say no to a stakeholder''s feature request. How did you explain your reasoning?';

update interview_questions set difficulty = 'medium', improvement_guide =
  'Start from the user''s core need -- seeing where money goes, without complex setup -- then describe a concrete, simple flow (auto-categorized transactions, a simple visual breakdown, one clear action like setting a monthly limit) rather than listing every possible feature. Common pitfall: designing a feature-rich, complex tool when the question specifically asks for something simple for a first-time user.'
  where firm_style = 'Fintech Product Manager' and question_text = 'Walk me through how you would design a simple budgeting feature for a first-time user.';

update interview_questions set difficulty = 'medium', improvement_guide =
  'Describe the specific feedback or data point, what it revealed, and the concrete change in direction it caused -- ideally with an outcome. Common pitfall: describing user feedback that was collected but not clearly connected to an actual change in what was built or prioritized.'
  where firm_style = 'Fintech Product Manager' and question_text = 'Describe a time you used user feedback or data to change the direction of a product decision.';

update interview_questions set difficulty = 'hard', improvement_guide =
  'Name concrete considerations: data privacy and security of financial information, KYC/anti-money-laundering requirements if the feature touches money movement, and truthful, non-misleading presentation of fees/terms. Common pitfall: treating a fintech feature like any other consumer app feature with no mention of the regulatory dimensions specific to handling money.'
  where firm_style = 'Fintech Product Manager' and question_text = 'What regulatory or compliance considerations would you expect to matter when designing a new fintech feature?';

-- ===================== Equity Research Associate (6) =====================

update interview_questions set difficulty = 'medium', improvement_guide =
  'A "buy" rating implies the analyst expects meaningful upside relative to the stock''s current price and their fair-value estimate; a "hold" implies the stock is roughly fairly valued with limited expected movement either way -- the rating is driven by the gap between estimated fair value and current price. Common pitfall: describing ratings as generic sentiment ("buy = good, hold = neutral") without tying it to the actual valuation-gap driver.'
  where firm_style = 'Equity Research Associate' and question_text = 'What is the difference between a "buy" rating and a "hold" rating, and what typically drives the difference?';

update interview_questions set difficulty = 'hard', improvement_guide =
  'Build a structured view: estimate the company''s intrinsic value (via a DCF or peer multiples), compare it to the current market price, and check that view against qualitative factors (competitive position, management, industry trends) before concluding whether the gap represents genuine mispricing. Common pitfall: naming a single valuation method without cross-checking it against qualitative context, or without comparing it to the current price at all.'
  where firm_style = 'Equity Research Associate' and question_text = 'Walk me through how you would build an initial view on whether a stock is overvalued or undervalued.';

update interview_questions set difficulty = 'medium', improvement_guide =
  'Name factors like macroeconomic conditions (rates, currency), industry/regulatory shifts, competitor actions, and shifts in overall investor sentiment or risk appetite. Common pitfall: describing only company-specific financial factors when the question explicitly asks what matters beyond the company''s own financials.'
  where firm_style = 'Equity Research Associate' and question_text = 'What factors, beyond a company''s own financials, might change your outlook on its stock?';

update interview_questions set difficulty = 'medium', improvement_guide =
  'Describe specifically what new information changed your view, and be clear that you actually updated your thesis rather than dismissing the conflicting evidence -- this tests intellectual honesty and adaptability. Common pitfall: describing being wrong without describing how you concretely revised your view once new evidence appeared.'
  where firm_style = 'Equity Research Associate' and question_text = 'Tell me about a time your initial thesis on something was proven wrong by new information. What did you do?';

update interview_questions set difficulty = 'medium', improvement_guide =
  'Lead with the practical conclusion -- what this means for their investment -- before the supporting reasoning, using a concrete analogy rather than jargon, and check understanding along the way. Common pitfall: walking a non-technical client through the same level of technical detail you''d use with a colleague, losing their grasp of the actual conclusion.'
  where firm_style = 'Equity Research Associate' and question_text = 'Describe how you would explain a complex investment thesis to a client with limited financial background.';

update interview_questions set difficulty = 'hard', improvement_guide =
  'Earnings growth alone doesn''t guarantee a rising stock price if it still falls short of what was already priced into the stock, or if broader factors (rising rates, sector rotation, guidance for slower future growth) weigh on the multiple investors are willing to pay. Common pitfall: assuming strong earnings should mechanically produce a rising stock price, without accounting for expectations already priced in.'
  where firm_style = 'Equity Research Associate' and question_text = 'Why might a company with strong earnings growth still have a falling stock price?';

-- ===================== General Technical (8) =====================

update interview_questions set difficulty = 'easy', improvement_guide =
  'Time value of money means a dollar today is worth more than a dollar in the future, because today''s dollar can be invested and grow -- this underlies why future cash flows must be discounted in valuation and why borrowing/lending carries interest. Common pitfall: stating the concept as a rule to memorize without explaining why it matters for actual financial decisions like discounting or investment comparisons.'
  where firm_style = 'General Technical' and question_text = 'What is the time value of money, and why does it matter in financial decision-making?';

update interview_questions set difficulty = 'medium', improvement_guide =
  'A fixed-rate loan locks in the same rate for its term, giving payment certainty but no benefit if rates fall; a variable-rate loan''s rate moves with market rates, which can save money if rates fall but exposes the borrower to higher payments if rates rise. Common pitfall: naming the difference without identifying the actual risk each type carries for the borrower.'
  where firm_style = 'General Technical' and question_text = 'What is the difference between a fixed-rate and a variable-rate loan, and what risk does each carry?';

update interview_questions set difficulty = 'easy', improvement_guide =
  'Revenue is total sales; profit is what remains after subtracting all costs -- a company can grow revenue while losing money if its costs (especially fixed or rapidly scaling costs) grow faster than revenue, common for fast-growing but not-yet-efficient companies. Common pitfall: defining revenue and profit correctly but not explaining a concrete mechanism for how the first can grow while the second falls.'
  where firm_style = 'General Technical' and question_text = 'Explain the difference between revenue and profit, and why a company can grow revenue while losing money.';

update interview_questions set difficulty = 'medium', improvement_guide =
  'Cash flow negative means a company is spending more cash than it brings in during a period; it isn''t always a bad sign -- a growing company investing heavily in future capacity can be cash flow negative on purpose, as long as it has enough capital runway and a credible path to positive cash flow later. Common pitfall: treating "cash flow negative" as automatically alarming without considering context like growth-stage investment.'
  where firm_style = 'General Technical' and question_text = 'What does it mean for a company to be "cash flow negative," and is that always a bad sign?';

update interview_questions set difficulty = 'easy', improvement_guide =
  'Opportunity cost is the value of the next-best alternative given up by choosing one option -- money spent on a purchase today is money that could have been invested and grown, so the real "cost" isn''t just the price tag but what that money could have otherwise earned. Common pitfall: defining the term correctly but failing to apply it to a concrete everyday example as the question asks.'
  where firm_style = 'General Technical' and question_text = 'What is opportunity cost, and how would you apply it to a everyday financial decision?';

update interview_questions set difficulty = 'medium', improvement_guide =
  'Build up from a population estimate: estimate the number of small businesses in the city using a rough per-capita business density assumption, then estimate what share don''t already have adequate bookkeeping software, stating each assumption explicitly. Common pitfall: giving a number with no visible build-up or stated per-capita/adoption assumptions.'
  where firm_style = 'General Technical' and question_text = 'Estimate how many small businesses in your city might need basic bookkeeping software.';

update interview_questions set difficulty = 'easy', improvement_guide =
  'Compound interest is interest earned not just on your original principal but also on previously earned interest, so growth accelerates over time -- starting early matters because it gives compounding more time to work, so even modest early contributions can outgrow larger contributions made later. Common pitfall: defining compound interest correctly without explaining why time specifically, not just contribution size, is the key lever.'
  where firm_style = 'General Technical' and question_text = 'What is compound interest, and why does starting to save early matter so much?';

update interview_questions set difficulty = 'hard', improvement_guide =
  'Possible explanations include cost-cutting or efficiency improvements, a favorable shift in product/revenue mix toward higher-margin items, one-time gains (an asset sale, a tax benefit) below the operating line, or reduced interest expense -- name multiple distinct, plausible drivers rather than one. Common pitfall: naming only "cost cutting" when several other distinct explanations (mix shift, one-time items, below-the-line effects) are equally plausible and worth naming.'
  where firm_style = 'General Technical' and question_text = 'A company''s revenue is flat but its net income is rising. What are some possible explanations?';

-- ===================== Safety net =====================
-- If any row above still has a null improvement_guide, a (firm_style,
-- question_text) match failed to hit its target row -- fail loudly here
-- rather than silently shipping an incomplete backfill or a not-null
-- constraint violation with no context about which row is at fault.
do $$
declare
  v_missing_ids uuid[];
begin
  select array_agg(id) into v_missing_ids from interview_questions where improvement_guide is null;

  if v_missing_ids is not null then
    raise exception 'interview_questions rows missing improvement_guide after backfill (ids: %) -- a firm_style/question_text match in 00000000000046 failed to hit; compare exact text against 00000000000019/00000000000035', v_missing_ids;
  end if;
end $$;

alter table interview_questions
  alter column improvement_guide set not null;

alter table interview_questions
  add constraint interview_questions_improvement_guide_not_blank check (length(trim(improvement_guide)) > 0);

