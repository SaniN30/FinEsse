-- Content depth pass: School tier. The original Phase 2 seed
-- (00000000000009) was explicitly a schema-validation fixture -- one
-- paragraph per lesson, 2 recall-only questions per quiz. This migration
-- expands each existing skill's lesson in place (same lesson id, longer
-- content_body with a worked example + recap) and adds 2-4 more questions
-- per quiz (existing 2 questions are untouched so any historical
-- quiz_attempts stay meaningful), bringing each quiz to 5-6 questions with
-- a real mix of recall and application/scenario questions.

update lessons set content_body =
  'Money is something people use to trade for things they need or want, instead of swapping goods directly. Coins and notes are physical money; a bank balance is digital money. Whatever form it takes, money works because everyone agrees it has value.

Before money, people used "bartering" -- swapping goods directly, like trading a chicken for a bag of grain. Barter has a big problem: it only works if both people happen to want what the other person has at the same time. Money fixes this because everyone accepts it, so you can sell what you have for money and then use that money to buy whatever you actually want, whenever you want it.

Worked example: Amir has a bike he no longer uses and wants a video game instead. Without money, he would need to find someone who both owns the exact video game he wants AND wants a used bike -- a hard match to find. Instead, Amir sells the bike to a neighbour for £40 in cash. He now has £40 he can spend on anything, including the video game, from any shop that will accept it -- not just from someone with a bike-shaped need.

Recap: money exists to solve the "who wants what I have, and has what I want" problem of direct swapping. It can be physical (coins, notes) or digital (a bank balance), and it only works because people trust and agree it holds value.',
  order_index = 1
where id = '00000000-0000-0000-0002-000000000001';

update lessons set content_body =
  'A need is something you must have to live, like food, water, and a place to stay. A want is something nice to have but not essential, like a video game or a second pair of trainers. Good money habits start with covering needs before spending on wants.

The tricky part is that needs and wants are not always obvious -- the same item can be a need for one situation and a want in another. A pair of shoes to replace ones with holes in them is a need; a fifth pair of trainers in a colour you like is a want. Working out which is which, honestly, is the actual skill -- it is easy to convince yourself a want is really a need when you want something badly enough.

Worked example: Priya has £15 in pocket money this month. Her school shoes have a hole in the sole (a need -- new shoes cost £12), and there is a new phone case she likes (a want -- £10). If she buys the phone case first, she will not have enough left for the shoes she actually needs. Covering the need first (shoes, £12) leaves her £3 towards the want later, rather than the other way round leaving her without proper shoes.

Recap: needs are essentials you cannot really do without (food, shelter, basic clothing); wants make life nicer but can wait. When money is limited, working out the true need vs. want -- and covering needs first -- keeps you from running short on the things you actually require.',
  order_index = 1
where id = '00000000-0000-0000-0002-000000000002';

update lessons set content_body =
  'Saving means setting money aside now so you can use it later, instead of spending all of it right away. Even small amounts add up over time. A savings goal -- like a target amount for something you want -- makes it easier to stick with the habit.

One useful way to think about saving is splitting money as soon as you get it, rather than saving "whatever is left over" at the end (which is often nothing). If you decide up front that a portion of every bit of money you receive goes straight into savings, the saving happens automatically instead of relying on willpower every single day.

Worked example: Sam gets £5 pocket money every week. If Sam saves £1 out of every £5 (20%) as soon as it arrives, spending the other £4 freely, then after 10 weeks Sam has saved £10 -- enough for a £10 book Sam has been wanting -- without ever having to make a hard "should I save today?" decision, because the split already happened automatically each week.

Recap: saving is setting money aside for later rather than spending it all now. Splitting off a fixed amount or percentage the moment money arrives -- rather than saving only what happens to be left over -- and having a clear goal both make saving much easier to keep up.',
  order_index = 1
where id = '00000000-0000-0000-0002-000000000003';

update lessons set content_body =
  'Pocket money can come from an allowance, doing chores, or small jobs like helping a neighbour. Earning your own money and deciding how to split it between spending and saving is good practice for managing money as an adult.

There is a difference between money you are given (an allowance, a birthday gift) and money you earn (chores, odd jobs). Earned money often feels more valuable to people because it took effort to get -- and thinking about "how many chores is this worth?" before buying something is a useful habit that carries into adult life, where the same question becomes "how many hours of work is this worth?"

Worked example: Jordan is given £3 a week allowance and also earns £2 for each extra chore (like washing the car) beyond the usual weekly jobs. In a week where Jordan does 2 extra chores, that is £3 + (2 x £2) = £7 total. If Jordan splits every pound earned as roughly 60% spending / 40% saving, that week is £4.20 to spend and £2.80 saved -- a habit that scales up whether the amounts are pocket money now or a real wage later.

Recap: pocket money can come from a fixed allowance or from effort-based earning like chores and odd jobs. Deciding on a consistent split between spending and saving -- and applying it to every pound you earn, not just some of it -- is a habit worth building early.',
  order_index = 1
where id = '00000000-0000-0000-0002-000000000004';

