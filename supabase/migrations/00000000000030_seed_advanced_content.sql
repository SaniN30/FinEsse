-- Content depth pass 2: adds new skills (not just longer copies of existing
-- ones) across all three tiers, closer to real finance-industry training
-- material in topic coverage and difficulty progression. All content below
-- is written originally for this project -- topics and reasoning patterns
-- are grounded in how real case studies/interview prep/bank training
-- programs are structured, but no text is copied from any publisher,
-- business school, or bank's copyrighted material.
--
-- Chains off the most advanced skill already seeded in each tier (same
-- pattern 00000000000016/00000000000029 used):
--   School:    5-6 chain off 4 (earning-pocket-money)
--   College:   105-107 chain off 104 (financial-statement-modeling)
--   Job-Ready: 204-206 chain off 203 (case-method-basics)
-- New modeling exercises (case-style, multi-step) go on College's
-- credit-risk-basics (106) and Job-Ready's market-sizing-case-interviews
-- (205) -- School has no modeling_exercises concept, and College/Job-Ready
-- already had one each from prior migrations.

-- ===================== School: 5-6 =====================

insert into skills (id, tier, slug, title, prerequisite_skill_id, mastery_threshold) values
  ('00000000-0000-0000-0001-000000000005', 'school', 'compound-interest-basics', 'Compound Interest & Borrowing',
    '00000000-0000-0000-0001-000000000004', 0.8),
  ('00000000-0000-0000-0001-000000000006', 'school', 'budgeting-basics', 'Budgeting Basics',
    '00000000-0000-0000-0001-000000000005', 0.8);

insert into lessons (id, skill_id, content_type, content_body, order_index) values
  ('00000000-0000-0000-0002-000000000005', '00000000-0000-0000-0001-000000000005', 'article',
   'Interest is the cost of borrowing money, or the reward for saving it. Simple interest is calculated only on the original amount (the "principal"); compound interest is calculated on the principal plus any interest already earned or owed, so it grows faster over time -- the longer money compounds, the bigger the gap between simple and compound versions of the same rate becomes.

This matters in two directions you will run into directly: saving and borrowing. When you save money in an account that pays compound interest, your balance grows faster the longer you leave it untouched, because each year''s interest starts earning interest of its own. When you borrow money (a loan, or an unpaid credit card balance) at compound interest, the amount you owe grows the same way if you don''t pay it down -- which is why credit card debt left unpaid can grow surprisingly fast.

Worked example: you save £100 at 10% annual compound interest. Year 1: £100 x 1.10 = £110. Year 2: £110 x 1.10 = £121 (not £120 -- interest was earned on the £10 of year-1 interest too, not just the original £100). Year 3: £121 x 1.10 = £133.10. Over 3 years, compound interest earned £33.10 versus simple interest''s flat £30 (3 x £10) -- a small gap here, but one that grows much larger over longer time periods or higher rates.

Recap: compound interest is calculated on principal plus already-accumulated interest, so amounts grow faster than simple interest over time -- a powerful effect working for you when saving early and consistently, and an equally powerful effect working against you if debt is left to compound unpaid.',
   1),
  ('00000000-0000-0000-0002-000000000006', '00000000-0000-0000-0001-000000000006', 'article',
   'A budget is a plan for how money coming in (income) will be allocated across money going out (expenses and savings) over a period of time, usually a month. The most basic budgeting skill is simply tracking where money already goes before trying to change anything -- most people are surprised by how much they spend on small, frequent purchases once they actually track it.

A common beginner framework splits income into three broad categories: needs (expenses you must pay, like transport or phone credit), wants (optional spending that improves quality of life but isn''t essential), and savings (money set aside for a future goal). There is no single "correct" percentage split -- a common starting guideline is roughly 50% needs, 30% wants, 20% savings -- but the discipline of assigning every pound a category before spending it, rather than spending until you run out, is what makes a budget useful.

Worked example: Amara gets £40 pocket money each month. Using a 50/30/20-style split: £20 goes to needs (bus fare, phone top-up), £12 goes to wants (going out with friends), and £8 goes to savings toward a bike she wants in 6 months. If Amara sticks to this, she will have £48 saved after 6 months (£8 x 6) -- visible progress instead of hoping there is "some left over" at the end of each month.

Recap: budgeting means assigning every unit of income a purpose (needs, wants, savings) before spending it, rather than spending freely and checking what is left. Tracking actual spending first, then applying a split like 50/30/20, turns a vague intention into a plan you can actually follow and adjust.',
   1);

insert into quizzes (id, skill_id, lesson_id, title, pass_threshold) values
  ('00000000-0000-0000-0003-000000000005', '00000000-0000-0000-0001-000000000005', '00000000-0000-0000-0002-000000000005', 'Compound Interest & Borrowing Quiz', 0.8),
  ('00000000-0000-0000-0003-000000000006', '00000000-0000-0000-0001-000000000006', '00000000-0000-0000-0002-000000000006', 'Budgeting Basics Quiz', 0.8);

