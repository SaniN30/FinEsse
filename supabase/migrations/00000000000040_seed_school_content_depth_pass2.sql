-- School-tier content depth pass 2: the tier had 7 skills after migrations
-- 09/27/30/31 (what-is-money, needs-vs-wants, saving-basics,
-- earning-pocket-money, compound-interest-basics, budgeting-basics,
-- banking-and-inflation-basics). This migration adds 8 more skills,
-- chaining off the top of that existing chain (007), to bring School to 15
-- distinct topics -- matching the depth already present in College and
-- Job-Ready. Topics and structure are grounded in widely-used financial
-- literacy frameworks for this age group (Jump$tart Coalition's National
-- Standards in K-12 Personal Finance Education, and CFPB financial
-- education building-block guidance), covering their core strands --
-- earn, spend, save, borrow, protect -- that School didn't yet have
-- dedicated skills for. All lesson text below is written originally for
-- this project; no text is copied from any publisher or curriculum.
--
-- Same lesson/quiz depth pattern as migrations 27-31: one full article
-- lesson per skill with a worked example and recap, one quiz per skill
-- with 5-6 recall + application questions. School has no
-- modeling_exercises concept (per migration 31's note), so no modeling
-- rows are added here.
--
-- Chains off school's most advanced skill: 008 chains off 007
-- (banking-and-inflation-basics). 40 was chosen as a clearly-past-the-end
-- migration number per this repo's numbering-collision history (see
-- AGENTS.md) -- the highest number in use on this branch at write time was
-- 33.

-- ===================== 008: Digital Payments & Online Safety =====================

insert into skills (id, tier, slug, title, prerequisite_skill_id, mastery_threshold) values
  ('00000000-0000-0000-0001-000000000008', 'school', 'digital-payments-and-online-safety', 'Digital Payments & Online Safety',
    '00000000-0000-0000-0001-000000000007', 0.8);

insert into lessons (id, skill_id, content_type, content_body, order_index) values
  ('00000000-0000-0000-0002-000000000008', '00000000-0000-0000-0001-000000000008', 'article',
   'Money increasingly moves without any cash changing hands at all: a card tap, a phone payment, or an app transfer moves value from one account to another instantly. This is convenient, but it also removes a lot of the natural friction that cash has -- handing over physical notes makes spending feel real in a way that tapping a card does not, which is one reason it is easy to spend more than you meant to when paying digitally.

Digital payments also come with safety responsibilities cash never had. A PIN, password, or fingerprint is what proves a payment is really you, so it needs to be kept private the same way you would keep a house key private -- never shared, never written down somewhere easy to find, and never reused across every single account. Scams that target digital payments usually work by tricking you into handing over that proof yourself: a message pretending to be your bank asking you to "confirm" your PIN or password, a link that looks like a real shop but isn''t, or a stranger online offering something great in exchange for payment details up front. A genuine bank or shop will never need to ask you for your full PIN or password over a message or phone call -- that request itself is the warning sign, regardless of how convincing it looks.

Worked example: Theo gets a text saying "Your account has been locked, click here to verify your PIN within 24 hours." The message looks urgent and official, with a logo that matches his bank''s. But his bank never asks for a PIN by text -- that is exactly the kind of request a real bank does not make. Theo does not click the link; instead, he opens his bank''s app directly (typing in the real address himself, not following the link) and checks there, where there is no such lock or warning. The urgency in the message was designed to make him act before he thought it through.

Recap: digital payments move money instantly and can make overspending easier because there is less physical friction than handing over cash. PINs, passwords, and similar proof-of-identity details must be kept private and are never legitimately requested by message or phone call -- treating any such request as suspicious, and checking through the real app or website directly instead of a link, is the core habit that avoids most digital payment scams.',
   1);

insert into quizzes (id, skill_id, lesson_id, title, pass_threshold) values
  ('00000000-0000-0000-0003-000000000008', '00000000-0000-0000-0001-000000000008', '00000000-0000-0000-0002-000000000008', 'Digital Payments & Online Safety Quiz', 0.8);

