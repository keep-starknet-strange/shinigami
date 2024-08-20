"use client";

import ScriptEditor from "@/components/script-editor";
import StackVisualizer from "@/components/stack-visualizer";
import { useState } from "react";

export default function Home() {
  const [stackContent, setStackContent] = useState([]);

  const handleStackContentChange = (
    newContent: Array<{ id: number; value: string }>,
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
