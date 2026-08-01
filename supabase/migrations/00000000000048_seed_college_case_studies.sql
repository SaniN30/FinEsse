-- College content-depth followup: case-study quizzes.
--
-- Three realistic College-tier financial scenarios, each its own quiz
-- attached (as a *second* quiz) to an existing/soon-to-exist skill via
-- `skill_id` -- `LessonDetail.tsx` already renders every quiz row for a
-- skill as its own "Take quiz" button, so no frontend change was needed to
-- surface a second quiz per skill. Each mixes multiple_choice and
-- free_response questions (graded by keyword match via the
-- `grade_quiz_attempt` extension in migration 046), spans easy/medium/hard
-- difficulty, and every question carries the same `scenario_context` for
-- its case so the frontend can display "what this case study is modeled
-- on" alongside the question. 24 questions total across the three cases.
--
-- Case study numbers used here (dollar figures, rates) are illustrative
-- teaching examples, not sourced from any real employer/lender data.

insert into quizzes (id, skill_id, title, pass_threshold) values
  ('00000000-0000-0000-0003-000000000119', '00000000-0000-0000-0001-000000000110',
   'Case Study: Choosing a Student Loan Repayment Strategy', 0.8),
  ('00000000-0000-0000-0003-000000000120', '00000000-0000-0000-0001-000000000109',
   'Case Study: Building a First Budget on a Student Income', 0.8),
  ('00000000-0000-0000-0003-000000000121', '00000000-0000-0000-0001-000000000118',
   'Case Study: Prioritizing Money Goals After Graduation', 0.8);

-- ===================== Case A: loan repayment strategy =====================
-- Priya: $58,000/year software engineer, $32,000 federal loans at 5.5%.
-- Standard 10-yr payment ~$347/mo (~$9,640 total interest over the term).
-- Income-driven payment set at $120/mo, below the ~$147/mo interest accrual,
-- so the balance grows (negative amortization) absent an income increase or
-- forgiveness path -- deliberately chosen to teach that the lower payment
-- is not automatically the cheaper choice.