insert into quiz_questions (quiz_id, question, options, correct_answer, order_index) values
  ('00000000-0000-0000-0003-000000000008', 'Why can digital payments make it easier to overspend compared to cash, per the lesson?',
    '["Digital payments always cost extra fees", "Tapping a card or phone removes the physical friction of handing over real notes, so spending can feel less real", "Digital payments are always more expensive per item", "Shops only accept digital payments for wants, never needs"]'::jsonb,
    'Tapping a card or phone removes the physical friction of handing over real notes, so spending can feel less real', 1),
  ('00000000-0000-0000-0003-000000000008', 'What is the biggest warning sign in a message asking you to "confirm your PIN" by clicking a link?',
    '["The message uses a logo", "A genuine bank or shop never legitimately asks for your full PIN or password this way", "The message is too short", "It arrived outside business hours"]'::jsonb,
    'A genuine bank or shop never legitimately asks for your full PIN or password this way', 2),
  ('00000000-0000-0000-0003-000000000008', 'Theo gets an urgent text asking him to click a link to "unlock" his account by entering his PIN. What is the safest response, per the worked example?',
    '["Click the link immediately since it looks official", "Ignore the message entirely and never check", "Open the bank''s real app or website directly (not via the link) to check", "Reply to the text asking if it is real"]'::jsonb,
    'Open the bank''s real app or website directly (not via the link) to check', 3),
  ('00000000-0000-0000-0003-000000000008', 'Why should a PIN or password never be reused across every account, per the lesson?',
    '["Reuse has no real downside", "It is treated like a house key -- keeping it private and unique limits the damage if one account is ever compromised", "Banks require a different PIN for every login by law", "Reused PINs are automatically rejected by apps"]'::jsonb,
    'It is treated like a house key -- keeping it private and unique limits the damage if one account is ever compromised', 4),
  ('00000000-0000-0000-0003-000000000008', 'What tactic do many digital payment scams rely on, per the lesson?',
    '["Making the scam message look boring so it is ignored", "Creating urgency so you act (e.g. clicking a link or sharing a PIN) before thinking it through", "Only targeting people who never use digital payments", "Requiring a face-to-face meeting before any payment"]'::jsonb,
    'Creating urgency so you act (e.g. clicking a link or sharing a PIN) before thinking it through', 5);

-- ===================== 009: Simple Investing Basics =====================

insert into skills (id, tier, slug, title, prerequisite_skill_id, mastery_threshold) values
  ('00000000-0000-0000-0001-000000000009', 'school', 'simple-investing-basics', 'Simple Investing Basics',
    '00000000-0000-0000-0001-000000000008', 0.8);

insert into lessons (id, skill_id, content_type, content_body, order_index) values
  ('00000000-0000-0000-0002-000000000009', '00000000-0000-0000-0001-000000000009', 'article',
   'Saving and investing both mean not spending money now so you have more of it later, but they work differently. Saving (like a bank account) keeps your money safe and easy to access, with a fairly predictable, small amount of interest. Investing means using money to buy a small piece of something -- like a share in a company -- hoping its value grows over time. Investments can grow faster than savings, but unlike a savings account, the value can also go down, sometimes a lot, especially in the short term.

This trade-off between "how much it could grow" and "how much it could lose" is called risk, and it is directly tied to time. Money you might need soon (for something in the next few months or year) is generally kept in savings, because you cannot afford for it to have temporarily dropped in value right when you need it. Money you will not need for many years has more time to recover from a drop, which is why investing is usually talked about as a long-term idea, not a way to quickly turn a small amount of money into a large one.

Worked example: Aisha has £200. If she puts it in a savings account paying 3% a year, in a year she has roughly £206 -- a small, fairly certain amount. If she instead invests it in a share fund that grows by an average of 7% a year over many years, £200 could become much more over say 10 years -- but in any single year, that same investment might instead have fallen by 15% before recovering later. If Aisha needs the £200 back in three months for something specific, the savings account is the safer choice, because a temporary drop in the investment right before she needs the money would leave her short.

Recap: saving keeps money safe and accessible with modest, predictable growth; investing buys a stake in something (like a company) that can grow faster over the long run but can also lose value, especially in the short term. Matching the choice to the timeframe -- savings for money needed soon, investing only for money that can stay untouched for years -- is the core idea, not chasing the highest possible short-term return.',
   1);

insert into quizzes (id, skill_id, lesson_id, title, pass_threshold) values
  ('00000000-0000-0000-0003-000000000009', '00000000-0000-0000-0001-000000000009', '00000000-0000-0000-0002-000000000009', 'Simple Investing Basics Quiz', 0.8);

insert into quiz_questions (quiz_id, question, options, correct_answer, order_index) values
  ('00000000-0000-0000-0003-000000000009', 'What is the key difference between saving and investing, per the lesson?',
    '["They are exactly the same thing", "Saving keeps money safe with predictable, small growth; investing can grow faster but its value can also fall", "Investing always guarantees more money than saving", "Saving always loses value over time"]'::jsonb,
    'Saving keeps money safe with predictable, small growth; investing can grow faster but its value can also fall', 1),
  ('00000000-0000-0000-0003-000000000009', 'Why is money you will need in the next few months generally kept in savings rather than invested?',
    '["Savings accounts always pay more than investments", "Investments can temporarily drop in value, and you may not have time to wait for a recovery before you need the money", "Investing is illegal for short time periods", "Savings accounts are the only legal place to keep money"]'::jsonb,
    'Investments can temporarily drop in value, and you may not have time to wait for a recovery before you need the money', 2),
  ('00000000-0000-0000-0003-000000000009', 'Aisha needs her £200 back in three months for something specific. Per the worked example, what is the safer choice for that money?',
    '["Investing it in a share fund for maximum growth", "Keeping it in a savings account", "Splitting it evenly regardless of the timeframe", "It does not matter which she chooses"]'::jsonb,
    'Keeping it in a savings account', 3),
  ('00000000-0000-0000-0003-000000000009', 'What does buying a "share" in a company mean, per the lesson?',
    '["Lending the company money that must be repaid on a fixed schedule", "Buying a small piece of ownership in that company", "Guaranteeing the company will pay you a fixed interest rate", "Working for the company for free"]'::jsonb,
    'Buying a small piece of ownership in that company', 4),
  ('00000000-0000-0000-0003-000000000009', 'Why is investing usually described as a long-term idea rather than a way to quickly grow a small amount of money?',
    '["Because investments never grow at all", "Because short-term drops in value are common, and more time gives an investment a better chance to recover and grow", "Because it is illegal to invest for less than 10 years", "Because investment returns are always identical to savings returns"]'::jsonb,
    'Because short-term drops in value are common, and more time gives an investment a better chance to recover and grow', 5);

