-- Content depth pass: College tier. The original Phase 3 seed
-- (00000000000016) was explicitly a schema-validation fixture -- one
-- paragraph per lesson, 2 recall-only questions per quiz, and a
-- single-step modeling exercise despite its own lesson describing a
-- full 3-statement link. This migration:
--   1. Expands each lesson's content_body with a worked numeric example
--      and a recap (lesson ids unchanged).
--   2. Adds 3-4 more questions per quiz, at least half application/scenario.
--   3. Replaces the modeling exercise with a multi-step build (revenue ->
--      COGS -> gross profit -> net income) that is a closer match to the
--      3-statement link its lesson describes, while staying inside
--      grade_modeling_submission's existing numeric-tolerance rubric
--      pattern (see 00000000000023_grade_modeling_submission_idempotent.sql)
--      -- no RPC change needed, since it already grades an arbitrary
--      jsonb-keyed rubric.

update lessons set content_body =
  'Finance careers span very different day-to-day work: investment bankers advise companies on raising capital and M&A; quants build mathematical trading and risk models; risk managers measure and limit a firm''s exposure to loss; operations ("ops") keeps trades settling and records accurate; and fintech product managers build the software finance runs on. Pay, hours, and required skills vary a lot across these roles -- there is no single "finance job."

These roles also differ in what skills matter most day to day. Investment banking leans on relationship-building, financial modeling under time pressure, and presentation polish. Quant and risk roles lean on statistics, programming, and probability. Ops leans on process discipline and accuracy under volume. Product management leans on translating between engineers and finance domain experts. Picking a path is partly about which of those skill sets you actually enjoy using, not just which pays the most.

Worked example: two graduates, Elena and Marcus, both join a bank. Elena joins as an investment banking analyst -- her week includes building a valuation model for a client pitch, formatting slides until midnight before a meeting, and calling company management to gather data. Marcus joins as a risk analyst -- his week includes running a script that recalculates the bank''s exposure to a market swing, flagging a trading desk that has exceeded its risk limit, and writing a one-page summary for a risk committee. Same industry, same starting pay band roughly, almost entirely different daily work.

Recap: "finance" is not one job -- it is a set of very different roles (banking, quant, risk, ops, fintech product) with different day-to-day work, skills, and cultures. Comparing roles by what the work actually involves, not just the industry label, is the right way to decide what fits.',
  order_index = 1
where id = '00000000-0000-0000-0002-000000000101';

update lessons set content_body =
  'Capital markets are where companies and governments raise money and investors trade it. The primary market is where a security (like a new stock or bond) is first sold to raise capital; the secondary market is where investors then trade that security among themselves, like a stock exchange. Prices in the secondary market move on supply, demand, and new information, and don''t change how much money the original issuer raised.

This distinction matters because it explains a common confusion: if a company''s stock price rises 10% today, the company itself does not receive any extra cash from that -- it already collected its money when it originally sold those shares in the primary market (an IPO, for example, or a later share issuance). Everyday buying and selling of existing shares on an exchange is investors trading with each other, not investors giving money directly to the company.

Worked example: Northwind Ltd sells 1 million new shares at £10 each in an IPO (primary market), raising £10 million for the company. The next day, those shares start trading on a stock exchange. An investor, Priya, buys 100 shares from another investor, Tom, at £11 each (secondary market) -- £1,100 changes hands between Priya and Tom. Northwind Ltd receives none of that £1,100; its £10 million was raised the day before, once, in the primary market.

Recap: the primary market is where new securities are sold and capital is actually raised by the issuer, one time; the secondary market is where existing securities trade afterward between investors, and those trades move prices but not the issuer''s cash.',
  order_index = 1
where id = '00000000-0000-0000-0002-000000000102';

update lessons set content_body =
  'Valuing a company means estimating what it is worth. Two common approaches: comparable-company analysis ("comps"), which prices a company relative to similar public companies using ratios like price-to-earnings; and discounted cash flow (DCF), which estimates a company''s value as the sum of its expected future cash flows, adjusted ("discounted") to reflect that money in the future is worth less than money today.

