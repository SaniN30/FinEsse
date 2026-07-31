-- Content depth pass 3 ("capstone" skills): adds one more skill at the top
-- of each tier's chain, closing the gaps left after migrations 27-30 raised
-- the depth bar. All content below is written originally for this project;
-- topics and reasoning patterns are grounded in how real bank training
-- programs, CFA-style curricula, and finance interview prep are structured,
-- but no text is copied from any publisher, business school, or bank's
-- copyrighted material.
--
-- Chains off the most advanced skill already seeded in each tier:
--   School:    007 chains off 006 (budgeting-basics)
--   College:   108 chains off 107 (portfolio-construction-basics)
--   Job-Ready: 207 chains off 206 (ethics-and-compliance-basics)
-- New modeling exercise (WACC, multi-step) goes on College's new
-- capital-structure-and-wacc skill -- School has no modeling_exercises
-- concept; Job-Ready's new skill is behavioral (no numeric rubric fits it).
--
-- Gap this migration closes: School had no banking-mechanics-vs-inflation
-- lesson (interest rates were only covered from the borrower/saver math
-- side in compound-interest-basics, never against purchasing power);
-- College had valuation (comps/DCF) and statement analysis but no
-- capital-structure/cost-of-capital content, a core College-tier topic;
-- Job-Ready had STAR fundamentals but no coverage of the specific
-- behavioral categories (leadership, failure, conflict) real interviews
-- draw from, or of reflecting on a failure without undermining the story.

-- ===================== School: 007 =====================

insert into skills (id, tier, slug, title, prerequisite_skill_id, mastery_threshold) values
  ('00000000-0000-0000-0001-000000000007', 'school', 'banking-and-inflation-basics', 'Banking & Inflation',
    '00000000-0000-0000-0001-000000000006', 0.8);

insert into lessons (id, skill_id, content_type, content_body, order_index) values
  ('00000000-0000-0000-0002-000000000007', '00000000-0000-0000-0001-000000000007', 'article',
   'A bank savings account pays you interest for keeping your money there, because the bank lends that money out to others and shares some of what it earns. The rate a bank advertises is usually an annual percentage -- but "annual" doesn''t mean you only see the effect after a full year passes; most accounts add interest more often (monthly is common), and once added, that interest itself starts earning more interest, the same compounding idea from the earlier lesson on borrowing and saving.

There is a second force acting on your money at the same time: inflation, the general rise in prices over time, which means a pound today buys slightly less a year from now than it does today. This is why the interest rate alone does not tell you whether your savings are actually getting more valuable -- what matters is the "real" return: your interest rate minus the inflation rate. If your savings account pays 3% but prices are rising 5% a year, your money grows in pounds but shrinks in what it can actually buy -- a real return of roughly -2%.

Worked example: Leah has £500 in a savings account paying 3% interest a year, and inflation that year runs at 5%. In pounds, her balance grows to £500 x 1.03 = £515 -- more money than she started with. But if the same basket of goods that cost £500 at the start of the year now costs £500 x 1.05 = £525, her £515 no longer buys that whole basket -- she is £10 short. Her real return was roughly 3% - 5% = -2%: more pounds, but less actual buying power.

Recap: bank interest grows the number of pounds you have, usually compounding more often than once a year; inflation shrinks what each pound can buy. A savings rate only truly grows your wealth if it beats inflation -- the "real return" (interest rate minus inflation rate) is what actually tells you whether saving in that account is keeping up with, losing to, or beating rising prices.',
   1);

insert into quizzes (id, skill_id, lesson_id, title, pass_threshold) values
  ('00000000-0000-0000-0003-000000000007', '00000000-0000-0000-0001-000000000007', '00000000-0000-0000-0002-000000000007', 'Banking & Inflation Quiz', 0.8);

