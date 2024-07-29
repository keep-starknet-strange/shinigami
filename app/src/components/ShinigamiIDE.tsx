"use client";

import React, { useState } from "react";
import dynamic from "next/dynamic";
import { FaPlay, FaCog } from "react-icons/fa";
import StackVisualizer from "./StackVisualizer";
import ProofStatus from "./ProofStatus";

const Editor = dynamic(() => import("@monaco-editor/react"), { ssr: false });

const ShinigamiIDE: React.FC = () => {
  const [script, setScript] = useState(`OP_ADD
<3>
OP_EQUAL`);
  const [stackContent, setStackContent] = useState<
    Array<{ id: number; value: string }>
  >([]);
  const [isGeneratingProof, setIsGeneratingProof] = useState(false);

  const handleRunScript = () => {
    console.log("Running script:", script);
    setStackContent([
      { id: 1, value: "OP_ADD" },
      { id: 2, value: "3" },
      { id: 3, value: "OP_EQUAL" },
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
    <div className="grid grid-cols-1 md:grid-cols-2 gap-4 p-4">
      <div className="retro-container p-4">
        <h2 className="text-xl mb-4">SCRIPT EDITOR</h2>
        <Editor
          height="300px"
          defaultLanguage="plaintext"
          value={script}
          onChange={(value) => setScript(value || "")}
          theme="vs-dark"
          options={{
            fontFamily: '"Press Start 2P", cursive',
            fontSize: 14,
            lineHeight: 24,
          }}
        />
        <div className="mt-4 flex justify-end space-x-4">
          <button className="retro-button" onClick={handleRunScript}>
            <FaPlay className="inline mr-2" /> RUN
          </button>
          <button
            className="retro-button"
            onClick={handleGenerateProof}
            disabled={isGeneratingProof}
          >
            <FaCog
              className={`inline mr-2 ${
                isGeneratingProof ? "animate-spin" : ""
              }`}
            />
            {isGeneratingProof ? "GENERATING..." : "GENERATE PROOF"}
          </button>
        </div>
      </div>

      <div className="retro-container p-4">
        <h2 className="text-xl mb-4">STACK VISUALIZER</h2>
        <StackVisualizer stackContent={stackContent} />
        <ProofStatus isGenerating={isGeneratingProof} />
      </div>
    </div>
  );
};

export default ShinigamiIDE;