"Comps" is fast and grounded in real market prices, but it assumes similar companies really are comparable and that the market is pricing them sensibly right now. DCF does not depend on other companies''s prices at all, but it is very sensitive to assumptions about future growth and the discount rate used -- small changes to those assumptions can swing the estimated value a lot. In practice, analysts often use both and treat the gap between them as useful information, not a flaw.

Worked example (comps): Riverside Co earns £2 million in annual profit. Three similar public companies trade at an average price-to-earnings (P/E) ratio of 15x. Applying that same multiple: estimated value = £2,000,000 x 15 = £30,000,000.
Worked example (why discounting matters in DCF): £1,000 promised to you in exactly one year is worth less than £1,000 in your hand today, because you could invest today''s £1,000 and have more than £1,000 in a year -- so a DCF "discounts" (reduces) each future year''s cash flow before adding them up, with cash flows further in the future discounted more.

Recap: comps values a company by comparing it to similar public companies'' pricing ratios; DCF values a company by projecting its future cash flows and discounting them to reflect that future money is worth less than money today. Neither is "more correct" on its own -- they answer the same question from different angles.',
  order_index = 1
where id = '00000000-0000-0000-0002-000000000103';

update lessons set content_body =
  'A financial model links a company''s three core statements -- income statement, balance sheet, and cash flow statement -- so that changing one assumption (like revenue growth) flows through consistently to the others. Analysts build these in a spreadsheet to project a company''s future performance and test "what if" scenarios, like the effect of a price increase or a new cost.

The income statement shows profitability over a period (revenue minus costs equals net income); the balance sheet shows what a company owns and owes at a single point in time (assets, liabilities, equity); the cash flow statement shows how cash actually moved, which is not the same thing as profit because some income-statement items (like depreciation) don''t involve any cash changing hands. A "linked" model means net income from the income statement flows into both retained earnings on the balance sheet and the starting point of the cash flow statement, so the three stay consistent with each other automatically when an assumption changes.

Worked example: a simplified income-statement build for one year -- revenue £2,160,000, cost of goods sold (COGS) at 60% of revenue = £1,296,000, giving gross profit of £2,160,000 - £1,296,000 = £864,000. Subtracting fixed operating expenses of £300,000 gives pre-tax income of £564,000. Applying a 25% tax rate leaves net income of £564,000 x (1 - 0.25) = £423,000. That £423,000 net income is exactly the number that would flow into the balance sheet''s retained earnings and the top of the cash flow statement -- one change (say, a different growth assumption for revenue) would ripple through every one of those steps and into all three statements consistently.

Recap: the three statements are linked, not separate documents -- income statement profitability flows into the balance sheet and cash flow statement, so a single changed assumption (like revenue growth or a cost ratio) should update all three consistently in a well-built model.',
  order_index = 1
where id = '00000000-0000-0000-0001-000000000104';

update lessons set content_body =
  'A financial model links a company''s three core statements -- income statement, balance sheet, and cash flow statement -- so that changing one assumption (like revenue growth) flows through consistently to the others. Analysts build these in a spreadsheet to project a company''s future performance and test "what if" scenarios, like the effect of a price increase or a new cost.

The income statement shows profitability over a period (revenue minus costs equals net income); the balance sheet shows what a company owns and owes at a single point in time (assets, liabilities, equity); the cash flow statement shows how cash actually moved, which is not the same thing as profit because some income-statement items (like depreciation) don''t involve any cash changing hands. A "linked" model means net income from the income statement flows into both retained earnings on the balance sheet and the starting point of the cash flow statement, so the three stay consistent with each other automatically when an assumption changes.

Worked example: a simplified income-statement build for one year -- revenue £2,160,000, cost of goods sold (COGS) at 60% of revenue = £1,296,000, giving gross profit of £2,160,000 - £1,296,000 = £864,000. Subtracting fixed operating expenses of £300,000 gives pre-tax income of £564,000. Applying a 25% tax rate leaves net income of £564,000 x (1 - 0.25) = £423,000. That £423,000 net income is exactly the number that would flow into the balance sheet''s retained earnings and the top of the cash flow statement -- one change (say, a different growth assumption for revenue) would ripple through every one of those steps and into all three statements consistently.