insert into quiz_questions (quiz_id, question, options, correct_answer, order_index) values
  ('00000000-0000-0000-0003-000000000007', 'What is inflation, as described in the lesson?',
    '["A bank fee charged on savings accounts", "The general rise in prices over time, which reduces what a pound can buy", "A type of compound interest paid only to businesses", "A tax applied to interest earned"]'::jsonb,
    'The general rise in prices over time, which reduces what a pound can buy', 1),
  ('00000000-0000-0000-0003-000000000007', 'Leah''s savings grow from £500 to £515 (3% interest) while prices rise from £500 to £525 (5% inflation) for the same basket of goods. What does this show?',
    '["Her buying power increased, since she has more pounds", "She has more pounds but cannot afford the same basket of goods -- her real return was negative", "Inflation and interest always cancel out exactly", "Her savings account made a mistake"]'::jsonb,
    'She has more pounds but cannot afford the same basket of goods -- her real return was negative', 2),
  ('00000000-0000-0000-0003-000000000007', 'How is "real return" calculated, per the lesson?',
    '["Interest rate plus inflation rate", "Interest rate minus inflation rate", "Inflation rate minus interest rate", "Interest rate multiplied by inflation rate"]'::jsonb,
    'Interest rate minus inflation rate', 3),
  ('00000000-0000-0000-0003-000000000007', 'A savings account pays 4% and inflation is 1% that year. What is the approximate real return, and what does it mean?',
    '["-3%, savings are losing buying power", "+3%, savings are gaining buying power, not just more pounds", "+5%, real return is always the sum", "0%, interest and inflation always offset"]'::jsonb,
    '+3%, savings are gaining buying power, not just more pounds', 4),
  ('00000000-0000-0000-0003-000000000007', 'Why does interest compounding more often than once a year (e.g. monthly) matter, per the lesson?',
    '["It doesn''t -- annual and monthly compounding always give identical totals", "Interest added each month starts earning its own interest sooner, the same compounding effect as the earlier borrowing/saving lesson", "Monthly compounding always uses a different, unrelated formula", "It only matters for loans, never for savings accounts"]'::jsonb,
    'Interest added each month starts earning its own interest sooner, the same compounding effect as the earlier borrowing/saving lesson', 5),
  ('00000000-0000-0000-0003-000000000007', 'Why can a savings account with a "positive" interest rate still be a bad place to keep money long-term?',
    '["Positive interest rates are always bad by definition", "If inflation is consistently higher than the interest rate, the real return stays negative and buying power keeps shrinking", "Banks are required to charge fees that exceed all interest paid", "It can never be a bad idea as long as the rate is positive"]'::jsonb,
    'If inflation is consistently higher than the interest rate, the real return stays negative and buying power keeps shrinking', 6);

-- ===================== College: 108 =====================

insert into skills (id, tier, slug, title, prerequisite_skill_id, mastery_threshold) values
  ('00000000-0000-0000-0001-000000000108', 'college', 'capital-structure-and-wacc', 'Capital Structure & Cost of Capital',
    '00000000-0000-0000-0001-000000000107', 0.8);

insert into lessons (id, skill_id, content_type, content_body, order_index) values
  ('00000000-0000-0000-0002-000000000108', '00000000-0000-0000-0001-000000000108', 'article',
   'Every company is financed by some mix of debt (borrowed money that must be repaid with interest) and equity (ownership stakes, with no fixed repayment but no guaranteed return either) -- that mix is its capital structure. Debt is usually the "cheaper" source of financing because interest payments are tax-deductible and lenders take less risk than equity holders (lenders get paid before equity holders in a bankruptcy), but relying on too much debt raises the risk of default if the company can''t make its payments, which is why real companies target a deliberate balance rather than maximizing either source alone.

Because a company uses more than one source of financing, valuing it (in a DCF, for instance) requires a discount rate that reflects the blended cost of all of it -- not just debt, and not just equity. This blended rate is the weighted average cost of capital (WACC): the cost of debt and the cost of equity, each weighted by how much of the company''s financing they represent, with the cost of debt reduced for its tax benefit. Cost of debt is usually observable directly (the interest rate the company actually pays on its borrowing); cost of equity is estimated, commonly using the Capital Asset Pricing Model (CAPM): cost of equity = risk-free rate + beta x equity risk premium, where beta measures how much a stock swings relative to the overall market, and the equity risk premium is the extra return investors demand for holding stocks over a "safe" government bond.

Worked example: a company is financed 40% by debt and 60% by equity. Its cost of debt is 6%, and the corporate tax rate is 25%, so its after-tax cost of debt = 6% x (1 - 0.25) = 4.5%. Its cost of equity, estimated via CAPM with a 3% risk-free rate, a beta of 1.2, and a 6% equity risk premium, is 3% + (1.2 x 6%) = 10.2%. WACC = (weight of debt x after-tax cost of debt) + (weight of equity x cost of equity) = (0.40 x 4.5%) + (0.60 x 10.2%) = 1.8% + 6.12% = 7.92%. That 7.92% is the discount rate this company should use to evaluate its own future cash flows -- a project or valuation using a materially different discount rate is implicitly assuming a different, wrong capital structure or risk level for the company.

Recap: capital structure is the mix of debt and equity financing a company uses; debt is cheaper per pound (tax-deductible interest, lower risk to the lender) but riskier in aggregate if overused. WACC blends the after-tax cost of debt and the cost of equity (often estimated via CAPM), weighted by how much of the company each source finances -- it is the correct discount rate for valuing that specific company''s own cash flows, because it reflects the actual blended cost of the capital funding them.',
   1);

