import { beforeAll, describe, expect, it } from "vitest";
import { createStudentAccount, recordConsent, serviceClient, signUpParent } from "./helpers";

describe("ledger postings balance enforcement", () => {
  let parent: Awaited<ReturnType<typeof signUpParent>>;
  let studentId: string;
  let walletAccountId: string;
  let savingsAccountId: string;

  beforeAll(async () => {
    parent = await signUpParent("Ledger Parent");
    const consentId = await recordConsent(parent.accessToken, "Ledger Kid");
    const created = await createStudentAccount(parent.accessToken, {
      consentId,
      displayName: "Ledger Kid",
      pin: "1111",
    });
    expect(created.status).toBe(200);
    studentId = created.body.student_id;

    const admin = serviceClient();
    const { data: wallet, error: walletError } = await admin
      .from("accounts")
      .insert({ profile_id: studentId, type: "student_wallet", name: "Wallet" })
      .select("id")
      .single();
    expect(walletError).toBeNull();
    walletAccountId = wallet!.id;

    const { data: savings, error: savingsError } = await admin
      .from("accounts")
      .insert({ profile_id: studentId, type: "savings_goal", name: "Savings" })
      .select("id")
      .single();
    expect(savingsError).toBeNull();
    savingsAccountId = savings!.id;
  });

  it("rejects postings that do not net to zero", async () => {
    const admin = serviceClient();

    const { data: txn, error: txnError } = await admin
      .from("transactions")
      .insert({ description: "unbalanced transfer", created_by: studentId })
      .select("id")
      .single();
    expect(txnError).toBeNull();

    const { error: postingError } = await admin.from("postings").insert([
      { transaction_id: txn!.id, account_id: walletAccountId, amount_cents: -500 },
      { transaction_id: txn!.id, account_id: savingsAccountId, amount_cents: 400 },
    ]);

    expect(postingError).not.toBeNull();
    expect(postingError!.message).toMatch(/do not net to zero/);
  });

  it("accepts postings that net to zero", async () => {
    const admin = serviceClient();

    const { data: txn, error: txnError } = await admin
      .from("transactions")
      .insert({ description: "balanced transfer", created_by: studentId })
      .select("id")
      .single();
    expect(txnError).toBeNull();

    const { error: postingError } = await admin.from("postings").insert([
      { transaction_id: txn!.id, account_id: walletAccountId, amount_cents: -500 },
      { transaction_id: txn!.id, account_id: savingsAccountId, amount_cents: 500 },
    ]);

    expect(postingError).toBeNull();
  });
});
