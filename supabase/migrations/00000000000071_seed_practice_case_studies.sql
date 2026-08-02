-- Practice mode content pass: five new case-study quizzes, one per topic
-- area named in the Practice feature brief (financial statement analysis,
-- credit decisions, valuation, workplace ethics, plus a School-tier goal-
-- setting case), bringing the platform's total case-study question count
-- (quiz_questions rows with scenario_context populated) from 24 to 58 --
-- comfortably past the 50+ bar. Each is attached as an additional quiz on
-- an existing, already-live skill (same "second quiz on a skill" pattern as
-- 00000000000048_seed_college_case_studies.sql), so no new skill is added
-- and tier-completion mastery math (which counts over `skills`) is
-- unaffected for any student.
--
-- All scenario narratives and figures below are original teaching examples
-- written for this migration, grounded in standard public frameworks (cited
-- per case) -- not copied from any textbook, course, or paywalled source.
--
-- School's QuizRunner (components/school/QuizRunner.tsx) only renders
-- multiple_choice options, so the School case study here is MCQ-only;
-- College/Job-Ready use components/quiz/QuizRunner.tsx, which already
-- renders free_response textareas and the scenario_context banner, so
-- those mix multiple_choice and free_response like the existing College
-- case studies.

insert into quizzes (id, skill_id, title, pass_threshold) values
  ('00000000-0000-0000-0005-000000000201', (select id from skills where slug = 'financial-goal-setting'),
   'Case Study: Juggling Multiple Savings Goals on a Part-Time Job', 0.8),
  ('00000000-0000-0000-0005-000000000202', (select id from skills where slug = 'financial-statement-analysis'),
   'Case Study: Reading Riverside Outdoor Co.''s Financial Statements', 0.7),
  ('00000000-0000-0000-0005-000000000203', (select id from skills where slug = 'credit-risk-basics'),
   'Case Study: Underwriting a Small-Business Loan for Community Bakery Co.', 0.7),
  ('00000000-0000-0000-0005-000000000204', (select id from skills where slug = 'technical-interview-prep'),
   'Case Study: Walking Through a DCF Valuation in a Technical Interview', 0.7),
  ('00000000-0000-0000-0005-000000000205', (select id from skills where slug = 'ethics-and-compliance-basics'),
   'Case Study: A Friend''s Tip Before Earnings', 0.7);

-- ===================== School: multiple savings goals =====================
-- Maya, 16, earns $120/month from a part-time job; a $600 laptop needed in
-- ~9 months and an open-ended $2,000 "future car" fund. Framework: SMART
-- goals + "pay yourself first" -- standard personal-finance goal-setting
-- concepts, not sourced from any specific course.

