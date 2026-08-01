-- AI Interview Coach: difficulty labels + post-answer improvement guides for
-- every one of the 115 existing interview_questions rows (9 from
-- 00000000000019, 106 from 00000000000035) plus the 20 case-study
-- free-response/MCQ questions added in 00000000000045 already carry their
-- own difficulty inline, so those are untouched here.
--
-- `interview_questions` has no stable, deterministic id for these rows (they
-- were seeded without explicit `id` values, so ids are random
-- `gen_random_uuid()` defaults) -- these UPDATEs match on the
-- (firm_style, question_text) pair, which is unique across the seeded set,
-- rather than by id. The safety check at the end of this migration exists
-- specifically because of that: if any (firm_style, question_text) match
-- below has a typo relative to what's actually stored, the affected row's
-- `improvement_guide` would stay null and the final not-null/check-length
-- constraint would fail loudly at apply time -- surfacing a text mismatch
-- immediately rather than shipping a silently-incomplete backfill.
--
-- Each `improvement_guide` names what a strong answer specifically
-- includes (structure, the right concept, a concrete mechanism) and one
-- concrete common pitfall -- written to be specific to that question, not
-- reusable boilerplate, per the "not generic filler" requirement.

alter table interview_questions
  add column difficulty text not null default 'medium' check (difficulty in ('easy', 'medium', 'hard')),
  add column improvement_guide text;

-- ===================== 00000000000019 (9 questions) =====================

update interview_questions set difficulty = 'easy', improvement_guide =
  'Treat this as a highlight reel, not a full recitation -- pick 3-4 experiences that build toward why you want this specific role, spending most time on the most relevant ones, and end by connecting your background to this job. Common pitfall: reciting every resume line verbatim with no narrative thread, which makes the interviewer scan the page instead of listening to you.'
  where firm_style = 'JPMorgan Chase' and question_text = 'Walk me through your resume.';

update interview_questions set difficulty = 'medium', improvement_guide =
  'A strong answer names a specific, personal reason for the industry (not just prestige or pay) and layers on genuine, researched reasons for this specific firm -- a person you spoke with, a deal or practice area, the culture. Common pitfall: an answer generic enough to copy-paste into any bank''s interview, which signals you haven''t done real research.'
  where firm_style = 'JPMorgan Chase' and question_text = 'Why investment banking, and why JPMorgan specifically?';

update interview_questions set difficulty = 'medium', improvement_guide =
  'Name all three statements and explain the linkages precisely: net income flows into retained earnings on the balance sheet and is the starting line of the cash flow statement, and ending cash from the cash flow statement becomes the balance sheet''s cash line. Common pitfall: naming the three statements but failing to explain how a change actually flows between them, which is usually the real point of the question.'
  where firm_style = 'JPMorgan Chase' and question_text = 'Walk me through the three financial statements and how they link together.';

update interview_questions set difficulty = 'medium', improvement_guide =
  'Use STAR and be explicit about what information was actually missing and how you handled that gap -- a reasonable assumption, a clarifying question, prioritizing what mattered most -- rather than skipping straight to the result. Common pitfall: focusing only on the time pressure and never addressing the "limited information" half of the question.'
  where firm_style = 'Goldman Sachs' and question_text = 'Tell me about a time you worked under a tight deadline with limited information.';

update interview_questions set difficulty = 'medium', improvement_guide =
  'Answer both halves distinctly: name 1-2 concrete qualities you value in a team (not a vague "good communication"), then walk through a real example of resolving a disagreement productively. Common pitfall: answering only the first half of a two-part question and forgetting to address disagreement at all.'
  where firm_style = 'Goldman Sachs' and question_text = 'What do you look for in a team, and how do you handle disagreement within one?';

update interview_questions set difficulty = 'hard', improvement_guide =
  'Cover the full mechanics in order: project free cash flows, discount them to present value using a discount rate (WACC), sum the discounted cash flows plus a discounted terminal value, and explain the result estimates intrinsic value from the company''s own projected cash generation, independent of market sentiment. Common pitfall: naming "discounted cash flow" without explaining why cash flows are discounted (time value of money) or what the terminal value represents.'
  where firm_style = 'Goldman Sachs' and question_text = 'Walk me through a DCF and what it tells you about a company''s valuation.';

update interview_questions set difficulty = 'medium', improvement_guide =
  'Focus on the reasoning you used to persuade them, not just that you eventually succeeded -- what evidence or framing changed their mind, and how you stayed respectful of their original position. Common pitfall: describing the disagreement in detail while glossing over the actual persuasion technique, leaving no evidence of your influencing skill.'
  where firm_style = 'Morgan Stanley' and question_text = 'Describe a time you had to persuade someone who disagreed with you.';

update interview_questions set difficulty = 'medium', improvement_guide =
  'Name something specific to Morgan Stanley -- a group, a recent deal, a value, a conversation with someone there -- rather than reasons that would apply to any bank equally. Common pitfall: an answer built entirely around prestige or compensation, which reads as interchangeable with any competitor.'
  where firm_style = 'Morgan Stanley' and question_text = 'Why do you want to work at Morgan Stanley over other banks?';

update interview_questions set difficulty = 'hard', improvement_guide =
  'Trace the full mechanic: net income falls by $10 x (1 - tax rate) since depreciation is tax-deductible, but depreciation itself is non-cash, so it is added back on the cash flow statement -- meaning cash flow from operations actually rises overall (by the tax-shield amount) even though net income fell. Common pitfall: stopping at "net income falls" without completing the add-back step, which is the actual point of the question.'
  where firm_style = 'Morgan Stanley' and question_text = 'What happens to a company''s cash flow statement if depreciation increases by $10?';

-- ===================== General Behavioral (15) =====================

update interview_questions set difficulty = 'easy', improvement_guide =
  'This is an elevator-pitch question, not an invitation for a full biography -- structure it as present (what you do now), past (relevant experience that led here), future (why this role specifically), in under two minutes. Common pitfall: starting from childhood or unrelated personal details instead of building toward why you''re a fit for this role.'
  where firm_style = 'General Behavioral' and question_text = 'Tell me about yourself.';

update interview_questions set difficulty = 'easy', improvement_guide =
  'Name one or two strengths and immediately back each with a specific example of it in action, not just an adjective. Common pitfall: naming a generic strength like "hard worker" with no concrete evidence, which is forgettable and unverifiable.'
  where firm_style = 'General Behavioral' and question_text = 'What are your greatest strengths, and how have they shown up in your work?';

update interview_questions set difficulty = 'medium', improvement_guide =
  'Name a real, specific weakness (not a disguised strength like "I work too hard") and describe a concrete action you''ve taken to address it, with evidence of progress. Common pitfall: picking a fake weakness that''s actually a strength in disguise, which reads as evasive rather than self-aware.'
  where firm_style = 'General Behavioral' and question_text = 'What is a weakness you''re actively working to improve, and what have you done about it?';

