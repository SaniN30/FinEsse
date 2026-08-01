import { Nav } from "@/components/Nav";
import { PocketMoneyPlanner } from "@/components/PocketMoneyPlanner";

export default function CollegePocketMoneyPage() {
  return (
    <div className="flex flex-1 flex-col">
      <Nav />
      <main className="flex-1 py-16">
        <PocketMoneyPlanner />
      </main>
    </div>
  );
}