insert into quiz_questions (quiz_id, question, options, correct_answer, order_index, difficulty, question_type, scenario_context) values
  ('00000000-0000-0000-0005-000000000201',
   'Maya has 9 months until she needs a laptop for school ($600 target) and a car fund with no deadline ($2,000 target, "someday"). Given the time constraint on the laptop, what should guide her priority?',
   '["Prioritize the laptop since it has a hard deadline and clear near-term need, while still sending a small amount to the car fund each month", "Ignore the laptop deadline entirely -- deadlines do not matter in budgeting", "Split every dollar 50/50 between the two goals regardless of deadlines", "Put all her money toward the car fund since it is the larger target"]'::jsonb,
   'Prioritize the laptop since it has a hard deadline and clear near-term need, while still sending a small amount to the car fund each month',
   1, 'easy', 'multiple_choice',
   'Case study: Maya, 16, earns $120/month from a part-time job. She needs a $600 laptop for school in 9 months and also wants to build a $2,000 "future car" fund with no fixed deadline.'),

  ('00000000-0000-0000-0005-000000000201',
   'Maya saves $70/month toward her $600 laptop goal, starting from $0. Rounding up to the nearest whole month, how long will it take her to reach $600?',
   '["6 months", "8 months", "9 months", "12 months"]'::jsonb,
   '9 months',
   2, 'medium', 'multiple_choice',
   'Case study: Maya, 16, earns $120/month from a part-time job. She needs a $600 laptop for school in 9 months and also wants to build a $2,000 "future car" fund with no fixed deadline.'),

  ('00000000-0000-0000-0005-000000000201',
   'Maya''s parent offers to match 50% of what she saves toward the laptop each month, up to a $35/month match cap. If Maya still saves $70/month herself, how many months will it now take to reach $600?',
   '["4 months", "5 months", "6 months", "9 months"]'::jsonb,
   '6 months',
   3, 'hard', 'multiple_choice',
   'Case study: Maya, 16, earns $120/month from a part-time job. She needs a $600 laptop for school in 9 months and also wants to build a $2,000 "future car" fund with no fixed deadline.'),

  ('00000000-0000-0000-0005-000000000201',
   'Maya''s "future car" goal has no deadline. Which budgeting principle best explains why she should still send it a small fixed amount every month rather than $0 until the laptop goal is finished?',
   '["Paying yourself first: consistent saving habits compound over time, even for undated goals, and are hard to restart once dropped to zero", "Only goals with deadlines are worth funding at all", "It is always better to save nothing until the first goal is fully done", "Undated goals should be deprioritized to exactly $0 by definition"]'::jsonb,
   'Paying yourself first: consistent saving habits compound over time, even for undated goals, and are hard to restart once dropped to zero',
   4, 'medium', 'multiple_choice',
   'Case study: Maya, 16, earns $120/month from a part-time job. She needs a $600 laptop for school in 9 months and also wants to build a $2,000 "future car" fund with no fixed deadline.'),

  ('00000000-0000-0000-0005-000000000201',
   'Maya''s part-time hours vary: some months she earns $90, other months $150. What is the best budgeting approach for her savings plan?',
   '["Budget her fixed savings contributions off her lowest reliably expected income, and treat anything extra in higher-earning months as bonus savings", "Budget as if she will always earn her best month''s pay", "Spend freely in high-income months since low-income months will balance out on their own", "Borrow against expected future high-income months to spend more now"]'::jsonb,
   'Budget her fixed savings contributions off her lowest reliably expected income, and treat anything extra in higher-earning months as bonus savings',
   5, 'easy', 'multiple_choice',
   'Case study: Maya, 16, earns $120/month from a part-time job. She needs a $600 laptop for school in 9 months and also wants to build a $2,000 "future car" fund with no fixed deadline.'),

  ('00000000-0000-0000-0005-000000000201',
   'Which of these is the best example of a SMART (Specific, Measurable, Achievable, Relevant, Time-bound) version of Maya''s laptop goal?',
   '["Save $600 for a laptop by saving $70/month for 9 months", "Save some money for a laptop someday", "Try to save as much as possible this year", "Get a laptop eventually, however that ends up happening"]'::jsonb,
   'Save $600 for a laptop by saving $70/month for 9 months',
   6, 'medium', 'multiple_choice',
   'Case study: Maya, 16, earns $120/month from a part-time job. She needs a $600 laptop for school in 9 months and also wants to build a $2,000 "future car" fund with no fixed deadline.');

-- ===================== College: financial statement analysis =====================
-- Riverside Outdoor Co. (illustrative small retailer). Current assets
-- $180k, current liabilities $120k, inventory $70k, total liabilities
-- $340k, total equity $260k, revenue $900k, COGS $600k, net income $54k.
-- Framework: standard liquidity/leverage/profitability ratio analysis
-- (current ratio, quick ratio, debt-to-equity, gross margin, ROE) -- a
-- general accounting/finance methodology, not sourced from any specific
-- textbook.

