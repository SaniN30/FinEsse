-- Job-Ready tier: workplace-readiness content pass. Migrations 29-31 built
-- Job-Ready's interview-prep track (interview fundamentals through advanced
-- behavioral), but the tier had no coverage of what happens *after* landing
-- an offer -- negotiating it, understanding pay/benefits, and managing money
-- once a paycheck starts arriving. This adds 15 new skills covering that gap,
-- at the same lesson/quiz depth pattern as migration 29 (one article lesson +
-- a 4-question quiz per skill, no modeling_exercises -- these are workplace
-- literacy topics, not numeric-build case exercises).
--
-- Chains off 207 (advanced-behavioral-interviews), the top of Job-Ready's
-- existing chain. All content below is written originally for this project;
-- topics are grounded in how real employer HR/benefits onboarding and
-- career-services financial-literacy programs are structured, but no text is
-- copied from any employer, publisher, or career-services office's material.
--
-- Migration numbering: 31 already exists twice on main (seed_capstone_content
-- and student_login_lockout), and 32/33 are in use -- 34 is free as of this
-- migration; check the highest number in use before adding another.

insert into skills (id, tier, slug, title, prerequisite_skill_id, mastery_threshold) values
  ('00000000-0000-0000-0001-000000000208', 'job_ready', 'negotiating-a-job-offer', 'Negotiating a Job Offer',
    '00000000-0000-0000-0001-000000000207', 0.8),
  ('00000000-0000-0000-0001-000000000209', 'job_ready', 'compensation-package-basics', 'Understanding Your Compensation Package',
    '00000000-0000-0000-0001-000000000208', 0.8),
  ('00000000-0000-0000-0001-000000000210', 'job_ready', 'reading-a-pay-stub-and-taxes', 'Reading a Pay Stub & Taxes Withheld',
    '00000000-0000-0000-0001-000000000209', 0.8),
  ('00000000-0000-0000-0001-000000000211', 'job_ready', 'employer-retirement-matching', 'Employer Retirement Matching',
    '00000000-0000-0000-0001-000000000210', 0.8),
  ('00000000-0000-0000-0001-000000000212', 'job_ready', 'health-insurance-basics', 'Health Insurance Basics for Your First Job',
    '00000000-0000-0000-0001-000000000211', 0.8),
  ('00000000-0000-0000-0001-000000000213', 'job_ready', 'workplace-financial-etiquette', 'Workplace Financial Etiquette',
    '00000000-0000-0000-0001-000000000212', 0.8),
  ('00000000-0000-0000-0001-000000000214', 'job_ready', 'budgeting-on-your-first-salary', 'Budgeting on Your First Salary',
    '00000000-0000-0000-0001-000000000213', 0.8),
  ('00000000-0000-0000-0001-000000000215', 'job_ready', 'building-an-emergency-fund', 'Building an Emergency Fund',
    '00000000-0000-0000-0001-000000000214', 0.8),
  ('00000000-0000-0000-0001-000000000216', 'job_ready', 'startup-equity-and-stock-options', 'Startup Equity & Stock Options',
    '00000000-0000-0000-0001-000000000215', 0.8),
  ('00000000-0000-0000-0001-000000000217', 'job_ready', 'professional-networking-basics', 'Professional Networking Basics',
    '00000000-0000-0000-0001-000000000216', 0.8),
  ('00000000-0000-0000-0001-000000000218', 'job_ready', 'personal-branding-and-linkedin-basics', 'Personal Branding & LinkedIn Basics',
    '00000000-0000-0000-0001-000000000217', 0.8),
  ('00000000-0000-0000-0001-000000000219', 'job_ready', 'benefits-enrollment-basics', 'Benefits Enrollment: HSA, FSA & Open Enrollment',
    '00000000-0000-0000-0001-000000000218', 0.8),
  ('00000000-0000-0000-0001-000000000220', 'job_ready', 'credit-cards-and-building-credit', 'Credit Cards & Building Credit as a New Professional',
    '00000000-0000-0000-0001-000000000219', 0.8),
  ('00000000-0000-0000-0001-000000000221', 'job_ready', 'student-loan-repayment-basics', 'Student Loan Repayment Basics',
    '00000000-0000-0000-0001-000000000220', 0.8),
  ('00000000-0000-0000-0001-000000000222', 'job_ready', 'workplace-communication-and-professionalism', 'Workplace Communication & Professionalism',
    '00000000-0000-0000-0001-000000000221', 0.8);