update interview_questions set difficulty = 'medium', improvement_guide =
  'Use STAR, being specific about exactly what you had to learn and the concrete steps you took to get up to speed quickly, not just "I studied hard." Common pitfall: emphasizing the time pressure and stress without showing the actual learning process or method used.'
  where firm_style = 'General Behavioral' and question_text = 'Tell me about a time you had to learn something completely new under time pressure.';

update interview_questions set difficulty = 'medium', improvement_guide =
  'Describe the specific feedback, your honest initial reaction, and then the concrete change you made afterward -- this question tests whether you actually adjust, not just whether you can take criticism gracefully. Common pitfall: saying feedback was "appreciated" with no description of what actually changed in your behavior as a result.'
  where firm_style = 'General Behavioral' and question_text = 'Describe a time you received critical feedback. How did you respond?';

update interview_questions set difficulty = 'easy', improvement_guide =
  'Pick a goal with a clear, ideally measurable outcome, and walk through the specific steps and any obstacles you overcame, not just the end result. Common pitfall: describing the goal and outcome but skipping the actual process, leaving no evidence of how you achieve things.'
  where firm_style = 'General Behavioral' and question_text = 'Tell me about a goal you set for yourself and how you achieved it.';

update interview_questions set difficulty = 'medium', improvement_guide =
  'Explain the specific criteria you used to decide what came first -- impact, urgency, dependencies -- rather than just saying you "stayed organized." Common pitfall: describing the stress of multiple deadlines without explaining the actual decision-making process used to prioritize them.'
  where firm_style = 'General Behavioral' and question_text = 'Describe a time you had to prioritize among multiple competing deadlines.';

update interview_questions set difficulty = 'medium', improvement_guide =
  'Own the mistake directly and specifically, then spend most of your answer on the concrete correction and what you changed afterward to prevent it recurring. Common pitfall: deflecting blame onto circumstances or other people rather than taking ownership of your own error.'
  where firm_style = 'General Behavioral' and question_text = 'Tell me about a time you made a mistake at work or school. What did you do next?';

update interview_questions set difficulty = 'easy', improvement_guide =
  'Name something specific and genuine that motivates you, then explicitly connect it to a real aspect of this role rather than restating the job description back. Common pitfall: a generic answer like "I''m motivated by success" that never actually connects to why this specific role fits that motivation.'
  where firm_style = 'General Behavioral' and question_text = 'What motivates you, and how does this role fit into that?';

update interview_questions set difficulty = 'easy', improvement_guide =
  'Show realistic ambition connected to growth within this field or firm, without over-committing to a specific title or over-promising loyalty you can''t guarantee. Common pitfall: an answer disconnected from this role or industry entirely, which raises doubts about genuine interest in the path.'
  where firm_style = 'General Behavioral' and question_text = 'Where do you see yourself in five years?';

update interview_questions set difficulty = 'medium', improvement_guide =
  'Focus on the specific adjustment you made to work well with that person -- communication style, meeting cadence, division of tasks -- not just that the difference existed. Common pitfall: describing the personality clash in detail while glossing over what you personally did to adapt and make the collaboration work.'
  where firm_style = 'General Behavioral' and question_text = 'Tell me about a time you had to work with someone whose working style was very different from yours.';

update interview_questions set difficulty = 'medium', improvement_guide =
  'Pick a specific instance where you did something beyond your formal responsibility, and be clear about the tangible impact it had. Common pitfall: describing normal, expected effort as if it were exceptional, which undersells what "above and beyond" should actually mean.'
  where firm_style = 'General Behavioral' and question_text = 'Describe a situation where you went above and beyond what was expected of you.';

update interview_questions set difficulty = 'medium', improvement_guide =
  'Explain the reasoning behind the no clearly and how you communicated it respectfully, ideally including any alternative you offered. Common pitfall: an answer that sounds like simple refusal with no diplomatic framing or explanation, which can read as inflexible.'
  where firm_style = 'General Behavioral' and question_text = 'Tell me about a time you had to say no to a request. How did you handle it?';

update interview_questions set difficulty = 'hard', improvement_guide =
  'Walk through the actual trade-offs you weighed, not just the final choice -- the interviewer wants to see your reasoning process under genuine uncertainty. Common pitfall: describing a decision that wasn''t actually difficult or high-stakes, which undermines the premise of the question.'
  where firm_style = 'General Behavioral' and question_text = 'What is the most difficult decision you''ve had to make recently, and how did you approach it?';

update interview_questions set difficulty = 'hard', improvement_guide =
  'Describe specifically how you framed the request or concern to the senior person -- with clear reasoning and respect for their time and authority -- and what the outcome was. Common pitfall: describing frustration with not getting support, without showing the specific, professional approach you took to actually get it.'
  where firm_style = 'General Behavioral' and question_text = 'Tell me about a time you had to manage up -- get support or a decision from someone more senior than you.';

-- ===================== General Situational (8) =====================

update interview_questions set difficulty = 'medium', improvement_guide =
  'Show you''d address the misunderstanding immediately and directly -- flagging it to whoever owns the requirement -- rather than either quietly redoing the work alone or continuing on the wrong path to avoid an awkward conversation. Common pitfall: focusing only on how you''d fix the output without mentioning that you''d proactively surface the misunderstanding first.'
  where firm_style = 'General Situational' and question_text = 'You realize partway through a project that you misunderstood a key requirement. What do you do?';

update interview_questions set difficulty = 'medium', improvement_guide =
  'Describe a specific, direct but respectful conversation with the teammate first, before escalating -- and be clear about what you''d actually say. Common pitfall: jumping straight to "I''d tell my manager" without first attempting to resolve it directly with the teammate.'
  where firm_style = 'General Situational' and question_text = 'A teammate is consistently missing deadlines and it''s affecting your work. How do you handle it?';

update interview_questions set difficulty = 'medium', improvement_guide =
  'Show you''d raise the concern proactively and specifically -- which parts are unrealistic and why -- rather than either silently accepting an impossible deadline or refusing outright. Common pitfall: an answer that either complains without proposing anything, or simply agrees without flagging the real risk.'
  where firm_style = 'General Situational' and question_text = 'Your manager gives you a task with an unrealistic deadline. What do you do?';

update interview_questions set difficulty = 'medium', improvement_guide =
  'Describe raising it privately and promptly with the colleague (or the right owner) before it reaches the client, framed as catching an error together rather than an accusation. Common pitfall: describing silently fixing it yourself without telling anyone, which hides a process problem that could recur.'
  where firm_style = 'General Situational' and question_text = 'You notice a colleague appears to have made an error in a client-facing document. What do you do?';

update interview_questions set difficulty = 'hard', improvement_guide =
  'Show you''d raise the disagreement directly and constructively with the decision-maker, ideally with a specific reason or new information, while still being willing to fully execute the team''s decision if it stands. Common pitfall: describing quietly undermining or slow-walking a decision you disagree with instead of raising the concern openly.'
  where firm_style = 'General Situational' and question_text = 'You disagree with a decision your team has already made and started implementing. How do you handle it?';