insert into quiz_questions (quiz_id, question, options, correct_answer, order_index, difficulty, question_type, grading_keywords, min_keyword_matches, scenario_context) values
  ('00000000-0000-0000-0005-000000000202',
   'Riverside Outdoor Co. has current assets of $180,000 and current liabilities of $120,000. What is its current ratio?',
   '["1.5", "0.67", "3.0", "60,000"]'::jsonb,
   '1.5',
   1, 'easy', 'multiple_choice', null, 1,
   'Case study: Riverside Outdoor Co., a small outdoor-gear retailer. Current assets $180,000; current liabilities $120,000; inventory $70,000; total liabilities $340,000; total equity $260,000; revenue $900,000; COGS $600,000; net income $54,000.'),

  ('00000000-0000-0000-0005-000000000202',
   'The quick ratio (acid-test ratio) excludes inventory from current assets before dividing by current liabilities. Using ($180,000 - $70,000) / $120,000, what is Riverside''s quick ratio?',
   '["0.92", "1.50", "1.10", "2.57"]'::jsonb,
   '0.92',
   2, 'medium', 'multiple_choice', null, 1,
   'Case study: Riverside Outdoor Co., a small outdoor-gear retailer. Current assets $180,000; current liabilities $120,000; inventory $70,000; total liabilities $340,000; total equity $260,000; revenue $900,000; COGS $600,000; net income $54,000.'),

  ('00000000-0000-0000-0005-000000000202',
   'With total liabilities of $340,000 and total equity of $260,000, what is Riverside''s debt-to-equity ratio (rounded to two decimals)?',
   '["1.31", "0.76", "0.44", "2.31"]'::jsonb,
   '1.31',
   3, 'medium', 'multiple_choice', null, 1,
   'Case study: Riverside Outdoor Co., a small outdoor-gear retailer. Current assets $180,000; current liabilities $120,000; inventory $70,000; total liabilities $340,000; total equity $260,000; revenue $900,000; COGS $600,000; net income $54,000.'),

  ('00000000-0000-0000-0005-000000000202',
   'With revenue of $900,000 and COGS of $600,000, what is Riverside''s gross margin?',
   '["33.3%", "66.7%", "6.0%", "150.0%"]'::jsonb,
   '33.3%',
   4, 'medium', 'multiple_choice', null, 1,
   'Case study: Riverside Outdoor Co., a small outdoor-gear retailer. Current assets $180,000; current liabilities $120,000; inventory $70,000; total liabilities $340,000; total equity $260,000; revenue $900,000; COGS $600,000; net income $54,000.'),

  ('00000000-0000-0000-0005-000000000202',
   'Riverside''s quick ratio (0.92) is below 1.0 while its current ratio (1.5) is above 1.0. In 1-2 sentences, explain what this gap tells a lender about how much of Riverside''s short-term liquidity depends on selling inventory.',
   '[]'::jsonb, '(graded via grading_keywords, not correct_answer)',
   5, 'hard', 'free_response',
   '["inventory", "sell", "sold", "liquidity", "depends on", "not immediately liquid", "harder to convert", "convert to cash"]'::jsonb, 1,
   'Case study: Riverside Outdoor Co., a small outdoor-gear retailer. Current assets $180,000; current liabilities $120,000; inventory $70,000; total liabilities $340,000; total equity $260,000; revenue $900,000; COGS $600,000; net income $54,000.'),

  ('00000000-0000-0000-0005-000000000202',
   'With net income of $54,000 and total equity of $260,000, what is Riverside''s return on equity (ROE), rounded to one decimal?',
   '["20.8%", "6.0%", "48.1%", "14.3%"]'::jsonb,
   '20.8%',
   6, 'hard', 'multiple_choice', null, 1,
   'Case study: Riverside Outdoor Co., a small outdoor-gear retailer. Current assets $180,000; current liabilities $120,000; inventory $70,000; total liabilities $340,000; total equity $260,000; revenue $900,000; COGS $600,000; net income $54,000.'),

  ('00000000-0000-0000-0005-000000000202',
   'A lender is deciding whether Riverside''s 1.31 debt-to-equity ratio is a red flag. In 1-2 sentences, what additional context (beyond the ratio alone) should the lender consider before concluding it is too risky?',
   '[]'::jsonb, '(graded via grading_keywords, not correct_answer)',
   7, 'hard', 'free_response',
   '["industry average", "compare to industry", "cash flow", "interest coverage", "trend over time", "stability of earnings", "industry norm"]'::jsonb, 1,
   'Case study: Riverside Outdoor Co., a small outdoor-gear retailer. Current assets $180,000; current liabilities $120,000; inventory $70,000; total liabilities $340,000; total equity $260,000; revenue $900,000; COGS $600,000; net income $54,000.');