insert into quiz_questions (quiz_id, question, options, correct_answer, order_index, difficulty, question_type, grading_keywords, min_keyword_matches, scenario_context) values
  ('00000000-0000-0000-0003-000000000119',
   'What is the main difference between a standard 10-year federal repayment plan and an income-driven repayment plan?',
   '["The standard plan has a fixed term with higher fixed payments; income-driven plans set payments as a percentage of income, often extending the payoff period", "Income-driven plans are only available for private loans", "The standard plan charges no interest at all", "Income-driven plans always cost less in total interest than the standard plan"]'::jsonb,
   'The standard plan has a fixed term with higher fixed payments; income-driven plans set payments as a percentage of income, often extending the payoff period',
   1, 'easy', 'multiple_choice', null, 1,
   'Case study: Priya, a first-year software engineer earning $58,000/year, graduated with $32,000 in federal student loans at 5.5% interest and is choosing a repayment plan.'),

  ('00000000-0000-0000-0003-000000000119',
   'Priya''s standard 10-year plan payment is about $347/month. Her income-driven plan payment is estimated at $120/month based on her income. What is the immediate trade-off she faces?',
   '["The income-driven plan frees up $227/month in cash flow now, but since $120 is less than the interest accruing each month, her loan balance could grow instead of shrink", "The income-driven plan pays off the loan faster", "There is no trade-off -- both plans are identical in cost", "The standard plan is not available to recent graduates"]'::jsonb,
   'The income-driven plan frees up $227/month in cash flow now, but since $120 is less than the interest accruing each month, her loan balance could grow instead of shrink',
   2, 'medium', 'multiple_choice', null, 1,
   'Case study: Priya, a first-year software engineer earning $58,000/year, graduated with $32,000 in federal student loans at 5.5% interest and is choosing a repayment plan.'),

  ('00000000-0000-0000-0003-000000000119',
   'At 5.5% annual interest on a $32,000 balance, monthly interest accrues at roughly $147. If Priya pays $120/month on the income-driven plan, approximately how much does her balance grow each month (before any income increase)?',
   '["It shrinks by about $27/month", "It grows by about $27/month", "It stays exactly flat", "It grows by about $120/month"]'::jsonb,
   'It grows by about $27/month',
   3, 'hard', 'multiple_choice', null, 1,
   'Case study: Priya, a first-year software engineer earning $58,000/year, graduated with $32,000 in federal student loans at 5.5% interest and is choosing a repayment plan.'),

  ('00000000-0000-0000-0003-000000000119',
   'Which of these is the strongest reason Priya might still rationally choose the income-driven plan despite the negative-amortization risk?',
   '["She expects her income to rise significantly in a few years, and/or she is pursuing a career path eligible for loan forgiveness after a set number of qualifying payments", "Income-driven plans are always cheaper in total dollars paid", "Negative amortization has no real consequence for future borrowing", "It guarantees her loan will be forgiven within 2 years"]'::jsonb,
   'She expects her income to rise significantly in a few years, and/or she is pursuing a career path eligible for loan forgiveness after a set number of qualifying payments',
   4, 'medium', 'multiple_choice', null, 1,
   'Case study: Priya, a first-year software engineer earning $58,000/year, graduated with $32,000 in federal student loans at 5.5% interest and is choosing a repayment plan.'),

  ('00000000-0000-0000-0003-000000000119',
   'Which type of federal loan does NOT accrue interest while the borrower is still in school?',
   '["Subsidized federal loans", "Unsubsidized federal loans", "Private loans", "All loans accrue interest while in school"]'::jsonb,
   'Subsidized federal loans',
   5, 'easy', 'multiple_choice', null, 1,
   'Case study: Priya, a first-year software engineer earning $58,000/year, graduated with $32,000 in federal student loans at 5.5% interest and is choosing a repayment plan.'),

  ('00000000-0000-0000-0003-000000000119',
   'In 1-2 sentences: explain why choosing the lower monthly payment (income-driven plan) is not automatically the cheaper choice for Priya.',
   '[]'::jsonb, '(graded via grading_keywords, not correct_answer)',
   6, 'medium', 'free_response',
   '["more interest", "total interest", "longer", "negative amortization", "balance grows", "costs more over time", "pay more over", "grow instead of shrink"]'::jsonb, 1,
   'Case study: Priya, a first-year software engineer earning $58,000/year, graduated with $32,000 in federal student loans at 5.5% interest and is choosing a repayment plan.'),

  ('00000000-0000-0000-0003-000000000119',
   'Priya is considering a career at a nonprofit that qualifies for Public Service Loan Forgiveness after 10 years of qualifying payments. In 1-2 sentences, explain how this changes the calculus around choosing the income-driven plan.',
   '[]'::jsonb, '(graded via grading_keywords, not correct_answer)',
   7, 'hard', 'free_response',
   '["forgiven", "forgiveness", "lower payments", "worth it", "remaining balance", "cheaper because", "don''t need to pay it all", "wiped"]'::jsonb, 1,
   'Case study: Priya, a first-year software engineer earning $58,000/year, graduated with $32,000 in federal student loans at 5.5% interest and is choosing a repayment plan.'),

  ('00000000-0000-0000-0003-000000000119',
   'Name one concrete action Priya should take before her loans enter repayment to make an informed choice between plans.',
   '[]'::jsonb, '(graded via grading_keywords, not correct_answer)',
   8, 'easy', 'free_response',
   '["loan servicer", "calculator", "compare", "read the terms", "budget", "estimate payment", "check eligibility", "research"]'::jsonb, 1,
   'Case study: Priya, a first-year software engineer earning $58,000/year, graduated with $32,000 in federal student loans at 5.5% interest and is choosing a repayment plan.');

-- ===================== Case B: first student-income budget =====================
-- Marcus: $900/mo part-time job + $400/mo aid refund = $1,300/mo. Fixed
-- costs $750/mo (rent share $500, groceries $150, phone $40, transport $60).
-- $300/semester textbooks averaged to $75/mo. 20% savings target on income.

