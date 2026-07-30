import { beforeAll, describe, expect, it } from "vitest";
import {
  createStudentAccount,
  recordConsent,
  serviceClient,
  signInStudent,
  signUpParent,
} from "./helpers";

describe("RLS isolation", () => {
  let parentA: Awaited<ReturnType<typeof signUpParent>>;
  let parentB: Awaited<ReturnType<typeof signUpParent>>;
  let studentA: { userId: string; email: string };
  let studentB: { userId: string; email: string };

  beforeAll(async () => {
    parentA = await signUpParent("Parent A");
    parentB = await signUpParent("Parent B");

    const consentA = await recordConsent(parentA.accessToken, "Kid A");
    const createdA = await createStudentAccount(parentA.accessToken, {
      consentId: consentA,
      displayName: "Kid A",
      pin: "1234",
    });
    expect(createdA.status).toBe(200);
    studentA = { userId: createdA.body.student_id, email: createdA.body.login_email };

    const consentB = await recordConsent(parentB.accessToken, "Kid B");
    const createdB = await createStudentAccount(parentB.accessToken, {
      consentId: consentB,
      displayName: "Kid B",
      pin: "5678",
    });
    expect(createdB.status).toBe(200);
    studentB = { userId: createdB.body.student_id, email: createdB.body.login_email };
  });

  it("lets a parent read their own linked child", async () => {
    const { data, error } = await parentA.client
      .from("profiles")
      .select("id")
      .eq("id", studentA.userId);

    expect(error).toBeNull();
    expect(data).toHaveLength(1);
  });

  it("prevents a parent from reading an unrelated student", async () => {
    const { data, error } = await parentA.client
      .from("profiles")
      .select("id")
      .eq("id", studentB.userId);

    expect(error).toBeNull();
    expect(data).toHaveLength(0);
  });

  it("prevents a student from reading another student's profile", async () => {
    const student = await signInStudent(studentA.email, "1234");

    const { data: ownRow, error: ownError } = await student.client
      .from("profiles")
      .select("id")
      .eq("id", studentA.userId);
    expect(ownError).toBeNull();
    expect(ownRow).toHaveLength(1);

    const { data: otherRow, error: otherError } = await student.client
      .from("profiles")
      .select("id")
      .eq("id", studentB.userId);
    expect(otherError).toBeNull();
    expect(otherRow).toHaveLength(0);
  });

  it("prevents a student from reading their parent's own profile row", async () => {
    const student = await signInStudent(studentA.email, "1234");

    const { data, error } = await student.client
      .from("profiles")
      .select("id")
      .eq("id", parentA.userId);

    expect(error).toBeNull();
    expect(data).toHaveLength(0);
  });

  it("service role bypasses RLS for admin operations", async () => {
    const admin = serviceClient();
    const { data, error } = await admin.from("profiles").select("id").eq("id", studentB.userId);
    expect(error).toBeNull();
    expect(data).toHaveLength(1);
  });
});
