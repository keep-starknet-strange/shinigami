"use client";

import Editor from "@monaco-editor/react";
import Image from "next/image";

import { useState } from "react";
import splitImage from "@/images/split.svg";
import unsplitImage from "@/images/unsplit.svg";
import refreshImage from "@/images/refresh-icon.svg";
import clsx from "../../lib/utils";

interface ScriptEditorProps {
  onStackContentChange: (content: Array<{ id: number; value: string }>) => void;
}

export default function ScriptEditor({
  onStackContentChange,
}: ScriptEditorProps) {
  const [scriptSig, setScriptSig] = useState("ScriptSig");
  const [scriptPubKey, setScriptPubKey] = useState("ScriptPubKey");

  const [stackContent, setStackContent] = useState([]);

  const handleRunScript = () => {
    const newStackContent = [
      { id: 1, value: "OP_ADD" },
      { id: 2, value: "3" },
      { id: 3, value: "OP_EQUAL" },
    ];
    setStackContent(newStackContent);
    onStackContentChange(newStackContent);
  };

  const [split, setSplit] = useState(false);

  return (
    <div className="w-full">
      <div className="w-full flex flex-row items-center justify-between">
        <div className="w-36 h-10 bg-[#0E0E0E] clip-trapezium-right flex flex-col items-start justify-center pl-2.5 pt-1.5 rounded-t-xl">
          <p className="text-[#85FFB2] text-lg">Script Editor</p>
        </div>
        <button className="flex flex-row items-center space-x-1" onClick={() => setSplit(!split)}>
          <Image src={split ? unsplitImage : splitImage} alt="" unoptimized />
          <p className="text-white uppercase">{split ? "Unsplit" : "Split"} Editor</p>
        </button>
      </div>
      <div className={clsx(split ? "border-b-4" : "rounded-b-xl", "w-full border-8 border-[#0E0E0E] h-40 bg-black overflow-y-scroll rounded-tr-xl")}>
        <Editor
          height={310}
          defaultLanguage="plaintext"
          theme="vs-dark"
          value={scriptSig}
          onChange={(value: string) => setScriptSig(value || "")}
          options={{
            fontSize: 16,
            lineHeight: 24,
          }}
        />
      </div>
      {
        split && <div className={clsx(split && "border-t-4", "w-full border-8 border-[#0E0E0E] h-40 bg-black overflow-y-scroll rounded-b-xl")}>
          <Editor
            height={310}
            defaultLanguage="plaintext"
            theme="vs-dark"
            value={scriptPubKey}
            onChange={(value: string) => setScriptPubKey(value || "")}
            options={{
              fontSize: 16,
              lineHeight: 24,
            }}
          />
        </div>
      }
      <div className="w-full flex flex-col space-y-3.5 sm:space-y-0 sm:flex-row sm:items-center sm:justify-between">
        <div className="mt-5 flex flex-col space-y-3.5 sm:space-y-0 sm:flex-row sm:items-center sm:space-x-3.5">
          <button
            className="bg-[#00FF5E] uppercase text-black px-6 py-3 rounded-[3px] opacity-50 shadow-[0px_4px_8px_2px_rgba(0,255,94,0.20)]"
            onClick={handleRunScript}
          >
            Run Script
          </button>
          <button className="bg-[rgba(0,255,94,0.10)] text-[#00FF5E] border border-[#00FF5E] border-opacity-50 px-3 py-3 rounded-[3px] opacity-50  uppercase">
            Debug Script
          </button>
        </div>
        <button className="flex flex-row items-center justify-center space-x-1.5">
          <Image src={refreshImage} alt="" unoptimized />
          <p className="text-white uppercase">Refresh</p>
        </button>
      </div>
    </div>
  );
}