insert into quiz_questions (quiz_id, question, options, correct_answer, order_index, difficulty, question_type, grading_keywords, min_keyword_matches, scenario_context) values
  ('00000000-0000-0000-0003-000000000120',
   'What are Marcus''s two income sources in this scenario?',
   '["Part-time job wages and a financial-aid refund", "A trust fund and a scholarship", "A trust fund and a part-time job", "A financial-aid refund and a scholarship"]'::jsonb,
   'Part-time job wages and a financial-aid refund',
   1, 'easy', 'multiple_choice', null, 1,
   'Case study: Marcus, a sophomore, earns $900/month from a part-time campus job and receives a $400/month financial-aid refund, and is building his first real budget.'),

  ('00000000-0000-0000-0003-000000000120',
   'Marcus earns $900/month from his job and $400/month from his aid refund. What is his total monthly income?',
   '["$1,200", "$1,300", "$1,400", "$900"]'::jsonb,
   '$1,300',
   2, 'easy', 'multiple_choice', null, 1,
   'Case study: Marcus, a sophomore, earns $900/month from a part-time campus job and receives a $400/month financial-aid refund, and is building his first real budget.'),

  ('00000000-0000-0000-0003-000000000120',
   'Marcus''s rent share is $500, groceries $150, phone $40, and transport $60. What are his total fixed/predictable monthly expenses?',
   '["$650", "$750", "$850", "$700"]'::jsonb,
   '$750',
   3, 'medium', 'multiple_choice', null, 1,
   'Case study: Marcus, a sophomore, earns $900/month from a part-time campus job and receives a $400/month financial-aid refund, and is building his first real budget.'),

  ('00000000-0000-0000-0003-000000000120',
   'With $1,300 income and $750 in predictable expenses, how much does Marcus have left for irregular expenses (like textbooks), wants, and savings combined?',
   '["$450", "$550", "$650", "$350"]'::jsonb,
   '$550',
   4, 'medium', 'multiple_choice', null, 1,
   'Case study: Marcus, a sophomore, earns $900/month from a part-time campus job and receives a $400/month financial-aid refund, and is building his first real budget.'),

  ('00000000-0000-0000-0003-000000000120',
   'Marcus spends $300 on textbooks once per semester (roughly every 4 months). What is the best way for him to budget for this irregular expense?',
   '["Ignore it until it happens and cover the shortfall however he can", "Set aside about $75/month ($300 / 4) in a dedicated fund so the lump cost doesn''t blow up any single month''s budget", "Only buy textbooks if he has $300 in his checking account that exact week", "Skip buying textbooks entirely"]'::jsonb,
   'Set aside about $75/month ($300 / 4) in a dedicated fund so the lump cost doesn''t blow up any single month''s budget',
   5, 'hard', 'multiple_choice', null, 1,
   'Case study: Marcus, a sophomore, earns $900/month from a part-time campus job and receives a $400/month financial-aid refund, and is building his first real budget.'),

  ('00000000-0000-0000-0003-000000000120',
   'After setting aside $75/month for textbooks from his $550 remaining, Marcus has $475/month left for wants and savings. If he wants to save 20% of his total $1,300 income each month, roughly how much is that, and is it achievable from the $475 remaining?',
   '["$260, and yes -- it leaves $215/month for discretionary wants", "$650, and no -- it exceeds what''s left", "$130, and no -- it''s not achievable", "$260, and no -- nothing would be left for wants"]'::jsonb,
   '$260, and yes -- it leaves $215/month for discretionary wants',
   6, 'hard', 'multiple_choice', null, 1,
   'Case study: Marcus, a sophomore, earns $900/month from a part-time campus job and receives a $400/month financial-aid refund, and is building his first real budget.'),

  ('00000000-0000-0000-0003-000000000120',
   'In 1-2 sentences: explain why Marcus should budget for his once-a-semester textbook cost monthly rather than only thinking about it when the bill arrives.',
   '[]'::jsonb, '(graded via grading_keywords, not correct_answer)',
   7, 'medium', 'free_response',
   '["irregular", "smooth", "spread out", "avoid a shortfall", "surprise", "plan ahead", "set aside", "sinking fund", "budget ahead"]'::jsonb, 1,
   'Case study: Marcus, a sophomore, earns $900/month from a part-time campus job and receives a $400/month financial-aid refund, and is building his first real budget.'),

  ('00000000-0000-0000-0003-000000000120',
   'Marcus''s financial-aid refund arrives once per semester as a lump sum rather than monthly. In 1-2 sentences, explain a risk of budgeting as if that lump sum were evenly spread across the semester, and one way to manage it.',
   '[]'::jsonb, '(graded via grading_keywords, not correct_answer)',
   8, 'hard', 'free_response',
   '["overspend", "spend it all", "run out", "budget it monthly", "divide", "separate account", "don''t spend all at once", "spread it out"]'::jsonb, 1,
   'Case study: Marcus, a sophomore, earns $900/month from a part-time campus job and receives a $400/month financial-aid refund, and is building his first real budget.');

-- ===================== Case C: post-grad money priorities =====================
-- Jordan: $55,000/year marketing job, $3,000 savings, $6,000 credit card
-- debt at 22% APR, no employer 401(k) match in year one.

