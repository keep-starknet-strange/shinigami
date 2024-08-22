"use client";

import StackVisualizer from "@/components/stack-visualizer";
import { Editor } from "@monaco-editor/react";
import Image from "next/image";
import Footer from "./footer";

import refreshImage from "@/images/refresh-icon.svg";
import splitImage from "@/images/split.svg";
import unsplitImage from "@/images/unsplit.svg";
import clsx from "@/utils/lib";
import { useState } from "react";

export default function ScriptEditor() {
  const [scriptSig, setScriptSig] = useState("ScriptSig");
  const [scriptPubKey, setScriptPubKey] = useState("ScriptPubKey");

  const [stackContent, setStackContent] = useState<
    { id: number; value: string }[]
  >([]);

  const handleRunScript = () => {
    const newStackContent = [
      { id: 1, value: "0x42" },
      { id: 2, value: "0x01" },
      { id: 3, value: "0x03" },
    ];
    setStackContent(newStackContent);
  };

  const [split, setSplit] = useState(false);

  const setEditorTheme = (monaco: any) => {
    monaco.editor.defineTheme("darker", {
      base: "hc-black",
      inherit: true,
      rules: [
      ],
      colors: {
        "editor.selectionBackground": "#A5FFC240",
        "editorLineNumber.foreground": "#258F42",
        "editorLineNumber.activeForeground": "#A5FFC2",
        "focusBorder": "#00000000",
        "scrollbar.shadow": "#00000000",
        "scrollbarSlider.background": "#258F4240",
        "scrollbarSlider.activeBackground": "#258F4260",
        "scrollbarSlider.hoverBackground": "#258F4245",
      },
    });
  };

  return (
    <div className="w-full min-h-screen h-full">
      <div className="w-full flex flex-row items-center justify-between">
        <div className="w-36 h-10 bg-[#232523AE] clip-trapezium-right flex flex-col items-start justify-center pl-2.5 pt-1.5 rounded-t-xl">
          <p className="text-[#85FFB2] text-lg">Script Editor</p>
        </div>
        <button
          className="flex flex-row items-center space-x-1"
          onClick={() => setSplit(!split)}
        >
          <Image src={split ? unsplitImage : splitImage} alt="" unoptimized />
          <p className="text-white uppercase">
            {split ? "Unsplit" : "Split"} Editor
          </p>
        </button>
      </div>
      <div
        className={clsx(
          split ? "border-b-4" : "rounded-b-xl h-44",
          "w-full border-8 border-[#232523AE] bg-black overflow-y rounded-tr-xl",
        )}
      >
        <Editor
          beforeMount={setEditorTheme}
          theme="darker"
          defaultLanguage="plaintext"
          value={scriptSig}
          onChange={(value: string | undefined) =>
            setScriptSig(value || "") as any
          }
          options={{
            fontSize: 16,
            lineHeight: 24,
            renderLineHighlight: "none",
          }}
        />
      </div>
      {split && (
        <div
          className={clsx(
            split && "border-t-4 h-44",
            "w-full border-8 border-[#232523AE] bg-black rounded-b-xl",
          )}
        >
          <Editor
            theme="darker"
            defaultLanguage="plaintext"
            value={scriptPubKey}
            onChange={(value: string | undefined) =>
              setScriptPubKey(value || "")
            }
            options={{
              fontSize: 16,
              lineHeight: 24,
              renderLineHighlight: "none",
            }}
          />
        </div>
      )}
      <div className="w-full flex flex-col space-y-3.5 sm:space-y-0 sm:flex-row sm:items-center sm:justify-between mb-10">
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
      <StackVisualizer stackContent={stackContent} />
      <Footer />
    </div>
  );
}