insert into quiz_questions (quiz_id, question, options, correct_answer, order_index) values
  -- What Is Money? -- 2 existing recall questions + 4 new (2 recall, 2 application)
  ('00000000-0000-0000-0003-000000000001', 'What problem does using money solve compared to bartering (direct swapping)?',
    '["It makes trading illegal", "It removes the need to find someone who wants exactly what you have and has exactly what you want", "It makes goods more expensive", "It has no real advantage over bartering"]'::jsonb,
    'It removes the need to find someone who wants exactly what you have and has exactly what you want', 3),
  ('00000000-0000-0000-0003-000000000001', 'Why does a coin, note, or bank balance actually work as money?',
    '["Because it is made of a rare metal", "Because everyone agrees it has value and will accept it in trade", "Because it can never be lost or stolen", "Because a bank prints new money for every purchase"]'::jsonb,
    'Because everyone agrees it has value and will accept it in trade', 4),
  ('00000000-0000-0000-0003-000000000001', 'Leo wants a football, and Mia has one she no longer uses but wants a book instead, not a football. Without money, what has to happen for a direct swap to work?',
    '["Leo and Mia must want exactly what the other person has, at the same time", "Leo must find a friend who owns a football", "Mia must give the football away for free", "Nothing -- a swap always works"]'::jsonb,
    'Leo and Mia must want exactly what the other person has, at the same time', 5),
  ('00000000-0000-0000-0003-000000000001', 'Amir sells his old bike for £40 cash instead of trying to trade it directly for a video game. What does having £40 in money let him do that a direct swap could not?',
    '["Nothing extra -- money and a direct swap work exactly the same way", "Spend the £40 at any shop that accepts money, not just with someone who happens to want a bike", "Only buy things from the person who bought the bike", "Guarantee the video game will be cheaper"]'::jsonb,
    'Spend the £40 at any shop that accepts money, not just with someone who happens to want a bike', 6),

  -- Needs vs Wants
  ('00000000-0000-0000-0003-000000000002', 'Which of these is generally a "want" rather than a "need"?',
    '["A place to sleep", "A fifth pair of trainers in a colour you like", "Basic food", "Replacing shoes with holes in the sole"]'::jsonb,
    'A fifth pair of trainers in a colour you like', 3),
  ('00000000-0000-0000-0003-000000000002', 'Why can the same type of item sometimes be a need and sometimes be a want?',
    '["It never can -- an item is always the same category", "Because whether it is essential depends on the situation, like replacing worn-out shoes vs. buying an extra pair you like", "Because prices change the category", "Because shops decide which items are needs"]'::jsonb,
    'Because whether it is essential depends on the situation, like replacing worn-out shoes vs. buying an extra pair you like', 4),
  ('00000000-0000-0000-0003-000000000002', 'Priya has £15. Her school shoes have a hole (new pair: £12, a need) and she also likes a £10 phone case (a want). If she buys the phone case first, what happens?',
    '["She will not have enough left to cover her shoes, a genuine need", "Nothing -- she can still easily afford both", "The shoes will fix themselves", "It does not matter which she buys first"]'::jsonb,
    'She will not have enough left to cover her shoes, a genuine need', 5),
  ('00000000-0000-0000-0003-000000000002', 'What is the recommended order when money is limited and both needs and wants are competing for it?',
    '["Always buy wants first because they are more fun", "Cover needs first, then spend any remaining money on wants", "Ignore needs completely", "Split evenly regardless of what each item actually is"]'::jsonb,
    'Cover needs first, then spend any remaining money on wants', 6),

  -- Saving Basics
  ('00000000-0000-0000-0003-000000000003', 'What is one benefit of saving even small amounts regularly?',
    '["Small amounts never add up to anything useful", "They add up over time into a larger amount", "It is illegal to save large amounts", "Saving small amounts guarantees a want becomes a need"]'::jsonb,
    'They add up over time into a larger amount', 3),
  ('00000000-0000-0000-0003-000000000003', 'Why is splitting off savings the moment money arrives usually more reliable than "saving whatever is left over"?',
    '["There is usually nothing left over by the end, so nothing gets saved", "Leftover money is always larger", "It is exactly the same either way", "Banks require you to save first by law"]'::jsonb,
    'There is usually nothing left over by the end, so nothing gets saved', 4),
  ('00000000-0000-0000-0003-000000000003', 'Sam saves £1 out of every £5 of pocket money as soon as it arrives. After 10 weeks of £5 pocket money, how much has Sam saved?',
    '["£1", "£5", "£10", "£50"]'::jsonb,
    '£10', 5),
  ('00000000-0000-0000-0003-000000000003', 'Sam wants to save up faster for a book. Which change would get Sam to a savings goal sooner, all else equal?',
    '["Saving a smaller share of each week''s pocket money", "Saving a larger share of each week''s pocket money", "Spending the savings on something else first", "Waiting longer between each pocket money payment"]'::jsonb,
    'Saving a larger share of each week''s pocket money', 6),

  -- Earning Pocket Money
  ('00000000-0000-0000-0003-000000000004', 'What is a key difference between an allowance and chore-based earnings?',
    '["There is no difference at all", "An allowance is given regardless of effort; chore earnings depend on the work done", "Chores never pay any money", "An allowance can only be spent, never saved"]'::jsonb,
    'An allowance is given regardless of effort; chore earnings depend on the work done', 3),
  ('00000000-0000-0000-0003-000000000004', 'Jordan gets £3 allowance plus £2 per extra chore, and does 2 extra chores one week. How much does Jordan earn that week in total?',
    '["£3", "£5", "£7", "£9"]'::jsonb,
    '£7', 4),
  ('00000000-0000-0000-0003-000000000004', 'If Jordan splits every pound earned as 60% spending and 40% saving, how much of £7 goes to savings that week?',
    '["£1.40", "£2.80", "£4.20", "£7.00"]'::jsonb,
    '£2.80', 5),
  ('00000000-0000-0000-0003-000000000004', 'Why is thinking "how many chores is this worth?" before buying something a useful habit?',
    '["It has no real benefit", "It connects spending to the effort behind earning it, a habit that carries into working life", "It guarantees the item will go on sale", "It means you should never buy anything"]'::jsonb,
    'It connects spending to the effort behind earning it, a habit that carries into working life', 6);
