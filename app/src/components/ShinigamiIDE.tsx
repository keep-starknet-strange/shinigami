"use client";

import React, { useState } from "react";
import dynamic from "next/dynamic";
import { FaPlay, FaCog } from "react-icons/fa";
import StackVisualizer from "./StackVisualizer";
import ProofStatus from "./ProofStatus";

const Editor = dynamic(() => import("@monaco-editor/react"), { ssr: false });

const ShinigamiIDE: React.FC = () => {
  const [script, setScript] = useState("");
  const [stackContent, setStackContent] = useState<
    Array<{ id: number; value: string }>
  >([]);
  const [isGeneratingProof, setIsGeneratingProof] = useState(false);

  const handleRunScript = () => {
    console.log("Running script:", script);
    setStackContent([
      { id: 1, value: "OP_1" },
      { id: 2, value: "OP_2" },
      { id: 3, value: "OP_ADD" },
    ]);
  };

  const handleGenerateProof = () => {
    setIsGeneratingProof(true);
    setTimeout(() => {
      setIsGeneratingProof(false);
      console.log("Proof generated for script:", script);
    }, 3000);
  };

  return (
    <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
      <div className="bg-white rounded-lg shadow-md p-4">
        <h2 className="text-2xl font-semibold mb-4">Script Editor</h2>
        <Editor
          height="400px"
          defaultLanguage="plaintext"
          value={script}
          onChange={(value) => setScript(value || "")}
          theme="vs-dark"
        />
        <div className="mt-4 flex justify-end space-x-4">
          <button
            className="bg-blue-500 hover:bg-blue-600 text-white font-bold py-2 px-4 rounded flex items-center"
            onClick={handleRunScript}
          >
            <FaPlay className="mr-2" /> Run Script
          </button>
          <button
            className="bg-green-500 hover:bg-green-600 text-white font-bold py-2 px-4 rounded flex items-center"
            onClick={handleGenerateProof}
            disabled={isGeneratingProof}
          >
            <FaCog
              className={`mr-2 ${isGeneratingProof ? "animate-spin" : ""}`}
            />
            {isGeneratingProof ? "Generating..." : "Generate Proof"}
          </button>
        </div>
      </div>

      <div className="bg-white rounded-lg shadow-md p-4">
        <h2 className="text-2xl font-semibold mb-4">Stack Visualizer</h2>
        <StackVisualizer stackContent={stackContent} />
        <ProofStatus isGenerating={isGeneratingProof} />
      </div>
    </div>
  );
};

export default ShinigamiIDE;
