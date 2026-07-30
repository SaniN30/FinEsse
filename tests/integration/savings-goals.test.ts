import { beforeAll, describe, expect, it } from "vitest";
import { createStudentAccount, recordConsent, signInStudent, signUpParent } from "./helpers";

describe("pocket money planner: savings goals", () => {
  let parentA: Awaited<ReturnType<typeof signUpParent>>;
  let studentA: Awaited<ReturnType<typeof signInStudent>>;
  let studentB: Awaited<ReturnType<typeof signInStudent>>;
  let goalId: string;

  beforeAll(async () => {
    parentA = await signUpParent("Savings Parent A");
    const parentB = await signUpParent("Savings Parent B");

    const consentA = await recordConsent(parentA.accessToken, "Savings Kid A");
    const createdA = await createStudentAccount(parentA.accessToken, {
      consentId: consentA,
      displayName: "Savings Kid A",
      pin: "1111",
    });
    expect(createdA.status).toBe(200);
    studentA = await signInStudent(createdA.body.login_email, "1111");

    const consentB = await recordConsent(parentB.accessToken, "Savings Kid B");
    const createdB = await createStudentAccount(parentB.accessToken, {
      consentId: consentB,
      displayName: "Savings Kid B",
      pin: "2222",
    });
    expect(createdB.status).toBe(200);
    studentB = await signInStudent(createdB.body.login_email, "2222");

    const { data, error } = await studentA.client.rpc("create_savings_goal", {
      p_name: "New Headphones",
      p_target_amount_cents: 10000,
    });
    expect(error).toBeNull();
    goalId = data as string;
  });

  it("creates a savings_goal account with the requested target", async () => {
    const { data, error } = await studentA.client
      .from("accounts")
      .select("type, target_amount_cents")
      .eq("id", goalId)
      .single();

    expect(error).toBeNull();
    expect(data!.type).toBe("savings_goal");
    expect(data!.target_amount_cents).toBe(10000);
  });

  it("deposit increases the goal balance and decreases the student wallet, netting to zero", async () => {
    const { error: depositError } = await studentA.client.rpc("deposit_to_savings_goal", {
      p_goal_account_id: goalId,
      p_amount_cents: 2500,
    });
    expect(depositError).toBeNull();

    const { data: progress, error: progressError } = await studentA.client
      .from("savings_goal_progress")
      .select("balance_cents, percent_complete")
      .eq("account_id", goalId)
      .single();
    expect(progressError).toBeNull();
    expect(progress!.balance_cents).toBe(2500);
    expect(progress!.percent_complete).toBe(25);

    const { data: wallet, error: walletError } = await studentA.client
      .from("account_balances")
      .select("balance_cents")
      .eq("profile_id", studentA.userId)
      .eq("type", "student_wallet")
      .single();
    expect(walletError).toBeNull();
    expect(wallet!.balance_cents).toBe(-2500);
  });

  it("withdrawal reverses a deposit", async () => {
    const { error: withdrawError } = await studentA.client.rpc("withdraw_from_savings_goal", {
      p_goal_account_id: goalId,
      p_amount_cents: 1000,
    });
    expect(withdrawError).toBeNull();

    const { data: progress, error: progressError } = await studentA.client
      .from("savings_goal_progress")
      .select("balance_cents")
      .eq("account_id", goalId)
      .single();
    expect(progressError).toBeNull();
    expect(progress!.balance_cents).toBe(1500);

    const { data: wallet, error: walletError } = await studentA.client
      .from("account_balances")
      .select("balance_cents")
      .eq("profile_id", studentA.userId)
      .eq("type", "student_wallet")
      .single();
    expect(walletError).toBeNull();
    expect(wallet!.balance_cents).toBe(-1500);
  });

  it("rejects a withdrawal that would overdraw the goal", async () => {
    const { error } = await studentA.client.rpc("withdraw_from_savings_goal", {
      p_goal_account_id: goalId,
      p_amount_cents: 999999,
    });
    expect(error).not.toBeNull();
  });

  it("prevents a student from depositing into another student's goal", async () => {
    const { error } = await studentB.client.rpc("deposit_to_savings_goal", {
      p_goal_account_id: goalId,
      p_amount_cents: 100,
    });
    expect(error).not.toBeNull();
  });

  it("prevents a student from withdrawing from another student's goal", async () => {
    const { error } = await studentB.client.rpc("withdraw_from_savings_goal", {
      p_goal_account_id: goalId,
      p_amount_cents: 100,
    });
    expect(error).not.toBeNull();
  });

  it("lets a linked parent read but not write a child's savings-goal account and transactions", async () => {
    const { data: accountData, error: accountReadError } = await parentA.client
      .from("accounts")
      .select("id")
      .eq("id", goalId);
    expect(accountReadError).toBeNull();
    expect(accountData!.length).toBe(1);

    const { data: progressData, error: progressReadError } = await parentA.client
      .from("savings_goal_progress")
      .select("account_id, balance_cents")
      .eq("account_id", goalId);
    expect(progressReadError).toBeNull();
    expect(progressData!.length).toBe(1);

    const { error: accountWriteError } = await parentA.client.from("accounts").insert({
      profile_id: studentA.userId,
      type: "savings_goal",
      name: "Parent-opened goal",
      target_amount_cents: 5000,
    });
    expect(accountWriteError).not.toBeNull();

    const { error: rpcError } = await parentA.client.rpc("deposit_to_savings_goal", {
      p_goal_account_id: goalId,
      p_amount_cents: 100,
    });
    expect(rpcError).not.toBeNull();
  });
});