-- ===================== 010: Taxes Basics =====================

insert into skills (id, tier, slug, title, prerequisite_skill_id, mastery_threshold) values
  ('00000000-0000-0000-0001-000000000010', 'school', 'taxes-basics', 'Taxes Basics',
    '00000000-0000-0000-0001-000000000009', 0.8);

insert into lessons (id, skill_id, content_type, content_body, order_index) values
  ('00000000-0000-0000-0002-000000000010', '00000000-0000-0000-0001-000000000010', 'article',
   'A tax is money collected by the government from people and businesses, used to pay for shared things everyone benefits from -- schools, roads, hospitals, and public services. You do not get to individually choose whether to pay tax or opt out of the services it funds; it is a required contribution, not a purchase.

There are different kinds of tax that show up in everyday life. Income tax is taken from money you earn from a job, usually automatically before it ever reaches your bank account -- which is why a job''s advertised salary is usually more than what actually lands in your account each payday. Sales tax (VAT in the UK) is added to the price of many things you buy in shops, so the price on the shelf is not always the full amount you pay at the till. Because income tax is taken automatically by an employer, most people''s first real encounter with "the amount I earn isn''t the amount I take home" is their very first payslip from a job.

Worked example: Mia gets her first part-time job advertised at £10 an hour. After working 10 hours, she might expect £100 -- but her actual payslip shows £100 earned, minus income tax and other automatic deductions, landing at perhaps £91 in her bank account. That gap is not a mistake or a fee taken by her employer for themselves -- it is tax being collected at the source, the same money that funds the school she attends and the road she uses to get there.

Recap: taxes are required contributions that fund shared public services like schools, roads, and hospitals -- not optional purchases. Income tax is usually deducted automatically from wages before you receive them, and sales tax (VAT) is added to the price of many purchases, both meaning the amount earned or the sticker price is often not the full amount that ends up in your pocket or that you pay at the till.',
   1);

insert into quizzes (id, skill_id, lesson_id, title, pass_threshold) values
  ('00000000-0000-0000-0003-000000000010', '00000000-0000-0000-0001-000000000010', '00000000-0000-0000-0002-000000000010', 'Taxes Basics Quiz', 0.8);

insert into quiz_questions (quiz_id, question, options, correct_answer, order_index) values
  ('00000000-0000-0000-0003-000000000010', 'What is a tax, per the lesson?',
    '["An optional donation to a charity", "Money collected by the government to fund shared public services like schools and roads", "A fee a shop keeps for itself", "A fine for breaking a rule"]'::jsonb,
    'Money collected by the government to fund shared public services like schools and roads', 1),
  ('00000000-0000-0000-0003-000000000010', 'Why does the amount on a payslip often differ from the salary or hourly rate first advertised?',
    '["The employer keeps the difference as profit", "Income tax and other deductions are usually taken automatically before the money reaches your bank account", "Advertised rates are always inaccurate", "Payslips always round down for no reason"]'::jsonb,
    'Income tax and other deductions are usually taken automatically before the money reaches your bank account', 2),
  ('00000000-0000-0000-0003-000000000010', 'Mia works 10 hours at an advertised £10/hour but her payslip shows £91 landing in her account instead of £100. What best explains the difference?',
    '["Her employer made an error", "Income tax and other automatic deductions were taken before the money reached her", "She was underpaid and should query it as a mistake", "Tax is only taken from full-time jobs, so this must be a fee instead"]'::jsonb,
    'Income tax and other automatic deductions were taken before the money reached her', 3),
  ('00000000-0000-0000-0003-000000000010', 'What is VAT (sales tax), per the lesson?',
    '["A tax taken directly from wages before payday", "A tax added to the price of many things bought in shops", "A one-time tax paid only once in your life", "A tax that only applies to savings accounts"]'::jsonb,
    'A tax added to the price of many things bought in shops', 4),
  ('00000000-0000-0000-0003-000000000010', 'Why is tax described as a required contribution rather than an optional purchase?',
    '["Because you can individually opt out of the services it funds", "Because everyone is required to contribute, and cannot individually choose to skip it while still using shared public services", "Because it is always voluntary in practice", "Because only businesses pay it, never individuals"]'::jsonb,
    'Because everyone is required to contribute, and cannot individually choose to skip it while still using shared public services', 5);

