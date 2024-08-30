"use client";

import { Jura } from "next/font/google";
import StackVisualizer from "@/components/stack-visualizer";
import { Editor } from "@monaco-editor/react";
import Image from "next/image";
import Footer from "./footer";

import refreshImage from "@/images/refresh-icon.svg";
import splitImage from "@/images/split.svg";
import unsplitImage from "@/images/unsplit.svg";
import clsx from "@/utils/lib";
import { Dispatch, SetStateAction, useState } from "react";
import { StackItem } from "../../types";

const jura = Jura({subsets: ["latin"]});

export default function ScriptEditor() {
  const [scriptSig, setScriptSig] = useState("");
  const [scriptPubKey, setScriptPubKey] = useState("OP_1 OP_2 OP_ADD OP_3 OP_EQUAL OP_HASH160");

  const [stackContent, setStackContent] = useState<StackItem[]>([]);

  const [isFetching, setIsFetching] = useState(false);
  const [isDebugging, setIsDebugging] = useState(false);

  const [runError, setRunError] = useState<string | undefined>();
  const [debugError, setDebugError] = useState<string | undefined>();

  const MAX_SIZE = 350000; // Max script size is 10000 bytes, longest named opcode is ~25 chars, so 25 * 10000 = 250000 + extra allowance

  const runScript = async (url: string, setIsLoading: Dispatch<SetStateAction<boolean>>, setError: Dispatch<SetStateAction<string | undefined>>) => {
    if (scriptPubKey.length > MAX_SIZE) {
      setError("Script Public Key exceeds maximum allowed size");
      return;
    }
    if (scriptSig.length > MAX_SIZE) {
      setError("Script Signature exceeds maximum allowed size");
      return;
    }

    const stack: StackItem[] = [];
    setIsLoading(true);
    setError(undefined);
    try {
      let backendUrl = process.env.NEXT_PUBLIC_BACKEND_URL;
      const response = await fetch(`${backendUrl}/${url}`, {
        method: "POST",
        headers: { 'Content-Type': 'application/json' },
        mode: 'cors',
        body: JSON.stringify({ pub_key: scriptPubKey, sig: scriptSig })
      });
      const result = await response.json();
      JSON.parse(result.message).reverse().map((item: string, _: number) => {
        stack.push({ value: item });
      })
      setStackContent(stack);
    } catch (err: any) {
      setError(err.message || "An error occurred");
    } finally {
      setIsLoading(false);
    }
  };

  const handleRunScript = () => runScript("run-script", setIsFetching, setRunError);
  const handleDebugScript = () => runScript("debug-script", setIsDebugging, setDebugError);

  const [split, setSplit] = useState(false);

  const setEditorTheme = (monaco: any) => {
    monaco.editor.defineTheme("darker", {
      base: "hc-black",
      inherit: true,
      rules: [],
      colors: {
        "editor.selectionBackground": "#A5FFC240",
        "editorLineNumber.foreground": "#258F42",
        "editorLineNumber.activeForeground": "#A5FFC2",
        focusBorder: "#00000000",
        "scrollbar.shadow": "#00000000",
        "scrollbarSlider.background": "#258F4240",
        "scrollbarSlider.activeBackground": "#258F4260",
        "scrollbarSlider.hoverBackground": "#258F4245",
      },
    });
    monaco.editor.remeasureFonts();
  };

  const renderEditor = (value: string, onChange: Dispatch<SetStateAction<string>>, height: string) => (
    <div
      className={clsx(
        height,
        "w-full border-8 border-[#232523AE] bg-black overflow-y",
      )}
    >
      <Editor
        beforeMount={setEditorTheme}
        theme="darker"
        defaultLanguage="plaintext"
        value={value || ""}
        onChange={(newValue) => onChange(newValue || "")}
        options={{
          fontFamily: `${jura.style.fontFamily}, sans-serif`,
          fontSize: 16,
          lineHeight: 24,
          renderLineHighlight: "none",
        }}
      />
    </div>
  );

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
      </div>{
        !split && renderEditor(scriptPubKey, setScriptPubKey, "rounded-b-xl h-[400px] rounded-tr-xl")}
      {split && (
        <>
          {renderEditor(scriptSig, setScriptSig, "border-b-4 h-[160px] rounded-tr-xl")}
          {renderEditor(scriptPubKey, setScriptPubKey, "border-t-4 rounded-t-0 h-[240px] rounded-b-xl")}
        </>
      )}
      <div className="w-full flex flex-col space-y-3.5 sm:space-y-0 sm:flex-row sm:items-center sm:justify-between mb-10">
        <div className="mt-5 flex flex-col space-y-3.5 sm:space-y-0 sm:flex-row sm:items-center sm:space-x-3.5">
          <button
            className="bg-[#00FF5E] uppercase text-black px-6 py-3 rounded-[3px] opacity-50 shadow-[0px_4px_8px_2px_rgba(0,255,94,0.20)]"
            onClick={handleRunScript}
            disabled={isFetching}
          >
            {runError ? runError : isFetching ? "Running..." : "Run Script"}
          </button>
          <button className="bg-[rgba(0,255,94,0.10)] text-[#00FF5E] border border-[#00FF5E] border-opacity-50 px-3 py-3 rounded-[3px] opacity-50  uppercase"
            onClick={handleDebugScript}
            disabled={isDebugging}>
            {debugError ? debugError : isDebugging ? "Debugging..." : "Debug Script"}
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
