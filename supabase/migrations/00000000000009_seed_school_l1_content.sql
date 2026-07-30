-- Seed/demo content: School tier, level 1 -- money basics & saving
-- fundamentals. Small and simple on purpose; this is enough real content to
-- exercise the schema and grading logic, not the final curriculum.

insert into skills (id, tier, slug, title, mastery_threshold) values
  ('00000000-0000-0000-0001-000000000001', 'school', 'what-is-money', 'What Is Money?', 0.8),
  ('00000000-0000-0000-0001-000000000002', 'school', 'needs-vs-wants', 'Needs vs. Wants', 0.8),
  ('00000000-0000-0000-0001-000000000003', 'school', 'saving-basics', 'Saving Basics', 0.8),
  ('00000000-0000-0000-0001-000000000004', 'school', 'earning-pocket-money', 'Earning Pocket Money', 0.8);

insert into lessons (id, skill_id, content_type, content_body, order_index) values
  ('00000000-0000-0000-0002-000000000001', '00000000-0000-0000-0001-000000000001', 'article',
   'Money is something people use to trade for things they need or want, instead of swapping goods directly. Coins and notes are physical money; a bank balance is digital money. Whatever form it takes, money works because everyone agrees it has value.',
   1),
  ('00000000-0000-0000-0002-000000000002', '00000000-0000-0000-0001-000000000002', 'article',
   'A need is something you must have to live, like food, water, and a place to stay. A want is something nice to have but not essential, like a video game or a second pair of trainers. Good money habits start with covering needs before spending on wants.',
   1),
  ('00000000-0000-0000-0002-000000000003', '00000000-0000-0000-0001-000000000003', 'article',
   'Saving means setting money aside now so you can use it later, instead of spending all of it right away. Even small amounts add up over time. A savings goal -- like a target amount for something you want -- makes it easier to stick with the habit.',
   1),
  ('00000000-0000-0000-0002-000000000004', '00000000-0000-0000-0001-000000000004', 'article',
   'Pocket money can come from an allowance, doing chores, or small jobs like helping a neighbour. Earning your own money and deciding how to split it between spending and saving is good practice for managing money as an adult.',
   1);

insert into quizzes (id, skill_id, lesson_id, title, pass_threshold) values
  ('00000000-0000-0000-0003-000000000001', '00000000-0000-0000-0001-000000000001', '00000000-0000-0000-0002-000000000001', 'What Is Money? Quiz', 0.8),
  ('00000000-0000-0000-0003-000000000002', '00000000-0000-0000-0001-000000000002', '00000000-0000-0000-0002-000000000002', 'Needs vs. Wants Quiz', 0.8),
  ('00000000-0000-0000-0003-000000000003', '00000000-0000-0000-0001-000000000003', '00000000-0000-0000-0002-000000000003', 'Saving Basics Quiz', 0.8),
  ('00000000-0000-0000-0003-000000000004', '00000000-0000-0000-0001-000000000004', '00000000-0000-0000-0002-000000000004', 'Earning Pocket Money Quiz', 0.8);

insert into quiz_questions (quiz_id, question, options, correct_answer, order_index) values
  ('00000000-0000-0000-0003-000000000001', 'Why do people use money instead of swapping goods directly?',
    '["Because it is illegal to swap goods", "Because everyone agrees it has value and it is easier to trade with", "Because money grows on trees", "Because shops require it by law"]'::jsonb,
    'Because everyone agrees it has value and it is easier to trade with', 1),
  ('00000000-0000-0000-0003-000000000001', 'Which of these is a form of digital money?',
    '["A gold coin", "A paper banknote", "A bank account balance", "A seashell"]'::jsonb,
    'A bank account balance', 2),

  ('00000000-0000-0000-0003-000000000002', 'Which of these is a "need"?',
    '["A new video game", "Food", "The latest trainers", "A toy"]'::jsonb,
    'Food', 1),
  ('00000000-0000-0000-0003-000000000002', 'What should you usually prioritise with your money?',
    '["Wants before needs", "Needs before wants", "Only wants", "Neither"]'::jsonb,
    'Needs before wants', 2),

  ('00000000-0000-0000-0003-000000000003', 'What does "saving" mean?',
    '["Spending all your money immediately", "Setting money aside to use later", "Giving all your money away", "Losing your money"]'::jsonb,
    'Setting money aside to use later', 1),
  ('00000000-0000-0000-0003-000000000003', 'Why does having a savings goal help?',
    '["It makes saving harder", "It gives you a target that makes it easier to stick with saving", "It means you never have to save", "It has no effect"]'::jsonb,
    'It gives you a target that makes it easier to stick with saving', 2),

  ('00000000-0000-0000-0003-000000000004', 'Which of these is a way to earn pocket money?',
    '["Doing chores", "Waiting for money to appear", "Ignoring your allowance", "Ignoring the pocket-money planner"]'::jsonb,
    'Doing chores', 1),
  ('00000000-0000-0000-0003-000000000004', 'What is good practice when you earn pocket money?',
    '["Spend all of it right away", "Split it between spending and saving", "Never spend any of it", "Give it all away"]'::jsonb,
    'Split it between spending and saving', 2);