-- ===================== 011: Entrepreneurship Basics =====================

insert into skills (id, tier, slug, title, prerequisite_skill_id, mastery_threshold) values
  ('00000000-0000-0000-0001-000000000011', 'school', 'entrepreneurship-basics', 'Entrepreneurship Basics',
    '00000000-0000-0000-0001-000000000010', 0.8);

insert into lessons (id, skill_id, content_type, content_body, order_index) values
  ('00000000-0000-0000-0002-000000000011', '00000000-0000-0000-0001-000000000011', 'article',
   'An entrepreneur starts and runs their own small enterprise instead of working for someone else''s -- like running a small lemonade stand, dog-walking round, or handmade craft stall. At the core of any such venture is a simple idea: revenue is the money that comes in from selling something, costs are the money that goes out to make and sell it, and profit is whatever is left over once costs are subtracted from revenue. A venture that spends more on costs than it earns in revenue is losing money, no matter how many items it sells.

Costs come in two flavours worth telling apart. Fixed costs stay the same no matter how much you sell -- like a one-off fee to rent a stall for the day. Variable costs scale with how much you make or sell -- like the sugar and lemons needed for each cup of lemonade, where selling twice as many cups roughly doubles that cost. Understanding this split matters because it changes how a single extra sale affects profit: fixed costs are already "paid for" regardless of sales, so each additional sale beyond that point contributes its price minus only its variable cost.

Worked example: Zara runs a lemonade stand. She pays a fixed £5 to rent a table for the day, and each cup costs her 50p in ingredients (a variable cost) to make. She sells cups for £1.50 each. If she sells 20 cups: revenue = 20 x £1.50 = £30; variable costs = 20 x £0.50 = £10; total costs = £10 + £5 (fixed) = £15; profit = £30 - £15 = £15. If she had only sold 3 cups, revenue would be £4.50 against £5 fixed + £1.50 variable = £6.50 total costs -- a loss of £2. The fixed cost of the table has to be covered by enough cups sold before the stand turns any profit at all.

Recap: revenue is money in, costs are money out, and profit is what remains after subtracting costs from revenue. Splitting costs into fixed (unchanged regardless of sales) and variable (scaling with each sale) shows why a venture needs enough sales to cover its fixed costs before each additional sale starts contributing real profit.',
   1);

insert into quizzes (id, skill_id, lesson_id, title, pass_threshold) values
  ('00000000-0000-0000-0003-000000000011', '00000000-0000-0000-0001-000000000011', '00000000-0000-0000-0002-000000000011', 'Entrepreneurship Basics Quiz', 0.8);

insert into quiz_questions (quiz_id, question, options, correct_answer, order_index) values
  ('00000000-0000-0000-0003-000000000011', 'What is profit, per the lesson?',
    '["The total money that comes in from sales, before any costs", "What remains after subtracting costs from revenue", "A fixed cost paid regardless of sales", "The price charged for a single item"]'::jsonb,
    'What remains after subtracting costs from revenue', 1),
  ('00000000-0000-0000-0003-000000000011', 'What is the difference between a fixed cost and a variable cost?',
    '["There is no real difference", "A fixed cost stays the same regardless of sales volume; a variable cost scales with how much is made or sold", "A variable cost is always larger than a fixed cost", "Fixed costs only apply to large businesses"]'::jsonb,
    'A fixed cost stays the same regardless of sales volume; a variable cost scales with how much is made or sold', 2),
  ('00000000-0000-0000-0003-000000000011', 'Zara pays a fixed £5 table rental and 50p in ingredients per cup, selling cups at £1.50 each. If she sells 20 cups, what is her profit?',
    '["£30", "£25", "£15", "£10"]'::jsonb,
    '£15', 3),
  ('00000000-0000-0000-0003-000000000011', 'In the same scenario, if Zara only sells 3 cups, what happens?',
    '["She still makes a small profit", "She makes a loss, because revenue does not cover her fixed and variable costs combined", "Her fixed cost disappears if she sells fewer cups", "Profit is unaffected by how many cups she sells"]'::jsonb,
    'She makes a loss, because revenue does not cover her fixed and variable costs combined', 4),
  ('00000000-0000-0000-0003-000000000011', 'Why does a venture need to sell enough units before it starts turning a real profit, per the lesson?',
    '["Because variable costs must be paid off first, in a fixed order", "Because fixed costs must be covered before each additional sale''s profit (price minus its own variable cost) starts to count as pure profit", "Because prices always increase after a certain number of sales", "Because profit is unrelated to how many units are sold"]'::jsonb,
    'Because fixed costs must be covered before each additional sale''s profit (price minus its own variable cost) starts to count as pure profit', 5);

