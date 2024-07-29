"use client";

import ShinigamiIDE from "../components/ShinigamiIDE";

export default function Home() {
  return (
    <main className="min-h-screen bg-gray-100 p-4">
      <h1 className="text-4xl font-bold mb-8 text-center">
        Shinigami Bitcoin Script IDE
      </h1>
      <ShinigamiIDE />
    </main>
  );
}