-- ===================== College: credit risk / underwriting =====================
-- Community Bakery Co. seeking a $150,000 loan. Existing debt service
-- $6,000/yr; new loan adds $30,000/yr; net operating income available for
-- debt service $42,000/yr. Framework: the "5 Cs of credit" (character,
-- capacity, capital, collateral, conditions) and debt service coverage
-- ratio (DSCR = net operating income / total debt service) -- standard
-- commercial credit underwriting concepts, not sourced from any specific
-- lender's proprietary materials.

insert into quiz_questions (quiz_id, question, options, correct_answer, order_index, difficulty, question_type, grading_keywords, min_keyword_matches, scenario_context) values
  ('00000000-0000-0000-0005-000000000203',
   'In the classic "5 Cs of credit" framework, which "C" refers to the borrower''s ability to repay the loan from its ongoing cash flow?',
   '["Capacity", "Character", "Collateral", "Conditions"]'::jsonb,
   'Capacity',
   1, 'medium', 'multiple_choice', null, 1,
   'Case study: Community Bakery Co. is applying for a $150,000 small-business loan. Its net operating income available for debt service is $42,000/year. It already has $6,000/year in existing debt service, and the new loan would add $30,000/year.'),

  ('00000000-0000-0000-0005-000000000203',
   'Debt service coverage ratio (DSCR) = net operating income / total debt service. With $42,000 in net operating income and total debt service of $36,000 ($30,000 new + $6,000 existing), what is Community Bakery''s DSCR (rounded to two decimals)?',
   '["1.17", "0.86", "1.40", "7.00"]'::jsonb,
   '1.17',
   2, 'hard', 'multiple_choice', null, 1,
   'Case study: Community Bakery Co. is applying for a $150,000 small-business loan. Its net operating income available for debt service is $42,000/year. It already has $6,000/year in existing debt service, and the new loan would add $30,000/year.'),

  ('00000000-0000-0000-0005-000000000203',
   'A DSCR of 1.17 means:',
   '["The business generates about 17% more operating income than it needs to cover all its scheduled debt payments", "The business earns 1.17 times its total debt outstanding every year", "The business cannot cover its debt payments at all", "The business has no debt"]'::jsonb,
   'The business generates about 17% more operating income than it needs to cover all its scheduled debt payments',
   3, 'hard', 'multiple_choice', null, 1,
   'Case study: Community Bakery Co. is applying for a $150,000 small-business loan. Its net operating income available for debt service is $42,000/year. It already has $6,000/year in existing debt service, and the new loan would add $30,000/year.'),

  ('00000000-0000-0000-0005-000000000203',
   'Many commercial lenders look for a minimum DSCR of roughly 1.20-1.25x as a cushion above the 1.0x break-even point. Given Community Bakery''s DSCR of 1.17, what does this suggest about the loan?',
   '["It falls just below many lenders'' typical comfort threshold and may be approved only with added conditions, a smaller loan amount, or additional collateral", "It comfortably exceeds every lender''s minimum requirement with room to spare", "DSCR is irrelevant once a business has any positive net income", "A DSCR below 2.0 always results in automatic loan denial"]'::jsonb,
   'It falls just below many lenders'' typical comfort threshold and may be approved only with added conditions, a smaller loan amount, or additional collateral',
   4, 'medium', 'multiple_choice', null, 1,
   'Case study: Community Bakery Co. is applying for a $150,000 small-business loan. Its net operating income available for debt service is $42,000/year. It already has $6,000/year in existing debt service, and the new loan would add $30,000/year.'),

  ('00000000-0000-0000-0005-000000000203',
   'Community Bakery''s DSCR of 1.17 is below the 1.20-1.25x cushion many lenders prefer. In 1-2 sentences, explain why a DSCR this close to 1.0 is risky even though it is technically above the break-even point.',
   '[]'::jsonb, '(graded via grading_keywords, not correct_answer)',
   5, 'hard', 'free_response',
   '["little cushion", "little margin", "no buffer", "bad month", "cash flow dip", "break even", "small drop", "margin for error"]'::jsonb, 1,
   'Case study: Community Bakery Co. is applying for a $150,000 small-business loan. Its net operating income available for debt service is $42,000/year. It already has $6,000/year in existing debt service, and the new loan would add $30,000/year.'),

  ('00000000-0000-0000-0005-000000000203',
   'In the "5 Cs of credit" framework, which "C" refers to the value of assets (e.g., equipment, property) pledged as security that the lender could seize if the business defaults?',
   '["Collateral", "Capacity", "Character", "Capital"]'::jsonb,
   'Collateral',
   6, 'medium', 'multiple_choice', null, 1,
   'Case study: Community Bakery Co. is applying for a $150,000 small-business loan. Its net operating income available for debt service is $42,000/year. It already has $6,000/year in existing debt service, and the new loan would add $30,000/year.'),

  ('00000000-0000-0000-0005-000000000203',
   'Beyond the DSCR number, name one qualitative factor from the 5 Cs framework a loan officer should investigate before approving Community Bakery''s loan, and briefly explain why it matters.',
   '[]'::jsonb, '(graded via grading_keywords, not correct_answer)',
   7, 'hard', 'free_response',
   '["character", "capital", "conditions", "collateral", "credit history", "industry conditions", "owner equity", "economic conditions"]'::jsonb, 1,
   'Case study: Community Bakery Co. is applying for a $150,000 small-business loan. Its net operating income available for debt service is $42,000/year. It already has $6,000/year in existing debt service, and the new loan would add $30,000/year.');