insert into quizzes (id, skill_id, lesson_id, title, pass_threshold) values
  ('00000000-0000-0000-0003-000000000108', '00000000-0000-0000-0001-000000000108', '00000000-0000-0000-0002-000000000108', 'Capital Structure & Cost of Capital Quiz', 0.8);

insert into quiz_questions (quiz_id, question, options, correct_answer, order_index) values
  ('00000000-0000-0000-0003-000000000108', 'Why is debt usually considered a "cheaper" source of financing than equity, per the lesson?',
    '["Debt never has to be repaid", "Interest payments are tax-deductible and lenders take less risk than equity holders, so they demand a lower return", "Equity holders are always paid before lenders in a bankruptcy", "Debt has no cost at all"]'::jsonb,
    'Interest payments are tax-deductible and lenders take less risk than equity holders, so they demand a lower return', 1),
  ('00000000-0000-0000-0003-000000000108', 'A company has a 6% cost of debt and a 25% tax rate. What is its after-tax cost of debt?',
    '["6%", "4.5%", "1.5%", "7.5%"]'::jsonb,
    '4.5%', 2),
  ('00000000-0000-0000-0003-000000000108', 'Using CAPM with a 3% risk-free rate, a beta of 1.2, and a 6% equity risk premium, what is the estimated cost of equity?',
    '["9%", "10.2%", "7.2%", "3.6%"]'::jsonb,
    '10.2%', 3),
  ('00000000-0000-0000-0003-000000000108', 'A company is 40% debt (4.5% after-tax cost) and 60% equity (10.2% cost). What is its WACC?',
    '["7.35%", "7.92%", "14.7%", "6.12%"]'::jsonb,
    '7.92%', 4),
  ('00000000-0000-0000-0003-000000000108', 'Why is WACC, rather than just the cost of debt or just the cost of equity, the correct discount rate for valuing a company''s own cash flows?',
    '["Because it is always the lowest of the two, which is convenient", "Because it reflects the actual blended cost of all the capital funding the company, weighted by how much each source represents", "Because regulations require using only WACC", "Because cost of debt and cost of equity are always identical in practice"]'::jsonb,
    'Because it reflects the actual blended cost of all the capital funding the company, weighted by how much each source represents', 5),
  ('00000000-0000-0000-0003-000000000108', 'Why doesn''t a company simply finance itself entirely with debt, given that debt is usually cheaper per pound?',
    '["Debt is illegal above a certain amount", "Relying on too much debt raises the risk of default if the company can''t make its payments", "Equity is always cheaper once a company is large enough", "Lenders refuse to lend to companies that already have any debt"]'::jsonb,
    'Relying on too much debt raises the risk of default if the company can''t make its payments', 6);

-- Case-style modeling exercise: multi-step WACC build for Capital Structure & Cost of Capital.
insert into modeling_exercises (id, skill_id, title, instructions, rubric, pass_threshold) values
  ('00000000-0000-0000-0004-000000000005', '00000000-0000-0000-0001-000000000108',
   'Calculate a Company''s WACC',
   'A company is financed 30% by debt and 70% by equity. Its cost of debt is 8%, and the corporate tax rate is 20%. Its cost of equity, estimated via CAPM, uses a 2.5% risk-free rate, a beta of 1.4, and a 5.5% equity risk premium. Working step by step, calculate: (1) the after-tax cost of debt (cost of debt x (1 - tax rate)), (2) the cost of equity via CAPM (risk-free rate + beta x equity risk premium), (3) the WACC (weight of debt x after-tax cost of debt, plus weight of equity x cost of equity). Submit percentages as numbers (e.g. 6.4 for 6.4%) in {"after_tax_cost_of_debt": <number>, "cost_of_equity": <number>, "wacc": <number>}.',
   '{
     "after_tax_cost_of_debt": {"expected": 6.4, "tolerance": 0.1},
     "cost_of_equity": {"expected": 10.2, "tolerance": 0.1},
     "wacc": {"expected": 9.06, "tolerance": 0.15}
   }'::jsonb,
   0.8);

-- ===================== Job-Ready: 207 =====================

insert into skills (id, tier, slug, title, prerequisite_skill_id, mastery_threshold) values
  ('00000000-0000-0000-0001-000000000207', 'job_ready', 'advanced-behavioral-interviews', 'Advanced Behavioral: Leadership, Failure & Conflict',
    '00000000-0000-0000-0001-000000000206', 0.8);