insert into lessons (id, skill_id, content_type, content_body, order_index) values
  ('00000000-0000-0000-0002-000000000208', '00000000-0000-0000-0001-000000000208', 'article',
   'An initial job offer is very rarely a company''s absolute final number -- it is an opening position, and most employers expect a candidate to respond with at least one counter before an offer is finalized. Declining to negotiate at all is itself a choice, and it usually leaves money and terms on the table that the employer had already budgeted for.

The strongest negotiating position comes from research, not bluffing: knowing the realistic market range for the role, level, and location (from sources like published salary surveys, professional networks, or the range the company itself may already be required to disclose) lets you ask for a specific, defensible number rather than an arbitrary one. It also matters to negotiate the whole package, not just base salary -- signing bonus, start date, vacation days, and remote-work flexibility are all frequently negotiable even when base salary has a hard ceiling.

Worked example: an offer arrives at $62,000 base, and your research shows the realistic range for this role/level/location is $60,000-$70,000. A weak approach is to accept immediately, or to ask for "as much as possible" with no anchor. A strong approach: "Thank you for the offer -- I''m excited about the role. Based on my research into the market range for this position, I was hoping we could look at something closer to $68,000. Is there flexibility there?" This names a specific number grounded in research, stays polite and enthusiastic, and leaves room for the employer to respond with their own counter.

Recap: initial offers are usually an opening position, not a final one, so declining to negotiate at all typically leaves value on the table. Ground any counter in real market research so the number is specific and defensible, and remember the whole package -- not just base salary -- is often negotiable.',
   1),
  ('00000000-0000-0000-0002-000000000209', '00000000-0000-0000-0001-000000000209', 'article',
   'A job offer''s headline number is rarely the whole story. A compensation package typically has several components: base salary (fixed, predictable pay), bonus (variable pay tied to individual or company performance, which may be a target percentage rather than a guarantee), equity (an ownership stake, common at startups and some public companies, covered in depth in a later lesson), and benefits (health insurance, retirement matching, paid time off, and similar non-cash value) -- and comparing two offers by base salary alone can be misleading if their other components differ substantially.

A useful habit is estimating each offer''s total value, not just its base: a bonus target should be treated as "up to" that amount rather than guaranteed, since payout often depends on hitting performance targets that aren''t fully in your control; benefits have real monetary value even though they don''t show up in a paycheck (employer-paid health insurance alone can be worth several thousand dollars a year compared to buying an individual plan).

Worked example: Offer A is $70,000 base with no bonus and modest benefits. Offer B is $62,000 base, a 10% target bonus (so up to $6,200, not guaranteed), and an employer that fully covers health insurance premiums worth roughly $6,000/year. On base salary alone, A looks better by $8,000. Accounting for B''s bonus target and benefits value, the total packages are much closer -- close enough that other factors (job content, growth, commute, culture) may matter more than the small remaining gap.

Recap: a compensation package is base + bonus + equity + benefits, not just the headline base number. Treat bonus targets as "up to," not guaranteed, and remember benefits carry real monetary value even though they aren''t paid in cash -- comparing offers on total package, not base alone, avoids a misleading comparison.',
   1),
  ('00000000-0000-0000-0002-000000000210', '00000000-0000-0000-0001-000000000210', 'article',
   'A pay stub shows the difference between "gross pay" (what you earned before any deductions) and "net pay" (what actually lands in your bank account) -- and for a first paycheck, that gap often comes as a surprise if you were only thinking in terms of your quoted annual salary. The deductions in between generally fall into two groups: taxes withheld (money the government requires your employer to hold back and send on your behalf) and voluntary deductions (things you elected, like retirement contributions or a share of health insurance premiums).

Tax withholding is not the final tax bill -- it is an estimate, based on the information you provided (like a W-4 in the US), of what you''ll likely owe; if too much was withheld across the year you get a refund, and if too little was withheld you owe more when you file. This is why a pay stub''s tax line is best understood as "an estimated prepayment," not a fixed fee -- and why life changes (a raise, a second job, marriage) can change how much should be withheld going forward.

Worked example: a pay stub shows gross pay of $2,500 for the pay period, with $380 withheld for federal income tax, $155 for payroll taxes (Social Security and Medicare combined, in the US context), $50 for state tax, and $125 voluntarily deducted for a 401(k) contribution -- net pay is $2,500 - $380 - $155 - $50 - $125 = $1,790. Someone expecting to receive their full "$2,500 paycheck" and budgeting against that number, instead of the $1,790 that actually arrives, will consistently overspend.

Recap: gross pay is what you earned; net pay, after mandatory tax withholding and any voluntary deductions, is what you actually receive -- budget against net pay, not the headline salary. Tax withholding is an estimated prepayment reconciled at tax-filing time, not your final tax bill.',
   1),
  ('00000000-0000-0000-0002-000000000211', '00000000-0000-0000-0001-000000000211', 'article',
   'Many employers offer a retirement plan (like a 401(k) in the US, or a workplace pension elsewhere) where you can contribute a portion of each paycheck, often before tax, into an investment account for retirement. The key feature that makes this different from ordinary saving is employer matching: many employers will contribute additional money of their own, up to some limit, based on how much you contribute -- a common structure is "matching 50% of your contribution, up to 6% of your salary."

Not contributing enough to capture the full employer match is often described as leaving free money on the table, because the match is compensation the employer is willing to pay only if you also contribute -- skipping it isn''t a neutral choice, it''s giving up guaranteed additional pay. Beyond the match itself, contributions in these accounts usually also grow tax-advantaged, meaning the growth compounds without being taxed each year the way an ordinary brokerage account''s gains might be.

Worked example: Priya earns $50,000/year and her employer matches 50% of her contributions up to 6% of salary. If Priya contributes 6% ($3,000/year), her employer adds 50% of that ($1,500/year) -- a total of $4,500/year going into her retirement account for a $3,000 outlay from her own paycheck. If Priya instead contributes only 2% ($1,000/year), she only receives a 50% match on that amount ($500), leaving $1,000 of potential employer match unclaimed each year she under-contributes.

Recap: an employer retirement match is additional compensation contingent on your own contribution -- contributing less than the full matched amount means turning down guaranteed extra pay, on top of missing out on tax-advantaged growth. Check your specific plan''s match formula and, budget allowing, aim to contribute at least enough to capture it in full.',
   1),
  ('00000000-0000-0000-0002-000000000212', '00000000-0000-0000-0001-000000000212', 'article',
   'Employer-provided health insurance usually offers a choice between a few plans, and the two numbers that matter most when comparing them are the premium (what you pay regularly, usually deducted from each paycheck, regardless of whether you use care) and the deductible (what you must pay out of pocket for care before the insurance starts covering a larger share) -- plans with a lower premium typically have a higher deductible, and vice versa, so the "cheaper-looking" plan on premium alone isn''t automatically the cheaper choice overall.

The right plan depends on expected usage: someone who rarely needs medical care and wants to minimize the guaranteed monthly cost may prefer a low-premium, high-deductible plan; someone who expects regular care (an ongoing condition, planned procedures, a family) may come out ahead paying a higher premium for a lower deductible, since they''re more likely to actually hit and benefit from that lower out-of-pocket ceiling.

Worked example: Plan A costs $50/month premium with a $3,000 deductible; Plan B costs $150/month premium with a $500 deductible. Over a year with no major medical needs, Plan A costs $600 in premiums and Plan B costs $1,800 -- Plan A wins by $1,200. But if a $4,000 medical expense occurs, Plan A costs $600 (premiums) + $3,000 (deductible) = $3,600 before insurance covers the rest, while Plan B costs $1,800 (premiums) + $500 (deductible) = $2,300 -- Plan B wins by $1,300 once the deductible is actually hit.

Recap: compare health plans on premium and deductible together, not premium alone -- lower premium usually means higher deductible. The right choice depends on how much medical care you realistically expect to use in a given year, not just which plan has the smallest number on the paycheck.',
   1),
  ('00000000-0000-0000-0002-000000000213', '00000000-0000-0000-0001-000000000213', 'article',
   'Many jobs involve spending company money on the company''s behalf -- a client dinner, travel for a conference, supplies for a project -- and most employers have specific expectations for how that spending should be documented and requested for reimbursement, generally called an expense report. Submitting an expense report usually requires an itemized receipt (not just a credit card statement showing the total), a stated business purpose, and submission within a defined window after the expense occurred -- missing any of these is a common reason reimbursements get delayed or denied.

A per diem is a related but different concept: a fixed daily allowance for expenses like meals during travel, given in place of requiring itemized receipts for every small purchase. Per diems simplify reporting, but spending is still expected to stay reasonable and business-related -- treating an unusually generous per diem amount as personal spending money, or submitting expenses that mix personal and business purchases without separating them clearly, is a fast way to damage trust with a manager or finance team, even if the dollar amounts involved are small.

Worked example: after a work conference, one employee submits an itemized list -- hotel ($220/night x 2 nights, receipt attached), one client dinner ($85, business purpose noted: "dinner with prospective client, discussed Q3 partnership"), and taxi receipts -- within the company''s 30-day window. A colleague instead submits a single vague line, "conference expenses, $650," with no receipts and no explanation, six weeks after returning. The first is straightforward to approve; the second creates unnecessary friction and signals carelessness with company funds, regardless of whether either amount was fully legitimate.

Recap: business expense reimbursement generally requires itemized receipts, a clear stated purpose, and timely submission; per diems simplify reporting but still assume reasonable, business-related spending. Careful, well-documented expense reporting is a low-cost way to build trust with a manager or finance team early in a role.',
   1),
  ('00000000-0000-0000-0002-000000000214', '00000000-0000-0000-0001-000000000214', 'article',
   'A first "real" salary often feels like a large jump from student or part-time income, which makes it easy to scale up spending immediately to match the new gross number -- a pattern sometimes called lifestyle inflation. Building a budget around net pay (what actually arrives after taxes and deductions, covered in an earlier lesson) rather than the headline salary figure is the first correction; the second is deciding, deliberately, how much of that net pay goes to fixed obligations, discretionary spending, and savings, rather than letting whatever''s left over at month''s end define savings by default.

A commonly cited starting framework is allocating roughly 50% of net pay to needs (rent, groceries, utilities, minimum debt payments), 30% to wants (discretionary spending), and 20% to savings and extra debt paydown -- not a rigid rule, since cost of living varies enormously by location, but a useful starting point to check a budget against rather than building one from nothing.

Worked example: on $3,200/month net pay, a 50/30/20 split suggests roughly $1,600 for needs, $960 for wants, and $640 for savings/extra debt paydown. Someone who instead signs a lease at $1,400/month (44% of net pay on rent alone) and finances a car payment on top has likely committed a large share of their "needs" and "wants" budget to fixed costs before even looking at groceries, utilities, or savings -- worth checking against the framework before signing, not after.

Recap: budget against net pay, not headline salary, and decide savings and discretionary spending deliberately rather than by default. A 50/30/20 (needs/wants/savings) split is a useful starting benchmark to check a first budget against, adjusted for real cost of living.',
   1),
  ('00000000-0000-0000-0002-000000000215', '00000000-0000-0000-0001-000000000215', 'article',
   'An emergency fund is money set aside specifically for unplanned, necessary expenses -- a job loss, a medical bill, an urgent car repair -- kept separate from everyday spending and savings goals so it isn''t accidentally spent on something else. Its purpose is to prevent an unplanned expense from forcing high-interest debt (like a credit card balance carried month to month) or derailing longer-term savings goals that were meant for something else entirely.

A commonly cited target is 3-6 months of essential expenses (not full income -- essential expenses like rent, food, utilities, and minimum debt payments), with the exact number depending on job stability and other safety nets: someone with a very stable job and family financial support might reasonably target the lower end, while someone with variable income or no other safety net might target the higher end or beyond. The fund is usually kept somewhere accessible and low-risk (like a savings account) rather than invested in something that could lose value right when it''s needed.

Worked example: Marcus''s essential monthly expenses (rent, food, utilities, minimum debt payments) total $1,800. A 3-month target is $5,400; a 6-month target is $10,800. Marcus starts with $0 and decides to build the fund gradually by automatically transferring $200/month -- at that rate, reaching the 3-month target takes 27 months. Building it faster (by temporarily redirecting some discretionary spending) shortens that runway, but the framework itself -- essential expenses x months of target coverage -- is what defines the goal either way.

Recap: an emergency fund is separate, accessible savings sized to essential expenses (not full income) that exists specifically to absorb unplanned costs without forcing high-interest debt or derailing other goals. 3-6 months of essential expenses is a common starting target, adjusted up or down based on job stability and other safety nets.',
   1),
  ('00000000-0000-0000-0002-000000000216', '00000000-0000-0000-0001-000000000216', 'article',
   'Startups sometimes offer equity -- typically stock options -- as part of a compensation package, especially when cash salary is lower than a comparable role at an established company. A stock option gives you the right (not the obligation) to buy company shares later at a fixed price set now (the "strike price"), which only has value if the company''s share price rises above that strike price by the time you exercise -- if it never does, the options are simply worth nothing, unlike a cash bonus which is guaranteed once earned.

Two concepts determine how much of that equity you actually get to keep: vesting (you earn the right to the options gradually over time, commonly over 4 years with a 1-year "cliff" before any of it vests, so leaving before the cliff typically forfeits all unvested equity) and dilution (as a startup raises more funding rounds and issues more shares, each existing share -- including yours -- represents a smaller percentage of the company, even though the number of shares you hold doesn''t change). Because most startups fail or are acquired for modest amounts, most employee equity grants end up worth little or nothing -- equity is reasonably treated as a lottery-ticket-like upside, not a reliable substitute for guaranteed cash compensation.

Worked example: an offer includes 10,000 options with a $1 strike price, vesting over 4 years with a 1-year cliff. If the company is later valued such that shares are worth $5 each, and all 10,000 have vested, the options'' value is 10,000 x ($5 - $1) = $40,000 before taxes -- but if the company''s share price never exceeds $1, or the company fails before any shares vest, that $40,000 estimate is worth $0 in practice, and someone who left after 8 months (before the 1-year cliff) would have forfeited the entire grant regardless of outcome.

Recap: stock options only have value if the share price rises above the strike price, and vesting schedules (commonly 4 years with a 1-year cliff) determine how much equity you actually keep if you leave early. Because most startup equity ends up worth little, it''s reasonable to value equity as speculative upside on top of cash compensation, not a substitute for it.',
   1),
  ('00000000-0000-0000-0002-000000000217', '00000000-0000-0000-0001-000000000217', 'article',
   'Professional networking is often misunderstood as asking strangers for favors, which is exactly why it feels uncomfortable to most people starting out -- but the more accurate framing is building genuine, mutually useful professional relationships over time, most of which never involve directly asking for anything. The single most effective and lowest-pressure form of networking for someone early in their career is the informational interview: a short conversation requesting someone''s perspective on their role, field, or path, explicitly not asking for a job -- a low-stakes ask that most professionals are willing to grant, since it costs them little and doesn''t put them on the spot to make a hiring decision.

A useful habit is following up and staying in touch after an initial conversation, rather than treating each contact as a one-time transaction -- sharing a relevant article, congratulating someone on a role change, or simply reconnecting a year later keeps a relationship genuinely alive instead of making every future message feel like a cold, favor-seeking ask.

Worked example: a student interested in a field messages a alum on LinkedIn: "Hi [Name], I saw you work in [field] at [Company] -- I''m a student exploring this path and would love to hear about your experience, if you have 15 minutes for a quick call sometime in the next few weeks. No pressure at all if you''re busy!" This is specific, time-bounded, low-pressure, and asks for perspective rather than a job or favor -- a much higher response rate than a vague "can we connect?" message with no clear ask.

Recap: networking is primarily about building genuine professional relationships, not transactional favor requests -- the informational interview (asking for perspective, not a job) is a low-pressure, effective way to start. Following up and staying in touch over time turns a single conversation into an actual relationship rather than a one-off ask.',
   1),
  ('00000000-0000-0000-0002-000000000218', '00000000-0000-0000-0001-000000000218', 'article',
   'A personal brand, in a career context, is simply the consistent impression your public professional presence creates -- what someone learns about you from a LinkedIn profile, a resume, or a quick search before or after meeting you. For most early-career professionals, LinkedIn is the highest-leverage piece of that presence, since recruiters and professional contacts frequently check it, and an incomplete or generic profile undersells someone who may otherwise be a strong candidate.

A few concrete elements do most of the work: a clear, specific headline (not just a job title, but what you actually do or are looking for), a summary that states your background and goals in your own voice rather than a bare list of skills, and experience entries written the same way strong resume bullets are (context, action, measurable result, covered in an earlier lesson) rather than copy-pasted job descriptions. Consistency matters too -- the story your resume, LinkedIn, and interview answers tell about your experience should line up, since discrepancies (dates that don''t match, different framings of the same role) are a quiet red flag to anyone checking closely.

Worked example: a weak LinkedIn headline reads "Student at University." A stronger one, for the same person, reads "Finance Student | Aspiring Equity Research Analyst | Building financial modeling skills through coursework and independent projects." The second gives a reader immediate, specific context about who this person is and what they''re working toward -- exactly what a recruiter skimming dozens of profiles needs to decide whether to look further.

Recap: personal brand is the consistent impression your public professional presence creates, and LinkedIn is usually the highest-leverage piece of it for an early-career professional. A specific headline, a genuine summary, and resume-quality experience bullets do most of the work -- and keeping your resume, LinkedIn, and interview story consistent avoids quiet red flags.',
   1),
  ('00000000-0000-0000-0002-000000000219', '00000000-0000-0000-0001-000000000219', 'article',
   'Open enrollment is a defined annual window (outside of which most benefit elections are locked in, barring a qualifying life event like marriage or a new child) where employees choose or change their benefit elections for the coming year -- health plan, and often optional accounts like an HSA or FSA. Missing this window without a qualifying life event usually means being stuck with default or prior-year elections for a full year, which makes understanding the choices in advance more valuable than reacting to them in the moment.

An HSA (Health Savings Account, available with certain high-deductible health plans) and an FSA (Flexible Spending Account) both let you set aside pre-tax money for medical expenses, but they behave differently: an HSA''s balance is yours permanently and rolls over indefinitely, and can even be invested for growth, while a standard FSA''s balance typically must be used within the plan year or a short grace period, or it is forfeited ("use it or lose it") -- which makes FSA contribution amounts worth estimating carefully rather than maximizing by default.

Worked example: someone enrolled in a high-deductible plan contributes $2,000 to an HSA and only uses $600 in medical expenses that year -- the remaining $1,400 stays theirs, rolling over into next year and beyond. A colleague on a standard plan contributes $2,000 to an FSA expecting similar usage but only incurs $600 in eligible expenses -- under typical FSA rules, most or all of the unused $1,400 is forfeited at year-end, since FSA funds don''t carry over the way an HSA''s do.

Recap: open enrollment is a defined annual window for benefit elections, generally locked in outside a qualifying life event -- worth understanding choices before the window, not during it. HSA balances are permanent and roll over indefinitely; standard FSA balances are typically "use it or lose it" within the plan year, so contribution amounts deserve more careful estimation.',
   1),
  ('00000000-0000-0000-0002-000000000220', '00000000-0000-0000-0001-000000000220', 'article',
   'A credit score is a number summarizing how reliably you''ve repaid borrowed money in the past, and it affects far more than just credit card approvals -- it can influence apartment applications, car loan interest rates, and sometimes even job applications in finance-adjacent roles. For someone with little or no credit history, a first credit card, used carefully, is one of the most common ways to start building that history -- but the same card used carelessly is also one of the most common ways early-career professionals damage their credit.

Two habits matter most: paying the full statement balance every month, on time (carrying a balance means paying interest, often 20%+ APR, on top of not reducing the underlying debt as fast as it appears), and keeping credit utilization (the share of your available credit limit you''re actually using) low, since a high utilization ratio -- even if you pay it off in full every month -- can itself lower your score if measured at the wrong moment in the billing cycle. Missing a payment, even by a few days, is typically the single most damaging action to a credit score, since payment history carries more weight than almost any other factor.

Worked example: someone with a $2,000 credit limit spends $1,800 one month (90% utilization) and pays it off in full by the due date -- no interest is charged, but the high utilization ratio can still temporarily lower their score if the card issuer reports that high balance to credit bureaus before the payment posts. Spreading the same spending more evenly, or paying down the balance before the statement closes, keeps reported utilization lower without changing actual spending or debt levels at all.

Recap: a credit score reflects repayment reliability and affects more than just credit approvals. Paying the full balance on time every month avoids interest and protects payment history (the most heavily weighted factor), and keeping reported credit utilization low -- even when paying in full -- helps protect the score further.',
   1),
  ('00000000-0000-0000-0002-000000000221', '00000000-0000-0000-0001-000000000221', 'article',
   'Student loans typically come with a grace period (often around 6 months) after graduation before repayment begins, which is valuable time to understand your specific loans -- balance, interest rate, and repayment options -- before payments are due, rather than figuring it out under pressure once the first bill arrives. Loans generally fall into two broad categories with very different flexibility: federal loans (in the US context), which usually offer multiple repayment plan options and, in some cases, income-driven plans that adjust the required payment based on income; and private loans, which typically have far less flexibility and fewer built-in options if your income is lower than expected after graduation.

A standard repayment plan pays off the loan over a fixed period (often 10 years) with a fixed monthly payment; an income-driven plan instead sets the payment as a percentage of discretionary income, which can substantially lower the required payment in early career years but usually extends the total repayment period and the total interest paid over the life of the loan -- a genuine trade-off between lower near-term payments and higher total cost, not a free upgrade.

Worked example: a $30,000 federal loan balance at 5% interest, on a standard 10-year plan, has a fixed monthly payment of roughly $320 and a defined payoff date. The same balance on an income-driven plan tied to a modest starting salary might require a payment closer to $150/month -- more affordable immediately, but because less principal is paid down each month, the loan takes longer to pay off and accrues more total interest over its life, unless the borrower later increases payments once income rises.

Recap: understand your specific loans (balance, rate, and options) during the grace period, before the first payment is due. Standard plans have fixed, higher payments over a shorter period; income-driven plans lower near-term payments but usually extend total repayment time and total interest paid -- a real trade-off to weigh deliberately, not an automatic better choice.',
   1),
  ('00000000-0000-0000-0002-000000000222', '00000000-0000-0000-0001-000000000222', 'article',
   'Workplace communication norms are usually never explicitly taught, which makes them easy to get wrong early in a career -- things like how quickly to respond to messages, how to phrase disagreement with a manager''s decision, or when a quick message is appropriate versus when a topic deserves a scheduled conversation. A generally reliable default is matching the tone and channel your team already uses (formal email versus quick chat messages, for instance) rather than assuming your prior context (school, a previous internship) transfers directly, since norms vary meaningfully between workplaces.

Disagreeing professionally is a specific skill worth practicing deliberately: stating a concern clearly and with reasoning, rather than either staying silent about a real problem or pushing back in a way that reads as combative, tends to be received far better -- and doing it privately with the relevant person first, rather than raising a disagreement in a larger group setting, generally preserves the relationship even when the disagreement itself is unresolved.

Worked example: a new analyst disagrees with a manager''s proposed approach to a task. A weak response is staying silent despite a real concern, letting a preventable problem happen. An equally weak response is pushing back sharply in a team meeting: "That approach doesn''t make sense." A stronger response, said privately: "I want to flag a concern with this approach before we move forward -- [specific reasoning]. Would it help if I put together an alternative to compare, or is there context I''m missing on why this approach was chosen?" This raises the concern clearly, offers to help rather than just criticize, and leaves room for the manager to explain context the analyst might not have.

Recap: workplace communication norms (response speed, channel choice, tone) vary by team and are rarely stated outright, so observing and matching your specific team is a safer default than assuming prior context transfers. Disagreeing professionally means raising a clear, reasoned concern privately with the relevant person, rather than staying silent or pushing back combatively in a group setting.',
   1);