insert into quiz_questions (quiz_id, question, options, correct_answer, order_index) values
  -- Compound Interest & Borrowing
  ('00000000-0000-0000-0003-000000000005', 'What is the key difference between simple interest and compound interest?',
    '["Simple interest only applies to loans, compound interest only to savings", "Compound interest is calculated on principal plus already-earned interest; simple interest is only calculated on the original principal", "They always produce the exact same result", "Simple interest is always higher"]'::jsonb,
    'Compound interest is calculated on principal plus already-earned interest; simple interest is only calculated on the original principal', 1),
  ('00000000-0000-0000-0003-000000000005', '£100 grows at 10% annual compound interest. What is the balance after year 2?',
    '["£120", "£121", "£110", "£200"]'::jsonb,
    '£121', 2),
  ('00000000-0000-0000-0003-000000000005', 'Why does £121 (not £120) make sense as the year-2 balance in the worked example?',
    '["Because interest was also earned on the £10 of year-1 interest, not just the original £100", "Because the interest rate doubled in year 2", "It is a rounding error and £120 is actually correct", "Because fees were added"]'::jsonb,
    'Because interest was also earned on the £10 of year-1 interest, not just the original £100', 3),
  ('00000000-0000-0000-0003-000000000005', 'Why can unpaid credit card debt grow surprisingly fast over time?',
    '["Credit cards only ever use simple interest, which is always small", "Compound interest is applied to the growing balance, so unpaid interest itself starts earning more interest", "Credit card debt does not accrue interest until year 5", "Interest is capped by law at a fixed small amount"]'::jsonb,
    'Compound interest is applied to the growing balance, so unpaid interest itself starts earning more interest', 4),
  ('00000000-0000-0000-0003-000000000005', 'Why does leaving savings untouched for longer make compound interest more powerful?',
    '["It doesn''t -- time has no effect on compound interest", "Each additional year lets previously-earned interest itself earn more interest, widening the gap versus simple interest", "Banks pay higher rates the longer you wait to withdraw", "Only the first year of interest ever compounds"]'::jsonb,
    'Each additional year lets previously-earned interest itself earn more interest, widening the gap versus simple interest', 5),
  ('00000000-0000-0000-0003-000000000005', 'Over 3 years at 10%, compound interest earned £33.10 on £100 versus simple interest''s flat £30. What does this gap illustrate?',
    '["Compound and simple interest are always identical over any period", "The compounding effect, though small over a short period, grows the longer money is left to compound", "Simple interest is always better for savers", "The gap only appears if the interest rate is above 50%"]'::jsonb,
    'The compounding effect, though small over a short period, grows the longer money is left to compound', 6),

  -- Budgeting Basics
  ('00000000-0000-0000-0003-000000000006', 'In the 50/30/20-style budgeting framework, what does the "20" typically represent?',
    '["Wants", "Needs", "Savings", "Taxes"]'::jsonb,
    'Savings', 1),
  ('00000000-0000-0000-0003-000000000006', 'What is the recommended first step before changing a budget, according to the lesson?',
    '["Immediately cut all discretionary spending to zero", "Track where money is actually currently going", "Borrow money to cover a shortfall", "Ask a bank to set the budget automatically"]'::jsonb,
    'Track where money is actually currently going', 2),
  ('00000000-0000-0000-0003-000000000006', 'Amara has £40/month and uses a 50/30/20 split. How much goes to wants?',
    '["£20", "£12", "£8", "£4"]'::jsonb,
    '£12', 3),
  ('00000000-0000-0000-0003-000000000006', 'Why does the lesson say there is no single "correct" needs/wants/savings percentage split?',
    '["Because budgeting itself is pointless", "Because the specific split matters less than the discipline of assigning every pound a category before spending", "Because only wealthy people need budgets", "Because percentages are illegal to use in personal finance"]'::jsonb,
    'Because the specific split matters less than the discipline of assigning every pound a category before spending', 4),
  ('00000000-0000-0000-0003-000000000006', 'Saving £8/month for 6 months toward a bike, how much will Amara have saved?',
    '["£40", "£48", "£8", "£56"]'::jsonb,
    '£48', 5),
  ('00000000-0000-0000-0003-000000000006', 'What is the main problem with "spending until you run out and seeing what''s left" instead of budgeting?',
    '["It is actually the same as budgeting", "It provides no plan or visible progress toward savings goals, since nothing is set aside deliberately", "It is illegal", "It guarantees you will overspend on needs specifically"]'::jsonb,
    'It provides no plan or visible progress toward savings goals, since nothing is set aside deliberately', 6);

-- ===================== College: 105-107 =====================

insert into skills (id, tier, slug, title, prerequisite_skill_id, mastery_threshold) values
  ('00000000-0000-0000-0001-000000000105', 'college', 'financial-statement-analysis', 'Financial Statement Analysis & Ratios',
    '00000000-0000-0000-0001-000000000104', 0.8),
  ('00000000-0000-0000-0001-000000000106', 'college', 'credit-risk-basics', 'Credit Risk Basics',
    '00000000-0000-0000-0001-000000000105', 0.8),
  ('00000000-0000-0000-0001-000000000107', 'college', 'portfolio-construction-basics', 'Portfolio Construction Basics',
    '00000000-0000-0000-0001-000000000106', 0.8);

