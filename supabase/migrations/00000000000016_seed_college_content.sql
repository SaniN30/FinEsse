-- Seed/demo content: College tier (L7-L9) -- finance roles, markets, and
-- valuation basics, plus one guided modeling exercise. Small and simple on
-- purpose, same bar as Phase 2's School L1 seed: enough real content to
-- exercise the schema and grading logic, not the final curriculum.
--
-- Prerequisite chain wires into the existing mastery graph by chaining off
-- 'earning-pocket-money' (the most advanced seeded School skill), so
-- College content unlocks after relevant School content per the plan.

insert into skills (id, tier, slug, title, prerequisite_skill_id, mastery_threshold) values
  ('00000000-0000-0000-0001-000000000101', 'college', 'finance-roles-overview', 'Finance Roles Overview',
    '00000000-0000-0000-0001-000000000004', 0.8),
  ('00000000-0000-0000-0001-000000000102', 'college', 'capital-markets-basics', 'Capital Markets Basics',
    '00000000-0000-0000-0001-000000000101', 0.8),
  ('00000000-0000-0000-0001-000000000103', 'college', 'company-valuation-basics', 'Company Valuation Basics',
    '00000000-0000-0000-0001-000000000102', 0.8),
  ('00000000-0000-0000-0001-000000000104', 'college', 'financial-statement-modeling', 'Financial Statement Modeling',
    '00000000-0000-0000-0001-000000000103', 0.8);

insert into lessons (id, skill_id, content_type, content_body, order_index) values
  ('00000000-0000-0000-0002-000000000101', '00000000-0000-0000-0001-000000000101', 'article',
   'Finance careers span very different day-to-day work: investment bankers advise companies on raising capital and M&A; quants build mathematical trading and risk models; risk managers measure and limit a firm''s exposure to loss; operations ("ops") keeps trades settling and records accurate; and fintech product managers build the software finance runs on. Pay, hours, and required skills vary a lot across these roles -- there is no single "finance job."',
   1),
  ('00000000-0000-0000-0002-000000000102', '00000000-0000-0000-0001-000000000102', 'article',
   'Capital markets are where companies and governments raise money and investors trade it. The primary market is where a security (like a new stock or bond) is first sold to raise capital; the secondary market is where investors then trade that security among themselves, like a stock exchange. Prices in the secondary market move on supply, demand, and new information, and don''t change how much money the original issuer raised.',
   1),
  ('00000000-0000-0000-0002-000000000103', '00000000-0000-0000-0001-000000000103', 'article',
   'Valuing a company means estimating what it is worth. Two common approaches: comparable-company analysis ("comps"), which prices a company relative to similar public companies using ratios like price-to-earnings; and discounted cash flow (DCF), which estimates a company''s value as the sum of its expected future cash flows, adjusted ("discounted") to reflect that money in the future is worth less than money today.',
   1),
  ('00000000-0000-0000-0002-000000000104', '00000000-0000-0000-0001-000000000104', 'article',
   'A financial model links a company''s three core statements -- income statement, balance sheet, and cash flow statement -- so that changing one assumption (like revenue growth) flows through consistently to the others. Analysts build these in a spreadsheet to project a company''s future performance and test "what if" scenarios, like the effect of a price increase or a new cost.',
   1);

insert into quizzes (id, skill_id, lesson_id, title, pass_threshold) values
  ('00000000-0000-0000-0003-000000000101', '00000000-0000-0000-0001-000000000101', '00000000-0000-0000-0002-000000000101', 'Finance Roles Overview Quiz', 0.8),
  ('00000000-0000-0000-0003-000000000102', '00000000-0000-0000-0001-000000000102', '00000000-0000-0000-0002-000000000102', 'Capital Markets Basics Quiz', 0.8),
  ('00000000-0000-0000-0003-000000000103', '00000000-0000-0000-0001-000000000103', '00000000-0000-0000-0002-000000000103', 'Company Valuation Basics Quiz', 0.8),
  ('00000000-0000-0000-0003-000000000104', '00000000-0000-0000-0001-000000000104', '00000000-0000-0000-0002-000000000104', 'Financial Statement Modeling Quiz', 0.8);

