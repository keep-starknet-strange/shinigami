"use client";

import ShinigamiIDE from "../components/ShinigamiIDE";

export default function Home() {
  return (
    <main className="min-h-screen bg-black p-4">
      <h1 className="text-4xl font-bold mb-8 text-center text-green-400">
        SHINIGAMI SCRIPT WIZARD
      </h1>
      <ShinigamiIDE />
    </main>
  );
}