insert into quiz_questions (quiz_id, question, options, correct_answer, order_index, difficulty, question_type, grading_keywords, min_keyword_matches, scenario_context) values
  ('00000000-0000-0000-0003-000000000121',
   'Jordan has $6,000 in credit card debt at 22% APR and $3,000 in savings earning about 0.5% in a regular savings account. What should Jordan generally prioritize first?',
   '["Aggressively paying down the 22% APR credit card debt, since that guaranteed cost avoided vastly exceeds what the savings account earns", "Investing all $3,000 in the stock market immediately", "Ignoring the credit card debt since it is a small amount", "Spending the $3,000 on a vacation since Jordan just graduated"]'::jsonb,
   'Aggressively paying down the 22% APR credit card debt, since that guaranteed cost avoided vastly exceeds what the savings account earns',
   1, 'easy', 'multiple_choice', null, 1,
   'Case study: Jordan just graduated and started a $55,000/year marketing job, has $3,000 in savings, $6,000 in credit card debt at 22% APR, and no employer 401(k) match for the first year.'),

  ('00000000-0000-0000-0003-000000000121',
   'Roughly how much does Jordan''s $6,000 balance cost in interest per year if left untouched at 22% APR?',
   '["About $132/year", "About $660/year", "About $1,320/year", "About $2,640/year"]'::jsonb,
   'About $1,320/year',
   2, 'medium', 'multiple_choice', null, 1,
   'Case study: Jordan just graduated and started a $55,000/year marketing job, has $3,000 in savings, $6,000 in credit card debt at 22% APR, and no employer 401(k) match for the first year.'),

  ('00000000-0000-0000-0003-000000000121',
   'A common priority framework suggests building a SMALL starter emergency fund (e.g. $500-$1,000) even before aggressively paying off moderate/high-rate debt. Why might that come first?',
   '["So an unexpected expense doesn''t force Jordan back onto the same high-interest credit card, undoing debt-payoff progress", "Emergency funds always earn higher returns than paying off debt", "It is required by law before paying off any debt", "It has no real purpose if you already have a credit card"]'::jsonb,
   'So an unexpected expense doesn''t force Jordan back onto the same high-interest credit card, undoing debt-payoff progress',
   3, 'medium', 'multiple_choice', null, 1,
   'Case study: Jordan just graduated and started a $55,000/year marketing job, has $3,000 in savings, $6,000 in credit card debt at 22% APR, and no employer 401(k) match for the first year.'),

  ('00000000-0000-0000-0003-000000000121',
   'A common priority framework ranks goals roughly as: (1) small starter emergency fund, (2) high-interest debt payoff, (3) fuller emergency fund, (4) retirement/investing, (5) other goals. Given Jordan has no employer match to "leave on the table" this year, does it still make sense to deprioritize retirement contributions below debt payoff?',
   '["Yes -- with no match, the guaranteed 22% return from paying off credit card debt outweighs the uncertain market return from investing right now", "No -- retirement should always come before any debt payoff regardless of interest rate", "No -- Jordan should stop saving for retirement permanently", "Yes, but only because retirement accounts are illegal before age 25"]'::jsonb,
   'Yes -- with no match, the guaranteed 22% return from paying off credit card debt outweighs the uncertain market return from investing right now',
   4, 'hard', 'multiple_choice', null, 1,
   'Case study: Jordan just graduated and started a $55,000/year marketing job, has $3,000 in savings, $6,000 in credit card debt at 22% APR, and no employer 401(k) match for the first year.'),

  ('00000000-0000-0000-0003-000000000121',
   'What is generally considered a reasonable target size for a FULL emergency fund, once high-interest debt is handled?',
   '["3-6 months of essential expenses", "One week of expenses", "A flat $50", "A full year of gross salary"]'::jsonb,
   '3-6 months of essential expenses',
   5, 'easy', 'multiple_choice', null, 1,
   'Case study: Jordan just graduated and started a $55,000/year marketing job, has $3,000 in savings, $6,000 in credit card debt at 22% APR, and no employer 401(k) match for the first year.'),

  ('00000000-0000-0000-0003-000000000121',
   'In 1-2 sentences: explain why "highest interest rate first" is a common rule of thumb when someone has multiple debts.',
   '[]'::jsonb, '(graded via grading_keywords, not correct_answer)',
   6, 'medium', 'free_response',
   '["costs the most", "grows fastest", "saves the most interest", "most expensive", "compounds fastest", "minimizes total interest"]'::jsonb, 1,
   'Case study: Jordan just graduated and started a $55,000/year marketing job, has $3,000 in savings, $6,000 in credit card debt at 22% APR, and no employer 401(k) match for the first year.'),

  ('00000000-0000-0000-0003-000000000121',
   'If Jordan''s employer added a 50% match up to 4% of salary starting next year, explain in 1-2 sentences how that should change Jordan''s priority order even while some credit card debt remains.',
   '[]'::jsonb, '(graded via grading_keywords, not correct_answer)',
   7, 'hard', 'free_response',
   '["free money", "match", "contribute enough to get the match", "guaranteed return", "before finishing", "at least up to the match"]'::jsonb, 1,
   'Case study: Jordan just graduated and started a $55,000/year marketing job, has $3,000 in savings, $6,000 in credit card debt at 22% APR, and no employer 401(k) match for the first year.'),

  ('00000000-0000-0000-0003-000000000121',
   'Name one specific new post-grad expense Jordan should account for in a budget that likely did not exist as a student.',
   '[]'::jsonb, '(graded via grading_keywords, not correct_answer)',
   8, 'easy', 'free_response',
   '["rent", "health insurance", "commuting", "work clothes", "retirement contribution", "moving cost", "utilities", "car payment", "student loan payment"]'::jsonb, 1,
   'Case study: Jordan just graduated and started a $55,000/year marketing job, has $3,000 in savings, $6,000 in credit card debt at 22% APR, and no employer 401(k) match for the first year.');
