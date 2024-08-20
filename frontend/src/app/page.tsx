"use client";

import ScriptEditor from "@/components/script-editor";
import StackVisualizer from "@/components/stack-visualizer";
import { useState } from "react";

export default function Home() {
  const [stackContent, setStackContent] = useState<{ id: number; value: string }[]>([]);

  const handleStackContentChange = (
    newContent: { id: number; value: string }[],
  ) => {
    setStackContent(newContent);
  };

  return (
    <div className="w-full max-w-4xl flex flex-col items-center justify-between space-y-5">
      <ScriptEditor onStackContentChange={handleStackContentChange} />
      <StackVisualizer stackContent={stackContent} />
    </div>
  );
}