-- ===================== Job-Ready: DCF valuation technical interview =====================
-- A DCF walkthrough case, the kind of technical-interview prompt this
-- skill's lesson already covers. Framework: standard discounted cash flow
-- valuation via the Gordon Growth (perpetuity) terminal value formula and
-- WACC as the discount rate -- general corporate finance methodology, not
-- sourced from any specific interview-prep course.

insert into quiz_questions (quiz_id, question, options, correct_answer, order_index, difficulty, question_type, grading_keywords, min_keyword_matches, scenario_context) values
  ('00000000-0000-0000-0005-000000000204',
   'In a DCF valuation, what does WACC represent?',
   '["The weighted average cost of capital: a blended required rate of return across the company''s debt and equity holders, used as the discount rate", "The company''s total annual revenue growth rate", "The tax rate applied to net income only", "The company''s current stock price divided by its earnings per share"]'::jsonb,
   'The weighted average cost of capital: a blended required rate of return across the company''s debt and equity holders, used as the discount rate',
   1, 'medium', 'multiple_choice', null, 1,
   'Case study: In a technical interview, you are asked to walk through a simplified DCF. The company''s final explicit-year free cash flow (FCF) is $24M, expected to grow at a 2% terminal rate forever after, discounted at a 10% WACC.'),

  ('00000000-0000-0000-0005-000000000204',
   'Using the Gordon Growth terminal value formula, TV = FCF_next / (WACC - g). If the final explicit-year FCF is $24M, terminal growth is 2%, and WACC is 10%, what is the terminal value (approximately)?',
   '["$306M", "$240M", "$480M", "$24M"]'::jsonb,
   '$306M',
   2, 'hard', 'multiple_choice', null, 1,
   'Case study: In a technical interview, you are asked to walk through a simplified DCF. The company''s final explicit-year free cash flow (FCF) is $24M, expected to grow at a 2% terminal rate forever after, discounted at a 10% WACC.'),

  ('00000000-0000-0000-0005-000000000204',
   'Why must the terminal value be discounted back to present value rather than added directly to the sum of explicit-period cash flows?',
   '["Because it represents a value calculated as of a future year, and must be converted to today''s dollars using the same time-value-of-money discounting applied to every other projected cash flow", "Because terminal value is always overstated and needs correcting", "Because terminal value only applies to companies with negative cash flow", "Discounting the terminal value is optional and rarely done in practice"]'::jsonb,
   'Because it represents a value calculated as of a future year, and must be converted to today''s dollars using the same time-value-of-money discounting applied to every other projected cash flow',
   3, 'medium', 'multiple_choice', null, 1,
   'Case study: In a technical interview, you are asked to walk through a simplified DCF. The company''s final explicit-year free cash flow (FCF) is $24M, expected to grow at a 2% terminal rate forever after, discounted at a 10% WACC.'),

  ('00000000-0000-0000-0005-000000000204',
   'If the company''s WACC increases (for example, due to higher perceived business risk), what happens to its DCF valuation, all else equal?',
   '["The valuation decreases, since future cash flows are discounted more heavily", "The valuation increases, since a higher discount rate always raises present value", "The valuation is unaffected by the discount rate", "Only the terminal value changes; explicit-period cash flows are unaffected by WACC"]'::jsonb,
   'The valuation decreases, since future cash flows are discounted more heavily',
   4, 'medium', 'multiple_choice', null, 1,
   'Case study: In a technical interview, you are asked to walk through a simplified DCF. The company''s final explicit-year free cash flow (FCF) is $24M, expected to grow at a 2% terminal rate forever after, discounted at a 10% WACC.'),

  ('00000000-0000-0000-0005-000000000204',
   'In 1-2 sentences, explain why a small change in the terminal growth rate assumption (e.g., 2% vs. 3%) can have an outsized effect on a DCF valuation compared to changing a single explicit year''s FCF forecast.',
   '[]'::jsonb, '(graded via grading_keywords, not correct_answer)',
   5, 'hard', 'free_response',
   '["terminal value", "majority of value", "most of the valuation", "large share", "sensitive", "denominator", "compounds"]'::jsonb, 1,
   'Case study: In a technical interview, you are asked to walk through a simplified DCF. The company''s final explicit-year free cash flow (FCF) is $24M, expected to grow at a 2% terminal rate forever after, discounted at a 10% WACC.'),

  ('00000000-0000-0000-0005-000000000204',
   'Which of these is NOT typically a direct input to calculating WACC?',
   '["The company''s expected long-run inflation rate", "The after-tax cost of debt", "The cost of equity", "The company''s weights of debt vs. equity in its capital structure"]'::jsonb,
   'The company''s expected long-run inflation rate',
   6, 'medium', 'multiple_choice', null, 1,
   'Case study: In a technical interview, you are asked to walk through a simplified DCF. The company''s final explicit-year free cash flow (FCF) is $24M, expected to grow at a 2% terminal rate forever after, discounted at a 10% WACC.'),

  ('00000000-0000-0000-0005-000000000204',
   'An interviewer asks: "Walk me through, at a high level, how you''d estimate a company''s cost of equity for a WACC calculation." In 1-2 sentences, name the standard approach and its key inputs.',
   '[]'::jsonb, '(graded via grading_keywords, not correct_answer)',
   7, 'hard', 'free_response',
   '["CAPM", "capital asset pricing model", "risk-free rate", "beta", "equity risk premium", "market risk premium"]'::jsonb, 1,
   'Case study: In a technical interview, you are asked to walk through a simplified DCF. The company''s final explicit-year free cash flow (FCF) is $24M, expected to grow at a 2% terminal rate forever after, discounted at a 10% WACC.');