Recap: the three statements are linked, not separate documents -- income statement profitability flows into the balance sheet and cash flow statement, so a single changed assumption (like revenue growth or a cost ratio) should update all three consistently in a well-built model.',
  order_index = 1
where id = '00000000-0000-0000-0002-000000000104';

insert into quiz_questions (quiz_id, question, options, correct_answer, order_index) values
  -- Finance Roles Overview
  ('00000000-0000-0000-0003-000000000101', 'Which skill set is most central to day-to-day work as an investment banking analyst?',
    '["Statistics and programming for pricing models", "Relationship-building, financial modeling, and presentation polish", "Recalculating a firm''s market risk exposure", "Trade settlement processing"]'::jsonb,
    'Relationship-building, financial modeling, and presentation polish', 3),
  ('00000000-0000-0000-0003-000000000101', 'Elena (investment banking) builds valuation models and preps client pitch decks. Marcus (risk) writes scripts to recalculate market exposure and flags limit breaches. What does this best illustrate?',
    '["Both roles have identical day-to-day work", "Different finance roles can involve very different daily work despite being in the same industry", "Risk analysts do not need any technical skills", "Investment banking never involves any modeling"]'::jsonb,
    'Different finance roles can involve very different daily work despite being in the same industry', 4),
  ('00000000-0000-0000-0003-000000000101', 'A graduate who most enjoys writing code to test statistical trading strategies would likely be best suited to which role?',
    '["Investment banking analyst", "Quant", "Operations analyst", "Fintech product manager"]'::jsonb,
    'Quant', 5),
  ('00000000-0000-0000-0003-000000000101', 'Why is "comparing roles by what the work actually involves" a better approach than picking based on the industry label alone?',
    '["It is not better -- industry label is all that matters", "Because roles within the same industry can differ enormously in required skills and daily work", "Because pay is identical across all finance roles", "Because job titles never affect the work itself"]'::jsonb,
    'Because roles within the same industry can differ enormously in required skills and daily work', 6),

  -- Capital Markets Basics
  ('00000000-0000-0000-0003-000000000102', 'Northwind Ltd raises £10 million by selling new shares in an IPO. The next day, Priya buys shares from Tom on the stock exchange. Who receives the money from Priya''s purchase?',
    '["Northwind Ltd", "Tom, the other investor", "The stock exchange keeps it", "It is split evenly between Northwind and Tom"]'::jsonb,
    'Tom, the other investor', 3),
  ('00000000-0000-0000-0003-000000000102', 'If a company''s share price rises 10% purely from secondary-market trading, what happens to the cash the company already raised?',
    '["The company receives an extra 10% in cash", "Nothing changes -- the company already raised its capital separately in the primary market", "The company must return the difference to investors", "The company''s capital is reduced by 10%"]'::jsonb,
    'Nothing changes -- the company already raised its capital separately in the primary market', 4),
  ('00000000-0000-0000-0003-000000000102', 'Which of these is an example of a primary-market transaction?',
    '["An investor buying existing shares on a stock exchange from another investor", "A company issuing new shares in an IPO to raise capital", "Two investors trading a bond that was issued years ago", "A stock price moving because of a news headline"]'::jsonb,
    'A company issuing new shares in an IPO to raise capital', 5),
  ('00000000-0000-0000-0003-000000000102', 'What mainly drives price movement in the secondary market?',
    '["The issuing company setting a new price each day", "Supply, demand, and new information among traders", "The original IPO price, which never changes", "Government-mandated price resets"]'::jsonb,
    'Supply, demand, and new information among traders', 6),

  -- Company Valuation Basics
  ('00000000-0000-0000-0003-000000000103', 'Riverside Co earns £2,000,000 in annual profit. Similar public companies trade at an average P/E of 15x. Using comps, what is the estimated value?',
    '["£2,000,000", "£15,000,000", "£30,000,000", "£150,000,000"]'::jsonb,
    '£30,000,000', 3),
  ('00000000-0000-0000-0003-000000000103', 'Why is £1,000 promised in one year worth less than £1,000 in hand today, in DCF logic?',
    '["Because inflation always makes money worthless within a year", "Because today''s £1,000 could be invested and grow to more than £1,000 by next year", "Because future money is illegal to use immediately", "There is no difference -- both are worth exactly the same"]'::jsonb,
    'Because today''s £1,000 could be invested and grow to more than £1,000 by next year', 4),
  ('00000000-0000-0000-0003-000000000103', 'A DCF estimate swings a lot when the assumed growth rate or discount rate changes slightly. What does this best illustrate?',
    '["DCF is completely useless and should never be used", "DCF is very sensitive to its underlying assumptions", "Comps and DCF always produce identical answers", "Discount rates never affect a DCF valuation"]'::jsonb,
    'DCF is very sensitive to its underlying assumptions', 5),
  ('00000000-0000-0000-0003-000000000103', 'Why might an analyst use both comps and DCF on the same company rather than just one?',
    '["Because using two methods is required by law", "Because the gap between the two estimates is itself useful information, and neither method is more correct on its own", "Because comps and DCF always give the exact same number, so using both confirms accuracy", "Because DCF cannot be used for public companies"]'::jsonb,
    'Because the gap between the two estimates is itself useful information, and neither method is more correct on its own', 6),

  -- Financial Statement Modeling
  ('00000000-0000-0000-0003-000000000104', 'Which statement shows what a company owns and owes at a single point in time?',
    '["Income statement", "Balance sheet", "Cash flow statement", "Rubric statement"]'::jsonb,
    'Balance sheet', 3),
  ('00000000-0000-0000-0003-000000000104', 'Why can a company be profitable on its income statement but still have a cash flow issue?',
    '["Profit and cash flow are always exactly the same number", "Some income-statement items, like depreciation, don''t involve cash actually changing hands", "Cash flow statements are only prepared once a year", "Balance sheets ignore all cash entirely"]'::jsonb,
    'Some income-statement items, like depreciation, don''t involve cash actually changing hands', 4),
  ('00000000-0000-0000-0003-000000000104', 'Revenue is £2,160,000, COGS is 60% of revenue, and fixed operating expenses are £300,000. What is gross profit (revenue minus COGS)?',
    '["£864,000", "£1,296,000", "£1,860,000", "£2,160,000"]'::jsonb,
    '£864,000', 5),
  ('00000000-0000-0000-0003-000000000104', 'In a properly linked 3-statement model, what happens when a single assumption -- like revenue growth -- is changed?',
    '["Only the income statement updates; the balance sheet and cash flow statement stay fixed", "All three statements update consistently, since net income flows into both the balance sheet and cash flow statement", "Nothing changes until the model is manually rebuilt from scratch", "The balance sheet must always be edited by hand separately"]'::jsonb,
    'All three statements update consistently, since net income flows into both the balance sheet and cash flow statement', 6);