update interview_questions set difficulty = 'medium', improvement_guide =
  'Describe quickly clarifying true urgency and dependencies with both people rather than guessing, and being transparent with both about the conflict rather than silently choosing one. Common pitfall: picking one task arbitrarily without communicating the conflict to either senior person.'
  where firm_style = 'General Situational' and question_text = 'You are given two urgent tasks by two different senior people at the same time. What do you do?';

update interview_questions set difficulty = 'hard', improvement_guide =
  'Name that you''d pause, ask clarifying questions about the reasoning, and escalate to a manager or compliance rather than either complying silently or refusing dramatically on the spot. Common pitfall: an answer that skips escalation entirely, either from over-compliance or from unilaterally refusing without raising it properly.'
  where firm_style = 'General Situational' and question_text = 'You''re asked to do something you believe is ethically questionable, but not clearly against any written policy. What do you do?';

update interview_questions set difficulty = 'medium', improvement_guide =
  'Show that you''d listen fully to the specific concern before responding, acknowledge what''s valid, and propose a concrete next step or revision, rather than getting defensive. Common pitfall: an answer focused on explaining or justifying the original work instead of first genuinely hearing out the stakeholder''s concern.'
  where firm_style = 'General Situational' and question_text = 'A client or stakeholder is unhappy with a deliverable you produced. How do you handle the conversation?';

-- ===================== JPMorgan Chase (6, from 00000000000035) =====================

update interview_questions set difficulty = 'medium', improvement_guide =
  'Pick a specific instance, describe the simplifying analogy or framing you used, and ideally reference how you confirmed the person actually understood. Common pitfall: describing the technical content in as much jargon as you''d use with a technical audience, which misses what the question is testing.'
  where firm_style = 'JPMorgan Chase' and question_text = 'Describe a time you had to explain something technical to someone without a technical background.';

update interview_questions set difficulty = 'easy', improvement_guide =
  'Show genuine, current engagement with the industry -- name a specific story or trend and explain why it matters to this business or role, not just that you "read the news." Common pitfall: a vague or outdated reference that suggests you didn''t prepare anything specific for this question.'
  where firm_style = 'JPMorgan Chase' and question_text = 'What recent market or industry news has caught your attention, and why?';

update interview_questions set difficulty = 'hard', improvement_guide =
  'Move away from P/E-style multiples (which break down with negative earnings) toward revenue multiples, EBITDA multiples if EBITDA is positive, or a DCF based on projected future cash flows/earnings rather than current ones. Common pitfall: defaulting to a standard P/E multiple without acknowledging why it doesn''t work when earnings are negative.'
  where firm_style = 'JPMorgan Chase' and question_text = 'How would you value a company with negative earnings?';

update interview_questions set difficulty = 'medium', improvement_guide =
  'Define both precisely: equity value is what shareholders own (market cap); enterprise value adds debt and subtracts cash, representing the whole operating business regardless of capital structure. Use enterprise value to compare companies with different debt levels, and equity value for questions specifically about shareholder returns. Common pitfall: defining one correctly but not naming a concrete situation where you''d use each.'
  where firm_style = 'JPMorgan Chase' and question_text = 'What is the difference between enterprise value and equity value, and when would you use each?';

update interview_questions set difficulty = 'hard', improvement_guide =
  'Walk through the mechanic precisely: enterprise value itself doesn''t change (EV = equity value + debt - cash is unaffected by shifting value between debt and equity), but the split changes -- debt rises, cash falls (used to buy back stock), and equity value falls by the amount repurchased. Common pitfall: assuming issuing debt changes enterprise value itself, rather than just its composition.'
  where firm_style = 'JPMorgan Chase' and question_text = 'Walk me through what happens to enterprise value if a company issues new debt to buy back stock.';

update interview_questions set difficulty = 'medium', improvement_guide =
  'Define WACC as the blended cost of a company''s debt and equity financing, weighted by their proportions, and explain it''s used as the discount rate in a DCF because it represents the return investors require given the company''s specific capital mix -- the appropriate "hurdle rate" for its projected cash flows. Common pitfall: naming the formula without explaining why that rate is the appropriate one to discount cash flows by.'
  where firm_style = 'JPMorgan Chase' and question_text = 'What is WACC, and why is it used as a discount rate?';

-- ===================== Goldman Sachs (6, from 00000000000035) =====================

update interview_questions set difficulty = 'medium', improvement_guide =
  'Focus on the specific action that built credibility quickly -- delivering on a small commitment first, being transparent about constraints, asking good questions -- rather than a vague claim of "good people skills." Common pitfall: describing the relationship''s importance without naming any specific trust-building action you actually took.'
  where firm_style = 'Goldman Sachs' and question_text = 'Tell me about a time you had to build trust with someone quickly.';

update interview_questions set difficulty = 'medium', improvement_guide =
  'Describe a concrete instance where you identified a need nobody assigned to you and acted on it, with a clear outcome. Common pitfall: describing something that was actually assigned or expected, which undercuts the "without being asked" premise of the question.'
  where firm_style = 'Goldman Sachs' and question_text = 'Describe a time you took initiative without being asked.';

update interview_questions set difficulty = 'hard', improvement_guide =
  'Name one or two specific, differentiated strengths or experiences -- not generic traits every candidate would claim -- and connect them concretely to what this specific role needs. Common pitfall: an answer built on generic positive adjectives with nothing distinctive or role-specific.'
  where firm_style = 'Goldman Sachs' and question_text = 'Why should we hire you over another candidate with a similar background?';

update interview_questions set difficulty = 'hard', improvement_guide =
  'Build a case around alternatives to public comps: precedent private transactions if available, a DCF grounded in the company''s own projected cash flows, and possibly a build-up from the closest available public proxies with explicit adjustments for size/liquidity differences. Common pitfall: saying "you can''t value it without comparables," which avoids answering rather than reasoning through the alternatives.'
  where firm_style = 'Goldman Sachs' and question_text = 'Walk me through how you would value a private company with no public comparables.';

update interview_questions set difficulty = 'medium', improvement_guide =
  'Trading comps are faster and market-grounded but only as good as the comparable set and current sentiment; a DCF is more independent of market mood but highly sensitive to long-term assumptions -- name when each weakness matters most (comps in a volatile or comp-poor market, DCF for a company with few good peers). Common pitfall: describing only one method''s strengths without addressing when the other approach is actually preferable.'
  where firm_style = 'Goldman Sachs' and question_text = 'What factors would make you choose a trading comparables approach over a DCF, or vice versa?';

update interview_questions set difficulty = 'medium', improvement_guide =
  'Explain the mechanism: higher rates raise the discount rate used to value future cash flows/earnings, which lowers the present value of those future cash flows -- so equity valuations generally fall, all else equal, when rates rise. Common pitfall: stating the directional relationship (rates up, valuations down) without explaining the discounting mechanism that causes it.'
  where firm_style = 'Goldman Sachs' and question_text = 'How does an increase in interest rates generally affect equity valuations?';

-- ===================== Morgan Stanley (6, from 00000000000035) =====================

