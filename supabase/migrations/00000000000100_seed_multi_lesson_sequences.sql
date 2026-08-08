-- Multi-lesson expansion: every skill across School/College/Job-Ready gets
-- 2-4 additional lessons.sql rows (same skill_id, incrementing order_index
-- starting at 2; the pre-existing lesson keeps order_index 1), breaking
-- each topic into a real foundational -> application/deep-dive sequence.
-- Presentation (ConceptCard/KeyTermBox/etc block) entries for these new
-- lessons, plus for every pre-existing lesson that didn't already have
-- one, live in lib/lessons/content-overrides.ts (code, not the DB -- see
-- that file's header comment for why).


-- ===================== School multi-lesson expansion =====================
-- what-is-money
insert into lessons (id, skill_id, content_type, content_body, order_index) values
  ('00000000-0000-0000-0002-000000900102', '00000000-0000-0000-0001-000000000001', 'article',
   'Before coins and notes existed, people bartered — trading goods and services directly for other goods and services. The problem with bartering is that it depends on a "double coincidence of wants": you need to find someone who has what you want AND wants what you have, at the same time. A farmer with extra eggs who wants shoes has to find a shoemaker who happens to want eggs that day — otherwise no trade happens at all, even though both people have something to offer.

Money fixes this by acting as a middle step everyone accepts. Instead of the farmer needing to find a shoe-wanting egg buyer, they can sell eggs to anyone for money, then use that money to buy shoes from anyone, whether or not the shoemaker wants eggs. Money only works this way because of shared trust — a coin or a banknote has no real value on its own (you can''t eat it or wear it), but because everyone accepts it in exchange for real things, it functions as if it does.

Worked example: a fisherman wants a haircut, but the barber doesn''t want fish that day. Without money, no trade happens. With money, the fisherman sells fish to a customer for £10, then pays the barber £10 for a haircut — the barber accepts the £10 not because they want it for its own sake, but because they trust it will buy them something they do want later.

Recap: bartering breaks down because it requires both people to want exactly what the other is offering, at the same time. Money removes that requirement by acting as something everyone accepts and trusts, letting trade happen between people whose wants don''t line up directly.',
   2),
  ('00000000-0000-0000-0002-000000900103', '00000000-0000-0000-0001-000000000001', 'article',
   'Money is generally expected to do three jobs at once, and it''s worth knowing all three because they explain why some things work well as money and others don''t. First, it''s a medium of exchange — something accepted in trade for goods and services, so people don''t need to barter. Second, it''s a store of value — it can be held onto and still be worth roughly the same later, so you don''t have to spend everything the moment you earn it. Third, it''s a unit of account — a common way to price and compare completely different things, so you can tell that a jacket costing £40 is "worth" roughly the same as four takeaway meals at £10 each.

Things that fail at one of these jobs make poor money. Fresh fruit could technically be traded, but it rots, so it fails as a store of value. A rare painting can store value well, but it''s hard to divide into small amounts for everyday purchases, so it''s a poor unit of account and a clumsy medium of exchange. Coins, notes, and bank balances work well precisely because they hold value reasonably steadily, divide into useful amounts (pounds and pence), and are widely accepted.

Worked example: imagine trying to price a bicycle in loaves of bread instead of pounds — is it 200 loaves? 250? Without a stable, common unit like currency, comparing the value of very different items becomes awkward and inconsistent, and saving up "250 loaves" for later doesn''t really work since bread goes stale.

Recap: money works as medium of exchange, store of value, and unit of account together — and things that fail at any one of those three jobs (perishable, hard to divide, unstable in value) make poor substitutes for it, which is why coins, notes, and bank balances became the standard.',
   3);

-- needs-vs-wants
insert into lessons (id, skill_id, content_type, content_body, order_index) values
  ('00000000-0000-0000-0002-000000900202', '00000000-0000-0000-0001-000000000002', 'article',
   'Most everyday items aren''t purely a "need" or purely a "want" — the honest answer usually depends on the specific version and situation. Food is a need, but a £15 restaurant meal when a £3 home-cooked meal would do is mostly a want layered on top of a real need. A phone can be a genuine need for a teenager who uses it to contact parents or complete schoolwork, but the latest £1,000 model versus a £150 basic phone that does the same job is a want. Recognising this "need with a want layered on top" pattern is more useful than trying to sort every purchase into one of two rigid boxes.

A simple test that helps: ask "would something bad happen soon if I didn''t have this?" If the honest answer is no, or "I''d just prefer it," it''s leaning toward a want, even if it feels important in the moment. This isn''t about never buying wants — wants are a normal and healthy part of spending — it''s about being honest with yourself about which category a purchase falls into, so you''re making a deliberate choice rather than mislabeling a want as a need to justify it.

Worked example: Jaydon says he "needs" new trainers because his current ones have a small scuff. Applying the test: would something bad happen soon without new trainers? No — the current ones still work fine. It''s a want (upgrading for appearance), which is a fine reason to buy them if the budget allows, but it shouldn''t be prioritised over an actual need, like replacing a school bag with a broken zip that''s spilling books.

Recap: many purchases are a real need with an optional want layered on top (a basic vs. premium version of the same item). Asking "would something bad happen soon without this?" helps sort genuine needs from wants honestly, so wants get bought deliberately rather than mislabeled to jump ahead of real needs.',
   2),
  ('00000000-0000-0000-0002-000000900203', '00000000-0000-0000-0001-000000000002', 'article',
   'Needs and wants aren''t just a sorting exercise — they''re a practical tool for deciding what to spend limited money on first. A simple approach: list your needs and estimate their real cost, cover those first, and only spend on wants with whatever is genuinely left over. This flips a common habit of spending on wants as they come up and hoping there''s enough left for needs later, which is a much riskier order — needs don''t stop needing to be paid for just because the money already went elsewhere.

It also helps to notice that "wants" aren''t fixed — they change with age, circumstances, and what your friends have, which is exactly why marketing and social pressure are so effective at making wants feel urgent, almost like needs. Recognising that pull ("everyone has the new trainers" isn''t the same as "I need new trainers") is a skill in itself, separate from just knowing the definitions.

Worked example: Priya has £30 pocket money this month. Her needs: £8 for bus fare to get to a friend''s house she''d already committed to, £5 for a school supply she''s genuinely out of. That''s £13 in needs, leaving £17 for wants — a cinema trip (£10) and saving £7 toward a game she wants. If Priya had instead spent £25 on the cinema trip and new game first, she''d only have £5 left for £13 of needs — a real shortfall for things that actually matter.

Recap: covering needs first with actual money, then spending only what''s left on wants, avoids the risk of running short on essentials. Wants shift with age and social pressure, and recognising that pull for what it is — not a real need — is as important as knowing the textbook definition.',
   3);

-- saving-basics
insert into lessons (id, skill_id, content_type, content_body, order_index) values
  ('00000000-0000-0000-0002-000000900302', '00000000-0000-0000-0001-000000000003', 'article',
   'Saving is easiest to stick with when it''s automatic rather than left to willpower. "Pay yourself first" means setting aside your savings amount the moment money arrives — before any spending happens — rather than saving "whatever''s left" at the end of the week or month. The second approach usually leaves little or nothing, because spending naturally expands to use whatever''s available if savings aren''t set aside first.

A useful way to think about it: treat your savings amount like a bill you owe yourself, due immediately, not an optional extra you''ll get to if there''s time. This doesn''t require a large amount — even a small, consistent amount set aside first beats a larger amount that only happens "if there''s some left," because the second one is unreliable.

Worked example: Ben gets £20 pocket money weekly. Plan A: he spends throughout the week and checks what''s left on Sunday — some weeks it''s £3, some weeks it''s £0. Plan B: he moves £5 into a savings jar the moment he gets the £20, then spends the remaining £15 freely through the week. Over 8 weeks, Plan B guarantees £40 saved; Plan A might total far less, and varies unpredictably week to week.

Recap: saving first — treating it like an immediate obligation rather than an afterthought — produces much more reliable results than saving "whatever''s left," because spending tends to expand to fill whatever money is available if nothing is set aside up front.',
   2),
  ('00000000-0000-0000-0002-000000900303', '00000000-0000-0000-0001-000000000003', 'article',
   'Where you keep savings matters, not just how much you save. Cash in a jar or under a mattress is easy to access — which can actually be a downside, since it''s just as easy to dip into for an unplanned purchase. A savings account at a bank keeps money slightly more separated from everyday spending, and usually pays a small amount of interest on top, meaning the balance grows a little just for being there, on top of whatever you add yourself.

Separating a savings goal from everyday spending money — even informally, like a labelled jar or a named section of a banking app — creates a small but real barrier against spending it by accident. It also makes progress visible: seeing a jar or balance labelled "bike fund" climb toward a target is motivating in a way that money mixed in with everyday spending cash isn''t.

Worked example: Freya keeps all her money in one place — spending and saving mixed together. When she wants a snack and has "enough" in total, she can''t easily tell if she''s spending her actual spare cash or dipping into savings meant for a jacket. If she instead kept £20 labelled "jacket fund" completely separate, she''d have to make a deliberate decision to move money out of it, rather than accidentally spending it without noticing.

Recap: keeping savings physically or visibly separate from everyday spending money — whether a labelled jar or a separate account — makes accidental spending less likely and progress toward a goal easier to see and stay motivated by.',
   3);

-- earning-pocket-money
insert into lessons (id, skill_id, content_type, content_body, order_index) values
  ('00000000-0000-0000-0002-000000900402', '00000000-0000-0000-0001-000000000004', 'article',
   'Not all pocket money comes the same way, and the source affects how reliable it is to plan around. A fixed allowance — the same amount on the same schedule regardless of what you do — is predictable, which makes it easy to plan a weekly budget or savings amount around it. Chore-based or task-based earning is less predictable: it depends on actually doing the chore, and the amount might vary week to week depending on which chores were available or completed.

One-off jobs, like helping a neighbour with a specific task, are the least predictable of all — they don''t happen on any fixed schedule, so they''re better treated as a bonus on top of a plan, not something to count on for a specific week''s needs. Mixing these types is common and fine, but it helps to know which part of your income is reliable (safe to plan spending or saving around) and which part is a bonus (nice when it happens, but not something to depend on).

Worked example: Sam gets a fixed £10/week allowance, plus £5 for each week he does the washing up (not guaranteed — some weeks he skips it), plus occasional £8 for helping a neighbour with gardening (maybe once a month). Sam should budget his regular spending and saving around the reliable £10, treat the chore money as a likely-but-not-certain extra, and treat the gardening money as a genuine bonus he doesn''t count on for any particular week.

Recap: pocket money from different sources has different reliability — a fixed allowance is safest to plan around, chore-based earning is somewhat variable, and one-off jobs are genuine bonuses. Knowing which category each source falls into avoids planning spending around money that might not actually show up that week.',
   2),
  ('00000000-0000-0000-0002-000000900403', '00000000-0000-0000-0001-000000000004', 'article',
   'Deciding how to split earned money between spending and saving is a habit worth setting up deliberately, the moment money is earned, rather than figuring it out after it''s already been spent. A simple starting rule — like saving a fixed fraction of everything earned, regardless of the source — is easier to stick to consistently than deciding case by case each time, because it removes the need to make a fresh decision (and find a fresh excuse not to save) every single time money comes in.

This also compounds nicely with earning more: if the split is a percentage rather than a fixed amount, saving automatically scales up when earning goes up, without needing to remember to adjust it. A percentage rule like "save 25% of anything earned" behaves consistently whether the amount earned that week is £5 or £50.

Worked example: Dani sets a rule to save 25% of everything earned, no matter the source. One week she earns £12 from an allowance and £8 from helping with a car wash, totalling £20 — she saves £5 (25% of £20) and spends £15. Another week she only earns £4 from a small chore — she saves £1 and spends £3. The rule applies automatically regardless of how much or where the money came from, so Dani never has to decide fresh each time.

Recap: setting a consistent rule — like saving a fixed percentage of everything earned — the moment money arrives removes the need for a fresh decision every time, and scales naturally whether earnings are small or large.',
   3);

-- compound-interest-basics
insert into lessons (id, skill_id, content_type, content_body, order_index) values
  ('00000000-0000-0000-0002-000000900502', '00000000-0000-0000-0001-000000000005', 'article',
   'How much compound interest matters depends heavily on two things: the interest rate and the length of time money is left to compound. A small difference in rate looks minor over one year, but the gap widens dramatically over many years, because each year''s growth is calculated on an already-bigger balance. This is why starting to save early, even a small amount, tends to matter more than people expect — time does a lot of the work.

A useful rough shortcut for getting a feel for this is the "rule of 72": dividing 72 by the annual interest rate gives a rough estimate of how many years it takes an amount to double. At 6% interest, money roughly doubles in 72 ÷ 6 = 12 years; at 9%, it roughly doubles in 72 ÷ 9 = 8 years. It''s an approximation, not an exact formula, but it''s a fast way to compare how rate and time interact without doing a full year-by-year calculation.

Worked example: two people each save £500. Person A starts at age 16 and leaves it untouched at 6% interest until age 40 (24 years) — using the rule of 72, the money roughly doubles twice in that time (doubling roughly every 12 years), reaching somewhere around £2,000. Person B starts the same £500 at age 28, leaving only 12 years until age 40 — it roughly doubles just once, to around £1,000. Same starting amount, same rate, but starting 12 years earlier roughly doubles the result, purely from extra compounding time.

Recap: compound growth accelerates with both a higher rate and more time, and the rule of 72 (72 ÷ rate ≈ years to double) is a quick way to estimate that effect. Starting to save earlier matters more than it seems, because extra years of compounding can be worth as much as a much larger contribution made later.',
   2),
  ('00000000-0000-0000-0002-000000900503', '00000000-0000-0000-0001-000000000005', 'article',
   'Compounding doesn''t only happen once a year — many real accounts add interest more often, like monthly, and this changes the outcome even at the "same" advertised annual rate. When interest compounds more frequently, each smaller addition starts earning its own interest sooner than it would if interest were only added once a year, so the actual amount earned over a year ends up slightly higher than the simple annual rate would suggest.

This is why two accounts advertising the same annual rate aren''t always identical — one that compounds monthly will out-earn one that compounds only annually, even though the headline rate looks the same on paper. The difference is usually small over short periods, but it''s a real, correct reason the fine print on savings and loan products matters, not just the big advertised number.

Worked example: £1,000 at 12% annual interest, compounded once a year, becomes £1,000 × 1.12 = £1,120 after one year. The same £1,000 at 12% annual interest but compounded monthly (1% per month) becomes £1,000 × (1.01)^12 ≈ £1,126.83 — about £6.83 more, purely from compounding in smaller, more frequent steps rather than one big annual step.

Recap: compounding more frequently (monthly rather than annually) produces a slightly higher actual return than the same headline annual rate compounded just once — a real, if usually modest, effect that''s worth knowing about when the fine print of a savings or loan product mentions how often interest compounds.',
   3);

-- budgeting-basics
insert into lessons (id, skill_id, content_type, content_body, order_index) values
  ('00000000-0000-0000-0002-000000900602', '00000000-0000-0000-0001-000000000006', 'article',
   'Before applying any split like 50/30/20, it''s worth actually tracking where money currently goes for a couple of weeks, because most people''s mental estimate of their own spending is noticeably wrong — usually because small, frequent purchases (a snack here, a top-up there) don''t feel significant individually and get forgotten, even though they add up to a real total. Tracking means writing down or noting every single thing spent, no matter how small, for a set period, then adding it up by category afterward.

This tracking step matters because a budget built on a wrong guess about current spending won''t actually work — if someone assumes they spend £5 a week on snacks but it''s really £15, a budget plan built on the £5 guess will be broken from day one, not because the plan itself was bad, but because it wasn''t based on real numbers.

Worked example: Leo guesses he spends about £10 a week on "extra stuff." After tracking every purchase for two weeks, he finds he actually spent £34 across the two weeks — about £17 a week, not £10 — mostly small purchases like vending machine snacks and a mobile game top-up that he hadn''t been mentally counting. With the real number, Leo can now build a budget that reflects what he actually does, rather than a guess that was off by 70%.

Recap: tracking real spending for a couple of weeks before setting a budget catches the gap between what people think they spend and what they actually spend — usually driven by small, frequent purchases that don''t feel significant individually. A budget built on real numbers is far more likely to actually work than one built on a guess.',
   2),
  ('00000000-0000-0000-0002-000000900603', '00000000-0000-0000-0001-000000000006', 'article',
   'A budget isn''t a one-time plan set and forgotten — it needs regular checking against what actually happened, because real spending rarely matches a plan exactly every single time, and the point of checking isn''t to feel bad about going over, but to notice and adjust. A simple weekly or monthly review — comparing what was actually spent per category against what was planned — catches problems early, while there''s still time to adjust, rather than discovering a shortfall only once money has already run out.

When actual spending consistently doesn''t match a category''s plan, that''s useful information, not necessarily a failure — it might mean the category was set unrealistically low to begin with (which tracking real spending first, as covered separately, helps avoid) or that spending habits have genuinely shifted and the budget needs updating to reflect real life rather than an outdated plan.

Worked example: Nadia budgets £15 a month for wants, but reviewing after two weeks, she''s already spent £14. Rather than ignoring this until the month is over and money runs out, she checks in now: either she cuts wants spending for the rest of the month to stay on track, or she recognises £15 was set too low for how she actually wants to live and adjusts the plan — moving a little from another category — for next month. Either way, catching it at the two-week mark gives her options that waiting until day 30 wouldn''t.

Recap: a budget needs regular checking against actual spending, not just a one-time plan — catching a mismatch early (while there''s still time to adjust spending or the plan itself) is far more useful than discovering it only once the month, and the money, has already run out.',
   3);

-- banking-and-inflation-basics
insert into lessons (id, skill_id, content_type, content_body, order_index) values
  ('00000000-0000-0000-0002-000000900702', '00000000-0000-0000-0001-000000000007', 'article',
   'A bank doesn''t just hold your money in a vault untouched — it lends most of it out to other people and businesses (for things like mortgages or business loans), earning interest on those loans. The interest a bank pays you on your savings is essentially a share of what it earns from lending your money onward, which is also why a bank can afford to pay interest at all rather than just storing money for free.

This is also why savings accounts and current (everyday spending) accounts often differ: money in a savings account is generally expected to sit for longer, giving the bank a more predictable pool to lend from, so savings accounts often pay a higher interest rate than current accounts, where money moves in and out constantly and unpredictably. Banks also aren''t lending recklessly — they''re regulated and required to keep a portion of deposits accessible, so that everyday customers can withdraw their money when they need it, even though most of it is out on loan at any given time.

Worked example: a bank takes in £1,000 from savers across many accounts. It lends most of that out as part of a mortgage to someone buying a home, charging them, say, 5% interest on the loan. The bank then pays its savers a smaller rate, say 3%, on their deposits — the difference (roughly 2%) is how the bank covers its own costs and makes a profit, while savers still get a real, if smaller, return for letting the bank use their money.

Recap: banks pay savings interest because they lend deposited money onward and share a portion of what they earn from that lending. Savings accounts often pay more than current accounts because savings money is expected to sit longer, giving the bank a more predictable pool to lend against.',
   2),
  ('00000000-0000-0000-0002-000000900703', '00000000-0000-0000-0001-000000000007', 'article',
   'Inflation doesn''t affect everything by the same amount — some things (like housing or food) can rise in price faster than the general inflation rate, while others (like electronics) can even fall in price over time due to improving technology, despite general inflation being positive. This means the "average" inflation rate reported doesn''t necessarily match any one person''s actual experience, depending on what they tend to spend money on.

Inflation also compounds over multiple years, the same way interest does — a 3% inflation rate doesn''t just make things 3% more expensive once; it makes them roughly 3% more expensive than the already-higher price from the previous year, each year, so prices over a decade can rise substantially more than simply multiplying 3% by 10 years would suggest.

Worked example: an item costing £100 today, with inflation at 3% a year, doesn''t cost £130 after 10 years (10 × 3%) — it costs roughly £100 × (1.03)^10 ≈ £134.39, because each year''s price rise is calculated on the already-higher price from the year before, not on the original £100. Over 20 years at the same rate, it would be roughly £180.61 — nearly double the original price, from a rate that sounds small year to year.

Recap: inflation compounds the same way interest does, so a small annual rate adds up to a much larger total increase over many years than simply multiplying by the number of years. Inflation also doesn''t hit every category of spending equally, so the "average" reported rate is a useful guide but not a perfect match for any one person''s actual costs.',
   3);

-- digital-payments-and-online-safety
insert into lessons (id, skill_id, content_type, content_body, order_index) values
  ('00000000-0000-0000-0002-000000900802', '00000000-0000-0000-0001-000000000008', 'article',
   'Digital payments come with built-in protections that cash never had, and knowing what they actually cover matters as much as knowing the risks. Many debit and credit cards offer some level of fraud protection, meaning that if someone makes an unauthorised payment using your card details, the bank can often reverse it and refund the money, provided it''s reported promptly. This is fundamentally different from cash — if a £20 note is stolen or lost, there''s no company that can "undo" that and give it back.

This protection isn''t unconditional, though: it generally depends on reporting suspicious activity quickly, and it can be weakened or voided if someone was tricked into willingly authorising a payment themselves (like being scammed into approving a transfer), because from the bank''s system''s perspective, that looks like a normal, authorised transaction rather than theft. This is exactly why scams are often designed to get the victim to actively approve or send the payment themselves, rather than trying to steal card details directly — it sidesteps a lot of the fraud protection that would otherwise kick in.

Worked example: if someone steals Maya''s card and uses it without her knowledge, her bank''s fraud protection can likely reverse the charge once she reports it. But if Maya is instead tricked by a fake "prize" message into transferring £50 of her own money to a stranger''s account herself, believing it''s a genuine fee to release a bigger prize, that transfer was technically authorised by her — much harder, sometimes impossible, to reverse, even though it was still a scam.

Recap: digital payments often come with real fraud protection that cash doesn''t have, but that protection is strongest against unauthorised use of your details, and much weaker against being tricked into authorising a payment yourself — which is exactly the angle many scams are designed around.',
   2),
  ('00000000-0000-0000-0002-000000900803', '00000000-0000-0000-0001-000000000008', 'article',
   'Beyond payment scams, digital accounts also need basic hygiene to stay secure, and a lot of it comes down to habits that are simple but easy to skip. Two-factor authentication (often called 2FA) adds a second proof of identity beyond just a password — usually a code sent to your phone — so that even if someone gets hold of your password, they still can''t get in without also having your phone. It''s one of the single most effective protections available, and it''s usually free and optional to turn on.

Reusing the same password across multiple accounts is a common but risky habit: if one site or app suffers a data breach (which happens regularly, even to large companies) and your password leaks, anyone with that leaked password can try it on your other accounts too — email, banking apps, social media — turning one breach into many compromised accounts. Using a different password for important accounts limits a single breach to just that one account.

Worked example: Nia uses the same password for a gaming forum, her email, and her banking app. The gaming forum suffers a data breach and her password leaks online. Because she reused it, anyone with the leaked password can now also try logging into her email and banking app — and likely succeed. If she''d used a different password for her banking app specifically, the breach would have stayed contained to just the forum account.

Recap: turning on two-factor authentication and avoiding reusing the same password across important accounts are two of the simplest, most effective habits for digital account security — both limit how much damage a single leaked password or stolen device can actually cause.',
   3);

-- simple-investing-basics
insert into lessons (id, skill_id, content_type, content_body, order_index) values
  ('00000000-0000-0000-0002-000000900902', '00000000-0000-0000-0001-000000000009', 'article',
   'One of the most reliable ways to reduce investing risk without giving up potential growth is diversification — spreading money across many different investments rather than putting it all into one company or one type of asset. If one company does badly, or even fails completely, the impact on a diversified investor''s total money is small, because it was never all riding on that one company in the first place.

A common way ordinary investors diversify without needing to research hundreds of individual companies themselves is through a fund — a pooled investment that automatically buys small pieces of many different companies at once, so buying "one" fund can actually mean owning a tiny slice of hundreds of businesses. This spreads out the risk of any single company doing badly, though it doesn''t remove risk from the market as a whole — if the overall market falls, a diversified fund can still fall too, just not as sharply as being concentrated in one badly-performing company would.

Worked example: two investors each put £1,000 into shares. Investor A puts it all into one company, which unexpectedly loses 40% of its value in a bad year — a £400 loss. Investor B spreads the same £1,000 across a fund holding 200 different companies; even if a few of those companies also do badly that year, the overall fund might only fall 8% because the bad performers are a small fraction of the total — a £80 loss instead of £400, for a similarly rocky year in the market overall.

Recap: diversification — spreading money across many investments rather than one — reduces the damage any single company''s bad performance can do to your total money, without necessarily giving up the overall growth potential of investing. Funds are a common, accessible way for ordinary investors to diversify without researching hundreds of companies individually.',
   2),
  ('00000000-0000-0000-0002-000000900903', '00000000-0000-0000-0001-000000000009', 'article',
   'Investing returns aren''t just about picking good investments — costs and fees quietly eat into growth over time, and because of compounding, even a seemingly small annual fee can add up to a large amount over many years. A fund or investment platform typically charges an ongoing fee, often shown as a percentage of the amount invested per year, to cover the cost of managing the investment — and this fee is taken whether the investment goes up or down in value that year.

Because fees compound the same way growth does, a fee that looks tiny year to year (like 1% versus 0.5%) can make a meaningfully different difference over a long time period, since the "missing" 0.5% each year would otherwise have kept compounding on top of itself too. This doesn''t mean fees should always be avoided entirely — some active management might be worth paying for — but it means comparing the fee, not just the headline return, is part of comparing investment options properly.

Worked example: £1,000 invested for 30 years at an average 7% growth rate, with a 0.5% annual fee, effectively grows at roughly 6.5% net — reaching around £6,614. The same £1,000 with a 1.5% annual fee (a 1-point difference) effectively grows at roughly 5.5% net — reaching only around £4,984. That single extra percentage point of annual fee, compounded over 30 years, is the difference between roughly £6,614 and £4,984 — over £1,600 lost to fees alone on the same underlying 7% growth.

Recap: investment fees are taken every year regardless of performance, and because they compound the same way growth does, even a seemingly small difference in annual fee percentage can add up to a large difference in the final amount over a long time period — worth comparing carefully, not just the advertised growth rate.',
   3);

-- taxes-basics
insert into lessons (id, skill_id, content_type, content_body, order_index) values
  ('00000000-0000-0000-0002-000000901002', '00000000-0000-0000-0001-000000000010', 'article',
   'Not everyone pays the same rate of income tax on every pound they earn — most income tax systems, including the UK''s, are structured in bands, where different portions of income are taxed at different rates, and the rate generally rises as income rises. Crucially, a higher rate on a higher band doesn''t apply to your entire income retroactively — it only applies to the portion of income that falls within that higher band, not everything you earn.

This is a common point of confusion: some people worry that earning slightly more could "push them into a higher bracket" and leave them with less take-home pay overall, but that''s not how banded tax systems actually work — only the extra income within the new band is taxed at the higher rate, so earning more always results in more take-home pay overall, never less, even after tax.

Worked example (simplified, illustrative rates): imagine income up to £12,000 is tax-free, income from £12,001 to £50,000 is taxed at 20%, and income above £50,000 is taxed at 40%. Someone earning £51,000 does not pay 40% tax on the entire £51,000 — they pay 0% on the first £12,000, 20% on the next £38,000 (£12,001 to £50,000), and 40% only on the final £1,000 above £50,000. Their overall tax is a blend across the bands, not a single flat rate applied to everything.

Recap: income tax is typically banded, with different rates applying only to the portion of income within each band, not retroactively to all income once a higher band is reached. Earning more always increases take-home pay overall in a banded system — the common worry about being "worse off" from a pay rise pushing you into a higher band is a misunderstanding of how banding actually works.',
   2),
  ('00000000-0000-0000-0002-000000901003', '00000000-0000-0000-0001-000000000010', 'article',
   'Governments don''t just spend tax revenue on physical things like roads and buildings — a large share goes toward services that are easy to overlook precisely because you might not personally use them very often, like healthcare systems, unemployment support, and pensions for retired people. These work on a shared-contribution idea similar to insurance: people who are currently earning contribute, funding support for people who currently need it, with the expectation that the same system will support today''s contributors later when they need it themselves (in retirement, or if they''re ever unemployed or ill).

This is different from a direct, personal transaction — you don''t get back exactly what you personally paid in, and that''s the point: a healthy adult who rarely needs healthcare in a given year is still contributing to a system that will be there if they need it later, and is currently helping someone else who does need it now. Understanding tax this way — as a form of shared, long-term social insurance, not a fee for services used that specific year — explains why it''s structured as a required contribution rather than an optional purchase.

Worked example: a 22-year-old in good health pays income tax throughout the year and barely uses the healthcare system, which might make the tax feel like "wasted" money in the short term. But that same system is there without a large personal bill if they''re seriously ill or injured unexpectedly, and the same tax system funds a pension they''ll rely on decades later in retirement — the value isn''t in that specific year''s usage, it''s in being part of a system that supports everyone across their whole life, not just the years they happen to need it most.

Recap: a significant share of tax funds shared, long-term systems like healthcare, unemployment support, and pensions, which work on a contribute-now, benefit-when-needed basis rather than a direct pay-for-what-you-personally-use transaction. This is why tax isn''t wasted even in years someone barely uses public services — it''s what makes those services available to everyone, including that same person, whenever they do need them.',
   3);

-- entrepreneurship-basics
insert into lessons (id, skill_id, content_type, content_body, order_index) values
  ('00000000-0000-0000-0002-000000901102', '00000000-0000-0000-0001-000000000011', 'article',
   'Before spending any money starting a small venture, it''s worth estimating the break-even point — the number of sales needed just to cover all costs, where profit is exactly zero, neither a gain nor a loss. Below that number of sales, the venture is losing money; above it, every additional sale contributes profit. Knowing this number in advance turns "I hope this works out" into a concrete target that can be checked against reality as sales actually happen.

The break-even point can be calculated by dividing total fixed costs by the profit each individual sale contributes after its own variable cost is subtracted (the "contribution per unit"). This tells you exactly how many units need to sell before the fixed cost is fully covered and the venture starts making genuine profit on each additional sale.

Worked example: Zara''s lemonade stand has a £5 fixed cost, 50p variable cost per cup, sold at £1.50. Each cup contributes £1.50 − £0.50 = £1.00 toward covering the fixed cost, after its own variable cost is paid. Break-even = £5 fixed cost ÷ £1.00 contribution per cup = 5 cups. Below 5 cups sold, Zara is making a loss; at exactly 5 cups, she breaks even (£5 revenue-after-variable-costs exactly covers the £5 table rental); every cup beyond 5 is £1.00 of genuine profit.

Recap: the break-even point — fixed costs divided by the profit contributed per sale — tells you exactly how many sales are needed before a venture starts genuinely profiting, rather than just covering its costs. It turns a vague hope for success into a specific, checkable number.',
   2),
  ('00000000-0000-0000-0002-000000901103', '00000000-0000-0000-0001-000000000011', 'article',
   'Pricing a product isn''t just about covering costs — it also needs to account for what customers are actually willing to pay, and undercharging is one of the most common mistakes new small ventures make, often because the person setting the price forgets to properly value their own time and effort, not just the ingredients or materials.

A useful pricing approach starts with cost-plus pricing: calculate the true cost per item (including materials and, ideally, a reasonable value for the time spent), then add a margin on top as profit — rather than picking a price that merely "sounds fair" without checking it actually covers costs plus a real margin. It''s also worth checking what similar products or services actually sell for elsewhere, since pricing far below what customers would readily pay leaves money on the table for no real benefit.

Worked example: Marcus makes friendship bracelets to sell. Materials cost him 80p per bracelet, and each one takes him roughly 20 minutes to make. If he prices them at £1 each, thinking "that covers the materials easily," he''s ignoring his own time entirely — 20p profit for 20 minutes of work is a very low effective rate. If he instead prices at £3 each (materials £0.80 + a reasonable value for his time + a margin), he earns £2.20 per bracelet — a far more sustainable price, and one that similar handmade items at a school fair or market often actually sell for.

Recap: pricing needs to cover true costs, including a reasonable value for time spent, plus a margin — not just materials, and not just "whatever sounds fair." Checking what similar products actually sell for elsewhere helps confirm a price isn''t leaving money on the table.',
   3),
  ('00000000-0000-0000-0002-000000901104', '00000000-0000-0000-0001-000000000011', 'article',
   'Even a small venture involves risk beyond just "will people buy it" — things can go wrong that a beginner might not plan for, like unsold stock, an unreliable supply of materials, or simply misjudging demand. Thinking through what could go wrong before spending money, rather than only after a problem happens, is a habit that separates a venture that survives a setback from one that doesn''t.

One simple, low-risk way to test an idea before committing significant money is to start small — make or buy a small trial batch rather than a large one, sell it, and see what actually happens before scaling up. This limits how much money is at risk if the idea doesn''t work as expected, and gives real information (not a guess) about actual demand before a bigger commitment is made.

Worked example: Priya wants to sell handmade cards at a school fair. Rather than buying materials for 100 cards up front (a large financial commitment if they don''t sell), she makes a trial batch of 10, using them to check actual demand, pricing, and what people say about them. If all 10 sell quickly, she has real evidence to justify making more for next time. If only 2 sell, she''s only risked the cost of 10 cards'' worth of materials, not 100, and can adjust her approach — different pricing, different designs — before trying again.

Recap: starting with a small trial batch rather than a large upfront commitment limits financial risk while an idea is still unproven, and gives real evidence about actual demand rather than a guess — information that can then guide a bigger, more confident commitment later.',
   4);

-- credit-and-debt-basics
insert into lessons (id, skill_id, content_type, content_body, order_index) values
  ('00000000-0000-0000-0002-000000901202', '00000000-0000-0000-0001-000000000012', 'article',
   'A credit history isn''t a single number handed out once — it''s built up over time from a track record of how reliably someone borrows and repays, and lenders check it before agreeing to lend again, using it to judge how risky lending to that particular person is likely to be. Someone with a strong track record of on-time repayments looks like a safer bet to a lender than someone with a history of missed or late payments, even if both are asking to borrow the exact same amount today.

This matters practically because a stronger credit history doesn''t just affect whether a lender says yes or no — it also affects the terms offered, including the interest rate. Lenders often charge a higher interest rate to borrowers they consider riskier, to compensate for the higher chance of not being repaid in full — so a poor credit history can mean paying more for the exact same loan than someone with a stronger history would pay.

Worked example: two people each want to borrow £1,000. Person A has a strong credit history of always repaying on time and might be offered the loan at 8% annual interest. Person B has a history of several missed payments and might be offered the same £1,000 loan at 18% annual interest instead — a lender''s way of pricing in the higher perceived risk. Over a year, Person A pays roughly £80 in interest; Person B pays roughly £180 for borrowing the identical amount, purely because of their different credit histories.

Recap: a credit history is a track record built over time, and lenders use it to judge risk before agreeing to lend — a stronger history not only makes approval more likely, it typically results in better terms (a lower interest rate), meaning the exact same loan can cost noticeably more for someone with a weaker credit history.',
   2),
  ('00000000-0000-0000-0002-000000901203', '00000000-0000-0000-0001-000000000012', 'article',
   'Not all debt is the same kind of risk, and it helps to distinguish between debt taken on for something that can grow in value or ability to earn over time versus debt taken on for something that loses value the moment it''s bought or used. This distinction is sometimes framed as "good debt" versus "bad debt", though the labels are a simplification — the real point is understanding what the borrowed money is actually being used for, and whether it has a realistic chance of being worth more than its cost over time.

A loan for something like education or a reliable tool needed to earn money can, in the right circumstances, pay for itself many times over through increased future earning ability — the interest cost is weighed against a realistic expectation of future benefit. Debt taken on for something that loses value immediately and provides no future earning benefit — like financing a takeaway meal on a high-interest credit card — has none of that offsetting benefit; it''s pure cost with nothing built up in return.

Worked example: a £2,000 loan for training that leads to a job paying £3,000 more per year going forward is arguably a strong use of debt — assuming the training genuinely leads to that outcome, the extra income easily outweighs the loan''s interest cost within the first year alone. A £2,000 credit card balance built up on takeaway meals and entertainment, at high interest, provides no future income boost at all — just an ongoing cost with nothing to show for it once the meals are long finished.

Recap: debt is not uniformly "good" or "bad" — what matters is whether the money borrowed is realistically likely to grow in value or future earning ability enough to outweigh its interest cost, versus being spent on something that loses value immediately with no offsetting future benefit.',
   3);

-- insurance-basics
insert into lessons (id, skill_id, content_type, content_body, order_index) values
  ('00000000-0000-0000-0002-000000901302', '00000000-0000-0000-0001-000000000013', 'article',
   'Most insurance policies include an excess (sometimes called a deductible) — a set amount the policyholder pays toward a claim themselves before the insurer covers the rest. This isn''t a hidden trick; it exists to discourage tiny, trivial claims that would cost the insurer more to process than they''re actually worth, and to keep everyone''s overall premiums lower by filtering out the smallest claims from the shared pool.

There''s a real trade-off in how a policy''s excess and premium relate to each other: a policy with a higher excess (you pay more yourself before coverage kicks in) typically comes with a lower ongoing premium, because the insurer is taking on less risk of small, frequent claims. A policy with a lower excess typically costs more in premium, because the insurer is covering more of even small losses. Neither is automatically "better" — it depends on whether someone would rather pay a bit more regularly for more complete coverage, or pay less regularly and accept covering more of a loss themselves if it happens.

Worked example: Tom is choosing between two phone insurance policies. Policy A has a £50 excess and costs £4/month (£48/year). Policy B has a £150 excess and costs £2.50/month (£30/year). If Tom''s phone screen needs a £150 repair, Policy A costs him £50 (excess) + £48 (year''s premium) = £98 total; Policy B costs him £150 (excess, since it doesn''t exceed the excess... in this case the whole repair) + £30 (year''s premium) = £180 total for the same £150 repair — Policy A works out cheaper for this particular claim, but Policy B would have been cheaper in a year with no claim at all (just £30 versus £48).

Recap: the excess is the amount a policyholder pays themselves before insurance covers the rest, and it trades off against the premium — a higher excess usually means a lower premium, and vice versa. Which combination is better depends on how likely a claim is and how large it''s likely to be, not a fixed rule that one is always superior.',
   2),
  ('00000000-0000-0000-0002-000000901303', '00000000-0000-0000-0001-000000000013', 'article',
   'Not every kind of loss is realistically insurable, and understanding why helps clarify what insurance is actually for. Insurance works well for losses that are unpredictable for any one individual but statistically predictable across a large group — an insurer can''t know whose phone will break this year, but across thousands of policyholders, it can estimate roughly how many phones will break and price premiums accordingly. This is why insurance is typically offered for things like accidental damage, theft, illness, or accidents — genuinely uncertain events for any one person.

Insurance generally isn''t offered, or is offered only at a very high cost, for losses that are certain or near-certain to happen, or that are within a person''s own control to cause deliberately — because insuring a certain event isn''t really "insurance" in any meaningful sense, it''s just prepaying for the loss with an extra fee added on top, and insuring against deliberately-caused loss would remove any incentive to avoid causing it. This is also why insurers ask questions and set conditions when a policy is taken out — to judge how likely a genuine claim actually is for that specific person, and to exclude protection for outcomes someone caused on purpose.

Worked example: a phone that''s already visibly cracked when someone applies for insurance isn''t a genuinely uncertain future risk — the loss has already happened, so most insurers won''t cover pre-existing damage, only future accidental damage from that point onward. Similarly, deliberately smashing your own insured phone to claim a payout isn''t a real insurable risk at all — it''s fraud, both because it removes the genuine uncertainty insurance is built around and because it directly costs the shared pool that funds genuine, honest claims.

Recap: insurance works for losses that are genuinely uncertain for an individual but statistically predictable across a large group — not for losses that are already certain to happen, already happened, or deliberately caused, since none of those involve the real uncertainty that makes pooled-risk insurance work in the first place.',
   3);

-- comparison-shopping-and-consumer-skills
insert into lessons (id, skill_id, content_type, content_body, order_index) values
  ('00000000-0000-0000-0002-000000901402', '00000000-0000-0000-0001-000000000014', 'article',
   'Shops and retailers use well-understood psychological pricing and layout techniques that shape what feels like a good deal, independent of the actual value on offer — recognising these techniques is itself a consumer skill worth having. Charm pricing (ending a price in £.99 rather than a round number) makes a price feel meaningfully lower than it is, even though the actual difference is a single penny — £9.99 registers as "in the £9 range" to many shoppers'' quick mental judgment, even though it''s essentially £10.

Store layout is similarly deliberate: everyday essentials people specifically came in for (like milk or bread) are often placed at the back of a shop, meaning shoppers walk past many other tempting items to reach them; end-of-aisle displays and checkout-adjacent shelves are prime, high-visibility spots often reserved for higher-margin items or impulse purchases, not necessarily the best-value options in the shop. None of this is illegal or hidden — it''s simply designed to influence buying decisions, and recognising it is what allows a shopper to make a deliberate choice rather than an automatic one.

Worked example: a shopper walks in only intending to buy milk, but the milk is at the back of the store. Along the way, eye-level shelves and an end-of-aisle "special offer" display show snacks and drinks that weren''t on the original list. Recognising that this layout is deliberately designed to prompt exactly this kind of extra browsing — rather than assuming it''s coincidence — makes it easier to stick to the original list and treat any extra purchase as a deliberate choice, not an automatic one triggered by clever placement.

Recap: pricing tricks like charm pricing (£.99 endings) and deliberate store layout (placing essentials far from the entrance, prime spots for high-margin items) are designed to influence buying decisions, not to indicate genuine value. Recognising these techniques for what they are helps a shopper make deliberate choices rather than automatic ones.',
   2),
  ('00000000-0000-0000-0002-000000901403', '00000000-0000-0000-0001-000000000014', 'article',
   'Beyond comparing prices in the moment, understanding a shop or retailer''s return and refund policy before buying, especially for a more expensive item, is a practical consumer skill that avoids being stuck with a bad purchase. Policies vary a lot: some shops offer a generous return window with a full refund for any reason, others only accept returns for genuinely faulty items, and some final-sale items can''t be returned at all — assuming all shops work the same way can lead to an unpleasant surprise if a purchase doesn''t work out.

It''s also worth understanding the difference between a shop''s own goodwill return policy (which it sets voluntarily and can vary) and a legal right to a refund for something that''s genuinely faulty, not as described, or not fit for purpose — the second is a stronger, legally-backed protection that exists independent of whatever policy is printed on a receipt. Knowing which situation applies changes what a reasonable next step actually is if something goes wrong with a purchase.

Worked example: Elias buys a jacket that simply doesn''t suit him once he gets home — no fault with the item itself, he just changed his mind. Whether he can return it depends entirely on that specific shop''s own return policy (many, but not all, allow this within a set window). If instead the jacket had a broken zip straight out of the packaging, that''s a genuinely faulty item — Elias has a stronger, legally-backed right to a repair, replacement, or refund regardless of the shop''s own return-policy small print, because the item didn''t do what it was reasonably expected to do.

Recap: "changed my mind" returns depend entirely on a shop''s own voluntary policy, which varies significantly and should be checked before buying, especially for expensive items. A genuinely faulty, not-as-described, or not-fit-for-purpose item is a different, stronger situation with legal backing that exists regardless of the shop''s own printed policy.',
   3);

-- financial-goal-setting
insert into lessons (id, skill_id, content_type, content_body, order_index) values
  ('00000000-0000-0000-0002-000000901502', '00000000-0000-0000-0001-000000000015', 'article',
   'Not all financial goals sit on the same timescale, and treating a short-term goal and a long-term goal the same way tends to work badly for both. A short-term goal (something needed within roughly a year, like a specific gadget or a trip) is best matched with straightforward saving — money set aside regularly in an accessible account, since there''s little time for ups and downs to average out and the money needs to be reliably there when the date arrives. A long-term goal (years away, like a car in the distant future or eventually a home deposit) has more time to work with, which opens up different, though not risk-free, options like investing, since there''s more time to ride out short-term fluctuations in value before the money is actually needed.

Mismatching the timescale and the approach causes real problems in both directions: putting a short-term goal''s money into something that can lose value right before it''s needed risks not having the full amount when the date arrives; treating a long-term goal exactly like a short-term one (plain saving the whole way) misses out on growth that a longer timeframe could otherwise capture, since money just sitting in low-interest savings for many years grows far more slowly than it could.

Worked example: Amir has two goals — a £150 gaming console he wants in 3 months, and a longer-term ambition to have £1,000 saved by the time he''s an adult, 6 years away. For the console, he sets aside a fixed amount each week in a simple savings jar — reliable and available exactly when needed. For the 6-year goal, once he''s old enough and with appropriate guidance, a longer-term approach with more growth potential is a more reasonable fit for money that genuinely won''t be touched for years, since there''s enough time for it to recover from any short-term dips along the way.

Recap: a goal''s timescale should shape the approach used to reach it — short-term goals need reliable, accessible saving since there''s little time to recover from any dip in value, while long-term goals have more room to consider growth-focused approaches, since more time allows short-term ups and downs to average out.',
   2),
  ('00000000-0000-0000-0002-000000901503', '00000000-0000-0000-0001-000000000015', 'article',
   'When more than one financial goal is active at once — which is normal, not a sign of doing something wrong — a limited amount of money has to be split across them deliberately, rather than whichever goal happens to be most exciting that week absorbing all the available savings. A simple way to prioritise is ranking goals by genuine urgency and importance rather than by how appealing they feel in the moment, since the most fun-sounding goal isn''t always the one that actually matters most.

One useful principle: goals tied to safety or necessity (like an emergency cushion for unexpected costs) generally deserve priority over goals that are purely enjoyable extras, even if the extra feels more motivating to save for day to day. This doesn''t mean never saving for fun things — it means being deliberate about the order, so a true priority isn''t quietly starved of money because a more exciting goal kept absorbing the available savings first.

Worked example: Zainab has £20 a week available for goals and two active ones: a £200 emergency-style cushion in case her bike needs a sudden repair, and a £150 games console she''s excited about. If she splits evenly (£10 each), both goals progress but slowly — the cushion, arguably the more important of the two, takes 20 weeks to complete. If she instead prioritises the cushion at £15/week and the console at £5/week, the cushion is done in about 13-14 weeks, giving her real protection sooner, while the console goal still progresses, just more slowly, until the cushion is complete and its full £20 can shift toward the console.

Recap: splitting limited money across multiple active goals is normal, but it works best when done deliberately by genuine priority — often favouring safety or necessity goals over purely enjoyable ones — rather than letting whichever goal feels most exciting that week absorb the most money by default.',
   3);


-- ===================== College multi-lesson expansion =====================
-- finance-roles-overview
insert into lessons (id, skill_id, content_type, content_body, order_index) values
  ('00000000-0000-0000-0002-000000910102', '00000000-0000-0000-0001-000000000101', 'article',
   'Each finance role sits inside a different kind of institution, and that institution shapes the work as much as the job title does. Investment banks (advisory-focused) and sales & trading desks pay to advise on deals or trade markets on the firm''s own or clients'' behalf. Asset managers and hedge funds manage pooled investor money, aiming to grow it — the quant and portfolio-construction roles you''ll meet later in this tier live here. Commercial and retail banks focus on deposits and lending to individuals and businesses — this is where a lot of risk management and credit-risk work happens. Insurance companies price and pool risk over long time horizons, employing actuaries alongside more familiar finance roles. And fintech companies build the software and infrastructure — payments, trading platforms, lending apps — that all of the above now run on, blending finance knowledge with product and engineering skill.

Worked example: two graduates both take "finance jobs." One joins an investment bank''s M&A team — long hours, client-facing, building valuation models under deal deadlines. The other joins a fintech company''s risk team, writing code that flags suspicious transactions in real time — technical, product-adjacent, calmer hours, but still squarely "finance" in that it manages financial risk. Same broad label, very different daily experience, compensation structure, and skill set required.

Recap: the same role type (e.g. risk management) can look different depending on the institution it sits inside — a bank''s risk manager and a fintech''s risk engineer both manage risk but work very differently day to day. Understanding the institution type is as important as understanding the role title when evaluating a career path.',
   2),
  ('00000000-0000-0000-0002-000000910103', '00000000-0000-0000-0001-000000000101', 'article',
   'Breaking into a finance role usually starts with understanding what each path actually screens for before you invest years preparing for it. Investment banking recruiting leans heavily on technical interview prep (valuation, accounting mechanics) and networking, often starting with internships as early as first or second year of university. Quant roles screen hard on mathematics, statistics, and programming ability, often via timed problem sets or coding tests rather than behavioral interviews. Risk and operations roles tend to value attention to detail and process rigor, with a somewhat less intense recruiting cycle than banking. Fintech product roles blend a product-management interview process (case studies, past project walkthroughs) with enough finance literacy to be credible talking to finance-industry customers or colleagues.

Worked example: a student targeting investment banking spends a summer doing structured technical prep — practicing DCF and comps walkthroughs out loud — and reaching out to alumni for informational interviews, because banking recruiting rewards early, visible preparation. A student targeting a quant role instead spends that same summer on a personal coding project and competitive-programming practice, because quant interviews test applied math and code, not deal vocabulary. Preparing for the wrong screen — banking-style networking for a quant role, or pure coding practice for a banking role — wastes real effort.

Recap: each finance path has a genuinely different recruiting process built around what that role actually requires day to day. Matching your preparation to the specific path (not "finance" broadly) makes limited prep time far more effective.',
   3);

-- capital-markets-basics
insert into lessons (id, skill_id, content_type, content_body, order_index) values
  ('00000000-0000-0000-0002-000000910202', '00000000-0000-0000-0001-000000000102', 'article',
   'Capital markets split further by what''s being traded. Equity markets trade ownership stakes (stocks) — a shareholder owns a slice of the company and its future profits, with no promise of repayment. Debt markets trade loans (bonds) — a bondholder is owed a fixed schedule of interest payments plus the principal back at maturity, regardless of how profitable the company becomes. This difference in claim type drives a difference in risk and return: equity holders get whatever''s left after all debt is paid (upside is unlimited, but so is downside — a shareholder can lose everything), while bondholders have a fixed, contractual claim that''s paid before equity holders in a bankruptcy, so bonds are generally lower risk and lower expected return than stocks.

Worked example: a company raises $10 million by issuing bonds at 5% interest and $10 million by issuing shares. In a strong year, the bondholders still only receive their fixed 5% ($500,000) — no more, no matter how well the company does. Shareholders, after the company pays that $500,000 in interest, split whatever profit remains — if the company earns $3 million after interest, shareholders effectively get a much higher return on their $10 million than the bondholders did. In a bad year where the company barely breaks even, bondholders still get their contractual $500,000 first; shareholders might get nothing.

Recap: equity and debt represent fundamentally different claims on a company — equity is residual and uncapped (both up and down), debt is fixed and paid first. This is the seed of the capital-structure and cost-of-capital ideas this tier returns to later.',
   2),
  ('00000000-0000-0000-0002-000000910203', '00000000-0000-0000-0001-000000000102', 'article',
   'Beyond stocks and bonds, capital markets include derivatives — contracts whose value is derived from an underlying asset (a stock, a bond, a commodity, a currency) rather than being that asset itself. Two common types: options (the right, but not the obligation, to buy or sell an asset at a set price by a certain date) and futures (an obligation to buy or sell an asset at a set price on a set future date). Derivatives serve two very different purposes depending on who''s using them: hedging (reducing risk — e.g. an airline buying oil futures to lock in fuel costs and protect against a price spike) and speculation (taking on risk deliberately, betting on a price move to profit from it). The same instrument can be a hedge for one party and speculation for the counterparty on the other side of the trade.

Worked example: an airline expects to need 1 million gallons of jet fuel in six months and is worried prices might rise. It buys a futures contract locking in today''s price for that fuel, delivered in six months. If the market price rises by then, the airline is protected — it pays the locked-in (lower) price rather than the new, higher market price. If the market price falls instead, the airline has locked itself out of a cheaper price it could have gotten — the cost of certainty. The counterparty on the other side of that contract might be a speculator betting fuel prices will fall, happy to take on that price risk in exchange for a chance at profit.

Recap: derivatives derive their value from an underlying asset rather than being that asset, and the same contract can serve as a hedge (reducing risk) for one party and speculation (taking on risk) for another — the instrument itself is neutral; its purpose depends on who''s using it and why.',
   3);

-- company-valuation-basics
insert into lessons (id, skill_id, content_type, content_body, order_index) values
  ('00000000-0000-0000-0002-000000910302', '00000000-0000-0000-0001-000000000103', 'article',
   'A DCF''s value is only as good as two inputs most beginners underweight: the discount rate and the terminal value. The discount rate reflects the return investors require given the risk of the cash flows — a riskier company needs a higher discount rate, which shrinks the present value of its future cash flows more aggressively. Later in this tier, you''ll compute this rate properly as the weighted average cost of capital (WACC), but the core idea is simple: future cash flows must be discounted at a rate that reflects how risky they are to receive. The terminal value captures everything beyond the explicit forecast period (often 5-10 years) as a single lump figure, usually estimated by assuming cash flows grow at a stable rate forever after that point — and it''s frequently the majority of a DCF''s total value, which is why small changes to its assumptions swing the answer a lot.

Worked example: a company is projected to generate $1 million in free cash flow next year, growing steadily. Discounted at a 10% rate, that cash flow is worth $1,000,000 / 1.10 = $909,091 today. A cash flow of $1 million arriving in year 5 is worth only $1,000,000 / 1.10^5 = $620,921 today — the further out a cash flow is, the more the discount rate shrinks its present value. If the terminal value assumption changes from a 2% to a 3% perpetual growth rate, the total valuation can move by tens of percent, even though every other input stayed the same.

Recap: a DCF''s answer is highly sensitive to the discount rate (higher risk → higher rate → lower value) and the terminal value assumption (which often dominates the total) — understanding these two levers matters more than memorizing the formula itself.',
   2),
  ('00000000-0000-0000-0002-000000910303', '00000000-0000-0000-0001-000000000103', 'article',
   'Comps valuation depends entirely on picking the right peer group and the right ratio — get either wrong and the resulting valuation is misleading even though the math is simple. A peer group should be genuinely comparable: similar industry, similar size, similar growth profile, and similar geography where relevant, since valuation multiples differ systematically across these dimensions (a fast-growing tech company and a mature utility company trade at very different price-to-earnings ratios for good reason). Common ratios include price-to-earnings (P/E, share price divided by earnings per share), EV/EBITDA (enterprise value divided by earnings before interest, tax, depreciation, and amortization — useful because it''s less distorted by different capital structures or tax situations across companies), and price-to-sales (used for companies without positive earnings yet, common for early-stage growth companies).

Worked example: valuing a private company with $50 million in EBITDA using comps. Three genuinely comparable public companies trade at EV/EBITDA multiples of 8x, 9x, and 10x — an average of 9x. Applying that multiple: $50 million × 9 = $450 million estimated enterprise value. If an analyst instead (incorrectly) included a much larger, faster-growing peer trading at 15x in that average, the implied multiple and resulting valuation would be pulled up in a way that doesn''t reflect the actual company being valued.

Recap: comps is only as reliable as the peer group''s genuine comparability — the ratio math is simple, but selecting companies that are truly similar in industry, size, growth, and geography is where the real judgment (and the real risk of a misleading number) lives.',
   3);

-- financial-statement-modeling
insert into lessons (id, skill_id, content_type, content_body, order_index) values
  ('00000000-0000-0000-0002-000000910402', '00000000-0000-0000-0001-000000000104', 'article',
   'The mechanical link between the three statements runs through two specific connections that a model must get right. First, net income (the bottom line of the income statement) is the starting point of the cash flow statement, which then adjusts it for non-cash items (like depreciation, added back since it reduced net income but didn''t actually use cash) and changes in working capital, to arrive at actual cash generated. Second, the ending cash balance from the cash flow statement becomes the cash line on the balance sheet, and retained earnings on the balance sheet increases by that period''s net income (minus any dividends paid) — this is what makes the balance sheet actually balance after a period of activity.

Worked example: a company''s income statement shows $10 million net income, including $2 million of depreciation. The cash flow statement starts at $10 million net income, adds back the $2 million depreciation (non-cash), and after other adjustments shows $11 million of cash generated during the period. That $11 million flows onto the balance sheet as an increase to the cash balance, and the $10 million net income (assuming no dividends) increases retained earnings by $10 million — assets go up by $11 million (more cash) while liabilities plus equity go up by $10 million (more retained earnings) plus whatever else moved on the liabilities side to keep the balance sheet actually balanced.

Recap: net income bridges the income statement into the cash flow statement, and the cash flow statement''s ending cash plus the period''s retained-earnings change both flow onto the balance sheet — these two links are what make a three-statement model actually internally consistent rather than three separate, disconnected spreadsheets.',
   2),
  ('00000000-0000-0000-0002-000000910403', '00000000-0000-0000-0001-000000000104', 'article',
   'A properly built model has one built-in check that catches most structural errors immediately: the balance sheet must actually balance (assets = liabilities + equity) in every projected period, not just the historical ones. If it doesn''t, something in the linkage is broken — a common cause is forgetting to flow a balance sheet item''s change through the cash flow statement (e.g. an increase in accounts receivable ties up cash that should reduce the cash flow statement''s total, but a broken model might miss that adjustment), or a sign error (adding instead of subtracting a working-capital change). Professional models almost always include an explicit "balance check" row (assets minus liabilities minus equity, which should equal exactly zero) so an error shows up immediately rather than silently producing a wrong-but-plausible-looking output.

Worked example: a model projects accounts receivable increasing by $500,000 (customers owe the company more, meaning cash hasn''t come in yet even though revenue was recognized). If the cash flow statement correctly subtracts that $500,000 as a use of cash, the balance sheet balances. If an analyst forgets that adjustment, the cash flow statement overstates cash by $500,000, the balance sheet''s cash line is too high, and the balance check row shows a nonzero number — immediately flagging that something in the model''s linkage is wrong, well before anyone tries to use the model''s output for a real decision.

Recap: a working three-statement model balances in every period by construction, not by luck — an explicit balance-check row that must equal zero is the standard way professional modelers catch broken linkages before the model''s output is trusted for anything.',
   3);

-- financial-statement-analysis
insert into lessons (id, skill_id, content_type, content_body, order_index) values
  ('00000000-0000-0000-0002-000000910502', '00000000-0000-0000-0001-000000000105', 'article',
   'Return on equity (ROE) — net income divided by shareholders'' equity — is one of the most watched profitability ratios because it measures how efficiently a company turns shareholders'' own money into profit. But ROE can be misleadingly inflated by leverage alone, not genuine operational improvement, which is why it needs to be read alongside leverage ratios rather than on its own. The DuPont breakdown makes this explicit by splitting ROE into three components: net margin (net income / revenue, operational efficiency), asset turnover (revenue / total assets, how efficiently assets generate sales), and financial leverage (total assets / equity, how much debt financing is being used). Multiplying the three together reproduces ROE — and shows exactly which lever is driving it.

Worked example: Company X has net margin of 8%, asset turnover of 1.2x, and financial leverage of 2.0x. ROE = 8% × 1.2 × 2.0 = 19.2%. A competitor, Company Y, has a lower net margin of 6% and the same asset turnover of 1.2x, but much higher leverage of 3.5x. ROE = 6% × 1.2 × 3.5 = 25.2% — a higher ROE than Company X, but driven almost entirely by taking on more debt, not by being more operationally efficient. An analyst who only looked at the headline ROE number would (wrongly) conclude Company Y is the stronger business.

Recap: ROE alone doesn''t distinguish genuine operational strength from simply borrowing more to boost the ratio — the DuPont breakdown (margin × turnover × leverage) reveals which of the three is actually driving a company''s ROE, which matters a great deal for judging how sustainable that return really is.',
   2),
  ('00000000-0000-0000-0002-000000910503', '00000000-0000-0000-0001-000000000105', 'article',
   'Ratios are most useful compared against a benchmark — and the two standard benchmarks are trend analysis (the same company''s own ratios over time) and peer comparison (the same ratio across similar companies today). Trend analysis catches deterioration or improvement that a single-period snapshot would miss entirely — a current ratio of 1.5 looks fine in isolation, but if it was 2.5 two years ago and has been steadily declining, that trend is a warning sign a single number hides. Peer comparison catches whether a ratio is actually unusual for that specific industry — every industry has structurally different "normal" ranges (a supermarket''s current ratio is naturally lower than a heavy manufacturer''s, because it converts inventory to cash much faster), so comparing across industries produces false alarms in both directions.

Worked example: Company Z''s current ratio has moved 2.2 → 1.9 → 1.5 over three years — a clear declining trend, worth investigating even though 1.5 alone isn''t alarming. Comparing Company Z''s 1.5 to its direct industry peers, which average 1.4, shows it''s actually still in line with normal industry practice — so the real story is a declining-but-still-normal liquidity position, a more nuanced read than either the trend or the peer comparison alone would give.

Recap: trend analysis and peer comparison answer different questions — is this company''s own position changing, and is this company unusual relative to others like it — and a thorough ratio analysis uses both together rather than relying on either one alone.',
   3);

-- credit-risk-basics
insert into lessons (id, skill_id, content_type, content_body, order_index) values
  ('00000000-0000-0000-0002-000000910602', '00000000-0000-0000-0001-000000000106', 'article',
   'Credit rating agencies don''t just assign a letter grade in isolation — they build it from a structured analysis of both a borrower''s ability to pay (cash flow strength, leverage levels, earnings stability) and willingness to pay (payment history, management quality, legal/reputational incentives to avoid default). Ratings fall into two broad tiers with real consequences beyond the label: investment-grade (roughly BBB-/Baa3 and above), which many large institutional investors (pension funds, insurers) are restricted by their own rules to holding, and speculative-grade or "junk" (below that threshold), which carries meaningfully higher default risk and is priced with a correspondingly higher yield spread. Crossing from investment-grade to junk (a "fallen angel") can trigger forced selling by funds no longer permitted to hold it — a real market event, not just a symbolic downgrade.

Worked example: two companies both have a DSCR of 1.8, which looks similar on that one metric alone. Company A has stable, predictable cash flows (a regulated utility) and a long history of on-time payments — rated A. Company B has volatile cash flows (a commodity producer exposed to swinging prices) and a recent history of late payments — rated BB, well into junk territory, despite the similar DSCR. The rating captures more than the single ratio: stability and payment history both matter independently.

Recap: a credit rating synthesizes ability to pay (cash flow, leverage, stability) and willingness to pay (payment history, incentives) into a single grade, and the investment-grade/junk boundary has real market consequences — not just a label, but a threshold that changes who is even allowed to hold the debt.',
   2),
  ('00000000-0000-0000-0002-000000910603', '00000000-0000-0000-0001-000000000106', 'article',
   'When a borrower does default, recovery — how much of the original debt actually gets paid back — depends heavily on where a specific piece of debt sits in the repayment order, known as seniority. Senior secured debt is backed by specific collateral (assets pledged against the loan) and paid first in a bankruptcy, typically recovering the most. Senior unsecured debt is paid next, with a general claim on the company''s assets but no specific collateral behind it. Subordinated (junior) debt is paid only after senior claims are satisfied, and equity holders are paid last of all, often recovering nothing if the company''s remaining value doesn''t cover the debt ahead of them. This is why two bonds from the same company, at the same time, can carry very different credit ratings and yields — the debt itself, not just the company, has its own risk profile depending on its seniority.

Worked example: a company defaults with $100 million in remaining asset value to distribute. It owes $60 million in senior secured debt, $50 million in senior unsecured debt, and $30 million in subordinated debt. Senior secured is paid in full: $60 million (100% recovery). The remaining $40 million goes toward the $50 million senior unsecured claim: an 80% recovery. Nothing remains for subordinated debt: a 0% recovery. Equity holders also recover nothing.

Recap: recovery in a default depends on seniority — where a specific debt instrument sits in the repayment order — not just on the borrower''s overall creditworthiness. This is why lenders care not only about who they''re lending to, but exactly what kind of claim they''re holding.',
   3);

-- portfolio-construction-basics
insert into lessons (id, skill_id, content_type, content_body, order_index) values
  ('00000000-0000-0000-0002-000000910702', '00000000-0000-0000-0001-000000000107', 'article',
   'Modern portfolio theory formalizes the diversification intuition with the efficient frontier: the set of portfolios that offer the highest possible expected return for each level of risk (or equivalently, the lowest possible risk for each level of expected return). Any portfolio below the frontier is inefficient — a better combination exists that gives more return for the same risk, or the same return for less risk, simply by re-weighting the same assets. Where an individual investor should sit on the frontier isn''t a universal answer — it depends on that investor''s own risk tolerance: a more risk-tolerant investor picks a point further along the frontier (higher expected return, higher risk); a more risk-averse investor picks a point closer to the low-risk end.

Worked example: two portfolios both hold the same three assets (a stock index, a bond index, and cash) but in different proportions. Portfolio A (70/20/10) has an expected return of 8% with 14% volatility. Portfolio B (50/40/10) has an expected return of 6.5% with 9% volatility. Neither is objectively "better" — Portfolio A suits an investor who can tolerate more short-term swings for higher expected long-run return; Portfolio B suits an investor who values a smoother ride even at the cost of some expected return. Both could sit on the same efficient frontier at different points.

Recap: the efficient frontier describes the best possible risk/return trade-offs available from a set of assets, but there''s no single "best" portfolio on it — the right point depends on the individual investor''s own risk tolerance and time horizon, not on the math alone.',
   2),
  ('00000000-0000-0000-0002-000000910703', '00000000-0000-0000-0001-000000000107', 'article',
   'Rebalancing — periodically buying and selling holdings to bring a portfolio back to its original target weights — is a discipline that matters as much as the initial allocation decision, because a portfolio''s actual weights drift away from its target simply as different assets grow at different rates. Left alone, a portfolio that starts 60% stocks / 40% bonds can drift to 75% stocks / 25% bonds after a strong multi-year stock rally — a materially riskier mix than originally intended, even though no deliberate decision was made to take on more risk. Rebalancing back to target forces a disciplined form of "sell high, buy low": trimming the asset class that''s grown the most (now relatively expensive) and adding to the one that''s lagged (now relatively cheap), without needing to predict which will do better next.

Worked example: a $100,000 portfolio starts at 60% stocks ($60,000) / 40% bonds ($40,000). After a strong year, stocks grow to $80,000 while bonds stay at $40,000 — the portfolio is now worth $120,000, but the mix has drifted to 67% stocks / 33% bonds. Rebalancing back to 60/40 means selling $6,000 of stocks (bringing stocks to $72,000, exactly 60% of $120,000) and buying $6,000 of bonds (bringing bonds to $48,000, exactly 40%) — locking in some of the stock gains and restoring the original risk profile, rather than letting the portfolio drift further toward stock-heavy risk without a deliberate decision to take it on.

Recap: rebalancing counteracts natural portfolio drift caused by different assets growing at different rates, restoring the intended risk level and, as a side effect, systematically trimming winners and adding to laggards — a disciplined process rather than a market-timing bet.',
   3);

-- capital-structure-and-wacc
insert into lessons (id, skill_id, content_type, content_body, order_index) values
  ('00000000-0000-0000-0002-000000910802', '00000000-0000-0000-0001-000000000108', 'article',
   'Why does debt get an after-tax adjustment in WACC but equity doesn''t? Because interest payments on debt are tax-deductible — they reduce a company''s taxable income before tax is calculated, so the government effectively subsidizes part of the interest cost, known as the "tax shield." Dividends paid to equity holders, by contrast, come out of after-tax profit and get no such deduction. This asymmetry is exactly why the after-tax cost of debt formula multiplies the stated interest rate by (1 − tax rate) — it captures the real, after-tax cost the company bears, which is always lower than the stated rate as long as the tax rate is positive.

Worked example: a company pays 8% interest on its debt and faces a 30% corporate tax rate. Without the tax shield, the true cost would simply be 8%. But because interest is tax-deductible, the after-tax cost of debt = 8% × (1 − 0.30) = 5.6% — every dollar of interest paid effectively costs the company only $0.70 after accounting for the tax it no longer owes on that deducted amount. This is a genuine incentive toward using some debt financing rather than none, though it doesn''t remove the real risk of relying on too much of it (higher fixed obligations regardless of how the business performs).

Recap: the tax shield is the reason debt''s cost in WACC gets multiplied by (1 − tax rate) while equity''s doesn''t — interest is deductible, dividends aren''t, so debt''s true after-tax cost to the company is always below its stated interest rate.',
   2),
  ('00000000-0000-0000-0002-000000910803', '00000000-0000-0000-0001-000000000108', 'article',
   'WACC isn''t just an abstract formula — it''s the hurdle rate a company uses to decide whether a project or investment is worth pursuing, because it represents the minimum return needed to satisfy both debt and equity investors. A project is generally worth undertaking only if its expected return exceeds the company''s WACC; a project expected to return less than WACC destroys value even if it''s profitable in an absolute sense, because it doesn''t clear the return that capital providers require for the risk they''re taking. A company''s WACC also isn''t fixed forever — it changes as the company''s capital structure (debt/equity mix), borrowing costs, or perceived risk (beta) change, which is why WACC is recalculated periodically rather than treated as a permanent constant.

Worked example: a company with a WACC of 8% is evaluating two projects. Project A is expected to generate a 12% return — worth pursuing, since it clears the 8% hurdle and creates value above what capital providers require. Project B is expected to generate a 6% return — technically profitable in absolute terms, but below the 8% WACC, meaning it doesn''t earn enough to compensate debt and equity holders for the risk of the capital they''ve committed; pursuing it would actually destroy value relative to the alternative of not doing it (or finding a better use for that capital).

Recap: WACC functions as a company''s minimum acceptable return, or hurdle rate, for new investments — a project only creates value if its expected return exceeds WACC, and WACC itself shifts over time as a company''s financing mix and risk profile change.',
   3);

-- budgeting-on-a-student-income
insert into lessons (id, skill_id, content_type, content_body, order_index) values
  ('00000000-0000-0000-0002-000000910902', '00000000-0000-0000-0001-000000000109', 'article',
   'Beyond splitting fixed and variable costs, a student budget needs a system for actually tracking spending, since the split is only useful if real spending stays visible. Three common approaches: a simple spreadsheet or notes app (manual, full control, requires discipline to keep updated), a budgeting app that auto-categorizes bank transactions (less manual effort, but requires linking accounts and occasionally miscategorizes), and the envelope method (physically or virtually dividing cash into spending categories, stopping when an envelope is empty — a strong forcing function against overspending in a specific category, though less convenient for card-based spending). None is objectively best; the right choice depends on which one a specific person will actually keep up with consistently, since a technically superior system that gets abandoned after two weeks is worse than a simple one that''s actually used.

Worked example: a student tries a detailed spreadsheet tracking every transaction by category, but stops updating it after three weeks because it takes too long each night. Switching to an auto-categorizing app that pulls transactions automatically means far less manual effort, and the student actually keeps using it six months later — the "worse" system on paper (less granular control) became the better system in practice because it was sustainable.

Recap: a budget''s category split (needs/wants/savings) only works if actual spending is tracked consistently — the specific tracking method matters far less than choosing one sustainable enough to actually stick with long-term.',
   2),
  ('00000000-0000-0000-0002-000000910903', '00000000-0000-0000-0001-000000000109', 'article',
   'A student budget also needs to plan for true one-off shocks — costs that aren''t part of any regular monthly or termly pattern, like a laptop breaking or an unplanned medical bill — which is exactly what an emergency fund is for, distinct from the routine savings goal in the standard 50/30/20 split. Without one, an unplanned $300 expense on a $1,000-a-month budget typically gets absorbed by high-interest credit card debt, turning a one-time cost into an ongoing interest expense. A commonly cited starter target for a student (with fewer fixed obligations than someone supporting a household) is one to two months of essential fixed costs, built gradually rather than all at once — even a small emergency fund meaningfully reduces the odds of reaching for a credit card during a genuine shock.

Worked example: a student with $550/month in fixed costs targets a $600 emergency fund (a bit over one month''s fixed costs) and builds it by redirecting $50/month from the "savings" slice of their 50/30/20 split for 12 months. When a $250 laptop repair comes up unexpectedly, it''s paid straight from the emergency fund with zero interest cost — versus putting it on a credit card at 22% APR, which (per the credit-scores-and-credit-cards lesson) would add real ongoing interest cost on top of the repair itself if not paid off immediately.

Recap: an emergency fund is a separate line from routine savings goals, specifically sized to absorb genuine one-off shocks without resorting to high-interest debt — even a modest fund, built gradually, changes what an unplanned expense costs in practice.',
   3);

-- student-loans-and-interest
insert into lessons (id, skill_id, content_type, content_body, order_index) values
  ('00000000-0000-0000-0002-000000911002', '00000000-0000-0000-0001-000000000110', 'article',
   'Choosing between a standard and an income-driven repayment plan is a genuine trade-off, not a strictly better-or-worse choice — the right answer depends on career trajectory and whether loan forgiveness is realistically in play. A standard plan (commonly 10 years) fixes both the term and payment amount so the loan is paid off on schedule, generally minimizing total interest paid over the life of the loan for a borrower who can comfortably afford the fixed payment. Income-driven plans instead set the payment as a percentage of discretionary income, which helps in a low-income period but can mean the payment doesn''t even cover the interest accruing that month — causing the balance to grow (negative amortization) rather than shrink, which is a real cost for a borrower not pursuing forgiveness, but expected and acceptable for one who is (after a set number of qualifying payments, typically 20-25 years, any remaining balance under most forgiveness programs is forgiven, though the forgiven amount may itself be taxable depending on the program and year).

Worked example: a borrower with $40,000 in federal loans at 6% interest ($2,400/year in interest) takes a job paying enough that their income-driven payment is calculated at $1,800/year — below the $2,400 in interest accruing. The balance grows by $600 that year under negative amortization. If this borrower is on a public-service forgiveness track and expects the remaining balance forgiven after 10 years of qualifying payments, that growing balance is a planned, acceptable part of the strategy. If they''re not pursuing forgiveness and simply took the lower payment for cash-flow relief, that same growing balance is a real, avoidable cost they should reconsider.

Recap: income-driven repayment isn''t automatically worse than a standard plan — it''s a different tool suited to a genuinely different situation (low current income, forgiveness eligibility), and negative amortization under it is either a planned feature or an avoidable cost depending entirely on whether forgiveness is actually the borrower''s plan.',
   2),
  ('00000000-0000-0000-0002-000000911003', '00000000-0000-0000-0001-000000000110', 'article',
   'Refinancing a student loan — taking out a new private loan to pay off existing ones, ideally at a lower interest rate — can genuinely lower the total cost of debt, but it comes with a specific, often overlooked trade-off: refinancing federal loans into a private loan permanently forfeits federal protections (income-driven repayment eligibility, deferment/forbearance options, forgiveness program eligibility), even if the rate itself is lower. This makes refinancing federal debt a much bigger decision than simply comparing interest rates — it should generally only be considered by a borrower confident in stable future income who is certain they won''t need those federal protections or forgiveness eligibility later.

Worked example: a graduate with $30,000 in federal loans at 6% interest qualifies to refinance into a private loan at 4% based on strong income and credit. The lower rate alone would save real money over the loan''s life. But refinancing gives up eligibility for income-driven repayment and forgiveness programs entirely — if that graduate later takes a lower-paying public-service job intending to pursue forgiveness, that option is now permanently gone. A borrower confident their income will stay stable or grow, with no future interest in public-service forgiveness, is in a genuinely different position than one who wants to keep that flexibility available.

Recap: refinancing federal loans can lower the interest rate, but it''s a one-way decision that permanently forfeits federal borrower protections and forgiveness eligibility — worth it for some borrowers, a real risk for others, and never purely a rate comparison.',
   3);

-- credit-scores-and-credit-cards
insert into lessons (id, skill_id, content_type, content_body, order_index) values
  ('00000000-0000-0000-0002-000000911102', '00000000-0000-0000-0001-000000000111', 'article',
   'Credit utilization can be managed at two levels that get conflated: overall utilization (total balances across all cards divided by total available credit) and per-card utilization (balance on a single card divided by that card''s own limit). Both can matter to a score, which means simply having one maxed-out card can hurt a score even if overall utilization across all cards looks fine, since some scoring models specifically flag any single card running near its limit. This is also why requesting a credit limit increase on an existing card (without spending more) can improve a score — it lowers utilization on that card by increasing the denominator, not by paying down any balance.

Worked example: someone has two cards — Card A with a $500 limit and a $450 balance (90% utilization on that card), and Card B with a $5,000 limit and a $0 balance. Overall utilization across both cards is $450 / $5,500 = about 8%, which looks healthy in aggregate. But Card A''s 90% per-card utilization can still drag down the score, because scoring models look at both the aggregate and the worst individual card. Requesting a limit increase on Card A to $2,000 (with the same $450 balance) drops its per-card utilization to about 22.5% without paying anything down.

Recap: credit utilization is evaluated both in aggregate and per card — a single near-maxed card can hurt a score even when overall utilization looks fine, which is why spreading balances or requesting limit increases on individual cards is a real (if secondary) lever, separate from simply paying balances down.',
   2),
  ('00000000-0000-0000-0002-000000911103', '00000000-0000-0000-0001-000000000111', 'article',
   'Length of credit history rewards accounts that have simply existed for a long time, which creates a specific, easy-to-make mistake: closing an old, unused credit card. Closing a card removes its available credit (raising overall utilization if any balance exists elsewhere) and, once it drops off a credit report after a period of years, can shorten the average age of accounts — both of which can lower a score, even though closing an unused card feels like a harmless cleanup decision. This is why the common advice for an old card with no annual fee is to keep it open and either use it occasionally (a small recurring charge, paid off immediately) or simply let it sit unused, rather than closing it.

Worked example: someone has three cards — one opened 8 years ago, one opened 3 years ago, one opened 1 year ago — giving an average account age of 4 years. Closing the 8-year-old card (even with a $0 balance) not only removes that card''s available credit (raising overall utilization if any balance exists on the remaining cards) but, once it eventually drops off the report, would lower the average account age to 2 years across the remaining two cards — a real, measurable hit to a factor that can only be rebuilt by waiting, not by any immediate action.

Recap: length of credit history rewards patience, not activity — closing an old, unused card (especially one with no annual fee) is a common, well-intentioned mistake that can lower a score by removing available credit and eventually shortening average account age, both of which are difficult to fix quickly.',
   3);

-- investing-basics
insert into lessons (id, skill_id, content_type, content_body, order_index) values
  ('00000000-0000-0000-0002-000000911202', '00000000-0000-0000-0001-000000000112', 'article',
   'Index funds and actively managed funds represent two competing philosophies for how to actually own stocks and bonds without picking individual securities yourself. An index fund simply holds all (or a representative sample of) the securities in a market index (like a broad stock market index), aiming to match that index''s return, with low fees since there''s no active decision-making involved. An actively managed fund employs a manager who picks specific securities, aiming to beat the index''s return, but charges meaningfully higher fees to pay for that research and decision-making. The evidence here is fairly consistent: over long time horizons, the majority of actively managed funds fail to beat their comparable index after fees are accounted for — not because active managers lack skill, but because their higher fees are a real, guaranteed cost that has to be overcome by genuine outperformance just to break even with a low-cost index fund.

Worked example: over 20 years, an index fund charging 0.05% in annual fees returns an average 7% per year before fees, or effectively 6.95% after fees. An actively managed fund charging 1% in annual fees needs to actually generate an 8% return before fees just to match the index fund''s 6.95% after-fee result — a full percentage point of genuine outperformance that has to happen consistently, year after year, just to tie. Historically, most active funds don''t clear that bar consistently over long periods.

Recap: index funds and active funds represent a real trade-off between low guaranteed cost and the possibility (but not likelihood, historically, over long periods) of beating the market — the fee difference is a certain, compounding cost that active management has to overcome just to match, not beat, a low-cost index fund.',
   2),
  ('00000000-0000-0000-0002-000000911203', '00000000-0000-0000-0001-000000000112', 'article',
   'Dollar-cost averaging — investing a fixed amount at regular intervals (e.g. monthly) regardless of the market''s price at that moment — is a common strategy for managing the emotional and timing difficulty of investing a lump sum all at once. Because it buys more shares when prices are low and fewer shares when prices are high, it averages the purchase price over time and removes the pressure of trying to identify the single best moment to invest, which is extremely difficult to do reliably even for professionals. It''s a behavioral tool as much as a mathematical one: many investors who try to time a lump-sum investment end up waiting indefinitely for a ''better'' entry point that may never clearly arrive, and end up not investing at all.

Worked example: an investor commits $100/month to an index fund over four months as the share price moves $20, $25, $20, $15. They buy 5 shares, 4 shares, 5 shares, and 6.67 shares respectively — 20.67 shares total for $400 invested, an average cost of about $19.35/share, lower than the simple average of the four prices ($20) because more shares were bought when the price dipped to $15. A lump-sum investor who happened to invest all $400 on the $25 day would have bought only 16 shares for the same money.

Recap: dollar-cost averaging trades the (unrealistic) goal of perfectly timing the market for a disciplined, automatic process that naturally buys more when prices are low — its main value is behavioral (removing the paralysis of trying to pick the best moment) as much as mathematical.',
   3);

-- taxes-for-a-first-job
insert into lessons (id, skill_id, content_type, content_body, order_index) values
  ('00000000-0000-0000-0002-000000911302', '00000000-0000-0000-0001-000000000113', 'article',
   'Income tax in most systems with a first job (like the US federal system) is progressive and marginal — meaning different portions of income are taxed at different rates, and only the income within each bracket is taxed at that bracket''s rate, not the entire income at the top rate reached. This distinction matters because a common misconception is that earning enough to reach a higher tax bracket means all income gets taxed at that higher rate, which would create a strange disincentive to earn more — in reality, moving into a higher bracket only raises the rate on the additional income earned within that bracket, while all the income below it continues to be taxed at the lower rates that applied to those earlier brackets.

Worked example: in a simplified system with a 10% rate on the first $10,000 and a 20% rate on income from $10,000-$40,000, someone earning $30,000 does not pay 20% on the full $30,000. They pay 10% on the first $10,000 ($1,000) plus 20% on the remaining $20,000 ($4,000), for a total tax of $5,000 — an effective rate of about 16.7%, meaningfully below the 20% marginal rate that applies only to the last dollars earned. Someone worried that a $1,000 raise pushing them into a new bracket would somehow reduce their overall take-home pay is working from the misconception above; in reality, that raise is only taxed at the new, higher rate on the portion within the new bracket.

Recap: a marginal tax system taxes each portion of income at its own bracket''s rate, not the entire income at the highest bracket reached — this means earning more (even enough to enter a new bracket) never reduces take-home pay, a common misconception worth correcting explicitly.',
   2),
  ('00000000-0000-0000-0002-000000911303', '00000000-0000-0000-0001-000000000113', 'article',
   'Beyond income tax, a first paycheck typically includes other withholdings that are easy to overlook when comparing a job offer''s headline salary. Payroll taxes (like FICA in the US, funding Social Security and Medicare) are withheld regardless of income tax bracket and fund specific government programs rather than general revenue. Pre-tax benefit deductions (health insurance premiums, retirement contributions like a 401(k)) are subtracted from gross pay before income tax is calculated, which actually lowers taxable income — a real, if easy to overlook, tax benefit of participating in these benefits, distinct from their direct value. Understanding a full pay stub, not just the headline salary, is necessary to actually predict what a job will pay out month to month.

Worked example: a job offers a $50,000 salary. Payroll tax (FICA-equivalent, roughly 7.65% in the US) takes about $3,825. If the employee also contributes 5% ($2,500) to a pre-tax retirement account, taxable income for income-tax purposes drops to $47,500 before income tax is even calculated — lowering the income tax bill compared to not contributing, on top of the retirement savings itself. The headline $50,000 salary and the actual net pay landing in the bank account each month can differ by many thousands of dollars once all of this is accounted for.

Recap: a pay stub includes more than income tax withholding — payroll taxes and pre-tax benefit deductions both shape actual take-home pay, and pre-tax contributions carry a real (if secondary) tax benefit by lowering taxable income before income tax is calculated.',
   3);

-- retirement-accounts-basics
insert into lessons (id, skill_id, content_type, content_body, order_index) values
  ('00000000-0000-0000-0002-000000911402', '00000000-0000-0000-0001-000000000114', 'article',
   'The power of starting retirement contributions early comes down to compounding over a genuinely long time horizon — a gap in start date that seems small in the moment produces a large gap in final balance, because each year of missed contributions is also missing every year of growth that contribution would have earned afterward. This is why the specific advice to "start now, even with a small amount" is grounded in real math, not just general prudence — money contributed in your 20s has decades longer to compound than the same dollar amount contributed in your 40s, even if the later contribution is larger.

Worked example: someone contributes $200/month starting at age 25 and stops at age 35 (10 years, $24,000 total contributed), then never contributes again, letting the balance grow untouched until age 65 at an assumed 7% annual return. A second person waits until 35 to start, contributing $200/month every year from 35 to 65 (30 years, $72,000 total contributed — three times as much). Despite contributing three times less, the early starter''s balance at 65 is typically larger than the late starter''s, because the early contributions had 30-40 years to compound versus the late contributor''s shorter windows on each dollar. The exact numbers depend on the assumed return, but the direction of this result holds broadly: time in the market, not amount contributed, is often the dominant factor.

Recap: starting retirement contributions early lets each dollar compound over a longer horizon, which can outweigh contributing a much larger total amount later — this is the single strongest argument for starting small and early rather than waiting for a "better" time to start seriously.',
   2),
  ('00000000-0000-0000-0002-000000911403', '00000000-0000-0000-0001-000000000114', 'article',
   'Retirement accounts also come with rules around early withdrawal that materially change how they should be used — they''re not simply savings accounts with a tax benefit attached. Withdrawing from a traditional 401(k) or IRA before age 59½ typically triggers both ordinary income tax on the amount withdrawn and an additional early-withdrawal penalty (commonly 10% in the US), on top of losing all the future compounding that money would have earned if left invested. This structure exists specifically to discourage using retirement accounts for near-term goals, which is why financial advice consistently separates retirement savings (locked away, tax-advantaged, for decades away) from an emergency fund or shorter-term savings goal (accessible, no penalty, for near-term needs) — using retirement funds as a substitute emergency fund is one of the more expensive mistakes an early-career saver can make.

Worked example: someone withdraws $10,000 early from a traditional 401(k) to cover an unexpected expense. At a 22% income tax rate plus a 10% early-withdrawal penalty, they lose $3,200 immediately (32% combined), leaving only $6,800 actually available — and permanently forfeit whatever that $10,000 would have compounded to by retirement, decades away. The same $10,000 held in a separate, accessible emergency fund would have been available in full, with no tax or penalty, for exactly this situation.

Recap: retirement accounts trade accessibility for tax advantages — early withdrawal typically triggers both tax and a penalty, which is why a separate emergency fund (not the retirement account) should be the first line of defense for unplanned expenses.',
   3);

-- insurance-fundamentals-for-young-adults
insert into lessons (id, skill_id, content_type, content_body, order_index) values
  ('00000000-0000-0000-0002-000000911502', '00000000-0000-0000-0001-000000000115', 'article',
   'Choosing between a lower-premium/higher-deductible plan and a higher-premium/lower-deductible plan is a genuine trade-off best resolved by estimating your own realistic likelihood of needing care, not by a blanket rule. A lower-premium plan minimizes guaranteed monthly cost but exposes you to a larger out-of-pocket cost if something does happen — a reasonable bet for someone young, healthy, and rarely using medical care. A higher-premium plan costs more every month regardless of usage, but caps the downside much lower if a real medical need arises — a more conservative choice, or a necessary one for someone with a known ongoing condition requiring regular care.

Worked example: Plan A costs $50/month premium with a $3,000 deductible; Plan B costs $150/month premium with a $500 deductible. Over a year with no medical claims, Plan A costs $600 total (all premium); Plan B costs $1,800 total — Plan A wins decisively for a healthy year. But if a $2,000 medical bill arises, Plan A costs $600 (premium) + $2,000 (below its $3,000 deductible, paid in full out of pocket) = $2,600; Plan B costs $1,800 (premium) + $500 (deductible met, insurer covers the rest) = $2,300 — Plan B wins once a real claim happens. The right choice depends on realistically estimating how likely that claim scenario is for you specifically.

Recap: comparing premium against deductible requires estimating your own realistic odds of needing care, not applying a universal rule — a healthy, rarely-sick person often does better with the lower-premium plan; someone expecting regular care often does better with the higher-premium, lower-deductible plan.',
   2),
  ('00000000-0000-0000-0002-000000911503', '00000000-0000-0000-0001-000000000115', 'article',
   'Auto insurance and disability insurance are two coverage types easy for a young adult to underweight — one because it''s legally mandatory and treated as a checkbox, the other because it''s simply overlooked. Auto insurance typically includes several distinct components beyond the legally required minimum: liability coverage (pays for damage/injury you cause to others, usually the legal minimum), collision coverage (pays for damage to your own car regardless of fault), and comprehensive coverage (covers non-collision events like theft or weather damage) — carrying only the legal minimum liability coverage can leave a driver personally exposed to costs well beyond what a minimum policy pays out if they cause a serious accident. Disability insurance replaces a portion of income if illness or injury prevents working, and is often skipped by young, healthy people who underestimate the real odds of a working-age disabling event — but the financial impact of losing income for months or years, with no offsetting insurance, is often larger than the financial impact of the health event itself.

Worked example: a driver carries only the legal minimum liability coverage ($25,000 in a hypothetical state) and causes an accident resulting in $60,000 of damage and injury to another driver. The insurer pays out the $25,000 limit; the driver is personally liable for the remaining $35,000 — a real, potentially life-altering financial exposure that slightly higher liability limits (often available for a modest premium increase) would have covered. Separately, a 28-year-old with no disability insurance who suffers an injury preventing work for 8 months loses 8 months of income entirely, with no offsetting benefit — a basic disability policy replacing even 60% of income would have substantially cushioned that gap.

Recap: minimum-required auto liability coverage is often not enough real protection, and disability insurance is frequently skipped despite meaningful real odds of needing it — both are worth deliberately evaluating rather than defaulting to "the legal minimum" or skipping entirely.',
   3);

-- negotiating-salary
insert into lessons (id, skill_id, content_type, content_body, order_index) values
  ('00000000-0000-0000-0002-000000911602', '00000000-0000-0000-0001-000000000116', 'article',
   'Anchoring — the psychological tendency for the first number mentioned in a negotiation to disproportionately influence the final outcome — is why the strongest negotiating position is to let the employer name a number first whenever possible, and why premature self-disclosure of a target salary (or worse, a current or expected salary lower than market) can quietly cap the eventual outcome even before real negotiation begins. When directly asked for a number early in a process, redirecting toward the employer''s budgeted range ("what range is budgeted for this role?") or citing researched market data rather than a specific personal figure avoids anchoring yourself too low, without being evasive or difficult to work with.

Worked example: two equally qualified candidates apply for the same role with a $70,000-$85,000 budgeted range. Candidate A, asked early about salary expectations, states "around $65,000" (below the actual range, perhaps out of caution) — the employer, having no obligation to correct this, may simply offer $65,000-$68,000, anchored to the candidate''s own low number. Candidate B, asked the same question, responds "I''d rather understand the budgeted range for this role first" — learning the $70,000-$85,000 range, and later negotiating from a $78,000 opening offer up toward $82,000. Both candidates are equally qualified; the anchoring difference alone likely accounts for a meaningful gap in final outcome.

Recap: anchoring means the first number mentioned disproportionately shapes the final outcome — deflecting an early request for a specific number toward the employer''s own range (rather than naming your own number first) protects against anchoring yourself below what the role was actually budgeted for.',
   2),
  ('00000000-0000-0000-0002-000000911603', '00000000-0000-0000-0001-000000000116', 'article',
   'Negotiation doesn''t end with the initial counter — most real negotiations involve at least one round of back-and-forth, and understanding the employer''s likely constraints helps frame a productive second ask rather than simply repeating the first one louder. Base salary is often the most constrained lever for an employer, since it''s frequently governed by internal pay bands or equity-across-the-team policies that a single hiring manager can''t easily override — while signing bonuses, start date flexibility, extra vacation days, or a defined early performance-review date (e.g. a formal 6-month review with a raise tied to it) are often easier for an employer to move on, since they don''t permanently reset a pay band. Recognizing which lever is actually flexible for a specific employer, rather than pushing repeatedly on the most rigid one, often produces a better overall outcome than fixating on base salary alone.

Worked example: a candidate''s initial ask for $80,000 base (against a $75,000 offer) is met with "we can''t move on base salary, it''s fixed by our pay bands this year." Rather than repeating the same ask, the candidate pivots: "I understand — would a $5,000 signing bonus and a formal 6-month compensation review be possible instead?" The employer agrees, since neither commits to a permanently higher pay band. The candidate ends up with meaningfully better total first-year compensation than the original base-salary-only ask might have achieved, by working with the employer''s actual constraint rather than against it.

Recap: when a specific lever (often base salary) is genuinely constrained, pivoting to a different lever (signing bonus, start date, an early review) that doesn''t share the same constraint is often more productive than repeating the same ask — understanding what''s actually flexible for a specific employer shapes a better second-round negotiation.',
   3);

-- side-income-and-freelancing-finance
insert into lessons (id, skill_id, content_type, content_body, order_index) values
  ('00000000-0000-0000-0002-000000911702', '00000000-0000-0000-0001-000000000117', 'article',
   'Setting freelance rates isn''t as simple as matching a comparable employee''s hourly-equivalent pay, because a freelancer''s rate has to cover costs an employee''s salary doesn''t have to — self-employment tax (covering both the employee and employer share), no employer-subsidized benefits (health insurance, retirement matching), unpaid time between projects, and the administrative overhead of running a small business (invoicing, finding clients, bookkeeping). A commonly cited rule of thumb is that a sustainable freelance rate needs to be meaningfully higher — often 1.5x to 2x — than an equivalent employee''s hourly-equivalent pay, specifically to cover these extra costs, not because freelancers are simply charging more for the same work.

Worked example: an equivalent full-time employee role pays $30/hour ($62,400/year at 2,080 hours). A freelancer doing similar work, charging that same $30/hour, would earn less in practice once self-employment tax (an extra ~7.65% beyond what an employee''s share alone would be), no employer benefits, and unpaid non-billable time (client-finding, invoicing, gaps between projects — often 20-30% of total working time) are accounted for. Setting a rate of $50-55/hour instead — roughly 1.7-1.8x the employee-equivalent rate — is closer to what''s actually needed to match the employee''s real take-home value once these extra freelance-specific costs are covered.

Recap: a freelance rate needs to cover more than an equivalent hourly wage — self-employment tax, lost benefits, and unpaid non-billable time all need to be built into the rate, which is why sustainable freelance rates are typically well above a directly comparable employee''s hourly pay, not simply matched to it.',
   2),
  ('00000000-0000-0000-0002-000000911703', '00000000-0000-0000-0001-000000000117', 'article',
   'As side income grows from occasional to substantial, the legal and financial structure around it starts to matter in ways it didn''t at a small scale — specifically, whether to remain an unstructured sole proprietor (the default with no extra paperwork) or to form a formal business entity like an LLC (limited liability company). A sole proprietor has no legal separation between personal and business assets — if the freelance work is ever sued (e.g. a dissatisfied client claims damages from bad work) or incurs a large business debt, personal assets (savings, a car, in some cases a home) can potentially be at risk. An LLC creates a legal separation, so a business liability generally stays a business liability rather than automatically becoming personal financial exposure — at the cost of some formation paperwork, an annual fee in most jurisdictions, and the ongoing discipline of actually keeping business and personal finances cleanly separated (commingling funds can undermine the legal protection an LLC is meant to provide).

Worked example: a freelance graphic designer earning $2,000/year as a side project faces low realistic liability exposure — an LLC''s setup cost and ongoing fees likely aren''t justified yet relative to the risk. The same designer three years later, earning $60,000/year with corporate clients and larger contracts, faces meaningfully higher realistic exposure if a project goes wrong — at that scale, the cost of forming and maintaining an LLC is a small, reasonable price for the liability protection it provides, and many freelancers make this transition specifically once income and client risk both cross a meaningful threshold.

Recap: the right business structure isn''t fixed — it''s worth revisiting as freelance income and liability exposure grow, since the LLC''s protection becomes proportionally more valuable (relative to its cost) as the stakes of a lawsuit or business debt get larger.',
   3);

-- financial-planning-for-post-grad-life
insert into lessons (id, skill_id, content_type, content_body, order_index) values
  ('00000000-0000-0000-0002-000000911802', '00000000-0000-0000-0001-000000000118', 'article',
   'The priority order in the existing lesson isn''t arbitrary — each step is ranked by comparing its effective "return," which makes the ordering a genuinely calculable decision rather than a rule of thumb to follow blindly. A starter emergency fund comes first because it prevents a single unplanned expense from forcing new debt, which would undo any progress made on other goals. The 401(k) match comes next because it''s an immediate, guaranteed 100% (or whatever the match rate is) return — no investment reliably matches that. High-interest credit card debt (often 20%+ APR) comes ahead of most further investing because paying it off is equivalent to earning a guaranteed 20%+ return, which is higher than the realistic expected return of nearly any other use of that same money.

Worked example: someone with $5,000 in credit card debt at 22% APR and access to a 100%-match 401(k) (matching up to 3% of salary) has $300/month of discretionary money to allocate. Comparing options: paying $300/month extra toward the credit card saves roughly 22% annualized on that debt — a guaranteed, very high return. Investing that same $300/month in a taxable brokerage account might realistically earn 7-8% annualized, with real risk of loss in any given year. The credit card payoff wins clearly on pure math, which is exactly why it''s prioritized above general investing (though not above capturing the 401(k) match itself, since 100% instantly beats 22%).

Recap: the priority order for allocating money isn''t a rule of thumb — it''s ranked by comparing each option''s effective guaranteed return, from the 401(k) match''s immediate 100%+ down through high-interest debt payoff''s guaranteed 20%+ down to general investing''s realistic but uncertain 7-8%.',
   2),
  ('00000000-0000-0000-0002-000000911803', '00000000-0000-0000-0001-000000000118', 'article',
   'Post-grad life also introduces a category of decisions with no clean formula: major life-cost choices (where to live, whether to have a car, how much rent to commit to) that interact with every other financial goal simultaneously, because housing and transportation are typically the two largest recurring costs in a post-grad budget. A common guideline caps rent at roughly 30% of gross income, though this varies significantly by city and is increasingly difficult to hit in high-cost metro areas — the real point isn''t the specific percentage, but recognizing that a housing decision made at the very start of a career sets a fixed cost that constrains every other financial goal (debt payoff pace, savings rate, investing capacity) for as long as that lease or living situation continues.

Worked example: two graduates with identical $50,000 salaries make different housing choices. One signs a lease at $1,800/month (well above the 30% guideline of about $1,250), leaving comparatively little discretionary income for debt payoff, emergency fund building, or investing. The other chooses a $1,100/month apartment (below the 30% guideline) or a roommate situation, freeing up several hundred extra dollars a month that can be redirected toward the priority order covered in the previous lesson — same salary, meaningfully different financial trajectory, driven almost entirely by one early housing decision.

Recap: housing and transportation are usually the largest controllable costs in a post-grad budget, and the choices made early (before other financial habits are locked in) set a fixed constraint on everything else — worth deliberately evaluating against a guideline like the 30%-of-income rent cap, rather than defaulting to whatever feels comfortable at the time.',
   3);


-- ===================== Job-Ready multi-lesson expansion =====================
-- interview-fundamentals
insert into lessons (id, skill_id, content_type, content_body, order_index) values
  ('00000000-0000-0000-0002-000000920102', '00000000-0000-0000-0001-000000000201', 'article',
   'Before you can answer well, you need to recognize what an interviewer is actually listening for beneath the surface of a question. A behavioral question is checking whether you have real, specific experience — the story itself is the evidence. A technical question is checking whether your underlying knowledge is correct and fluent under pressure — precision matters more than personality. A fit question ("why this company/role?") is checking whether your interest is genuine and researched, not generic enough to paste into any application.

One practical habit is keeping a running mental (or written) list of 4-6 real experiences flexible enough to answer several different behavioral prompts — a single strong project story can usually be reshaped to answer "tell me about a challenge," "tell me about teamwork," and "tell me about a time you took initiative," depending on which part of the story you foreground.

Worked example: the same group-project story can answer "describe a challenge" by foregrounding the disagreement and how it was resolved, or "describe teamwork" by foregrounding how tasks were divided and combined. Practicing telling one story from two different angles is far more efficient prep than memorizing a separate story for every possible question.

Recap: interviewers ask different question types to test different things — story quality for behavioral, correctness for technical, genuine research for fit. A small set of flexible, real stories, told from different angles depending on the question, prepares you more efficiently than trying to have a unique story for every possible prompt.',
   2),
  ('00000000-0000-0000-0002-000000920103', '00000000-0000-0000-0001-000000000201', 'article',
   'Interview nerves often come less from not knowing an answer and more from not having a plan for how to structure it live. A simple three-part opening habit reduces this: briefly restate or acknowledge the question, give yourself two seconds to pick your example or approach, then answer in the structure that question type rewards. This tiny pause is invisible to an interviewer but prevents rambling starts that waste your best material on a weak opening line.

For technical and fit questions specifically, it helps to prepare a short "headline" sentence you say first — one sentence stating your core answer or position — before expanding into detail. This mirrors how strong professional communication generally works: lead with the conclusion, then support it, rather than building up to the conclusion at the end where a distracted listener might miss it.

Worked example: asked "why this company?", a rambling answer might wander through unrelated personal history before finally naming a reason. A headline-first answer states the reason immediately — "I''m drawn to this firm''s focus on [specific thing], because [genuine reason]" — then spends the rest of the answer supporting that one clear claim with specifics.

Recap: pause briefly to plan your structure before answering, and for technical/fit questions, lead with a one-sentence headline answer before expanding — this keeps answers focused and makes sure your strongest point isn''t buried at the end.',
   3);

-- resume-and-behavioral-basics
insert into lessons (id, skill_id, content_type, content_body, order_index) values
  ('00000000-0000-0000-0002-000000920202', '00000000-0000-0000-0001-000000000202', 'article',
   'Writing STAR answers well starts before the interview, in how you mine your own experience for material. Most people underestimate how much usable material sits in ordinary experiences — a group project, a part-time job, a club role — because they judge these as "not impressive enough" compared to imagined ideal stories. In practice, interviewers care far more about the clarity of your Action and Result than about the prestige of the Situation.

A useful exercise is working backward from Result: for each experience, first identify what changed or improved because of something you did, then reconstruct the Situation, Task, and Action that led there. This avoids the common trap of describing a Situation in exhaustive detail and then rushing a thin, vague Result at the end.

Worked example: instead of starting with "I worked at a coffee shop," start with the result — "cut average order-wait time during the morning rush." Working backward: Situation (mornings were consistently backed up), Task (management asked staff for ideas), Action (I proposed and helped test a modified station layout), Result (average wait time dropped noticeably, and the layout became standard). The result anchors the story; everything else supports it.

Recap: mine ordinary experiences for material by starting from a concrete result and working backward to the situation, task, and action — this produces sharper stories than starting from the situation and hoping a strong result appears at the end.',
   2),
  ('00000000-0000-0000-0002-000000920203', '00000000-0000-0000-0001-000000000202', 'article',
   'Resume bullets and STAR answers should tell the same story, not two different versions of your experience — a common and avoidable mistake is a resume claiming an achievement that an interviewer then can''t get any specific detail on when asked to expand. Treat every resume bullet as a promise you need to be able to back up conversationally, with the same context/action/result specificity, on demand.

A related discipline is quantifying results even when an exact number isn''t available. "Improved" or "helped with" are weak because they''re unfalsifiable; even a rough, honestly-labeled estimate ("roughly halved," "increased attendance by an estimated 20%") gives an interviewer something concrete to evaluate, as long as you can explain how you arrived at that estimate if asked.

Worked example: a resume bullet reads "Improved club event attendance." Expanded in an interview using STAR: Situation (attendance had been declining for two semesters), Task (as events coordinator, asked to reverse the trend), Action (moved event times based on a quick member survey, added reminder emails), Result (attendance roughly doubled over the following semester, based on sign-in sheets). The resume bullet and the STAR answer reinforce each other instead of contradicting or diverging.

Recap: keep your resume bullets and STAR answers consistent — a bullet is a promise you should be able to expand on with the same specificity. Quantify results even with a rough, honestly-explained estimate rather than vague language like "helped with" or "improved."',
   3);

-- case-method-basics
insert into lessons (id, skill_id, content_type, content_body, order_index) values
  ('00000000-0000-0000-0002-000000920302', '00000000-0000-0000-0001-000000000203', 'article',
   'A common failure mode in case interviews isn''t bad math — it''s silence. Many candidates freeze because they''re trying to solve the whole problem in their head before saying anything, which looks to an interviewer like you have no process at all. The fix is narrating out loud from the very first step: state how you''re clarifying the question before you''ve even decided your full approach, so the interviewer sees your thinking develop in real time rather than receiving a finished answer with no visible reasoning.

Narrating also lets an interviewer redirect you gently if an assumption is off-base, which is a feature, not a failure — real case interviews are often collaborative, and interviewers frequently nudge candidates who are close but have picked an unrealistic number for one input.

Worked example: rather than going silent to calculate, a strong candidate says: "I''ll estimate this by breaking it into population, adoption rate, and frequency. Let me start with population — I''ll assume roughly a million people in this city, since that''s a reasonable size for the scenario you''ve described." This out-loud approach invites correction before too much is built on a shaky number.

Recap: narrate your reasoning out loud from the first step rather than solving silently — it shows your process, and it lets an interviewer redirect a shaky assumption early rather than after an entire calculation is built on it.',
   2),
  ('00000000-0000-0000-0002-000000920303', '00000000-0000-0000-0001-000000000203', 'article',
   'Once you''ve built an estimate, the strongest case answers don''t stop at the number — they briefly discuss what would make the estimate more or less reliable. This shows an interviewer you understand your own answer''s limitations, which is closer to how a real analyst operates than treating any single estimate as final.

A simple habit: after reaching a number, name one assumption that, if wrong, would change the answer the most, and briefly say what data you''d want in the real world to firm it up. This takes ten seconds but visibly upgrades an answer from "here''s a guess" to "here''s a reasoned estimate, and here''s where the real uncertainty lives."

Worked example: after estimating 360,000 coffees sold per day in a city, a strong close is: "The number I''m least confident in is the 30% adoption rate — if it''s closer to 20%, the estimate drops to 240,000. In practice I''d want actual café sales or survey data to narrow that down." This costs almost nothing to add and signals real analytical maturity.

Recap: after reaching an estimate, name the assumption you''re least confident in and what real data would firm it up — this small addition shows you understand your own estimate''s limitations rather than treating a rough number as final.',
   3);

-- technical-interview-prep
insert into lessons (id, skill_id, content_type, content_body, order_index) values
  ('00000000-0000-0000-0002-000000920402', '00000000-0000-0000-0001-000000000204', 'article',
   'Beyond DCF and statement linkage, a recurring technical theme is comparable company analysis ("comps") — valuing a company by looking at how the market prices similar companies, usually via a multiple like EV/EBITDA or P/E. Interviewers often ask candidates to explain why two seemingly similar companies might trade at different multiples, which tests whether you understand that a multiple reflects the market''s expectations about growth, risk, and profitability — not just company size.

A reliable anchor explanation: a higher multiple generally signals the market expects faster growth, lower risk, or higher margins from that company relative to peers; a lower multiple signals the opposite, or can reflect a temporary problem the market is discounting.

Worked example: two retailers have similar current revenue, but Retailer A trades at 12x EBITDA while Retailer B trades at 7x. A strong explanation: "The market is likely pricing in higher expected growth or lower risk for A — maybe it has a stronger online channel or less debt — while B''s lower multiple could reflect slower expected growth, more competitive pressure, or a specific recent problem investors are discounting." This shows you understand what a multiple represents, not just how to calculate one.

Recap: comps valuation prices a company relative to similar peers using a multiple like EV/EBITDA; differences in multiples between similar companies typically reflect differing market expectations about growth, risk, or margins — being able to explain why, not just calculate the multiple, is what technical interviewers are listening for.',
   2),
  ('00000000-0000-0000-0002-000000920403', '00000000-0000-0000-0001-000000000204', 'article',
   'Interviewers also frequently probe how well you can reason about a scenario you haven''t seen before, rather than recite a memorized fact — a common format is a short "what happens if" question layered on top of a concept you already know. The skill being tested is applying a mechanic to a new situation live, which is different from (and harder than) reciting a definition.

A useful preparation habit is taking each anchor explanation you''ve built and deliberately generating your own "what if" variations to practice on, rather than only rehearsing the original question. This builds the flexibility interviewers are actually testing for.

Worked example: having rehearsed the depreciation-increase walkthrough, a candidate might be asked instead, "what happens to the three statements if a company writes off £10 of bad debt (an account receivable it won''t collect)?" Reasoning from the same core mechanics: income statement — bad debt expense reduces pre-tax income by £10, net income falls by £7.50 after tax; cash flow — like depreciation, this is a non-cash expense, so it''s added back, and cash flow from operations rises by £2.50 net; balance sheet — accounts receivable falls by £10 (the uncollectible amount is written off), cash rises by £2.50, and equity falls by £7.50 — the same balancing logic as the depreciation case, applied to a different line item.

Recap: interviewers often test whether you can apply a known mechanic to a new scenario, not just recite a memorized answer — practicing deliberate variations on your anchor explanations builds the flexibility that live "what if" questions actually test for.',
   3);

-- market-sizing-case-interviews
insert into lessons (id, skill_id, content_type, content_body, order_index) values
  ('00000000-0000-0000-0002-000000920502', '00000000-0000-0000-0001-000000000205', 'article',
   'A useful extension to basic market sizing is thinking in ranges rather than a single point estimate, especially once you''ve identified a shaky assumption. Presenting a range shows more sophistication than a single number, because it demonstrates you understand how sensitive your conclusion is to the input you''re least sure about — a skill directly relevant to how real financial analysts communicate uncertainty to decision-makers.

A simple way to build a range live: after your base-case calculation, quickly recompute using a plausible low and high value for your shakiest assumption, and state the resulting range alongside your headline number.

Worked example: continuing the bank branch case, instead of stopping at "roughly break-even," a stronger close is: "Using my base assumption of 4% capture, the branch is roughly break-even in year one. If capture is closer to 2%, it loses about £66,000; if capture reaches 6%, it''s profitable by around £102,000. Given that wide swing, I''d want real local market data on likely capture rate before recommending either way — a base-case number alone understates how much this decision actually hinges on that one input."

Recap: presenting a quick range around your shakiest assumption, not just a single point estimate, shows deeper understanding of your own analysis and mirrors how real financial recommendations communicate uncertainty to decision-makers.',
   2),
  ('00000000-0000-0000-0002-000000920503', '00000000-0000-0000-0001-000000000205', 'article',
   'Market-sizing cases are also a chance to demonstrate commercial judgment beyond the arithmetic — noticing a factor the interviewer didn''t explicitly ask about but that a real decision-maker would care about. This doesn''t mean padding your answer with unrelated tangents; it means briefly flagging one genuinely relevant factor your core estimate doesn''t capture, then returning to your main structure.

Common factors worth a brief mention, when relevant: competitive response (would a competitor react to this decision in a way that changes the outcome?), timing (does the estimate assume conditions stay constant, when they may not?), and non-financial risk (regulatory, reputational) that a pure numbers estimate wouldn''t show.

Worked example: after estimating the bank branch''s year-one economics, a candidate with strong commercial judgment adds: "One thing my estimate doesn''t capture is competitive response — if a rival bank already has a branch nearby, my 4% capture assumption might be optimistic; if this town currently has no bank branch at all, it could be conservative. That competitive context would meaningfully move my confidence in either direction." This single added sentence signals real business thinking without derailing the core structured estimate.

Recap: briefly flagging one genuinely relevant factor your core numeric estimate doesn''t capture — competitive response, timing, or non-financial risk — shows commercial judgment beyond arithmetic, as long as it stays brief and doesn''t replace your main structured estimate.',
   3);

-- ethics-and-compliance-basics
insert into lessons (id, skill_id, content_type, content_body, order_index) values
  ('00000000-0000-0000-0002-000000920602', '00000000-0000-0000-0001-000000000206', 'article',
   'Conflicts of interest are the third recurring ethics concept, and they''re often more subtle than insider trading or fiduciary breaches because a conflict doesn''t require anyone to actually do anything wrong — it exists the moment two interests could pull in different directions, before any decision is even made. Recognizing a conflict early, and disclosing it, is itself considered good practice, distinct from resolving it.

A common source of conflicts in finance is compensation structure: an advisor paid a commission for selling a particular product has a built-in incentive to recommend that product even when it''s not the client''s best option, regardless of the advisor''s personal intentions. This is why many regulated roles require disclosing compensation structure to clients — not because commission-based pay is automatically wrong, but because the client deserves to know the incentive exists.

Worked example: a financial advisor''s firm pays a higher commission for recommending its own in-house investment fund over a comparable external fund. Even if the in-house fund is genuinely reasonable for the client, recommending it without disclosing the commission difference is a conflict-of-interest problem — the fix isn''t necessarily avoiding the in-house fund entirely, but disclosing the incentive so the client can weigh the recommendation with that context.

Recap: a conflict of interest exists whenever two interests could pull in different directions, independent of whether anyone acts improperly — disclosure, not just avoidance, is often the appropriate response, particularly around compensation structures that could bias a recommendation.',
   2),
  ('00000000-0000-0000-0002-000000920603', '00000000-0000-0000-0001-000000000206', 'article',
   'Beyond recognizing a single ethics concept in isolation, real workplace situations often layer more than one issue at once, which is why interviewers sometimes present a scenario with no clean single answer. The goal in these cases isn''t finding the one "correct" label — it''s demonstrating a consistent reasoning process even when the situation is genuinely ambiguous.

A useful habit for layered scenarios: explicitly separate what you know for certain from what you''re inferring or assuming, since conflating the two is a common way ethics answers go wrong — either overreacting to an assumption as if it were confirmed fact, or underreacting to a real red flag by explaining it away.

Worked example: a colleague mentions they''re "stretched thin" and pushes back on a compliance review you flagged as urgent. This could be ordinary workload pressure (a management, not ethics, issue), or it could indicate a colleague trying to avoid scrutiny of something they''re aware is a problem. A strong response separates the two explicitly: "I don''t know which of these is true, so I''ll document the specific compliance concern clearly, raise it through the normal review channel regardless of pushback, and let the process — not my guess about their motive — determine the outcome." This avoids either over-accusing or letting a real concern quietly drop.

Recap: layered, ambiguous ethics scenarios test consistent reasoning under uncertainty, not a single correct label — explicitly separating what you know from what you''re assuming, and letting the normal process run rather than acting on an unconfirmed guess, is a reliable way to handle them.',
   3);

-- advanced-behavioral-interviews
insert into lessons (id, skill_id, content_type, content_body, order_index) values
  ('00000000-0000-0000-0002-000000920702', '00000000-0000-0000-0001-000000000207', 'article',
   'Leadership questions trip people up when they assume leadership requires a formal title — many strong candidates undersell themselves by saying "I''ve never officially led anything" and skipping the question''s real intent. Informal leadership (organizing a group without being asked, stepping up when a project was stalling, coordinating people with no reporting relationship to you) counts fully, and often demonstrates initiative more clearly than a title given by default.

What interviewers are actually checking for in a leadership story: did you notice something needed to happen, did you take ownership of making it happen, and did you get other people aligned and moving, not just yourself. A story where you did all the work alone, with no coordination of others, isn''t really a leadership story — it''s an individual-contributor story, which is fine for other questions but doesn''t answer this one.

Worked example: instead of "I''ve never led a team," a candidate reframes: "During a class project, no one had claimed the coordinator role and we were falling behind. I volunteered to organize a weekly check-in and track who owned what — nothing official, just stepping up because it needed doing. We finished on time, and two teammates later told me the structure helped them a lot." This has no title, no formal authority, and is still a genuine leadership story because it shows initiative and coordinating others.

Recap: leadership doesn''t require a formal title — informal instances of noticing something needed to happen and coordinating others to make it happen count fully. Make sure your story involves aligning other people, not just your own individual effort, or it answers a different question than the one being asked.',
   2),
  ('00000000-0000-0000-0002-000000920703', '00000000-0000-0000-0001-000000000207', 'article',
   'Conflict questions are often answered too safely — candidates describe a disagreement that was resolved so smoothly it barely sounds like a real conflict, which can read as evasive or as though the candidate is avoiding a genuine example. A stronger conflict story acknowledges real tension existed, without becoming a story where you''re clearly in the right and the other person is clearly wrong — that framing tends to read as one-sided rather than as evidence of interpersonal skill.

A useful structure specific to conflict stories: describe the disagreement honestly (including that it was genuinely uncomfortable, if it was), describe the specific step you took to move toward resolution (not "we talked it out" vaguely, but what you actually said or did), and describe the outcome, including whether the relationship was preserved even if the immediate disagreement wasn''t fully resolved your way.

Worked example: "A colleague and I disagreed on how to prioritize two competing deadlines — I thought Project A was more urgent, they thought B was. Rather than escalating immediately, I asked if we could each walk through our reasoning for ten minutes, then compare. It turned out they had context on a client timeline I didn''t have, which changed my view — we ended up prioritizing B, and I made sure to say directly that their information had changed my mind, not just quietly went along with it." This shows genuine disagreement, a specific de-escalation step, and an honest outcome where the candidate''s original position didn''t win — which is more credible than always being right.

Recap: conflict stories are stronger when they acknowledge genuine tension rather than a suspiciously smooth resolution, describe a specific de-escalation action (not vague "we talked it out"), and are honest about the outcome — including when your original position didn''t prevail.',
   3);

-- negotiating-a-job-offer
insert into lessons (id, skill_id, content_type, content_body, order_index) values
  ('00000000-0000-0000-0002-000000920802', '00000000-0000-0000-0001-000000000208', 'article',
   'Negotiation isn''t a single moment — it''s often a short back-and-forth, and knowing how to respond to a counter is as important as making the first ask. A common pattern: you counter with a specific number, the employer responds with something in between their original offer and your ask, and you need to decide quickly whether to accept, counter once more, or ask for a non-salary concession instead.

A useful principle: know your "walk-away" point before the conversation starts — the minimum package you''d genuinely accept — so you''re not deciding under pressure in the moment. Without this, it''s easy to either cave too early or keep pushing past the point of diminishing returns and risk souring the relationship before you''ve even started.

Worked example: you counter at $68,000; the employer comes back at $65,000, citing budget constraints. If your walk-away point was $64,000, this is a good outcome worth accepting — pushing further risks the relationship for a small remaining gap. If the offer includes an extra week of vacation you value highly, accepting $65,000 plus confirming that vacation detail in writing may be a stronger overall outcome than squeezing for another $1,000 in base.

Recap: negotiation is often a short back-and-forth, not a single ask — decide your walk-away point in advance so you''re not deciding under pressure, and remember a non-salary concession (vacation, start date, signing bonus) can sometimes close a remaining gap better than continuing to push on base salary alone.',
   2),
  ('00000000-0000-0000-0002-000000920803', '00000000-0000-0000-0001-000000000208', 'article',
   'Tone matters as much as substance in a negotiation, particularly because you''ll be working with these same people if you accept. A negotiation that comes across as adversarial or overly aggressive can create friction before your first day, even if you technically "win" a higher number — while a negotiation that''s too passive risks leaving real value unclaimed.

The most reliable tone is enthusiastic but direct: express genuine excitement about the role first, so the ask doesn''t read as a threat to walk away, then state your ask clearly and specifically rather than hinting at it. Avoid ultimatums ("I need $70,000 or I''m walking") unless you genuinely mean them and are prepared to follow through — bluffing an ultimatum you don''t intend to keep, and then backing down, damages credibility for the rest of the relationship.

Worked example: a weak, adversarial approach: "Your offer is too low, I''ve gotten better elsewhere." A weak, overly passive approach: hinting vaguely that the offer "could maybe be a bit higher" without a number. A strong, enthusiastic-but-direct approach: "I''m genuinely excited about this role and the team — I do want to flag that based on my research, $68,000 feels like a better fit for the role and my experience. Is there room to get closer to that?" This keeps warmth while still being specific and direct.

Recap: negotiate in a tone that''s enthusiastic but direct — genuine excitement first, then a clear, specific ask — rather than adversarial (which creates friction before you start) or overly passive (which leaves value unclaimed). Avoid ultimatums you''re not actually prepared to follow through on.',
   3);

-- compensation-package-basics
insert into lessons (id, skill_id, content_type, content_body, order_index) values
  ('00000000-0000-0000-0002-000000920902', '00000000-0000-0000-0001-000000000209', 'article',
   'Once you understand a package''s four components, the next skill is putting a realistic number on each one so two offers can actually be compared apples-to-apples. Base salary needs no adjustment. Bonus should be discounted for uncertainty — treating a 10% target as worth perhaps 60-80% of its face value in your comparison is more realistic than counting it at full value, since payout typically depends on performance conditions you don''t fully control.

Benefits are the piece people most often ignore entirely, but employer-paid health insurance, retirement matching, and paid time off all carry real, estimable dollar value — often several thousand dollars a year combined, meaningful enough to change which offer is actually better.

Worked example: Offer A ($70,000 base, no bonus, modest benefits) versus Offer B ($62,000 base, 10% bonus target, ~$6,000/year benefits value). Discounting B''s bonus to 70% of face value (~$4,340) and adding benefits: A totals roughly $70,000 + minimal benefits; B totals roughly $62,000 + $4,340 + $6,000 = $72,340 — B is actually the higher total-value offer once bonus is realistically discounted and benefits are counted, despite the lower headline base.

Recap: discount a bonus target for uncertainty rather than counting it at full face value, and add a realistic dollar estimate for benefits — doing this consistently across offers often changes, or at least narrows, which offer looks better on paper.',
   2),
  ('00000000-0000-0000-0002-000000920903', '00000000-0000-0000-0001-000000000209', 'article',
   'Comparing two offers also means comparing what each employer is signaling about how they value the role, not just the raw numbers — a company offering a lower base but a rich bonus and benefits package may have a different compensation philosophy (pay for performance) than one offering a flat, high base with minimal variable pay (pay for stability). Neither approach is inherently better, but it''s worth understanding which one you''re actually being offered, since it affects your income''s predictability, not just its average size.

A related consideration is how compensation typically grows at each type of employer — some companies give small, steady base increases and rely on bonus growth for upside; others rarely adjust base and instead expect you to negotiate a new offer via a job change to see a meaningful jump. Asking directly about typical raise and promotion timelines during the offer stage, not after accepting, gives you information the initial offer number alone doesn''t.

Worked example: a candidate comparing a stable-base company (small predictable annual raises) against a bonus-heavy company (larger swings tied to performance) should weigh not just this year''s total estimated value, but which structure fits their own risk tolerance and need for predictable income — a candidate with tight fixed expenses may reasonably prefer the stable-base offer even if its average expected value is slightly lower.

Recap: compensation structure signals an employer''s philosophy (predictable stability vs. performance-linked upside) beyond the raw numbers — asking about typical raise and promotion timelines during the offer stage, and weighing your own tolerance for income variability, are decisions the headline number alone doesn''t capture.',
   3);

-- reading-a-pay-stub-and-taxes
insert into lessons (id, skill_id, content_type, content_body, order_index) values
  ('00000000-0000-0000-0002-000000921002', '00000000-0000-0000-0001-000000000210', 'article',
   'Beyond understanding a single pay stub, it helps to know which withholding decisions you actually control, since these are usually set once at hiring (via a form like the US W-4) and then forgotten — even though life changes can make the original setting wrong. Claiming too few withholding allowances means over-withholding (a larger refund at tax time, but less cash in each paycheck all year); claiming too many means under-withholding (more cash now, but a possible tax bill, and in some cases a penalty, at filing time).

Neither extreme is inherently better — a large annual refund is sometimes framed as "forced savings," but it also means the government held your money interest-free all year when you could have had it in each paycheck instead. The right setting depends on your own preference for predictability versus maximizing take-home pay throughout the year.

Worked example: someone who starts a job, has a second part-time job added mid-year, or gets married often needs to revisit their withholding form, since the original setting was calculated for a different situation — failing to update it is a common reason people are surprised by a larger-than-expected tax bill the following spring.

Recap: withholding settings (set via a form like a W-4) are a choice, not a fixed fact, and life changes (a second job, marriage, a raise) can make an old setting wrong — revisiting the setting periodically avoids being surprised by a large bill or an unnecessarily large refund at filing time.',
   2),
  ('00000000-0000-0000-0002-000000921003', '00000000-0000-0000-0001-000000000210', 'article',
   'Voluntary deductions on a pay stub deserve their own attention, since — unlike taxes — you control whether and how much goes toward them, and getting this wrong is a common way new employees either overspend without realizing it or underuse valuable pre-tax benefits. Common voluntary deductions include retirement contributions, health insurance premiums, and pre-tax accounts for medical or transit expenses — each reduces net pay in exchange for something of value, but the trade-off is only worth it if you understand what you''re getting.

A useful habit when starting a new job is reconstructing your expected net pay by hand before the first paycheck arrives, using the specific deductions you elected, rather than assuming net pay will be close to gross pay divided by pay periods. This avoids the common budgeting mistake of committing to fixed costs (like a lease) based on gross salary, only to discover net pay is meaningfully lower once deductions start.

Worked example: someone earning $60,000/year ($2,500 gross per bi-weekly paycheck before tax) who signs up for a 5% 401(k) contribution and employee health insurance might see close to $300-400 of voluntary deductions per paycheck on top of taxes — reconstructing this in advance, rather than discovering it on the first real paycheck, avoids budgeting against a number that was never going to arrive in the bank account.

Recap: voluntary deductions (retirement, health insurance, pre-tax accounts) are choices that reduce net pay in exchange for value received — reconstruct your expected net pay by hand before your first paycheck, using your specific elections, rather than assuming it will be close to gross pay.',
   3);

-- employer-retirement-matching
insert into lessons (id, skill_id, content_type, content_body, order_index) values
  ('00000000-0000-0000-0002-000000921102', '00000000-0000-0000-0001-000000000211', 'article',
   'Understanding your specific plan''s match formula in detail matters, because match structures vary meaningfully between employers and a vague sense of "my employer matches" isn''t enough to know how much you need to contribute to capture it fully. Common formulas include a flat percentage match (employer matches 100% of your contribution up to some % of salary), a partial match (like 50% up to some % of salary), or a tiered match (a higher match rate on the first portion of your contribution, lower on additional amounts).

It''s also worth checking whether your plan has a vesting schedule on the employer''s contributions specifically — some employers require you to stay a certain number of years before their matching contributions (not your own) fully belong to you, meaning leaving early could forfeit some employer-contributed money even though your own contributions are always fully yours.

Worked example: an employee assumes their employer "matches contributions" generally, and contributes only 3% of salary, when the actual plan matches 100% up to 4% — they''re leaving 1 percentage point of salary in unclaimed match. Checking the actual plan document (not just a verbal summary from a colleague) would have revealed the true 4% target.

Recap: read your specific plan''s match formula rather than assuming a generic understanding — formulas vary (flat, partial, tiered), and check for a vesting schedule on employer contributions specifically, since leaving before it''s satisfied can forfeit some of that matched money even though your own contributions are always fully yours.',
   2),
  ('00000000-0000-0000-0002-000000921103', '00000000-0000-0000-0001-000000000211', 'article',
   'Once you''re capturing the full employer match, a natural next question is whether to contribute beyond it — and the answer depends on comparing the retirement account''s tax-advantaged growth against other financial priorities competing for the same dollar, like paying down high-interest debt or building an emergency fund. There''s no universal right order, but a commonly cited general priority sequence is: capture the full employer match first (guaranteed, immediate return), then address any high-interest debt (a credit card balance at 20%+ APR is a guaranteed "return" from paying it down that''s hard for most investments to beat), then build a basic emergency fund, then consider additional retirement contributions beyond the match.

This ordering isn''t a rigid rule — someone with no high-interest debt and a stable job might reasonably skip straight to additional retirement contributions after the match, while someone carrying credit card debt is usually better off directing extra money there first, since the guaranteed "return" from eliminating that debt typically exceeds likely investment returns.

Worked example: someone capturing their full 4% employer match, but also carrying a $3,000 credit card balance at 22% APR, is very likely better off directing any extra money toward paying down that balance before increasing retirement contributions further — the guaranteed 22% "return" from eliminating that debt is higher than a typical long-term investment return.

Recap: after capturing the full employer match, compare additional retirement contributions against other priorities competing for the same dollar — high-interest debt in particular usually deserves priority, since eliminating it delivers a guaranteed return that''s hard for most investments to beat.',
   3);

-- health-insurance-basics
insert into lessons (id, skill_id, content_type, content_body, order_index) values
  ('00000000-0000-0000-0002-000000921202', '00000000-0000-0000-0001-000000000212', 'article',
   'Beyond premium and deductible, two more terms determine what a health plan actually costs you across a year: out-of-pocket maximum (the total you''d ever pay in a year before insurance covers everything else completely, a genuine worst-case ceiling) and copay/coinsurance (what you pay per visit or as a percentage of a bill, even after meeting your deductible — insurance often doesn''t cover 100% immediately once the deductible is met).

The out-of-pocket maximum matters most in a genuine worst-case scenario — a serious illness or accident — and is worth checking specifically for anyone weighing plans partly on risk tolerance, since a plan with a low premium but no reasonable out-of-pocket cap could expose you to costs far beyond the deductible alone.

Worked example: Plan A has a $3,000 deductible and, after that, 20% coinsurance up to a $6,000 out-of-pocket maximum; Plan B has a $500 deductible and 10% coinsurance up to a $3,000 maximum. In a genuine worst-case year (a major surgery, for instance), Plan A could cost up to $6,000 out of pocket while Plan B caps at $3,000 — a meaningful difference in worst-case financial exposure that premium and deductible alone don''t fully capture.

Recap: out-of-pocket maximum is the real worst-case ceiling on annual health costs, and coinsurance is what you keep paying (as a percentage) even after the deductible is met — checking both, not just premium and deductible, gives a fuller picture of a plan''s actual financial risk.',
   2),
  ('00000000-0000-0000-0002-000000921203', '00000000-0000-0000-0001-000000000212', 'article',
   'Choosing a health plan is also a decision worth revisiting, not a one-time choice locked in forever — most employers offer an annual window (open enrollment, covered in a later lesson) to switch plans as your circumstances change. A plan that made sense as a healthy new graduate with no ongoing medical needs may no longer be the best fit after a life change like starting a family, developing an ongoing condition, or simply using more care than expected in a given year.

A useful habit is reviewing actual usage at the end of each plan year (how much was spent on premiums, deductible, and coinsurance combined) against what the alternative plan would have cost under the same usage — this retrospective check often reveals whether your original premium/deductible trade-off was actually the right one, more reliably than guessing in advance.

Worked example: someone who chose a low-premium, high-deductible plan expecting minimal care, but ended up with two unexpected doctor visits and a minor procedure, might find in hindsight that the higher-premium plan would have cost less overall that year — useful information for the next open enrollment decision, even though the original choice was reasonable given what was known at the time.

Recap: health plan choice is worth revisiting annually, not treated as permanent — reviewing actual usage and cost against what the alternative plan would have cost under the same usage gives a more reliable basis for next year''s decision than guessing usage in advance alone.',
   3);

-- workplace-financial-etiquette
insert into lessons (id, skill_id, content_type, content_body, order_index) values
  ('00000000-0000-0000-0002-000000921302', '00000000-0000-0000-0001-000000000213', 'article',
   'Beyond formal expense reports, everyday financial etiquette at work covers a set of smaller, unwritten norms that new employees often only learn by making a mistake first. Splitting a group meal or team gift fairly and promptly, not "forgetting" to pay your share, is a small but real trust signal — colleagues notice patterns of who consistently pays back promptly versus who needs repeated reminders.

Another common gray area is company-provided resources used for mixed personal/business purposes — a company phone plan, a subscription, or supplies. The safest default when a policy isn''t explicit is asking rather than assuming, since a clarifying question early costs nothing, while an incorrect assumption discovered later can look like carelessness or worse, even if it was genuinely an honest mistake.

Worked example: an employee unsure whether a modest personal purchase can go on a company card asks their manager directly rather than guessing: "Quick question — is X the kind of thing that''s fine to expense, or should I keep that separate?" This costs thirty seconds and avoids a much more awkward conversation later if the assumption had been wrong.

Recap: everyday financial etiquette — splitting shared costs promptly, and asking rather than assuming about gray-area company resource use — is made up of small habits that build or erode trust over time, well before a formal expense report is ever involved.',
   2),
  ('00000000-0000-0000-0002-000000921303', '00000000-0000-0000-0001-000000000213', 'article',
   'Financial etiquette also extends to how you discuss money at work generally — salary, bonuses, and personal financial situations carry different norms of openness than most other workplace topics, and misjudging them can create friction even with good intentions. Discussing your own salary is often legally protected (in many jurisdictions, employers cannot prohibit employees from discussing pay), but that doesn''t mean every workplace culture treats it as comfortable to bring up casually — reading the norms of your specific team matters here as much as anywhere else.

Asking a colleague directly about their salary is generally considered more sensitive than sharing your own if asked, since it puts the other person in a position of having to decide whether to answer or decline. A safer default is being open about your own compensation if someone else raises it or asks, without proactively pressing others for theirs.

Worked example: a new hire wondering whether their offer was fair asks a colleague, "Would you be comfortable sharing roughly what the range is for this role? No pressure if not." — framing it as optional and non-pressuring respects that the colleague may not want to answer, while still opening the door if they''re willing.

Recap: pay transparency norms vary by workplace culture even where discussing salary is legally protected — being open about your own compensation if asked is generally safer than pressing others for theirs, and framing any ask as explicitly optional respects that not everyone is comfortable answering.',
   3);

-- budgeting-on-your-first-salary
insert into lessons (id, skill_id, content_type, content_body, order_index) values
  ('00000000-0000-0000-0002-000000921402', '00000000-0000-0000-0001-000000000214', 'article',
   'The 50/30/20 framework is a starting benchmark, not a rigid rule, and applying it mechanically without adjusting for real local cost of living can produce an unrealistic budget that gets abandoned within a month. In genuinely high cost-of-living areas, needs alone can easily exceed 50% of net pay even for someone being reasonably frugal — in that case, the honest adjustment is usually reducing the wants percentage, not pretending needs will magically shrink to fit the framework.

A more durable approach than forcing the exact percentages is using them as a diagnostic: if needs are running well above 50%, that''s a signal to look hard at fixed costs (housing, in particular, since it''s usually the largest single line item) before assuming discretionary spending is the problem. If needs are reasonably in line but savings are still near zero, the more likely culprit is wants spending growing to fill whatever''s left over.

Worked example: someone in an expensive city finds needs run 65% of net pay even after reasonable cuts, mostly driven by rent. Rather than abandoning budgeting altogether, they adjust: 65% needs, 20% wants, 15% savings — a real, sustainable budget for their actual cost of living, still deliberately allocating savings rather than letting it default to whatever''s left.

Recap: 50/30/20 is a diagnostic starting point, not a rule to force regardless of real cost of living — if needs consistently run high, adjust the framework''s percentages deliberately (usually trimming wants) rather than abandoning budgeting or pretending fixed costs will shrink to fit an unrealistic target.',
   2),
  ('00000000-0000-0000-0002-000000921403', '00000000-0000-0000-0001-000000000214', 'article',
   'A first salary is also usually the first time someone needs to handle irregular expenses — costs that don''t occur every month but are entirely predictable in advance, like car insurance paid semi-annually, an annual subscription renewal, or holiday gifts. Budgeting only against monthly recurring costs and being surprised every time an irregular expense hits is a common and avoidable first-salary mistake.

The standard fix is a "sinking fund" approach: dividing an irregular annual cost by 12 and setting that smaller amount aside every month in a separate tracked category, so the money is already there when the larger bill arrives instead of disrupting that month''s budget.

Worked example: a $600 annual car insurance premium and $300 in typical December gift spending total $900/year in irregular costs — dividing by 12 means setting aside $75/month specifically for this category. Someone who instead budgets only for monthly recurring costs experiences December and their insurance renewal month as unexplained budget blowouts, even though both were entirely predictable well in advance.

Recap: irregular but predictable expenses (insurance, subscriptions, seasonal gifts) deserve their own monthly "sinking fund" line — dividing the annual total by 12 and setting that amount aside monthly avoids being repeatedly surprised by costs that were actually foreseeable all along.',
   3);

-- building-an-emergency-fund
insert into lessons (id, skill_id, content_type, content_body, order_index) values
  ('00000000-0000-0000-0002-000000921502', '00000000-0000-0000-0001-000000000215', 'article',
   'Deciding where exactly on the 3-6 month range to target requires being honest about your own specific risk factors, not just picking the midpoint by default. Someone with a highly stable job, a dual-income household, or family who could help in a true emergency has more real safety net already and might reasonably target the lower end. Someone with variable or commission-based income, a single-income household, or no other safety net to fall back on should generally target the higher end, or even beyond 6 months.

It''s also worth separating the emergency fund conceptually, even if not literally in a different account, from other savings goals — mixing an emergency fund with a vacation fund makes it too easy to justify "borrowing" from the emergency portion for a non-emergency, which defeats its purpose.

Worked example: two people with identical $1,800/month essential expenses reach different targets: one, in a stable dual-income household with family nearby, targets 3 months ($5,400); the other, a freelancer with variable monthly income and no family financial safety net, targets 6 months ($10,800) — same expense level, different real risk profile, different appropriate target.

Recap: where you land on the 3-6 month range (or beyond) should reflect your actual risk factors — job/income stability, household structure, and other available safety nets — not a default midpoint; and keeping the fund conceptually separate from other savings goals, even in the same account, protects it from being spent on non-emergencies.',
   2),
  ('00000000-0000-0000-0002-000000921503', '00000000-0000-0000-0001-000000000215', 'article',
   'Building an emergency fund from zero can feel discouraging if the full target looks distant, which is why breaking the goal into smaller intermediate milestones — rather than fixating only on the final 3-6 month number — tends to sustain the habit better. A common first milestone is a smaller starter amount (enough to cover one modest unplanned expense, like a car repair) reached quickly, which provides real protection against the most common small emergencies even before the full target is reached.

Automating the monthly transfer, so building the fund doesn''t depend on remembering or having leftover willpower at the end of each month, is one of the most reliable ways to actually sustain progress — treating the transfer like a fixed bill rather than a discretionary choice made fresh each month.

Worked example: rather than only tracking progress toward the full $5,400 target, Marcus sets an intermediate milestone of $1,000 (covering most single unplanned expenses) as a first goal, reached in 5 months at $200/month — hitting this milestone provides real, immediate protection and visible progress, both of which make continuing toward the full $5,400 target easier than facing an undifferentiated 27-month goal from day one.

Recap: breaking an emergency fund goal into a smaller starter milestone, reached quickly, provides real protection sooner and sustains motivation better than only tracking the distant full target — automating the monthly transfer removes reliance on remembering or willpower each month.',
   3);

-- startup-equity-and-stock-options
insert into lessons (id, skill_id, content_type, content_body, order_index) values
  ('00000000-0000-0000-0002-000000921602', '00000000-0000-0000-0001-000000000216', 'article',
   'Beyond the basic mechanics, evaluating a specific equity offer requires a few more concrete questions most candidates don''t think to ask, and startups generally expect and welcome these questions rather than viewing them as inappropriate. Useful questions include: what is the current strike price relative to the company''s most recent valuation (a strike price already close to or above a reasonable per-share value leaves little room for the options to gain value); how many total shares are outstanding, so you can estimate what percentage of the company your grant actually represents, since "10,000 options" means very different things at a company with 1 million total shares versus 100 million; and what happens to unvested and vested options if you''re laid off, since terms sometimes differ meaningfully by exit reason.

It''s also reasonable to ask how much runway (months of cash remaining before the company needs new funding or becomes profitable) the company has, since this affects both job security and the realistic odds the equity ever becomes valuable.

Worked example: a candidate comparing two startup offers with identical option counts (10,000 shares) finds Company A has 10 million total shares outstanding (0.1% ownership) while Company B has 50 million (0.02% ownership) — despite an identical headline number, the actual ownership stake, and thus the potential value, differs fivefold, information the raw option count alone doesn''t reveal.

Recap: evaluating a specific equity offer requires asking about strike price relative to recent valuation, total shares outstanding (to estimate your real ownership percentage), and treatment of unvested equity if laid off — a raw option count alone, without this context, doesn''t tell you what the grant is actually worth.',
   2),
  ('00000000-0000-0000-0002-000000921603', '00000000-0000-0000-0001-000000000216', 'article',
   'Tax treatment of stock options is a genuinely complex area, but understanding the basic shape of it matters for anyone evaluating a startup offer, since taxes can take a meaningful bite out of paper gains and, in some structures, can even create a tax bill before you''ve sold anything to generate cash to pay it. Common option types (in the US context) include Incentive Stock Options (ISOs) and Non-Qualified Stock Options (NSOs), which are taxed differently and at different points in time — the details are worth a real conversation with a tax professional once an offer is real, not something to fully resolve from a general lesson.

The broader principle worth understanding without the full technical detail: exercising options (actually buying the shares at the strike price) can itself trigger a tax event even before you sell any shares, meaning someone could owe real cash taxes on a gain that exists only on paper, with the shares still illiquid (not tradeable, since startup shares typically can''t be sold until an acquisition or public listing).

Worked example: someone exercises options when the strike price is $1 and the company''s shares are estimated to be worth $5, creating a $4/share paper gain across their grant. Depending on the option type, this exercise could trigger a real tax liability now, in cash, even though the shares themselves can''t be sold to generate that cash — a genuine liquidity trap worth understanding before exercising, not after.

Recap: stock option taxation is complex and depends on option type and timing, but the key principle to know going in is that exercising options can trigger real, immediate tax liability on a paper gain, even when the shares themselves are illiquid — a real conversation with a tax professional before exercising is worth the cost once a grant is meaningful.',
   3);

-- professional-networking-basics
insert into lessons (id, skill_id, content_type, content_body, order_index) values
  ('00000000-0000-0000-0002-000000921702', '00000000-0000-0000-0001-000000000217', 'article',
   'Preparing for an informational interview well is what separates a genuinely useful conversation from one that wastes the other person''s generosity and makes them less likely to help the next person who asks. Arriving with specific, thoughtful questions — informed by having actually looked at the person''s background and current role — signals real interest and respect for their time, versus generic questions that could be asked of anyone in the field ("what''s it like working in finance?") and suggest no preparation was done at all.

A useful structure for the conversation itself: a brief, genuine opening about why you reached out to them specifically, 2-3 well-prepared questions that couldn''t be answered by a quick search, room for the conversation to go where it naturally goes rather than rigidly working through a script, and a clear, low-pressure close that doesn''t put them on the spot for a follow-up favor.

Worked example: instead of asking a generic "what''s it like working in your field," a prepared question might be: "I saw you moved from an analyst role into a client-facing one after about two years — was that a deliberate move, and what made you ready for it?" This is specific to their actual path, shows you did real homework, and tends to generate a much more genuine, detailed answer than a generic prompt.

Recap: preparing specific, well-researched questions — not generic ones anyone in the field could answer — signals real interest and respect for the other person''s time, and tends to produce a far more useful conversation than a script of generic prompts.',
   2),
  ('00000000-0000-0000-0002-000000921703', '00000000-0000-0000-0001-000000000217', 'article',
   'Following up after an informational interview or networking conversation is where most of the actual long-term relationship value is built or lost, and it''s the step most people skip because it feels less urgent than the initial ask. A simple, specific thank-you message within a day or two — referencing something particular from the conversation, not a generic "thanks for your time" — closes the loop respectfully and keeps the door open for future contact.

Beyond the immediate thank-you, staying genuinely in touch over months or years (not just when you need something) is what turns a single conversation into an actual professional relationship — sharing a relevant article, congratulating a job change noticed on LinkedIn, or a brief periodic check-in are all low-effort ways to do this without it feeling forced or purely transactional.

Worked example: a strong follow-up message references specifics: "Thank you again for taking the time last week — your point about how you prepared for the client-facing transition was really helpful, and I''ve started applying it by [specific action taken]." This shows the conversation actually had impact, which is far more memorable to the other person than a generic thanks, and makes a future reconnection feel natural rather than out of nowhere.

Recap: a specific, timely thank-you that references something particular from the conversation closes the loop well, and genuine periodic staying-in-touch (not just when you need something) is what actually builds a lasting professional relationship out of a single conversation.',
   3);

-- personal-branding-and-linkedin-basics
insert into lessons (id, skill_id, content_type, content_body, order_index) values
  ('00000000-0000-0000-0002-000000921802', '00000000-0000-0000-0001-000000000218', 'article',
   'A LinkedIn summary is often left blank or filled with generic language ("passionate, hardworking team player") because it feels harder to write than a resume bullet — there''s no fixed template — but a genuine, specific summary is one of the highest-leverage pieces of the whole profile precisely because so few people write one well, making a good one stand out by comparison alone.

A useful structure: one or two sentences on your current focus or background, one or two sentences on what you''re specifically working toward or interested in, and optionally a sentence inviting the kind of connection or conversation you''re open to — written in first person, in your own voice, rather than a resume-style list of skills with no personality.

Worked example: a weak summary reads, "Hardworking and detail-oriented student passionate about finance." A stronger one, for the same person: "Finance student currently building financial modeling skills through coursework and a student investment club, where I help evaluate potential portfolio holdings. Interested in equity research and always happy to connect with others exploring similar paths — feel free to reach out if you''re working on something similar." The second is specific, shows genuine current activity, and invites connection — the first could describe almost anyone.

Recap: a genuine, specific LinkedIn summary — current focus, what you''re working toward, and an invitation to connect — stands out precisely because most profiles either skip it or fill it with generic language; writing it in your own voice, with real specifics, is worth the extra effort a fixed-template resume bullet doesn''t require.',
   2),
  ('00000000-0000-0000-0002-000000921803', '00000000-0000-0000-0001-000000000218', 'article',
   'Beyond the headline and summary, ongoing LinkedIn activity — not just a static, complete profile — plays a real role in how visible and credible a personal brand becomes over time, since a profile that''s never updated or engaged with signals inactivity in a way that can undercut even a well-written summary. This doesn''t require posting frequently or performing enthusiasm; a small amount of genuine, low-effort activity is usually enough to stay visibly active.

Useful low-effort habits: updating the profile promptly after a real accomplishment (a new project, a completed certificate, a role change) rather than letting it go stale for months or years; occasionally commenting thoughtfully on a post relevant to your field, which is lower-effort and often more genuine than writing original posts; and connecting with people you''ve actually met or had a real conversation with, rather than mass-connecting with strangers, which keeps your network meaningful rather than just large.

Worked example: after completing a relevant course or finishing a significant class project, updating the profile the same week — rather than "getting to it eventually" — keeps the profile an accurate, current reflection of real activity, which matters more to someone reviewing it than an impressively long but stale list of things from years ago.

Recap: a personal brand benefits from small, genuine ongoing activity — prompt updates after real accomplishments, occasional thoughtful engagement, and connecting with people you''ve actually met — more than from a one-time, perfectly polished but then-abandoned profile.',
   3);

-- benefits-enrollment-basics
insert into lessons (id, skill_id, content_type, content_body, order_index) values
  ('00000000-0000-0000-0002-000000921902', '00000000-0000-0000-0001-000000000219', 'article',
   'Estimating an FSA contribution accurately is a genuinely tricky forecasting problem, since it requires predicting a full year of medical and dependent-care expenses in advance, before the plan year even starts — which is exactly why the "use it or lose it" risk matters so much. A useful approach is starting conservative in your first year at a new employer (since you don''t yet have your own historical spending data at this specific job''s benefit levels), then adjusting the following year based on what you actually spent.

Most FSA plans do allow a small grace period or limited carryover (commonly up to a modest capped amount, though this varies by employer and plan year), which somewhat softens the risk of a small miscalculation — but relying on this buffer as a planning strategy, rather than as a safety margin for genuine uncertainty, defeats the purpose of estimating carefully in the first place.

Worked example: a first-year employee unsure of their exact annual eligible medical spending elects a conservative FSA amount covering only clearly predictable costs (routine prescriptions, known upcoming appointments) rather than guessing high to "be safe" — guessing high is actually the riskier direction under use-it-or-lose-it rules, since underestimating just means paying a bit more out of pocket, while overestimating risks forfeiting real money.

Recap: FSA elections require forecasting a full year of expenses in advance under forfeiture risk — starting conservative in year one, adjusting with real data afterward, and treating any grace-period carryover as a safety margin rather than a planning crutch, all reduce the risk of losing contributed money.',
   2),
  ('00000000-0000-0000-0002-000000921903', '00000000-0000-0000-0001-000000000219', 'article',
   'Beyond health-related accounts, an open enrollment window often includes other benefit elections that are easy to overlook because they''re less immediately visible than health insurance — life insurance beyond a small employer-provided base amount, short- and long-term disability insurance, and sometimes legal or identity-theft protection plans. These are worth at least a deliberate yes-or-no decision each year rather than defaulting to whatever was selected (or not selected) previously without reconsidering.

Disability insurance in particular is often underweighted by younger employees who reasonably feel healthy and low-risk, but it protects against a genuinely significant financial risk — an inability to work due to illness or injury — that health insurance alone doesn''t cover, since health insurance pays for care but doesn''t replace lost income while you''re unable to work.

Worked example: an employer offers a small amount of free basic life insurance automatically, plus the option to purchase additional supplemental life and long-term disability coverage at group rates, often cheaper than buying equivalent coverage individually. An employee who never opens the supplemental options because they assumed the free basic amount was "the benefit" may be underinsured against a real risk, particularly if they have dependents who rely on their income.

Recap: open enrollment often includes benefits beyond health insurance — disability and supplemental life insurance in particular are easy to overlook but protect against real financial risks health insurance alone doesn''t cover, and are frequently available at cheaper group rates than buying equivalent coverage individually.',
   3);

-- credit-cards-and-building-credit
insert into lessons (id, skill_id, content_type, content_body, order_index) values
  ('00000000-0000-0000-0002-000000922002', '00000000-0000-0000-0001-000000000220', 'article',
   'Choosing a first credit card is itself a decision worth some care, since not every card is equally suited to someone building credit for the first time — cards marketed toward established, high-income customers often require a longer credit history to be approved for at all, while cards specifically designed for first-time or limited-history applicants (student cards, secured cards) exist precisely to solve this chicken-and-egg problem.

A secured credit card, which requires a cash deposit that typically becomes your credit limit, is a common and reliable starting point for someone with no credit history at all, since it removes the lender''s main risk (you defaulting on money you were never given in the first place) while still reporting your payment activity to credit bureaus the same way an unsecured card does.

Annual fees and rewards programs, while worth knowing about, matter far less for a first card than reliable, on-time payment and low utilization — a card with a small annual fee but that genuinely helps someone build credit responsibly is a better first choice than a flashy rewards card that encourages overspending to chase points.

Worked example: someone with no credit history applies for a general rewards card and is rejected due to insufficient credit history, then successfully opens a secured card with a $500 deposit as their limit — used carefully (small purchases, paid in full monthly) for 6-12 months, this typically builds enough credit history to later qualify for an unsecured card with better terms.

Recap: a first card should prioritize accessibility and building payment history over rewards or fees — secured or student cards exist specifically to solve the no-history problem, and consistent, careful use of one typically opens the door to better unsecured cards later.',
   2),
  ('00000000-0000-0000-0002-000000922003', '00000000-0000-0000-0001-000000000220', 'article',
   'Beyond the two core habits (on-time payment, low utilization), a few less obvious factors also shape a credit score over time and are worth understanding, particularly because some of the intuitive-seeming actions actually hurt rather than help. Length of credit history matters — an older account, even one rarely used, generally helps a score, which is why closing your very first credit card once you get a "better" one can actually lower your score by shortening your average account age and reducing total available credit (which raises overall utilization even if spending hasn''t changed).

Applying for several new cards in a short window also has a real, if usually temporary, negative effect (each application typically triggers a "hard inquiry" that dings the score slightly), which is why deliberately spacing out new credit applications rather than applying for several at once — even if each individually looks appealing — is generally the safer approach.

Worked example: someone who opens a first card at 18, then a second, better rewards card at 22, and considers closing the first card since they rarely use it, is often better off keeping the first card open with occasional small use, purely for the credit-history-length and available-credit benefits — closing it would shorten their average account age and reduce total available credit, both working against their score even though the change feels like simplifying their finances.

Recap: length of credit history and the number of accounts both matter beyond the two core habits — closing your oldest card can hurt your score by shortening account age and reducing available credit, and applying for several new cards in a short window triggers multiple hard inquiries — both worth understanding before making a change that feels intuitively like a simplification.',
   3);

-- student-loan-repayment-basics
insert into lessons (id, skill_id, content_type, content_body, order_index) values
  ('00000000-0000-0000-0002-000000922102', '00000000-0000-0000-0001-000000000221', 'article',
   'Beyond choosing a repayment plan, several federal loan programs (in the US context) offer forgiveness or discharge under specific conditions — most notably Public Service Loan Forgiveness (PSLF) for those working in qualifying government or nonprofit roles after 10 years of qualifying payments — worth knowing about early, since eligibility depends on choices made from the start (the right repayment plan type, the right employer type), not something you can necessarily set up retroactively after years of payments on a plan that doesn''t qualify.

A common and costly mistake is refinancing federal loans into a private loan to get a lower interest rate, without realizing that federal loans carry protections (income-driven plans, deferment options, forgiveness program eligibility) that are permanently lost once refinanced into a private loan — a private refinance can be the right choice for someone with a stable, well-paying job and no interest in these protections, but it''s a one-way door worth understanding fully before taking.

Worked example: someone eligible for PSLF who accepts a lower-rate private refinance offer to save on interest permanently loses PSLF eligibility for that loan, potentially forfeiting complete forgiveness of a much larger remaining balance after 10 years of qualifying nonprofit employment — the near-term interest savings could be dramatically outweighed by the lost forgiveness, depending on their career path.

Recap: federal loan protections (income-driven plans, forgiveness programs like PSLF) require choices made from early in repayment, and refinancing into a private loan permanently forfeits these protections — understanding whether you might realistically use them (based on likely career path) before refinancing for a lower rate avoids a costly, irreversible mistake.',
   2),
  ('00000000-0000-0000-0002-000000922103', '00000000-0000-0000-0001-000000000221', 'article',
   'Making extra payments beyond the required minimum is a powerful way to reduce total interest paid, but doing it correctly requires understanding a detail many borrowers miss: how a loan servicer applies an extra payment by default. Without explicit instruction, some servicers apply extra payments toward future scheduled payments (effectively "pre-paying" and buying time before the next payment is due) rather than directly reducing the principal balance — the second is what actually saves meaningful interest, so the two outcomes are not equivalent even though the total dollars paid are the same.

Most servicers allow borrowers to explicitly designate an extra payment as "principal-only" through their online portal or by written instruction, and confirming this designation each time (some servicers reset the default behavior) is the step that actually captures the interest savings intended.

Worked example: a borrower making an extra $100 payment without specifying principal-only might find their servicer applied it toward next month''s payment instead — technically "ahead" on payments, but with the same principal balance and same total interest still accruing as before. The same $100, explicitly designated principal-only, directly reduces the balance the loan accrues interest on going forward, meaningfully shortening the loan and reducing total interest paid over its life.

Recap: extra payments only meaningfully reduce total interest paid if explicitly designated principal-only — without that designation, some servicers apply extra payments toward future scheduled payments instead, which doesn''t reduce the balance interest accrues on nearly as effectively.',
   3);

-- workplace-communication-and-professionalism
insert into lessons (id, skill_id, content_type, content_body, order_index) values
  ('00000000-0000-0000-0002-000000922202', '00000000-0000-0000-0001-000000000222', 'article',
   'Written communication carries specific risks spoken conversation doesn''t — tone is easy to misread in a short message with no vocal inflection or facial expression to soften it, and a written record persists in a way a hallway conversation doesn''t. This makes a brief pause before sending a message written while frustrated genuinely valuable, since a message that felt appropriately direct while writing it can read as sharper or more combative than intended once received without the writer''s actual tone attached.

A useful habit for a message you''re unsure about: reading it back as if you were the recipient, with no context on your mood while writing it, and asking whether it would land as intended. For anything with real stakes or nuance, defaulting to a quick call or in-person conversation instead of a written message avoids the tone-reading risk entirely, even though it takes more initial effort to set up.

Worked example: a written message sent quickly while frustrated — "This needs to be fixed today, we can''t keep missing deadlines" — can read as sharper than intended once separated from the writer''s actual tone of voice. A brief pause and a small rewrite — "Can we prioritize fixing this today? We''ve missed a couple deadlines recently and I want to get ahead of it before it becomes a bigger issue" — communicates the same underlying urgency with a tone far less likely to be read as combative.

Recap: written messages lose vocal tone and persist as a record, both of which raise the stakes of how something is phrased — a brief pause before sending a message written while frustrated, and defaulting to a call or in-person conversation for anything high-stakes or nuanced, both reduce the risk of being misread.',
   2),
  ('00000000-0000-0000-0002-000000922203', '00000000-0000-0000-0001-000000000222', 'article',
   'Professionalism also shows up in smaller, easy-to-overlook habits around meetings and commitments — showing up on time (or a few minutes early), coming prepared with any requested materials reviewed in advance, and following through on action items you agreed to without needing repeated reminders. None of these individually seem significant, but consistently doing them (or consistently failing to) is one of the clearest signals colleagues and managers use to judge reliability, often more than any single dramatic success or failure.

When you can''t follow through on something as originally agreed — a deadline slips, you realize you misunderstood a task — communicating that proactively, before you''re asked, is far better received than staying silent and hoping it resolves itself or is worked around unnoticed. A short, honest heads-up ("I''m not going to make the original deadline on X — here''s why, and here''s my new estimate") preserves trust far better than silence followed by a missed deadline discovered after the fact.

Worked example: a new analyst realizes a task will take longer than the estimate they gave their manager two days ago. Rather than staying quiet and hoping to catch up unnoticed, they proactively message: "Wanted to flag early — this is taking longer than I estimated because of [specific reason]. I now expect to finish by [new date]. Let me know if that''s a problem for anything downstream." This costs a moment of discomfort but protects trust far more than silence followed by a missed deadline.

Recap: small, consistent habits — punctuality, preparation, following through without reminders — build reliability over time more than any single success or failure, and proactively communicating when you can''t follow through as originally agreed preserves trust far better than silence.',
   3);

-- case-study-practice
insert into lessons (id, skill_id, content_type, content_body, order_index) values
  ('00000000-0000-0000-0002-000000922302', '00000000-0000-0000-0001-000000000223', 'article',
   'Case studies work best when you treat the scenario as a container for multiple lessons you''ve already learned, rather than a brand-new topic requiring brand-new knowledge — the skill being tested is recognizing which prior lessons apply to which part of the scenario, and connecting them, not learning something entirely new in the moment.

A useful habit when reading a case scenario for the first time: before jumping to the questions, mentally (or on scratch paper) list which concepts from earlier lessons seem relevant just from the scenario description alone — compensation structure, negotiation, tax withholding, credit, whatever seems to apply — before you''ve even seen what''s being asked. This primes you to recognize the relevant concept quickly once you do read each question, rather than searching from scratch under time pressure.

Worked example: a case scenario describing two competing job offers, one with higher base salary and one with equity and better benefits, should immediately bring to mind several earlier lessons even before reading the specific questions: compensation package basics (comparing total value, not just base), startup equity and stock options (vesting, strike price, speculative value), and possibly negotiation (whether either offer has room to improve). Having already connected these mentally makes each individual question much faster and more confident to answer once you see it.

Recap: read a case scenario first for which prior lessons it seems to draw on, before diving into the specific questions — this primes faster, more confident recognition of which concept each question is actually testing, rather than searching from scratch under time pressure.',
   2),
  ('00000000-0000-0000-0002-000000922303', '00000000-0000-0000-0001-000000000223', 'article',
   'Free-response questions in a case study reward a specific writing habit that differs from how you might naturally write a first draft: leading with your core claim in the first sentence, then supporting it — mirroring the same "headline-first" structure that helps in spoken interview answers. Since grading is keyword-based, a core concept named clearly and early is more reliably credited than the same concept buried in the middle of a longer, more exploratory paragraph.

It also helps to explicitly name concepts using their actual terms ("vesting," "opportunity cost," "utilization") rather than only describing them in your own words without ever naming them directly — both can demonstrate understanding to a human reader, but a keyword-based grader specifically needs the term itself present to credit that concept, so naming it directly is a safer choice than only circling around it descriptively.

Worked example: asked why a candidate should weigh an equity-heavy offer''s true value carefully, a weaker answer might write generally about "the offer maybe not being as good as it looks" without naming any specific concept. A stronger answer states directly: "The equity portion carries real risk because of vesting (you could leave before the cliff and forfeit it) and because options only have value if the share price exceeds the strike price — so I''d weigh the guaranteed cash offer more heavily unless I have strong reason to believe the equity will actually pay off." This names vesting and strike price directly while still reading naturally.

Recap: lead free-response answers with your core claim, and name specific concepts by their actual terms rather than only describing them indirectly — both make your understanding easier to credit, whether by a human reader or keyword-based grading.',
   3);