-- Replace the single-step modeling exercise with a multi-step build that
-- mirrors the lesson's worked example (revenue -> COGS -> gross profit ->
-- net income), using the exact same grading pattern (numeric key + tolerance
-- per metric) -- grade_modeling_submission already iterates an arbitrary
-- set of jsonb keys, so no RPC change is required.
update modeling_exercises set
  title = 'Build a One-Year Income Statement Projection',
  instructions =
    'A company had $2,000,000 in revenue this year and is projected to grow revenue 8% next year. Cost of goods sold (COGS) is consistently 60% of revenue. Fixed operating expenses are $300,000. The tax rate is 25%. Working step by step, calculate: (1) next year''s projected revenue, (2) next year''s projected COGS (60% of projected revenue), (3) gross profit (projected revenue minus projected COGS), and (4) net income (gross profit minus operating expenses, then taxed at 25%: net income = (gross profit - operating expenses) x (1 - 0.25)). Submit as {"projected_revenue": <number>, "projected_cogs": <number>, "gross_profit": <number>, "net_income": <number>}.',
  rubric = '{
    "projected_revenue": {"expected": 2160000, "tolerance": 1000},
    "projected_cogs": {"expected": 1296000, "tolerance": 1000},
    "gross_profit": {"expected": 864000, "tolerance": 1000},
    "net_income": {"expected": 423000, "tolerance": 1000}
  }'::jsonb
where id = '00000000-0000-0000-0004-000000000001';