insert into lessons (id, skill_id, content_type, content_body, order_index) values
  ('00000000-0000-0000-0002-000000000105', '00000000-0000-0000-0001-000000000105', 'article',
   'Beyond building the three statements, analysts constantly compare them using ratios -- standardized numbers that let you judge a company''s health without already needing to know whether "£50 million in debt" is a lot or a little for that specific company. Ratios turn raw statement figures into comparable signals across time (this year vs. last year) and across companies (this company vs. a competitor).

Three ratio families come up constantly: liquidity ratios (can the company pay its short-term bills? e.g. current ratio = current assets / current liabilities), profitability ratios (how much profit per pound of revenue or equity? e.g. net margin = net income / revenue, return on equity = net income / shareholders'' equity), and leverage ratios (how much of the company is financed by debt vs. equity? e.g. debt-to-equity = total debt / total equity). A single ratio in isolation rarely tells the whole story -- a low current ratio might mean real liquidity risk, or it might just be normal for that industry (a supermarket chain, which turns inventory into cash fast, typically runs a lower current ratio than a heavy manufacturer).

Worked example: Company A has current assets of £3,000,000 and current liabilities of £2,000,000 -- current ratio = 3,000,000 / 2,000,000 = 1.5. Its net income is £900,000 on revenue of £12,000,000 -- net margin = 900,000 / 12,000,000 = 7.5%. Its total debt is £4,000,000 against total equity of £5,000,000 -- debt-to-equity = 4,000,000 / 5,000,000 = 0.8. Read together: the company can comfortably cover short-term obligations (ratio above 1), runs a modest but real profit margin, and is financed somewhat more by equity than debt (ratio below 1) -- a reasonably healthy overall picture, though a real analyst would still compare each number against the company''s own history and its sector peers before concluding anything.

Recap: ratios convert raw financial-statement figures into comparable signals across liquidity, profitability, and leverage. No single ratio is meaningful alone -- it needs a benchmark (the company''s own trend over time, or comparable peers) to say whether a number is actually good, bad, or simply normal for that kind of business.',
   1),
  ('00000000-0000-0000-0002-000000000106', '00000000-0000-0000-0001-000000000106', 'article',
   'Credit risk is the risk that a borrower won''t repay what they owe -- whether that borrower is an individual, a company, or a government. Banks and bond investors price and manage this risk constantly, since lending money is only profitable if enough of it actually comes back with interest. The core judgment is: how likely is default (failure to repay), and if it happens, how much would actually be recovered?

Two ideas anchor most credit analysis. First, credit rating agencies assign letter-grade ratings (from roughly AAA, the safest, down through speculative "junk" grades) based on an issuer''s ability to repay -- a lower rating means the market perceives higher default risk, so investors demand a higher interest rate (a "spread") to compensate; this is why a struggling company''s bonds pay a noticeably higher yield than a stable government''s bonds of the same maturity. Second, lenders look beyond a single rating at underlying signals: cash flow relative to debt payments due (can the borrower actually cover what''s owed from operating cash, not just paper profit?), existing leverage (how much debt is already outstanding relative to assets or earnings?), and collateral (is any specific asset pledged that the lender could recover if default happens?).

Worked example: a lender is deciding between two corporate bonds paying different yields for the same 5-year maturity. Bond X (highly-rated, stable large company) yields 4%. Bond Y (lower-rated, smaller leveraged company) yields 9%. The 5-point yield gap ("spread") is compensation for Bond Y''s materially higher perceived default risk -- not free extra return. A lender who only sees "Bond Y pays more" without weighing the higher chance of losing principal is mispricing the actual risk being taken.

A common tool lenders use to check a borrower''s ability to service debt is the debt service coverage ratio (DSCR) = operating cash flow / total debt service (principal + interest due). A DSCR of 2.0 means the borrower generates twice the cash needed to cover this year''s debt payments -- comfortable headroom. A DSCR below 1.0 means the borrower cannot cover debt payments from operating cash alone, a serious warning sign lenders typically will not accept without other mitigants.

Recap: credit risk is about the probability a borrower defaults and how much would be recovered if it happened. Credit ratings summarize that risk, the extra yield ("spread") lower-rated borrowers must offer is compensation for taking on more of it, and DSCR is a concrete cash-flow-based check lenders use before extending credit -- a higher yield is not automatically a better deal once default risk is properly weighed.',
   1),
  ('00000000-0000-0000-0002-000000000107', '00000000-0000-0000-0001-000000000107', 'article',
   'Portfolio construction is about combining multiple investments so the whole portfolio behaves better than any single holding on its own -- mainly through diversification, which reduces risk without necessarily reducing expected return, as long as the assets don''t move in exactly the same way. The key idea is correlation: if two assets tend to rise and fall together (highly correlated), holding both barely reduces risk; if they tend to move somewhat independently or oppositely (low or negative correlation), holding both smooths out the portfolio''s overall swings, because a bad day for one is often offset by an average or good day for the other.

Two return/risk building blocks come up constantly: expected return (a weighted average of each holding''s expected return, weighted by how much of the portfolio it makes up) and risk, usually measured as volatility (how much returns bounce around over time). The point of diversification is that a portfolio''s expected return is just the weighted average of its parts, but a well-diversified portfolio''s volatility can be lower than that same weighted average, because the ups and downs of imperfectly-correlated assets partly cancel out.

Worked example: a portfolio is 60% in Stock A (expected return 10%, high volatility) and 40% in Bond B (expected return 4%, low volatility, low correlation with Stock A). Expected portfolio return = (0.60 x 10%) + (0.40 x 4%) = 6% + 1.6% = 7.6% -- a straightforward weighted average. But because Stock A and Bond B don''t move in lockstep, the portfolio''s actual volatility over time tends to be noticeably lower than a simple 60/40 weighted average of their individual volatilities would suggest -- the classic case for holding both asset classes rather than an all-stock or all-bond portfolio.

Recap: portfolio construction combines assets so the mix''s risk is lower than a simple average of the parts would suggest, as long as those assets aren''t perfectly correlated. Expected return is always a straightforward weighted average of the holdings; the benefit of diversification shows up specifically in reduced volatility, not in extra return.',
   1);