insert into quizzes (id, skill_id, lesson_id, title, pass_threshold) values
  ('00000000-0000-0000-0003-000000000208', '00000000-0000-0000-0001-000000000208', '00000000-0000-0000-0002-000000000208', 'Negotiating a Job Offer Quiz', 0.8),
  ('00000000-0000-0000-0003-000000000209', '00000000-0000-0000-0001-000000000209', '00000000-0000-0000-0002-000000000209', 'Understanding Your Compensation Package Quiz', 0.8),
  ('00000000-0000-0000-0003-000000000210', '00000000-0000-0000-0001-000000000210', '00000000-0000-0000-0002-000000000210', 'Reading a Pay Stub & Taxes Withheld Quiz', 0.8),
  ('00000000-0000-0000-0003-000000000211', '00000000-0000-0000-0001-000000000211', '00000000-0000-0000-0002-000000000211', 'Employer Retirement Matching Quiz', 0.8),
  ('00000000-0000-0000-0003-000000000212', '00000000-0000-0000-0001-000000000212', '00000000-0000-0000-0002-000000000212', 'Health Insurance Basics Quiz', 0.8),
  ('00000000-0000-0000-0003-000000000213', '00000000-0000-0000-0001-000000000213', '00000000-0000-0000-0002-000000000213', 'Workplace Financial Etiquette Quiz', 0.8),
  ('00000000-0000-0000-0003-000000000214', '00000000-0000-0000-0001-000000000214', '00000000-0000-0000-0002-000000000214', 'Budgeting on Your First Salary Quiz', 0.8),
  ('00000000-0000-0000-0003-000000000215', '00000000-0000-0000-0001-000000000215', '00000000-0000-0000-0002-000000000215', 'Building an Emergency Fund Quiz', 0.8),
  ('00000000-0000-0000-0003-000000000216', '00000000-0000-0000-0001-000000000216', '00000000-0000-0000-0002-000000000216', 'Startup Equity & Stock Options Quiz', 0.8),
  ('00000000-0000-0000-0003-000000000217', '00000000-0000-0000-0001-000000000217', '00000000-0000-0000-0002-000000000217', 'Professional Networking Basics Quiz', 0.8),
  ('00000000-0000-0000-0003-000000000218', '00000000-0000-0000-0001-000000000218', '00000000-0000-0000-0002-000000000218', 'Personal Branding & LinkedIn Basics Quiz', 0.8),
  ('00000000-0000-0000-0003-000000000219', '00000000-0000-0000-0001-000000000219', '00000000-0000-0000-0002-000000000219', 'Benefits Enrollment Quiz', 0.8),
  ('00000000-0000-0000-0003-000000000220', '00000000-0000-0000-0001-000000000220', '00000000-0000-0000-0002-000000000220', 'Credit Cards & Building Credit Quiz', 0.8),
  ('00000000-0000-0000-0003-000000000221', '00000000-0000-0000-0001-000000000221', '00000000-0000-0000-0002-000000000221', 'Student Loan Repayment Basics Quiz', 0.8),
  ('00000000-0000-0000-0003-000000000222', '00000000-0000-0000-0001-000000000222', '00000000-0000-0000-0002-000000000222', 'Workplace Communication & Professionalism Quiz', 0.8);

