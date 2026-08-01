-- College content-depth followup: the core new-topics migration.
--
-- Adds 10 new College-tier skills (109-118), chaining off the existing
-- capstone skill 108 (capital-structure-and-wacc), bringing College from 8
-- to 18 total skills -- well past the "10-15+ substantive topics" bar the
-- captain asked for. Topics are the exact list named in the task brief:
-- budgeting on a student income, student loans, credit scores/cards,
-- investing basics, taxes for a first job, retirement accounts, insurance
-- basics, negotiating salary, side income/freelancing, and a capstone
-- "financial planning for post-grad life" topic.
--
-- Every quiz has 10 questions (per the captain's added scope), difficulty
-- roughly tiered by order_index (1-3 easy, 4-7 medium, 8-10 hard) -- the
-- same recall-first/application-later shape migration 049's backfill notes
-- describe for existing content, just authored directly this time. Skill/
-- lesson/quiz ids follow the existing X09-X18 suffix convention shared
-- across the three uuid namespaces (skills/lessons/quizzes), and this
-- migration's quiz ids (109-118) are exactly the ones migration 049
-- excludes from its difficulty backfill.
--
-- Migration 048 (case-study quizzes, already written) attaches its three
-- quizzes to skills 109, 110, and 118 seeded here -- this migration must
-- run before 048 for that migration's foreign keys to resolve, hence the
-- 047 timestamp slotting between 046 and 048.
--
-- Content is written originally for this project; topics and reasoning
-- patterns are grounded in how undergraduate personal-finance electives and
-- financial-literacy nonprofit curricula are structured, not copied from
-- any publisher's text. Dollar figures and rates are illustrative teaching
-- examples, not sourced from any real employer/lender/tax-year data -- US
-- personal-finance concepts (federal loans, 401(k)/IRA, FICA) are used
-- throughout to match the US-specific framing migrations 016/028/030/031/048
-- already established for College tier.

-- ===================== 109: Budgeting on a Student Income =====================

insert into skills (id, tier, slug, title, prerequisite_skill_id, mastery_threshold) values
  ('00000000-0000-0000-0001-000000000109', 'college', 'budgeting-on-a-student-income', 'Budgeting on a Student Income',
    '00000000-0000-0000-0001-000000000108', 0.8);

insert into lessons (id, skill_id, content_type, content_body, order_index) values
  ('00000000-0000-0000-0002-000000000109', '00000000-0000-0000-0001-000000000109', 'article',
   'Budgeting means deciding, before you spend it, where every dollar of your income is going to go -- the alternative is finding out only after the money is already gone. For most college students, income is smaller and less steady than it will be after graduation, which makes deliberate budgeting more important, not less: an unplanned $50 expense can wreck a month''s budget when total monthly income is $1,000, in a way it wouldn''t on a $5,000 income. The first step is separating expenses into fixed costs (the same amount every month -- rent, a phone plan, a subscription) and variable costs (amounts that change -- groceries, going out, transportation), because fixed costs can be planned around with near-certainty, while variable costs are the part a budget actually has to manage.

A common starting framework splits after-tax income roughly into needs (essential costs -- housing, food, utilities, required course materials), wants (discretionary spending -- entertainment, dining out, non-essential purchases), and savings (building an emergency cushion or a specific goal), often cited as a rough 50/30/20 split, though the right split for any individual depends on their actual fixed costs. Student income is also often irregular in a way a salaried budget isn''t -- a financial-aid refund or a family contribution can arrive as one lump sum meant to last a whole semester, and an irregular expense like a textbook bill happens once a term rather than every month. Treating a lump sum as if it were all available to spend at once, or treating a predictable-but-infrequent cost as a surprise every time it recurs, are the two most common ways a student budget breaks down -- both are solved the same way, by dividing the lump sum or the irregular cost by the number of months it actually needs to cover, and setting that smaller monthly amount aside in advance.

Worked example: a student earns $700/month from a part-time job and receives a $1,200 financial-aid refund at the start of each 4-month term (effectively $300/month). Total effective monthly income is $1,000. Fixed costs are $550 (rent share $400, phone $30, a streaming subscription $10, transit pass $60, insurance $50), leaving $450. A $240 textbook bill each term works out to $60/month set aside ($240 / 4), leaving $390 for groceries, wants, and savings combined. If groceries run about $150/month, that leaves $240 to deliberately split between discretionary wants and building savings, rather than whatever happens to be left over by accident at the end of the month.

Recap: a budget separates fixed costs (predictable) from variable costs (the part that needs active management), and works best when built around actual income and actual costs rather than a generic percentage split alone. Irregular income (lump-sum refunds) and irregular expenses (once-a-term costs) are both best handled by converting them into an equivalent monthly amount, so no single month gets blindsided by a cost that was always coming.',
   1);

insert into quizzes (id, skill_id, lesson_id, title, pass_threshold) values
  ('00000000-0000-0000-0003-000000000109', '00000000-0000-0000-0001-000000000109', '00000000-0000-0000-0002-000000000109', 'Budgeting on a Student Income Quiz', 0.8);

insert into quiz_questions (quiz_id, question, options, correct_answer, order_index, difficulty) values
  ('00000000-0000-0000-0003-000000000109', 'What is the main difference between a fixed cost and a variable cost?',
    '["A fixed cost stays the same amount each month; a variable cost changes", "A fixed cost only applies to rent", "A variable cost is always larger than a fixed cost", "There is no real difference"]'::jsonb,
    'A fixed cost stays the same amount each month; a variable cost changes', 1, 'easy'),
  ('00000000-0000-0000-0003-000000000109', 'In the rough 50/30/20 framework described in the lesson, what does income get split into?',
    '["Needs, wants, and savings", "Rent, food, and tuition", "Fixed costs, variable costs, and debt", "Taxes, insurance, and entertainment"]'::jsonb,
    'Needs, wants, and savings', 2, 'easy'),
  ('00000000-0000-0000-0003-000000000109', 'The example student earns $700/month from a job and receives a $1,200 refund every 4 months. What is their total effective monthly income?',
    '["$700", "$1,200", "$1,000", "$1,900"]'::jsonb,
    '$1,000', 3, 'easy'),
  ('00000000-0000-0000-0003-000000000109', 'Why is a small unplanned expense riskier for a student budget than for a much higher salaried income, per the lesson?',
    '["It represents a much larger share of a smaller total budget", "Students are legally not allowed unplanned expenses", "Unplanned expenses only happen to students", "It isn''t actually riskier at all"]'::jsonb,
    'It represents a much larger share of a smaller total budget', 4, 'medium'),
  ('00000000-0000-0000-0003-000000000109', 'The example student has $550 in fixed costs out of $1,000 total income. How much is left after fixed costs?',
    '["$350", "$450", "$550", "$650"]'::jsonb,
    '$450', 5, 'medium'),
  ('00000000-0000-0000-0003-000000000109', 'The student sets aside money monthly for a $240 textbook bill that comes once every 4 months. What calculation produces the monthly amount to set aside?',
    '["$240 x 4", "$240 / 4", "$240 - 4", "$240 + 4"]'::jsonb,
    '$240 / 4', 6, 'medium'),
  ('00000000-0000-0000-0003-000000000109', 'After setting aside $60/month for textbooks from the $450 remaining after fixed costs, how much is left for groceries, wants, and savings combined?',
    '["$330", "$390", "$450", "$510"]'::jsonb,
    '$390', 7, 'medium'),
  ('00000000-0000-0000-0003-000000000109', 'If groceries cost $150/month out of the remaining $390, how much is left to split between wants and savings?',
    '["$140", "$190", "$240", "$290"]'::jsonb,
    '$240', 8, 'hard'),
  ('00000000-0000-0000-0003-000000000109', 'Why does the lesson recommend converting a once-a-term expense into a monthly set-aside amount rather than budgeting for it only when the bill arrives?',
    '["So the cost is smoothed out and doesn''t blow up a single month''s budget when it finally hits", "Because irregular expenses are actually illegal to budget for", "Because it makes the total amount spent smaller", "It has no real benefit, it just feels more organized"]'::jsonb,
    'So the cost is smoothed out and doesn''t blow up a single month''s budget when it finally hits', 9, 'hard'),
  ('00000000-0000-0000-0003-000000000109', 'What is the main risk of treating a semester''s lump-sum financial-aid refund as money that is all available to spend right away?',
    '["Spending it too early leaves nothing for the later months it was actually meant to cover", "Lump sums cannot legally be spent on anything but tuition", "Refunds expire within a week of being received", "There is no risk, lump sums should always be spent immediately"]'::jsonb,
    'Spending it too early leaves nothing for the later months it was actually meant to cover', 10, 'hard');

-- ===================== 110: Student Loans & Interest =====================

insert into skills (id, tier, slug, title, prerequisite_skill_id, mastery_threshold) values
  ('00000000-0000-0000-0001-000000000110', 'college', 'student-loans-and-interest', 'Student Loans & Interest',
    '00000000-0000-0000-0001-000000000109', 0.8);

insert into lessons (id, skill_id, content_type, content_body, order_index) values
  ('00000000-0000-0000-0002-000000000110', '00000000-0000-0000-0001-000000000110', 'article',
   'Student loans come in two broad categories with very different risk profiles: federal loans, issued by the government with fixed rates and built-in borrower protections (income-driven repayment, deferment, forgiveness programs), and private loans, issued by banks or other lenders with rates that can be fixed or variable and typically far fewer protections. Within federal loans, subsidized loans do not accrue interest while the borrower is still in school (the government pays it), while unsubsidized loans start accruing interest immediately, even before the first payment is due -- a distinction that changes how large the balance actually is by the time repayment starts.

Interest on a loan is the cost of borrowing, calculated as a percentage of the outstanding balance, and it keeps accruing during any period the loan isn''t being actively paid down, including the standard 6-month "grace period" most federal loans give new graduates before payments begin. If that accrued interest is not paid during the grace period, it typically gets "capitalized" -- added to the principal balance, so that future interest is calculated on a larger number, meaning unpaid interest itself starts generating more interest. This is why paying at least the accruing interest during school or the grace period, even without touching the principal, can meaningfully reduce the total cost of an unsubsidized loan.

Repayment plans also matter beyond the interest rate itself. A standard plan fixes the term (commonly 10 years) and the payment amount, which is calculated so the loan is fully paid off on schedule. Income-driven plans instead set the payment as a percentage of discretionary income, which can be much lower month to month, but if that lower payment is less than the interest accruing, the balance can actually grow over time (negative amortization) -- not automatically a bad outcome if the borrower is pursuing loan forgiveness after a set number of qualifying payments, but a real cost if they are not.

Worked example: a student has a $5,000 unsubsidized loan accruing interest at 5% annually while still in school. Over 2 years in school plus a 6-month grace period (2.5 years total), interest accrues at roughly $5,000 x 5% x 2.5 = $625. If that interest is never paid and instead capitalizes at the start of repayment, the loan''s new principal becomes $5,625 -- and every future interest calculation is now based on $5,625, not $5,000, permanently raising the total cost versus a borrower who paid that $625 in interest along the way.

Recap: subsidized loans don''t accrue interest in school, unsubsidized loans do from day one; unpaid interest that capitalizes at repayment permanently raises the balance future interest is calculated on. A lower monthly payment (income-driven plans) is not automatically the cheaper choice overall -- it depends on whether the payment covers accruing interest and whether the borrower is on a path to forgiveness.',
   1);

insert into quizzes (id, skill_id, lesson_id, title, pass_threshold) values
  ('00000000-0000-0000-0003-000000000110', '00000000-0000-0000-0001-000000000110', '00000000-0000-0000-0002-000000000110', 'Student Loans & Interest Quiz', 0.8);

insert into quiz_questions (quiz_id, question, options, correct_answer, order_index, difficulty) values
  ('00000000-0000-0000-0003-000000000110', 'What is the main difference between a subsidized and an unsubsidized federal student loan?',
    '["Subsidized loans don''t accrue interest while the borrower is in school; unsubsidized loans do", "Unsubsidized loans are always private loans", "Subsidized loans have no interest rate ever", "There is no real difference between them"]'::jsonb,
    'Subsidized loans don''t accrue interest while the borrower is in school; unsubsidized loans do', 1, 'easy'),
  ('00000000-0000-0000-0003-000000000110', 'What does "interest capitalizing" mean, per the lesson?',
    '["Unpaid accrued interest is added to the principal, so future interest is calculated on a larger balance", "The interest rate is permanently reduced to zero", "The loan is automatically forgiven", "The borrower stops owing any further interest"]'::jsonb,
    'Unpaid accrued interest is added to the principal, so future interest is calculated on a larger balance', 2, 'easy'),
  ('00000000-0000-0000-0003-000000000110', 'What is the standard grace period most federal loans give a borrower after graduation before payments begin?',
    '["6 months", "10 years", "1 month", "There is no grace period"]'::jsonb,
    '6 months', 3, 'easy'),
  ('00000000-0000-0000-0003-000000000110', 'Generally speaking, which type of loan tends to have fewer borrower protections (like income-driven repayment or forgiveness paths)?',
    '["Private loans", "Federal loans", "Both offer identical protections", "Neither type offers any protections"]'::jsonb,
    'Private loans', 4, 'medium'),
  ('00000000-0000-0000-0003-000000000110', 'A $5,000 unsubsidized loan accrues about $625 in interest over 2.5 years in school and grace period. If that interest is never paid, what happens to it at the start of repayment?',
    '["It is forgiven automatically", "It capitalizes, making the new principal $5,625", "It is deducted from the principal", "It disappears since grace periods are interest-free"]'::jsonb,
    'It capitalizes, making the new principal $5,625', 5, 'medium'),
  ('00000000-0000-0000-0003-000000000110', 'Why can paying just the accruing interest during school (without touching the principal) meaningfully reduce a loan''s total cost?',
    '["It prevents that interest from capitalizing into a larger principal balance later", "It has no effect on total cost", "It automatically qualifies the borrower for forgiveness", "It converts the loan from unsubsidized to subsidized"]'::jsonb,
    'It prevents that interest from capitalizing into a larger principal balance later', 6, 'medium'),
  ('00000000-0000-0000-0003-000000000110', 'How does an income-driven repayment plan set the monthly payment amount, compared to a standard plan?',
    '["As a percentage of the borrower''s discretionary income, rather than a fixed amount tied to a fixed term", "It is always exactly half of the standard plan''s payment", "It is set entirely by the borrower with no formula", "It is always higher than the standard plan"]'::jsonb,
    'As a percentage of the borrower''s discretionary income, rather than a fixed amount tied to a fixed term', 7, 'medium'),
  ('00000000-0000-0000-0003-000000000110', 'Under what circumstance can an income-driven plan''s lower monthly payment cause a loan balance to actually grow instead of shrink?',
    '["When the payment amount is less than the interest accruing each month", "Whenever the interest rate is below 1%", "This can never happen under any repayment plan", "Only if the borrower misses every single payment"]'::jsonb,
    'When the payment amount is less than the interest accruing each month', 8, 'hard'),
  ('00000000-0000-0000-0003-000000000110', 'Why might negative amortization (a growing balance) still be a rational outcome for a borrower on an income-driven plan, per the lesson?',
    '["If they are pursuing a career path eligible for loan forgiveness after a set number of qualifying payments", "Because a growing balance always eventually shrinks on its own", "Because interest stops accruing once the balance is large enough", "It is never rational under any circumstance"]'::jsonb,
    'If they are pursuing a career path eligible for loan forgiveness after a set number of qualifying payments', 9, 'hard'),
  ('00000000-0000-0000-0003-000000000110', 'Why does the lesson caution that a lower monthly payment is not automatically the cheaper choice overall?',
    '["Because it depends on whether the lower payment covers accruing interest and whether the borrower is on a forgiveness path -- otherwise more total interest can accumulate over a longer payoff", "Because monthly payment amount has no relationship to total cost", "Because lower payments always mean a shorter payoff term", "Because federal loans do not allow lower payments"]'::jsonb,
    'Because it depends on whether the lower payment covers accruing interest and whether the borrower is on a forgiveness path -- otherwise more total interest can accumulate over a longer payoff', 10, 'hard');

-- Case-style modeling exercise: first-month loan amortization mechanics.
insert into modeling_exercises (id, skill_id, title, instructions, rubric, pass_threshold) values
  ('00000000-0000-0000-0004-000000000006', '00000000-0000-0000-0001-000000000110',
   'Calculate a Loan''s First Monthly Payment Breakdown',
   'A borrower has a $10,000 student loan balance at 6% annual interest and pays $200 in their first month of repayment. Calculate: (1) the interest portion of that payment (annual rate / 12 x balance), (2) the principal portion (payment minus interest), and (3) the remaining balance after that payment (starting balance minus principal paid). Submit as {"first_month_interest": <number>, "first_month_principal": <number>, "remaining_balance": <number>}.',
   '{"first_month_interest": {"expected": 50, "tolerance": 2}, "first_month_principal": {"expected": 150, "tolerance": 2}, "remaining_balance": {"expected": 9850, "tolerance": 5}}'::jsonb,
   0.8);

-- ===================== 111: Credit Scores & Credit Cards =====================

insert into skills (id, tier, slug, title, prerequisite_skill_id, mastery_threshold) values
  ('00000000-0000-0000-0001-000000000111', 'college', 'credit-scores-and-credit-cards', 'Credit Scores & Credit Cards',
    '00000000-0000-0000-0001-000000000110', 0.8);

insert into lessons (id, skill_id, content_type, content_body, order_index) values
  ('00000000-0000-0000-0002-000000000111', '00000000-0000-0000-0001-000000000111', 'article',
   'A credit score is a number, roughly 300-850 in the most common scoring models, meant to summarize how risky it is to lend to a person, based on their past borrowing behavior. It is built from several weighted factors: payment history (whether bills were paid on time -- typically the single largest factor), credit utilization (how much of your available credit you''re actually using), length of credit history (how long your accounts have existed), credit mix (having a mix of account types), and new credit (how many new accounts you''ve recently opened). A higher score generally means access to better loan and credit card terms -- lower interest rates and higher approval odds -- because it signals lower risk to the lender.

Credit utilization deserves special attention because it is easy to control and reacts quickly: it is the percentage of your total available credit that you''re currently using, calculated across all your cards. A commonly cited guideline is to keep utilization under 30% of your total limit, and lower is generally better -- not because using credit is bad, but because a very high utilization ratio, even if you plan to pay it off in full, signals higher risk in the moment the score is calculated. This is different from carrying a balance: paying your statement in full every month keeps utilization visible on your report but avoids interest entirely, because credit cards give a grace period between the purchase and the payment due date during which no interest accrues on new purchases, as long as the previous balance was paid in full.

The most expensive mistake with a credit card is misunderstanding the "minimum payment." A card''s minimum payment is set low enough that a cardholder can technically stay current while barely reducing the balance, because credit card interest rates are high (commonly 20%+ APR) and compound on whatever balance remains after each billing cycle. Making only minimum payments on a large balance can mean paying far more in interest than the original purchase cost, and can take years to pay off.

Worked example: a $2,000 balance sits on a card at 22% APR. If only a $50 minimum payment is made each month, that payment barely exceeds the roughly $37 in interest accruing that month ($2,000 x 22% / 12), so almost all of it goes to interest rather than principal, and the balance shrinks by only a few dollars -- a pattern that, if repeated, takes years and hundreds of dollars in interest to resolve, compared to paying the statement in full each month and never accruing interest at all.

Recap: a credit score weighs payment history and utilization most heavily, and utilization (ideally under 30%) is the factor most directly within a cardholder''s control month to month. Paying a statement in full every cycle avoids interest entirely thanks to the grace period; making only minimum payments on a high-rate balance is one of the most expensive ongoing mistakes a young borrower can make.',
   1);

insert into quizzes (id, skill_id, lesson_id, title, pass_threshold) values
  ('00000000-0000-0000-0003-000000000111', '00000000-0000-0000-0001-000000000111', '00000000-0000-0000-0002-000000000111', 'Credit Scores & Credit Cards Quiz', 0.8);

insert into quiz_questions (quiz_id, question, options, correct_answer, order_index, difficulty) values
  ('00000000-0000-0000-0003-000000000111', 'What does a credit score summarize, per the lesson?',
    '["How risky it is to lend to a person, based on past borrowing behavior", "A person''s total annual income", "How many bank accounts a person owns", "A person''s age"]'::jsonb,
    'How risky it is to lend to a person, based on past borrowing behavior', 1, 'easy'),
  ('00000000-0000-0000-0003-000000000111', 'Which factor is typically the single largest contributor to a credit score?',
    '["Payment history", "The color of the credit card", "The bank''s name", "The cardholder''s job title"]'::jsonb,
    'Payment history', 2, 'easy'),
  ('00000000-0000-0000-0003-000000000111', 'What is credit utilization?',
    '["The percentage of your total available credit that you''re currently using", "The number of credit cards you own", "The interest rate on your credit card", "The number of years you''ve had a credit card"]'::jsonb,
    'The percentage of your total available credit that you''re currently using', 3, 'easy'),
  ('00000000-0000-0000-0003-000000000111', 'What utilization percentage does the lesson cite as a commonly recommended guideline to stay under?',
    '["30%", "90%", "5%", "There is no guideline"]'::jsonb,
    '30%', 4, 'medium'),
  ('00000000-0000-0000-0003-000000000111', 'How does paying a credit card statement in full every month affect interest charges on new purchases?',
    '["It avoids interest entirely thanks to the grace period", "It doubles the interest charged", "It has no effect on interest", "It only works for the first purchase each year"]'::jsonb,
    'It avoids interest entirely thanks to the grace period', 5, 'medium'),
  ('00000000-0000-0000-0003-000000000111', 'Why does the lesson say a very high utilization ratio can hurt a score even if the cardholder plans to pay it off in full?',
    '["A high utilization ratio signals higher risk in the moment the score is calculated, regardless of future payoff intent", "Utilization has no impact on the score at all", "Only unpaid balances count toward utilization, never total usage", "Scores are recalculated only once per year"]'::jsonb,
    'A high utilization ratio signals higher risk in the moment the score is calculated, regardless of future payoff intent', 6, 'medium'),
  ('00000000-0000-0000-0003-000000000111', 'A $2,000 balance sits at 22% APR. Roughly how much interest accrues on it in one month ($2,000 x 22% / 12)?',
    '["About $37", "About $440", "About $3.70", "About $220"]'::jsonb,
    'About $37', 7, 'medium'),
  ('00000000-0000-0000-0003-000000000111', 'If a $50 minimum payment is made on that $2,000 balance and about $37 of it is interest, roughly how much actually reduces the principal that month?',
    '["About $13", "About $50", "About $37", "About $0"]'::jsonb,
    'About $13', 8, 'hard'),
  ('00000000-0000-0000-0003-000000000111', 'Why can making only minimum payments on a high-APR credit card balance end up costing far more than the original purchase?',
    '["Because so little of each payment reduces principal that interest keeps compounding on a nearly-unchanged balance for years", "Because minimum payments always exceed the full balance", "Because credit card interest is a one-time flat fee", "Because minimum payments are illegal for balances over $1,000"]'::jsonb,
    'Because so little of each payment reduces principal that interest keeps compounding on a nearly-unchanged balance for years', 9, 'hard'),
  ('00000000-0000-0000-0003-000000000111', 'A cardholder with a strong payment history but consistently high utilization (e.g., regularly maxing out their limit) would most likely see what effect on their score, per the lesson?',
    '["Their score would be held back by utilization even though payment history looks good, since both factors are weighed separately", "Their score would be unaffected since payment history is the only factor that matters", "Their score would automatically be the maximum possible", "Utilization only matters if a payment is ever missed"]'::jsonb,
    'Their score would be held back by utilization even though payment history looks good, since both factors are weighed separately', 10, 'hard');

-- ===================== 112: Investing Basics =====================

insert into skills (id, tier, slug, title, prerequisite_skill_id, mastery_threshold) values
  ('00000000-0000-0000-0001-000000000112', 'college', 'investing-basics', 'Investing Basics',
    '00000000-0000-0000-0001-000000000111', 0.8);

insert into lessons (id, skill_id, content_type, content_body, order_index) values
  ('00000000-0000-0000-0002-000000000112', '00000000-0000-0000-0001-000000000112', 'article',
   'Investing means putting money into an asset expecting it to grow in value over time, in exchange for accepting some risk that it could lose value instead -- the core trade-off in investing is that higher expected return generally comes with higher risk, and there is no investment that offers high returns with no risk at all. The two most common building-block asset classes are stocks (a share of ownership in a company, whose value moves with that company''s performance and investor sentiment) and bonds (a loan to a company or government that pays back with interest, generally lower risk and lower expected return than stocks). Diversification -- spreading money across many different investments rather than concentrating it in one -- reduces risk because it is unlikely that everything drops in value at the same time for the same reason; a single company can fail, but an entire diversified market rarely does.

An index fund is a single investment that holds many stocks (or bonds) at once, designed to track a broad market index rather than trying to pick individual winners -- buying one index fund is an easy way to get instant diversification across hundreds or thousands of companies. Index funds also tend to charge a very low "expense ratio" (an annual fee, as a percentage of the amount invested) compared to actively managed funds where a manager tries to pick winning stocks, and most actively managed funds fail to beat the market consistently enough to justify their higher fees over the long run -- which is why low-cost index funds are a common recommended starting point for a young investor.

The other core force behind long-term investing is compound growth: investment returns earned in one year themselves start earning returns in following years, so growth accelerates the longer money stays invested. This means time in the market matters enormously -- money invested at 22 has far more years to compound than the same money invested at 32, even at the identical return rate, which is why starting early, even with small amounts, tends to matter more than trying to invest large amounts later. The formula for compound growth is straightforward: future value = principal x (1 + annual return)^number of years.

Worked example: $2,000 invested today at an assumed 7% average annual return, left untouched for 10 years, grows to roughly $2,000 x (1.07)^10 ≈ $3,934 -- about $1,934 of pure growth on top of the original $2,000, without adding another dollar. The longer the time horizon, the larger the share of the ending value that comes from growth rather than the original contribution, which is the practical reason investing (rather than just saving) matters most for long-term goals like retirement.

Recap: diversification spreads out risk, index funds provide broad, low-cost diversification in a single investment, and compound growth means returns earn their own returns over time -- so starting to invest early, even in small amounts, is one of the highest-leverage financial decisions a young person can make.',
   1);

insert into quizzes (id, skill_id, lesson_id, title, pass_threshold) values
  ('00000000-0000-0000-0003-000000000112', '00000000-0000-0000-0001-000000000112', '00000000-0000-0000-0002-000000000112', 'Investing Basics Quiz', 0.8);

insert into quiz_questions (quiz_id, question, options, correct_answer, order_index, difficulty) values
  ('00000000-0000-0000-0003-000000000112', 'What is the core trade-off in investing, per the lesson?',
    '["Higher expected return generally comes with higher risk", "Higher return always means zero risk", "Risk and return are completely unrelated", "Lower risk always means higher return"]'::jsonb,
    'Higher expected return generally comes with higher risk', 1, 'easy'),
  ('00000000-0000-0000-0003-000000000112', 'What does diversification mean?',
    '["Spreading money across many different investments rather than concentrating it in one", "Putting all your money into a single stock you believe in strongly", "Only investing in bonds", "Avoiding investing entirely"]'::jsonb,
    'Spreading money across many different investments rather than concentrating it in one', 2, 'easy'),
  ('00000000-0000-0000-0003-000000000112', 'What is an index fund?',
    '["A single investment that holds many stocks or bonds at once, tracking a broad market index", "A savings account offered only by the government", "A loan made directly to one specific company", "A type of insurance policy"]'::jsonb,
    'A single investment that holds many stocks or bonds at once, tracking a broad market index', 3, 'easy'),
  ('00000000-0000-0000-0003-000000000112', 'Why do index funds typically charge lower fees than actively managed funds, per the lesson?',
    '["They don''t rely on a manager trying to pick individual winning stocks", "They are required by law to charge nothing", "They only invest in one company at a time", "Actively managed funds are always illegal"]'::jsonb,
    'They don''t rely on a manager trying to pick individual winning stocks', 4, 'medium'),
  ('00000000-0000-0000-0003-000000000112', 'What does "compound growth" mean in investing?',
    '["Returns earned in one year themselves start earning returns in following years", "Returns are paid out once and never grow again", "Only the original principal ever earns any return", "Compound growth only applies to bonds, never stocks"]'::jsonb,
    'Returns earned in one year themselves start earning returns in following years', 5, 'medium'),
  ('00000000-0000-0000-0003-000000000112', 'Why does the lesson say starting to invest early matters more than investing larger amounts later, at the same return rate?',
    '["Money invested earlier has more years to compound, so it grows more even from a smaller starting amount", "Later investments always earn a higher return automatically", "Starting early guarantees a specific dollar outcome", "It doesn''t actually matter when you start"]'::jsonb,
    'Money invested earlier has more years to compound, so it grows more even from a smaller starting amount', 6, 'medium'),
  ('00000000-0000-0000-0003-000000000112', 'Using future value = principal x (1 + return)^years, what is the approximate future value of $2,000 invested at 7% for 10 years?',
    '["About $3,934", "About $2,140", "About $14,000", "About $2,700"]'::jsonb,
    'About $3,934', 7, 'medium'),
  ('00000000-0000-0000-0003-000000000112', 'In that $2,000-at-7%-for-10-years example, roughly how much of the ~$3,934 ending value is growth rather than the original contribution?',
    '["About $1,934", "About $200", "About $3,934", "About $700"]'::jsonb,
    'About $1,934', 8, 'hard'),
  ('00000000-0000-0000-0003-000000000112', 'Why is a diversified index fund generally less risky than putting all your money into a single company''s stock?',
    '["It is unlikely that hundreds or thousands of companies all lose value at once for the same reason, unlike a single company that can fail on its own", "Index funds are guaranteed by the government against any loss", "Single stocks always lose value over time", "Diversified funds never go down in value"]'::jsonb,
    'It is unlikely that hundreds or thousands of companies all lose value at once for the same reason, unlike a single company that can fail on its own', 9, 'hard'),
  ('00000000-0000-0000-0003-000000000112', 'Why does the lesson argue that most actively managed funds don''t justify their higher fees over the long run?',
    '["Most fail to beat the market consistently enough to make up for the extra cost of their fees", "Active management is illegal in most markets", "Actively managed funds never hold diversified portfolios", "Fees on actively managed funds are always refunded"]'::jsonb,
    'Most fail to beat the market consistently enough to make up for the extra cost of their fees', 10, 'hard');

-- Case-style modeling exercise: compound growth of a lump-sum investment.
insert into modeling_exercises (id, skill_id, title, instructions, rubric, pass_threshold) values
  ('00000000-0000-0000-0004-000000000007', '00000000-0000-0000-0001-000000000112',
   'Project Compound Growth of a Lump-Sum Investment',
   'You invest $2,000 today at an assumed 7% average annual return, compounded annually, and leave it untouched for 10 years. Using future value = principal x (1 + return)^years, calculate: (1) the future value after 10 years, and (2) the growth amount (future value minus the original $2,000). Submit as {"future_value": <number>, "growth_amount": <number>}.',
   '{"future_value": {"expected": 3934, "tolerance": 60}, "growth_amount": {"expected": 1934, "tolerance": 60}}'::jsonb,
   0.8);

-- ===================== 113: Taxes for a First Job =====================

insert into skills (id, tier, slug, title, prerequisite_skill_id, mastery_threshold) values
  ('00000000-0000-0000-0001-000000000113', 'college', 'taxes-for-a-first-job', 'Taxes for a First Job',
    '00000000-0000-0000-0001-000000000112', 0.8);

insert into lessons (id, skill_id, content_type, content_body, order_index) values
  ('00000000-0000-0000-0002-000000000113', '00000000-0000-0000-0001-000000000113', 'article',
   'Gross pay is what an employer agrees to pay before anything is withheld; net pay ("take-home pay") is what actually lands in a bank account after taxes and other deductions come out. For most first jobs, three kinds of things reduce gross pay: income taxes (federal, and often state), payroll taxes (in the US, Social Security and Medicare, together called FICA, which fund those specific programs and are separate from income tax), and any pre-tax benefit deductions the employee elects, like retirement contributions or health insurance premiums. A new employee fills out a form (in the US, a W-4) that tells the employer how much income tax to withhold from each paycheck as an estimate -- withholding too little can mean owing money at tax time, and withholding too much just means a larger refund later, effectively an interest-free loan to the government in the meantime.

One of the most commonly confused ideas in personal taxes is the difference between a marginal tax rate and an effective tax rate. Income tax systems in the US are progressive and bracketed: income is taxed in layers, with each layer (bracket) taxed at its own rate, and only the income within a bracket is taxed at that bracket''s rate -- not the entire income. The marginal rate is the rate applied to the last dollar earned (the top bracket reached); the effective rate is the average rate actually paid across all income, blending the lower rates paid on the earlier brackets with the higher rate on the top bracket. Because of this, moving into a higher tax bracket does not mean all your income suddenly gets taxed at the higher rate -- only the portion within that new bracket does, so effective rate is always lower than or equal to marginal rate.

Pre-tax deductions reduce taxable income directly: money contributed to a traditional 401(k) or a Health Savings Account, for example, is subtracted from gross pay before income tax is calculated, which lowers the tax bill in the year the contribution is made (the trade-offs of pre-tax vs. after-tax retirement contributions are covered in the retirement accounts lesson). This is different from a tax credit, which reduces the tax bill directly rather than reducing taxable income.

Worked example: with illustrative brackets of 10% on the first $11,000 of taxable income and 12% on the next portion up to $44,000, someone with $40,000 in taxable income pays 10% x $11,000 = $1,100 on the first layer, plus 12% x ($40,000 - $11,000) = 12% x $29,000 = $3,480 on the second layer, for $4,580 total tax. Their marginal rate is 12% (the rate on their last dollar earned), but their effective rate is $4,580 / $40,000 ≈ 11.45% -- noticeably lower than the marginal rate, because only part of their income was taxed at 12%.

Recap: gross pay minus taxes and pre-tax deductions equals net pay; FICA payroll taxes are separate from income tax; and a progressive tax system means only the income within each bracket is taxed at that bracket''s rate, so effective tax rate (the true average) is always lower than the marginal rate most people mistakenly assume applies to their whole paycheck.',
   1);

insert into quizzes (id, skill_id, lesson_id, title, pass_threshold) values
  ('00000000-0000-0000-0003-000000000113', '00000000-0000-0000-0001-000000000113', '00000000-0000-0000-0002-000000000113', 'Taxes for a First Job Quiz', 0.8);

insert into quiz_questions (quiz_id, question, options, correct_answer, order_index, difficulty) values
  ('00000000-0000-0000-0003-000000000113', 'What is the difference between gross pay and net pay?',
    '["Gross pay is before deductions; net pay is what actually lands in your bank account after taxes and deductions", "Gross pay and net pay are always the same number", "Net pay is always higher than gross pay", "Gross pay only applies to salaried employees"]'::jsonb,
    'Gross pay is before deductions; net pay is what actually lands in your bank account after taxes and deductions', 1, 'easy'),
  ('00000000-0000-0000-0003-000000000113', 'What does FICA fund, per the lesson?',
    '["Social Security and Medicare", "State income tax only", "A private employer''s profits", "Federal student loan forgiveness"]'::jsonb,
    'Social Security and Medicare', 2, 'easy'),
  ('00000000-0000-0000-0003-000000000113', 'What is a W-4 form used for?',
    '["Telling an employer how much income tax to withhold from each paycheck", "Filing your final annual tax return", "Applying for a Social Security number", "Requesting a raise"]'::jsonb,
    'Telling an employer how much income tax to withhold from each paycheck', 3, 'easy'),
  ('00000000-0000-0000-0003-000000000113', 'In a progressive, bracketed tax system, how is income actually taxed?',
    '["Each bracket of income is taxed at that bracket''s own rate -- not the entire income at one rate", "All income is taxed at the top bracket''s rate once you reach it", "All income is taxed at the lowest bracket''s rate regardless of amount", "Tax brackets only apply to businesses, not individuals"]'::jsonb,
    'Each bracket of income is taxed at that bracket''s own rate -- not the entire income at one rate', 4, 'medium'),
  ('00000000-0000-0000-0003-000000000113', 'What is the difference between marginal tax rate and effective tax rate?',
    '["Marginal is the rate on the last dollar earned; effective is the average rate paid across all income", "They are always exactly the same number", "Effective rate is always higher than marginal rate", "Marginal rate only applies to businesses"]'::jsonb,
    'Marginal is the rate on the last dollar earned; effective is the average rate paid across all income', 5, 'medium'),
  ('00000000-0000-0000-0003-000000000113', 'Why does withholding too little on a W-4 create a risk at tax time?',
    '["It can mean owing money when filing, if not enough was set aside during the year", "It means the employer must pay a penalty, not the employee", "It automatically increases the employee''s salary", "It has no consequence at all"]'::jsonb,
    'It can mean owing money when filing, if not enough was set aside during the year', 6, 'medium'),
  ('00000000-0000-0000-0003-000000000113', 'How does a pre-tax 401(k) contribution affect an employee''s tax bill in the year it''s made?',
    '["It reduces taxable income, lowering the tax bill that year", "It has no effect on taxes until retirement", "It increases taxable income", "It is taxed twice, once when contributed and once when withdrawn"]'::jsonb,
    'It reduces taxable income, lowering the tax bill that year', 7, 'medium'),
  ('00000000-0000-0000-0003-000000000113', 'Using 10% on the first $11,000 and 12% on the next portion, how much tax is owed on exactly $40,000 of taxable income?',
    '["$4,580", "$4,800", "$4,000", "$3,480"]'::jsonb,
    '$4,580', 8, 'hard'),
  ('00000000-0000-0000-0003-000000000113', 'For that same $40,000 example ($4,580 total tax), what is the approximate effective tax rate?',
    '["About 11.45%", "About 12%", "About 22%", "About 4.58%"]'::jsonb,
    'About 11.45%', 9, 'hard'),
  ('00000000-0000-0000-0003-000000000113', 'Why is it a common misconception to think moving into a higher tax bracket means your entire income gets taxed at that higher rate?',
    '["Because only the income within that new bracket is taxed at the higher rate -- the earlier brackets keep their own lower rates", "Because tax brackets don''t actually exist in practice", "Because higher earners are exempt from the lower brackets", "Because the misconception is actually correct"]'::jsonb,
    'Because only the income within that new bracket is taxed at the higher rate -- the earlier brackets keep their own lower rates', 10, 'hard');

-- ===================== 114: Retirement Accounts (401(k) & IRA Basics) =====================

insert into skills (id, tier, slug, title, prerequisite_skill_id, mastery_threshold) values
  ('00000000-0000-0000-0001-000000000114', 'college', 'retirement-accounts-basics', 'Retirement Accounts: 401(k) & IRA Basics',
    '00000000-0000-0000-0001-000000000113', 0.8);

insert into lessons (id, skill_id, content_type, content_body, order_index) values
  ('00000000-0000-0000-0002-000000000114', '00000000-0000-0000-0001-000000000114', 'article',
   'A 401(k) is a retirement account offered through an employer that lets an employee contribute part of their paycheck, often with the employer adding its own money on top as a "match" -- commonly structured as matching some percentage of what the employee contributes, up to a cap (e.g., 100% of the first 3% of salary). A match is effectively free money that only appears if the employee contributes enough to claim it, which is why contributing at least up to the full match is one of the most commonly repeated pieces of financial advice: turning it down is walking away from part of your own compensation. An IRA (Individual Retirement Account) is similar but opened independently rather than through an employer, useful both as a way to save for retirement outside a job and, in some cases, alongside a 401(k) for additional tax-advantaged saving, subject to its own annual contribution limit.

Both account types come in two main tax treatments. A traditional 401(k) or IRA uses pre-tax contributions -- money goes in before income tax is calculated, lowering taxable income now, but withdrawals in retirement are taxed as ordinary income. A Roth 401(k) or IRA uses after-tax contributions -- money goes in after tax is already paid, so there''s no upfront tax break, but qualified withdrawals in retirement, including all the growth, come out completely tax-free. Which is better depends largely on whether someone expects to be in a higher or lower tax bracket in retirement than they are now: paying tax now (Roth) tends to be better if you expect your rate to rise later; deferring tax (traditional) tends to be better if you expect it to fall.

Because these are retirement accounts, they come with rules discouraging early access: withdrawing traditional or Roth contributions before a set retirement age typically triggers both ordinary income tax on the pre-tax growth and an additional early-withdrawal penalty, on top of losing all the future compound growth that money would otherwise have earned -- one of the biggest hidden costs of raiding a retirement account early is not the penalty itself, but the decades of compounding that withdrawn money never gets to do.

Worked example: an employee earning $50,000/year contributes 5% of salary ($2,500/year) to their 401(k). Their employer matches 100% of contributions up to 3% of salary, so the employer adds $50,000 x 3% = $1,500/year, even though the employee contributed more (5%) than the match cap (3%) -- the match itself is capped at 3%, not the employee''s own contribution. Total money going into the account that year is $2,500 + $1,500 = $4,000, meaning $1,500 of it was compensation the employee would have simply forfeited by contributing less than 3%.

Recap: an employer match is money left on the table if not claimed, so contributing at least up to the match is a near-universal first step; traditional accounts defer tax to retirement while Roth accounts pay tax now for tax-free growth later, and the right choice depends on expected future tax rates; and withdrawing early doesn''t just risk a penalty, it also permanently cuts off decades of compound growth that money would have otherwise had.',
   1);

insert into quizzes (id, skill_id, lesson_id, title, pass_threshold) values
  ('00000000-0000-0000-0003-000000000114', '00000000-0000-0000-0001-000000000114', '00000000-0000-0000-0002-000000000114', 'Retirement Accounts: 401(k) & IRA Basics Quiz', 0.8);

insert into quiz_questions (quiz_id, question, options, correct_answer, order_index, difficulty) values
  ('00000000-0000-0000-0003-000000000114', 'What is a 401(k)?',
    '["A retirement account offered through an employer, often with an employer contribution match", "A type of health insurance plan", "A government-issued tax refund", "A type of student loan"]'::jsonb,
    'A retirement account offered through an employer, often with an employer contribution match', 1, 'easy'),
  ('00000000-0000-0000-0003-000000000114', 'What is an employer 401(k) match, in simple terms?',
    '["The employer contributing its own money on top of what the employee contributes, up to a cap", "A penalty charged for contributing too much", "A loan the employee must repay", "A tax the employer charges on contributions"]'::jsonb,
    'The employer contributing its own money on top of what the employee contributes, up to a cap', 2, 'easy'),
  ('00000000-0000-0000-0003-000000000114', 'What is an IRA?',
    '["An Individual Retirement Account opened independently rather than through an employer", "A type of employer-provided health insurance", "A federal student loan program", "A type of credit card"]'::jsonb,
    'An Individual Retirement Account opened independently rather than through an employer', 3, 'easy'),
  ('00000000-0000-0000-0003-000000000114', 'How does a traditional 401(k)/IRA treat contributions and withdrawals, tax-wise?',
    '["Contributions are pre-tax (lowering taxable income now); withdrawals in retirement are taxed as ordinary income", "Contributions and withdrawals are both entirely tax-free", "Contributions are taxed twice", "Withdrawals are tax-free but contributions are not deductible"]'::jsonb,
    'Contributions are pre-tax (lowering taxable income now); withdrawals in retirement are taxed as ordinary income', 4, 'medium'),
  ('00000000-0000-0000-0003-000000000114', 'How does a Roth 401(k)/IRA differ from a traditional one?',
    '["Contributions are after-tax, but qualified withdrawals in retirement, including growth, are tax-free", "Contributions are pre-tax and withdrawals are also tax-free", "There is no difference between Roth and traditional accounts", "Roth accounts have no contribution limits at all"]'::jsonb,
    'Contributions are after-tax, but qualified withdrawals in retirement, including growth, are tax-free', 5, 'medium'),
  ('00000000-0000-0000-0003-000000000114', 'Why is failing to contribute enough to get a full employer match often described as leaving money on the table?',
    '["The match is essentially free additional compensation that only appears if the employee contributes enough to claim it", "The employer keeps the unclaimed match as extra profit for itself only in theory", "Matches are automatically given regardless of employee contributions", "It has no real financial consequence"]'::jsonb,
    'The match is essentially free additional compensation that only appears if the employee contributes enough to claim it', 6, 'medium'),
  ('00000000-0000-0000-0003-000000000114', 'An employee earning $50,000/year contributes 5% to their 401(k), and the employer matches 100% up to 3% of salary. How much does the employer contribute?',
    '["$1,500", "$2,500", "$4,000", "$1,000"]'::jsonb,
    '$1,500', 7, 'medium'),
  ('00000000-0000-0000-0003-000000000114', 'In that same example, what is the total amount (employee + employer) going into the account that year?',
    '["$4,000", "$2,500", "$1,500", "$5,000"]'::jsonb,
    '$4,000', 8, 'hard'),
  ('00000000-0000-0000-0003-000000000114', 'Per the lesson, what is generally the biggest hidden cost of withdrawing retirement savings early, beyond any penalty?',
    '["Losing the decades of future compound growth that money would have otherwise earned", "Having to close the account permanently", "Losing your job as a result", "None -- there is no meaningful additional cost"]'::jsonb,
    'Losing the decades of future compound growth that money would have otherwise earned', 9, 'hard'),
  ('00000000-0000-0000-0003-000000000114', 'Whether a traditional or Roth account is the better choice for a given person depends mainly on what, per the lesson?',
    '["Whether they expect to be in a higher or lower tax bracket in retirement than they are now", "Which account type has a more attractive account name", "The employee''s age at hire, with no other factor mattering", "Whether the employer offers dental insurance"]'::jsonb,
    'Whether they expect to be in a higher or lower tax bracket in retirement than they are now', 10, 'hard');

-- Case-style modeling exercise: 401(k) contribution + employer match.
insert into modeling_exercises (id, skill_id, title, instructions, rubric, pass_threshold) values
  ('00000000-0000-0000-0004-000000000008', '00000000-0000-0000-0001-000000000114',
   'Calculate the Value of an Employer 401(k) Match',
   'An employee earns $50,000/year and contributes 5% of salary to their 401(k). Their employer matches 100% of contributions up to 3% of salary. Calculate: (1) the employee''s own annual contribution in dollars, (2) the employer''s matching contribution in dollars (remember the match is capped at 3% of salary even though the employee contributed more), and (3) the total annual amount going into the account (employee + employer). Submit as {"your_contribution": <number>, "employer_match": <number>, "total_contribution": <number>}.',
   '{"your_contribution": {"expected": 2500, "tolerance": 25}, "employer_match": {"expected": 1500, "tolerance": 25}, "total_contribution": {"expected": 4000, "tolerance": 25}}'::jsonb,
   0.8);

-- ===================== 115: Insurance Basics =====================

insert into skills (id, tier, slug, title, prerequisite_skill_id, mastery_threshold) values
  ('00000000-0000-0000-0001-000000000115', 'college', 'insurance-fundamentals-for-young-adults', 'Insurance Basics',
    '00000000-0000-0000-0001-000000000114', 0.8);

insert into lessons (id, skill_id, content_type, content_body, order_index) values
  ('00000000-0000-0000-0002-000000000115', '00000000-0000-0000-0001-000000000115', 'article',
   'Insurance is a way of pooling risk: many people pay a smaller, predictable amount (a premium) into a shared pool, so that when a much larger, unpredictable loss happens to any one of them, the pool covers it, rather than that one person bearing the full cost alone. This trade -- a small certain cost in exchange for protection from a large uncertain one -- is the reason insurance exists at all, and it only works because most people paying in won''t file a large claim in any given year, which is what makes the pool large enough to cover the ones who do.

Understanding a policy means understanding a few core terms. The premium is the recurring amount paid to keep coverage active. The deductible is the amount the policyholder pays out of pocket before insurance starts paying anything, on a covered claim. A copay is a smaller, fixed amount paid per service even after the deductible is met. And the out-of-pocket maximum is the most a policyholder will have to pay in a given period, after which the insurer covers 100% of further covered costs. These interact directly: a plan with a lower premium usually has a higher deductible (you pay less monthly, but more if something actually happens), while a plan with a higher premium usually has a lower deductible (you pay more monthly, but less if something happens) -- neither is universally better, it depends on how likely and how large a claim is expected to be.

For a young adult starting out, a few types of insurance matter most. Health insurance protects against medical costs, often the single largest financial risk a young person faces if uninsured. Renters insurance is inexpensive and covers a tenant''s belongings and liability inside a rented space -- a landlord''s own insurance typically only covers the building, not the tenant''s possessions. Auto insurance is usually legally required to drive and covers damage/liability from accidents. Disability insurance replaces a portion of income if illness or injury prevents working -- often overlooked, even though the odds of a working-age person experiencing a disabling condition are higher than many assume. Term life insurance (a policy that pays out only if the insured dies within a set term, with no cash-value component) is generally only worth considering once someone has dependents relying on their income -- it is usually not a priority for a single young adult with no dependents.

Worked example: comparing two health plans, Plan A has a $50/month premium and a $3,000 deductible; Plan B has a $150/month premium and a $500 deductible. Over a year with no major medical claims, Plan A costs $600 in premiums total, while Plan B costs $1,800 -- Plan A is cheaper if nothing happens. But if a $4,000 claim occurs, Plan A costs $600 (premiums) + $3,000 (deductible, since the claim exceeds it) = $3,600, while Plan B costs $1,800 (premiums) + $500 (deductible) = $2,300 -- Plan B ends up cheaper overall despite the higher premium, because its lower deductible limits the damage from the large claim.

Recap: insurance pools risk so a small certain premium replaces exposure to a large uncertain loss; premium and deductible trade off against each other, and which combination is "better" depends on how likely a claim actually is; and for most young adults, health, renters, auto (if driving), and disability insurance matter far more immediately than life insurance, which usually only becomes relevant once there are dependents to protect.',
   1);

insert into quizzes (id, skill_id, lesson_id, title, pass_threshold) values
  ('00000000-0000-0000-0003-000000000115', '00000000-0000-0000-0001-000000000115', '00000000-0000-0000-0002-000000000115', 'Insurance Basics Quiz', 0.8);

insert into quiz_questions (quiz_id, question, options, correct_answer, order_index, difficulty) values
  ('00000000-0000-0000-0003-000000000115', 'What is the basic idea behind insurance, per the lesson?',
    '["Pooling risk: many people pay a small premium so the pool can cover a large loss for whoever experiences one", "Guaranteeing that nobody in the pool ever experiences a loss", "A government program that replaces the need for savings", "A way to avoid ever paying for medical care"]'::jsonb,
    'Pooling risk: many people pay a small premium so the pool can cover a large loss for whoever experiences one', 1, 'easy'),
  ('00000000-0000-0000-0003-000000000115', 'What is a deductible?',
    '["The amount the policyholder pays out of pocket before insurance starts paying on a covered claim", "The monthly amount paid to keep a policy active", "The maximum amount an insurer will ever pay in total", "A fee charged only when filing a false claim"]'::jsonb,
    'The amount the policyholder pays out of pocket before insurance starts paying on a covered claim', 2, 'easy'),
  ('00000000-0000-0000-0003-000000000115', 'What is a premium?',
    '["The recurring amount paid to keep coverage active", "The amount paid only when a claim is filed", "The maximum payout of a policy", "A one-time signup fee"]'::jsonb,
    'The recurring amount paid to keep coverage active', 3, 'easy'),
  ('00000000-0000-0000-0003-000000000115', 'What does renters insurance typically cover that a landlord''s own insurance usually does not?',
    '["The tenant''s personal belongings and liability inside the rented space", "The entire building structure", "The landlord''s mortgage payments", "Other tenants'' belongings"]'::jsonb,
    'The tenant''s personal belongings and liability inside the rented space', 4, 'medium'),
  ('00000000-0000-0000-0003-000000000115', 'What does disability insurance protect against, per the lesson?',
    '["Loss of income if illness or injury prevents someone from working", "Damage to a rented apartment", "Theft of a vehicle", "Medical costs specifically for dependents"]'::jsonb,
    'Loss of income if illness or injury prevents someone from working', 5, 'medium'),
  ('00000000-0000-0000-0003-000000000115', 'Why does the lesson say term life insurance is generally not a priority for a single young adult with no dependents?',
    '["Its main purpose is replacing income for dependents who rely on the insured person, which doesn''t apply without dependents", "Life insurance is illegal for anyone under 30", "Life insurance policies never pay out under any circumstance", "It always costs more than health insurance"]'::jsonb,
    'Its main purpose is replacing income for dependents who rely on the insured person, which doesn''t apply without dependents', 6, 'medium'),
  ('00000000-0000-0000-0003-000000000115', 'Generally, how does a lower monthly premium plan compare to a higher premium plan on deductible?',
    '["A lower-premium plan usually has a higher deductible, and vice versa", "Premium and deductible are always unrelated", "A lower-premium plan always has a lower deductible too", "Deductibles are fixed by law regardless of premium"]'::jsonb,
    'A lower-premium plan usually has a higher deductible, and vice versa', 7, 'medium'),
  ('00000000-0000-0000-0003-000000000115', 'Comparing Plan A ($50/mo premium, $3,000 deductible) and Plan B ($150/mo premium, $500 deductible) over a year with zero claims, which plan costs less?',
    '["Plan A ($600 vs $1,800 in premiums)", "Plan B", "They cost exactly the same", "Neither plan has any cost with zero claims"]'::jsonb,
    'Plan A ($600 vs $1,800 in premiums)', 8, 'hard'),
  ('00000000-0000-0000-0003-000000000115', 'In that same comparison, if a $4,000 claim occurs, which plan ends up cheaper in total for the year?',
    '["Plan B ($2,300 total vs Plan A''s $3,600 total)", "Plan A", "They cost exactly the same after a claim", "Neither plan covers a $4,000 claim"]'::jsonb,
    'Plan B ($2,300 total vs Plan A''s $3,600 total)', 9, 'hard'),
  ('00000000-0000-0000-0003-000000000115', 'What is the out-of-pocket maximum, and why does it matter?',
    '["The most a policyholder will pay in a period before the insurer covers 100% of further costs -- it caps the worst-case financial exposure", "The minimum amount that must be paid before any coverage begins", "A one-time enrollment fee unrelated to claims", "The total amount an insurer will ever pay across a lifetime"]'::jsonb,
    'The most a policyholder will pay in a period before the insurer covers 100% of further costs -- it caps the worst-case financial exposure', 10, 'hard');

-- ===================== 116: Negotiating Salary =====================

insert into skills (id, tier, slug, title, prerequisite_skill_id, mastery_threshold) values
  ('00000000-0000-0000-0001-000000000116', 'college', 'negotiating-salary', 'Negotiating Salary',
    '00000000-0000-0000-0001-000000000115', 0.8);

insert into lessons (id, skill_id, content_type, content_body, order_index) values
  ('00000000-0000-0000-0002-000000000116', '00000000-0000-0000-0001-000000000116', 'article',
   'Salary negotiation is one of the highest-leverage financial conversations most people ever have, because a raise negotiated once doesn''t just apply to a single paycheck -- it typically becomes the new baseline that future raises, bonuses (often calculated as a percentage of salary), and even future employers'' offers get built on top of. Yet many candidates, especially early in their careers, skip negotiating entirely out of fear of seeming greedy or risking the offer -- in reality, most employers expect some negotiation and build a small amount of room into their initial offer specifically anticipating it.

Preparation is what separates an effective negotiation from an awkward one. Before any conversation happens, research the market rate for the specific role, level, and location using salary-data sites and, where possible, conversations with people in similar roles -- a number grounded in real market data is far more persuasive than a number chosen because it "feels right." It also helps to evaluate total compensation, not just base salary: signing bonuses, equity, retirement matching, and other benefits all have real dollar value and are sometimes more flexible for an employer to move on than base salary itself, especially if the base salary band is fixed by internal policy.

Timing and framing matter as much as the number itself. The strongest point to negotiate is after receiving a formal offer, not before -- naming a number too early, before the employer has committed to wanting you specifically, gives away information without leverage. When asked "what''s your expected salary" earlier in a process, redirecting toward the employer''s budgeted range, or citing researched market data rather than a specific personal number, avoids anchoring yourself too low before an offer even exists. Once a real offer is in hand, a simple, confident, non-confrontational framing works well: expressing genuine enthusiasm for the role, citing the specific market data supporting a higher number, and asking directly if there''s room to move closer to it -- silence after making the ask is normal and not a sign anything has gone wrong.

Worked example: a candidate receives an offer of $58,000 for a role where market research shows a typical range of $58,000-$68,000 for the position and experience level in that location. Simply saying "based on my research into typical compensation for this role in this market, I was expecting something closer to $64,000 -- is there flexibility to get closer to that?" is grounded, specific, and non-confrontational. If the employer counters at $61,000, that $3,000 increase, compounded across years of subsequent raises calculated as a percentage of a higher base, is worth meaningfully more over a career than the one-time gain in the first year alone.

Recap: negotiate after an offer, not before; ground any number in researched market data rather than a personal guess; consider total compensation, not just base salary, since some elements may have more room to move; and remember that a single successful negotiation compounds over an entire career, since future raises typically build on top of the number you land on now.',
   1);

insert into quizzes (id, skill_id, lesson_id, title, pass_threshold) values
  ('00000000-0000-0000-0003-000000000116', '00000000-0000-0000-0001-000000000116', '00000000-0000-0000-0002-000000000116', 'Negotiating Salary Quiz', 0.8);

insert into quiz_questions (quiz_id, question, options, correct_answer, order_index, difficulty) values
  ('00000000-0000-0000-0003-000000000116', 'Why does the lesson describe salary negotiation as high-leverage, beyond the first paycheck?',
    '["A negotiated raise typically becomes the baseline future raises and offers build on top of", "It only ever affects a single paycheck and nothing else", "It has no effect on future compensation", "It only matters for senior executives"]'::jsonb,
    'A negotiated raise typically becomes the baseline future raises and offers build on top of', 1, 'easy'),
  ('00000000-0000-0000-0003-000000000116', 'When is the strongest point to negotiate salary, per the lesson?',
    '["After receiving a formal offer", "Before the first interview", "During the very first phone screen", "Negotiation should never happen at any point"]'::jsonb,
    'After receiving a formal offer', 2, 'easy'),
  ('00000000-0000-0000-0003-000000000116', 'What does "total compensation" include, beyond base salary?',
    '["Signing bonuses, equity, retirement matching, and other benefits", "Only the base salary number", "Just the job title", "Only the number of vacation days"]'::jsonb,
    'Signing bonuses, equity, retirement matching, and other benefits', 3, 'easy'),
  ('00000000-0000-0000-0003-000000000116', 'Why does the lesson recommend grounding a requested number in market research rather than a personal guess?',
    '["A number grounded in real data is more persuasive and defensible than one that just \"feels right\"", "Market research is legally required before any negotiation", "Personal guesses are always higher than market data", "Employers only accept numbers with no justification at all"]'::jsonb,
    'A number grounded in real data is more persuasive and defensible than one that just "feels right"', 4, 'medium'),
  ('00000000-0000-0000-0003-000000000116', 'Why might it be risky to name a specific salary number very early in an interview process, before an offer exists?',
    '["It gives away information without leverage, before the employer has committed to wanting you specifically", "It is illegal to ask for a specific number that early", "Employers always increase the offer automatically when this happens", "It guarantees a lower final offer no matter what"]'::jsonb,
    'It gives away information without leverage, before the employer has committed to wanting you specifically', 5, 'medium'),
  ('00000000-0000-0000-0003-000000000116', 'Why does the lesson say many employers actually expect some negotiation and build room into an initial offer?',
    '["Because negotiation is a normal, expected part of hiring, not an unusual or greedy request", "Because initial offers are always a mistake that must be corrected", "Because negotiating is required by law in every job offer", "Because employers prefer candidates who never negotiate"]'::jsonb,
    'Because negotiation is a normal, expected part of hiring, not an unusual or greedy request', 6, 'medium'),
  ('00000000-0000-0000-0003-000000000116', 'In the worked example, the candidate is offered $58,000 where market data shows a $58,000-$68,000 range. What number do they ask for, and how do they justify it?',
    '["$64,000, justified by citing researched market data for the role", "$100,000, with no justification given", "$58,000, since that matches the initial offer exactly", "$68,000, justified only by personal preference"]'::jsonb,
    '$64,000, justified by citing researched market data for the role', 7, 'medium'),
  ('00000000-0000-0000-0003-000000000116', 'Why does the lesson suggest that some elements of total compensation, like a signing bonus, may have more room to negotiate than base salary?',
    '["Base salary is sometimes fixed by internal policy bands in a way other elements aren''t", "Signing bonuses are always larger than base salary", "Base salary can never legally be discussed", "Non-salary compensation is always worth less than salary"]'::jsonb,
    'Base salary is sometimes fixed by internal policy bands in a way other elements aren''t', 8, 'hard'),
  ('00000000-0000-0000-0003-000000000116', 'If a candidate successfully negotiates a $3,000 higher starting salary, why does the lesson describe this as worth more than $3,000 over a career?',
    '["Because future raises and bonuses are typically calculated as a percentage of a now-higher base, compounding the gain over time", "Because the $3,000 itself grows through investment automatically", "Because base salary never changes again after the first year", "It isn''t worth more, $3,000 is a one-time gain only"]'::jsonb,
    'Because future raises and bonuses are typically calculated as a percentage of a now-higher base, compounding the gain over time', 9, 'hard'),
  ('00000000-0000-0000-0003-000000000116', 'When asked "what''s your expected salary" early in an interview process, what does the lesson suggest instead of naming a specific personal number?',
    '["Redirecting toward the employer''s budgeted range or citing researched market data", "Immediately naming the highest number you can think of", "Refusing to answer the question in any way", "Always naming a number lower than you actually want"]'::jsonb,
    'Redirecting toward the employer''s budgeted range or citing researched market data', 10, 'hard');

-- ===================== 117: Side Income & Freelancing Finance =====================

insert into skills (id, tier, slug, title, prerequisite_skill_id, mastery_threshold) values
  ('00000000-0000-0000-0001-000000000117', 'college', 'side-income-and-freelancing-finance', 'Side Income & Freelancing Finance',
    '00000000-0000-0000-0001-000000000116', 0.8);

insert into lessons (id, skill_id, content_type, content_body, order_index) values
  ('00000000-0000-0000-0002-000000000117', '00000000-0000-0000-0001-000000000117', 'article',
   'Income from a traditional job and income from freelancing or a side hustle are treated very differently by the tax system, and understanding that difference matters the first time it applies to you. A traditional employer withholds income tax and FICA payroll taxes automatically from every paycheck (reported on a W-2 in the US), so the employee rarely has to think about tax mechanics day to day. Freelance or self-employed income (often reported to the freelancer via a 1099 in the US) has no automatic withholding at all -- the full amount is paid out, and the freelancer is personally responsible for setting aside and paying their own taxes, including both income tax and the self-employment tax equivalent of FICA (since there''s no employer to split that cost, a self-employed person effectively pays both the employee and employer share).

Because no tax is withheld automatically, self-employed income above a certain threshold generally requires paying estimated taxes quarterly throughout the year, rather than settling everything at once when filing an annual return -- skipping this and paying it all at once at tax time can trigger an underpayment penalty on top of the tax owed itself, since the system expects tax to be paid roughly as the income is earned, not all at year-end. A simple, commonly cited rule of thumb is to set aside roughly 25-30% of every freelance payment received, in a separate account, specifically earmarked for taxes -- treating that portion as never really "available" to spend in the first place, the same logic as budgeting for an irregular expense.

Freelancers can also deduct legitimate business expenses (a laptop used for the work, software subscriptions, a portion of home internet used for client work, business travel) from their income before calculating tax owed, which is why keeping organized records and receipts throughout the year matters -- expenses that are never tracked can''t be deducted, even if they were legitimately incurred. Keeping business and personal finances separate (a dedicated bank account, even for a small side hustle) makes this tracking dramatically easier than trying to reconstruct it from a single mixed account at tax time.

Worked example: a student earns $4,000 over a year from freelance design work. Setting aside 28% for taxes as each payment arrives means $1,120 is moved to a separate tax account throughout the year, leaving $2,880 treated as actually spendable income. If $500 of that $4,000 was spent on a laptop used substantially for the freelance work, that $500 is a legitimate deductible business expense, reducing the taxable income the 28% estimate should really be calculated against -- a reason to track expenses as they happen rather than guessing at tax time.

Recap: freelance/self-employed income has no automatic tax withholding, so the freelancer is responsible for setting aside their own taxes (commonly 25-30% of each payment) and often for paying them quarterly; legitimate business expenses can reduce the taxable amount, but only if they''re actually tracked; and separating business and personal finances from the start makes all of this dramatically more manageable than untangling it later.',
   1);

insert into quizzes (id, skill_id, lesson_id, title, pass_threshold) values
  ('00000000-0000-0000-0003-000000000117', '00000000-0000-0000-0001-000000000117', '00000000-0000-0000-0002-000000000117', 'Side Income & Freelancing Finance Quiz', 0.8);

insert into quiz_questions (quiz_id, question, options, correct_answer, order_index, difficulty) values
  ('00000000-0000-0000-0003-000000000117', 'How does a traditional employer typically handle taxes on an employee''s paycheck?',
    '["It automatically withholds income tax and FICA payroll taxes from every paycheck", "It pays no taxes on the employee''s behalf under any circumstance", "It only withholds taxes once a year", "It withholds taxes only for employees earning over $1 million"]'::jsonb,
    'It automatically withholds income tax and FICA payroll taxes from every paycheck', 1, 'easy'),
  ('00000000-0000-0000-0003-000000000117', 'How is freelance/self-employed income typically different, tax-wise, from traditional employment income?',
    '["It has no automatic tax withholding -- the freelancer must set aside and pay their own taxes", "It is entirely tax-exempt", "It is taxed at a permanently lower rate than employment income", "It is taxed exactly the same way in every respect"]'::jsonb,
    'It has no automatic tax withholding -- the freelancer must set aside and pay their own taxes', 2, 'easy'),
  ('00000000-0000-0000-0003-000000000117', 'What rule of thumb does the lesson cite for how much of each freelance payment to set aside for taxes?',
    '["Roughly 25-30%", "Roughly 1%", "Exactly 50%", "Nothing needs to be set aside until the year ends"]'::jsonb,
    'Roughly 25-30%', 3, 'easy'),
  ('00000000-0000-0000-0003-000000000117', 'Why might a freelancer need to pay estimated taxes quarterly rather than all at once when filing?',
    '["The tax system expects tax to be paid roughly as income is earned, and paying it all at once can trigger an underpayment penalty", "Quarterly payments are always smaller in total than paying once a year", "It is purely optional and has no effect on penalties either way", "Freelancers are legally forbidden from paying taxes just once a year under any circumstance"]'::jsonb,
    'The tax system expects tax to be paid roughly as income is earned, and paying it all at once can trigger an underpayment penalty', 4, 'medium'),
  ('00000000-0000-0000-0003-000000000117', 'Why does a self-employed person effectively pay "both the employee and employer share" of FICA-equivalent tax?',
    '["Because there is no separate employer to split that cost with, unlike a traditional job", "Because self-employed people are taxed at double the rate for no reason", "Because FICA doesn''t apply to self-employed people at all", "Because it is a voluntary extra payment with no requirement behind it"]'::jsonb,
    'Because there is no separate employer to split that cost with, unlike a traditional job', 5, 'medium'),
  ('00000000-0000-0000-0003-000000000117', 'What can a freelancer generally deduct from their income before calculating tax owed?',
    '["Legitimate business expenses, like a laptop or software used for the work", "Personal grocery bills unrelated to the work", "Any expense at all, whether business-related or not", "Nothing -- freelancers cannot deduct any expenses"]'::jsonb,
    'Legitimate business expenses, like a laptop or software used for the work', 6, 'medium'),
  ('00000000-0000-0000-0003-000000000117', 'A student earns $4,000 freelancing and sets aside 28% for taxes as payments arrive. How much is set aside for taxes in total?',
    '["$1,120", "$2,880", "$400", "$4,000"]'::jsonb,
    '$1,120', 7, 'medium'),
  ('00000000-0000-0000-0003-000000000117', 'In that same example, how much of the $4,000 is left treated as actually spendable after setting aside the 28% tax portion?',
    '["$2,880", "$1,120", "$4,000", "$3,500"]'::jsonb,
    '$2,880', 8, 'hard'),
  ('00000000-0000-0000-0003-000000000117', 'Why does the lesson recommend keeping business and personal finances in separate accounts, even for a small side hustle?',
    '["It makes tracking deductible expenses and tax set-asides dramatically easier than reconstructing it later from one mixed account", "It is a legal requirement for any income over $10", "Separate accounts automatically calculate taxes for you", "It has no practical benefit, it is just a personal preference"]'::jsonb,
    'It makes tracking deductible expenses and tax set-asides dramatically easier than reconstructing it later from one mixed account', 9, 'hard'),
  ('00000000-0000-0000-0003-000000000117', 'Why does the lesson stress tracking business expenses and receipts throughout the year rather than at tax time?',
    '["Expenses that are never tracked can''t be deducted, even if they were legitimately incurred", "Tracking expenses is only required for expenses over $10,000", "Untracked expenses are automatically deducted anyway", "It has no bearing on what can eventually be deducted"]'::jsonb,
    'Expenses that are never tracked can''t be deducted, even if they were legitimately incurred', 10, 'hard');

-- ===================== 118: Financial Planning for Post-Grad Life (capstone) =====================

insert into skills (id, tier, slug, title, prerequisite_skill_id, mastery_threshold) values
  ('00000000-0000-0000-0001-000000000118', 'college', 'financial-planning-for-post-grad-life', 'Financial Planning for Post-Grad Life',
    '00000000-0000-0000-0001-000000000117', 0.8);

insert into lessons (id, skill_id, content_type, content_body, order_index) values
  ('00000000-0000-0000-0002-000000000118', '00000000-0000-0000-0001-000000000118', 'article',
   'Every topic covered so far in College tier -- budgeting, debt, credit, investing, taxes, retirement accounts, insurance, salary, and side income -- comes together the moment a real paycheck starts arriving after graduation, often all at once and with no obvious order of operations. A widely used priority framework helps resolve that: (1) build a small starter emergency fund (roughly $500-$1,000) before anything else, so an unexpected cost doesn''t force a return to high-interest debt; (2) aggressively pay down any high-interest debt (generally anything in double-digit APR territory, like most credit cards), since that guaranteed "return" from avoided interest usually beats what investing could realistically earn in the meantime; (3) build a fuller emergency fund (commonly 3-6 months of essential expenses); (4) contribute to retirement accounts, at minimum up to any employer match; and (5) direct further money toward other goals -- additional investing, a house down payment, or further debt payoff.

This order isn''t rigid dogma -- it bends around real exceptions. If an employer offers a 401(k) match, contributing at least enough to capture that match usually still makes sense even before high-interest debt is fully paid off, because a 100% (or 50%) instant return from a match is difficult for any debt-interest-rate comparison to beat. Someone with only low-interest debt (a subsidized student loan at 5%, say) has much more room to invest instead of aggressively prepaying that loan than someone carrying a 22% credit card balance. The framework is a reasonable default ordering, not a rule that ignores someone''s specific numbers.

The first few months after starting a full-time job also bring genuinely new expenses and decisions that didn''t exist as a student: choosing employer benefits during open enrollment (health insurance tier, whether to opt into a Health Savings Account, life/disability insurance elections), setting a 401(k) contribution rate on day one rather than "getting to it later," budgeting for costs that scale with a real income (rent for an independent apartment instead of a shared dorm, commuting, work-appropriate clothing), and starting to track net worth (total assets minus total debts) as a single number that captures whether all these pieces, together, are actually moving in the right direction over time.

Worked example: a new graduate starts a $55,000/year job with $3,000 in savings, $6,000 in credit card debt at 22% APR, and no 401(k) match in year one. Applying the framework: their $3,000 savings already covers a starter emergency fund, so step 1 is effectively done; step 2 means directing extra cash toward the 22% debt aggressively, since no guaranteed alternative return comes close to a guaranteed 22% cost avoided; only once that debt is cleared does it make sense to move to building a fuller 3-6 month emergency fund and then meaningful retirement contributions, though even in year one, contributing something to start the retirement account habit (even a small amount) has value beyond the dollar figure itself.

Recap: post-grad financial planning is less about learning any single new concept and more about sequencing the concepts already covered -- starter emergency fund, high-interest debt, fuller emergency fund, retirement (at least to the match), then other goals -- while staying flexible around genuine exceptions like an employer match. Tracking net worth over time is a simple way to confirm that all of these individual decisions are actually adding up to real progress.',
   1);

insert into quizzes (id, skill_id, lesson_id, title, pass_threshold) values
  ('00000000-0000-0000-0003-000000000118', '00000000-0000-0000-0001-000000000118', '00000000-0000-0000-0002-000000000118', 'Financial Planning for Post-Grad Life Quiz', 0.8);

insert into quiz_questions (quiz_id, question, options, correct_answer, order_index, difficulty) values
  ('00000000-0000-0000-0003-000000000118', 'What is the first step in the priority framework described in the lesson?',
    '["Build a small starter emergency fund (roughly $500-$1,000)", "Immediately max out retirement contributions", "Pay off all debt before saving anything", "Invest everything in the stock market immediately"]'::jsonb,
    'Build a small starter emergency fund (roughly $500-$1,000)', 1, 'easy'),
  ('00000000-0000-0000-0003-000000000118', 'What is net worth, as described in the lesson?',
    '["Total assets minus total debts", "Total annual salary before taxes", "The amount in a checking account only", "The total value of all debt owed"]'::jsonb,
    'Total assets minus total debts', 2, 'easy'),
  ('00000000-0000-0000-0003-000000000118', 'What size is a "fuller" emergency fund generally considered to be, per the framework, once high-interest debt is handled?',
    '["3-6 months of essential expenses", "One week of expenses", "A flat $10,000 regardless of expenses", "A full year of gross income"]'::jsonb,
    '3-6 months of essential expenses', 3, 'easy'),
  ('00000000-0000-0000-0003-000000000118', 'Why does the framework place aggressive high-interest debt payoff before building a fuller emergency fund?',
    '["The guaranteed cost avoided from high-interest debt usually exceeds what could realistically be earned elsewhere in the meantime", "High-interest debt has no real cost associated with it", "Emergency funds are never actually useful", "It doesn''t -- the framework places debt payoff last"]'::jsonb,
    'The guaranteed cost avoided from high-interest debt usually exceeds what could realistically be earned elsewhere in the meantime', 4, 'medium'),
  ('00000000-0000-0000-0003-000000000118', 'Why does the lesson say capturing an employer 401(k) match usually still makes sense even before high-interest debt is fully paid off?',
    '["An instant match return (e.g., 50-100%) is difficult for almost any debt-interest comparison to beat", "Employer matches are always larger than any credit card balance", "It doesn''t -- matches should always wait until all debt is paid", "401(k) contributions have no relationship to employer matches"]'::jsonb,
    'An instant match return (e.g., 50-100%) is difficult for almost any debt-interest comparison to beat', 5, 'medium'),
  ('00000000-0000-0000-0003-000000000118', 'Name a genuinely new type of decision or expense the lesson says shows up in the first months of a full-time job that didn''t exist as a student.',
    '["Choosing employer benefits during open enrollment", "Choosing a favorite class elective", "Deciding on a college major", "Picking a dorm roommate"]'::jsonb,
    'Choosing employer benefits during open enrollment', 6, 'medium'),
  ('00000000-0000-0000-0003-000000000118', 'A graduate has $3,000 in savings and $6,000 in credit card debt at 22% APR, with no 401(k) match in year one. Per the framework, what should they prioritize?',
    '["Aggressively paying down the 22% APR debt, since their starter emergency fund is already effectively covered", "Investing the $3,000 immediately in the stock market", "Ignoring the debt entirely since it will resolve itself", "Spending the $3,000 rather than keeping it as savings"]'::jsonb,
    'Aggressively paying down the 22% APR debt, since their starter emergency fund is already effectively covered', 7, 'medium'),
  ('00000000-0000-0000-0003-000000000118', 'Why does someone with only low-interest debt (e.g., a 5% subsidized loan) have more room to invest instead of aggressively prepaying that loan, compared to someone with 22% credit card debt?',
    '["The guaranteed \"return\" from prepaying a low-rate loan is much smaller, so investing has a more competitive expected return by comparison", "Low-interest debt is always illegal to prepay early", "Investing always beats every debt rate regardless of the number", "There is no real difference between the two situations"]'::jsonb,
    'The guaranteed "return" from prepaying a low-rate loan is much smaller, so investing has a more competitive expected return by comparison', 8, 'hard'),
  ('00000000-0000-0000-0003-000000000118', 'Why does the lesson describe the 5-step priority framework as "a reasonable default ordering, not a rule that ignores someone''s specific numbers"?',
    '["Because real exceptions (like an employer match, or unusually low-interest debt) can rationally change the order for a given person''s actual situation", "Because the framework is entirely random and has no real logic behind it", "Because the steps must always be followed in the exact order with zero exceptions", "Because the framework only applies to people earning over $100,000"]'::jsonb,
    'Because real exceptions (like an employer match, or unusually low-interest debt) can rationally change the order for a given person''s actual situation', 9, 'hard'),
  ('00000000-0000-0000-0003-000000000118', 'Why does the lesson recommend tracking net worth as a single number over time, rather than looking at any one account in isolation?',
    '["It captures whether all the individual budgeting, debt, saving, and investing decisions together are actually producing real progress", "Net worth is the only number that determines credit score", "Tracking any single account is always more informative than net worth", "Net worth has no practical use for a recent graduate"]'::jsonb,
    'It captures whether all the individual budgeting, debt, saving, and investing decisions together are actually producing real progress', 10, 'hard');