insert into lessons (id, skill_id, content_type, content_body, order_index) values
  ('00000000-0000-0000-0002-000000000207', '00000000-0000-0000-0001-000000000207', 'article',
   'Resume & Behavioral Basics covered STAR as a general structure. Real interviews draw from a smaller set of recurring behavioral categories, and each one is actually testing something slightly different -- treating them all as "just tell a STAR story" misses what the interviewer is really evaluating. Three categories come up constantly: leadership ("tell me about a time you led something"), which tests whether you can organize others and take ownership of an outcome, not whether you held a formal title; conflict ("tell me about a disagreement with a colleague"), which tests whether you can resolve tension productively without becoming either a pushover or combative; and failure ("tell me about a time you failed"), which tests self-awareness and whether you actually learn from mistakes, not whether you can find a "failure" that is secretly a humblebrag.

Failure questions are the ones candidates most often answer badly, in one of two ways: picking a fake failure that is really a disguised strength ("I work too hard"), which reads as evasive; or picking a real failure but stopping at the mistake itself without showing what changed afterward, which reads as someone who doesn''t learn. The fix is a small addition to STAR for this category specifically -- sometimes called STARL: Situation, Task, Action, Result, and Learning, where the Learning line states concretely what you do differently now because of that failure. Naming a genuine mistake and a genuine behavior change is far stronger than either extreme.

Worked example -- "Tell me about a time you failed." A weak answer: "I once missed a deadline because I''m such a perfectionist." (A disguised strength -- evasive, not credible.) A strong answer: "I was leading a 3-person group project and assumed everyone understood their part after one group chat message, without checking in. Two days before the deadline, I found out one teammate had misunderstood their section and hadn''t started. We missed our internal checkpoint and had to pull two late nights to finish, and the final grade was solid but not what it could have been. Since then, on every group project I explicitly ask each person to restate their part back to me after we divide up work, and I check in at the halfway point rather than assuming things are on track -- that one habit change has prevented the same problem twice since." This names a real mistake (assuming instead of confirming), a real consequence (late nights, a grade that suffered), and a specific, still-in-use behavior change -- exactly the self-awareness a failure question is testing for.

Recap: leadership, conflict, and failure questions each test something distinct beneath the shared STAR shape -- ownership of an outcome, productive resolution of tension, and genuine self-awareness, respectively. For failure questions specifically, extend STAR to STARL: name a real mistake, its real consequence, and a concrete, ongoing behavior change -- avoiding both the disguised-strength dodge and a story that ends at the mistake with no evidence of learning.',
   1);

insert into quizzes (id, skill_id, lesson_id, title, pass_threshold) values
  ('00000000-0000-0000-0003-000000000207', '00000000-0000-0000-0001-000000000207', '00000000-0000-0000-0002-000000000207', 'Advanced Behavioral Interviews Quiz', 0.8);

insert into quiz_questions (quiz_id, question, options, correct_answer, order_index) values
  ('00000000-0000-0000-0003-000000000207', 'What does a leadership behavioral question primarily test, per the lesson?',
    '["Whether you have ever held a formal management title", "Whether you can organize others and take ownership of an outcome", "How many people reported to you", "Whether you prefer working alone"]'::jsonb,
    'Whether you can organize others and take ownership of an outcome', 1),
  ('00000000-0000-0000-0003-000000000207', 'Why does answering "I work too hard" to a failure question read as evasive?',
    '["It is too specific a story", "It is a disguised strength, not a genuine failure, so it avoids the actual question", "It is factually impossible to be a failure", "Interviewers are not allowed to ask about failure"]'::jsonb,
    'It is a disguised strength, not a genuine failure, so it avoids the actual question', 2),
  ('00000000-0000-0000-0003-000000000207', 'What does the "L" add to STAR in the STARL structure recommended for failure questions?',
    '["A second, longer result", "A concrete statement of what you do differently now because of that failure", "A list of everyone else involved", "A restatement of the original situation"]'::jsonb,
    'A concrete statement of what you do differently now because of that failure', 3),
  ('00000000-0000-0000-0003-000000000207', 'In the worked example, what was the actual mistake the candidate identifies (not just the outcome)?',
    '["Missing the final deadline entirely", "Assuming teammates understood their part after one message, without checking in", "Choosing the wrong group project topic", "Working too many late nights"]'::jsonb,
    'Assuming teammates understood their part after one message, without checking in', 4),
  ('00000000-0000-0000-0003-000000000207', 'Why is a failure story that stops at describing the mistake, with no mention of what changed afterward, considered weak?',
    '["Because it is too short in general", "Because it reads as someone who doesn''t learn from mistakes, which is what the question is actually testing", "Because interviewers require a minimum word count", "Because it should instead be a leadership story"]'::jsonb,
    'Because it reads as someone who doesn''t learn from mistakes, which is what the question is actually testing', 5),
  ('00000000-0000-0000-0003-000000000207', 'What is a conflict behavioral question primarily testing, per the lesson?',
    '["Whether you avoid all disagreement entirely", "Whether you can resolve tension productively without becoming a pushover or combative", "Whether you always win the disagreement", "Whether you have ever argued with a manager"]'::jsonb,
    'Whether you can resolve tension productively without becoming a pushover or combative', 6);