-- ===================== 012: Credit & Debt Basics =====================

insert into skills (id, tier, slug, title, prerequisite_skill_id, mastery_threshold) values
  ('00000000-0000-0000-0001-000000000012', 'school', 'credit-and-debt-basics', 'Credit & Debt Basics',
    '00000000-0000-0000-0001-000000000011', 0.8);

insert into lessons (id, skill_id, content_type, content_body, order_index) values
  ('00000000-0000-0000-0002-000000000012', '00000000-0000-0000-0001-000000000012', 'article',
   'Credit means borrowing money now with a promise to pay it back later, usually with interest added as the cost of borrowing -- covered from the saver''s side in the earlier lesson on compound interest, but borrowing is the same mechanism working in the opposite direction against you. A credit card is one common form: it lets you buy things immediately using money the card company effectively lends you, which you then owe back. If you pay off the full amount by the due date, many cards charge no interest at all -- but if you only pay part of it, interest is charged on what remains, and it compounds, meaning the amount owed can grow faster than many people expect.

This is why a "minimum payment" on a credit card statement can be misleading: it is calculated to be the smallest amount that keeps the account from being in default, not an amount that meaningfully reduces what is owed. Paying only the minimum, month after month, on a card charging a typical double-digit annual interest rate can mean the vast majority of each payment goes toward interest rather than the original amount borrowed, dragging out repayment for years and multiplying the total cost far beyond the original purchase price. A person''s track record of borrowing and repaying reliably is also tracked over time as a "credit history," which lenders check before agreeing to lend again -- consistently repaying on time builds a good one, while missed or late payments damage it and can make future borrowing (for things like a car or a home) more difficult or expensive.

Worked example: Ravi puts a £300 purchase on a credit card charging 20% annual interest, and only pays the minimum each month rather than the full balance. Because interest is charged on the remaining balance and compounds, a large share of each monthly payment goes to interest rather than reducing the £300 itself -- it can take years to fully repay, and the total amount paid over that time can end up well over £400 for what was originally a £300 purchase, purely from making minimum payments instead of paying it off promptly.

Recap: credit lets you buy now and pay later, but unpaid balances accrue compounding interest, the same mechanism that grows savings but now working against the borrower. Minimum payments are designed to avoid default, not to meaningfully pay down debt, so paying only the minimum on an interest-charging balance can multiply the eventual cost; repaying reliably and on time also builds a credit history that affects how easily and cheaply you can borrow in future.',
   1);

insert into quizzes (id, skill_id, lesson_id, title, pass_threshold) values
  ('00000000-0000-0000-0003-000000000012', '00000000-0000-0000-0001-000000000012', '00000000-0000-0000-0002-000000000012', 'Credit & Debt Basics Quiz', 0.8);

insert into quiz_questions (quiz_id, question, options, correct_answer, order_index) values
  ('00000000-0000-0000-0003-000000000012', 'What is credit, per the lesson?',
    '["Money given to you for free with no obligation", "Borrowing money now with a promise to pay it back later, usually with interest", "A type of savings account", "A government payment"]'::jsonb,
    'Borrowing money now with a promise to pay it back later, usually with interest', 1),
  ('00000000-0000-0000-0003-000000000012', 'What happens if a credit card balance is only partly paid off by the due date, per the lesson?',
    '["No interest is ever charged in that case", "Interest is charged on what remains, and it compounds over time", "The remaining balance is automatically forgiven", "The card is immediately cancelled"]'::jsonb,
    'Interest is charged on what remains, and it compounds over time', 2),
  ('00000000-0000-0000-0003-000000000012', 'Why can paying only the "minimum payment" each month be misleading, per the lesson?',
    '["The minimum payment always pays off the full balance quickly", "It is calculated to avoid default, not to meaningfully reduce the amount owed, so much of each payment can go to interest", "Minimum payments are illegal on most cards", "It guarantees no interest will ever be charged"]'::jsonb,
    'It is calculated to avoid default, not to meaningfully reduce the amount owed, so much of each payment can go to interest', 3),
  ('00000000-0000-0000-0003-000000000012', 'Ravi puts £300 on a card charging 20% annual interest and pays only the minimum each month. What does the lesson say tends to happen?',
    '["The balance is repaid quickly with little extra cost", "A large share of each payment goes to interest, and the total repaid can end up well over £400 for the £300 purchase", "Interest stops accruing after the first month", "The card company absorbs the interest cost instead of Ravi"]'::jsonb,
    'A large share of each payment goes to interest, and the total repaid can end up well over £400 for the £300 purchase', 4),
  ('00000000-0000-0000-0003-000000000012', 'What is a "credit history," and why does it matter, per the lesson?',
    '["A record of every purchase you have ever made, unrelated to borrowing", "A tracked record of borrowing and repaying reliably over time, which lenders check before agreeing to lend again", "A score given only once and never updated", "A requirement only for businesses, never individuals"]'::jsonb,
    'A tracked record of borrowing and repaying reliably over time, which lenders check before agreeing to lend again', 5);

