-- Job-Ready case studies: one new skill (223, chaining off 222, the top of
-- the tier's existing chain) holding a short intro lesson plus four
-- case-study quizzes (quiz_type = 'case_study', schema added in
-- 00000000000043) attached to that same skill_id -- the existing
-- LessonDetail component already renders one button per quiz for a given
-- skill, so multiple quizzes under one skill needs no frontend change.
--
-- Each case study shows a realistic Job-Ready scenario once
-- (`quizzes.scenario_body`) tagged with where it's drawn from
-- (`quizzes.context_tag`: scenario type + role/industry context) and asks
-- 5 questions mixing multiple_choice and free_response, spanning easy/
-- medium/hard difficulty -- 20 questions total across the four. Free-
-- response questions are graded by keyword match (>=50% of a question's
-- `keywords` array must appear in the submitted answer -- see
-- grade_quiz_attempt in 00000000000043), so `keywords` lists below name the
-- concrete concepts a correct answer should mention, not exact phrasing.
--
-- pass_threshold is 0.7 here (vs. 0.8 for standard quizzes) because
-- keyword-match grading is coarser than exact multiple-choice matching --
-- a student who answers correctly but phrases a free-response answer
-- differently than the keyword list shouldn't be penalized as hard as a
-- genuinely wrong multiple-choice pick.

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

insert into quiz_questions (quiz_id, question, options, correct_answer, order_index, difficulty, question_type, keywords) values
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
    null, null, 4, 'medium', 'free_response',
    '["bonus", "equity", "options", "vesting", "health insurance", "premium", "cliff"]'::jsonb),
  ('00000000-0000-0000-0003-000000000223', 'Given the 1-year cliff on Nimbus Pay''s options, what risk would you take by leaving that job after 8 months, and how should that risk factor into your decision between the two offers?',
    null, null, 5, 'hard', 'free_response',
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
    null, null, 4, 'hard', 'free_response',
    '["net pay", "gross pay", "deductions", "budget", "less than", "actual"]'::jsonb),
  ('00000000-0000-0000-0003-000000000224', 'What does it mean that Jordan''s tax withholding is an "estimated prepayment" rather than a final bill?',
    null, null, 5, 'easy', 'free_response',
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
    null, null, 4, 'hard', 'free_response',
    '["report", "escalate", "compliance", "manager", "flag", "risk", "silence"]'::jsonb),
  ('00000000-0000-0000-0003-000000000225', 'What should you do with the acquisition tip you received, even though you didn''t ask for it?',
    null, null, 5, 'medium', 'free_response',
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
    null, null, 4, 'medium', 'free_response',
    '["401(k) match", "retirement match", "health insurance", "deductible", "salary", "guaranteed"]'::jsonb),
  ('00000000-0000-0000-0003-000000000226', 'How should Amara weigh the startup''s speculative equity upside against the corporation''s guaranteed compensation, based on how most startup equity tends to turn out?',
    null, null, 5, 'hard', 'free_response',
    '["most startups fail", "speculative", "upside", "guaranteed", "cash", "little or nothing", "risk"]'::jsonb);
