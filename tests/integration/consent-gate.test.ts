import { describe, expect, it } from "vitest";
import { createStudentAccount, recordConsent, serviceClient, signUpParent } from "./helpers";

describe("parent-consent gate for student account creation", () => {
  it("rejects create-student-account with a fabricated/nonexistent consent id", async () => {
    const parent = await signUpParent("No Consent Parent");

    const result = await createStudentAccount(parent.accessToken, {
      consentId: "00000000-0000-0000-0000-000000000000",
      displayName: "Ghost Kid",
      pin: "9999",
    });

    expect(result.status).toBe(404);
  });

  it("rejects using another parent's consent record", async () => {
    const parentA = await signUpParent("Consent Owner");
    const parentB = await signUpParent("Consent Thief");

    const consentId = await recordConsent(parentA.accessToken, "Kid A");

    const result = await createStudentAccount(parentB.accessToken, {
      consentId,
      displayName: "Kid A",
      pin: "2468",
    });

    expect(result.status).toBe(403);
  });

  it("cannot bypass the consent gate with a direct service-role insert into profiles", async () => {
    const parent = await signUpParent("Direct Insert Parent");
    const admin = serviceClient();

    const { error } = await admin.from("profiles").insert({
      id: "11111111-1111-1111-1111-111111111111",
      role: "student",
      parent_id: parent.userId,
      display_name: "Bypass Kid",
      consent_id: null,
    });

    expect(error).not.toBeNull();
    expect(error!.message).toMatch(/requires a recorded parental consent/);
  });

  it("cannot bypass the gate by pointing at an unconsented (consent_given=false) record", async () => {
    const parent = await signUpParent("False Consent Parent");
    const admin = serviceClient();

    const { data: consent, error: consentError } = await admin
      .from("parental_consents")
      .insert({
        parent_id: parent.userId,
        child_display_name: "Unconsented Kid",
        consent_given: false,
        consent_version: "coppa-gdprk-v1",
      })
      .select("id")
      .single();
    expect(consentError).toBeNull();

    const { error } = await admin.from("profiles").insert({
      id: "22222222-2222-2222-2222-222222222222",
      role: "student",
      parent_id: parent.userId,
      display_name: "Unconsented Kid",
      consent_id: consent!.id,
    });

    expect(error).not.toBeNull();
    expect(error!.message).toMatch(/has not been explicitly given/);
  });

  it("succeeds end-to-end once consent is properly recorded", async () => {
    const parent = await signUpParent("Happy Path Parent");
    const consentId = await recordConsent(parent.accessToken, "Happy Kid");

    const result = await createStudentAccount(parent.accessToken, {
      consentId,
      displayName: "Happy Kid",
      pin: "1357",
    });

    expect(result.status).toBe(200);
    expect(result.body.student_id).toBeTruthy();
  });
});