insert into quizzes (id, skill_id, lesson_id, title, pass_threshold) values
  ('00000000-0000-0000-0003-000000000105', '00000000-0000-0000-0001-000000000105', '00000000-0000-0000-0002-000000000105', 'Financial Statement Analysis & Ratios Quiz', 0.8),
  ('00000000-0000-0000-0003-000000000106', '00000000-0000-0000-0001-000000000106', '00000000-0000-0000-0002-000000000106', 'Credit Risk Basics Quiz', 0.8),
  ('00000000-0000-0000-0003-000000000107', '00000000-0000-0000-0001-000000000107', '00000000-0000-0000-0002-000000000107', 'Portfolio Construction Basics Quiz', 0.8);

insert into quiz_questions (quiz_id, question, options, correct_answer, order_index) values
  -- Financial Statement Analysis & Ratios
  ('00000000-0000-0000-0003-000000000105', 'A company has current assets of £3,000,000 and current liabilities of £2,000,000. What is its current ratio?',
    '["0.67", "1.0", "1.5", "3.0"]'::jsonb,
    '1.5', 1),
  ('00000000-0000-0000-0003-000000000105', 'What does a current ratio measure?',
    '["How profitable a company is", "Whether a company can pay its short-term bills with its short-term assets", "How much debt a company has relative to equity", "How fast a company''s stock price is moving"]'::jsonb,
    'Whether a company can pay its short-term bills with its short-term assets', 2),
  ('00000000-0000-0000-0003-000000000105', 'Why might a supermarket chain normally run a lower current ratio than a heavy manufacturer without that being a red flag?',
    '["Supermarkets are legally required to run low ratios", "Supermarkets turn inventory into cash quickly, so a lower ratio can be normal for that business model, not necessarily risky", "Manufacturers never carry any liabilities", "Current ratio does not apply to retail businesses"]'::jsonb,
    'Supermarkets turn inventory into cash quickly, so a lower ratio can be normal for that business model, not necessarily risky', 3),
  ('00000000-0000-0000-0003-000000000105', 'Net income is £900,000 on revenue of £12,000,000. What is the net margin?',
    '["1.33%", "7.5%", "13.3%", "75%"]'::jsonb,
    '7.5%', 4),
  ('00000000-0000-0000-0003-000000000105', 'A company has total debt of £4,000,000 and total equity of £5,000,000. What does its debt-to-equity ratio of 0.8 indicate?',
    '["The company has no debt at all", "The company is financed somewhat more by equity than by debt", "The company is financed entirely by debt", "The ratio cannot be interpreted without knowing revenue"]'::jsonb,
    'The company is financed somewhat more by equity than by debt', 5),
  ('00000000-0000-0000-0003-000000000105', 'Why is a single ratio, viewed in isolation, rarely enough to judge a company''s health?',
    '["Ratios are only ever calculated once per company''s lifetime", "A ratio needs a benchmark -- the company''s own trend over time or comparable peers -- to say whether the number is actually good, bad, or normal", "Ratios are always inaccurate by design", "Only liquidity ratios are ever useful"]'::jsonb,
    'A ratio needs a benchmark -- the company''s own trend over time or comparable peers -- to say whether the number is actually good, bad, or normal', 6),

  -- Credit Risk Basics
  ('00000000-0000-0000-0003-000000000106', 'What does credit risk primarily measure?',
    '["How fast a stock price moves", "The risk that a borrower will fail to repay what they owe", "The tax rate applied to interest income", "How liquid a secondary market is"]'::jsonb,
    'The risk that a borrower will fail to repay what they owe', 1),
  ('00000000-0000-0000-0003-000000000106', 'Bond X (highly rated) yields 4%. Bond Y (lower rated) yields 9% for the same maturity. What does the 5-point yield gap represent?',
    '["A pricing error that will correct itself", "Compensation investors demand for Bond Y''s materially higher perceived default risk", "Guaranteed extra profit with no added risk", "The difference in each bond''s currency"]'::jsonb,
    'Compensation investors demand for Bond Y''s materially higher perceived default risk', 2),
  ('00000000-0000-0000-0003-000000000106', 'Why would a lender mispricing risk by only seeing "Bond Y pays more" be a mistake?',
    '["Because it ignores the higher chance of losing principal that comes with the higher yield", "Because Bond Y always defaults immediately", "Because yield and risk are always unrelated", "Because lower-rated bonds are illegal to hold"]'::jsonb,
    'Because it ignores the higher chance of losing principal that comes with the higher yield', 3),
  ('00000000-0000-0000-0003-000000000106', 'A company has operating cash flow of $1,500,000 and total debt service of $750,000. What is its DSCR?',
    '["0.5", "1.0", "2.0", "750,000"]'::jsonb,
    '2.0', 4),
  ('00000000-0000-0000-0003-000000000106', 'What does a DSCR below 1.0 indicate?',
    '["The borrower has no debt", "The borrower cannot cover this year''s debt payments from operating cash alone -- a serious warning sign", "The borrower is over-collateralized", "The borrower''s credit rating is guaranteed to be AAA"]'::jsonb,
    'The borrower cannot cover this year''s debt payments from operating cash alone -- a serious warning sign', 5),
  ('00000000-0000-0000-0003-000000000106', 'Which of these is NOT one of the signals the lesson says lenders look at beyond a single credit rating?',
    '["Cash flow relative to debt payments due", "Existing leverage relative to assets or earnings", "Whether any collateral is pledged", "The borrower''s favorite bank branch location"]'::jsonb,
    'The borrower''s favorite bank branch location', 6),

  -- Portfolio Construction Basics
  ('00000000-0000-0000-0003-000000000107', 'What is the main benefit diversification provides, according to the lesson?',
    '["It guarantees higher returns", "It can reduce a portfolio''s volatility without necessarily reducing its expected return", "It eliminates all investment risk entirely", "It only works for bonds, never stocks"]'::jsonb,
    'It can reduce a portfolio''s volatility without necessarily reducing its expected return', 1),
  ('00000000-0000-0000-0003-000000000107', 'A portfolio is 60% Stock A (10% expected return) and 40% Bond B (4% expected return). What is the expected portfolio return?',
    '["7%", "7.6%", "10%", "14%"]'::jsonb,
    '7.6%', 2),
  ('00000000-0000-0000-0003-000000000107', 'Why does holding two highly-correlated assets barely reduce portfolio risk?',
    '["Because they tend to rise and fall together, so one rarely offsets a bad day for the other", "Because correlation has no effect on portfolio volatility", "Because highly-correlated assets always have identical expected returns", "Because diversification only applies to more than 2 assets"]'::jsonb,
    'Because they tend to rise and fall together, so one rarely offsets a bad day for the other', 3),
  ('00000000-0000-0000-0003-000000000107', 'Is a portfolio''s expected return calculated the same way (a weighted average) regardless of how correlated the holdings are?',
    '["No, correlation changes how expected return is weighted", "Yes -- expected return is always a straightforward weighted average; correlation specifically affects volatility, not expected return", "No, expected return is always equal to the highest individual holding''s return", "Yes, but only if there are exactly two holdings"]'::jsonb,
    'Yes -- expected return is always a straightforward weighted average; correlation specifically affects volatility, not expected return', 4),
  ('00000000-0000-0000-0003-000000000107', 'Why might a well-diversified 60/40 stock/bond portfolio have lower volatility than a simple weighted average of the two assets'' individual volatilities would suggest?',
    '["Because bonds have no volatility at all, ever", "Because the imperfectly-correlated assets'' ups and downs partly cancel each other out", "Because stocks and bonds always move in perfect opposite lockstep", "Because volatility calculations always round down"]'::jsonb,
    'Because the imperfectly-correlated assets'' ups and downs partly cancel each other out', 5),
  ('00000000-0000-0000-0003-000000000107', 'What is the classic case for holding both stocks and bonds rather than an all-stock or all-bond portfolio, per the lesson?',
    '["Bonds always outperform stocks over any period", "Their imperfect correlation lets the combined portfolio achieve lower volatility than either asset class delivers on its own weighting", "Regulations require every portfolio to hold both", "Stocks and bonds have identical risk profiles, so mixing them changes nothing"]'::jsonb,
    'Their imperfect correlation lets the combined portfolio achieve lower volatility than either asset class delivers on its own weighting', 6);

