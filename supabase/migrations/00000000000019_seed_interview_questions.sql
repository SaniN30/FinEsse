-- Seed interview question bank: 9 questions across 3 firm styles, mixing
-- behavioral and technical categories, matching real early-career finance
-- interview questions reported for each firm.
insert into interview_questions (firm_style, question_text, category) values
  ('JPMorgan Chase', 'Walk me through your resume.', 'behavioral'),
  ('JPMorgan Chase', 'Why investment banking, and why JPMorgan specifically?', 'behavioral'),
  ('JPMorgan Chase', 'Walk me through the three financial statements and how they link together.', 'technical'),
  ('Goldman Sachs', 'Tell me about a time you worked under a tight deadline with limited information.', 'behavioral'),
  ('Goldman Sachs', 'What do you look for in a team, and how do you handle disagreement within one?', 'behavioral'),
  ('Goldman Sachs', 'Walk me through a DCF and what it tells you about a company''s valuation.', 'technical'),
  ('Morgan Stanley', 'Describe a time you had to persuade someone who disagreed with you.', 'behavioral'),
  ('Morgan Stanley', 'Why do you want to work at Morgan Stanley over other banks?', 'behavioral'),
  ('Morgan Stanley', 'What happens to a company''s cash flow statement if depreciation increases by $10?', 'technical');
