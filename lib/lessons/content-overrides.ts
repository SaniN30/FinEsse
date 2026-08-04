import type { LessonBlock } from "@/lib/lessons/content-blocks";

/**
 * Structured presentation overrides for every lesson, keyed by
 * `${skill_id}:${order_index}` (not skill_id alone — a skill now has several
 * lessons in sequence, and each needs its own distinct block set rather than
 * all lessons of a skill sharing one). When a lesson's `${skill_id}:${order_index}`
 * key has an entry here, `LessonDetail` renders these blocks (concept cards,
 * key terms, tables, steps, diagrams) instead of the raw `content_body`
 * paragraph — same underlying facts as the lesson's `content_body`,
 * restructured for scannability. Lessons with no entry keep rendering their
 * plain `content_body` unchanged.
 *
 * This lives in code rather than the database so it ships without touching
 * the live Supabase migration history (see AGENTS.md's migration-numbering-
 * collision notes) — a lesson's `content_body` remains the source of truth
 * for the facts; adding an entry here is a presentation-only decision and can
 * be migrated into `content_body` later if the team standardizes on that.
 */
export const lessonContentOverrides: Record<string, LessonBlock[]> = {
  // School — compound-interest-basics
  "00000000-0000-0000-0001-000000000005:1": [
    {
      type: "concept",
      title: "Simple vs. compound interest",
      body: "Simple interest is calculated only on the original amount (the \"principal\"). Compound interest is calculated on the principal plus any interest already earned or owed, so it grows faster the longer it's left alone.",
    },
    {
      type: "keyterm",
      term: "Principal",
      definition: "The original amount of money saved or borrowed, before any interest is added.",
    },
    {
      type: "steps",
      title: "£100 at 10% annual compound interest",
      steps: [
        "Year 1: £100 × 1.10 = £110",
        "Year 2: £110 × 1.10 = £121 — interest was earned on last year's £10 of interest too, not just the original £100",
        "Year 3: £121 × 1.10 = £133.10",
      ],
    },
    {
      type: "table",
      caption: "Compound vs. simple interest over 3 years",
      headers: ["Year", "Compound interest", "Simple interest"],
      rows: [
        ["1", "£110.00", "£110.00"],
        ["2", "£121.00", "£120.00"],
        ["3", "£133.10", "£130.00"],
      ],
    },
    {
      type: "mistake",
      body: "Forgetting that compounding applies to debt too: an unpaid credit card balance grows the same way — the longer it's left unpaid, the faster the amount owed grows.",
    },
    {
      type: "takeaway",
      body: "Compound interest grows on principal plus already-earned interest — a small gap versus simple interest at first, but one that grows much larger the longer money (or debt) is left to compound.",
    },
  ],
  // School — budgeting-basics
  "00000000-0000-0000-0001-000000000006:1": [
    {
      type: "concept",
      title: "What a budget actually does",
      body: "A budget is a plan for how money coming in (income) gets allocated across money going out (expenses and savings) over a period of time, usually a month. The first skill is simply tracking where money already goes before trying to change anything.",
    },
    {
      type: "table",
      caption: "The 50/30/20 starting split",
      headers: ["Category", "Guideline share", "What it covers"],
      rows: [
        ["Needs", "~50%", "Expenses you must pay — transport, phone credit"],
        ["Wants", "~30%", "Optional spending that improves quality of life"],
        ["Savings", "~20%", "Money set aside for a future goal"],
      ],
    },
    {
      type: "example",
      title: "Amara's £40 pocket money",
      body: "Using a 50/30/20-style split: £20 to needs (bus fare, phone top-up), £12 to wants (going out with friends), £8 to savings toward a bike in 6 months. Sticking to this gives Amara £48 saved after 6 months (£8 × 6) — visible progress instead of hoping there's \"some left over.\"",
    },
    {
      type: "takeaway",
      body: "Assign every pound a purpose before spending it, rather than spending freely and checking what's left. Track actual spending first, then apply a split like 50/30/20.",
    },
  ],
  // School — banking-and-inflation-basics
  "00000000-0000-0000-0001-000000000007:1": [
    {
      type: "diagram",
      caption: "Two forces acting on your savings",
      nodes: [
        { label: "Your money", sublabel: "in a savings account" },
        { label: "Bank interest", sublabel: "grows the number of pounds" },
        { label: "Inflation", sublabel: "shrinks what each pound buys" },
        { label: "Real return", sublabel: "interest rate − inflation rate" },
      ],
    },
    {
      type: "keyterm",
      term: "Real return",
      definition: "Your interest rate minus the inflation rate — what actually tells you whether your savings are gaining or losing buying power.",
    },
    {
      type: "example",
      title: "Leah's £500 savings",
      body: "Leah earns 3% interest while inflation runs at 5%. Her balance grows to £515 (£500 × 1.03) — more pounds. But the same basket of goods now costs £525 (£500 × 1.05), so her £515 falls £10 short. Her real return is roughly 3% − 5% = −2%: more pounds, less buying power.",
    },
    {
      type: "mistake",
      body: "Looking only at the advertised interest rate and assuming savings are automatically \"growing\" — a savings rate only truly grows wealth if it beats inflation.",
    },
    {
      type: "takeaway",
      body: "Bank interest grows the number of pounds you have; inflation shrinks what each pound buys. The real return (interest minus inflation) is what actually tells you whether you're getting ahead.",
    },
  ],

  // College — financial-statement-analysis
  "00000000-0000-0000-0001-000000000105:1": [
    {
      type: "concept",
      title: "Why ratios, not raw numbers",
      body: "Ratios are standardized numbers that let you judge a company's health without already knowing whether a given figure is a lot or a little for that specific company — they turn raw statement figures into comparable signals across time and across companies.",
    },
    {
      type: "table",
      caption: "Three ratio families",
      headers: ["Family", "Question it answers", "Example ratio"],
      rows: [
        ["Liquidity", "Can the company pay short-term bills?", "Current ratio = current assets / current liabilities"],
        ["Profitability", "How much profit per £ of revenue or equity?", "Net margin = net income / revenue"],
        ["Leverage", "How much of the company is debt-financed?", "Debt-to-equity = total debt / total equity"],
      ],
    },
    {
      type: "example",
      title: "Company A",
      body: "Current ratio = £3.0m / £2.0m = 1.5. Net margin = £900k / £12.0m = 7.5%. Debt-to-equity = £4.0m / £5.0m = 0.8. Read together: comfortable short-term coverage, a modest but real margin, and financing tilted slightly toward equity.",
    },
    {
      type: "mistake",
      body: "Treating a single ratio as meaningful in isolation — a low current ratio might be a real liquidity risk, or simply normal for that industry (a supermarket vs. a heavy manufacturer). Every ratio needs a benchmark.",
    },
    {
      type: "takeaway",
      body: "No ratio is meaningful alone — it needs a benchmark (the company's own trend, or comparable peers) to say whether a number is good, bad, or simply normal for that kind of business.",
    },
  ],
  // College — capital-structure-and-wacc
  "00000000-0000-0000-0001-000000000108:1": [
    {
      type: "keyterm",
      term: "Capital structure",
      definition: "The mix of debt (borrowed money, repaid with interest) and equity (ownership stakes, no fixed repayment) a company uses to finance itself.",
    },
    {
      type: "concept",
      title: "Why debt is \"cheaper\" but not free of risk",
      body: "Debt is usually the cheaper financing source because interest is tax-deductible and lenders take less risk than equity holders. But relying on too much debt raises default risk if the company can't make its payments — real companies target a deliberate balance.",
    },
    {
      type: "steps",
      title: "Computing WACC",
      steps: [
        "Find the weight of debt and weight of equity in the capital structure (e.g. 40% debt / 60% equity)",
        "After-tax cost of debt = cost of debt × (1 − tax rate)",
        "Cost of equity via CAPM = risk-free rate + (beta × equity risk premium)",
        "WACC = (weight of debt × after-tax cost of debt) + (weight of equity × cost of equity)",
      ],
    },
    {
      type: "example",
      title: "40% debt / 60% equity",
      body: "After-tax cost of debt = 6% × (1 − 0.25) = 4.5%. Cost of equity via CAPM = 3% + (1.2 × 6%) = 10.2%. WACC = (0.40 × 4.5%) + (0.60 × 10.2%) = 1.8% + 6.12% = 7.92% — the discount rate this company should use to evaluate its own future cash flows.",
    },
    {
      type: "takeaway",
      body: "WACC blends the after-tax cost of debt and the cost of equity, weighted by how much of the company each source finances — it's the correct discount rate for valuing that company's own cash flows.",
    },
  ],
  // College — credit-risk-basics
  "00000000-0000-0000-0001-000000000106:1": [
    {
      type: "concept",
      title: "What credit risk actually measures",
      body: "Credit risk is the risk that a borrower won't repay what they owe. The core judgment is: how likely is default, and if it happens, how much would actually be recovered?",
    },
    {
      type: "diagram",
      caption: "From rating to lending decision",
      nodes: [
        { label: "Credit rating", sublabel: "AAA (safest) → junk" },
        { label: "Yield spread", sublabel: "compensation for default risk" },
        { label: "DSCR check", sublabel: "cash flow / debt service" },
        { label: "Lending decision", sublabel: "extend, price, or decline" },
      ],
    },
    {
      type: "keyterm",
      term: "Debt service coverage ratio (DSCR)",
      definition: "Operating cash flow ÷ total debt service (principal + interest due). A DSCR of 2.0 means twice the cash needed to cover this year's payments; below 1.0 is a serious warning sign.",
    },
    {
      type: "mistake",
      body: "Seeing a higher-yield bond as automatically the better deal. A 9%-yield bond vs. a 4%-yield bond isn't free extra return — the 5-point spread is compensation for materially higher perceived default risk.",
    },
    {
      type: "takeaway",
      body: "Credit ratings summarize default risk, the extra yield lower-rated borrowers must offer compensates for it, and DSCR is a concrete cash-flow check before extending credit.",
    },
  ],

  // Job-Ready — interview-fundamentals
  "00000000-0000-0000-0001-000000000201:1": [
    {
      type: "concept",
      title: "One interview, three question types",
      body: "Interviews mix behavioral (\"tell me about a time...\"), technical (job-specific knowledge), and fit (\"why this company?\") questions — each type wants a different kind of answer, so recognizing the type comes before answering it well.",
    },
    {
      type: "table",
      caption: "Match your answer to the question type",
      headers: ["Question type", "What it's testing", "What a strong answer gives"],
      rows: [
        ["Behavioral", "How you've actually handled situations", "One specific real story"],
        ["Technical", "Job-specific knowledge", "A clear, structured explanation"],
        ["Fit", "Why this role/company", "Genuine, researched reasons"],
      ],
    },
    {
      type: "example",
      title: "\"Tell me about a time you handled a disagreement\"",
      body: "Weak: \"I'm good at working with people.\" Strong: \"On a group project, a teammate and I disagreed on approach. I suggested we each outline our approach for 10 minutes, then compared trade-offs — we combined both ideas and delivered on time.\" The second gives actual evidence.",
    },
    {
      type: "mistake",
      body: "Answering every question the same way regardless of type — a vague general answer to a behavioral question, or a rambling personal anecdote to a technical one.",
    },
    {
      type: "keyterm",
      term: "Behavioral question",
      definition: "A question asking how you've actually handled a real past situation (\"tell me about a time...\"), best answered with one specific story rather than a general claim about yourself.",
    },
  ],
  // Job-Ready — negotiating-a-job-offer
  "00000000-0000-0000-0001-000000000208:1": [
    {
      type: "concept",
      title: "An offer is an opening position, not a final one",
      body: "Most employers expect a candidate to respond with at least one counter before an offer is finalized. Declining to negotiate at all usually leaves money and terms on the table that the employer already budgeted for.",
    },
    {
      type: "table",
      caption: "What's often negotiable beyond base salary",
      headers: ["Component", "Why it matters"],
      rows: [
        ["Signing bonus", "Can offset a base salary gap"],
        ["Start date", "Flexibility for notice periods or breaks"],
        ["Vacation days", "Often has more room than base pay"],
        ["Remote-work flexibility", "Frequently negotiable even with a fixed salary ceiling"],
      ],
    },
    {
      type: "example",
      title: "$62,000 offer, $60k–$70k market range",
      body: "Weak: accepting immediately, or asking for \"as much as possible.\" Strong: \"Thank you for the offer — based on my research into the market range for this role, I was hoping we could look at something closer to $68,000. Is there flexibility there?\" Specific, research-backed, and polite.",
    },
    {
      type: "mistake",
      body: "Negotiating by bluffing instead of research — an arbitrary ask is easy to dismiss. A number grounded in real market data is defensible.",
    },
    {
      type: "takeaway",
      body: "Initial offers are usually an opening position. Ground any counter in real market research, and negotiate the whole package — not just base salary.",
    },
  ],
  // Job-Ready — case-method-basics
  "00000000-0000-0000-0001-000000000203:1": [
    {
      type: "concept",
      title: "What case interviews actually evaluate",
      body: "Case-method interviews present an open-ended business problem and evaluate how you think, not just whether you reach the \"right\" number. The goal is to structure the problem out loud, state assumptions clearly, and reason toward an estimate step by step.",
    },
    {
      type: "steps",
      title: "A reliable structure",
      steps: [
        "Clarify the question and restate it in your own words",
        "Break the problem into a small number of clear components",
        "Make explicit, reasonable assumptions for anything you don't know — and say them out loud",
        "Work through the math step by step, narrating your reasoning",
        "Sanity-check the final number against something you already know",
      ],
    },
    {
      type: "example",
      title: "\"Estimate coffees sold in this city each day\"",
      body: "Assume 1,000,000 people in the city. Assume ~30% drink coffee regularly = 300,000 coffee drinkers. Assume each drinks 1.2 coffees/day = 360,000 coffees/day. The exact number matters far less than showing clear, sensible assumptions and a step-by-step build-up.",
    },
    {
      type: "diagram",
      caption: "The five-step case structure",
      nodes: [
        { label: "Clarify", sublabel: "Restate the question" },
        { label: "Break down", sublabel: "Split into components" },
        { label: "State assumptions", sublabel: "Say them out loud" },
        { label: "Compute", sublabel: "Work the math step by step" },
        { label: "Sanity-check", sublabel: "Compare to something known" },
      ],
    },
    {
      type: "takeaway",
      body: "Case questions test structured thinking under uncertainty, not trivia recall — clarify, break down, state assumptions, compute step by step, and sanity-check the result.",
    },
  ],

  // ---- School ----
  "00000000-0000-0000-0001-000000000001:2":   [
    {
      type: "concept",
      title: "The barter problem",
      body: "Direct trading of goods only works if both people happen to want what the other has at the same time — a \"double coincidence of wants\" that's often hard to find.",
    },
    {
      type: "keyterm",
      term: "Double coincidence of wants",
      definition: "The barter requirement that each trading partner wants exactly what the other is offering, at the same time — the main reason bartering is inefficient.",
    },
    {
      type: "example",
      title: "Fisherman and barber",
      body: "A fisherman wants a haircut, but the barber has no use for fish. Without money, no trade can happen. With money as a middle step, the fisherman sells fish for cash, then pays the barber in cash — the barber accepts it on trust it will buy something they want later.",
    },
    {
      type: "takeaway",
      body: "Money exists to solve barter's core problem: it lets trade happen between people whose wants don't directly match, because everyone accepts and trusts it as a stand-in for real value.",
    },
  ],
  "00000000-0000-0000-0001-000000000001:3":   [
    {
      type: "concept",
      title: "Money's three jobs",
      body: "Money needs to work as a medium of exchange (accepted in trade), a store of value (holds worth over time), and a unit of account (a common way to compare prices).",
    },
    {
      type: "table",
      caption: "Why fruit and paintings make poor money",
      headers: ["Item", "Fails at"],
      rows: [
        ["Fresh fruit", "Store of value — it rots"],
        ["A rare painting", "Unit of account / medium of exchange — hard to divide for everyday buying"],
      ],
    },
    {
      type: "example",
      title: "Pricing a bike in loaves of bread",
      body: "Without a stable common unit, comparing very different items becomes inconsistent, and \"saving\" 250 loaves for later doesn't work since bread goes stale — showing why a stable currency unit matters.",
    },
    {
      type: "takeaway",
      body: "Coins, notes, and bank balances became standard money because they do all three jobs — hold value, divide easily, and are widely accepted — better than almost anything else.",
    },
  ],
  "00000000-0000-0000-0001-000000000001:1":   [
    {
      type: "concept",
      title: "Why money replaced bartering",
      body: "Before money, people traded goods directly (bartering), which only works if each person happens to want exactly what the other has. Money solves this by being something everyone agrees has value, so it can be traded for anything.",
    },
    {
      type: "keyterm",
      term: "Money",
      definition: "Anything widely accepted as payment for goods and services because people trust it holds value.",
    },
    {
      type: "table",
      caption: "Forms money takes",
      headers: ["Form", "Example"],
      rows: [
        ["Physical", "Coins and banknotes"],
        ["Digital", "A bank account balance, a card payment"],
      ],
    },
    {
      type: "takeaway",
      body: "Money works because everyone agrees it has value — whether it's a coin in your pocket or a number in a bank app, that shared trust is what makes it usable.",
    },
  ],
  "00000000-0000-0000-0001-000000000002:2":   [
    {
      type: "concept",
      title: "Needs with wants layered on top",
      body: "Many purchases blend a real need with an optional upgrade — a basic phone (need) versus the latest expensive model (want layered on top).",
    },
    {
      type: "steps",
      title: "The \"would something bad happen soon\" test",
      steps: ["Ask: would something bad happen soon if I didn't have this?", "If yes — it's likely a genuine need", "If no, or \"I'd just prefer it\" — it's likely a want", "Wants aren't bad to buy, but label them honestly rather than disguising them as needs"],
    },
    {
      type: "example",
      title: "Jaydon's trainers",
      body: "Jaydon calls new trainers a \"need\" over a small scuff. The test says otherwise: nothing bad happens with the current pair, so it's a want — fine to buy if the budget allows, but it shouldn't jump ahead of a genuine need like a broken school bag.",
    },
    {
      type: "mistake",
      body: "Mislabeling a want as a need to justify buying it first, which can push a genuine need further down the priority list.",
    },
    {
      type: "takeaway",
      body: "Sorting purchases honestly — not \"is this nice?\" but \"would something bad happen soon without it?\" — keeps wants from crowding out real needs.",
    },
  ],
  "00000000-0000-0000-0001-000000000002:3":   [
    {
      type: "concept",
      title: "Needs-first ordering",
      body: "Estimate and cover needs first with real money, then spend only what's genuinely left over on wants — not the other way around.",
    },
    {
      type: "table",
      caption: "Priya's £30, needs-first vs. wants-first",
      headers: ["Order", "Outcome"],
      rows: [
        ["Needs first (£13), then wants", "£17 left for wants — no shortfall"],
        ["Wants first (£25), then needs", "Only £5 left for £13 of needs — shortfall"],
      ],
    },
    {
      type: "mistake",
      body: "Spending on wants as they come up and hoping enough is left for needs later — needs don't disappear just because the money already went elsewhere.",
    },
    {
      type: "keyterm",
      term: "Social pressure spending",
      definition: "Feeling a want as urgent because peers have it, even though nothing bad would happen without it — a pull worth recognising rather than mistaking for a real need.",
    },
    {
      type: "takeaway",
      body: "Covering needs first with real money, then spending only what remains on wants, is a safer order than hoping needs get covered after wants are already paid for.",
    },
  ],
  "00000000-0000-0000-0001-000000000002:1":   [
    {
      type: "concept",
      title: "Needs vs. wants",
      body: "A need is essential to live — food, water, shelter. A want is nice to have but not essential — a video game, a second pair of trainers.",
    },
    {
      type: "keyterm",
      term: "Need",
      definition: "Something required to live and function, like food, water, or a place to stay.",
    },
    {
      type: "keyterm",
      term: "Want",
      definition: "Something that improves quality of life but isn't essential to survive.",
    },
    {
      type: "takeaway",
      body: "Good money habits start with covering needs before spending on wants.",
    },
  ],
  "00000000-0000-0000-0001-000000000003:2":   [
    {
      type: "concept",
      title: "Pay yourself first",
      body: "Set aside your savings the moment money arrives, before any spending — rather than saving only what happens to be left over.",
    },
    {
      type: "table",
      caption: "Ben's £20/week over 8 weeks",
      headers: ["Plan", "Approach", "Result"],
      rows: [
        ["A", "Spend freely, save what's left", "Unpredictable, often little"],
        ["B", "Save £5 first, spend the rest", "Reliable £40 saved"],
      ],
    },
    {
      type: "mistake",
      body: "Treating saving as optional \"if there's time\" — spending tends to expand to use whatever money is available if nothing is set aside first.",
    },
    {
      type: "takeaway",
      body: "Saving a smaller amount first, consistently, beats hoping a larger amount is left over — reliability matters more than the size of any single saving.",
    },
  ],
  "00000000-0000-0000-0001-000000000003:3":   [
    {
      type: "concept",
      title: "Separation matters as much as amount",
      body: "Keeping savings visibly or physically separate from everyday spending money makes it harder to dip into by accident and easier to track progress.",
    },
    {
      type: "example",
      title: "Freya's mixed vs. separated money",
      body: "With money all mixed together, Freya can't easily tell if a snack purchase eats into her jacket savings. A separate, labelled \"jacket fund\" forces a deliberate decision before that money is touched.",
    },
    {
      type: "keyterm",
      term: "Interest (on savings)",
      definition: "A small amount a bank adds to a savings balance just for keeping money there, on top of whatever is deposited.",
    },
    {
      type: "mistake",
      body: "Keeping savings and everyday spending money mixed together, which makes accidental spending of savings easy and progress hard to track.",
    },
    {
      type: "takeaway",
      body: "A labelled jar or a separate account — even without much interest — creates a real barrier against accidentally spending savings, and makes progress toward a goal visible.",
    },
  ],
  "00000000-0000-0000-0001-000000000003:1":   [
    {
      type: "concept",
      title: "What saving means",
      body: "Saving means setting money aside now so you can use it later, instead of spending all of it right away. Even small amounts add up over time.",
    },
    {
      type: "keyterm",
      term: "Savings goal",
      definition: "A target amount for something you want, which makes it easier to stick with the saving habit.",
    },
    {
      type: "takeaway",
      body: "A specific savings goal makes saving easier to stick with than a vague intention to \"save more.\"",
    },
  ],
  "00000000-0000-0000-0001-000000000004:2":   [
    {
      type: "concept",
      title: "Not all income is equally reliable",
      body: "A fixed allowance is predictable and safe to plan around; chore-based earning varies; one-off jobs are bonuses, not something to count on for a specific week.",
    },
    {
      type: "table",
      caption: "Sam's income sources by reliability",
      headers: ["Source", "Reliability", "How to treat it"],
      rows: [
        ["£10/week allowance", "Fixed", "Plan spending/saving around it"],
        ["£5 chore pay", "Variable", "Likely, but not guaranteed"],
        ["£8 gardening job", "One-off", "Bonus — don't count on it"],
      ],
    },
    {
      type: "mistake",
      body: "Planning a specific week's spending around a one-off job or chore payment that might not actually happen that week.",
    },
    {
      type: "takeaway",
      body: "Knowing which part of your pocket money is reliable versus a bonus prevents planning spending around money that might not show up.",
    },
  ],
  "00000000-0000-0000-0001-000000000004:3":   [
    {
      type: "concept",
      title: "A consistent split beats a case-by-case decision",
      body: "Deciding a fixed rule (like a percentage to save) once, applied automatically to every bit of income, is easier to stick with than deciding fresh each time money arrives.",
    },
    {
      type: "steps",
      title: "Applying a percentage savings rule",
      steps: ["Total up money earned from any source", "Apply the fixed percentage (e.g. 25%) to find the savings amount", "Move that amount to savings immediately", "Spend the remainder freely"],
    },
    {
      type: "example",
      title: "Dani's 25% rule",
      body: "Earning £20 in a week (allowance + car wash): saves £5, spends £15. Earning £4 in a lighter week: saves £1, spends £3 — the same rule applies automatically regardless of the amount or source.",
    },
    {
      type: "takeaway",
      body: "A percentage-based savings rule, applied automatically to every bit of income, removes the need to decide fresh each time and scales naturally with how much is earned.",
    },
  ],
  "00000000-0000-0000-0001-000000000004:1":   [
    {
      type: "concept",
      title: "Ways to earn pocket money",
      body: "Pocket money can come from an allowance, doing chores, or small jobs like helping a neighbour.",
    },
    {
      type: "keyterm",
      term: "Allowance",
      definition: "A regular amount of money given, often by parents, sometimes tied to chores or responsibilities.",
    },
    {
      type: "takeaway",
      body: "Earning your own money and deciding how to split it between spending and saving is good practice for managing money as an adult.",
    },
  ],
  "00000000-0000-0000-0001-000000000005:2":   [
    {
      type: "concept",
      title: "Rate and time both drive compound growth",
      body: "A small rate difference looks minor over one year but widens dramatically over many years, because growth compounds on an already-larger balance each year.",
    },
    {
      type: "keyterm",
      term: "Rule of 72",
      definition: "A rough shortcut: dividing 72 by the annual interest rate estimates how many years it takes an amount to roughly double.",
    },
    {
      type: "table",
      caption: "Rule of 72 examples",
      headers: ["Rate", "Years to roughly double"],
      rows: [
        ["6%", "72 ÷ 6 = 12 years"],
        ["9%", "72 ÷ 9 = 8 years"],
      ],
    },
    {
      type: "example",
      title: "Starting at 16 vs. 28",
      body: "£500 at 6%, left untouched: starting at 16 (24 years to age 40) roughly doubles twice to ~£2,000; starting at 28 (12 years) roughly doubles once to ~£1,000 — 12 extra years roughly doubles the result.",
    },
    {
      type: "takeaway",
      body: "Extra years of compounding can matter as much as a much bigger contribution made later — starting early is one of the most powerful levers in saving.",
    },
  ],
  "00000000-0000-0000-0001-000000000005:3":   [
    {
      type: "concept",
      title: "Compounding frequency matters",
      body: "The same advertised annual rate produces different actual results depending on how often interest is added — monthly compounding out-earns annual compounding on paper-identical rates.",
    },
    {
      type: "example",
      title: "£1,000 at 12%, annual vs. monthly",
      body: "Compounded once a year: £1,000 × 1.12 = £1,120. Compounded monthly (1% × 12): £1,000 × (1.01)^12 ≈ £1,126.83 — about £6.83 more from more frequent compounding steps.",
    },
    {
      type: "keyterm",
      term: "Compounding frequency",
      definition: "How often interest is calculated and added to a balance — e.g. annually, monthly, or daily — which affects the actual return even at the same headline annual rate.",
    },
    {
      type: "mistake",
      body: "Assuming two products with the same advertised annual rate are identical, without checking how often each one actually compounds.",
    },
    {
      type: "takeaway",
      body: "More frequent compounding produces a slightly higher actual return than the same headline rate compounded just once a year — a real detail worth checking in the fine print.",
    },
  ],
  "00000000-0000-0000-0001-000000000006:2":   [
    {
      type: "concept",
      title: "Track before you plan",
      body: "Most people underestimate their own spending, usually because small frequent purchases don't feel significant individually but add up. Tracking real spending for a couple of weeks before setting a budget avoids building a plan on a wrong guess.",
    },
    {
      type: "steps",
      title: "A simple tracking process",
      steps: ["Write down every purchase, no matter how small, for 1-2 weeks", "Add up the total spent in that period", "Group purchases into categories (needs, wants, savings)", "Compare the real totals against your original guess"],
    },
    {
      type: "example",
      title: "Leo's guess vs. reality",
      body: "Leo guessed £10/week on \"extra stuff\"; tracking showed £17/week — a 70% gap, mostly from small purchases he hadn't been mentally counting.",
    },
    {
      type: "mistake",
      body: "Building a budget on a guessed spending figure instead of tracked real numbers — the plan breaks from day one if the guess was wrong.",
    },
    {
      type: "takeaway",
      body: "A budget is only as good as the numbers it's built on — tracking real spending first, even for just a couple of weeks, makes the resulting plan far more likely to actually work.",
    },
  ],
  "00000000-0000-0000-0001-000000000006:3":   [
    {
      type: "concept",
      title: "Budgets need regular review, not just a plan",
      body: "Checking actual spending against the plan regularly (weekly or monthly) catches problems early, while there's still time to adjust — rather than discovering a shortfall only once money has run out.",
    },
    {
      type: "example",
      title: "Nadia's mid-month check",
      body: "Budgeted £15/month for wants, already at £14 after two weeks. Checking now gives her real options — cut spending for the rest of the month, or recognise the category was set too low and adjust — rather than only finding out at month's end.",
    },
    {
      type: "steps",
      title: "A simple review habit",
      steps: ["Pick a regular check-in point (weekly or mid-month)", "Compare actual spending per category to what was planned", "If overspending, decide: cut back now, or adjust the plan for next time", "Update the budget if a category is consistently unrealistic, rather than repeatedly \"failing\" the same plan"],
    },
    {
      type: "mistake",
      body: "Treating a mismatch between actual and planned spending as a personal failure rather than useful information to adjust the plan or the spending.",
    },
    {
      type: "takeaway",
      body: "Checking a budget regularly against real spending — and being willing to adjust it — is what makes budgeting a genuinely useful ongoing habit rather than a one-time plan that quietly stops matching reality.",
    },
  ],
  "00000000-0000-0000-0001-000000000007:2":   [
    {
      type: "concept",
      title: "Where bank interest actually comes from",
      body: "Banks lend out most of the money deposited with them (like mortgages), earning interest on those loans, and share a portion of that with savers as the interest paid on savings accounts.",
    },
    {
      type: "diagram",
      caption: "How a bank makes savings interest possible",
      nodes: [
        { label: "Savers deposit money", sublabel: "e.g. £1,000" },
        { label: "Bank lends it out", sublabel: "e.g. a mortgage at 5%" },
        { label: "Bank pays savers a share", sublabel: "e.g. 3% to savers" },
        { label: "Bank keeps the difference", sublabel: "covers costs and profit" },
      ],
    },
    {
      type: "keyterm",
      term: "Current account",
      definition: "An everyday account for regular spending, where money moves in and out often — typically pays little or no interest compared to a savings account.",
    },
    {
      type: "example",
      title: "£1,000 deposit example",
      body: "A bank lends deposited money at 5% (e.g. a mortgage) and pays savers 3% — the roughly 2% gap covers the bank's own costs and profit, while savers still earn a real return.",
    },
    {
      type: "takeaway",
      body: "Savings interest exists because banks lend deposited money onward — savings accounts often pay more than current accounts because that money is expected to sit longer, making it more useful for the bank to lend against.",
    },
  ],
  "00000000-0000-0000-0001-000000000007:3":   [
    {
      type: "concept",
      title: "Inflation compounds too",
      body: "A small annual inflation rate compounds over multiple years the same way interest does — each year's rise is calculated on the already-higher price from the year before, not the original price.",
    },
    {
      type: "table",
      caption: "£100 item at 3% annual inflation",
      headers: ["Time", "Naive estimate (3% × years)", "Actual (compounded)"],
      rows: [
        ["10 years", "£130.00", "≈ £134.39"],
        ["20 years", "£160.00", "≈ £180.61"],
      ],
    },
    {
      type: "keyterm",
      term: "Compounded inflation",
      definition: "The effect of inflation building on already-higher prices each year, similar to compound interest — causing prices to rise faster over time than a flat annual rate suggests.",
    },
    {
      type: "mistake",
      body: "Estimating long-term price rises by simply multiplying the annual inflation rate by the number of years, which understates the real, compounded effect.",
    },
    {
      type: "takeaway",
      body: "Because inflation compounds, even a modest annual rate adds up to a much larger increase over 10-20 years than a simple multiplication suggests — a useful reason to plan savings and goals with that compounding in mind.",
    },
  ],
  "00000000-0000-0000-0001-000000000008:2":   [
    {
      type: "concept",
      title: "Fraud protection vs. being tricked into authorising",
      body: "Card fraud protection can often reverse an unauthorised payment made without your knowledge — but offers much weaker protection if you were tricked into approving or sending a payment yourself.",
    },
    {
      type: "table",
      caption: "Two very different scam angles",
      headers: ["Scenario", "Protection level"],
      rows: [
        ["Card stolen and used without knowledge", "Often reversible if reported promptly"],
        ["Tricked into transferring money yourself", "Technically \"authorised\" — much harder to reverse"],
      ],
    },
    {
      type: "example",
      title: "Maya's two scenarios",
      body: "Card stolen and misused: fraud protection can likely reverse it once reported. Tricked by a fake prize message into transferring £50 herself: technically authorised by her, so much harder to undo.",
    },
    {
      type: "mistake",
      body: "Assuming fraud protection covers any scam — it's much weaker once a payment was actively approved or sent by the account holder, even under false pretences.",
    },
    {
      type: "takeaway",
      body: "This is exactly why scams often try to get you to willingly send or approve a payment yourself, rather than stealing your details directly — it's the angle that sidesteps most fraud protection.",
    },
  ],
  "00000000-0000-0000-0001-000000000008:3":   [
    {
      type: "keyterm",
      term: "Two-factor authentication (2FA)",
      definition: "A second proof of identity beyond a password, usually a code sent to your phone — means a leaked password alone isn't enough to get into an account.",
    },
    {
      type: "concept",
      title: "Why password reuse is risky",
      body: "If one site suffers a data breach and your password leaks, anyone with it can try it on your other accounts too — turning one breach into many, unless each important account uses a different password.",
    },
    {
      type: "example",
      title: "Nia's reused password",
      body: "A gaming forum breach leaks Nia's password, which she also used for email and banking — both are now at risk too. A unique banking password would have kept the breach contained to just the forum.",
    },
    {
      type: "steps",
      title: "Basic digital account hygiene",
      steps: ["Turn on two-factor authentication wherever it's offered", "Use a different password for important accounts (email, banking) than for less important ones", "Never share a PIN, password, or 2FA code with anyone, including someone claiming to be from your bank"],
    },
    {
      type: "takeaway",
      body: "Two-factor authentication and unique passwords for important accounts are simple, mostly free habits that sharply limit the damage a single leaked password or breach can cause.",
    },
  ],
  "00000000-0000-0000-0001-000000000008:1":   [
    {
      type: "concept",
      title: "Digital payments remove friction",
      body: "A card tap, phone payment, or app transfer moves value instantly, without the natural friction of handing over physical cash — which is part of why it's easy to spend more than intended digitally.",
    },
    {
      type: "keyterm",
      term: "PIN / password",
      definition: "Proof that a payment is really you — must be kept private like a house key: never shared, never written down somewhere easy to find, never reused everywhere.",
    },
    {
      type: "mistake",
      body: "A message pretending to be your bank asking you to \"confirm\" your PIN or password. A genuine bank or shop never legitimately asks for this by message or call.",
    },
    {
      type: "example",
      title: "Theo's fake \"account locked\" text",
      body: "An urgent text claims his account is locked and asks him to click a link and enter his PIN. Instead of clicking, Theo opens his bank's real app directly and checks there — no such lock exists. The urgency was designed to make him act before thinking.",
    },
    {
      type: "takeaway",
      body: "Treat any request for your PIN or password by message or call as suspicious, and check through the real app or website directly instead of a link — the core habit that avoids most digital payment scams.",
    },
  ],
  "00000000-0000-0000-0001-000000000009:2":   [
    {
      type: "concept",
      title: "Diversification reduces single-company risk",
      body: "Spreading money across many investments rather than one means a single company doing badly has a small effect on your total money, rather than a devastating one.",
    },
    {
      type: "keyterm",
      term: "Fund",
      definition: "A pooled investment that automatically buys small pieces of many different companies at once, letting an investor diversify without researching each company individually.",
    },
    {
      type: "table",
      caption: "Same £1,000, concentrated vs. diversified",
      headers: ["Investor", "Approach", "Bad-year outcome"],
      rows: [
        ["A", "All in one company (-40%)", "£400 loss"],
        ["B", "Spread across 200 companies (-8% overall)", "£80 loss"],
      ],
    },
    {
      type: "mistake",
      body: "Putting a large share of money into a single company, which means that one company's bad year can seriously damage total money, however good the company generally seems.",
    },
    {
      type: "takeaway",
      body: "Diversifying across many investments, often through a fund, limits how much damage any single company's bad performance can do — a core way to manage investing risk.",
    },
  ],
  "00000000-0000-0000-0001-000000000009:3":   [
    {
      type: "concept",
      title: "Fees compound too — even small ones matter",
      body: "Investment fees are typically charged as a yearly percentage regardless of performance, and because they compound the same way growth does, small differences in fee percentage add up to large differences over decades.",
    },
    {
      type: "table",
      caption: "£1,000 at 7% growth over 30 years, by annual fee",
      headers: ["Annual fee", "Net growth rate", "Value after 30 years"],
      rows: [
        ["0.5%", "~6.5%", "≈ £6,614"],
        ["1.5%", "~5.5%", "≈ £4,984"],
      ],
    },
    {
      type: "keyterm",
      term: "Annual fee (fund fee)",
      definition: "An ongoing charge, usually a percentage of the amount invested, taken each year to cover the cost of managing a fund or investment platform — taken regardless of whether the investment gained or lost value that year.",
    },
    {
      type: "mistake",
      body: "Comparing investment options only by their advertised growth rate, without checking the annual fee, which can eat into a large share of that growth over a long time period.",
    },
    {
      type: "takeaway",
      body: "A 1-percentage-point difference in annual fee can mean thousands of pounds' difference over decades, because fees compound the same way growth does — always compare fees alongside expected returns.",
    },
  ],
  "00000000-0000-0000-0001-000000000009:1":   [
    {
      type: "concept",
      title: "Saving vs. investing",
      body: "Saving keeps money safe and accessible with predictable, small growth. Investing means buying a small piece of something (like a company share), hoping its value grows over time — but unlike savings, the value can also go down.",
    },
    {
      type: "keyterm",
      term: "Risk",
      definition: "The trade-off between how much an investment could grow and how much it could lose, directly tied to how long the money can stay invested.",
    },
    {
      type: "example",
      title: "Aisha's £200",
      body: "In savings at 3%, roughly £206 after a year — small but certain. Invested in a share fund averaging 7% a year, it could grow much more over 10 years, but might fall 15% in any single year before recovering. If she needs the £200 back in 3 months, savings is the safer choice.",
    },
    {
      type: "takeaway",
      body: "Match the choice to the timeframe — savings for money needed soon, investing only for money that can stay untouched for years — rather than chasing the highest possible short-term return.",
    },
  ],
  "00000000-0000-0000-0001-000000000010:2":   [
    {
      type: "concept",
      title: "Tax bands apply only to the portion within them",
      body: "Income tax is typically charged in bands at increasing rates, but a higher rate only applies to the slice of income within that band — not retroactively to all income once a higher band is reached.",
    },
    {
      type: "table",
      caption: "Simplified illustrative tax bands",
      headers: ["Band", "Rate"],
      rows: [
        ["Up to £12,000", "0%"],
        ["£12,001 – £50,000", "20%"],
        ["Above £50,000", "40%"],
      ],
    },
    {
      type: "example",
      title: "Earning £51,000",
      body: "Tax is not 40% on the whole £51,000. It's 0% on the first £12,000, 20% on the next £38,000, and 40% only on the final £1,000 — a blended rate across bands, not one flat rate.",
    },
    {
      type: "mistake",
      body: "Believing a pay rise into a higher tax band could leave you with less take-home pay overall — under banded taxation, only the extra income in the new band is taxed at the higher rate, so more income always means more take-home pay.",
    },
    {
      type: "takeaway",
      body: "Tax bands only tax the income within each band at that band's rate — earning more always results in more take-home pay overall in a banded system, never less.",
    },
  ],
  "00000000-0000-0000-0001-000000000010:3":   [
    {
      type: "concept",
      title: "Tax as long-term shared insurance",
      body: "A large share of tax funds systems like healthcare, unemployment support, and pensions, working on a contribute-now, benefit-when-needed basis — not a direct fee for services used that specific year.",
    },
    {
      type: "keyterm",
      term: "Social insurance",
      definition: "The idea that current contributions (like tax) fund support for people who need it now, with the expectation the same system supports today's contributors later in life.",
    },
    {
      type: "example",
      title: "A healthy 22-year-old's tax",
      body: "Barely uses healthcare that year, which can feel like \"wasted\" tax — but the same system is there without a huge bill if they're seriously ill later, and funds the pension they'll rely on decades on.",
    },
    {
      type: "mistake",
      body: "Judging tax as \"wasted\" in a year you personally used few public services, rather than recognising it as funding a system that supports everyone across their whole life, including you when you need it.",
    },
    {
      type: "takeaway",
      body: "Tax-funded systems like healthcare and pensions work as shared, long-term insurance — the value isn't in one year's personal usage, it's in the system being there for everyone whenever they need it.",
    },
  ],
  "00000000-0000-0000-0001-000000000010:1":   [
    {
      type: "concept",
      title: "What tax is for",
      body: "A tax is money collected by the government from people and businesses, used to pay for shared things everyone benefits from — schools, roads, hospitals, and public services. It is a required contribution, not a purchase.",
    },
    {
      type: "table",
      caption: "Two everyday taxes",
      headers: ["Tax", "How it works"],
      rows: [
        ["Income tax", "Taken automatically from wages before the money reaches your bank account"],
        ["VAT (sales tax)", "Added to the price of many things bought in shops"],
      ],
    },
    {
      type: "example",
      title: "Mia's first payslip",
      body: "Advertised at £10/hour, working 10 hours might suggest £100 — but her payslip shows £91 landing in her account after income tax and other automatic deductions. Not a mistake — tax collected at the source.",
    },
    {
      type: "takeaway",
      body: "The amount earned or the sticker price is often not the full amount that ends up in your pocket or that you pay at the till, because of automatic income tax and added sales tax.",
    },
  ],
  "00000000-0000-0000-0001-000000000011:2":   [
    {
      type: "concept",
      title: "Break-even point",
      body: "The number of sales at which total revenue exactly covers all costs — profit is zero. Below it, the venture loses money; above it, each sale adds real profit.",
    },
    {
      type: "steps",
      title: "Calculating break-even",
      steps: ["Find the contribution per unit: selling price minus variable cost per unit", "Divide total fixed costs by the contribution per unit", "The result is the number of units needed to break even"],
    },
    {
      type: "example",
      title: "Zara's break-even: 5 cups",
      body: "Contribution per cup = £1.50 − £0.50 = £1.00. Break-even = £5 fixed cost ÷ £1.00 = 5 cups. Below 5 cups: a loss. Above 5 cups: each cup adds £1.00 of genuine profit.",
    },
    {
      type: "keyterm",
      term: "Contribution per unit",
      definition: "The profit each individual sale contributes toward covering fixed costs, after its own variable cost is subtracted — selling price minus variable cost.",
    },
    {
      type: "takeaway",
      body: "Knowing the break-even point in advance turns starting a venture from a hope into a checkable target: how many sales are actually needed before it's genuinely profitable.",
    },
  ],
  "00000000-0000-0000-0001-000000000011:3":   [
    {
      type: "concept",
      title: "Pricing needs to cover more than materials",
      body: "A common mistake is pricing based only on material cost, forgetting to properly value the time and effort spent making or providing something.",
    },
    {
      type: "example",
      title: "Marcus's bracelets: £1 vs. £3",
      body: "At £1 (materials 80p), Marcus earns only 20p for 20 minutes of work. At £3, accounting for his time and a margin, he earns £2.20 per bracelet — a far more sustainable price, in line with similar handmade items elsewhere.",
    },
    {
      type: "keyterm",
      term: "Cost-plus pricing",
      definition: "A pricing method: calculate the true cost per item (materials plus a reasonable value for time), then add a profit margin on top.",
    },
    {
      type: "mistake",
      body: "Pricing a product based only on material cost while ignoring the value of your own time spent making or providing it.",
    },
    {
      type: "takeaway",
      body: "A sustainable price covers true costs — including a fair value for time — plus a margin, checked against what similar products or services actually sell for elsewhere.",
    },
  ],
  "00000000-0000-0000-0001-000000000011:4":   [
    {
      type: "concept",
      title: "Start small to limit risk",
      body: "Testing an idea with a small trial batch before a large commitment limits how much money is at risk if demand turns out lower than expected, while still providing real evidence.",
    },
    {
      type: "example",
      title: "Priya's trial batch of cards",
      body: "Rather than 100 cards upfront, Priya makes 10 to test actual demand and pricing. If they sell well, she has evidence to scale up; if not, she's only risked a small amount, and can adjust before trying again.",
    },
    {
      type: "mistake",
      body: "Committing a large amount of money to a venture before testing whether there's real demand for it.",
    },
    {
      type: "steps",
      title: "Testing an idea before scaling",
      steps: ["Make or buy a small trial batch", "Sell it and observe real demand and feedback", "If demand is strong, scale up with more confidence", "If demand is weak, adjust pricing, product, or approach before trying again — having risked only a small amount"],
    },
    {
      type: "takeaway",
      body: "A small trial batch turns a guess about demand into real evidence, while keeping the financial risk of an unproven idea low.",
    },
  ],
  "00000000-0000-0000-0001-000000000011:1":   [
    {
      type: "concept",
      title: "Revenue, costs, and profit",
      body: "Revenue is money in from selling something, costs are money out to make and sell it, and profit is whatever is left after subtracting costs from revenue.",
    },
    {
      type: "table",
      caption: "Fixed vs. variable costs",
      headers: ["Type", "Behaviour", "Example"],
      rows: [
        ["Fixed", "Same no matter how much you sell", "A one-off table rental fee"],
        ["Variable", "Scales with how much you sell", "Ingredients per cup sold"],
      ],
    },
    {
      type: "example",
      title: "Zara's lemonade stand",
      body: "Fixed cost £5 table rental, 50p variable cost per cup, sold at £1.50. Selling 20 cups: revenue £30, costs £15 (£10 variable + £5 fixed), profit £15. Selling only 3 cups: revenue £4.50 against £6.50 costs — a £2 loss.",
    },
    {
      type: "takeaway",
      body: "A venture needs enough sales to cover its fixed costs before each additional sale starts contributing real profit.",
    },
  ],
  "00000000-0000-0000-0001-000000000012:2":   [
    {
      type: "concept",
      title: "Credit history affects terms, not just approval",
      body: "A stronger credit history doesn't just make a lender more likely to say yes — it typically results in better loan terms, including a lower interest rate, since lenders price in perceived risk.",
    },
    {
      type: "table",
      caption: "Same £1,000 loan, different credit histories",
      headers: ["Borrower", "History", "Rate offered", "Interest over a year"],
      rows: [
        ["Person A", "Always on time", "8%", "≈ £80"],
        ["Person B", "Several missed payments", "18%", "≈ £180"],
      ],
    },
    {
      type: "keyterm",
      term: "Risk-based pricing",
      definition: "A lender's practice of charging higher interest rates to borrowers considered riskier, to compensate for a higher chance of not being fully repaid.",
    },
    {
      type: "mistake",
      body: "Assuming a missed or late payment only matters if you get caught or penalised immediately — it can raise the cost of borrowing for years afterward through a weaker credit history.",
    },
    {
      type: "takeaway",
      body: "A strong credit history, built by consistently repaying on time, isn't just about being approved for future borrowing — it directly affects how much that future borrowing actually costs.",
    },
  ],
  "00000000-0000-0000-0001-000000000012:3":   [
    {
      type: "concept",
      title: "What the debt is used for matters",
      body: "Debt used for something with a realistic chance of growing in value or future earning ability (like education) differs meaningfully from debt used for something that loses value immediately with no future benefit.",
    },
    {
      type: "table",
      caption: "Two very different £2,000 loans",
      headers: ["Use of borrowed money", "Future benefit"],
      rows: [
        ["Training leading to +£3,000/year income", "Likely outweighs the loan's interest cost"],
        ["Takeaway meals and entertainment", "No future benefit — pure ongoing cost"],
      ],
    },
    {
      type: "keyterm",
      term: "\"Good debt\" vs. \"bad debt\"",
      definition: "An informal way of distinguishing debt likely to pay for itself through future value or earnings (e.g. education) from debt spent on something that loses value immediately with no offsetting benefit.",
    },
    {
      type: "mistake",
      body: "Treating all debt the same, without considering whether what it was spent on has any realistic chance of outweighing the interest cost through future value or earnings.",
    },
    {
      type: "takeaway",
      body: "The real question for any debt isn't just the interest rate — it's whether what the money was actually spent on realistically has a chance of being worth more than what borrowing it costs.",
    },
  ],
  "00000000-0000-0000-0001-000000000012:1":   [
    {
      type: "concept",
      title: "What credit is",
      body: "Credit means borrowing money now with a promise to pay it back later, usually with interest added as the cost of borrowing — the same compounding mechanism from saving, now working against the borrower if not repaid.",
    },
    {
      type: "keyterm",
      term: "Minimum payment",
      definition: "The smallest amount that keeps a credit account from default — not an amount that meaningfully reduces what is owed.",
    },
    {
      type: "example",
      title: "Ravi's £300 purchase",
      body: "On a card charging 20% annual interest, paying only the minimum each month means most of each payment goes to interest, not the original £300 — it can take years to repay, and the total paid can end up well over £400.",
    },
    {
      type: "takeaway",
      body: "Repaying reliably and on time builds a credit history that affects how easily and cheaply you can borrow in future.",
    },
  ],
  "00000000-0000-0000-0001-000000000013:2":   [
    {
      type: "keyterm",
      term: "Excess (deductible)",
      definition: "The set amount a policyholder pays toward a claim themselves before the insurer covers the rest — exists to discourage tiny claims and keep overall premiums lower.",
    },
    {
      type: "concept",
      title: "Excess and premium trade off against each other",
      body: "A higher excess typically comes with a lower ongoing premium, since the insurer takes on less risk of small claims; a lower excess typically costs more in premium.",
    },
    {
      type: "table",
      caption: "Tom's two policy options for a £150 repair",
      headers: ["Policy", "Excess", "Annual premium", "Total cost if claimed"],
      rows: [
        ["A", "£50", "£48", "£98"],
        ["B", "£150", "£30", "£180"],
      ],
    },
    {
      type: "mistake",
      body: "Choosing a policy based only on the lowest premium without checking the excess — a cheap premium with a very high excess can end up more expensive overall if a claim actually happens.",
    },
    {
      type: "takeaway",
      body: "Comparing insurance policies means weighing excess and premium together, not just the headline premium — the better choice depends on how likely and how large a claim is expected to be.",
    },
  ],
  "00000000-0000-0000-0001-000000000013:3":   [
    {
      type: "concept",
      title: "Insurance needs genuine uncertainty",
      body: "Insurance works for losses unpredictable for any one person but statistically predictable across a large group — not for losses that are already certain, already happened, or deliberately caused.",
    },
    {
      type: "example",
      title: "Pre-existing damage isn't insurable",
      body: "A phone already cracked when a policy is taken out isn't a future uncertain risk — most insurers exclude pre-existing damage, covering only genuine future accidental damage from that point on.",
    },
    {
      type: "mistake",
      body: "Deliberately causing damage to claim a payout — this isn't a genuine insurable risk, it's fraud, and it costs the shared pool that funds honest claims.",
    },
    {
      type: "keyterm",
      term: "Pre-existing condition/damage",
      definition: "Damage or a loss that already existed before a policy started — generally excluded from coverage since it isn't a genuinely uncertain future risk.",
    },
    {
      type: "takeaway",
      body: "Insurance is built around genuine uncertainty shared across a large group — that's why it doesn't (and shouldn't) cover losses that are already certain, already happened, or deliberately self-caused.",
    },
  ],
  "00000000-0000-0000-0001-000000000013:1":   [
    {
      type: "concept",
      title: "What insurance trades",
      body: "Insurance trades a smaller, predictable, regular cost (the premium) for protection against a large, unpredictable loss.",
    },
    {
      type: "keyterm",
      term: "Premium",
      definition: "The smaller, predictable, regular amount paid to an insurer in exchange for coverage against a large, unpredictable loss.",
    },
    {
      type: "concept",
      title: "Pooled risk",
      body: "An insurer collects premiums from thousands of people; only a small fraction experience the insured event in any given year, and the pooled premiums cover their payouts.",
    },
    {
      type: "example",
      title: "Priya's phone insurance",
      body: "£60/year to insure a £400 phone. Most years nothing happens. The one year the screen shatters, the insurer covers most of the £150 repair — turning an unexpected large cost into a small, budgeted one.",
    },
    {
      type: "takeaway",
      body: "Not claiming in a given year is not wasted money — it means the covered bad event did not happen, which is exactly what everyone paying in is hoping for.",
    },
  ],
  "00000000-0000-0000-0001-000000000014:2":   [
    {
      type: "concept",
      title: "Pricing and layout shape perception, not value",
      body: "Techniques like charm pricing (£.99 endings) and deliberate store layout are designed to influence buying decisions, independent of whether the underlying deal is actually good.",
    },
    {
      type: "keyterm",
      term: "Charm pricing",
      definition: "Pricing something at £9.99 instead of £10 — makes the price feel meaningfully lower than it actually is, even though the real difference is a single penny.",
    },
    {
      type: "example",
      title: "Milk at the back of the store",
      body: "Essentials people came in for are often placed far from the entrance, meaning shoppers pass many tempting displays along the way — a deliberate layout choice, not coincidence.",
    },
    {
      type: "mistake",
      body: "Treating an eye-level shelf or end-of-aisle \"special offer\" display as automatically the best value in the shop, rather than recognising it as a high-visibility spot often reserved for higher-margin items.",
    },
    {
      type: "takeaway",
      body: "Recognising pricing and layout techniques for what they are — designed to influence, not to indicate value — helps turn automatic purchases into deliberate ones.",
    },
  ],
  "00000000-0000-0000-0001-000000000014:3":   [
    {
      type: "concept",
      title: "Two different kinds of \"return\"",
      body: "Returning something because you changed your mind depends entirely on a shop's own voluntary policy. Returning something genuinely faulty is a stronger, legally-backed right that exists regardless of the shop's printed policy.",
    },
    {
      type: "table",
      caption: "Changed mind vs. genuinely faulty",
      headers: ["Situation", "What applies"],
      rows: [
        ["Changed your mind, item works fine", "Shop's own voluntary return policy — varies a lot"],
        ["Item is faulty, not as described, or not fit for purpose", "Stronger legal right to repair, replacement, or refund"],
      ],
    },
    {
      type: "example",
      title: "Elias's two jackets",
      body: "A jacket that just doesn't suit him: return depends on the shop's own policy. A jacket with a broken zip out of the box: a genuinely faulty item, with a legal right to remedy regardless of the shop's printed policy.",
    },
    {
      type: "mistake",
      body: "Assuming every shop offers the same return policy, or assuming a \"changed my mind\" return and a faulty-item return are treated the same way.",
    },
    {
      type: "takeaway",
      body: "Checking a shop's return policy before buying an expensive item, and knowing the difference between a voluntary policy and a legal right for faulty goods, avoids being stuck with a bad purchase.",
    },
  ],
  "00000000-0000-0000-0001-000000000014:1":   [
    {
      type: "concept",
      title: "Unit price beats sticker price",
      body: "Unit price — the cost per single unit of measure, like per 100g or per item — lets you compare differently-sized packs on equal footing.",
    },
    {
      type: "example",
      title: "500ml vs. 1.5 litre juice",
      body: "£1.20 for 500ml = £0.24 per 100ml. £3.30 for 1.5 litre = £0.22 per 100ml — the larger bottle is genuinely cheaper per unit, even though its sticker price is higher.",
    },
    {
      type: "mistake",
      body: "Buying in bulk only saves money if you'll actually use the extra quantity before it expires — otherwise the \"saving\" is wasted the moment the excess is thrown away.",
    },
    {
      type: "takeaway",
      body: "Discounts and bulk sizes are only genuine savings if the final unit price is actually lower and you will realistically use the full quantity.",
    },
  ],
  "00000000-0000-0000-0001-000000000015:2":   [
    {
      type: "concept",
      title: "Match the approach to the timescale",
      body: "Short-term goals (within about a year) need reliable, accessible saving. Long-term goals (years away) have more time to consider growth-focused approaches, since there's time to recover from short-term dips.",
    },
    {
      type: "table",
      caption: "Amir's two goals",
      headers: ["Goal", "Timescale", "Best-fit approach"],
      rows: [
        ["£150 console", "3 months", "Simple, reliable saving"],
        ["£1,000 by adulthood", "6 years", "More room for a growth-focused approach"],
      ],
    },
    {
      type: "mistake",
      body: "Putting money needed soon into something that could lose value right before it's needed — or leaving money meant for a distant goal sitting in low-growth savings for many years, missing out on growth a longer timeframe could capture.",
    },
    {
      type: "keyterm",
      term: "Time horizon",
      definition: "How far away a goal's deadline is — a key factor in deciding whether reliable saving or a growth-focused approach is more appropriate for that specific goal's money.",
    },
    {
      type: "takeaway",
      body: "A goal's timescale should drive the approach used to save for it — the right approach for a 3-month goal and a 6-year goal is rarely the same one.",
    },
  ],
  "00000000-0000-0000-0001-000000000015:3":   [
    {
      type: "concept",
      title: "Prioritising multiple goals deliberately",
      body: "When more than one goal is active, splitting money by genuine urgency and importance — not just by whatever feels most exciting that week — keeps a true priority from being quietly starved of funds.",
    },
    {
      type: "table",
      caption: "Zainab's £20/week, two approaches",
      headers: ["Approach", "Cushion (£200)", "Console (£150)"],
      rows: [
        ["Even split (£10/£10)", "20 weeks", "15 weeks"],
        ["Priority split (£15/£5)", "≈13-14 weeks", "Slower, then speeds up after cushion is done"],
      ],
    },
    {
      type: "keyterm",
      term: "Priority ranking",
      definition: "Deliberately ordering financial goals by genuine importance (e.g. safety or necessity first) rather than by which one feels most exciting or urgent in the moment.",
    },
    {
      type: "mistake",
      body: "Letting the most exciting or newest goal absorb most of the available savings by default, while a more important goal (like a safety cushion) quietly stalls.",
    },
    {
      type: "takeaway",
      body: "With multiple active goals, deliberately prioritising by genuine importance — often safety before pure enjoyment — gets the goals that matter most funded sooner, without abandoning the others entirely.",
    },
  ],
  "00000000-0000-0000-0001-000000000015:1":   [
    {
      type: "concept",
      title: "Turning intentions into goals",
      body: "A financial goal turns \"I should save more\" into a concrete target: a specific amount, for a specific purpose, by a specific date.",
    },
    {
      type: "steps",
      title: "Working backward from a goal",
      steps: ["Find the total amount needed", "Find the time available", "Divide amount by time to find how much to save per week or month", "Check the result against actual income to see if it's realistic"],
    },
    {
      type: "example",
      title: "Kofi's £120 bike in 12 weeks",
      body: "£120 ÷ 12 = £10/week needed. Earning £15/week, saving £10 and keeping £5 for spending is realistic. In just 4 weeks, it would need £30/week — more than his income, revealing that timeline is unrealistic.",
    },
    {
      type: "takeaway",
      body: "Working backward from a goal makes progress checkable every week and quickly reveals whether a goal is realistic — and if not, which lever (timeline, amount, spending) needs to change.",
    },
  ],

  // ---- College ----
  "00000000-0000-0000-0001-000000000101:2":   [
    {
      type: "concept",
      title: "Institution shapes the role",
      body: "The same job title can mean different daily work depending on what kind of institution it sits inside — a bank, an asset manager, an insurer, or a fintech company.",
    },
    {
      type: "table",
      caption: "Institution types and what they do",
      headers: ["Institution type", "What it does"],
      rows: [
        ["Investment bank", "Advises on deals, raises capital"],
        ["Asset manager / hedge fund", "Manages pooled investor money"],
        ["Commercial / retail bank", "Takes deposits, lends to individuals/businesses"],
        ["Insurance company", "Prices and pools long-horizon risk"],
        ["Fintech company", "Builds the software finance runs on"],
      ],
    },
    {
      type: "example",
      title: "Two \"finance jobs,\" two different days",
      body: "An investment bank M&A analyst works long, client-facing hours building deal models. A fintech risk engineer writes fraud-detection code on a calmer schedule. Both are \"finance jobs\" with almost nothing in common day to day.",
    },
    {
      type: "mistake",
      body: "Picking a role title without checking which institution type it sits inside — the same title (\"risk manager\") can mean spreadsheet-and-meetings work at a bank or code-heavy work at a fintech.",
    },
    {
      type: "takeaway",
      body: "Evaluate a finance career by both the role and the institution type it sits inside — the combination, not the title alone, determines what the job actually feels like day to day.",
    },
  ],
  "00000000-0000-0000-0001-000000000101:3":   [
    {
      type: "concept",
      title: "Recruiting mirrors the job",
      body: "Each finance path's interview process tests what that role actually requires day to day — banking rewards technical polish and networking, quant roles reward raw math/coding ability, and fintech blends product and finance literacy.",
    },
    {
      type: "steps",
      title: "Matching prep to the path",
      steps: ["Identify the specific role and institution type you're targeting, not \"finance\" broadly", "Research what that path's interviews actually test", "Investment banking: technical (valuation/accounting) prep plus networking/internships", "Quant: math, statistics, and coding practice", "Fintech product: case studies plus baseline finance literacy"],
    },
    {
      type: "example",
      title: "Two students, two summers",
      body: "A banking-track student practices DCF/comps walkthroughs and does alumni outreach. A quant-track student builds a coding project and does competitive programming. Each prep matches what their target role's interview actually tests.",
    },
    {
      type: "mistake",
      body: "Preparing the same way for every finance role — banking-style networking doesn't help a quant interview, and pure coding practice doesn't help a banking interview.",
    },
    {
      type: "takeaway",
      body: "Match your preparation to the specific role and institution type you're targeting — the recruiting process for each finance path tests genuinely different skills.",
    },
  ],
  "00000000-0000-0000-0001-000000000101:1":   [
    {
      type: "concept",
      title: "There is no single \"finance job\"",
      body: "Finance careers span very different day-to-day work — advising on deals, building models, managing risk, keeping trades settling, or building the software finance runs on. Pay, hours, and required skills vary a lot across these paths.",
    },
    {
      type: "table",
      caption: "Five common finance roles",
      headers: ["Role", "Core work"],
      rows: [
        ["Investment banker", "Advises companies on raising capital and M&A"],
        ["Quant", "Builds mathematical trading and risk models"],
        ["Risk manager", "Measures and limits a firm's exposure to loss"],
        ["Operations (\"ops\")", "Keeps trades settling and records accurate"],
        ["Fintech product manager", "Builds the software finance runs on"],
      ],
    },
    {
      type: "keyterm",
      term: "M&A",
      definition: "Mergers and acquisitions — the business of companies buying, selling, or combining with one another, a core investment-banking advisory service.",
    },
    {
      type: "mistake",
      body: "Assuming \"working in finance\" means one lifestyle or skill set — a quant's day (heavy coding and statistics) looks nothing like a banker's day (client meetings, pitch decks, long hours around deal closings).",
    },
    {
      type: "takeaway",
      body: "Before targeting \"a career in finance,\" identify which specific role's actual day-to-day work fits your interests and strengths — the label \"finance\" covers roles with almost nothing in common.",
    },
  ],
  "00000000-0000-0000-0001-000000000102:2":   [
    {
      type: "concept",
      title: "Two kinds of claim: equity and debt",
      body: "Equity (stocks) is an ownership stake with no fixed repayment — upside and downside are both uncapped. Debt (bonds) is a loan with a fixed interest schedule, paid before equity holders in a bankruptcy.",
    },
    {
      type: "table",
      caption: "Equity vs. debt claims",
      headers: ["", "Equity", "Debt"],
      rows: [
        ["Claim type", "Residual (whatever's left)", "Fixed (contractual)"],
        ["Paid in bankruptcy", "Last", "First"],
        ["Risk / expected return", "Higher", "Lower"],
      ],
    },
    {
      type: "example",
      title: "$10m raised each way, strong year",
      body: "Bondholders get their fixed 5% ($500,000) regardless of performance. Shareholders split whatever profit is left after that — in a strong year, a much higher return on the same $10 million; in a weak year, potentially nothing.",
    },
    {
      type: "keyterm",
      term: "Residual claim",
      definition: "A claim on whatever value remains after all fixed obligations (like debt interest) are paid — equity holders have a residual claim, which is why their returns are uncapped in both directions.",
    },
    {
      type: "takeaway",
      body: "Equity and debt aren't just \"two ways to raise money\" — they represent fundamentally different risk/return claims, which is why a company's mix of the two (its capital structure) matters.",
    },
  ],
  "00000000-0000-0000-0001-000000000102:3":   [
    {
      type: "keyterm",
      term: "Derivative",
      definition: "A contract whose value is derived from an underlying asset (a stock, bond, commodity, or currency) rather than being that asset itself — options and futures are the two most common types.",
    },
    {
      type: "table",
      caption: "Options vs. futures",
      headers: ["Type", "Obligation"],
      rows: [
        ["Option", "Right, not obligation, to buy/sell at a set price by a date"],
        ["Futures", "Obligation to buy/sell at a set price on a set date"],
      ],
    },
    {
      type: "concept",
      title: "Same instrument, two purposes",
      body: "Derivatives can hedge (reduce risk, like an airline locking in fuel costs) or speculate (take on risk deliberately for profit) — the same contract type serves both purposes depending on who is using it.",
    },
    {
      type: "example",
      title: "Airline fuel futures",
      body: "An airline locks in today's fuel price via a futures contract. If prices rise, it's protected (paid the lower locked-in price). If prices fall, it's locked out of the cheaper price — the cost of certainty.",
    },
    {
      type: "mistake",
      body: "Assuming derivatives are inherently risky or reckless instruments — the same contract that's pure speculation for one party is risk-reducing hedging for the other, depending on their underlying exposure.",
    },
    {
      type: "takeaway",
      body: "Derivatives derive their value from an underlying asset and can be used to either hedge (reduce risk) or speculate (take on risk) — the instrument is neutral; the purpose depends on the user.",
    },
  ],
  "00000000-0000-0000-0001-000000000102:1":   [
    {
      type: "concept",
      title: "Primary vs. secondary market",
      body: "The primary market is where a security is first sold to raise capital for the issuer. The secondary market is where investors then trade that security among themselves — like a stock exchange.",
    },
    {
      type: "diagram",
      caption: "From issuance to trading",
      nodes: [
        { label: "Company issues shares", sublabel: "Primary market — raises capital" },
        { label: "Shares list on exchange", sublabel: "Now tradeable" },
        { label: "Investors trade shares", sublabel: "Secondary market" },
      ],
    },
    {
      type: "keyterm",
      term: "Secondary market",
      definition: "Where investors trade securities among themselves after issuance — prices here move on supply, demand, and new information.",
    },
    {
      type: "mistake",
      body: "Assuming secondary-market price moves change how much money the original issuer raised — they don't; the issuer's cash was fixed at the primary-market sale price.",
    },
    {
      type: "takeaway",
      body: "Capital markets have two distinct stages: raising money (primary market) and trading it afterward (secondary market) — only the first stage moves cash to the issuer.",
    },
  ],
  "00000000-0000-0000-0001-000000000103:2":   [
    {
      type: "concept",
      title: "The two inputs that move a DCF the most",
      body: "A DCF's answer is most sensitive to the discount rate (reflecting risk) and the terminal value (capturing everything beyond the explicit forecast period) — both deserve more scrutiny than the mechanical formula itself.",
    },
    {
      type: "steps",
      title: "How discounting shrinks value over time",
      steps: ["$1,000,000 received in year 1, discounted at 10%: $1,000,000 / 1.10 = $909,091", "$1,000,000 received in year 5, discounted at 10%: $1,000,000 / 1.10^5 = $620,921", "The further out a cash flow is, the more the discount rate shrinks its present value"],
    },
    {
      type: "keyterm",
      term: "Terminal value",
      definition: "The lump-sum value of all cash flows beyond a DCF's explicit forecast period, usually estimated assuming a stable perpetual growth rate — often the majority of a DCF's total value.",
    },
    {
      type: "mistake",
      body: "Treating a DCF's output as precise because the math is exact — a DCF is only as reliable as its discount-rate and terminal-growth-rate assumptions, both of which are judgment calls, not observed facts.",
    },
    {
      type: "takeaway",
      body: "A DCF is a spreadsheet built on two sensitive assumptions (discount rate and terminal growth) — a good analyst stress-tests these, not just the cash-flow forecasts themselves.",
    },
  ],
  "00000000-0000-0000-0001-000000000103:3":   [
    {
      type: "concept",
      title: "Comps lives or dies on peer selection",
      body: "The ratio arithmetic in comps is simple — the real judgment is picking a peer group that's genuinely comparable in industry, size, growth profile, and geography, since multiples differ systematically across these.",
    },
    {
      type: "table",
      caption: "Common valuation multiples",
      headers: ["Multiple", "Best used for"],
      rows: [
        ["P/E", "Companies with stable positive earnings"],
        ["EV/EBITDA", "Comparing across different capital structures/tax situations"],
        ["Price-to-sales", "Early-stage companies without positive earnings yet"],
      ],
    },
    {
      type: "example",
      title: "$50m EBITDA company, 9x peer multiple",
      body: "Three genuinely comparable peers average 9x EV/EBITDA. $50 million × 9 = $450 million estimated enterprise value. Including one badly-matched high-growth peer at 15x would distort the average and the answer.",
    },
    {
      type: "mistake",
      body: "Widening a peer group just to get more data points — a larger sample of poorly-matched companies produces a less reliable multiple than a small sample of genuinely comparable ones.",
    },
    {
      type: "takeaway",
      body: "Comps' reliability comes almost entirely from peer-group quality, not the ratio formula — always ask whether the peers are truly similar before trusting the multiple.",
    },
  ],
  "00000000-0000-0000-0001-000000000103:1":   [
    {
      type: "concept",
      title: "Two roads to the same question",
      body: "Valuing a company means estimating what it's worth. Comps prices a company relative to similar public companies using ratios. DCF estimates value as the sum of expected future cash flows, discounted because money in the future is worth less than money today.",
    },
    {
      type: "keyterm",
      term: "Comparable-company analysis (\"comps\")",
      definition: "Valuing a company by applying valuation ratios (like price-to-earnings) observed at similar public companies.",
    },
    {
      type: "keyterm",
      term: "Discounted cash flow (DCF)",
      definition: "Valuing a company as the sum of its expected future cash flows, each adjusted down (\"discounted\") to reflect that money received later is worth less than money received today.",
    },
    {
      type: "table",
      caption: "Comps vs. DCF",
      headers: ["Method", "Relies on"],
      rows: [
        ["Comps", "Market prices of similar companies"],
        ["DCF", "The company's own projected future cash flows"],
      ],
    },
    {
      type: "takeaway",
      body: "Comps and DCF answer \"what is this company worth\" from two different directions — market-relative pricing versus the company's own projected cash generation — and are usually used together, not alone.",
    },
  ],
  "00000000-0000-0000-0001-000000000104:2":   [
    {
      type: "concept",
      title: "The two links that connect the statements",
      body: "Net income flows from the income statement into the cash flow statement as its starting point. The cash flow statement's ending cash and the period's retained-earnings change both flow onto the balance sheet — these two links make the three statements internally consistent.",
    },
    {
      type: "steps",
      title: "Following $10m of net income through the model",
      steps: ["Income statement: net income = $10 million (includes $2 million depreciation)", "Cash flow statement: start at $10 million, add back $2 million depreciation (non-cash) plus other adjustments → $11 million cash generated", "Balance sheet: cash balance rises by $11 million; retained earnings rises by $10 million net income"],
    },
    {
      type: "keyterm",
      term: "Non-cash item",
      definition: "An expense (like depreciation) that reduces net income on the income statement but doesn't actually use cash in that period — added back in the cash flow statement to get to real cash generated.",
    },
    {
      type: "mistake",
      body: "Building three separate statement tabs that don't actually reference each other's cells — a model where changing revenue on the income statement doesn't automatically update cash and the balance sheet isn't a linked model, it's three disconnected spreadsheets.",
    },
    {
      type: "takeaway",
      body: "A model is only truly \"linked\" if net income flows into cash flow, and cash flow's ending balance plus retained earnings both flow into the balance sheet — verify these connections explicitly, don't assume them.",
    },
  ],
  "00000000-0000-0000-0001-000000000104:3":   [
    {
      type: "concept",
      title: "The balance check as a built-in error catcher",
      body: "A correctly linked model balances (assets = liabilities + equity) in every projected period. An explicit balance-check row (assets − liabilities − equity, which must equal zero) catches broken linkages immediately rather than letting a wrong model produce plausible-looking but incorrect output.",
    },
    {
      type: "example",
      title: "A missed working-capital adjustment",
      body: "Accounts receivable rises $500,000 (revenue recognized, cash not yet received). If the cash flow statement correctly subtracts this as a use of cash, the balance sheet balances. If it's forgotten, cash is overstated by $500,000 and the balance check shows a nonzero error.",
    },
    {
      type: "keyterm",
      term: "Balance check",
      definition: "A model row calculating assets minus liabilities minus equity, which should equal exactly zero in every period if the model's statements are correctly linked — a standard error-detection convention.",
    },
    {
      type: "mistake",
      body: "Trusting a model's output without checking that it actually balances — a model can produce a plausible-looking valuation or projection while silently containing a broken linkage that makes every number downstream wrong.",
    },
    {
      type: "takeaway",
      body: "Always build (and check) an explicit balance-check row before trusting any output from a three-statement model — it's the fastest way to catch a broken linkage.",
    },
  ],
  "00000000-0000-0000-0001-000000000104:1":   [
    {
      type: "concept",
      title: "One model, three linked statements",
      body: "A financial model links the income statement, balance sheet, and cash flow statement so changing one assumption (like revenue growth) flows through consistently to all three.",
    },
    {
      type: "diagram",
      caption: "The three linked statements",
      nodes: [
        { label: "Income statement", sublabel: "Revenue → net income" },
        { label: "Cash flow statement", sublabel: "Net income → cash generated" },
        { label: "Balance sheet", sublabel: "Cash balance updates" },
      ],
    },
    {
      type: "keyterm",
      term: "Assumption",
      definition: "An input an analyst chooses (e.g. revenue growth rate) that drives everything else in the model — changing it should flow through consistently across all three statements.",
    },
    {
      type: "example",
      title: "\"What if\" testing",
      body: "A model lets an analyst test the effect of a price increase or a new cost by changing one input and watching how it flows through the income statement, cash flow, and balance sheet together.",
    },
    {
      type: "takeaway",
      body: "A financial model's value comes from the statements being properly linked — a single changed assumption should update all three consistently, not just one.",
    },
  ],
  "00000000-0000-0000-0001-000000000105:2":   [
    {
      type: "concept",
      title: "ROE can be inflated by leverage, not just performance",
      body: "Return on equity (net income / equity) is a popular profitability measure, but a company can boost its ROE simply by taking on more debt — the DuPont breakdown separates genuine operational strength from leverage-driven ROE.",
    },
    {
      type: "steps",
      title: "The DuPont breakdown",
      steps: ["Net margin = net income / revenue (operational efficiency)", "Asset turnover = revenue / total assets (how efficiently assets generate sales)", "Financial leverage = total assets / equity (how much debt financing is used)", "ROE = net margin × asset turnover × financial leverage"],
    },
    {
      type: "table",
      caption: "Same-ish ROE, different sources",
      headers: ["Company", "Margin", "Turnover", "Leverage", "ROE"],
      rows: [
        ["X", "8%", "1.2x", "2.0x", "19.2%"],
        ["Y", "6%", "1.2x", "3.5x", "25.2%"],
      ],
    },
    {
      type: "mistake",
      body: "Concluding a higher ROE means a stronger business without checking the DuPont breakdown — Company Y's higher ROE above comes from more debt, not better operations, and carries more financial risk.",
    },
    {
      type: "takeaway",
      body: "Always decompose ROE with the DuPont breakdown before comparing companies on it — a high ROE driven by leverage is a materially different (and riskier) story than one driven by genuine margin or efficiency.",
    },
  ],
  "00000000-0000-0000-0001-000000000105:3":   [
    {
      type: "concept",
      title: "Two benchmarks, two different questions",
      body: "Trend analysis (a company's own ratios over time) reveals whether its position is improving or deteriorating. Peer comparison (the same ratio across similar companies) reveals whether a number is actually unusual for that industry. Both are needed.",
    },
    {
      type: "table",
      caption: "Company Z's current ratio over time",
      headers: ["Year", "Current ratio"],
      rows: [
        ["Year 1", "2.2"],
        ["Year 2", "1.9"],
        ["Year 3", "1.5"],
      ],
    },
    {
      type: "example",
      title: "Declining but still normal",
      body: "Company Z's current ratio has declined from 2.2 to 1.5 over three years (a real trend worth investigating) but is still in line with its industry peer average of 1.4 (not unusual for the sector) — the two benchmarks together give a more complete picture than either alone.",
    },
    {
      type: "mistake",
      body: "Comparing a ratio across unrelated industries and drawing a conclusion — a supermarket's naturally low current ratio isn't a liquidity red flag; it reflects fast inventory-to-cash conversion, normal for that business model.",
    },
    {
      type: "takeaway",
      body: "Always check a ratio against both its own trend over time and its industry peer group — either benchmark alone can mislead, but together they distinguish genuine problems from normal industry variation.",
    },
  ],
  "00000000-0000-0000-0001-000000000106:2":   [
    {
      type: "concept",
      title: "Ratings combine ability and willingness to pay",
      body: "A credit rating isn't just a cash-flow ratio — it synthesizes ability to pay (cash flow, leverage, stability) and willingness to pay (payment history, management incentives) into one grade.",
    },
    {
      type: "table",
      caption: "Investment-grade vs. junk",
      headers: ["Tier", "Rough rating range", "Consequence"],
      rows: [
        ["Investment-grade", "BBB-/Baa3 and above", "Many institutional investors permitted to hold it"],
        ["Speculative-grade (\"junk\")", "Below BBB-/Baa3", "Higher yield required; often restricted for institutional funds"],
      ],
    },
    {
      type: "keyterm",
      term: "Fallen angel",
      definition: "A bond downgraded from investment-grade to junk status — can trigger forced selling by funds whose own rules restrict them from holding sub-investment-grade debt.",
    },
    {
      type: "example",
      title: "Same DSCR, different ratings",
      body: "Two companies both have a DSCR of 1.8. A regulated utility with stable cash flows and a clean payment history rates A; a volatile commodity producer with a recent late-payment history rates BB — the rating reflects more than the single ratio.",
    },
    {
      type: "takeaway",
      body: "A credit rating is a synthesis of multiple factors, not a single ratio — and the investment-grade/junk boundary is a real threshold with market consequences, not just a symbolic label.",
    },
  ],
  "00000000-0000-0000-0001-000000000106:3":   [
    {
      type: "concept",
      title: "Seniority determines who gets paid first",
      body: "In a default, recovery depends on where a specific debt instrument sits in the repayment order — senior secured is paid first, then senior unsecured, then subordinated debt, then equity last.",
    },
    {
      type: "steps",
      title: "The repayment order",
      steps: ["Senior secured debt (backed by specific collateral) — paid first", "Senior unsecured debt (general claim, no specific collateral) — paid next", "Subordinated (junior) debt — paid only after senior claims are satisfied", "Equity holders — paid last, often recover nothing"],
    },
    {
      type: "table",
      caption: "$100m recovered, $140m total debt owed",
      headers: ["Claim", "Owed", "Recovery"],
      rows: [
        ["Senior secured", "$60m", "$60m (100%)"],
        ["Senior unsecured", "$50m", "$40m (80%)"],
        ["Subordinated", "$30m", "$0 (0%)"],
      ],
    },
    {
      type: "mistake",
      body: "Assuming all of a company's debt carries the same risk because it's the same borrower — two bonds from the same issuer can have very different recovery prospects (and ratings) purely based on seniority.",
    },
    {
      type: "takeaway",
      body: "Seniority — where a debt instrument sits in the repayment order — determines recovery in a default independently of the borrower's overall creditworthiness, which is why lenders scrutinize the specific claim, not just the company.",
    },
  ],
  "00000000-0000-0000-0001-000000000107:2":   [
    {
      type: "concept",
      title: "The efficient frontier",
      body: "The set of portfolios offering the highest expected return for each risk level (or lowest risk for each return level). A portfolio below the frontier is inefficient — a better combination of the same assets exists.",
    },
    {
      type: "diagram",
      caption: "Risk tolerance determines the point on the frontier, not the math alone",
      nodes: [
        { label: "Efficient frontier", sublabel: "Best risk/return trade-offs available" },
        { label: "Risk-averse investor", sublabel: "Picks a lower-risk point" },
        { label: "Risk-tolerant investor", sublabel: "Picks a higher-return, higher-risk point" },
      ],
    },
    {
      type: "table",
      caption: "Two portfolios, same assets, different weights",
      headers: ["Portfolio", "Stock/Bond/Cash", "Expected return", "Volatility"],
      rows: [
        ["A", "70/20/10", "8%", "14%"],
        ["B", "50/40/10", "6.5%", "9%"],
      ],
    },
    {
      type: "mistake",
      body: "Assuming there's a single \"correct\" portfolio on the efficient frontier — the right point depends on the individual investor's own risk tolerance and time horizon, not a universal optimum.",
    },
    {
      type: "takeaway",
      body: "The efficient frontier shows the best available risk/return combinations, but choosing a specific point on it is a personal risk-tolerance decision, not a math problem with one right answer.",
    },
  ],
  "00000000-0000-0000-0001-000000000107:3":   [
    {
      type: "concept",
      title: "Why portfolios drift from their target",
      body: "A portfolio's actual weights drift away from its target simply because different assets grow at different rates — left unmanaged, a strong multi-year rally in one asset class can shift a portfolio's risk level without any deliberate decision.",
    },
    {
      type: "steps",
      title: "Rebalancing a drifted $120,000 portfolio",
      steps: ["Portfolio starts 60/40 ($60,000 stocks / $40,000 bonds)", "Stocks grow to $80,000, bonds stay $40,000 — now worth $120,000, drifted to 67/33", "Sell $6,000 of stocks, buy $6,000 of bonds", "Restored to $72,000 stocks / $48,000 bonds — exactly 60/40 of $120,000"],
    },
    {
      type: "keyterm",
      term: "Rebalancing",
      definition: "Periodically buying and selling holdings to bring a portfolio's actual weights back to its target allocation, counteracting natural drift caused by different assets growing at different rates.",
    },
    {
      type: "mistake",
      body: "Letting a portfolio drift indefinitely without rebalancing — the resulting mix can become significantly riskier (or more conservative) than originally intended, purely as a side effect of market performance, not a deliberate choice.",
    },
    {
      type: "takeaway",
      body: "Rebalancing restores a portfolio's intended risk level and, as a byproduct, systematically trims recent winners and adds to laggards — a disciplined process, not a bet on which asset will do better next.",
    },
  ],
  "00000000-0000-0000-0001-000000000107:1":   [
    {
      type: "concept",
      title: "Diversification reduces risk, not necessarily return",
      body: "Combining assets that don't move in exactly the same way reduces a portfolio's overall risk. Correlation is the key idea: highly correlated assets barely reduce risk together; low or negatively correlated assets smooth out the portfolio's swings.",
    },
    {
      type: "keyterm",
      term: "Correlation",
      definition: "How closely two assets' returns move together — high correlation means they rise and fall together (little diversification benefit); low or negative correlation means they move more independently (real diversification benefit).",
    },
    {
      type: "steps",
      title: "60% Stock A / 40% Bond B",
      steps: ["Expected return = (0.60 × 10%) + (0.40 × 4%) = 6% + 1.6% = 7.6%", "Volatility is lower than the simple weighted average would suggest, because Stock A and Bond B don't move in lockstep"],
    },
    {
      type: "mistake",
      body: "Expecting diversification to increase expected return — expected return is always just a weighted average of the parts; the benefit shows up specifically in reduced volatility, not extra return.",
    },
    {
      type: "takeaway",
      body: "Expected portfolio return is a straightforward weighted average of the holdings; the diversification benefit shows up in lower-than-average volatility, and only when the holdings aren't perfectly correlated.",
    },
  ],
  "00000000-0000-0000-0001-000000000108:2":   [
    {
      type: "keyterm",
      term: "Tax shield",
      definition: "The reduction in taxable income (and therefore tax owed) that a company gets from deducting interest payments — the reason after-tax cost of debt is lower than the stated interest rate.",
    },
    {
      type: "concept",
      title: "Why debt and equity are treated differently in WACC",
      body: "Interest on debt is tax-deductible; dividends paid to equity holders are not. This asymmetry is why WACC applies a (1 − tax rate) adjustment only to the cost of debt.",
    },
    {
      type: "steps",
      title: "8% interest rate, 30% tax rate",
      steps: ["Stated interest cost: 8%", "Tax shield: interest is deductible, reducing taxable income", "After-tax cost of debt = 8% × (1 − 0.30) = 5.6%"],
    },
    {
      type: "mistake",
      body: "Using a company's stated interest rate directly in WACC without applying the (1 − tax rate) adjustment — this overstates the true cost of debt and produces an inaccurate (too-high) WACC.",
    },
    {
      type: "takeaway",
      body: "Debt's tax deductibility (the tax shield) means its real cost to a company is always below its stated interest rate — capture this with the (1 − tax rate) adjustment when computing WACC.",
    },
  ],
  "00000000-0000-0000-0001-000000000108:3":   [
    {
      type: "concept",
      title: "WACC as a hurdle rate",
      body: "WACC represents the minimum return a company needs to earn to satisfy both its debt and equity investors — it functions as the hurdle rate for deciding whether a new project or investment is worth pursuing.",
    },
    {
      type: "example",
      title: "8% WACC, two projects",
      body: "Project A expects 12% return — clears WACC, creates value. Project B expects 6% return — profitable in absolute terms, but below WACC, meaning it doesn't compensate capital providers enough for the risk taken.",
    },
    {
      type: "table",
      caption: "Comparing projects against WACC",
      headers: ["Project", "Expected return", "vs. 8% WACC", "Decision"],
      rows: [
        ["A", "12%", "Above", "Pursue"],
        ["B", "6%", "Below", "Reject"],
      ],
    },
    {
      type: "mistake",
      body: "Approving a project because it's \"profitable\" without checking it against WACC — a positive return that's still below the company's cost of capital destroys value relative to better uses of that same capital.",
    },
    {
      type: "takeaway",
      body: "WACC is a hurdle rate, not just a valuation input — it changes as a company's financing mix and risk change, and only projects expected to exceed it actually create value for capital providers.",
    },
  ],
  "00000000-0000-0000-0001-000000000109:2":   [
    {
      type: "concept",
      title: "Tracking makes the split real",
      body: "A budget's category split is only useful if actual spending is tracked consistently — the best tracking method is whichever one a specific person will actually keep up with, not the most detailed one.",
    },
    {
      type: "table",
      caption: "Three tracking methods",
      headers: ["Method", "Trade-off"],
      rows: [
        ["Manual spreadsheet/notes", "Full control, requires discipline"],
        ["Auto-categorizing app", "Less manual effort, occasional miscategorization"],
        ["Envelope method", "Strong overspending forcing function, less convenient for cards"],
      ],
    },
    {
      type: "example",
      title: "Abandoned spreadsheet, adopted app",
      body: "A student abandons a detailed spreadsheet after three weeks (too time-consuming) but sticks with an auto-categorizing app six months later — the less granular system won because it was actually sustainable.",
    },
    {
      type: "mistake",
      body: "Choosing the most detailed or \"correct\" tracking system without considering whether you'll actually keep using it — an abandoned system tracks nothing at all.",
    },
    {
      type: "takeaway",
      body: "Pick the budget-tracking method you'll actually sustain, not the most detailed one on paper — consistency matters more than granularity.",
    },
  ],
  "00000000-0000-0000-0001-000000000109:3":   [
    {
      type: "concept",
      title: "Emergency fund vs. routine savings",
      body: "An emergency fund is a separate line from a routine savings goal, sized specifically to absorb one-off shocks (a broken laptop, a medical bill) without resorting to high-interest debt.",
    },
    {
      type: "keyterm",
      term: "Emergency fund",
      definition: "Money set aside specifically to cover unplanned one-off costs, kept separate from savings goals aimed at planned future purchases — a starter target for a student is roughly one to two months of essential fixed costs.",
    },
    {
      type: "example",
      title: "$250 repair, with vs. without a fund",
      body: "With a $600 emergency fund built up over 12 months at $50/month, a $250 laptop repair costs exactly $250. Without one, the same repair on a 22% APR credit card adds ongoing interest cost if not paid off immediately.",
    },
    {
      type: "mistake",
      body: "Relying on a credit card as an implicit emergency fund — it covers the cost in the moment, but at a real ongoing interest cost that a genuine emergency fund avoids entirely.",
    },
    {
      type: "takeaway",
      body: "Build a modest, dedicated emergency fund separate from routine savings — even a small one changes what an unplanned expense actually costs by avoiding high-interest debt.",
    },
  ],
  "00000000-0000-0000-0001-000000000109:1":   [
    {
      type: "concept",
      title: "Fixed vs. variable costs",
      body: "Fixed costs (rent, phone plan, subscriptions) are the same every month and can be planned around with near-certainty. Variable costs (groceries, going out, transportation) change and are the part a budget actually has to manage.",
    },
    {
      type: "table",
      caption: "A rough 50/30/20 starting split",
      headers: ["Category", "Share", "Covers"],
      rows: [
        ["Needs", "~50%", "Housing, food, utilities, required materials"],
        ["Wants", "~30%", "Entertainment, dining out, non-essentials"],
        ["Savings", "~20%", "Emergency cushion or a specific goal"],
      ],
    },
    {
      type: "example",
      title: "$1,000/month effective income",
      body: "$700 from a part-time job + $1,200 refund/term ($300/month). Fixed costs $550, leaving $450. A $240/term textbook bill set aside monthly is $60, leaving $390 for groceries, wants, and savings.",
    },
    {
      type: "mistake",
      body: "Treating a lump-sum refund as all spendable at once, or treating a predictable-but-infrequent cost as a surprise each time — both break a student budget the same way.",
    },
    {
      type: "takeaway",
      body: "Convert irregular income and irregular expenses into an equivalent monthly amount so no single month gets blindsided by a cost that was always coming.",
    },
  ],
  "00000000-0000-0000-0001-000000000110:2":   [
    {
      type: "concept",
      title: "Standard vs. income-driven repayment is a real trade-off",
      body: "A standard plan minimizes total interest for a borrower who can afford the fixed payment. An income-driven plan lowers the payment based on income but can cause the balance to grow if it doesn't cover accruing interest — the right choice depends on income trajectory and forgiveness eligibility.",
    },
    {
      type: "table",
      caption: "Standard vs. income-driven",
      headers: ["", "Standard", "Income-driven"],
      rows: [
        ["Payment based on", "Fixed term/amount", "% of discretionary income"],
        ["Risk", "None (paid off on schedule)", "Negative amortization possible"],
        ["Best suited to", "Stable, sufficient income", "Low income now, or forgiveness track"],
      ],
    },
    {
      type: "example",
      title: "$1,800 payment vs. $2,400 accruing interest",
      body: "An income-driven payment below the year's accruing interest grows the balance by $600 that year. Planned and acceptable on a forgiveness track; a real, avoidable cost otherwise.",
    },
    {
      type: "keyterm",
      term: "Negative amortization",
      definition: "When a loan payment is smaller than the interest accruing that period, causing the balance to grow instead of shrink — a real cost unless the borrower is on a forgiveness track expecting the remaining balance forgiven.",
    },
    {
      type: "takeaway",
      body: "Income-driven repayment is a genuine trade-off suited to specific situations (low current income, forgiveness eligibility), not a universally worse option — evaluate it against your actual income trajectory and forgiveness plans, not in isolation.",
    },
  ],
  "00000000-0000-0000-0001-000000000110:3":   [
    {
      type: "concept",
      title: "Refinancing federal debt is a one-way trade",
      body: "Refinancing a federal loan into a private one can lower the interest rate, but permanently forfeits federal protections — income-driven repayment, deferment, and forgiveness eligibility — even though the rate itself improves.",
    },
    {
      type: "example",
      title: "6% federal → 4% private",
      body: "A graduate refinances $30,000 in federal loans at 6% into a private loan at 4%, saving on interest — but permanently loses eligibility for income-driven repayment and forgiveness, a real cost if their income or career plans change later.",
    },
    {
      type: "mistake",
      body: "Comparing refinancing purely on interest rate — the lower rate is real, but it comes bundled with a permanent, irreversible loss of federal protections that a rate comparison alone doesn't capture.",
    },
    {
      type: "keyterm",
      term: "Refinancing",
      definition: "Taking out a new loan (typically private) to pay off existing loans, usually to secure a lower interest rate — for federal loans, this permanently forfeits federal repayment protections and forgiveness eligibility.",
    },
    {
      type: "takeaway",
      body: "Only refinance federal loans into private ones if you're confident in stable future income and certain you won't need federal protections or forgiveness eligibility later — the decision is bigger than the interest rate alone.",
    },
  ],
  "00000000-0000-0000-0001-000000000110:1":   [
    {
      type: "table",
      caption: "Federal vs. private student loans",
      headers: ["", "Federal", "Private"],
      rows: [
        ["Rates", "Fixed", "Fixed or variable"],
        ["Protections", "Income-driven repayment, deferment, forgiveness", "Typically far fewer"],
      ],
    },
    {
      type: "keyterm",
      term: "Subsidized vs. unsubsidized",
      definition: "Subsidized federal loans don't accrue interest while the borrower is in school; unsubsidized loans start accruing interest immediately, even before the first payment is due.",
    },
    {
      type: "concept",
      title: "Capitalization compounds unpaid interest",
      body: "If accrued interest isn't paid during school or the grace period, it typically capitalizes — gets added to the principal, so future interest is calculated on a larger balance.",
    },
    {
      type: "example",
      title: "$5,000 unsubsidized loan, 5% interest",
      body: "Over 2.5 years in school plus grace period, interest accrues to roughly $625. If it capitalizes at repayment start, the new principal is $5,625 — permanently raising the total cost.",
    },
    {
      type: "takeaway",
      body: "Subsidized loans don't accrue interest in school; unsubsidized loans do from day one. Paying accruing interest during school, even without touching principal, meaningfully reduces total cost.",
    },
  ],
  "00000000-0000-0000-0001-000000000111:2":   [
    {
      type: "concept",
      title: "Overall vs. per-card utilization",
      body: "Utilization is evaluated both in aggregate (total balances / total limits) and per individual card. A single near-maxed card can hurt a score even when overall utilization looks healthy.",
    },
    {
      type: "table",
      caption: "Two cards, overall vs. per-card utilization",
      headers: ["Card", "Limit", "Balance", "Per-card utilization"],
      rows: [
        ["A", "$500", "$450", "90%"],
        ["B", "$5,000", "$0", "0%"],
      ],
    },
    {
      type: "example",
      title: "Overall 8%, but Card A at 90%",
      body: "Aggregate utilization across both cards is about 8% — healthy-looking. But Card A's individual 90% utilization can still hurt the score, since scoring models flag any single near-maxed card.",
    },
    {
      type: "keyterm",
      term: "Per-card utilization",
      definition: "The balance on one specific credit card divided by that card's own limit — evaluated separately from overall utilization across all cards, and can hurt a score even when the aggregate looks fine.",
    },
    {
      type: "takeaway",
      body: "Watch utilization on each individual card, not just the aggregate — a limit increase on a near-maxed card (without new spending) can meaningfully improve a score by lowering that card's per-card ratio.",
    },
  ],
  "00000000-0000-0000-0001-000000000111:3":   [
    {
      type: "concept",
      title: "Closing an old card can hurt a score",
      body: "Length of credit history rewards accounts that have simply existed for a long time. Closing an old, unused card removes available credit and can eventually shorten the average age of accounts on file — both can lower a score.",
    },
    {
      type: "example",
      title: "Closing an 8-year-old card",
      body: "Three cards aged 8, 3, and 1 year average 4 years. Closing the 8-year-old card removes its available credit now and, once it drops off the report, lowers the average account age to 2 years across the remaining cards.",
    },
    {
      type: "mistake",
      body: "Closing an old, no-fee credit card as routine \"cleanup\" — it feels harmless but can lower a score by removing available credit and shortening average account age, a factor that only rebuilds with time.",
    },
    {
      type: "keyterm",
      term: "Length of credit history",
      definition: "A scoring factor based on how long credit accounts have existed — rewards patience and account longevity, which is why closing old accounts (even unused ones) can hurt a score.",
    },
    {
      type: "takeaway",
      body: "Keep old, no-fee credit cards open even if rarely used — closing them can lower a score by removing available credit and eventually shortening average account age, both difficult to rebuild quickly.",
    },
  ],
  "00000000-0000-0000-0001-000000000111:1":   [
    {
      type: "concept",
      title: "What builds a credit score",
      body: "A credit score summarizes lending risk from past borrowing behavior: payment history (largest factor), credit utilization, length of credit history, credit mix, and new credit.",
    },
    {
      type: "keyterm",
      term: "Credit utilization",
      definition: "The percentage of total available credit currently in use across all cards — commonly recommended to stay under 30%, since a high ratio signals higher risk even if paid off in full each month.",
    },
    {
      type: "table",
      caption: "Minimum payment vs. paying in full",
      headers: ["", "$2,000 balance, 22% APR"],
      rows: [
        ["Minimum payment ($50/mo)", "~$37/month interest — barely reduces balance"],
        ["Paid in full each cycle", "$0 interest (grace period)"],
      ],
    },
    {
      type: "mistake",
      body: "Assuming the minimum payment is a safe way to manage a balance — it's set low enough that a large balance can take years and hundreds of dollars in interest to pay off.",
    },
    {
      type: "takeaway",
      body: "Payment history and utilization matter most to a credit score; paying a statement in full every cycle avoids interest entirely thanks to the grace period.",
    },
  ],
  "00000000-0000-0000-0001-000000000112:2":   [
    {
      type: "concept",
      title: "Index funds vs. actively managed funds",
      body: "Index funds hold a market index's securities to match its return at low cost. Actively managed funds pick specific securities aiming to beat the index, at meaningfully higher fees — most fail to beat the index after fees, over long periods.",
    },
    {
      type: "table",
      caption: "Fee comparison over 20 years",
      headers: ["Fund type", "Annual fee", "Return needed to match index net of fees"],
      rows: [
        ["Index fund", "0.05%", "6.95% net (7% gross)"],
        ["Active fund", "1%", "8% gross just to tie"],
      ],
    },
    {
      type: "keyterm",
      term: "Index fund",
      definition: "A fund that holds all or a representative sample of a market index's securities, aiming to match (not beat) that index's return, typically at low cost.",
    },
    {
      type: "mistake",
      body: "Assuming a higher-fee actively managed fund is worth it because a skilled manager might beat the market — historically, most active funds fail to beat their comparable index after fees, over long time horizons.",
    },
    {
      type: "takeaway",
      body: "A fund's fee is a certain, compounding cost; beating the market is not certain — this is why low-cost index funds are the standard baseline recommendation for most long-term investors.",
    },
  ],
  "00000000-0000-0000-0001-000000000112:3":   [
    {
      type: "concept",
      title: "Dollar-cost averaging removes timing pressure",
      body: "Investing a fixed amount at regular intervals, regardless of price, buys more shares when prices are low and fewer when high — averaging the purchase price over time and removing the pressure to pick the single best entry point.",
    },
    {
      type: "steps",
      title: "$100/month over four months",
      steps: ["Month 1: price $20 → buy 5 shares", "Month 2: price $25 → buy 4 shares", "Month 3: price $20 → buy 5 shares", "Month 4: price $15 → buy 6.67 shares", "Total: 20.67 shares for $400, average cost ~$19.35/share"],
    },
    {
      type: "keyterm",
      term: "Dollar-cost averaging",
      definition: "Investing a fixed amount at regular intervals regardless of price, which averages the purchase cost over time and removes the need to time the market perfectly.",
    },
    {
      type: "mistake",
      body: "Waiting indefinitely for a \"better\" moment to invest a lump sum — many investors trying to time the market end up delaying so long that they simply never invest at all.",
    },
    {
      type: "takeaway",
      body: "Dollar-cost averaging is as much a behavioral discipline as a mathematical one — it replaces the near-impossible goal of perfect timing with a consistent, automatic process.",
    },
  ],
  "00000000-0000-0000-0001-000000000112:1":   [
    {
      type: "concept",
      title: "Risk and return trade off",
      body: "Investing means accepting some risk of loss in exchange for expected growth. Higher expected return generally comes with higher risk — there's no investment offering high returns with no risk.",
    },
    {
      type: "table",
      caption: "Two building-block asset classes",
      headers: ["Asset class", "What it is", "Risk/return"],
      rows: [
        ["Stocks", "Ownership share in a company", "Higher risk, higher expected return"],
        ["Bonds", "A loan to a company or government", "Lower risk, lower expected return"],
      ],
    },
    {
      type: "keyterm",
      term: "Diversification",
      definition: "Spreading money across many different investments rather than concentrating it in one, reducing risk since it's unlikely everything drops in value at once for the same reason.",
    },
    {
      type: "mistake",
      body: "Chasing an investment promising high returns with no real risk — no legitimate investment offers that combination.",
    },
    {
      type: "takeaway",
      body: "Accept that risk and expected return move together, and use diversification across stocks, bonds, and other assets to manage that risk rather than eliminate it.",
    },
  ],
  "00000000-0000-0000-0001-000000000113:2":   [
    {
      type: "concept",
      title: "Marginal, not flat, taxation",
      body: "A progressive tax system taxes different portions of income at different rates — only income within a given bracket is taxed at that bracket's rate, not the entire income at the top rate reached.",
    },
    {
      type: "steps",
      title: "$30,000 income, 10%/20% brackets ($10,000 threshold)",
      steps: ["First $10,000 taxed at 10% = $1,000", "Remaining $20,000 taxed at 20% = $4,000", "Total tax = $5,000 (effective rate ~16.7%, below the 20% marginal rate)"],
    },
    {
      type: "keyterm",
      term: "Marginal tax rate",
      definition: "The tax rate applied to the last dollar of income earned, within the highest bracket reached — distinct from the effective (average) tax rate paid across all income.",
    },
    {
      type: "mistake",
      body: "Believing a raise that pushes you into a higher tax bracket reduces your overall take-home pay — only the portion of income within the new bracket is taxed at the higher rate; earning more never reduces take-home pay.",
    },
    {
      type: "takeaway",
      body: "A marginal tax system only raises the rate on income within each new bracket — never assume a raise or bonus that crosses a bracket threshold will reduce your net pay.",
    },
  ],
  "00000000-0000-0000-0001-000000000113:3":   [
    {
      type: "concept",
      title: "A pay stub has more than one deduction",
      body: "Beyond income tax, payroll taxes (funding specific programs like Social Security/Medicare) and pre-tax benefit deductions (health insurance, retirement contributions) both reduce a paycheck — and pre-tax deductions also lower taxable income.",
    },
    {
      type: "table",
      caption: "$50,000 salary, worked example",
      headers: ["Item", "Effect"],
      rows: [
        ["Payroll tax (~7.65%)", "~$3,825 withheld"],
        ["5% pre-tax 401(k) contribution", "$2,500 saved; taxable income drops to $47,500"],
      ],
    },
    {
      type: "keyterm",
      term: "Pre-tax deduction",
      definition: "An amount (like a retirement contribution or health insurance premium) subtracted from gross pay before income tax is calculated, lowering taxable income as a secondary benefit beyond the deduction's direct value.",
    },
    {
      type: "mistake",
      body: "Comparing job offers purely on headline salary without considering payroll tax and available pre-tax benefits — actual take-home pay and total compensation value can differ meaningfully between two offers with the same headline number.",
    },
    {
      type: "takeaway",
      body: "Read a full pay stub, not just the offer letter's salary figure — payroll taxes and pre-tax benefit deductions both shape real take-home pay, and pre-tax contributions carry a genuine secondary tax benefit.",
    },
  ],
  "00000000-0000-0000-0001-000000000113:1":   [
    {
      type: "concept",
      title: "Gross pay vs. what actually arrives",
      body: "Gross pay is what an employer agrees to pay before anything is withheld. Taxes and other deductions are subtracted before the paycheck reaches the employee — net pay, not gross pay, is what's actually available to spend.",
    },
    {
      type: "keyterm",
      term: "Withholding",
      definition: "Tax an employer automatically deducts from each paycheck and sends to the government on the employee's behalf, based on information the employee provides (like a W-4 in the US).",
    },
    {
      type: "table",
      caption: "Gross pay vs. net pay",
      headers: ["", "What it means"],
      rows: [
        ["Gross pay", "Agreed salary before any deductions"],
        ["Net pay", "What actually lands in the bank account after tax and other withholding"],
      ],
    },
    {
      type: "mistake",
      body: "Budgeting off a gross salary figure — the actual spendable amount is meaningfully lower once tax withholding and other deductions are subtracted.",
    },
    {
      type: "takeaway",
      body: "Always budget off net pay (what actually arrives), not the gross salary figure quoted in an offer — the gap between the two can be substantial.",
    },
  ],
  "00000000-0000-0000-0001-000000000114:2":   [
    {
      type: "concept",
      title: "Time in the market beats amount contributed",
      body: "Money contributed early has more years to compound. A smaller amount contributed early can grow to more than a larger amount contributed later, because each early dollar has decades longer to compound.",
    },
    {
      type: "example",
      title: "10 years early vs. 30 years late",
      body: "Contributing $200/month from 25-35 ($24,000 total) then stopping typically grows to more by 65 than contributing $200/month from 35-65 ($72,000 total) — despite contributing three times less, because the early contributions compounded far longer.",
    },
    {
      type: "keyterm",
      term: "Compounding horizon",
      definition: "The number of years a contribution has to grow before it's needed — the single biggest lever in retirement saving, often outweighing the total amount contributed.",
    },
    {
      type: "mistake",
      body: "Waiting to start retirement contributions until you can contribute \"a meaningful amount\" — the years lost waiting cost more in lost compounding than starting small immediately.",
    },
    {
      type: "takeaway",
      body: "Start retirement contributions as early as possible, even at a small amount — the compounding horizon matters more than the size of any individual contribution.",
    },
  ],
  "00000000-0000-0000-0001-000000000114:3":   [
    {
      type: "concept",
      title: "Retirement accounts trade accessibility for tax benefits",
      body: "Early withdrawal from a traditional 401(k)/IRA before age 59½ typically triggers both ordinary income tax and an early-withdrawal penalty, on top of losing future compounding — a deliberate structure discouraging near-term use of retirement funds.",
    },
    {
      type: "steps",
      title: "Cost of a $10,000 early withdrawal",
      steps: ["Income tax at 22%: $2,200", "Early-withdrawal penalty at 10%: $1,000", "Total lost immediately: $3,200 — only $6,800 actually received", "Plus: permanently forfeited decades of future compounding on the full $10,000"],
    },
    {
      type: "keyterm",
      term: "Early-withdrawal penalty",
      definition: "An additional penalty (commonly 10% in the US) charged on withdrawals from a traditional retirement account before age 59½, on top of ordinary income tax — designed to discourage using retirement funds for near-term needs.",
    },
    {
      type: "mistake",
      body: "Treating a retirement account as an accessible emergency fund — the tax and penalty cost, plus lost future compounding, make early withdrawal one of the more expensive ways to cover an unplanned expense.",
    },
    {
      type: "takeaway",
      body: "Keep a separate emergency fund for near-term needs — retirement accounts are structured with real tax and penalty costs specifically to discourage using them for anything but genuine long-term retirement saving.",
    },
  ],
  "00000000-0000-0000-0001-000000000114:1":   [
    {
      type: "concept",
      title: "401(k) match is free money",
      body: "A 401(k) lets an employee contribute part of their paycheck, often with an employer match — commonly some percentage of what the employee contributes, up to a cap. Contributing at least up to the full match is one of the most repeated pieces of financial advice, since turning it down forfeits part of your own compensation.",
    },
    {
      type: "table",
      caption: "Traditional vs. Roth",
      headers: ["", "Contributions", "Withdrawals"],
      rows: [
        ["Traditional", "Pre-tax (lowers taxable income now)", "Taxed as ordinary income in retirement"],
        ["Roth", "After-tax (no upfront break)", "Qualified withdrawals tax-free, including growth"],
      ],
    },
    {
      type: "keyterm",
      term: "IRA",
      definition: "Individual Retirement Account — opened independently rather than through an employer, usable alongside or instead of a 401(k), subject to its own annual contribution limit.",
    },
    {
      type: "mistake",
      body: "Contributing less than the full employer match — that's walking away from part of your own compensation, since the match only appears if you contribute enough to claim it.",
    },
    {
      type: "takeaway",
      body: "Whether Roth or traditional is better depends largely on whether you expect a higher or lower tax bracket in retirement than now — paying tax now (Roth) tends to be better if you expect your rate to rise later.",
    },
  ],
  "00000000-0000-0000-0001-000000000115:2":   [
    {
      type: "concept",
      title: "Choosing between plans is a personal probability estimate",
      body: "A lower-premium/higher-deductible plan minimizes guaranteed cost but risks a larger bill if care is needed. A higher-premium/lower-deductible plan costs more every month but caps the downside — the right choice depends on your own realistic likelihood of needing care.",
    },
    {
      type: "table",
      caption: "Plan A vs. Plan B, with and without a claim",
      headers: ["Scenario", "Plan A ($50/mo, $3,000 ded.)", "Plan B ($150/mo, $500 ded.)"],
      rows: [
        ["No claims (1 year)", "$600", "$1,800"],
        ["$2,000 medical bill", "$2,600", "$2,300"],
      ],
    },
    {
      type: "example",
      title: "The break-even depends on claim likelihood",
      body: "Plan A wins in a healthy year with no claims. Plan B wins once a real, meaningful medical bill arises. Neither plan is universally better — the right pick depends on realistically estimating your own odds of needing care.",
    },
    {
      type: "mistake",
      body: "Always picking the lowest-premium plan without considering realistic claim likelihood — it wins in a healthy year but can cost more overall if even one real medical need arises.",
    },
    {
      type: "takeaway",
      body: "Compare plans by modeling both a no-claims scenario and a realistic claims scenario, not just the premium alone — the better plan depends on your own likely usage.",
    },
  ],
  "00000000-0000-0000-0001-000000000115:3":   [
    {
      type: "concept",
      title: "Two commonly underweighted coverages",
      body: "Auto insurance's legal minimum liability limit often isn't enough real protection if a serious accident happens. Disability insurance, often skipped by young healthy people, covers a real and often underestimated risk of losing income to illness or injury.",
    },
    {
      type: "table",
      caption: "Auto insurance components",
      headers: ["Component", "Covers"],
      rows: [
        ["Liability", "Damage/injury you cause to others (often just the legal minimum)"],
        ["Collision", "Damage to your own car, regardless of fault"],
        ["Comprehensive", "Non-collision events — theft, weather damage"],
      ],
    },
    {
      type: "example",
      title: "Minimum liability, $60,000 accident",
      body: "A driver with a $25,000 liability limit causes $60,000 in damage — the insurer pays $25,000, and the driver is personally liable for the remaining $35,000, a gap higher liability limits would have covered.",
    },
    {
      type: "mistake",
      body: "Defaulting to the legal minimum auto liability coverage without considering real exposure, and skipping disability insurance as a young, healthy person — both underweight real, non-trivial financial risks.",
    },
    {
      type: "takeaway",
      body: "Carry auto liability coverage meaningfully above the legal minimum if affordable, and seriously evaluate disability insurance even when young and healthy — both cover real risks that are easy to underestimate.",
    },
  ],
  "00000000-0000-0000-0001-000000000115:1":   [
    {
      type: "concept",
      title: "Insurance pools risk",
      body: "Many people pay a smaller, predictable premium into a shared pool, so that when a much larger, unpredictable loss happens to any one of them, the pool covers it — a small certain cost in exchange for protection from a large uncertain one.",
    },
    {
      type: "table",
      caption: "Core policy terms",
      headers: ["Term", "Meaning"],
      rows: [
        ["Premium", "Recurring amount paid to keep coverage active"],
        ["Deductible", "Paid out of pocket before insurance starts paying"],
        ["Copay", "Fixed amount paid per service after the deductible is met"],
        ["Out-of-pocket maximum", "Most you'll pay in a period before insurer covers 100%"],
      ],
    },
    {
      type: "keyterm",
      term: "Premium/deductible trade-off",
      definition: "A plan with a lower premium usually has a higher deductible (pay less monthly, more if something happens); a higher premium usually has a lower deductible — neither is universally better.",
    },
    {
      type: "mistake",
      body: "Assuming a landlord's insurance covers a tenant's belongings — it typically only covers the building, which is why renters insurance (inexpensive) matters even when renting.",
    },
    {
      type: "takeaway",
      body: "For a young adult, health, renters, and auto insurance (where applicable) matter most; term life insurance is generally only worth considering once someone has dependents.",
    },
  ],
  "00000000-0000-0000-0001-000000000116:2":   [
    {
      type: "keyterm",
      term: "Anchoring",
      definition: "The psychological tendency for the first number mentioned in a negotiation to disproportionately influence the final outcome — the reason it's usually stronger to let the employer name a number first.",
    },
    {
      type: "concept",
      title: "Why deflecting an early salary question helps",
      body: "Naming your own number first, especially a cautious one, can anchor an employer's later offer below what the role was actually budgeted for. Redirecting toward the employer's range protects against this.",
    },
    {
      type: "example",
      title: "Two candidates, same $70k-$85k budget",
      body: "Candidate A states \"around $65,000\" early and gets anchored to a $65,000-$68,000 offer. Candidate B redirects toward the employer's budgeted range, learns it's $70,000-$85,000, and negotiates up from a $78,000 opening offer.",
    },
    {
      type: "mistake",
      body: "Naming a specific expected salary early in a process, especially a cautious/low one, out of a desire to seem reasonable — it can anchor the entire negotiation below the role's actual budgeted range.",
    },
    {
      type: "takeaway",
      body: "Deflect an early request for a specific salary number toward the employer's own budgeted range rather than naming your own figure first — anchoring makes the first number mentioned disproportionately powerful.",
    },
  ],
  "00000000-0000-0000-0001-000000000116:3":   [
    {
      type: "concept",
      title: "Not every lever is equally flexible",
      body: "Base salary is often the most rigid lever for an employer, constrained by internal pay bands. Signing bonuses, start-date flexibility, extra vacation, or an early performance review are often easier for an employer to move on.",
    },
    {
      type: "table",
      caption: "Rigid vs. flexible levers",
      headers: ["Lever", "Typical flexibility"],
      rows: [
        ["Base salary", "Often rigid — constrained by pay bands"],
        ["Signing bonus", "Often flexible — one-time cost"],
        ["Start date / vacation days", "Often flexible"],
        ["Early performance review", "Often flexible — no permanent commitment"],
      ],
    },
    {
      type: "example",
      title: "Pivoting after a rejected base-salary ask",
      body: "When told base salary can't move, a candidate pivots to a signing bonus plus a formal 6-month review instead of repeating the same ask — and the employer agrees, since neither permanently raises the pay band.",
    },
    {
      type: "mistake",
      body: "Repeating the same base-salary ask after being told it's constrained — pivoting to a different, genuinely flexible lever is usually more productive than pushing harder on a rigid one.",
    },
    {
      type: "takeaway",
      body: "When one negotiating lever is genuinely constrained, pivot to a different one rather than repeating the same ask — total compensation has multiple levers, and not all are equally flexible for a given employer.",
    },
  ],
  "00000000-0000-0000-0001-000000000116:1":   [
    {
      type: "concept",
      title: "A negotiated raise compounds forward",
      body: "A raise negotiated once doesn't just apply to a single paycheck — it typically becomes the new baseline that future raises, bonuses, and even future employers' offers get built on top of.",
    },
    {
      type: "steps",
      title: "Preparing to negotiate",
      steps: ["Research market rate for the specific role, level, and location", "Evaluate total compensation, not just base salary — bonus, equity, retirement match, benefits", "Wait until after a formal offer to name a number"],
    },
    {
      type: "example",
      title: "$58,000 offer, $58k-$68k market range",
      body: "\"Based on my research into typical compensation for this role, I was expecting something closer to $64,000 — is there flexibility to get closer to that?\" Grounded, specific, non-confrontational.",
    },
    {
      type: "mistake",
      body: "Naming a number too early in the process, before an employer has committed to wanting you specifically — it gives away information without leverage.",
    },
    {
      type: "takeaway",
      body: "Negotiate after an offer, not before; ground any counter in real market data; and negotiate the whole package, not just base salary.",
    },
  ],
  "00000000-0000-0000-0001-000000000117:2":   [
    {
      type: "concept",
      title: "A freelance rate covers more than an hourly wage",
      body: "A freelancer's rate has to cover self-employment tax, no employer-subsidized benefits, and unpaid non-billable time — costs a comparable employee's salary doesn't carry directly. This is why sustainable freelance rates run well above an equivalent employee hourly rate.",
    },
    {
      type: "steps",
      title: "Building up a sustainable freelance rate",
      steps: ["Start from a comparable employee's hourly-equivalent pay", "Add for self-employment tax (no employer sharing the cost)", "Add for lost employer-subsidized benefits (health insurance, retirement match)", "Add for unpaid non-billable time (often 20-30% of total working time)"],
    },
    {
      type: "example",
      title: "$30/hour employee-equivalent → $50-55/hour freelance rate",
      body: "A freelancer charging the same $30/hour as an equivalent employee earns less in practice once self-employment tax, lost benefits, and unpaid non-billable time are accounted for — a rate of roughly 1.7-1.8x is closer to matching the employee's real take-home value.",
    },
    {
      type: "mistake",
      body: "Setting a freelance rate equal to a comparable employee's hourly pay — it looks fair on paper but ignores self-employment tax, lost benefits, and unpaid non-billable time, all real costs an employee doesn't bear directly.",
    },
    {
      type: "takeaway",
      body: "Price freelance work well above a directly comparable employee's hourly rate — the multiplier isn't overcharging, it's covering real costs (tax, benefits, unpaid time) that an employee's salary doesn't have to.",
    },
  ],
  "00000000-0000-0000-0001-000000000117:3":   [
    {
      type: "concept",
      title: "Sole proprietor vs. LLC",
      body: "A sole proprietor has no legal separation between personal and business assets — a business liability can become personal exposure. An LLC creates that separation, at the cost of formation paperwork and an ongoing fee.",
    },
    {
      type: "table",
      caption: "Sole proprietor vs. LLC",
      headers: ["", "Sole proprietor", "LLC"],
      rows: [
        ["Setup cost", "None", "Formation paperwork + fee"],
        ["Personal asset protection", "None — fully exposed", "Generally protected, if funds stay separate"],
      ],
    },
    {
      type: "example",
      title: "$2,000/year vs. $60,000/year side income",
      body: "At $2,000/year, low liability exposure likely doesn't justify an LLC's cost. At $60,000/year with corporate clients, the LLC's liability protection becomes proportionally more valuable relative to its cost — a common point to transition structures.",
    },
    {
      type: "mistake",
      body: "Commingling business and personal funds after forming an LLC — this can undermine the very legal separation an LLC is meant to provide, defeating its purpose.",
    },
    {
      type: "takeaway",
      body: "Revisit your business structure as freelance income and client risk grow — an LLC's liability protection becomes proportionally more valuable as the financial stakes of a lawsuit or business debt increase.",
    },
  ],
  "00000000-0000-0000-0001-000000000117:1":   [
    {
      type: "concept",
      title: "No automatic withholding on freelance income",
      body: "A traditional employer withholds income tax and payroll taxes automatically. Freelance/self-employed income has no automatic withholding — the freelancer is personally responsible for setting aside and paying their own taxes, including both the employee and employer share of payroll-equivalent tax.",
    },
    {
      type: "keyterm",
      term: "Estimated quarterly taxes",
      definition: "Tax payments a self-employed person generally must make throughout the year rather than settling everything at filing time — skipping this can trigger an underpayment penalty.",
    },
    {
      type: "steps",
      title: "Managing freelance tax obligations",
      steps: ["Set aside roughly 25-30% of every payment received, in a separate account", "Pay estimated taxes quarterly if income is above the threshold", "Track legitimate business expenses (equipment, software, a share of relevant costs) to deduct", "Keep business and personal finances separate for easier tracking"],
    },
    {
      type: "example",
      title: "$4,000 freelance income, 28% set-aside",
      body: "$1,120 moved to a separate tax account, leaving $2,880 spendable. A $500 deductible laptop expense reduces the taxable income the 28% estimate is calculated against.",
    },
    {
      type: "takeaway",
      body: "Freelance income requires proactively setting aside and often quarterly-paying your own taxes — treat the tax portion as never really available to spend.",
    },
  ],
  "00000000-0000-0000-0001-000000000118:2":   [
    {
      type: "concept",
      title: "The priority order is ranked by effective return",
      body: "Each step in the priority order can be compared by its effective guaranteed return — a 401(k) match, high-interest debt payoff, and general investing all have calculable (or estimable) returns, which is what actually determines the order.",
    },
    {
      type: "table",
      caption: "Comparing effective returns",
      headers: ["Action", "Effective return"],
      rows: [
        ["Capture full 401(k) match", "100%+ (immediate, guaranteed)"],
        ["Pay off 22% APR credit card debt", "~22% (guaranteed)"],
        ["Invest in a taxable brokerage account", "~7-8% (realistic, uncertain)"],
      ],
    },
    {
      type: "example",
      title: "$300/month, debt payoff vs. investing",
      body: "Paying down 22% APR credit card debt is equivalent to a guaranteed 22% return. Investing the same money might realistically earn 7-8% with real risk — the debt payoff wins clearly on pure math.",
    },
    {
      type: "mistake",
      body: "Investing in a taxable brokerage account while still carrying high-interest credit card debt — the guaranteed return from paying off the debt is almost always higher than a realistic expected investment return.",
    },
    {
      type: "takeaway",
      body: "Rank competing financial priorities by their effective guaranteed return, not by which feels most urgent — this is what makes the standard priority order (match, then high-interest debt, then further saving/investing) a calculated decision, not just conventional wisdom.",
    },
  ],
  "00000000-0000-0000-0001-000000000118:3":   [
    {
      type: "concept",
      title: "Housing choice constrains every other financial goal",
      body: "Housing and transportation are typically the largest recurring costs in a post-grad budget. A housing decision made early sets a fixed cost that constrains debt payoff pace, savings rate, and investing capacity for as long as it continues.",
    },
    {
      type: "keyterm",
      term: "30% rent guideline",
      definition: "A common budgeting rule capping rent at roughly 30% of gross income — not a hard rule, but a useful benchmark for evaluating whether a housing choice leaves enough room for other financial goals.",
    },
    {
      type: "example",
      title: "Same $50,000 salary, different rent choices",
      body: "One graduate signs an $1,800/month lease (well above the 30% guideline), leaving little room for other goals. Another chooses $1,100/month, freeing up several hundred extra dollars monthly for debt payoff, savings, and investing — same income, different trajectory.",
    },
    {
      type: "mistake",
      body: "Choosing housing based on what feels affordable in the moment without checking it against a guideline like the 30%-of-income rule — an oversized housing cost quietly crowds out every other financial priority for years.",
    },
    {
      type: "takeaway",
      body: "Evaluate housing and transportation choices early and deliberately — they're usually the largest controllable costs in a post-grad budget, and an outsized choice here constrains every other financial goal for as long as it lasts.",
    },
  ],
  "00000000-0000-0000-0001-000000000118:1":   [
    {
      type: "concept",
      title: "A priority order for a first real paycheck",
      body: "Every topic covered so far — budgeting, debt, credit, investing, taxes, retirement, insurance, salary, side income — comes together the moment a real paycheck starts arriving, often with no obvious order of operations. A widely used priority framework helps resolve that.",
    },
    {
      type: "steps",
      title: "A common priority order",
      steps: ["Build a small starter emergency fund (roughly $500-$1,000) before anything else", "Capture the full employer 401(k) match if offered (free money)", "Pay down high-interest debt (credit cards) aggressively", "Build the emergency fund further (1-2+ months of expenses)", "Invest further for longer-term goals"],
    },
    {
      type: "keyterm",
      term: "Priority framework",
      definition: "An ordered sequence for allocating a first real paycheck across competing financial goals — designed to avoid the common mistake of trying to do everything at once with limited money.",
    },
    {
      type: "mistake",
      body: "Trying to aggressively pay down debt, build a large emergency fund, and max out investing all at once on a starting salary — spreading limited money too thin across every goal simultaneously is less effective than a deliberate order.",
    },
    {
      type: "takeaway",
      body: "Follow a deliberate priority order rather than splitting a first paycheck evenly across every financial goal at once — some steps (capturing a full 401(k) match, paying off high-interest debt) come before others for good, calculable reasons.",
    },
  ],

  // ---- Job-Ready ----
  "00000000-0000-0000-0001-000000000201:2":   [
    {
      type: "concept",
      title: "What each question type actually tests",
      body: "Behavioral tests whether you have real specific experience; technical tests whether your knowledge is correct and fluent; fit tests whether your interest is genuine and researched.",
    },
    {
      type: "steps",
      title: "Building a flexible story bank",
      steps: ["Pick 4-6 real experiences with a clear challenge and outcome", "Identify which behavioral themes each story could answer (teamwork, conflict, initiative, failure)", "Practice telling the same story emphasizing a different angle for each theme"],
    },
    {
      type: "example",
      title: "One story, two angles",
      body: "A group-project story foregrounding the disagreement answers \"describe a challenge\"; the same story foregrounding task division answers \"describe teamwork.\"",
    },
    {
      type: "mistake",
      body: "Trying to memorize a unique story for every possible question instead of a small flexible set that can be reshaped.",
    },
    {
      type: "takeaway",
      body: "A small bank of real, flexible stories told from different angles prepares you more efficiently than memorizing one script per question.",
    },
  ],
  "00000000-0000-0000-0001-000000000201:3":   [
    {
      type: "steps",
      title: "A simple answering habit",
      steps: ["Briefly acknowledge the question", "Take a short pause to pick your example or approach", "Answer with a one-sentence headline first, then supporting detail"],
    },
    {
      type: "concept",
      title: "Lead with the conclusion",
      body: "Stating your core point first, then supporting it, keeps your strongest material from getting buried at the end of a rambling answer.",
    },
    {
      type: "example",
      title: "Headline-first \"why this company\" answer",
      body: "\"I'm drawn to this firm's focus on [specific thing], because [genuine reason]\" — stated immediately, then supported with specifics.",
    },
    {
      type: "mistake",
      body: "Building up to your main point at the end of a long answer, where a distracted interviewer may miss it entirely.",
    },
    {
      type: "takeaway",
      body: "A brief pause to plan structure, plus a headline-first answer style, keeps responses focused under interview pressure.",
    },
  ],
  "00000000-0000-0000-0001-000000000202:2":   [
    {
      type: "concept",
      title: "Ordinary experience is usable material",
      body: "Interviewers care more about clarity of Action and Result than the perceived prestige of the Situation — a part-time job story can outperform a generic \"impressive\" one.",
    },
    {
      type: "steps",
      title: "Working backward from Result",
      steps: ["Identify a concrete thing that changed or improved because of you", "Reconstruct the Action that caused it", "Reconstruct the Task and Situation that set it up"],
    },
    {
      type: "example",
      title: "Coffee shop, worked backward",
      body: "Result: wait times dropped. Working backward: Situation (mornings backed up), Task (asked for ideas), Action (proposed a new layout).",
    },
    {
      type: "mistake",
      body: "Describing the Situation in exhaustive detail, then rushing a thin, vague Result at the very end.",
    },
    {
      type: "takeaway",
      body: "Start from a concrete result and work backward — it produces sharper, more specific STAR stories than starting from the situation.",
    },
  ],
  "00000000-0000-0000-0001-000000000202:3":   [
    {
      type: "concept",
      title: "Resume and interview should match",
      body: "A resume bullet is a promise you need to be able to expand on conversationally with the same context/action/result specificity.",
    },
    {
      type: "mistake",
      body: "Claiming an achievement on a resume that falls apart under a follow-up question asking for specific detail.",
    },
    {
      type: "example",
      title: "Quantifying without exact data",
      body: "\"Improved club attendance\" becomes credible when expanded with a rough, explained estimate: \"attendance roughly doubled, based on sign-in sheets.\"",
    },
    {
      type: "steps",
      title: "Keeping bullets and stories aligned",
      steps: ["Write the resume bullet", "Expand it mentally using full STAR", "Check the bullet doesn't overstate what the STAR story actually supports"],
    },
    {
      type: "takeaway",
      body: "Quantify results even roughly, and make sure every resume claim survives being expanded into a full, specific STAR answer.",
    },
  ],
  "00000000-0000-0000-0001-000000000202:1":   [
    {
      type: "keyterm",
      term: "STAR",
      definition: "Situation, Task, Action, Result — a structure for behavioral answers that keeps them concrete instead of vague.",
    },
    {
      type: "concept",
      title: "Resume bullets need evidence, not duties",
      body: "A strong bullet states what you did, in what context, with what measurable result — not just a listed responsibility.",
    },
    {
      type: "example",
      title: "Weak vs. strong bullet",
      body: "Weak: \"Responsible for team project.\" Strong: \"Led a 4-person team under a 2-week deadline; restructured assignments after week 1 fell behind, delivering on time in the top 10% of the class.\"",
    },
    {
      type: "mistake",
      body: "Skipping straight from Situation to a vague Result with no clear Action described in between.",
    },
    {
      type: "takeaway",
      body: "Both resume bullets and STAR answers reward the same discipline: specific context, a clear personal action, and a concrete result.",
    },
  ],
  "00000000-0000-0000-0001-000000000203:2":   [
    {
      type: "mistake",
      body: "Going silent to work out the full answer in your head, leaving the interviewer with no visibility into your reasoning process.",
    },
    {
      type: "concept",
      title: "Narration invites correction",
      body: "Case interviews are often collaborative — narrating lets an interviewer redirect an unrealistic assumption before it's built into the whole calculation.",
    },
    {
      type: "example",
      title: "Narrating from the first step",
      body: "\"I'll break this into population, adoption rate, and frequency — starting with population, I'll assume roughly a million people.\"",
    },
    {
      type: "takeaway",
      body: "Narrate your reasoning out loud from the start rather than solving silently — it shows process and invites early correction.",
    },
  ],
  "00000000-0000-0000-0001-000000000203:3":   [
    {
      type: "concept",
      title: "An estimate isn't the finish line",
      body: "The strongest case answers briefly discuss what would make the estimate more or less reliable, not just state a final number.",
    },
    {
      type: "steps",
      title: "Closing a case answer well",
      steps: ["State your final estimate", "Name the assumption you're least confident in", "Say what real data would firm it up"],
    },
    {
      type: "example",
      title: "Flagging uncertainty",
      body: "\"The number I'm least confident in is the 30% adoption rate — if it's 20%, the estimate drops to 240,000.\"",
    },
    {
      type: "takeaway",
      body: "Naming your weakest assumption and what data would clarify it shows real analytical maturity, not just arithmetic.",
    },
  ],
  "00000000-0000-0000-0001-000000000204:2":   [
    {
      type: "keyterm",
      term: "Comparable company analysis (comps)",
      definition: "Valuing a company by comparing its trading multiple (e.g. EV/EBITDA) to similar peer companies.",
    },
    {
      type: "concept",
      title: "What a multiple reflects",
      body: "A multiple reflects the market's expectations about a company's growth, risk, and margins — not just its size.",
    },
    {
      type: "example",
      title: "Why two similar retailers trade differently",
      body: "12x vs. 7x EBITDA likely reflects differing expected growth, risk, or a specific problem investors are discounting for the lower-multiple company.",
    },
    {
      type: "takeaway",
      body: "Explaining why multiples differ between similar companies matters more than just knowing how to calculate one.",
    },
  ],
  "00000000-0000-0000-0001-000000000204:3":   [
    {
      type: "concept",
      title: "Applying mechanics to new scenarios",
      body: "Interviewers often test whether you can apply a known mechanic to an unfamiliar scenario, not just recite a memorized answer.",
    },
    {
      type: "steps",
      title: "Bad debt write-off, three statements",
      steps: ["Income statement: net income falls £7.50 after tax", "Cash flow: non-cash expense added back, CFO rises £2.50", "Balance sheet: receivables -£10, cash +£2.50, equity -£7.50"],
    },
    {
      type: "mistake",
      body: "Only rehearsing the exact original question instead of practicing deliberate variations on the same underlying mechanic.",
    },
    {
      type: "takeaway",
      body: "Practicing self-generated \"what if\" variations on your anchor explanations builds the flexibility live technical questions test for.",
    },
  ],
  "00000000-0000-0000-0001-000000000204:1":   [
    {
      type: "concept",
      title: "What technical questions test",
      body: "Technical finance questions test whether you understand core mechanics well enough to explain them correctly under pressure, not eloquence.",
    },
    {
      type: "keyterm",
      term: "Anchor explanation",
      definition: "A short, rehearsed, correct explanation of a core concept (DCF, statement linkage, bond/rate relationship) you can deliver fluently under pressure.",
    },
    {
      type: "steps",
      title: "Depreciation +£10 walkthrough",
      steps: ["Income statement: net income falls £7.50 after 25% tax", "Cash flow: depreciation added back, CFO rises £2.50", "Balance sheet: cash +£2.50, fixed assets -£10, equity -£7.50 — still balances"],
    },
    {
      type: "takeaway",
      body: "A small set of core mechanics is asked constantly — fluent, correct explanations of those beat broad but shallow knowledge.",
    },
  ],
  "00000000-0000-0000-0001-000000000205:2":   [
    {
      type: "concept",
      title: "Point estimates understate uncertainty",
      body: "A single number hides how sensitive a conclusion is to the input you're least sure about — a range communicates that honestly.",
    },
    {
      type: "steps",
      title: "Building a quick range live",
      steps: ["Compute your base case", "Recompute using a plausible low value for your shakiest assumption", "Recompute using a plausible high value", "State the range alongside your headline number"],
    },
    {
      type: "example",
      title: "Bank branch range",
      body: "At 2% capture: -£66,000. At 4%: roughly break-even. At 6%: +£102,000 — a wide swing worth flagging explicitly.",
    },
    {
      type: "takeaway",
      body: "A quick range around your shakiest assumption shows more analytical sophistication than a single point estimate alone.",
    },
  ],
  "00000000-0000-0000-0001-000000000205:3":   [
    {
      type: "concept",
      title: "Commercial judgment beyond the arithmetic",
      body: "Briefly flagging a relevant factor your estimate doesn't capture shows real business thinking, without derailing your core structure.",
    },
    {
      type: "table",
      caption: "Factors worth a brief mention",
      headers: ["Factor", "Why it matters"],
      rows: [
        ["Competitive response", "A rival's presence could raise or lower your capture-rate assumption"],
        ["Timing", "Estimates often assume conditions stay constant when they may not"],
        ["Non-financial risk", "Regulatory or reputational risk a pure numbers estimate misses"],
      ],
    },
    {
      type: "example",
      title: "Flagging competitive context",
      body: "\"If a rival bank already has a branch nearby, my 4% capture assumption might be optimistic.\"",
    },
    {
      type: "takeaway",
      body: "One brief, genuinely relevant factor beyond the numbers — not a tangent — demonstrates commercial judgment interviewers value.",
    },
  ],
  "00000000-0000-0000-0001-000000000205:1":   [
    {
      type: "concept",
      title: "Finance cases add a decision layer",
      body: "Finance-flavored cases embed a business decision inside the estimate — the interviewer wants to see the structure would support a real recommendation, not just a number.",
    },
    {
      type: "steps",
      title: "Bank branch worked example",
      steps: ["35,000 potential customers (50,000 x 70% banked)", "1,400 accounts captured (4% of 35,000)", "£168,000 year-one revenue vs £150,000 cost — roughly break-even"],
    },
    {
      type: "example",
      title: "Naming the shakiest assumption",
      body: "The 4% capture rate is doing the most work — at 2%, revenue drops to £84,000 and the branch loses money.",
    },
    {
      type: "takeaway",
      body: "State what the number implies for the decision, and name the biggest assumption that could most change the answer.",
    },
  ],
  "00000000-0000-0000-0001-000000000206:2":   [
    {
      type: "concept",
      title: "A conflict exists before any wrongdoing",
      body: "A conflict of interest exists the moment two interests could diverge — it doesn't require anyone to have actually acted improperly.",
    },
    {
      type: "keyterm",
      term: "Conflict of interest",
      definition: "A situation where your interests, or your firm's, could improperly influence advice given to a client.",
    },
    {
      type: "example",
      title: "Commission-based fund recommendation",
      body: "Recommending an in-house fund that pays a higher commission is a conflict problem unless the incentive is disclosed to the client.",
    },
    {
      type: "takeaway",
      body: "Disclosure, not just avoidance, is often the right response to a conflict of interest — especially around compensation structures.",
    },
  ],
  "00000000-0000-0000-0001-000000000206:3":   [
    {
      type: "concept",
      title: "Ambiguous scenarios test process, not a label",
      body: "Layered ethics scenarios test whether your reasoning stays consistent under uncertainty, not whether you find one correct answer.",
    },
    {
      type: "mistake",
      body: "Conflating what you know for certain with what you're only assuming — either overreacting or explaining away a real red flag.",
    },
    {
      type: "example",
      title: "Pushback on a compliance review",
      body: "Separate the fact (pushback occurred) from the assumption (why) — document the concern and follow the normal review process regardless of the guess.",
    },
    {
      type: "takeaway",
      body: "When a scenario is genuinely ambiguous, let the normal process run rather than acting on an unconfirmed assumption about motive.",
    },
  ],
  "00000000-0000-0000-0001-000000000206:1":   [
    {
      type: "keyterm",
      term: "Insider trading",
      definition: "Trading a security based on material non-public information — information not yet public that a reasonable investor would consider important.",
    },
    {
      type: "keyterm",
      term: "Fiduciary duty",
      definition: "A legal and ethical obligation to act in a client's best interest, not your own or your firm's.",
    },
    {
      type: "steps",
      title: "Answering an ethics scenario",
      steps: ["Name the specific issue (conflict of interest, insider trading, fiduciary duty)", "Explain concretely who could be harmed and how", "State what you'd actually do — usually escalate to compliance"],
    },
    {
      type: "example",
      title: "Friend's tip about an acquisition",
      body: "Not trading, not sharing further, and reporting to compliance — even unintentional receipt of material non-public information creates exposure.",
    },
    {
      type: "takeaway",
      body: "Default to escalating a gray-area ethics situation rather than deciding unilaterally.",
    },
  ],
  "00000000-0000-0000-0001-000000000207:2":   [
    {
      type: "mistake",
      body: "Undervaluing informal leadership and saying \"I've never officially led anything,\" missing what the question is actually testing.",
    },
    {
      type: "concept",
      title: "What counts as leadership",
      body: "Noticing something needed to happen, taking ownership, and getting other people aligned and moving — no formal title required.",
    },
    {
      type: "example",
      title: "Informal leadership story",
      body: "Volunteering to organize weekly check-ins on a stalled group project, with no official role, still counts as genuine leadership.",
    },
    {
      type: "takeaway",
      body: "Make sure a leadership story involves coordinating other people, not just your own solo effort — that's what separates it from a different kind of story.",
    },
  ],
  "00000000-0000-0000-0001-000000000207:3":   [
    {
      type: "mistake",
      body: "Describing a conflict so smoothly resolved it barely sounds like real tension existed — reads as evasive.",
    },
    {
      type: "steps",
      title: "A credible conflict story",
      steps: ["Describe the disagreement honestly, including real discomfort if present", "Describe a specific de-escalation action you took", "Give an honest outcome, even if your original position didn't fully win"],
    },
    {
      type: "example",
      title: "Honest conflict resolution",
      body: "Directly acknowledging a colleague's information changed your mind, rather than quietly going along or insisting you were right.",
    },
    {
      type: "takeaway",
      body: "An honest conflict story with real tension and a specific resolution step is more credible than one where you're clearly always right.",
    },
  ],
  "00000000-0000-0000-0001-000000000207:1":   [
    {
      type: "concept",
      title: "Three categories, three different tests",
      body: "Leadership tests ownership of an outcome; conflict tests productive resolution of tension; failure tests genuine self-awareness.",
    },
    {
      type: "keyterm",
      term: "STARL",
      definition: "STAR plus Learning — for failure questions specifically, a concrete statement of what you do differently now because of the failure.",
    },
    {
      type: "mistake",
      body: "Picking a disguised-strength \"failure\" (\"I work too hard\") instead of a real mistake — it reads as evasive.",
    },
    {
      type: "example",
      title: "Strong failure answer",
      body: "Assumed teammates understood their part after one message; missed a checkpoint; now explicitly confirms understanding and checks in at the halfway point.",
    },
    {
      type: "takeaway",
      body: "For failure questions, name a real mistake, its real consequence, and a specific, still-in-use behavior change.",
    },
  ],
  "00000000-0000-0000-0001-000000000208:2":   [
    {
      type: "concept",
      title: "Negotiation is a back-and-forth",
      body: "Knowing how to respond to a counter-offer is as important as making the first ask.",
    },
    {
      type: "steps",
      title: "Preparing for the back-and-forth",
      steps: ["Decide your walk-away point before the conversation", "Respond to a counter-offer without deciding under pressure", "Consider a non-salary concession to close a remaining gap"],
    },
    {
      type: "example",
      title: "Accepting a reasonable counter",
      body: "If your walk-away point was $64,000 and the employer counters at $65,000, accepting is often better than pushing further and risking the relationship.",
    },
    {
      type: "takeaway",
      body: "Deciding your walk-away point in advance, and considering non-salary concessions, leads to better negotiation outcomes than reacting in the moment.",
    },
  ],
  "00000000-0000-0000-0001-000000000208:3":   [
    {
      type: "concept",
      title: "Tone: enthusiastic but direct",
      body: "Genuine excitement first, then a clear specific ask, avoids both adversarial friction and passive, unclaimed value.",
    },
    {
      type: "mistake",
      body: "Issuing an ultimatum you're not actually prepared to follow through on — backing down afterward damages credibility.",
    },
    {
      type: "example",
      title: "Enthusiastic but direct ask",
      body: "\"I'm genuinely excited about this role — based on my research, $68,000 feels like a better fit. Is there room to get closer to that?\"",
    },
    {
      type: "takeaway",
      body: "An enthusiastic, specific, direct tone negotiates more effectively than either an adversarial or an overly passive approach.",
    },
  ],
  "00000000-0000-0000-0001-000000000209:2":   [
    {
      type: "steps",
      title: "Comparing offers on total value",
      steps: ["Take base salary at face value", "Discount a bonus target for uncertainty (e.g. 60-80% of face value)", "Add a realistic dollar estimate for benefits"],
    },
    {
      type: "example",
      title: "Discounted comparison",
      body: "B's 10% bonus at 70% face value (~$4,340) plus ~$6,000 benefits brings its total above A's higher headline base.",
    },
    {
      type: "mistake",
      body: "Counting a bonus target at full face value, or ignoring benefits entirely, both distort an offer comparison.",
    },
    {
      type: "takeaway",
      body: "A consistent, realistic discounting method for bonus and benefits often narrows or reverses which offer looks better on headline base alone.",
    },
  ],
  "00000000-0000-0000-0001-000000000209:3":   [
    {
      type: "concept",
      title: "Compensation structure signals philosophy",
      body: "A stable high base vs. a lower base with rich variable pay reflects different employer philosophies — stability vs. performance-linked upside.",
    },
    {
      type: "steps",
      title: "Questions to ask at offer stage",
      steps: ["What's the typical annual raise, and how is it decided?", "How often do promotions happen, and what changes with them?", "Is bonus/equity growth the primary way compensation rises here?"],
    },
    {
      type: "example",
      title: "Matching structure to risk tolerance",
      body: "A candidate with tight fixed expenses may reasonably prefer a stable-base offer even with slightly lower average expected value.",
    },
    {
      type: "takeaway",
      body: "Ask about raise and promotion timelines at the offer stage — compensation structure, not just this year's number, affects long-term income predictability.",
    },
  ],
  "00000000-0000-0000-0001-000000000209:1":   [
    {
      type: "concept",
      title: "A package has four parts",
      body: "Base salary, bonus (often a target, not guaranteed), equity, and benefits — comparing offers on base alone can mislead.",
    },
    {
      type: "table",
      caption: "Offer A vs Offer B",
      headers: ["", "Base", "Bonus target", "Benefits value"],
      rows: [
        ["Offer A", "$70,000", "None", "Modest"],
        ["Offer B", "$62,000", "10% ($6,200)", "~$6,000/yr health"],
      ],
    },
    {
      type: "mistake",
      body: "Treating a bonus target as guaranteed income, when payout often depends on hitting targets outside your full control.",
    },
    {
      type: "takeaway",
      body: "Estimate total package value, not just base salary — the gap between two offers is often smaller than it first appears.",
    },
  ],
  "00000000-0000-0000-0001-000000000210:2":   [
    {
      type: "concept",
      title: "Withholding is a choice you make",
      body: "A form like a W-4 sets how much is withheld each paycheck — it's a choice, not a fixed fact, and can be revisited.",
    },
    {
      type: "mistake",
      body: "Setting withholding once at hiring and never revisiting it, even after a life change like a second job or marriage.",
    },
    {
      type: "example",
      title: "Two extremes",
      body: "Too little withheld risks owing a surprise bill (or penalty); too much withheld means the government holds your money interest-free until refund.",
    },
    {
      type: "takeaway",
      body: "Revisit your withholding setting after major life changes to avoid a surprise tax bill or an unnecessarily large refund.",
    },
  ],
  "00000000-0000-0000-0001-000000000210:3":   [
    {
      type: "concept",
      title: "Voluntary deductions are choices",
      body: "Unlike taxes, you control whether and how much goes toward voluntary deductions like retirement contributions or health insurance.",
    },
    {
      type: "steps",
      title: "Reconstructing expected net pay",
      steps: ["Start with gross pay per period", "Subtract estimated tax withholding", "Subtract your specific voluntary deduction elections", "Compare the result to what you're budgeting against"],
    },
    {
      type: "mistake",
      body: "Committing to fixed costs like a lease based on gross salary, before accounting for voluntary deductions that reduce actual net pay.",
    },
    {
      type: "takeaway",
      body: "Reconstruct expected net pay by hand before your first paycheck arrives, using your actual elections, rather than assuming it's close to gross pay.",
    },
  ],
  "00000000-0000-0000-0001-000000000210:1":   [
    {
      type: "keyterm",
      term: "Gross pay vs. net pay",
      definition: "Gross pay is what you earned before deductions; net pay is what actually lands in your account after taxes and voluntary deductions.",
    },
    {
      type: "steps",
      title: "$2,500 gross to $1,790 net",
      steps: ["-$380 federal tax", "-$155 payroll tax (Social Security/Medicare)", "-$50 state tax", "-$125 voluntary 401(k)", "= $1,790 net"],
    },
    {
      type: "concept",
      title: "Withholding is an estimate",
      body: "Tax withheld during the year is a prepayment reconciled at filing time — too much withheld means a refund, too little means owing more.",
    },
    {
      type: "takeaway",
      body: "Budget against net pay, not the headline salary — the gap between the two is easy to underestimate on a first paycheck.",
    },
  ],
  "00000000-0000-0000-0001-000000000211:2":   [
    {
      type: "table",
      caption: "Common match formula types",
      headers: ["Type", "Example"],
      rows: [
        ["Flat", "100% match up to 4% of salary"],
        ["Partial", "50% match up to 6% of salary"],
        ["Tiered", "100% on first 3%, 50% on next 2%"],
      ],
    },
    {
      type: "keyterm",
      term: "Vesting schedule (employer contributions)",
      definition: "A required period of employment before an employer's matching contributions fully belong to you — your own contributions are always fully yours.",
    },
    {
      type: "mistake",
      body: "Assuming a generic \"my employer matches\" understanding instead of checking the actual plan document for the real contribution target.",
    },
    {
      type: "takeaway",
      body: "Read your specific plan's match formula and vesting schedule directly — don't rely on a secondhand or generic summary.",
    },
  ],
  "00000000-0000-0000-0001-000000000211:3":   [
    {
      type: "steps",
      title: "A common general priority order",
      steps: ["Capture the full employer retirement match", "Pay down high-interest debt", "Build a basic emergency fund", "Consider contributing beyond the match"],
    },
    {
      type: "concept",
      title: "Debt payoff as a guaranteed return",
      body: "Paying down a 22% APR balance delivers a guaranteed 22% \"return\" that's hard for most investments to beat.",
    },
    {
      type: "example",
      title: "Match plus credit card debt",
      body: "Someone capturing their match but carrying $3,000 at 22% APR is usually better off directing extra money to the debt before contributing further.",
    },
    {
      type: "takeaway",
      body: "This priority order isn't rigid — but high-interest debt usually deserves priority over retirement contributions beyond the employer match.",
    },
  ],
  "00000000-0000-0000-0001-000000000211:1":   [
    {
      type: "concept",
      title: "The employer match is compensation",
      body: "Many employers add money based on your own contribution — not capturing the full match means leaving guaranteed additional pay unclaimed.",
    },
    {
      type: "keyterm",
      term: "Tax-advantaged growth",
      definition: "Investment growth inside a retirement account that isn't taxed each year the way an ordinary brokerage account's gains might be.",
    },
    {
      type: "example",
      title: "Priya's match",
      body: "Contributing 6% ($3,000) gets a 50% match ($1,500) — $4,500 total. Contributing only 2% leaves $1,000 of match unclaimed.",
    },
    {
      type: "takeaway",
      body: "Aim to contribute at least enough to capture the full employer match — it's guaranteed extra pay contingent on your own contribution.",
    },
  ],
  "00000000-0000-0000-0001-000000000212:2":   [
    {
      type: "keyterm",
      term: "Out-of-pocket maximum",
      definition: "The total you'd ever pay in a year before insurance covers everything else completely — a genuine worst-case ceiling.",
    },
    {
      type: "keyterm",
      term: "Coinsurance",
      definition: "The percentage of a bill you keep paying even after meeting your deductible, until you hit the out-of-pocket maximum.",
    },
    {
      type: "example",
      title: "Worst-case comparison",
      body: "Plan A's out-of-pocket max is $6,000; Plan B's is $3,000 — a meaningful gap in worst-case exposure premium and deductible alone don't show.",
    },
    {
      type: "takeaway",
      body: "Check out-of-pocket maximum and coinsurance, not just premium and deductible, for the full picture of a plan's financial risk.",
    },
  ],
  "00000000-0000-0000-0001-000000000212:3":   [
    {
      type: "concept",
      title: "A plan choice isn't permanent",
      body: "Most employers offer an annual window to switch plans — a plan that fit one year may not fit after a life change.",
    },
    {
      type: "steps",
      title: "Reviewing your plan choice annually",
      steps: ["Total actual spending (premiums + deductible + coinsurance) for the year", "Estimate what the alternative plan would have cost under the same usage", "Use that comparison to inform next year's open enrollment choice"],
    },
    {
      type: "example",
      title: "Hindsight review",
      body: "Unexpected visits might reveal the higher-premium plan would have cost less that year — useful for the next decision, even if the original choice was reasonable.",
    },
    {
      type: "takeaway",
      body: "Review actual usage against the alternative plan's cost each year — it's a more reliable guide than guessing usage in advance.",
    },
  ],
  "00000000-0000-0000-0001-000000000212:1":   [
    {
      type: "keyterm",
      term: "Premium vs. deductible",
      definition: "Premium is the regular cost paid regardless of use; deductible is what you pay out of pocket before insurance covers a larger share.",
    },
    {
      type: "table",
      caption: "Plan A vs Plan B, no major needs",
      headers: ["", "Premium/yr", "Deductible"],
      rows: [
        ["Plan A", "$600", "$3,000"],
        ["Plan B", "$1,800", "$500"],
      ],
    },
    {
      type: "example",
      title: "With a $4,000 medical expense",
      body: "Plan A: $3,600 total before full coverage kicks in. Plan B: $2,300 total — Plan B wins once the deductible is actually hit.",
    },
    {
      type: "takeaway",
      body: "The right plan depends on expected usage — low usage favors low-premium/high-deductible; regular care favors higher premium/lower deductible.",
    },
  ],
  "00000000-0000-0000-0001-000000000213:2":   [
    {
      type: "concept",
      title: "Small habits build trust over time",
      body: "Splitting shared costs promptly and asking about gray-area policies, not just formal expense reports, shape how colleagues see your reliability.",
    },
    {
      type: "mistake",
      body: "Guessing at an unclear policy on company resource use instead of asking — an incorrect assumption discovered later looks worse than a quick question.",
    },
    {
      type: "example",
      title: "Asking instead of assuming",
      body: "\"Quick question — is X the kind of thing that's fine to expense, or should I keep that separate?\"",
    },
    {
      type: "takeaway",
      body: "Prompt repayment of shared costs and asking about unclear policies are low-cost habits that build workplace trust over time.",
    },
  ],
  "00000000-0000-0000-0001-000000000213:3":   [
    {
      type: "concept",
      title: "Pay discussion norms vary",
      body: "Discussing your own salary is often legally protected, but workplace comfort with the topic still varies by team culture.",
    },
    {
      type: "mistake",
      body: "Directly pressing a colleague for their salary, which puts them in an uncomfortable position of having to decide whether to answer.",
    },
    {
      type: "example",
      title: "An optional, low-pressure ask",
      body: "\"Would you be comfortable sharing roughly what the range is for this role? No pressure if not.\"",
    },
    {
      type: "takeaway",
      body: "Be open about your own compensation if asked; frame any ask about someone else's pay as explicitly optional, respecting their comfort level.",
    },
  ],
  "00000000-0000-0000-0001-000000000213:1":   [
    {
      type: "concept",
      title: "Expense reports need documentation",
      body: "Itemized receipts, a stated business purpose, and timely submission — missing any is a common reason reimbursements get delayed or denied.",
    },
    {
      type: "keyterm",
      term: "Per diem",
      definition: "A fixed daily allowance for travel expenses like meals, given in place of requiring itemized receipts for every small purchase.",
    },
    {
      type: "example",
      title: "Good vs. poor submission",
      body: "Itemized list with receipts and business purpose, within 30 days, vs. a vague \"conference expenses, $650\" with no receipts, six weeks late.",
    },
    {
      type: "takeaway",
      body: "Careful, well-documented expense reporting is a low-cost way to build trust with a manager or finance team early in a role.",
    },
  ],
  "00000000-0000-0000-0001-000000000214:2":   [
    {
      type: "concept",
      title: "50/30/20 is a diagnostic, not a rule",
      body: "In high cost-of-living areas, needs can genuinely exceed 50% — the honest fix is adjusting the framework, not forcing an unrealistic budget.",
    },
    {
      type: "steps",
      title: "Diagnosing a strained budget",
      steps: ["Check if needs are running well above 50%", "If so, examine fixed costs (especially housing) first", "If needs are fine but savings are near zero, look at wants spending"],
    },
    {
      type: "example",
      title: "A realistic adjusted split",
      body: "65% needs / 20% wants / 15% savings for a genuinely high cost-of-living area — still deliberate, just rebalanced.",
    },
    {
      type: "takeaway",
      body: "Adjust the 50/30/20 percentages deliberately for real cost of living rather than abandoning budgeting when the default split doesn't fit.",
    },
  ],
  "00000000-0000-0000-0001-000000000214:3":   [
    {
      type: "keyterm",
      term: "Sinking fund",
      definition: "Setting aside a portion of an irregular annual cost every month, so the full amount is already available when the bill arrives.",
    },
    {
      type: "mistake",
      body: "Budgeting only against monthly recurring costs and being repeatedly surprised by predictable irregular expenses like insurance or holiday spending.",
    },
    {
      type: "example",
      title: "$900/year in irregular costs",
      body: "Car insurance ($600) plus December gifts ($300), divided by 12, means setting aside $75/month specifically for this category.",
    },
    {
      type: "takeaway",
      body: "Divide predictable irregular annual costs by 12 and set that amount aside monthly, rather than budgeting only for recurring monthly expenses.",
    },
  ],
  "00000000-0000-0000-0001-000000000214:1":   [
    {
      type: "keyterm",
      term: "Lifestyle inflation",
      definition: "Scaling up spending immediately to match a new, larger gross salary, rather than budgeting deliberately.",
    },
    {
      type: "table",
      caption: "50/30/20 on $3,200/month net",
      headers: ["Category", "Share", "Amount"],
      rows: [
        ["Needs", "50%", "$1,600"],
        ["Wants", "30%", "$960"],
        ["Savings", "20%", "$640"],
      ],
    },
    {
      type: "mistake",
      body: "Signing a lease at 44% of net pay on rent alone, before checking the framework — committing most of the budget before groceries, utilities, or savings.",
    },
    {
      type: "takeaway",
      body: "Budget against net pay, not headline salary, and decide savings and discretionary spending deliberately rather than by default.",
    },
  ],
  "00000000-0000-0000-0001-000000000215:2":   [
    {
      type: "concept",
      title: "Your target should reflect your real risk",
      body: "Job stability, household income structure, and other safety nets should push your target toward the lower or higher end of 3-6 months.",
    },
    {
      type: "table",
      caption: "Same expenses, different targets",
      headers: ["Person", "Situation", "Target"],
      rows: [
        ["A", "Stable dual-income, family nearby", "3 months ($5,400)"],
        ["B", "Variable freelance income, no safety net", "6 months ($10,800)"],
      ],
    },
    {
      type: "mistake",
      body: "Mixing an emergency fund conceptually with other savings goals, making it easy to justify spending it on a non-emergency.",
    },
    {
      type: "takeaway",
      body: "Choose your target based on your actual risk factors, and keep the fund conceptually separate from other savings goals.",
    },
  ],
  "00000000-0000-0000-0001-000000000215:3":   [
    {
      type: "steps",
      title: "Building the fund sustainably",
      steps: ["Set a smaller starter milestone (e.g. $1,000) as a first goal", "Automate the monthly transfer so it's not a discretionary choice", "Continue toward the full 3-6 month target after the starter milestone"],
    },
    {
      type: "concept",
      title: "Milestones sustain motivation",
      body: "A quickly-reached starter milestone provides real protection and visible progress, making the larger goal feel less distant.",
    },
    {
      type: "example",
      title: "Marcus's starter milestone",
      body: "$1,000 reached in 5 months at $200/month, before continuing toward the full $5,400 target.",
    },
    {
      type: "takeaway",
      body: "Break a large emergency fund goal into a smaller starter milestone and automate contributions to sustain progress.",
    },
  ],
  "00000000-0000-0000-0001-000000000215:1":   [
    {
      type: "concept",
      title: "Purpose of an emergency fund",
      body: "Separate, accessible savings sized to essential expenses, existing to absorb unplanned costs without forcing high-interest debt.",
    },
    {
      type: "keyterm",
      term: "3-6 months target",
      definition: "A common target range, in months of essential (not full) expenses, adjusted by job stability and other safety nets.",
    },
    {
      type: "example",
      title: "Marcus's plan",
      body: "$1,800/month essentials; 3-month target = $5,400. Saving $200/month reaches it in 27 months.",
    },
    {
      type: "takeaway",
      body: "Keep the fund accessible and low-risk (a savings account), not invested where it could lose value right when needed.",
    },
  ],
  "00000000-0000-0000-0001-000000000216:2":   [
    {
      type: "steps",
      title: "Questions worth asking about an equity offer",
      steps: ["What is the strike price relative to the company's recent valuation?", "How many total shares are outstanding, to estimate real ownership percentage?", "What happens to vested/unvested options if I'm laid off?", "How much cash runway does the company have?"],
    },
    {
      type: "concept",
      title: "Option count alone is incomplete",
      body: "The same 10,000-option grant means very different things depending on total shares outstanding — always ask for the ownership percentage.",
    },
    {
      type: "example",
      title: "Same grant, different ownership",
      body: "10,000 shares is 0.1% of a 10-million-share company but only 0.02% of a 50-million-share company.",
    },
    {
      type: "takeaway",
      body: "Ask about strike price context, total shares outstanding, and layoff treatment — a raw option count alone doesn't reveal a grant's real value.",
    },
  ],
  "00000000-0000-0000-0001-000000000216:3":   [
    {
      type: "keyterm",
      term: "ISO vs. NSO",
      definition: "Two common US stock option types with different tax treatment and timing — details worth a tax professional's review once an offer is real.",
    },
    {
      type: "concept",
      title: "Exercising can trigger tax before you have cash",
      body: "Buying shares at the strike price can create a real tax liability on a paper gain, even while the shares remain illiquid and unsellable.",
    },
    {
      type: "example",
      title: "A liquidity trap",
      body: "Exercising at a $4/share paper gain can trigger real cash tax owed now, even though startup shares typically can't be sold until an acquisition or listing.",
    },
    {
      type: "takeaway",
      body: "Understand that exercising options can create an immediate tax bill on an illiquid paper gain — get professional tax advice before exercising a meaningful grant.",
    },
  ],
  "00000000-0000-0000-0001-000000000216:1":   [
    {
      type: "keyterm",
      term: "Strike price",
      definition: "The fixed price set now at which a stock option lets you buy shares later — options only have value if the share price rises above it.",
    },
    {
      type: "keyterm",
      term: "Vesting and cliff",
      definition: "Earning the right to options gradually, commonly over 4 years with a 1-year cliff before any vests — leaving before the cliff forfeits everything unvested.",
    },
    {
      type: "example",
      title: "10,000 options at $1 strike",
      body: "If shares reach $5 and all vested: worth $40,000 pre-tax. If the company fails, or you leave before the 1-year cliff: worth $0.",
    },
    {
      type: "takeaway",
      body: "Because most startup equity ends up worth little, treat it as speculative upside on top of cash compensation, not a substitute for it.",
    },
  ],
  "00000000-0000-0000-0001-000000000217:2":   [
    {
      type: "concept",
      title: "Specific questions signal real interest",
      body: "Questions informed by actually researching the person's background produce better conversations than generic prompts anyone could ask.",
    },
    {
      type: "steps",
      title: "Structuring an informational interview",
      steps: ["A brief, genuine reason for reaching out to them specifically", "2-3 well-prepared, specific questions", "Room for natural conversation", "A clear, low-pressure close"],
    },
    {
      type: "example",
      title: "A researched question",
      body: "\"I saw you moved from an analyst role into a client-facing one after two years — was that deliberate, and what made you ready for it?\"",
    },
    {
      type: "takeaway",
      body: "Specific, researched questions produce a more genuine conversation and respect the other person's generosity in agreeing to talk.",
    },
  ],
  "00000000-0000-0000-0001-000000000217:3":   [
    {
      type: "steps",
      title: "Following up well",
      steps: ["Send a specific thank-you within a day or two", "Reference something particular from the conversation", "Stay in touch periodically, not just when you need something"],
    },
    {
      type: "mistake",
      body: "Sending a generic \"thanks for your time\" instead of referencing something specific — or never following up at all after the initial conversation.",
    },
    {
      type: "example",
      title: "A specific thank-you",
      body: "\"Your point about how you prepared for the client-facing transition was really helpful, and I've started applying it by [specific action].\"",
    },
    {
      type: "takeaway",
      body: "A specific, timely follow-up and genuine periodic staying-in-touch turn a single conversation into a lasting professional relationship.",
    },
  ],
  "00000000-0000-0000-0001-000000000217:1":   [
    {
      type: "concept",
      title: "Networking is relationship-building, not favors",
      body: "Most networking never involves directly asking for anything — the informational interview (asking for perspective, not a job) is the lowest-pressure start.",
    },
    {
      type: "example",
      title: "A specific, low-pressure ask",
      body: "\"I'm a student exploring this path and would love to hear about your experience, if you have 15 minutes sometime in the next few weeks. No pressure at all if you're busy!\"",
    },
    {
      type: "mistake",
      body: "Treating each contact as a one-time transaction instead of following up and staying in touch over time.",
    },
    {
      type: "takeaway",
      body: "Genuine, mutually useful relationships built over time — not transactional asks — are what real networking is.",
    },
  ],
  "00000000-0000-0000-0001-000000000218:2":   [
    {
      type: "mistake",
      body: "Filling a LinkedIn summary with generic language (\"passionate, hardworking team player\") that could describe almost anyone.",
    },
    {
      type: "steps",
      title: "Structuring a genuine summary",
      steps: ["One or two sentences on your current focus or background", "One or two sentences on what you're working toward", "Optionally, an invitation to connect or talk"],
    },
    {
      type: "example",
      title: "A specific, genuine summary",
      body: "\"Finance student building modeling skills through coursework and a student investment club... always happy to connect with others exploring similar paths.\"",
    },
    {
      type: "takeaway",
      body: "A specific, first-person summary stands out precisely because most profiles skip it or fill it with generic language.",
    },
  ],
  "00000000-0000-0000-0001-000000000218:3":   [
    {
      type: "concept",
      title: "Ongoing activity matters, not just a static profile",
      body: "A profile that's never updated or engaged with signals inactivity, even if the initial write-up was strong.",
    },
    {
      type: "steps",
      title: "Low-effort habits that keep a profile active",
      steps: ["Update the profile promptly after a real accomplishment", "Occasionally comment thoughtfully on relevant posts", "Connect with people you've actually met, not strangers"],
    },
    {
      type: "mistake",
      body: "Letting a profile go stale for months or years, then relying on a one-time polished write-up to carry all the impression.",
    },
    {
      type: "takeaway",
      body: "Small, genuine ongoing activity keeps a personal brand credible and current far more than a one-time polished but then-abandoned profile.",
    },
  ],
  "00000000-0000-0000-0001-000000000218:1":   [
    {
      type: "concept",
      title: "Personal brand is a consistent impression",
      body: "What someone learns about you from a LinkedIn profile, resume, or quick search — LinkedIn is usually the highest-leverage piece for an early-career professional.",
    },
    {
      type: "example",
      title: "Weak vs. strong headline",
      body: "Weak: \"Student at University.\" Strong: \"Finance Student | Aspiring Equity Research Analyst | Building financial modeling skills through coursework and projects.\"",
    },
    {
      type: "mistake",
      body: "Discrepancies between resume, LinkedIn, and interview answers (mismatched dates, different framings of the same role) read as a quiet red flag.",
    },
    {
      type: "takeaway",
      body: "A specific headline, a genuine summary, and resume-quality bullets do most of the work — plus keeping the story consistent across surfaces.",
    },
  ],
  "00000000-0000-0000-0001-000000000219:2":   [
    {
      type: "concept",
      title: "FSA elections require forecasting expenses in advance",
      body: "You're predicting a full year of medical spending before the plan year starts, with real forfeiture risk if you overestimate.",
    },
    {
      type: "steps",
      title: "Estimating conservatively",
      steps: ["In your first year, elect only clearly predictable costs", "Avoid guessing high to \"be safe\" — overestimating risks forfeiture", "Adjust the following year based on actual spending data"],
    },
    {
      type: "mistake",
      body: "Guessing an FSA amount high to \"be safe\" — under use-it-or-lose-it rules, overestimating is actually the riskier direction.",
    },
    {
      type: "takeaway",
      body: "Start conservative on FSA elections in your first year and adjust with real data afterward, since overestimating risks forfeiting real money.",
    },
  ],
  "00000000-0000-0000-0001-000000000219:3":   [
    {
      type: "concept",
      title: "Benefits beyond health insurance",
      body: "Disability and supplemental life insurance are easy to overlook during open enrollment but protect against risks health insurance doesn't cover.",
    },
    {
      type: "keyterm",
      term: "Disability insurance",
      definition: "Insurance that replaces lost income if you're unable to work due to illness or injury — distinct from health insurance, which pays for care.",
    },
    {
      type: "mistake",
      body: "Assuming a small automatic employer-provided life insurance amount is \"the benefit\" and never reviewing supplemental options.",
    },
    {
      type: "takeaway",
      body: "Review disability and supplemental life insurance options deliberately each year — they're often available at cheaper group rates and cover real risks health insurance alone misses.",
    },
  ],
  "00000000-0000-0000-0001-000000000219:1":   [
    {
      type: "concept",
      title: "Open enrollment is a defined window",
      body: "Elections are locked in outside this window barring a qualifying life event — worth understanding choices in advance, not reacting in the moment.",
    },
    {
      type: "keyterm",
      term: "HSA vs. FSA",
      definition: "An HSA's balance rolls over indefinitely and can be invested; a standard FSA's balance is typically 'use it or lose it' within the plan year.",
    },
    {
      type: "example",
      title: "$1,400 unused at year-end",
      body: "HSA: stays yours, rolls over. FSA: typically forfeited under 'use it or lose it' rules.",
    },
    {
      type: "takeaway",
      body: "Estimate FSA contributions carefully since unused funds are forfeited; HSA balances carry no such risk.",
    },
  ],
  "00000000-0000-0000-0001-000000000220:2":   [
    {
      type: "concept",
      title: "Not every card suits a first-time applicant",
      body: "Cards marketed to established customers often require credit history you don't yet have — student and secured cards solve this problem.",
    },
    {
      type: "keyterm",
      term: "Secured credit card",
      definition: "A card backed by a cash deposit that typically becomes your credit limit, removing the lender's default risk for someone with no credit history.",
    },
    {
      type: "example",
      title: "Building history with a secured card",
      body: "A $500 deposit card, used carefully for 6-12 months, typically builds enough history to qualify for a better unsecured card.",
    },
    {
      type: "takeaway",
      body: "A first card should prioritize building payment history over rewards or fees — secured or student cards are a common, reliable starting point.",
    },
  ],
  "00000000-0000-0000-0001-000000000220:3":   [
    {
      type: "concept",
      title: "Older accounts generally help your score",
      body: "Closing your first, oldest card can lower your score by shortening average account age and reducing total available credit.",
    },
    {
      type: "mistake",
      body: "Applying for several new credit cards in a short window — each triggers a hard inquiry that temporarily dings the score.",
    },
    {
      type: "example",
      title: "Why to keep an old first card open",
      body: "Keeping a rarely-used first card open, with occasional small use, preserves account-age and available-credit benefits a closure would erase.",
    },
    {
      type: "takeaway",
      body: "Keep old accounts open when reasonable, and space out new credit applications, since both length of history and inquiry frequency affect your score.",
    },
  ],
  "00000000-0000-0000-0001-000000000220:1":   [
    {
      type: "concept",
      title: "A credit score reflects repayment reliability",
      body: "It affects apartment applications, car loan rates, and sometimes job applications in finance-adjacent roles — not just credit card approvals.",
    },
    {
      type: "steps",
      title: "Two habits that matter most",
      steps: ["Pay the full statement balance every month, on time", "Keep credit utilization (share of available credit used) low"],
    },
    {
      type: "example",
      title: "90% utilization, paid in full",
      body: "No interest charged, but a high reported balance before payment posts can still temporarily lower the score.",
    },
    {
      type: "takeaway",
      body: "Missing a payment is typically the single most damaging action, since payment history carries more weight than almost any other factor.",
    },
  ],
  "00000000-0000-0000-0001-000000000221:2":   [
    {
      type: "keyterm",
      term: "Public Service Loan Forgiveness (PSLF)",
      definition: "A federal program forgiving remaining loan balance after 10 years of qualifying payments while working in qualifying government or nonprofit roles.",
    },
    {
      type: "mistake",
      body: "Refinancing federal loans into a private loan for a lower rate, without realizing federal protections (income-driven plans, forgiveness eligibility) are permanently lost.",
    },
    {
      type: "example",
      title: "A costly refinance",
      body: "Someone eligible for PSLF who refinances loses eligibility, potentially forfeiting complete forgiveness of a much larger balance for near-term interest savings.",
    },
    {
      type: "takeaway",
      body: "Understand whether you might realistically use federal loan protections, based on your likely career path, before refinancing into a private loan permanently forfeits them.",
    },
  ],
  "00000000-0000-0000-0001-000000000221:3":   [
    {
      type: "concept",
      title: "Not all extra payments are equal",
      body: "Without explicit instruction, some servicers apply extra payments toward future scheduled payments rather than directly reducing principal.",
    },
    {
      type: "steps",
      title: "Making an extra payment count",
      steps: ["Make the extra payment through your servicer's portal or by written instruction", "Explicitly designate it as \"principal-only\"", "Confirm the designation each time, since some servicers reset the default"],
    },
    {
      type: "example",
      title: "Same $100, different outcomes",
      body: "Undesignated: applied to next month's payment, balance unchanged. Principal-only: directly reduces the balance interest accrues on.",
    },
    {
      type: "takeaway",
      body: "Always explicitly designate extra payments as principal-only to actually capture the intended interest savings.",
    },
  ],
  "00000000-0000-0000-0001-000000000221:1":   [
    {
      type: "concept",
      title: "Use the grace period to understand your loans",
      body: "Roughly 6 months after graduation before repayment begins — time to learn balance, rate, and options before the first bill is due.",
    },
    {
      type: "keyterm",
      term: "Federal vs. private loans",
      definition: "Federal loans usually offer multiple repayment plans, including income-driven options; private loans typically have far less flexibility.",
    },
    {
      type: "table",
      caption: "$30,000 at 5%, standard vs. income-driven",
      headers: ["Plan", "Monthly payment", "Trade-off"],
      rows: [
        ["Standard (10yr)", "~$320", "Fixed, shorter term"],
        ["Income-driven", "~$150", "Lower now, more total interest, longer term"],
      ],
    },
    {
      type: "takeaway",
      body: "Income-driven plans lower near-term payments but usually extend total repayment time and total interest paid — a real trade-off, not a free upgrade.",
    },
  ],
  "00000000-0000-0000-0001-000000000222:2":   [
    {
      type: "concept",
      title: "Written tone is easy to misread",
      body: "A message that feels appropriately direct while writing it can read as sharper than intended once received without vocal tone attached.",
    },
    {
      type: "mistake",
      body: "Sending a message quickly while frustrated, without pausing to consider how it will read to the recipient.",
    },
    {
      type: "example",
      title: "A softer rewrite",
      body: "\"This needs to be fixed today\" becomes \"Can we prioritize fixing this today? I want to get ahead of it before it becomes a bigger issue.\"",
    },
    {
      type: "takeaway",
      body: "Pause before sending a message written while frustrated, and default to a call or in-person conversation for high-stakes or nuanced topics.",
    },
  ],
  "00000000-0000-0000-0001-000000000222:3":   [
    {
      type: "concept",
      title: "Reliability is built from small consistent habits",
      body: "Punctuality, preparation, and following through without reminders shape how colleagues judge reliability, often more than any single dramatic event.",
    },
    {
      type: "steps",
      title: "When you can't follow through as agreed",
      steps: ["Recognize the issue as early as possible", "Communicate it proactively, before being asked", "Give a specific reason and a new realistic estimate"],
    },
    {
      type: "example",
      title: "A proactive heads-up",
      body: "\"Wanted to flag early — this is taking longer because of [reason]. I now expect to finish by [new date].\"",
    },
    {
      type: "takeaway",
      body: "Proactively communicating when you can't follow through as agreed preserves trust far better than silence followed by a missed deadline.",
    },
  ],
  "00000000-0000-0000-0001-000000000222:1":   [
    {
      type: "concept",
      title: "Norms are rarely explicitly taught",
      body: "Response speed, channel choice, and disagreement tone vary by workplace — matching your specific team is a safer default than assuming prior context transfers.",
    },
    {
      type: "steps",
      title: "Disagreeing professionally",
      steps: ["State a concern clearly, with reasoning", "Do it privately with the relevant person first", "Offer to help (e.g. an alternative) rather than just criticize"],
    },
    {
      type: "example",
      title: "A stronger pushback",
      body: "\"I want to flag a concern before we move forward — [reasoning]. Would it help if I put together an alternative, or is there context I'm missing?\"",
    },
    {
      type: "takeaway",
      body: "Raising a clear, reasoned concern privately preserves the relationship better than staying silent or pushing back combatively in a group.",
    },
  ],
  "00000000-0000-0000-0001-000000000223:2":   [
    {
      type: "concept",
      title: "Recognize relevant concepts before reading questions",
      body: "Mentally listing which earlier lessons a scenario seems to draw on, before reading the questions, primes faster recognition once you see them.",
    },
    {
      type: "example",
      title: "Two competing offers scenario",
      body: "Immediately connects to compensation package basics, startup equity, and possibly negotiation — before even reading the specific questions.",
    },
    {
      type: "steps",
      title: "Reading a case scenario",
      steps: ["Read the full scenario once, without jumping to questions", "List which earlier lessons seem relevant", "Then read each question and match it to a concept you've already identified"],
    },
    {
      type: "takeaway",
      body: "Priming yourself on which lessons a scenario draws on, before reading the questions, makes each individual question faster and more confident to answer.",
    },
  ],
  "00000000-0000-0000-0001-000000000223:3":   [
    {
      type: "concept",
      title: "Lead with your core claim",
      body: "Stating your main point in the first sentence, then supporting it, mirrors the headline-first structure that helps in spoken answers too.",
    },
    {
      type: "mistake",
      body: "Describing a concept only indirectly, in your own words, without ever naming the actual term — harder to credit under keyword-based grading.",
    },
    {
      type: "example",
      title: "Naming terms directly",
      body: "\"Vesting\" and \"strike price\" named explicitly, rather than just \"the offer maybe not being as good as it looks.\"",
    },
    {
      type: "takeaway",
      body: "Name specific concepts by their actual terms and lead with your core claim — both make a free-response answer easier to credit.",
    },
  ],
  "00000000-0000-0000-0001-000000000223:1":   [
    {
      type: "concept",
      title: "Real situations combine concepts",
      body: "A single job offer decision might involve negotiation, compensation structure, and equity risk all at once — case studies present a realistic scenario, then ask several questions about it.",
    },
    {
      type: "keyterm",
      term: "Keyword-matched grading",
      definition: "Typed answers are checked for whether they touch the key concepts a strong response should cover, not for matching exact wording.",
    },
    {
      type: "steps",
      title: "Answering a typed question well",
      steps: ["Name the specific concept(s) your answer relies on directly", "Explain briefly why that concept applies to this scenario", "Avoid writing generally around the topic without naming it"],
    },
    {
      type: "takeaway",
      body: "Answering in a few clear sentences that name the relevant concepts directly tends to score better than a vague answer that talks around the topic.",
    },
  ],
};
