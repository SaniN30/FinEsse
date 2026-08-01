-- AI Interview Coach: question bank expansion. 00000000000019 seeded 9
-- questions across 3 firm styles (JPMorgan, Goldman, Morgan Stanley), split
-- behavioral/technical. This adds 95 more (104 total) spanning: more
-- behavioral firms/styles, more technical/case firms, and role-specific
-- questions tied to the roles already seeded in 00000000000016
-- (investment-banking-analyst, quantitative-analyst, risk-analyst,
-- operations-analyst, fintech-product-manager, equity-research-associate).
-- `interview_questions` has no role foreign key (see 00000000000017 -- it is
-- deliberately not tier/role-gated), so role-specific questions use
-- `firm_style` to carry the role name, matching how the existing schema
-- already groups questions -- no schema change needed. `category` stays
-- constrained to ('behavioral', 'technical') per the existing check
-- constraint; case-style and role-specific questions are tagged 'technical'.
--
-- All question phrasing below is written originally for this project;
-- question types and topics are grounded in the kinds of questions commonly
-- referenced by career-services offices and interview-prep resources, not
-- copied verbatim from any firm, publisher, or prep company's material.

insert into interview_questions (firm_style, question_text, category) values
  -- ===================== General behavioral (broad-fit) =====================
  ('General Behavioral', 'Tell me about yourself.', 'behavioral'),
  ('General Behavioral', 'What are your greatest strengths, and how have they shown up in your work?', 'behavioral'),
  ('General Behavioral', 'What is a weakness you''re actively working to improve, and what have you done about it?', 'behavioral'),
  ('General Behavioral', 'Tell me about a time you had to learn something completely new under time pressure.', 'behavioral'),
  ('General Behavioral', 'Describe a time you received critical feedback. How did you respond?', 'behavioral'),
  ('General Behavioral', 'Tell me about a goal you set for yourself and how you achieved it.', 'behavioral'),
  ('General Behavioral', 'Describe a time you had to prioritize among multiple competing deadlines.', 'behavioral'),
  ('General Behavioral', 'Tell me about a time you made a mistake at work or school. What did you do next?', 'behavioral'),
  ('General Behavioral', 'What motivates you, and how does this role fit into that?', 'behavioral'),
  ('General Behavioral', 'Where do you see yourself in five years?', 'behavioral'),
  ('General Behavioral', 'Tell me about a time you had to work with someone whose working style was very different from yours.', 'behavioral'),
  ('General Behavioral', 'Describe a situation where you went above and beyond what was expected of you.', 'behavioral'),
  ('General Behavioral', 'Tell me about a time you had to say no to a request. How did you handle it?', 'behavioral'),
  ('General Behavioral', 'What is the most difficult decision you''ve had to make recently, and how did you approach it?', 'behavioral'),
  ('General Behavioral', 'Tell me about a time you had to manage up -- get support or a decision from someone more senior than you.', 'behavioral'),

  -- ===================== General situational =====================
  ('General Situational', 'You realize partway through a project that you misunderstood a key requirement. What do you do?', 'behavioral'),
  ('General Situational', 'A teammate is consistently missing deadlines and it''s affecting your work. How do you handle it?', 'behavioral'),
  ('General Situational', 'Your manager gives you a task with an unrealistic deadline. What do you do?', 'behavioral'),
  ('General Situational', 'You notice a colleague appears to have made an error in a client-facing document. What do you do?', 'behavioral'),
  ('General Situational', 'You disagree with a decision your team has already made and started implementing. How do you handle it?', 'behavioral'),
  ('General Situational', 'You are given two urgent tasks by two different senior people at the same time. What do you do?', 'behavioral'),
  ('General Situational', 'You''re asked to do something you believe is ethically questionable, but not clearly against any written policy. What do you do?', 'behavioral'),
  ('General Situational', 'A client or stakeholder is unhappy with a deliverable you produced. How do you handle the conversation?', 'behavioral'),

  -- ===================== JPMorgan Chase =====================
  ('JPMorgan Chase', 'Describe a time you had to explain something technical to someone without a technical background.', 'behavioral'),
  ('JPMorgan Chase', 'What recent market or industry news has caught your attention, and why?', 'behavioral'),
  ('JPMorgan Chase', 'How would you value a company with negative earnings?', 'technical'),
  ('JPMorgan Chase', 'What is the difference between enterprise value and equity value, and when would you use each?', 'technical'),
  ('JPMorgan Chase', 'Walk me through what happens to enterprise value if a company issues new debt to buy back stock.', 'technical'),
  ('JPMorgan Chase', 'What is WACC, and why is it used as a discount rate?', 'technical'),

  -- ===================== Goldman Sachs =====================
  ('Goldman Sachs', 'Tell me about a time you had to build trust with someone quickly.', 'behavioral'),
  ('Goldman Sachs', 'Describe a time you took initiative without being asked.', 'behavioral'),
  ('Goldman Sachs', 'Why should we hire you over another candidate with a similar background?', 'behavioral'),
  ('Goldman Sachs', 'Walk me through how you would value a private company with no public comparables.', 'technical'),
  ('Goldman Sachs', 'What factors would make you choose a trading comparables approach over a DCF, or vice versa?', 'technical'),
  ('Goldman Sachs', 'How does an increase in interest rates generally affect equity valuations?', 'technical'),

  -- ===================== Morgan Stanley =====================
  ('Morgan Stanley', 'Tell me about a time your initial approach to a problem turned out to be wrong. What did you do?', 'behavioral'),
  ('Morgan Stanley', 'Describe a time you had to give someone difficult feedback.', 'behavioral'),
  ('Morgan Stanley', 'How do you stay organized when managing several projects with different priorities?', 'behavioral'),
  ('Morgan Stanley', 'Walk me through the impact of a $10 increase in inventory on the three financial statements.', 'technical'),
  ('Morgan Stanley', 'What is the difference between a company''s book value and its market value?', 'technical'),
  ('Morgan Stanley', 'Why might two analysts arrive at very different valuations for the exact same company?', 'technical'),

  -- ===================== BlackRock (asset management) =====================
  ('BlackRock', 'Tell me about a time you had to make a decision with incomplete information.', 'behavioral'),
  ('BlackRock', 'Describe a time you changed your mind about something after new evidence came in.', 'behavioral'),
  ('BlackRock', 'What is diversification, and why does it reduce risk in a portfolio?', 'technical'),
  ('BlackRock', 'What is the difference between systematic and idiosyncratic (company-specific) risk?', 'technical'),
  ('BlackRock', 'How would you explain the relationship between bond prices and interest rates to someone with no finance background?', 'technical'),
  ('BlackRock', 'What is a Sharpe ratio, and what does it measure?', 'technical'),

  -- ===================== McKinsey & Company (consulting/case) =====================
  ('McKinsey & Company', 'Tell me about a time you had to influence someone without having formal authority over them.', 'behavioral'),
  ('McKinsey & Company', 'Describe a time you worked on a team with a very tight deadline. How did you divide the work?', 'behavioral'),
  ('McKinsey & Company', 'A retail client''s profits have declined for two straight years despite stable revenue. How would you investigate why?', 'technical'),
  ('McKinsey & Company', 'A client wants to know whether they should enter a new international market. What factors would you consider?', 'technical'),
  ('McKinsey & Company', 'Estimate the annual revenue of a mid-sized coffee shop chain in a major city.', 'technical'),
  ('McKinsey & Company', 'A manufacturer is considering whether to build a new factory or expand an existing one. How would you structure that decision?', 'technical'),

  -- ===================== Boston Consulting Group (consulting/case) =====================
  ('Boston Consulting Group', 'Tell me about a time you had to persuade a group to change its approach mid-project.', 'behavioral'),
  ('Boston Consulting Group', 'Describe the most complex analysis you''ve done to reach a decision or recommendation.', 'behavioral'),
  ('Boston Consulting Group', 'A company''s market share is shrinking even as the overall market grows. What could explain this?', 'technical'),
  ('Boston Consulting Group', 'How would you estimate the total addressable market for a new electric bike subscription service?', 'technical'),
  ('Boston Consulting Group', 'A client is deciding whether to acquire a competitor or build a competing product in-house. What would you weigh?', 'technical'),

  -- ===================== Bain & Company (consulting/case) =====================
  ('Bain & Company', 'Tell me about a time you had to deliver results with fewer resources than you thought you needed.', 'behavioral'),
  ('Bain & Company', 'Describe a time you had to synthesize a large amount of information quickly to make a recommendation.', 'behavioral'),
  ('Bain & Company', 'A subscription business has stable revenue but rising customer churn. How would you diagnose the cause?', 'technical'),
  ('Bain & Company', 'Estimate how many gym memberships are active in a city of two million people.', 'technical'),

  -- ===================== Investment Banking Analyst (role-specific) =====================
  ('Investment Banking Analyst', 'Walk me through the three financial statements and how a change in one flows through the others.', 'technical'),
  ('Investment Banking Analyst', 'What is the difference between a merger and an acquisition?', 'technical'),
  ('Investment Banking Analyst', 'Why would a company choose to raise capital through debt instead of issuing new equity?', 'technical'),
  ('Investment Banking Analyst', 'What is an LBO, in simple terms, and why does debt matter so much to its returns?', 'technical'),
  ('Investment Banking Analyst', 'Tell me about a time you had to double-check your own work under a tight deadline. How did you catch errors?', 'behavioral'),
  ('Investment Banking Analyst', 'Describe a time you had to produce a polished deliverable overnight or on very short notice.', 'behavioral'),
  ('Investment Banking Analyst', 'Why investment banking specifically, rather than another area of finance?', 'behavioral'),

  -- ===================== Quantitative Analyst (role-specific) =====================
  ('Quantitative Analyst', 'What is the difference between correlation and causation, and why does that distinction matter in modeling?', 'technical'),
  ('Quantitative Analyst', 'Explain what standard deviation measures and why it matters for evaluating risk.', 'technical'),
  ('Quantitative Analyst', 'You flip a fair coin 10 times and get 8 heads. What does this tell you, if anything, about the coin''s fairness?', 'technical'),
  ('Quantitative Analyst', 'What is overfitting in a statistical model, and how would you recognize it?', 'technical'),
  ('Quantitative Analyst', 'Tell me about a time you found an error in a model or dataset that others had missed.', 'behavioral'),
  ('Quantitative Analyst', 'Describe a project where you had to translate a mathematical or statistical result into a plain-language explanation for a non-technical audience.', 'behavioral'),

  -- ===================== Risk Analyst (role-specific) =====================
  ('Risk Analyst', 'What is the difference between market risk and credit risk?', 'technical'),
  ('Risk Analyst', 'What does "value at risk" attempt to measure, in simple terms?', 'technical'),
  ('Risk Analyst', 'Why might a firm choose to hedge a risk rather than simply avoid taking it on in the first place?', 'technical'),
  ('Risk Analyst', 'Tell me about a time you identified a risk that others on your team had overlooked.', 'behavioral'),
  ('Risk Analyst', 'Describe a time you had to say no to a proposal because the risk outweighed the potential benefit.', 'behavioral'),
  ('Risk Analyst', 'How would you explain the concept of diversification to someone with no finance background?', 'technical'),

  -- ===================== Operations Analyst (role-specific) =====================
  ('Operations Analyst', 'Describe a process you improved to make it faster or less error-prone.', 'behavioral'),
  ('Operations Analyst', 'Tell me about a time you had to troubleshoot a problem when you didn''t immediately know the cause.', 'behavioral'),
  ('Operations Analyst', 'What steps would you take if you noticed a recurring reconciliation error between two systems?', 'technical'),
  ('Operations Analyst', 'Why does attention to detail matter more in operations roles than it might in a purely strategic role?', 'behavioral'),
  ('Operations Analyst', 'Tell me about a time a process failure caused a downstream problem for someone else. How did you fix it?', 'behavioral'),

  -- ===================== Fintech Product Manager (role-specific) =====================
  ('Fintech Product Manager', 'How would you prioritize which feature to build next with limited engineering resources?', 'technical'),
  ('Fintech Product Manager', 'Describe how you would measure whether a new savings feature is actually helping users.', 'technical'),
  ('Fintech Product Manager', 'Tell me about a time you had to say no to a stakeholder''s feature request. How did you explain your reasoning?', 'behavioral'),
  ('Fintech Product Manager', 'Walk me through how you would design a simple budgeting feature for a first-time user.', 'technical'),
  ('Fintech Product Manager', 'Describe a time you used user feedback or data to change the direction of a product decision.', 'behavioral'),
  ('Fintech Product Manager', 'What regulatory or compliance considerations would you expect to matter when designing a new fintech feature?', 'technical'),

  -- ===================== Equity Research Associate (role-specific) =====================
  ('Equity Research Associate', 'What is the difference between a "buy" rating and a "hold" rating, and what typically drives the difference?', 'technical'),
  ('Equity Research Associate', 'Walk me through how you would build an initial view on whether a stock is overvalued or undervalued.', 'technical'),
  ('Equity Research Associate', 'What factors, beyond a company''s own financials, might change your outlook on its stock?', 'technical'),
  ('Equity Research Associate', 'Tell me about a time your initial thesis on something was proven wrong by new information. What did you do?', 'behavioral'),
  ('Equity Research Associate', 'Describe how you would explain a complex investment thesis to a client with limited financial background.', 'behavioral'),
  ('Equity Research Associate', 'Why might a company with strong earnings growth still have a falling stock price?', 'technical'),

  -- ===================== More general technical/case (broad-fit) =====================
  ('General Technical', 'What is the time value of money, and why does it matter in financial decision-making?', 'technical'),
  ('General Technical', 'What is the difference between a fixed-rate and a variable-rate loan, and what risk does each carry?', 'technical'),
  ('General Technical', 'Explain the difference between revenue and profit, and why a company can grow revenue while losing money.', 'technical'),
  ('General Technical', 'What does it mean for a company to be "cash flow negative," and is that always a bad sign?', 'technical'),
  ('General Technical', 'What is opportunity cost, and how would you apply it to a everyday financial decision?', 'technical'),
  ('General Technical', 'Estimate how many small businesses in your city might need basic bookkeeping software.', 'technical'),
  ('General Technical', 'What is compound interest, and why does starting to save early matter so much?', 'technical'),
  ('General Technical', 'A company''s revenue is flat but its net income is rising. What are some possible explanations?', 'technical');