-- Case-style modeling exercise: DSCR calculation for Credit Risk Basics.
insert into modeling_exercises (id, skill_id, title, instructions, rubric, pass_threshold) values
  ('00000000-0000-0000-0004-000000000002', '00000000-0000-0000-0001-000000000106',
   'Assess a Loan Using Debt Service Coverage Ratio',
   'A company applying for a loan has annual operating cash flow of $1,500,000. Its required debt payments this year would be $600,000 in principal and $150,000 in interest. A typical lender minimum DSCR threshold is 1.25. Calculate: (1) total annual debt service (principal + interest), (2) the debt service coverage ratio (DSCR = operating cash flow / total debt service), rounded to 2 decimals, (3) whether the company passes the 1.25 minimum threshold (submit 1 for pass, 0 for fail). Submit as {"total_debt_service": <number>, "dscr": <number>, "passes_threshold": <0 or 1>}.',
   '{
     "total_debt_service": {"expected": 750000, "tolerance": 1000},
     "dscr": {"expected": 2.0, "tolerance": 0.05},
     "passes_threshold": {"expected": 1, "tolerance": 0}
   }'::jsonb,
   0.8);

-- ===================== Job-Ready: 204-206 =====================

insert into skills (id, tier, slug, title, prerequisite_skill_id, mastery_threshold) values
  ('00000000-0000-0000-0001-000000000204', 'job_ready', 'technical-interview-prep', 'Technical Interview Prep: Markets & Valuation',
    '00000000-0000-0000-0001-000000000203', 0.8),
  ('00000000-0000-0000-0001-000000000205', 'job_ready', 'market-sizing-case-interviews', 'Market Sizing & Case Interviews',
    '00000000-0000-0000-0001-000000000204', 0.8),
  ('00000000-0000-0000-0001-000000000206', 'job_ready', 'ethics-and-compliance-basics', 'Ethics & Compliance in Finance',
    '00000000-0000-0000-0001-000000000205', 0.8);