update interview_questions set difficulty = 'medium', improvement_guide =
  'Show you''d recognize the error early (what tipped you off) and pivoted concretely, rather than persisting with a flawed approach out of sunk cost. Common pitfall: spending the whole answer on why the initial approach seemed reasonable, with little detail on the actual pivot and its outcome.'
  where firm_style = 'Morgan Stanley' and question_text = 'Tell me about a time your initial approach to a problem turned out to be wrong. What did you do?';

update interview_questions set difficulty = 'medium', improvement_guide =
  'Describe the specific, respectful way you framed the feedback -- a concrete example, focused on behavior not character -- and how the person responded. Common pitfall: describing that feedback was "necessary" without detailing how you actually delivered it constructively.'
  where firm_style = 'Morgan Stanley' and question_text = 'Describe a time you had to give someone difficult feedback.';

update interview_questions set difficulty = 'easy', improvement_guide =
  'Name a concrete system -- a prioritization framework, a specific tool, a weekly review habit -- rather than a vague claim of being "naturally organized." Common pitfall: a generic answer with no specific method, which gives the interviewer nothing to evaluate.'
  where firm_style = 'Morgan Stanley' and question_text = 'How do you stay organized when managing several projects with different priorities?';

update interview_questions set difficulty = 'hard', improvement_guide =
  'Walk through the mechanic precisely: inventory rises by $10 on the balance sheet, funded by a $10 cash decrease (if paid cash) or a $10 accounts-payable increase (if on credit); the income statement is unaffected until the inventory is sold (then it becomes cost of goods sold); the cash flow statement shows a $10 operating use of cash (or no effect if bought on credit). Common pitfall: assuming the income statement changes immediately, when inventory purchases don''t hit it until the goods are actually sold.'
  where firm_style = 'Morgan Stanley' and question_text = 'Walk me through the impact of a $10 increase in inventory on the three financial statements.';

update interview_questions set difficulty = 'medium', improvement_guide =
  'Book value is the accounting value of equity on the balance sheet (assets minus liabilities, at historical/depreciated cost); market value is what investors are actually willing to pay today, reflecting expectations book value doesn''t capture. Common pitfall: describing one without contrasting it against the other, or treating them as if they should always be similar.'
  where firm_style = 'Morgan Stanley' and question_text = 'What is the difference between a company''s book value and its market value?';

update interview_questions set difficulty = 'medium', improvement_guide =
  'Name concrete sources of divergence: different assumptions (growth rates, discount rates, terminal value), different methodologies (DCF vs. comps vs. precedent transactions), or different judgment on qualitative factors (management quality, competitive risk). Common pitfall: saying valuation is "subjective" without naming any specific driver of the disagreement.'
  where firm_style = 'Morgan Stanley' and question_text = 'Why might two analysts arrive at very different valuations for the exact same company?';

-- ===================== BlackRock (6) =====================

update interview_questions set difficulty = 'medium', improvement_guide =
  'Show your process for deciding despite the gap -- what you did know, what reasonable assumption you made, how you''d have adjusted if new information arrived. Common pitfall: implying you had full information when you didn''t, instead of directly addressing how you handled the actual gap.'
  where firm_style = 'BlackRock' and question_text = 'Tell me about a time you had to make a decision with incomplete information.';

update interview_questions set difficulty = 'medium', improvement_guide =
  'Be specific about what the new evidence was and exactly how it changed your view -- this question rewards intellectual honesty, not consistency for its own sake. Common pitfall: describing a minor preference change rather than a genuine, substantive change of mind, which undersells the point of the question.'
  where firm_style = 'BlackRock' and question_text = 'Describe a time you changed your mind about something after new evidence came in.';

update interview_questions set difficulty = 'easy', improvement_guide =
  'Define diversification as spreading investments across assets that don''t all move together, and explain the mechanism: losses in some holdings are offset by gains or stability in others, so overall portfolio volatility falls even if individual holdings are still risky. Common pitfall: saying diversification "reduces risk" without explaining the actual mechanism -- imperfect correlation between holdings.'
  where firm_style = 'BlackRock' and question_text = 'What is diversification, and why does it reduce risk in a portfolio?';

update interview_questions set difficulty = 'medium', improvement_guide =
  'Systematic risk affects the whole market (a recession, rate changes) and can''t be diversified away; idiosyncratic risk is specific to one company (a product recall) and can be reduced by holding a diversified portfolio. Common pitfall: naming the two terms without being able to say which one diversification actually addresses -- idiosyncratic, not systematic.'
  where firm_style = 'BlackRock' and question_text = 'What is the difference between systematic and idiosyncratic (company-specific) risk?';

update interview_questions set difficulty = 'medium', improvement_guide =
  'Use a plain-language mechanism: a bond pays a fixed rate, so when new bonds are issued at higher prevailing rates, existing lower-rate bonds become less attractive and must sell at a discount to compete -- so bond prices fall when rates rise, and rise when rates fall. Common pitfall: stating the inverse relationship as a fact to memorize without giving the requested plain-language explanation of why it happens.'
  where firm_style = 'BlackRock' and question_text = 'How would you explain the relationship between bond prices and interest rates to someone with no finance background?';

update interview_questions set difficulty = 'medium', improvement_guide =
  'Define the Sharpe ratio as risk-adjusted return: excess return (over a risk-free rate) divided by the investment''s volatility (standard deviation), so a higher Sharpe ratio means more return per unit of risk taken. Common pitfall: describing it as just "a return measure" without mentioning that it specifically adjusts for risk taken, which is the entire point of the metric.'
  where firm_style = 'BlackRock' and question_text = 'What is a Sharpe ratio, and what does it measure?';

-- ===================== McKinsey & Company (6) =====================

update interview_questions set difficulty = 'medium', improvement_guide =
  'Describe the specific approach you used to build buy-in -- data, framing the shared benefit, finding an ally -- rather than relying on your role or title. Common pitfall: describing a situation where you actually did have some authority, which misses the point of the question.'
  where firm_style = 'McKinsey & Company' and question_text = 'Tell me about a time you had to influence someone without having formal authority over them.';

update interview_questions set difficulty = 'medium', improvement_guide =
  'Explain the specific criteria used to split work -- skills, availability, task dependencies -- and how you tracked progress against the deadline, not just that the team "worked hard." Common pitfall: describing the deadline pressure vividly while skipping the actual division-of-labor logic, which is what''s being tested.'
  where firm_style = 'McKinsey & Company' and question_text = 'Describe a time you worked on a team with a very tight deadline. How did you divide the work?';

update interview_questions set difficulty = 'hard', improvement_guide =
  'Since revenue is stable but profit fell, the issue must be on the cost or margin side -- structure the investigation around cost categories (COGS, labor, rent, marketing) and margin per unit/store, checking for a specific driver like rising input costs or new-store underperformance rather than jumping to a conclusion. Common pitfall: guessing a single cause immediately instead of laying out a structured framework of possible cost/margin drivers first.'
  where firm_style = 'McKinsey & Company' and question_text = 'A retail client''s profits have declined for two straight years despite stable revenue. How would you investigate why?';

