import { Nav } from "@/components/Nav";

export default function PrivacyPage() {
  return (
    <div className="flex flex-1 flex-col">
      <Nav />
      <main className="mx-auto w-full max-w-2xl flex-1 px-6 py-16">
        <h1 className="text-3xl font-semibold tracking-tight">Privacy policy</h1>
        <p className="mt-4 text-sm leading-relaxed text-neutral-500">
          FinEsse collects only what&apos;s needed to run a parent-consented
          student account: a parent&apos;s email, a child&apos;s display name, and
          activity within the app (lessons, quizzes, pocket-money practice,
          interview practice). Students never provide real contact
          information — their login is a synthetic, internal address tied to
          a PIN their parent sets. Parental consent is recorded as its own
          explicit step, separate from account creation, and is viewable at
          any time from Settings → Legal.
        </p>
        <p className="mt-4 text-sm leading-relaxed text-neutral-500">
          Data is retained only as long as the account is active. A parent
          can request deletion of their account and any linked children from
          Settings → Legal at any time.
        </p>
      </main>
    </div>
  );
}
