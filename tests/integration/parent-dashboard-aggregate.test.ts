import { beforeAll, describe, expect, it } from "vitest";
import { createStudentAccount, recordConsent, serviceClient, signUpParent } from "./helpers";

describe("parent dashboard aggregate view", () => {
  let parentA: Awaited<ReturnType<typeof signUpParent>>;
  let parentB: Awaited<ReturnType<typeof signUpParent>>;
  let studentAId: string;
  let studentBId: string;

  beforeAll(async () => {
    parentA = await signUpParent("Dashboard Parent A");
    parentB = await signUpParent("Dashboard Parent B");

    const consentA = await recordConsent(parentA.accessToken, "Dashboard Kid A");
    const createdA = await createStudentAccount(parentA.accessToken, {
      consentId: consentA,
      displayName: "Dashboard Kid A",
      pin: "1111",
    });
    expect(createdA.status).toBe(200);
    studentAId = createdA.body.student_id;

    const consentB = await recordConsent(parentB.accessToken, "Dashboard Kid B");
    const createdB = await createStudentAccount(parentB.accessToken, {
      consentId: consentB,
      displayName: "Dashboard Kid B",
      pin: "2222",
    });
    expect(createdB.status).toBe(200);
    studentBId = createdB.body.student_id;

    const admin = serviceClient();

    // Give student A some XP, a skill attempt (for mastery %), a wallet with
    // a balance, a savings goal, and a scored interview session, so the
    // aggregate view has non-empty data to roll up for at least one child.
    const { data: skill, error: skillError } = await admin
      .from("skills")
      .select("id")
      .eq("tier", "school")
      .limit(1)
      .single();
    expect(skillError).toBeNull();

    const { error: attemptError } = await admin.from("skill_attempts").insert({
      profile_id: studentAId,
      skill_id: skill!.id,
      is_correct: true,
    });
    expect(attemptError).toBeNull();

    const { error: xpError } = await admin.from("xp_events").insert({
      profile_id: studentAId,
      source: "bonus",
      xp_delta: 50,
    });
    expect(xpError).toBeNull();

    const { data: wallet, error: walletError } = await admin
      .from("accounts")
      .insert({ profile_id: studentAId, type: "student_wallet", name: "Wallet" })
      .select("id")
      .single();
    expect(walletError).toBeNull();

    const { data: goalAccount, error: goalError } = await admin
      .from("accounts")
      .insert({
        profile_id: studentAId,
        type: "savings_goal",
        name: "New Bike",
        target_amount_cents: 20000,
      })
      .select("id")
      .single();
    expect(goalError).toBeNull();

    // Fund the wallet from an external parent_wallet counterparty, then
    // move part of it into the savings goal -- both via balanced
    // transactions (postings for a transaction must net to zero, per the
    // ledger enforcement covered in ledger-balance.test.ts) -- so both
    // derived balances (wallet: 1000, goal: 5000) are non-zero for the
    // aggregate view's own tests.
    const { data: parentWallet, error: parentWalletError } = await admin
      .from("accounts")
      .insert({ profile_id: parentA.userId, type: "parent_wallet", name: "Parent Wallet" })
      .select("id")
      .single();
    expect(parentWalletError).toBeNull();

    const { data: fundingTxn, error: fundingTxnError } = await admin
      .from("transactions")
      .insert({ description: "seed wallet", created_by: parentA.userId })
      .select("id")
      .single();
    expect(fundingTxnError).toBeNull();

    const { error: fundingPostingError } = await admin.from("postings").insert([
      { transaction_id: fundingTxn!.id, account_id: parentWallet!.id, amount_cents: -6000 },
      { transaction_id: fundingTxn!.id, account_id: wallet!.id, amount_cents: 6000 },
    ]);
    expect(fundingPostingError).toBeNull();

    const { data: goalTxn, error: goalTxnError } = await admin
      .from("transactions")
      .insert({ description: "deposit to goal", created_by: studentAId })
      .select("id")
      .single();
    expect(goalTxnError).toBeNull();

    const { error: goalPostingError } = await admin.from("postings").insert([
      { transaction_id: goalTxn!.id, account_id: wallet!.id, amount_cents: -5000 },
      { transaction_id: goalTxn!.id, account_id: goalAccount!.id, amount_cents: 5000 },
    ]);
    expect(goalPostingError).toBeNull();

    const { error: interviewError } = await admin.from("interview_sessions").insert({
      profile_id: studentAId,
      firm_style: "consulting",
      transcript: [],
      rubric_scores: { overall_feedback: "Solid answer.", star_structure: { score: 4 } },
    });
    expect(interviewError).toBeNull();
  });

  it("returns exactly one row for a parent's single linked child, with derived fields populated", async () => {
    const { data, error } = await parentA.client
      .from("parent_dashboard_children")
      .select("*")
      .eq("profile_id", studentAId);

    expect(error).toBeNull();
    expect(data).toHaveLength(1);

    const row = data![0];
    expect(row.tier).toBe("school");
    expect(row.total_xp).toBe(50);
    expect(row.avg_mastery_pct).not.toBeNull();
    expect(row.wallet_balance_cents).toBe(1000);
    expect(row.savings_goals).toHaveLength(1);
    expect(row.savings_goals[0].name).toBe("New Bike");
    expect(row.savings_goals[0].balance_cents).toBe(5000);
    expect(row.interview_sessions).toHaveLength(1);
    expect(row.interview_sessions[0].firm_style).toBe("consulting");
  });

  it("returns a sensible empty-state row for a child with no XP, goals, or interview sessions", async () => {
    const { data, error } = await parentB.client
      .from("parent_dashboard_children")
      .select("*")
      .eq("profile_id", studentBId);

    expect(error).toBeNull();
    expect(data).toHaveLength(1);

    const row = data![0];
    expect(row.total_xp).toBe(0);
    expect(row.avg_mastery_pct).toBeNull();
    expect(row.wallet_balance_cents).toBe(0);
    expect(row.savings_goals).toEqual([]);
    expect(row.interview_sessions).toEqual([]);
  });

  it("prevents a parent from seeing another parent's child through the aggregate view", async () => {
    const { data, error } = await parentB.client
      .from("parent_dashboard_children")
      .select("*")
      .eq("profile_id", studentAId);

    expect(error).toBeNull();
    expect(data).toHaveLength(0);
  });

  it("a parent's aggregate query only ever returns their own linked children", async () => {
    const { data, error } = await parentA.client.from("parent_dashboard_children").select("*");

    expect(error).toBeNull();
    expect(data!.every((row) => row.profile_id === studentAId)).toBe(true);
    expect(data!.some((row) => row.profile_id === studentBId)).toBe(false);
  });
});