update interview_questions set difficulty = 'medium', improvement_guide =
  'Cover market attractiveness (size, growth, competition), the client''s right to win (existing capabilities, brand fit), entry-mode options (build, acquire, partner) and their trade-offs, and regulatory/cultural factors specific to that market. Common pitfall: listing only market size and growth while ignoring the client''s actual fit and realistic entry-mode options.'
  where firm_style = 'McKinsey & Company' and question_text = 'A client wants to know whether they should enter a new international market. What factors would you consider?';

update interview_questions set difficulty = 'medium', improvement_guide =
  'Use a structured build-up: estimate the number of relevant stores in the city, average daily customers per store, average ticket size, and operating days per year, stating each assumption explicitly before multiplying through. Common pitfall: guessing a round final number without showing the structured build-up the question is actually testing.'
  where firm_style = 'McKinsey & Company' and question_text = 'Estimate the annual revenue of a mid-sized coffee shop chain in a major city.';

update interview_questions set difficulty = 'hard', improvement_guide =
  'Frame it as a cost/capacity trade-off: estimate the capital cost and lead time of each option, the capacity gain each provides, and the risk profile (new factory adds capacity but more risk/lead time; expansion is faster and lower-risk but capped) before landing on assumptions that would tip the decision. Common pitfall: picking one option immediately without laying out the comparative cost/capacity/risk framework first.'
  where firm_style = 'McKinsey & Company' and question_text = 'A manufacturer is considering whether to build a new factory or expand an existing one. How would you structure that decision?';

-- ===================== Boston Consulting Group (5) =====================

update interview_questions set difficulty = 'hard', improvement_guide =
  'Describe specifically what evidence or reframing changed the group''s mind mid-project, and how you managed the disruption of changing course partway through, not just that you were eventually right. Common pitfall: focusing on being right in hindsight rather than the actual process of persuading a group already committed to a different path.'
  where firm_style = 'Boston Consulting Group' and question_text = 'Tell me about a time you had to persuade a group to change its approach mid-project.';

update interview_questions set difficulty = 'medium', improvement_guide =
  'Name the specific data sources, method, and how the analysis directly led to a decision or recommendation someone acted on -- complexity should be shown through the reasoning, not data volume. Common pitfall: describing a large dataset without explaining the actual analytical method or how it changed a real decision.'
  where firm_style = 'Boston Consulting Group' and question_text = 'Describe the most complex analysis you''ve done to reach a decision or recommendation.';

update interview_questions set difficulty = 'medium', improvement_guide =
  'Structure hypotheses around competitors (a rival out-innovating, undercutting on price, or out-marketing you) and the company''s own execution (product gaps, distribution issues, customer service problems) before picking one to investigate. Common pitfall: naming only one possible cause instead of laying out a structured set of competitor-side and company-side hypotheses first.'
  where firm_style = 'Boston Consulting Group' and question_text = 'A company''s market share is shrinking even as the overall market grows. What could explain this?';

update interview_questions set difficulty = 'medium', improvement_guide =
  'Build up from a clear population base: estimate the relevant city/region population, the share who''d realistically use a bike subscription, and an average annual subscription price, stating each assumption before multiplying through. Common pitfall: guessing a large round number without showing the population-based build-up the question is testing.'
  where firm_style = 'Boston Consulting Group' and question_text = 'How would you estimate the total addressable market for a new electric bike subscription service?';

update interview_questions set difficulty = 'hard', improvement_guide =
  'Weigh cost and speed to market (acquisition is faster but expensive and carries integration risk; building in-house is slower but avoids overpaying and integration issues), and each option''s effect on competitive dynamics. Common pitfall: focusing only on price/cost while ignoring integration risk and competitive-dynamics considerations.'
  where firm_style = 'Boston Consulting Group' and question_text = 'A client is deciding whether to acquire a competitor or build a competing product in-house. What would you weigh?';

-- ===================== Bain & Company (4) =====================

update interview_questions set difficulty = 'medium', improvement_guide =
  'Focus on the specific trade-off decisions you made under the resource constraint -- what you cut, reprioritized, or did differently -- rather than just describing the shortage itself. Common pitfall: dwelling on how limited the resources were without explaining the concrete adjustments that let you still deliver.'
  where firm_style = 'Bain & Company' and question_text = 'Tell me about a time you had to deliver results with fewer resources than you thought you needed.';

update interview_questions set difficulty = 'medium', improvement_guide =
  'Describe the specific method you used to filter and structure a large amount of information quickly -- a framework, prioritizing by relevance, grouping into themes -- and how that led directly to your recommendation. Common pitfall: describing the volume of information without explaining the actual synthesis method used to cut through it.'
  where firm_style = 'Bain & Company' and question_text = 'Describe a time you had to synthesize a large amount of information quickly to make a recommendation.';

update interview_questions set difficulty = 'medium', improvement_guide =
  'Since revenue is stable but churn is rising (masked by roughly offsetting new signups), structure hypotheses around product/service issues, pricing or a competitor''s new offer, and onboarding/engagement problems -- then describe narrowing down using cohort or survey data. Common pitfall: jumping to a single explanation (usually "price") without laying out multiple hypotheses to test first.'
  where firm_style = 'Bain & Company' and question_text = 'A subscription business has stable revenue but rising customer churn. How would you diagnose the cause?';

update interview_questions set difficulty = 'easy', improvement_guide =
  'Build up from population: estimate the share of the 2,000,000 population with an active gym membership (a stated percentage assumption), multiply through, and sanity-check the result against a plausible per-capita gym membership rate. Common pitfall: giving a number with no visible build-up or stated assumption behind it.'
  where firm_style = 'Bain & Company' and question_text = 'Estimate how many gym memberships are active in a city of two million people.';

-- ===================== Investment Banking Analyst (7) =====================

update interview_questions set difficulty = 'medium', improvement_guide =
  'Name all three statements and trace one concrete example through all of them -- e.g. a revenue increase raises net income, which raises retained earnings on the balance sheet and is the starting point of the cash flow statement. Common pitfall: naming the three statements correctly but failing to actually trace a change through all of them when asked.'
  where firm_style = 'Investment Banking Analyst' and question_text = 'Walk me through the three financial statements and how a change in one flows through the others.';

update interview_questions set difficulty = 'easy', improvement_guide =
  'A merger combines two companies of relatively similar size into a new combined entity; an acquisition is one company purchasing and absorbing another, which typically ceases to exist independently. Common pitfall: using the terms interchangeably without naming the actual distinction -- relative size/structure of the resulting entity.'
  where firm_style = 'Investment Banking Analyst' and question_text = 'What is the difference between a merger and an acquisition?';

update interview_questions set difficulty = 'medium', improvement_guide =
  'Debt doesn''t dilute existing shareholders'' ownership, interest payments are tax-deductible (a "tax shield"), and debt is typically cheaper than equity since lenders take less risk than shareholders -- but it must be repaid regardless of performance, unlike equity. Common pitfall: naming only "debt is cheaper" without mentioning tax deductibility or the dilution trade-off.'
  where firm_style = 'Investment Banking Analyst' and question_text = 'Why would a company choose to raise capital through debt instead of issuing new equity?';