-- ===================== 013: Insurance Basics =====================

insert into skills (id, tier, slug, title, prerequisite_skill_id, mastery_threshold) values
  ('00000000-0000-0000-0001-000000000013', 'school', 'insurance-basics', 'Insurance Basics',
    '00000000-0000-0000-0001-000000000012', 0.8);

insert into lessons (id, skill_id, content_type, content_body, order_index) values
  ('00000000-0000-0000-0002-000000000013', '00000000-0000-0000-0001-000000000013', 'article',
   'Insurance is a way of protecting against a large, unpredictable cost by paying a smaller, predictable amount regularly (called a premium) to an insurance company. In exchange, the insurer agrees to cover a large loss if a specific bad event happens -- a bike being stolen, a phone screen shattering, a house catching fire. Most people who pay a premium in any given year never make a claim at all, and that is not a waste: it means the bad event simply did not happen to them that year, which is what everyone paying in is hoping for.

The idea works because of shared risk across a large group. An insurance company collects small premiums from thousands of people, only a small fraction of whom will experience the insured event in any given year; the pooled premiums from everyone cover the payouts to that unlucky fraction, with the company keeping a portion to cover its own costs and profit. This is why insurance is not designed to make the average person money -- if it reliably paid out more than it collected, insurance companies could not stay in business -- but it is extremely valuable for the specific people who do experience the loss, turning a cost that could be financially devastating into one they had already budgeted for as a manageable premium.

Worked example: Priya pays £5 a month (£60 a year) to insure her £400 phone against accidental damage. Most years, nothing happens to her phone, and that £60 feels, in hindsight, like money she "didn''t need to spend." But in the one year her phone is dropped and the screen shatters, the insurer covers most of the £150 repair cost for a small excess fee, rather than Priya having to find £150 unexpectedly all at once. Across many people paying similar premiums, the insurer''s income from those who never claim funds the payouts to those who do -- which is exactly the trade Priya is making: a small, certain cost every year in exchange for protection against a larger, uncertain one.

Recap: insurance trades a small, predictable, regular cost (the premium) for protection against a large, unpredictable loss, funded by pooling many people''s premiums together since only a fraction will claim in any given period. Not claiming in a given year is not wasted money -- it means the covered bad event did not happen -- and the value of insurance is precisely in turning a potentially devastating cost into a manageable, budgeted one for whoever does experience the loss.',
   1);

insert into quizzes (id, skill_id, lesson_id, title, pass_threshold) values
  ('00000000-0000-0000-0003-000000000013', '00000000-0000-0000-0001-000000000013', '00000000-0000-0000-0002-000000000013', 'Insurance Basics Quiz', 0.8);

insert into quiz_questions (quiz_id, question, options, correct_answer, order_index) values
  ('00000000-0000-0000-0003-000000000013', 'What is insurance, per the lesson?',
    '["A guaranteed way to make money every year", "Paying a smaller, predictable premium in exchange for protection against a large, unpredictable loss", "A savings account with a fixed interest rate", "A type of tax on valuable items"]'::jsonb,
    'Paying a smaller, predictable premium in exchange for protection against a large, unpredictable loss', 1),
  ('00000000-0000-0000-0003-000000000013', 'Why is not making a claim in a given year not considered wasted money, per the lesson?',
    '["Because the premium is always refunded if you don''t claim", "Because it means the insured bad event simply did not happen to you that year, which is the outcome everyone is hoping for", "Because insurers require at least one claim per year", "Because unclaimed premiums are illegal to keep"]'::jsonb,
    'Because it means the insured bad event simply did not happen to you that year, which is the outcome everyone is hoping for', 2),
  ('00000000-0000-0000-0003-000000000013', 'How does pooling premiums across many people make insurance work, per the lesson?',
    '["Every person who pays a premium is guaranteed to claim the same year", "Premiums from the many who don''t claim in a given period fund payouts to the smaller fraction who do", "Insurance companies rely entirely on government funding", "Pooling has no real effect on how insurance works"]'::jsonb,
    'Premiums from the many who don''t claim in a given period fund payouts to the smaller fraction who do', 3),
  ('00000000-0000-0000-0003-000000000013', 'Priya pays £60 a year to insure her phone, and one year her screen shatters, costing £150 to repair. What does insurance let her avoid, per the worked example?',
    '["Paying any premium at all that year", "Having to find £150 unexpectedly all at once for the repair", "Ever using her phone again", "Paying tax on the repair"]'::jsonb,
    'Having to find £150 unexpectedly all at once for the repair', 4),
  ('00000000-0000-0000-0003-000000000013', 'Why can''t insurance reliably pay out more, on average, than it collects in premiums, per the lesson?',
    '["Because insurance companies would not be able to stay in business if it did", "Because it is illegal for insurers to profit at all", "Because premiums are set randomly with no relation to claims", "Because claims are always smaller than premiums paid"]'::jsonb,
    'Because insurance companies would not be able to stay in business if it did', 5);

