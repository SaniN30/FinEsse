import type { LessonBlock } from "@/lib/lessons/content-blocks";

/**
 * Structured presentation overrides for a sample of existing lessons, keyed
 * by `skill_id`. When a lesson's skill has an entry here, `LessonDetail`
 * renders these blocks (concept cards, key terms, tables, steps, diagrams)
 * instead of the raw `content_body` paragraph — same underlying facts as the
 * lesson's `content_body`, restructured for scannability. Lessons with no
 * entry keep rendering their plain `content_body` unchanged.
 *
 * This lives in code rather than the database so it ships without touching
 * the live Supabase migration history (see AGENTS.md's migration-numbering-
 * collision notes) — a lesson's `content_body` remains the source of truth
 * for the facts; adding an entry here is a presentation-only decision and can
 * be migrated into `content_body` later if the team standardizes on that.
 */
export const lessonContentOverrides: Record<string, LessonBlock[]> = {
  // School — compound-interest-basics
  "00000000-0000-0000-0001-000000000005": [
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
  "00000000-0000-0000-0001-000000000006": [
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
  "00000000-0000-0000-0001-000000000007": [
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
  "00000000-0000-0000-0001-000000000105": [
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
  "00000000-0000-0000-0001-000000000108": [
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
  "00000000-0000-0000-0001-000000000106": [
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
  "00000000-0000-0000-0001-000000000201": [
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
  "00000000-0000-0000-0001-000000000208": [
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
  "00000000-0000-0000-0001-000000000203": [
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
};