update interview_questions set difficulty = 'hard', improvement_guide =
  'An LBO is buying a company primarily with borrowed money, using the target''s own future cash flows to pay down that debt over time -- returns are amplified because the buyer put in relatively little of their own equity, so a modest overall gain in company value produces a much larger percentage return on that smaller equity investment. Common pitfall: describing "buying a company with debt" without explaining why leverage specifically amplifies equity returns.'
  where firm_style = 'Investment Banking Analyst' and question_text = 'What is an LBO, in simple terms, and why does debt matter so much to its returns?';

update interview_questions set difficulty = 'medium', improvement_guide =
  'Name a specific, repeatable checking method -- re-deriving key numbers a second way, checking a balance sheet still balances, having a colleague spot-check -- rather than a vague "I''m careful." Common pitfall: claiming to always catch every error without describing an actual verification method or process.'
  where firm_style = 'Investment Banking Analyst' and question_text = 'Tell me about a time you had to double-check your own work under a tight deadline. How did you catch errors?';

update interview_questions set difficulty = 'medium', improvement_guide =
  'Describe the specific steps you took to move fast without sacrificing accuracy -- triaging what mattered most, checking in on scope early, a final quality pass -- rather than just describing the long hours. Common pitfall: focusing on effort/hours worked rather than the actual process that produced a polished result under time pressure.'
  where firm_style = 'Investment Banking Analyst' and question_text = 'Describe a time you had to produce a polished deliverable overnight or on very short notice.';

update interview_questions set difficulty = 'medium', improvement_guide =
  'Name specific, genuine reasons tied to the actual work -- pace, deal exposure, analytical rigor, mentorship structure -- rather than generic reasons like prestige or pay that could apply to any high-paying job. Common pitfall: an answer indistinguishable from "why finance in general," which misses the "specifically" in the question.'
  where firm_style = 'Investment Banking Analyst' and question_text = 'Why investment banking specifically, rather than another area of finance?';

-- ===================== Quantitative Analyst (6) =====================

update interview_questions set difficulty = 'medium', improvement_guide =
  'Correlation means two variables move together; causation means one actually produces a change in the other -- confusing them in a model risks building a predictive relationship on a coincidental or confounded pattern that won''t hold up out of sample. Common pitfall: defining the terms correctly without explaining the actual modeling risk -- spurious relationships -- of conflating them.'
  where firm_style = 'Quantitative Analyst' and question_text = 'What is the difference between correlation and causation, and why does that distinction matter in modeling?';

update interview_questions set difficulty = 'easy', improvement_guide =
  'Standard deviation measures how spread out values are around the average; in a risk context, a higher standard deviation of returns means more volatility/uncertainty around the expected outcome, a common proxy for risk. Common pitfall: defining standard deviation mathematically without connecting it to what it actually implies about risk.'
  where firm_style = 'Quantitative Analyst' and question_text = 'Explain what standard deviation measures and why it matters for evaluating risk.';

update interview_questions set difficulty = 'hard', improvement_guide =
  'Resist over-interpreting a small sample: 8/10 heads is well within normal variation for a fair coin, so this single result alone provides very weak evidence of unfairness -- you''d want many more flips before drawing a real conclusion. Common pitfall: concluding the coin is likely unfair based on one small sample, which shows a misunderstanding of statistical variation.'
  where firm_style = 'Quantitative Analyst' and question_text = 'You flip a fair coin 10 times and get 8 heads. What does this tell you, if anything, about the coin''s fairness?';

update interview_questions set difficulty = 'medium', improvement_guide =
  'Overfitting is when a model fits the noise/idiosyncrasies of its training data too closely, so it performs well on data it''s already seen but poorly on new data; recognize it by strong training performance paired with much weaker validation/out-of-sample performance. Common pitfall: defining overfitting only as "too complex a model" without mentioning the actual diagnostic -- a training/validation performance gap.'
  where firm_style = 'Quantitative Analyst' and question_text = 'What is overfitting in a statistical model, and how would you recognize it?';

update interview_questions set difficulty = 'medium', improvement_guide =
  'Describe specifically how you noticed the discrepancy -- a sanity check, an unexpected result, cross-checking against another source -- and what the error turned out to be and its impact once corrected. Common pitfall: stating that you "found an error" without describing the specific method that led you to catch it.'
  where firm_style = 'Quantitative Analyst' and question_text = 'Tell me about a time you found an error in a model or dataset that others had missed.';

update interview_questions set difficulty = 'medium', improvement_guide =
  'Describe the specific simplification or analogy you used to convey the result''s practical implication, focused on what the result meant for a decision rather than the statistical method itself. Common pitfall: over-explaining the technical method to a non-technical audience instead of focusing on the practical implication of the result.'
  where firm_style = 'Quantitative Analyst' and question_text = 'Describe a project where you had to translate a mathematical or statistical result into a plain-language explanation for a non-technical audience.';

-- ===================== Risk Analyst (6) =====================

update interview_questions set difficulty = 'medium', improvement_guide =
  'Market risk is the risk of loss from broad market movements (rates, prices, currencies) affecting many holdings at once; credit risk is the risk that a specific borrower or counterparty fails to repay what they owe. Common pitfall: defining one but not clearly distinguishing it from the other.'
  where firm_style = 'Risk Analyst' and question_text = 'What is the difference between market risk and credit risk?';

update interview_questions set difficulty = 'medium', improvement_guide =
  'Value at risk estimates, at a given confidence level over a given time period, the maximum loss a portfolio is expected not to exceed under normal market conditions -- e.g. a 1-day 95% VaR of $1M means a 5% chance of losing more than $1M in a single day. Common pitfall: describing VaR as "the maximum possible loss" without the confidence-level and time-horizon caveats, a common and important misunderstanding of what VaR actually says.'
  where firm_style = 'Risk Analyst' and question_text = 'What does "value at risk" attempt to measure, in simple terms?';

update interview_questions set difficulty = 'medium', improvement_guide =
  'Hedging lets a firm keep the underlying business or exposure it wants (holding foreign revenue, extending credit to customers) while offsetting the specific risk that exposure carries, rather than giving up a valuable activity entirely just because it carries risk. Common pitfall: implying hedging and avoiding risk are interchangeable, missing that hedging preserves the underlying opportunity.'
  where firm_style = 'Risk Analyst' and question_text = 'Why might a firm choose to hedge a risk rather than simply avoid taking it on in the first place?';

update interview_questions set difficulty = 'medium', improvement_guide =
  'Describe the specific signal that tipped you off -- an assumption nobody had questioned, a stress scenario not yet considered -- and how you raised it and what happened as a result. Common pitfall: stating you found a risk others missed without describing the specific reasoning or check that surfaced it.'
  where firm_style = 'Risk Analyst' and question_text = 'Tell me about a time you identified a risk that others on your team had overlooked.';