-- ===================== 014: Comparison Shopping & Consumer Skills =====================

insert into skills (id, tier, slug, title, prerequisite_skill_id, mastery_threshold) values
  ('00000000-0000-0000-0001-000000000014', 'school', 'comparison-shopping-and-consumer-skills', 'Comparison Shopping & Consumer Skills',
    '00000000-0000-0000-0001-000000000013', 0.8);

insert into lessons (id, skill_id, content_type, content_body, order_index) values
  ('00000000-0000-0000-0002-000000000014', '00000000-0000-0000-0001-000000000014', 'article',
   'The sticker price on an item is not always the best way to compare value, especially when items come in different sizes, quantities, or payment plans. Unit price -- the cost per single unit of measure, like per 100g or per item -- lets you compare a £3 pack of 6 items against a £4.50 pack of 10 items on equal footing, even though the packs themselves look completely different. Without converting to a common unit, it is easy to assume the more expensive-looking price is the worse deal, when the opposite may actually be true.

Marketing and store layout are also designed to influence what feels like a good deal, not just to inform you of one. A large "50% off" sign draws attention to the discount, but the real question is always the final price compared to the same or a similar item elsewhere -- a "discounted" item can still be more expensive than an ordinary-priced alternative. Similarly, buying in bulk is often, but not always, cheaper per unit; it is only a genuine saving if you will actually use the extra quantity before it expires or becomes useless, otherwise the "saving" is wasted the moment the excess is thrown away.

Worked example: a shop sells juice in a 500ml bottle for £1.20, and a 1.5 litre bottle for £3.30. The unit price of the small bottle is £1.20 / 500ml = £0.24 per 100ml. The unit price of the large bottle is £3.30 / 1500ml = £0.22 per 100ml -- genuinely a bit cheaper per unit. But if someone only drinks juice occasionally and half the large bottle would go off before it is finished, buying the smaller bottle at a slightly higher unit price may still be the better real-world choice, because the "extra" juice in the big bottle is never actually used.

Recap: comparing unit price (cost per common measure, like per 100g or per 100ml) rather than sticker price is the reliable way to compare differently-sized options fairly. Discounts and bulk sizes are only genuine savings if the final unit price is actually lower and you will realistically use the full quantity -- otherwise the apparent saving is marketing framing rather than real value.',
   1);

insert into quizzes (id, skill_id, lesson_id, title, pass_threshold) values
  ('00000000-0000-0000-0003-000000000014', '00000000-0000-0000-0001-000000000014', '00000000-0000-0000-0002-000000000014', 'Comparison Shopping & Consumer Skills Quiz', 0.8);

insert into quiz_questions (quiz_id, question, options, correct_answer, order_index) values
  ('00000000-0000-0000-0003-000000000014', 'What is "unit price," per the lesson?',
    '["The total price shown on the shelf label", "The cost per single common unit of measure, like per 100g or per item", "The price after all discounts are removed", "A price that only applies to bulk purchases"]'::jsonb,
    'The cost per single common unit of measure, like per 100g or per item', 1),
  ('00000000-0000-0000-0003-000000000014', 'Why is unit price more reliable than sticker price for comparing a 6-pack and a 10-pack of the same item?',
    '["Sticker price is always more accurate", "It puts differently-sized options on equal footing by converting to a shared measure", "Unit price is always identical to sticker price", "It only matters for items that never go on sale"]'::jsonb,
    'It puts differently-sized options on equal footing by converting to a shared measure', 2),
  ('00000000-0000-0000-0003-000000000014', 'A 500ml bottle costs £1.20 (£0.24 per 100ml) and a 1.5 litre bottle costs £3.30 (£0.22 per 100ml). Which has the lower unit price?',
    '["The 500ml bottle", "The 1.5 litre bottle", "They are exactly equal", "Unit price cannot be compared between different sizes"]'::jsonb,
    'The 1.5 litre bottle', 3),
  ('00000000-0000-0000-0003-000000000014', 'In the worked example, why might the smaller bottle still be the better real-world choice for someone who drinks juice occasionally?',
    '["Because the smaller bottle actually has a lower unit price", "Because unused juice in the larger bottle going off before use would waste the apparent per-unit saving", "Because larger bottles are always illegal to sell", "Because unit price does not apply to drinks"]'::jsonb,
    'Because unused juice in the larger bottle going off before use would waste the apparent per-unit saving', 4),
  ('00000000-0000-0000-0003-000000000014', 'Why does the lesson caution against trusting a large "50% off" sign at face value?',
    '["Discounts are always fake", "The real question is the final price compared to similar items elsewhere -- a discounted item can still cost more than an ordinary-priced alternative", "Percentage discounts are illegal in most shops", "Discounted items are always the best unit price by definition"]'::jsonb,
    'The real question is the final price compared to similar items elsewhere -- a discounted item can still cost more than an ordinary-priced alternative', 5);