insert into quiz_questions (quiz_id, question, options, correct_answer, order_index) values
  ('00000000-0000-0000-0003-000000000101', 'Which finance role primarily measures and limits a firm''s exposure to loss?',
    '["Investment banker", "Risk manager", "Fintech product manager", "Operations analyst"]'::jsonb,
    'Risk manager', 1),
  ('00000000-0000-0000-0003-000000000101', 'What best describes a quant''s core work?',
    '["Advising on mergers and acquisitions", "Building mathematical trading and risk models", "Keeping trades settling accurately", "Designing finance software"]'::jsonb,
    'Building mathematical trading and risk models', 2),

  ('00000000-0000-0000-0003-000000000102', 'A company selling new shares to raise capital for the first time happens in which market?',
    '["The secondary market", "The primary market", "The derivatives market", "The commodities market"]'::jsonb,
    'The primary market', 1),
  ('00000000-0000-0000-0003-000000000102', 'Does secondary-market trading change how much money the original issuer raised?',
    '["Yes, every trade sends the issuer more money", "No, the issuer already raised its capital in the primary market", "Only if the price goes up", "Only if the price goes down"]'::jsonb,
    'No, the issuer already raised its capital in the primary market', 2),

  ('00000000-0000-0000-0003-000000000103', 'What does a "comps" valuation do?',
    '["Prices a company relative to similar public companies", "Predicts the weather''s effect on stock prices", "Ignores all other companies entirely", "Only looks at a company''s cash on hand"]'::jsonb,
    'Prices a company relative to similar public companies', 1),
  ('00000000-0000-0000-0003-000000000103', 'What does "discounting" future cash flows in a DCF reflect?',
    '["That future money is worth more than money today", "That future money is worth less than money today", "That all money is worth the same regardless of timing", "That cash flows never change over time"]'::jsonb,
    'That future money is worth less than money today', 2),

  ('00000000-0000-0000-0003-000000000104', 'What are the three core financial statements a model links together?',
    '["Income statement, balance sheet, cash flow statement", "Resume, cover letter, offer letter", "Budget, forecast, actuals report", "Invoice, receipt, ledger"]'::jsonb,
    'Income statement, balance sheet, cash flow statement', 1),
  ('00000000-0000-0000-0003-000000000104', 'Why do analysts build financial models in a spreadsheet?',
    '["To project future performance and test ''what if'' scenarios", "To replace the need for any financial statements", "Because spreadsheets are required by law", "To avoid ever updating assumptions"]'::jsonb,
    'To project future performance and test ''what if'' scenarios', 2);

-- Guided modeling exercise: a simple revenue-growth projection, tied to the
-- financial-statement-modeling skill. Rubric compares two derived metrics
-- with a small tolerance for rounding.
insert into modeling_exercises (id, skill_id, title, instructions, rubric, pass_threshold) values
  ('00000000-0000-0000-0004-000000000001', '00000000-0000-0000-0001-000000000104',
   'Project Next Year''s Revenue',
   'A company had $1,000,000 in revenue this year and grew 10% last year. Assuming the same growth rate continues, calculate: (1) next year''s projected revenue in dollars, and (2) the revenue growth percentage you used. Submit as {"projected_revenue": <number>, "revenue_growth_pct": <number>}.',
   '{"projected_revenue": {"expected": 1100000, "tolerance": 1000}, "revenue_growth_pct": {"expected": 10, "tolerance": 0.5}}'::jsonb,
   0.8);

-- Role Explorer reference content -- publicly readable, service-role writable.
insert into roles (slug, title, description, typical_pay_range, required_skill_ids) values
  ('investment-banking-analyst', 'Investment Banking Analyst',
   'Advises companies on raising capital, mergers, and acquisitions; builds financial models and pitch materials for senior bankers and clients.',
   '$85,000 - $150,000 (base + bonus, entry level)',
   array['00000000-0000-0000-0001-000000000103'::uuid, '00000000-0000-0000-0001-000000000104'::uuid]),
  ('quantitative-analyst', 'Quantitative Analyst ("Quant")',
   'Builds and maintains mathematical models for trading, pricing, or risk, often using statistics and programming rather than traditional deal work.',
   '$100,000 - $180,000 (base + bonus, entry level)',
   array['00000000-0000-0000-0001-000000000102'::uuid]),
  ('risk-analyst', 'Risk Analyst',
   'Measures and monitors a firm''s exposure to market, credit, or operational risk, and helps set limits to keep that exposure within acceptable bounds.',
   '$70,000 - $120,000',
   array['00000000-0000-0000-0001-000000000102'::uuid]),
  ('operations-analyst', 'Operations ("Ops") Analyst',
   'Keeps trades settling correctly and records accurate, working behind the scenes so front-office deals actually complete without errors.',
   '$60,000 - $95,000',
   array['00000000-0000-0000-0001-000000000101'::uuid]),
  ('fintech-product-manager', 'Fintech Product Manager',
   'Defines and ships the software products finance runs on, working between engineers, designers, and finance domain experts.',
   '$90,000 - $150,000',
   array['00000000-0000-0000-0001-000000000101'::uuid]),
  ('equity-research-associate', 'Equity Research Associate',
   'Analyzes public companies and industries to publish investment recommendations, leaning heavily on valuation and modeling skills.',
   '$75,000 - $130,000',
   array['00000000-0000-0000-0001-000000000103'::uuid, '00000000-0000-0000-0001-000000000104'::uuid]);