insert into lessons (id, skill_id, content_type, content_body, order_index) values
  ('00000000-0000-0000-0002-000000000204', '00000000-0000-0000-0001-000000000204', 'article',
   'Technical finance interview questions test whether you actually understand core concepts well enough to explain them under pressure, not whether you''ve memorised a script. Common technical questions cluster around a few recurring themes: valuation ("walk me through a DCF," "how would you value this company"), accounting/statement linkage ("if depreciation increases by £10, what happens to the three statements"), and markets basics ("what happens to bond prices when interest rates rise"). Interviewers are listening for structure and correct mechanics, not eloquence.

A reliable way to prepare is building a small set of "anchor explanations" for the concepts that come up most: be able to state, in under 60 seconds, what a DCF is and why it discounts future cash flows; be able to trace how a single accounting change ripples through the income statement, balance sheet, and cash flow statement; be able to explain the inverse relationship between bond prices and interest rates in plain terms. Practicing these out loud, not just reading about them, is what prevents freezing when asked live.

Worked example -- the classic "depreciation increases by £10" walk-through: on the income statement, pre-tax income falls by £10, and net income falls by £10 x (1 - tax rate) -- say a 25% tax rate, so net income falls by £7.50. On the cash flow statement, net income (down £7.50) is the starting line, but depreciation is a non-cash expense added back (+£10), so cash flow from operations actually rises by £2.50 net (-£7.50 + £10). On the balance sheet, cash rises by £2.50 (from the cash flow statement), retained earnings falls by £7.50 (lower net income), and accumulated depreciation rises by £10 (reducing net fixed assets by £10) -- assets fall by £7.50 net (+£2.50 cash, -£10 fixed assets), matching the £7.50 fall in equity from lower retained earnings, so the balance sheet still balances.

Recap: technical interview prep rewards being able to explain a small set of core mechanics fluently and correctly under pressure -- DCF logic, how one accounting change flows through all three statements, and basic bond/rate relationships are asked constantly enough that a rehearsed, correct explanation is worth more than broad but shallow knowledge of many topics.',
   1),
  ('00000000-0000-0000-0002-000000000205', '00000000-0000-0000-0001-000000000205', 'article',
   'Case-method basics covered the general structure -- clarify, break down, assume, calculate, sanity-check. Finance-flavored case questions add one more layer: they often embed a business or investment decision inside the estimate, so the interviewer is also watching whether your structure would actually support a real recommendation, not just a number.

A useful extra habit for finance-flavored cases: after reaching an estimate, explicitly state what the number implies for the decision at hand, and name the biggest assumption that, if wrong, would most change your answer. This shows the interviewer you understand estimation is a tool for a decision, not an end in itself -- and that you know which assumption is doing the most work, exactly the kind of judgment a real analyst needs when a model''s projected value depends heavily on one shaky input.

Worked example -- "A regional bank is deciding whether to open a new branch in a town of 50,000 people. Estimate whether it''s worth it." Structure: clarify what "worth it" means (assume: worth opening if it can attract enough deposit accounts to cover its annual operating cost within a reasonable payback period). Break down: assume 50,000 people, 70% are banked adults = 35,000 potential customers; assume the branch could realistically capture 4% of that town''s banking relationships in year one = 1,400 accounts; assume average annual revenue per account (fees + net interest margin) is £120 = £168,000 in year-one revenue; assume the branch costs £150,000/year to run. Compare: £168,000 in revenue against £150,000 in cost suggests the branch is roughly break-even to modestly profitable in year one -- a plausible "yes, worth opening, but thin margin" answer. Explicitly flag the shakiest assumption: the 4% capture rate is doing the most work -- if it''s actually 2%, revenue drops to £84,000 and the branch loses money in year one, so a real analyst would want much better local market data on that specific number before recommending it.

Recap: finance case interviews reward the same structured-estimation process as any case, plus explicitly connecting the number to the underlying decision and naming which assumption matters most -- showing you understand estimation serves a decision, and that you know where the real uncertainty in your own answer lives.',
   1),
  ('00000000-0000-0000-0002-000000000206', '00000000-0000-0000-0001-000000000206', 'article',
   'Finance roles carry real ethical and regulatory weight, because the industry handles other people''s money and privileged information -- interviewers, especially at banks, often include at least one ethics/compliance-flavored question to see how a candidate reasons about it, not to test memorised rules. Three concepts come up repeatedly: conflicts of interest (a situation where your interests, or your firm''s, could improperly influence advice given to a client), insider trading (trading a security based on material non-public information -- information not yet available to the public that a reasonable investor would consider important), and fiduciary duty (a legal and ethical obligation to act in a client''s best interest, not your own or your firm''s).

A useful pattern for answering an ethics scenario question: name the specific issue at stake (which of the concepts above applies), explain concretely why it matters (who could be harmed and how), and state what you would actually do -- usually escalating to a compliance officer or manager rather than deciding alone, since acting unilaterally on a gray-area judgment call is itself often the wrong move in a regulated industry.

Worked example -- "You''re a junior analyst and a friend at another firm mentions their company is about to be acquired, before any public announcement. What do you do?" A weak answer either ignores the issue or vaguely says "I''d be careful." A strong answer names the issue precisely: this is material non-public information, and trading on it (or even just tipping someone else who trades on it) is insider trading, a serious securities law violation, regardless of whether you personally profit. The right action is to not trade the stock, not share the information further, and report the situation to your firm''s compliance department, since receiving this kind of information -- even unintentionally, from a friend -- can itself create legal exposure that compliance needs to be aware of and document.

Recap: ethics and compliance questions test whether you can correctly name the underlying issue (conflict of interest, insider trading, fiduciary duty), explain the real-world harm at stake, and default to escalating rather than deciding alone -- a pattern that reflects how regulated finance firms actually expect junior staff to behave in gray-area situations.',
   1);