-- ===================== 015: Financial Goal Setting =====================

insert into skills (id, tier, slug, title, prerequisite_skill_id, mastery_threshold) values
  ('00000000-0000-0000-0001-000000000015', 'school', 'financial-goal-setting', 'Financial Goal Setting',
    '00000000-0000-0000-0001-000000000014', 0.8);

insert into lessons (id, skill_id, content_type, content_body, order_index) values
  ('00000000-0000-0000-0002-000000000015', '00000000-0000-0000-0001-000000000015', 'article',
   'Everything covered so far -- saving, budgeting, needs vs. wants, earning, borrowing carefully -- works best when it is aimed at something specific, rather than practiced as vague good habits in the abstract. A financial goal turns "I should save more" into a concrete target: a specific amount, for a specific purpose, by a specific date. Vague goals are hard to act on because there is no way to tell whether any given week''s choices are actually moving you closer to them or not.

A useful way to make a goal concrete is to work backward from the target: figure out the total amount needed, the time available, and divide to find how much needs to be set aside per week or month. This turns a single large, possibly intimidating number into a small, manageable, repeatable action -- and it also makes it immediately obvious whether a goal is realistic given your actual income, or whether the timeline, the amount, or the spending elsewhere needs adjusting.

Worked example: Kofi wants a £120 bike in 12 weeks. £120 / 12 weeks = £10 a week needs to be saved. Kofi earns £15 a week from chores and an allowance. If he budgets £10 a week for the bike and keeps £5 for other spending, the goal is realistic and on track -- he can check every single week whether he actually saved his £10, rather than only finding out in week 12 whether it worked out. If Kofi had instead wanted the bike in 4 weeks, the same maths would require £30 a week -- more than his total income -- immediately revealing that goal is unrealistic without either extending the timeline, finding extra income, or choosing a cheaper bike.

Recap: turning a vague intention into a financial goal means specifying an amount, a purpose, and a deadline, then working backward to find the regular amount needed per week or month. This makes progress checkable at every step rather than only at the end, and quickly reveals whether a goal is realistic for your actual income -- and if not, exactly which lever (timeline, amount, or spending elsewhere) needs to change to make it so.',
   1);

insert into quizzes (id, skill_id, lesson_id, title, pass_threshold) values
  ('00000000-0000-0000-0003-000000000015', '00000000-0000-0000-0001-000000000015', '00000000-0000-0000-0002-000000000015', 'Financial Goal Setting Quiz', 0.8);

insert into quiz_questions (quiz_id, question, options, correct_answer, order_index) values
  ('00000000-0000-0000-0003-000000000015', 'What makes a financial goal more useful than a vague intention like "I should save more," per the lesson?',
    '["Vague intentions always work better in practice", "A goal specifies an amount, a purpose, and a deadline, making progress checkable along the way", "Financial goals remove the need to actually save any money", "There is no real difference between the two"]'::jsonb,
    'A goal specifies an amount, a purpose, and a deadline, making progress checkable along the way', 1),
  ('00000000-0000-0000-0003-000000000015', 'Kofi wants a £120 bike in 12 weeks. How much does he need to save per week, per the worked example?',
    '["£5", "£10", "£12", "£15"]'::jsonb,
    '£10', 2),
  ('00000000-0000-0000-0003-000000000015', 'Kofi earns £15 a week and needs to save £10 a week for his bike goal. Is this goal realistic, per the lesson?',
    '["No, because £10 exceeds his total income", "Yes, because £10 fits within his £15 weekly income, leaving £5 for other spending", "It cannot be determined without knowing the bike''s color", "No, because goals with a deadline are never realistic"]'::jsonb,
    'Yes, because £10 fits within his £15 weekly income, leaving £5 for other spending', 3),
  ('00000000-0000-0000-0003-000000000015', 'If Kofi instead wanted the same £120 bike in just 4 weeks, how much would he need to save per week, and what would that reveal?',
    '["£10 a week -- exactly the same as before", "£30 a week -- more than his £15 income, revealing the goal is unrealistic as set", "£120 a week -- the full amount up front", "£4 a week -- easily achievable"]'::jsonb,
    '£30 a week -- more than his £15 income, revealing the goal is unrealistic as set', 4),
  ('00000000-0000-0000-0003-000000000015', 'What is the benefit of working backward from a goal''s total amount and deadline to a weekly saving figure, per the lesson?',
    '["It has no practical benefit over just hoping for the best", "It turns one large, intimidating number into a small, repeatable action and makes it checkable every week", "It guarantees the goal will be met regardless of income", "It only works for goals under £50"]'::jsonb,
    'It turns one large, intimidating number into a small, repeatable action and makes it checkable every week', 5);
