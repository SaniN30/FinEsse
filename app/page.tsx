import { Nav } from "@/components/Nav";
import { Hero } from "@/components/Hero";
import { LevelSection } from "@/components/LevelSection";
import { PocketMoneyPlanner } from "@/components/PocketMoneyPlanner";

export default function Home() {
  return (
    <div className="flex flex-1 flex-col">
      <Nav />
      <main className="flex-1">
        <Hero />
        <LevelSection />
        <PocketMoneyPlanner />
      </main>
    </div>
  );
}