insert into quizzes (id, skill_id, lesson_id, title, pass_threshold) values
  ('00000000-0000-0000-0003-000000000204', '00000000-0000-0000-0001-000000000204', '00000000-0000-0000-0002-000000000204', 'Technical Interview Prep Quiz', 0.8),
  ('00000000-0000-0000-0003-000000000205', '00000000-0000-0000-0001-000000000205', '00000000-0000-0000-0002-000000000205', 'Market Sizing & Case Interviews Quiz', 0.8),
  ('00000000-0000-0000-0003-000000000206', '00000000-0000-0000-0001-000000000206', '00000000-0000-0000-0002-000000000206', 'Ethics & Compliance in Finance Quiz', 0.8);

insert into quiz_questions (quiz_id, question, options, correct_answer, order_index) values
  -- Technical Interview Prep
  ('00000000-0000-0000-0003-000000000204', 'What are technical finance interview questions primarily testing, per the lesson?',
    '["How eloquently you can speak regardless of accuracy", "Whether you understand core concepts well enough to explain them correctly under pressure", "Whether you have memorised a fixed script", "How quickly you can change the subject"]'::jsonb,
    'Whether you understand core concepts well enough to explain them correctly under pressure', 1),
  ('00000000-0000-0000-0003-000000000204', 'Depreciation increases by £10 with a 25% tax rate. By how much does net income fall?',
    '["£2.50", "£7.50", "£10.00", "£0"]'::jsonb,
    '£7.50', 2),
  ('00000000-0000-0000-0003-000000000204', 'In the same scenario, why does cash flow from operations actually rise by £2.50, even though net income falls?',
    '["Because depreciation is a non-cash expense that gets added back after net income falls", "Because taxes are refunded automatically", "Because depreciation increases cash directly", "It does not rise -- this is a trick and cash flow falls too"]'::jsonb,
    'Because depreciation is a non-cash expense that gets added back after net income falls', 3),
  ('00000000-0000-0000-0003-000000000204', 'On the balance sheet in that scenario, what happens to accumulated depreciation and net fixed assets?',
    '["Accumulated depreciation falls and fixed assets rise", "Accumulated depreciation rises by £10, reducing net fixed assets by £10", "Neither changes", "Fixed assets rise by £10 and cash falls by £10"]'::jsonb,
    'Accumulated depreciation rises by £10, reducing net fixed assets by £10', 4),
  ('00000000-0000-0000-0003-000000000204', 'Why does the lesson recommend building a small set of "anchor explanations" rather than studying broadly across many topics?',
    '["Because interviewers only ever ask one question per interview", "Because a small set of core mechanics comes up constantly, so fluency there matters more than shallow knowledge of many topics", "Because broad knowledge is actively penalised in interviews", "Because anchor explanations replace the need to understand any mechanics"]'::jsonb,
    'Because a small set of core mechanics comes up constantly, so fluency there matters more than shallow knowledge of many topics', 5),
  ('00000000-0000-0000-0003-000000000204', 'What does DCF logic fundamentally rest on, per the lesson''s anchor-explanation guidance?',
    '["Comparing a company only to its stock ticker symbol", "Discounting future cash flows to reflect that money in the future is worth less than money today", "Ignoring all future cash flows entirely", "Using only historical, not projected, financial data"]'::jsonb,
    'Discounting future cash flows to reflect that money in the future is worth less than money today', 6),

  -- Market Sizing & Case Interviews
  ('00000000-0000-0000-0003-000000000205', 'What extra habit does the lesson recommend adding to the standard case-interview structure for finance-flavored cases?',
    '["Skipping the sanity-check step entirely", "Explicitly stating what the number implies for the decision, and naming the biggest assumption that could most change the answer", "Never stating any assumptions out loud", "Always giving the exact same estimate regardless of the scenario"]'::jsonb,
    'Explicitly stating what the number implies for the decision, and naming the biggest assumption that could most change the answer', 1),
  ('00000000-0000-0000-0003-000000000205', 'In the branch worked example, 50,000 people with 70% banked adults gives how many potential customers?',
    '["15,000", "35,000", "50,000", "70,000"]'::jsonb,
    '35,000', 2),
  ('00000000-0000-0000-0003-000000000205', 'If the branch captures 4% of 35,000 potential customers, how many accounts does it gain in year one?',
    '["140", "700", "1,400", "3,500"]'::jsonb,
    '1,400', 3),
  ('00000000-0000-0000-0003-000000000205', 'With 1,400 accounts averaging £120 annual revenue each, and £150,000 annual operating cost, what does the branch''s year-one economics look like?',
    '["A large loss of over £100,000", "Roughly break-even to modestly profitable (£168,000 revenue vs. £150,000 cost)", "A guaranteed £168,000 profit with no costs", "Impossible to estimate without more information"]'::jsonb,
    'Roughly break-even to modestly profitable (£168,000 revenue vs. £150,000 cost)', 4),
  ('00000000-0000-0000-0003-000000000205', 'Why does the lesson flag the 4% capture-rate assumption as the "shakiest" one in the branch example?',
    '["Because it is a government-set number that cannot change", "Because a small change in that one assumption (e.g. to 2%) would flip the branch from profitable to unprofitable", "Because capture rate has no effect on the final estimate", "Because it is the only assumption that is always exactly correct"]'::jsonb,
    'Because a small change in that one assumption (e.g. to 2%) would flip the branch from profitable to unprofitable', 5),
  ('00000000-0000-0000-0003-000000000205', 'What is the main point of explicitly naming your biggest assumption at the end of a case answer?',
    '["It has no real purpose beyond sounding thorough", "It shows the interviewer you understand where the real uncertainty in your own estimate lives, which is real analytical judgment", "It is required to avoid being penalised for giving any estimate at all", "It replaces the need to do any calculation"]'::jsonb,
    'It shows the interviewer you understand where the real uncertainty in your own estimate lives, which is real analytical judgment', 6),

  -- Ethics & Compliance in Finance
  ('00000000-0000-0000-0003-000000000206', 'What is insider trading, as defined in the lesson?',
    '["Any trade made by a bank employee", "Trading a security based on material non-public information", "Trading only on days the market is closed", "Buying and selling the same stock within one day"]'::jsonb,
    'Trading a security based on material non-public information', 1),
  ('00000000-0000-0000-0003-000000000206', 'A junior analyst learns from a friend, before any public announcement, that the friend''s company is about to be acquired. What should the analyst do?',
    '["Trade on the tip immediately before the news becomes public", "Not trade or share the information, and report the situation to compliance", "Wait exactly 24 hours, then trade freely", "Only share the tip with close family members"]'::jsonb,
    'Not trade or share the information, and report the situation to compliance', 2),
  ('00000000-0000-0000-0003-000000000206', 'Why can receiving insider information unintentionally (e.g. from a friend) still create legal exposure?',
    '["It cannot -- only intentionally seeking out the information is illegal", "Possessing and potentially acting on material non-public information carries legal risk regardless of how it was received", "Legal exposure only applies to the original source of the information", "There is no legal exposure as long as no money is made"]'::jsonb,
    'Possessing and potentially acting on material non-public information carries legal risk regardless of how it was received', 3),
  ('00000000-0000-0000-0003-000000000206', 'What does fiduciary duty require of a financial professional?',
    '["Acting in their own firm''s interest above all else", "Acting in the client''s best interest, not their own or their firm''s", "Maximizing trading volume regardless of client outcomes", "Disclosing client information to competitors when asked"]'::jsonb,
    'Acting in the client''s best interest, not their own or their firm''s', 4),
  ('00000000-0000-0000-0003-000000000206', 'What is the recommended default action when facing a gray-area ethics situation, per the lesson?',
    '["Decide alone and act quickly to avoid delay", "Escalate to a compliance officer or manager rather than deciding unilaterally", "Ignore the situation unless directly asked about it", "Always assume the most aggressive interpretation is correct"]'::jsonb,
    'Escalate to a compliance officer or manager rather than deciding unilaterally', 5),
  ('00000000-0000-0000-0003-000000000206', 'What is the recommended structure for answering an ethics scenario question in an interview?',
    '["Give a vague reassurance without naming any specific issue", "Name the specific issue at stake, explain the concrete harm, and state what action you would actually take", "Recite the definition of fiduciary duty word-for-word with no scenario-specific reasoning", "Deflect the question by asking the interviewer what they would do instead"]'::jsonb,
    'Name the specific issue at stake, explain the concrete harm, and state what action you would actually take', 6);

-- Case-style modeling exercise: branch market-sizing case for Market Sizing & Case Interviews.
insert into modeling_exercises (id, skill_id, title, instructions, rubric, pass_threshold) values
  ('00000000-0000-0000-0004-000000000004', '00000000-0000-0000-0001-000000000205',
   'Size a New Bank Branch''s Year-One Economics',
   'A regional bank is evaluating a new branch in a town of 80,000 people. Assume 70% of the population are banked adults. Assume the branch can capture 5% of those banked adults as customers in year one. Assume average annual revenue per customer is $150. The branch''s annual operating cost is $220,000. Calculate: (1) the number of banked adults in the town, (2) the number of year-one customers captured, (3) year-one revenue, (4) year-one profit (revenue minus operating cost -- may be negative). Submit as {"banked_adults": <number>, "year_one_customers": <number>, "year_one_revenue": <number>, "year_one_profit": <number>}.',
   '{
     "banked_adults": {"expected": 56000, "tolerance": 500},
     "year_one_customers": {"expected": 2800, "tolerance": 50},
     "year_one_revenue": {"expected": 420000, "tolerance": 2000},
     "year_one_profit": {"expected": 200000, "tolerance": 2000}
   }'::jsonb,
   0.8);