update interview_questions set difficulty = 'hard', improvement_guide =
  'Explain the specific trade-off you weighed -- the potential benefit vs. the specific downside scenario and its likelihood/severity -- and how you communicated the "no" constructively, ideally with an alternative. Common pitfall: describing the refusal without explaining the actual risk/benefit reasoning behind it.'
  where firm_style = 'Risk Analyst' and question_text = 'Describe a time you had to say no to a proposal because the risk outweighed the potential benefit.';

update interview_questions set difficulty = 'easy', improvement_guide =
  'Use a plain-language analogy: not putting all your eggs in one basket -- spreading money across different, not-perfectly-correlated investments so a loss in one area is likely offset by stability or gains elsewhere. Common pitfall: using technical terms like "correlation" or "variance" when the question specifically asks for a non-technical explanation.'
  where firm_style = 'Risk Analyst' and question_text = 'How would you explain the concept of diversification to someone with no finance background?';

-- ===================== Operations Analyst (5) =====================

update interview_questions set difficulty = 'medium', improvement_guide =
  'Describe the specific inefficiency or error source you identified, the concrete change you made, and ideally a measurable before/after (time saved, errors reduced). Common pitfall: describing a process change without quantifying or clearly stating what actually improved as a result.'
  where firm_style = 'Operations Analyst' and question_text = 'Describe a process you improved to make it faster or less error-prone.';

update interview_questions set difficulty = 'medium', improvement_guide =
  'Walk through your actual troubleshooting method -- isolating variables, checking recent changes, reproducing the issue -- rather than jumping straight to the fix, since the question is testing your diagnostic process. Common pitfall: skipping straight to how the problem was resolved without describing how you actually found the root cause.'
  where firm_style = 'Operations Analyst' and question_text = 'Tell me about a time you had to troubleshoot a problem when you didn''t immediately know the cause.';

update interview_questions set difficulty = 'medium', improvement_guide =
  'Describe a structured approach: isolate the specific transactions/records causing the mismatch, check for a systematic pattern (timing difference, a specific data field) rather than one-off errors, fix the root cause, and add a control to catch recurrences going forward. Common pitfall: describing only fixing the current mismatch without addressing why it''s recurring or how to prevent it next time.'
  where firm_style = 'Operations Analyst' and question_text = 'What steps would you take if you noticed a recurring reconciliation error between two systems?';

update interview_questions set difficulty = 'easy', improvement_guide =
  'Operations errors compound and often surface downstream -- in reporting, client-facing documents, financial statements -- where they''re costly or embarrassing to unwind, whereas a strategic misjudgment is usually caught and corrected earlier in a review process. Common pitfall: giving a generic "details matter" answer without explaining the specific downstream-consequence reasoning the question is asking for.'
  where firm_style = 'Operations Analyst' and question_text = 'Why does attention to detail matter more in operations roles than it might in a purely strategic role?';

update interview_questions set difficulty = 'hard', improvement_guide =
  'Describe the specific downstream impact clearly -- who was affected and how -- then focus most of the answer on the fix and, ideally, the process change that prevents recurrence, not just an apology. Common pitfall: focusing on how bad the downstream problem was without explaining what you specifically did to fix it and prevent it recurring.'
  where firm_style = 'Operations Analyst' and question_text = 'Tell me about a time a process failure caused a downstream problem for someone else. How did you fix it?';

-- ===================== Fintech Product Manager (6) =====================

update interview_questions set difficulty = 'medium', improvement_guide =
  'Use an explicit framework -- weighing user impact/reach against estimated engineering effort and strategic alignment -- rather than a gut-feel ranking, and be ready to name a specific trade-off you''d make. Common pitfall: listing desirable features without naming any actual prioritization criteria or framework.'
  where firm_style = 'Fintech Product Manager' and question_text = 'How would you prioritize which feature to build next with limited engineering resources?';

update interview_questions set difficulty = 'medium', improvement_guide =
  'Name specific, measurable behavioral metrics tied to the feature''s actual goal -- e.g. savings-goal completion rate, deposit frequency, balance growth over time -- rather than vanity metrics like page views. Common pitfall: proposing a metric like "user satisfaction" with no concrete, measurable definition of what that means or how it''s tracked.'
  where firm_style = 'Fintech Product Manager' and question_text = 'Describe how you would measure whether a new savings feature is actually helping users.';

update interview_questions set difficulty = 'medium', improvement_guide =
  'Describe the specific data or reasoning you used to explain the "no" -- competing priorities, low expected impact, technical risk -- and how you kept the stakeholder relationship constructive. Common pitfall: describing that you said no without explaining how you framed and justified that decision to the stakeholder.'
  where firm_style = 'Fintech Product Manager' and question_text = 'Tell me about a time you had to say no to a stakeholder''s feature request. How did you explain your reasoning?';

update interview_questions set difficulty = 'medium', improvement_guide =
  'Start from the user''s core need -- seeing where money goes, without complex setup -- then describe a concrete, simple flow (auto-categorized transactions, a simple visual breakdown, one clear action like setting a monthly limit) rather than listing every possible feature. Common pitfall: designing a feature-rich, complex tool when the question specifically asks for something simple for a first-time user.'
  where firm_style = 'Fintech Product Manager' and question_text = 'Walk me through how you would design a simple budgeting feature for a first-time user.';

update interview_questions set difficulty = 'medium', improvement_guide =
  'Describe the specific feedback or data point, what it revealed, and the concrete change in direction it caused -- ideally with an outcome. Common pitfall: describing user feedback that was collected but not clearly connected to an actual change in what was built or prioritized.'
  where firm_style = 'Fintech Product Manager' and question_text = 'Describe a time you used user feedback or data to change the direction of a product decision.';

update interview_questions set difficulty = 'hard', improvement_guide =
  'Name concrete considerations: data privacy and security of financial information, KYC/anti-money-laundering requirements if the feature touches money movement, and truthful, non-misleading presentation of fees/terms. Common pitfall: treating a fintech feature like any other consumer app feature with no mention of the regulatory dimensions specific to handling money.'
  where firm_style = 'Fintech Product Manager' and question_text = 'What regulatory or compliance considerations would you expect to matter when designing a new fintech feature?';

-- ===================== Equity Research Associate (6) =====================

update interview_questions set difficulty = 'medium', improvement_guide =
  'A "buy" rating implies the analyst expects meaningful upside relative to the stock''s current price and their fair-value estimate; a "hold" implies the stock is roughly fairly valued with limited expected movement either way -- the rating is driven by the gap between estimated fair value and current price. Common pitfall: describing ratings as generic sentiment ("buy = good, hold = neutral") without tying it to the actual valuation-gap driver.'
  where firm_style = 'Equity Research Associate' and question_text = 'What is the difference between a "buy" rating and a "hold" rating, and what typically drives the difference?';

update interview_questions set difficulty = 'hard', improvement_guide =
  'Build a structured view: estimate the company''s intrinsic value (via a DCF or peer multiples), compare it to the current market price, and check that view against qualitative factors (competitive position, management, industry trends) before concluding whether the gap represents genuine mispricing. Common pitfall: naming a single valuation method without cross-checking it against qualitative context, or without comparing it to the current price at all.'
  where firm_style = 'Equity Research Associate' and question_text = 'Walk me through how you would build an initial view on whether a stock is overvalued or undervalued.';