-- ===================== Job-Ready: workplace ethics & compliance =====================
-- A material-non-public-information (insider trading) scenario. Framework:
-- general securities-compliance principles around trading/tipping on
-- material non-public information (the concepts underlying prohibitions
-- such as U.S. Rule 10b-5) -- not sourced from any firm's specific
-- proprietary compliance training.

insert into quiz_questions (quiz_id, question, options, correct_answer, order_index, difficulty, question_type, grading_keywords, min_keyword_matches, scenario_context) values
  ('00000000-0000-0000-0005-000000000205',
   'What should the analyst do first after hearing this?',
   '["Refrain from trading the stock or sharing the tip, and consult compliance/legal before taking any further action", "Quietly sell the firm''s position in that stock before the announcement", "Tell a few trusted colleagues so they can also avoid losses", "Wait a day or two, then trade based on it since some time will have passed"]'::jsonb,
   'Refrain from trading the stock or sharing the tip, and consult compliance/legal before taking any further action',
   1, 'medium', 'multiple_choice', null, 1,
   'Case study: You are a junior analyst at an investment firm. Two days before your firm publicly announces disappointing earnings for a portfolio holding, a close friend who works at that company mentions in casual conversation, "this quarter is going to be really bad" -- information that is not yet public.'),

  ('00000000-0000-0000-0005-000000000205',
   'What is this scenario a textbook example of?',
   '["Insider trading: possessing and potentially acting on material non-public information (MNPI)", "Standard market research", "A routine compliance-approved data source", "Public information already reflected in the stock price"]'::jsonb,
   'Insider trading: possessing and potentially acting on material non-public information (MNPI)',
   2, 'easy', 'multiple_choice', null, 1,
   'Case study: You are a junior analyst at an investment firm. Two days before your firm publicly announces disappointing earnings for a portfolio holding, a close friend who works at that company mentions in casual conversation, "this quarter is going to be really bad" -- information that is not yet public.'),

  ('00000000-0000-0000-0005-000000000205',
   'Why is trading on this tip prohibited even though the analyst did not ask for the information?',
   '["Knowingly receiving and acting on material non-public information is prohibited regardless of how it was obtained, as long as it was disclosed in breach of a duty of trust or confidence", "It is only illegal if the analyst explicitly requested the information in writing", "It is only illegal if the trade results in a large profit", "It is not actually prohibited if the source is a personal friend rather than a colleague"]'::jsonb,
   'Knowingly receiving and acting on material non-public information is prohibited regardless of how it was obtained, as long as it was disclosed in breach of a duty of trust or confidence',
   3, 'medium', 'multiple_choice', null, 1,
   'Case study: You are a junior analyst at an investment firm. Two days before your firm publicly announces disappointing earnings for a portfolio holding, a close friend who works at that company mentions in casual conversation, "this quarter is going to be really bad" -- information that is not yet public.'),

  ('00000000-0000-0000-0005-000000000205',
   'What is generally the best first internal step for reporting a situation like this at most firms?',
   '["Notify compliance or legal promptly, per the firm''s code of conduct", "Handle it privately and mention it only if directly asked later", "Post about it in a public team channel for transparency", "Ignore it since no trade has happened yet"]'::jsonb,
   'Notify compliance or legal promptly, per the firm''s code of conduct',
   4, 'medium', 'multiple_choice', null, 1,
   'Case study: You are a junior analyst at an investment firm. Two days before your firm publicly announces disappointing earnings for a portfolio holding, a close friend who works at that company mentions in casual conversation, "this quarter is going to be really bad" -- information that is not yet public.'),

  ('00000000-0000-0000-0005-000000000205',
   'In 1-2 sentences, explain why "I didn''t ask for the information, my friend just volunteered it" is not a valid defense against insider-trading rules.',
   '[]'::jsonb, '(graded via grading_keywords, not correct_answer)',
   5, 'hard', 'free_response',
   '["duty", "breach", "doesn''t matter how", "knowingly", "material nonpublic", "still prohibited", "obtained it", "regardless"]'::jsonb, 1,
   'Case study: You are a junior analyst at an investment firm. Two days before your firm publicly announces disappointing earnings for a portfolio holding, a close friend who works at that company mentions in casual conversation, "this quarter is going to be really bad" -- information that is not yet public.'),

  ('00000000-0000-0000-0005-000000000205',
   'Besides not trading on the tip herself, what else should the analyst avoid doing with this information?',
   '["Sharing or ''tipping'' it to others, since passing along material non-public information can also create liability for both parties", "Documenting the date she heard it", "Declining future casual conversations with the friend entirely", "Reporting it to compliance"]'::jsonb,
   'Sharing or ''tipping'' it to others, since passing along material non-public information can also create liability for both parties',
   6, 'medium', 'multiple_choice', null, 1,
   'Case study: You are a junior analyst at an investment firm. Two days before your firm publicly announces disappointing earnings for a portfolio holding, a close friend who works at that company mentions in casual conversation, "this quarter is going to be really bad" -- information that is not yet public.'),

  ('00000000-0000-0000-0005-000000000205',
   'Name one general workplace practice firms use to reduce the risk of employees acting on non-public information they hear through personal relationships (e.g., friends or family at other companies).',
   '[]'::jsonb, '(graded via grading_keywords, not correct_answer)',
   7, 'hard', 'free_response',
   '["disclosure", "conflict of interest", "restricted list", "blackout period", "pre-clearance", "compliance training", "outside relationships", "reporting"]'::jsonb, 1,
   'Case study: You are a junior analyst at an investment firm. Two days before your firm publicly announces disappointing earnings for a portfolio holding, a close friend who works at that company mentions in casual conversation, "this quarter is going to be really bad" -- information that is not yet public.');