insert into quiz_questions (quiz_id, question, options, correct_answer, order_index) values
  -- Negotiating a Job Offer
  ('00000000-0000-0000-0003-000000000208', 'Per the lesson, is an initial job offer usually a company''s final number?',
    '["Yes, offers are always final and non-negotiable", "No, it is usually an opening position and most employers expect at least one counter", "Only for senior roles, never for entry-level roles", "Only if the offer is below market rate"]'::jsonb,
    'No, it is usually an opening position and most employers expect at least one counter', 1),
  ('00000000-0000-0000-0003-000000000208', 'What gives a counter-offer number credibility, per the lesson?',
    '["Asking for as much as possible with no anchor", "Grounding it in real market research for the role, level, and location", "Only negotiating base salary and nothing else", "Waiting until after accepting to bring it up"]'::jsonb,
    'Grounding it in real market research for the role, level, and location', 2),
  ('00000000-0000-0000-0003-000000000208', 'Besides base salary, what else does the lesson say is frequently negotiable?',
    '["Nothing else is ever negotiable", "Signing bonus, start date, vacation days, and remote-work flexibility", "Only the job title", "Only the company''s stock price"]'::jsonb,
    'Signing bonus, start date, vacation days, and remote-work flexibility', 3),
  ('00000000-0000-0000-0003-000000000208', 'What is a weak negotiating approach, per the lesson?',
    '["Naming a specific number grounded in research", "Accepting immediately or asking for \"as much as possible\" with no anchor", "Staying polite and enthusiastic while countering", "Leaving room for the employer to respond"]'::jsonb,
    'Accepting immediately or asking for "as much as possible" with no anchor', 4),

  -- Understanding Your Compensation Package
  ('00000000-0000-0000-0003-000000000209', 'What four components make up a typical compensation package, per the lesson?',
    '["Base salary, bonus, equity, and benefits", "Base salary, vacation days, title, and office location", "Bonus, equity, commute time, and job title", "Base salary only -- the other terms don''t count as compensation"]'::jsonb,
    'Base salary, bonus, equity, and benefits', 1),
  ('00000000-0000-0000-0003-000000000209', 'Why should a bonus target be treated as "up to" that amount rather than guaranteed?',
    '["Bonuses are always paid in full regardless of performance", "Payout often depends on hitting performance targets not fully in your control", "Bonuses are illegal in most industries", "Bonus targets are always higher than what is actually paid"]'::jsonb,
    'Payout often depends on hitting performance targets not fully in your control', 2),
  ('00000000-0000-0000-0003-000000000209', 'In the worked example, why do Offer A ($70,000 base, no bonus, modest benefits) and Offer B ($62,000 base, 10% target bonus, employer-paid health insurance) end up closer in total value than the base salary gap suggests?',
    '["They don''t end up closer -- Offer A is strictly better", "Offer B''s bonus target and benefits value add real value not captured by base salary alone", "Offer A''s benefits are actually worth more than Offer B''s", "Bonus targets should be ignored entirely when comparing offers"]'::jsonb,
    'Offer B''s bonus target and benefits value add real value not captured by base salary alone', 3),
  ('00000000-0000-0000-0003-000000000209', 'Why can benefits carry real monetary value even though they aren''t paid to you in cash?',
    '["They don''t -- only cash compensation counts", "Because things like employer-paid health insurance premiums have a real cost equivalent if you had to buy them yourself", "Because benefits are taxed at a higher rate than cash", "Because all employers offer identical benefits"]'::jsonb,
    'Because things like employer-paid health insurance premiums have a real cost equivalent if you had to buy them yourself', 4),

  -- Reading a Pay Stub & Taxes
  ('00000000-0000-0000-0003-000000000210', 'What is the difference between gross pay and net pay?',
    '["They are the same thing", "Gross pay is what you earned before deductions; net pay is what actually lands in your account after taxes and deductions", "Gross pay is only for hourly workers; net pay is only for salaried workers", "Net pay is always higher than gross pay"]'::jsonb,
    'Gross pay is what you earned before deductions; net pay is what actually lands in your account after taxes and deductions', 1),
  ('00000000-0000-0000-0003-000000000210', 'Per the lesson, is tax withholding the same as your final tax bill?',
    '["Yes, whatever is withheld is exactly what you owe", "No, it is an estimated prepayment reconciled at tax-filing time", "No, withholding has nothing to do with your final tax bill", "Yes, but only for salaried employees"]'::jsonb,
    'No, it is an estimated prepayment reconciled at tax-filing time', 2),
  ('00000000-0000-0000-0003-000000000210', 'In the worked example, gross pay is $2,500 with $380 federal tax, $155 payroll tax, $50 state tax, and $125 voluntary 401(k) deducted. What is net pay?',
    '["$2,500", "$1,790", "$1,915", "$2,120"]'::jsonb,
    '$1,790', 3),
  ('00000000-0000-0000-0003-000000000210', 'Why does the lesson warn against budgeting based on your quoted annual salary rather than net pay?',
    '["Quoted salary is usually inaccurate", "Deductions mean the amount that actually arrives is meaningfully less than the gross salary figure", "Net pay is always higher than the quoted salary", "Budgeting against salary is illegal"]'::jsonb,
    'Deductions mean the amount that actually arrives is meaningfully less than the gross salary figure', 4),

  -- Employer Retirement Matching
  ('00000000-0000-0000-0003-000000000211', 'Why is not capturing a full employer retirement match often described as "leaving free money on the table"?',
    '["Because the employer match is compensation contingent on your own contribution, so skipping it forfeits guaranteed extra pay", "Because employers are legally required to contribute regardless of your own contribution", "Because retirement accounts have no tax benefits", "Because the match only applies after 10 years of employment"]'::jsonb,
    'Because the employer match is compensation contingent on your own contribution, so skipping it forfeits guaranteed extra pay', 1),
  ('00000000-0000-0000-0003-000000000211', 'Priya earns $50,000/year with a 50% match up to 6% of salary. If she contributes the full 6% ($3,000), how much does her employer add?',
    '["$3,000", "$1,500", "$500", "$6,000"]'::jsonb,
    '$1,500', 2),
  ('00000000-0000-0000-0003-000000000211', 'If Priya instead contributes only 2% ($1,000) instead of the full matched 6%, what happens?',
    '["She still receives the full $1,500 match", "She only receives a 50% match on the $1,000 she contributed, leaving matched money unclaimed", "Her employer stops matching entirely going forward", "There is no difference in outcome"]'::jsonb,
    'She only receives a 50% match on the $1,000 she contributed, leaving matched money unclaimed', 3),
  ('00000000-0000-0000-0003-000000000211', 'Beyond the match itself, what other advantage do these retirement accounts typically offer, per the lesson?',
    '["Guaranteed high returns with no risk", "Tax-advantaged growth, meaning contributions grow without being taxed each year the way ordinary account gains might be", "Unlimited early withdrawal with no penalty", "A fixed government-guaranteed interest rate"]'::jsonb,
    'Tax-advantaged growth, meaning contributions grow without being taxed each year the way ordinary account gains might be', 4),

  -- Health Insurance Basics
  ('00000000-0000-0000-0003-000000000212', 'What is the general relationship between a health plan''s premium and its deductible?',
    '["They are unrelated", "Lower premium plans typically have higher deductibles, and vice versa", "Higher premium plans always have higher deductibles too", "Deductibles are fixed by law and never vary by plan"]'::jsonb,
    'Lower premium plans typically have higher deductibles, and vice versa', 1),
  ('00000000-0000-0000-0003-000000000212', 'In the worked example, with no major medical needs in a year, which plan costs less overall -- Plan A ($50/month premium, $3,000 deductible) or Plan B ($150/month premium, $500 deductible)?',
    '["Plan A, since only premiums are paid and it has the lower one", "Plan B, since it has the lower deductible", "They cost exactly the same", "Neither -- deductibles apply even with no medical care"]'::jsonb,
    'Plan A, since only premiums are paid and it has the lower one', 2),
  ('00000000-0000-0000-0003-000000000212', 'In the same example, if a $4,000 medical expense occurs, which plan ends up cheaper overall?',
    '["Plan A, because its premium is lower", "Plan B, because its lower deductible means less out-of-pocket cost before insurance covers more", "They cost the same either way", "Neither plan covers medical expenses"]'::jsonb,
    'Plan B, because its lower deductible means less out-of-pocket cost before insurance covers more', 3),
  ('00000000-0000-0000-0003-000000000212', 'Per the lesson, what should determine which health plan is the right choice for a given person?',
    '["Always choosing the lowest premium available", "How much medical care they realistically expect to use in a given year", "Always choosing the lowest deductible available", "Whichever plan a coworker chose"]'::jsonb,
    'How much medical care they realistically expect to use in a given year', 4),

  -- Workplace Financial Etiquette
  ('00000000-0000-0000-0003-000000000213', 'What does a proper expense report generally require, per the lesson?',
    '["Just the total from a credit card statement", "An itemized receipt, a stated business purpose, and timely submission", "Nothing -- expenses are automatically reimbursed", "Only a verbal description to a manager"]'::jsonb,
    'An itemized receipt, a stated business purpose, and timely submission', 1),
  ('00000000-0000-0000-0003-000000000213', 'What is a per diem?',
    '["A one-time signing bonus", "A fixed daily allowance for expenses like meals during travel, given in place of itemized receipts", "A penalty for late expense submission", "A type of retirement contribution"]'::jsonb,
    'A fixed daily allowance for expenses like meals during travel, given in place of itemized receipts', 2),
  ('00000000-0000-0000-0003-000000000213', 'In the worked example, why is the itemized, well-documented expense submission preferable to the vague, late one?',
    '["Both are treated identically by finance teams", "It is straightforward to approve and signals care with company funds, while the vague one creates friction and signals carelessness", "The itemized version is always for a larger dollar amount", "Vague submissions are illegal"]'::jsonb,
    'It is straightforward to approve and signals care with company funds, while the vague one creates friction and signals carelessness', 3),
  ('00000000-0000-0000-0003-000000000213', 'Per the lesson, is it acceptable to treat a generous per diem as personal spending money?',
    '["Yes, per diems are unrestricted personal funds", "No, spending is still expected to stay reasonable and business-related even without itemized receipts", "Yes, as long as the receipts are kept", "Only for travel longer than a week"]'::jsonb,
    'No, spending is still expected to stay reasonable and business-related even without itemized receipts', 4),

  -- Budgeting on Your First Salary
  ('00000000-0000-0000-0003-000000000214', 'What is "lifestyle inflation," per the lesson?',
    '["A government policy affecting salaries", "Scaling up spending immediately to match a new, larger gross salary figure", "A type of tax withholding", "An increase in a company''s cost of living adjustment"]'::jsonb,
    'Scaling up spending immediately to match a new, larger gross salary figure', 1),
  ('00000000-0000-0000-0003-000000000214', 'What does the 50/30/20 framework allocate net pay to?',
    '["50% wants, 30% needs, 20% savings", "50% needs, 30% wants, 20% savings and extra debt paydown", "50% savings, 30% needs, 20% wants", "50% taxes, 30% needs, 20% wants"]'::jsonb,
    '50% needs, 30% wants, 20% savings and extra debt paydown', 2),
  ('00000000-0000-0000-0003-000000000214', 'On $3,200/month net pay, roughly how much does the 50/30/20 framework suggest for needs?',
    '["$960", "$1,600", "$640", "$3,200"]'::jsonb,
    '$1,600', 3),
  ('00000000-0000-0000-0003-000000000214', 'In the worked example, why is signing a $1,400/month lease on $3,200/month net pay flagged as worth checking against the framework?',
    '["Because $1,400 exceeds any reasonable budget entirely", "Because it alone is about 44% of net pay, leaving little room for the rest of needs, wants, and savings", "Because rent is never included in a budget", "Because leases are always a bad financial decision"]'::jsonb,
    'Because it alone is about 44% of net pay, leaving little room for the rest of needs, wants, and savings', 4),

  -- Building an Emergency Fund
  ('00000000-0000-0000-0003-000000000215', 'What is the purpose of an emergency fund, per the lesson?',
    '["To fund vacations and discretionary purchases", "To absorb unplanned necessary expenses without forcing high-interest debt or derailing other savings goals", "To replace an employer retirement account", "To pay ordinary monthly bills"]'::jsonb,
    'To absorb unplanned necessary expenses without forcing high-interest debt or derailing other savings goals', 1),
  ('00000000-0000-0000-0003-000000000215', 'Is an emergency fund typically sized to full income or to essential expenses?',
    '["Full income", "Essential expenses (rent, food, utilities, minimum debt payments), not full income", "Neither -- it has no defined sizing method", "Whatever amount is easiest to save"]'::jsonb,
    'Essential expenses (rent, food, utilities, minimum debt payments), not full income', 2),
  ('00000000-0000-0000-0003-000000000215', 'Marcus''s essential monthly expenses are $1,800. What is a 3-month emergency fund target?',
    '["$1,800", "$5,400", "$10,800", "$3,600"]'::jsonb,
    '$5,400', 3),
  ('00000000-0000-0000-0003-000000000215', 'Why does the lesson recommend keeping an emergency fund in something accessible and low-risk, rather than invested?',
    '["Investing is always illegal for emergency savings", "So it isn''t at risk of losing value right when it''s needed", "Because low-risk accounts always earn more than investments", "Because emergency funds are never actually used"]'::jsonb,
    'So it isn''t at risk of losing value right when it''s needed', 4),

  -- Startup Equity & Stock Options
  ('00000000-0000-0000-0003-000000000216', 'What does a stock option give you, per the lesson?',
    '["Guaranteed cash equal to the option''s estimated value", "The right, not the obligation, to buy company shares later at a fixed strike price", "Immediate ownership of shares with no conditions", "A guaranteed salary increase"]'::jsonb,
    'The right, not the obligation, to buy company shares later at a fixed strike price', 1),
  ('00000000-0000-0000-0003-000000000216', 'What is "vesting," per the lesson?',
    '["A tax paid on stock options", "Earning the right to options gradually over time, commonly over 4 years with a 1-year cliff", "The process of exercising options immediately upon hire", "A type of dilution"]'::jsonb,
    'Earning the right to options gradually over time, commonly over 4 years with a 1-year cliff', 2),
  ('00000000-0000-0000-0003-000000000216', 'In the worked example, someone leaves after 8 months, before the 1-year cliff. What happens to their equity grant?',
    '["They keep it in full regardless of timing", "They forfeit the entire grant, since it hadn''t started vesting yet", "They keep exactly half of it", "Vesting cliffs don''t affect unvested equity"]'::jsonb,
    'They forfeit the entire grant, since it hadn''t started vesting yet', 3),
  ('00000000-0000-0000-0003-000000000216', 'Why does the lesson suggest treating startup equity as speculative upside rather than a substitute for cash compensation?',
    '["Because equity is always worth more than cash in the end", "Because most startups fail or are acquired for modest amounts, so most employee equity ends up worth little or nothing", "Because equity is illegal to include in an offer", "Because options never actually vest"]'::jsonb,
    'Because most startups fail or are acquired for modest amounts, so most employee equity ends up worth little or nothing', 4),

  -- Professional Networking Basics
  ('00000000-0000-0000-0003-000000000217', 'What is an informational interview, per the lesson?',
    '["A formal job interview with multiple rounds", "A short conversation requesting someone''s perspective on their role or field, explicitly not asking for a job", "A performance review with a manager", "An interview conducted entirely by email"]'::jsonb,
    'A short conversation requesting someone''s perspective on their role or field, explicitly not asking for a job', 1),
  ('00000000-0000-0000-0003-000000000217', 'Why does the lesson say the informational interview tends to get a higher response rate than a vague "can we connect?" message?',
    '["Because it is shorter in length", "Because it is specific, time-bounded, low-pressure, and asks for perspective rather than a job or favor", "Because it is sent to more people at once", "Because it guarantees a job offer"]'::jsonb,
    'Because it is specific, time-bounded, low-pressure, and asks for perspective rather than a job or favor', 2),
  ('00000000-0000-0000-0003-000000000217', 'Per the lesson, what keeps a networking relationship genuinely alive over time?',
    '["Only reaching out when you need something", "Following up and staying in touch, rather than treating each contact as a one-time transaction", "Sending the same message to as many people as possible", "Avoiding any further contact after the first conversation"]'::jsonb,
    'Following up and staying in touch, rather than treating each contact as a one-time transaction', 3),
  ('00000000-0000-0000-0003-000000000217', 'What is the more accurate framing of networking, per the lesson, compared to "asking strangers for favors"?',
    '["There is no meaningful difference between the two", "Building genuine, mutually useful professional relationships over time", "Only networking with people who can directly hire you", "Networking is primarily about collecting business cards"]'::jsonb,
    'Building genuine, mutually useful professional relationships over time', 4),

  -- Personal Branding & LinkedIn Basics
  ('00000000-0000-0000-0003-000000000218', 'What is a "personal brand," per the lesson, in a career context?',
    '["A logo or slogan you design for yourself", "The consistent impression your public professional presence creates", "A paid marketing service", "A résumé template"]'::jsonb,
    'The consistent impression your public professional presence creates', 1),
  ('00000000-0000-0000-0003-000000000218', 'What makes the strong LinkedIn headline example ("Finance Student | Aspiring Equity Research Analyst | Building financial modeling skills...") better than "Student at University"?',
    '["It uses more exclamation marks", "It gives immediate, specific context about who this person is and what they''re working toward", "It is shorter", "It avoids mentioning any specific field"]'::jsonb,
    'It gives immediate, specific context about who this person is and what they''re working toward', 2),
  ('00000000-0000-0000-0003-000000000218', 'Per the lesson, how should LinkedIn experience entries be written?',
    '["Copy-pasted directly from the official job description", "The same way strong resume bullets are: context, action, measurable result", "As a bare list of skills with no context", "As long as possible, with no specific structure"]'::jsonb,
    'The same way strong resume bullets are: context, action, measurable result', 3),
  ('00000000-0000-0000-0003-000000000218', 'Why does the lesson warn that discrepancies between your resume, LinkedIn, and interview story are a "quiet red flag"?',
    '["Because discrepancies are illegal", "Because inconsistencies (mismatched dates, different framings of the same role) can raise doubts for anyone checking closely", "Because LinkedIn automatically flags mismatches to employers", "Because resumes and LinkedIn profiles must be identical word-for-word"]'::jsonb,
    'Because inconsistencies (mismatched dates, different framings of the same role) can raise doubts for anyone checking closely', 4),

  -- Benefits Enrollment
  ('00000000-0000-0000-0003-000000000219', 'What is open enrollment, per the lesson?',
    '["A one-time signup available only to new hires", "A defined annual window to choose or change benefit elections, generally locked in outside a qualifying life event", "A window for negotiating salary", "An ongoing process available at any time"]'::jsonb,
    'A defined annual window to choose or change benefit elections, generally locked in outside a qualifying life event', 1),
  ('00000000-0000-0000-0003-000000000219', 'What is the key difference between an HSA and a standard FSA, per the lesson?',
    '["They are functionally identical", "An HSA balance rolls over indefinitely and is permanently yours; a standard FSA is typically \"use it or lose it\" within the plan year", "An FSA rolls over indefinitely while an HSA does not", "Only an FSA offers pre-tax contributions"]'::jsonb,
    'An HSA balance rolls over indefinitely and is permanently yours; a standard FSA is typically "use it or lose it" within the plan year', 2),
  ('00000000-0000-0000-0003-000000000219', 'In the worked example, someone contributes $2,000 to an FSA but only uses $600. What generally happens to the remaining $1,400 under typical FSA rules?',
    '["It rolls over indefinitely, like an HSA", "Most or all of it is forfeited at year-end", "It is automatically refunded in cash", "It is converted into an HSA"]'::jsonb,
    'Most or all of it is forfeited at year-end', 3),
  ('00000000-0000-0000-0003-000000000219', 'Why does the lesson recommend understanding benefit choices before the open enrollment window rather than during it?',
    '["Because elections made during the window are non-binding anyway", "Because most elections are locked in for a full year absent a qualifying life event, making reactive decisions costly", "Because the window is only open for one hour", "Because benefits information is unavailable during the window"]'::jsonb,
    'Because most elections are locked in for a full year absent a qualifying life event, making reactive decisions costly', 4),

  -- Credit Cards & Building Credit
  ('00000000-0000-0000-0003-000000000220', 'What two habits does the lesson say matter most for building credit responsibly?',
    '["Opening as many cards as possible and spending the maximum limit", "Paying the full statement balance on time every month, and keeping credit utilization low", "Only using cash and avoiding credit entirely", "Making only the minimum payment each month"]'::jsonb,
    'Paying the full statement balance on time every month, and keeping credit utilization low', 1),
  ('00000000-0000-0000-0003-000000000220', 'Per the lesson, what happens if you carry a credit card balance instead of paying it in full?',
    '["Nothing -- there is no cost to carrying a balance", "You typically pay interest, often 20%+ APR, on top of the underlying debt", "Your credit score always improves", "Your credit limit is automatically reduced"]'::jsonb,
    'You typically pay interest, often 20%+ APR, on top of the underlying debt', 2),
  ('00000000-0000-0000-0003-000000000220', 'In the worked example, why can 90% utilization on a $2,000 limit ($1,800 spent) still lower a credit score even if paid off in full by the due date?',
    '["Utilization never affects a credit score", "A high balance can be reported to credit bureaus before the payment posts, regardless of eventual full payment", "Paying in full always guarantees a higher score", "Only late payments affect utilization"]'::jsonb,
    'A high balance can be reported to credit bureaus before the payment posts, regardless of eventual full payment', 3),
  ('00000000-0000-0000-0003-000000000220', 'What does the lesson identify as typically the single most damaging action to a credit score?',
    '["Having a high credit limit", "Missing a payment, even by a few days", "Opening a first credit card at all", "Using a credit card for everyday purchases"]'::jsonb,
    'Missing a payment, even by a few days', 4),

  -- Student Loan Repayment Basics
  ('00000000-0000-0000-0003-000000000221', 'What is a loan grace period, per the lesson?',
    '["A period where no interest accrues ever again", "A period, often around 6 months after graduation, before repayment begins", "A period where the loan is forgiven", "A penalty period for late payments"]'::jsonb,
    'A period, often around 6 months after graduation, before repayment begins', 1),
  ('00000000-0000-0000-0003-000000000221', 'What is the main trade-off of an income-driven repayment plan compared to a standard plan, per the lesson?',
    '["It has no trade-off -- it is strictly better in every way", "Lower near-term payments, but usually a longer repayment period and more total interest paid", "Higher near-term payments but a shorter repayment period", "It is only available for private loans"]'::jsonb,
    'Lower near-term payments, but usually a longer repayment period and more total interest paid', 2),
  ('00000000-0000-0000-0003-000000000221', 'Per the lesson, how do federal and private student loans generally compare in flexibility?',
    '["They offer identical repayment options", "Federal loans generally offer more repayment plan options, including income-driven plans in some cases; private loans typically offer far less flexibility", "Private loans always have more flexible income-driven options", "Neither type offers any repayment flexibility"]'::jsonb,
    'Federal loans generally offer more repayment plan options, including income-driven plans in some cases; private loans typically offer far less flexibility', 3),
  ('00000000-0000-0000-0003-000000000221', 'Why does the lesson recommend understanding your specific loans during the grace period?',
    '["Because grace periods are extremely short, often just a few days", "So you understand balance, rate, and repayment options before the first payment is due, rather than under pressure", "Because loan terms change automatically after the grace period", "Because interest cannot accrue during the grace period under any circumstance"]'::jsonb,
    'So you understand balance, rate, and repayment options before the first payment is due, rather than under pressure', 4),

  -- Workplace Communication & Professionalism
  ('00000000-0000-0000-0003-000000000222', 'What does the lesson recommend as a reliable default for workplace communication norms?',
    '["Assuming norms from school or a previous internship transfer directly", "Matching the tone and channel your current team already uses", "Always using the most formal channel available", "Avoiding all communication with managers"]'::jsonb,
    'Matching the tone and channel your current team already uses', 1),
  ('00000000-0000-0000-0003-000000000222', 'Per the lesson, how should a disagreement with a manager''s decision generally be raised?',
    '["Staying silent regardless of the concern", "Pushing back sharply in a group meeting", "Privately, with clear reasoning, to the relevant person", "Only through anonymous feedback channels"]'::jsonb,
    'Privately, with clear reasoning, to the relevant person', 2),
  ('00000000-0000-0000-0003-000000000222', 'In the worked example, what makes the stronger response to a disagreement effective?',
    '["It avoids stating any actual concern", "It raises a clear, reasoned concern privately and offers to help rather than just criticize", "It is delivered in a team meeting for visibility", "It simply agrees with the manager regardless of the concern"]'::jsonb,
    'It raises a clear, reasoned concern privately and offers to help rather than just criticize', 3),
  ('00000000-0000-0000-0003-000000000222', 'Why does the lesson say raising a disagreement in a larger group setting is generally worse than raising it privately first?',
    '["Group settings are always against company policy", "It is more likely to read as combative and can damage the relationship even when the underlying concern is valid", "Managers never respond to group settings", "It takes longer to raise a concern privately"]'::jsonb,
    'It is more likely to read as combative and can damage the relationship even when the underlying concern is valid', 4);