update interview_questions set difficulty = 'medium', improvement_guide =
  'Name factors like macroeconomic conditions (rates, currency), industry/regulatory shifts, competitor actions, and shifts in overall investor sentiment or risk appetite. Common pitfall: describing only company-specific financial factors when the question explicitly asks what matters beyond the company''s own financials.'
  where firm_style = 'Equity Research Associate' and question_text = 'What factors, beyond a company''s own financials, might change your outlook on its stock?';

update interview_questions set difficulty = 'medium', improvement_guide =
  'Describe specifically what new information changed your view, and be clear that you actually updated your thesis rather than dismissing the conflicting evidence -- this tests intellectual honesty and adaptability. Common pitfall: describing being wrong without describing how you concretely revised your view once new evidence appeared.'
  where firm_style = 'Equity Research Associate' and question_text = 'Tell me about a time your initial thesis on something was proven wrong by new information. What did you do?';

update interview_questions set difficulty = 'medium', improvement_guide =
  'Lead with the practical conclusion -- what this means for their investment -- before the supporting reasoning, using a concrete analogy rather than jargon, and check understanding along the way. Common pitfall: walking a non-technical client through the same level of technical detail you''d use with a colleague, losing their grasp of the actual conclusion.'
  where firm_style = 'Equity Research Associate' and question_text = 'Describe how you would explain a complex investment thesis to a client with limited financial background.';

update interview_questions set difficulty = 'hard', improvement_guide =
  'Earnings growth alone doesn''t guarantee a rising stock price if it still falls short of what was already priced into the stock, or if broader factors (rising rates, sector rotation, guidance for slower future growth) weigh on the multiple investors are willing to pay. Common pitfall: assuming strong earnings should mechanically produce a rising stock price, without accounting for expectations already priced in.'
  where firm_style = 'Equity Research Associate' and question_text = 'Why might a company with strong earnings growth still have a falling stock price?';

-- ===================== General Technical (8) =====================

update interview_questions set difficulty = 'easy', improvement_guide =
  'Time value of money means a dollar today is worth more than a dollar in the future, because today''s dollar can be invested and grow -- this underlies why future cash flows must be discounted in valuation and why borrowing/lending carries interest. Common pitfall: stating the concept as a rule to memorize without explaining why it matters for actual financial decisions like discounting or investment comparisons.'
  where firm_style = 'General Technical' and question_text = 'What is the time value of money, and why does it matter in financial decision-making?';

update interview_questions set difficulty = 'medium', improvement_guide =
  'A fixed-rate loan locks in the same rate for its term, giving payment certainty but no benefit if rates fall; a variable-rate loan''s rate moves with market rates, which can save money if rates fall but exposes the borrower to higher payments if rates rise. Common pitfall: naming the difference without identifying the actual risk each type carries for the borrower.'
  where firm_style = 'General Technical' and question_text = 'What is the difference between a fixed-rate and a variable-rate loan, and what risk does each carry?';

update interview_questions set difficulty = 'easy', improvement_guide =
  'Revenue is total sales; profit is what remains after subtracting all costs -- a company can grow revenue while losing money if its costs (especially fixed or rapidly scaling costs) grow faster than revenue, common for fast-growing but not-yet-efficient companies. Common pitfall: defining revenue and profit correctly but not explaining a concrete mechanism for how the first can grow while the second falls.'
  where firm_style = 'General Technical' and question_text = 'Explain the difference between revenue and profit, and why a company can grow revenue while losing money.';

update interview_questions set difficulty = 'medium', improvement_guide =
  'Cash flow negative means a company is spending more cash than it brings in during a period; it isn''t always a bad sign -- a growing company investing heavily in future capacity can be cash flow negative on purpose, as long as it has enough capital runway and a credible path to positive cash flow later. Common pitfall: treating "cash flow negative" as automatically alarming without considering context like growth-stage investment.'
  where firm_style = 'General Technical' and question_text = 'What does it mean for a company to be "cash flow negative," and is that always a bad sign?';

update interview_questions set difficulty = 'easy', improvement_guide =
  'Opportunity cost is the value of the next-best alternative given up by choosing one option -- money spent on a purchase today is money that could have been invested and grown, so the real "cost" isn''t just the price tag but what that money could have otherwise earned. Common pitfall: defining the term correctly but failing to apply it to a concrete everyday example as the question asks.'
  where firm_style = 'General Technical' and question_text = 'What is opportunity cost, and how would you apply it to a everyday financial decision?';

update interview_questions set difficulty = 'medium', improvement_guide =
  'Build up from a population estimate: estimate the number of small businesses in the city using a rough per-capita business density assumption, then estimate what share don''t already have adequate bookkeeping software, stating each assumption explicitly. Common pitfall: giving a number with no visible build-up or stated per-capita/adoption assumptions.'
  where firm_style = 'General Technical' and question_text = 'Estimate how many small businesses in your city might need basic bookkeeping software.';

update interview_questions set difficulty = 'easy', improvement_guide =
  'Compound interest is interest earned not just on your original principal but also on previously earned interest, so growth accelerates over time -- starting early matters because it gives compounding more time to work, so even modest early contributions can outgrow larger contributions made later. Common pitfall: defining compound interest correctly without explaining why time specifically, not just contribution size, is the key lever.'
  where firm_style = 'General Technical' and question_text = 'What is compound interest, and why does starting to save early matter so much?';

update interview_questions set difficulty = 'hard', improvement_guide =
  'Possible explanations include cost-cutting or efficiency improvements, a favorable shift in product/revenue mix toward higher-margin items, one-time gains (an asset sale, a tax benefit) below the operating line, or reduced interest expense -- name multiple distinct, plausible drivers rather than one. Common pitfall: naming only "cost cutting" when several other distinct explanations (mix shift, one-time items, below-the-line effects) are equally plausible and worth naming.'
  where firm_style = 'General Technical' and question_text = 'A company''s revenue is flat but its net income is rising. What are some possible explanations?';

-- ===================== Safety net =====================
-- If any row above still has a null improvement_guide, a (firm_style,
-- question_text) match failed to hit its target row -- fail loudly here
-- rather than silently shipping an incomplete backfill or a not-null
-- constraint violation with no context about which row is at fault.
do $$
declare
  v_missing_ids uuid[];
begin
  select array_agg(id) into v_missing_ids from interview_questions where improvement_guide is null;

  if v_missing_ids is not null then
    raise exception 'interview_questions rows missing improvement_guide after backfill (ids: %) -- a firm_style/question_text match in 00000000000046 failed to hit; compare exact text against 00000000000019/00000000000035', v_missing_ids;
  end if;
end $$;

alter table interview_questions
  alter column improvement_guide set not null;

alter table interview_questions
  add constraint interview_questions_improvement_guide_not_blank check (length(trim(improvement_guide)) > 0);
