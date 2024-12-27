"use client";

import { Jura } from "next/font/google";
import StackVisualizer from "@/components/stack-visualizer";
import { Editor } from "@monaco-editor/react";
import Image from "next/image";

import splitImage from "@/images/split.svg";
import unsplitImage from "@/images/unsplit.svg";
import next from "@/images/next.svg";
import previous from "@/images/previous.svg";
import stop from "@/images/stop.svg";
import clsx from "@/utils/lib";
import { Dispatch, SetStateAction, useEffect, useState } from "react";
import { StackItem } from "../../types";
import { bitcoinScriptLanguage, bitcoinScriptOpcodes } from "@/utils/bitcoin-script";
import { backendRun, backendDebug, InputData } from "@/utils/shinigami";

const jura = Jura({ subsets: ["latin"] });

export default function ScriptEditor() {
  const [scriptSig, setScriptSig] = useState("// Script Sig\nOP_1 OP_3 OP_2 OP_SUB OP_EQUALVERIFY")
  const [scriptPubKey, setScriptPubKey] = useState("// Script Pub Key\nOP_1 OP_2 OP_ADD OP_3 OP_EQUAL\nOP_HASH160 OP_HASH160\nOP_DATA_20 0xb157bee96d62f6855392b9920385a834c3113d9a\nOP_EQUAL");

  const [stackContent, setStackContent] = useState<StackItem[]>([]);
  const [debuggingContent, setDebuggingContent] = useState<StackItem[][]>([]);

  const [isFetching, setIsFetching] = useState(false);
  const [isDebugFetch, setDebugFetch] = useState(false);
  const [isDebugging, setIsDebugging] = useState(false);

  const [runError, setRunError] = useState<string | undefined>();
  const [debugError, setDebugError] = useState<string | undefined>();

  const [hasFetchedDebugData, setHasFetchedDebugData] = useState(false);

  const [step, setStep] = useState(-1);

  const MAX_SIZE = 350000; // Max script size is 10000 bytes, longest named opcode is ~25 chars, so 25 * 10000 = 250000 + extra allowance

  const runScript = async (runType: string, setIsLoading: Dispatch<SetStateAction<boolean>>, setError: Dispatch<SetStateAction<string | undefined>>) => {
    // Filter out comments staring with // and Convert double quotes to single quotes
    const pubKey = scriptPubKey.replace(/\/\/.*/g, "").split("\n").join(" ").replace(/\"(.*?)\"/g, "'$1'");
    let sig = scriptSig.replace(/\/\/.*/g, "").split("\n").join(" ").replace(/\"(.*?)\"/g, "'$1'");
    if (!split) {
        sig = "";
    }

    if (pubKey.length > MAX_SIZE) {
      setError("Script Public Key exceeds maximum allowed size");
      return;
    }
    if (sig.length > MAX_SIZE) {
      setError("Script Signature exceeds maximum allowed size");
      return;
    }

    setIsLoading(true);
    setError(undefined);
    try {
        const input: InputData = {
            ScriptSig: sig,
            ScriptPubKey: pubKey
        };
        
        if (runType === "run-script") {
            const result = backendRun(input);
            setStackContent([{ value: result === 1 ? "1" : "0" }]);
        }
        else if (runType === "debug-script") {
            const debugStates = backendDebug(input);
            
            // Parse the debug states and convert to StackItem arrays
            const debuggingContent: StackItem[][] = debugStates.map((state: string) => {
                const stackArray = JSON.parse(state);
                return stackArray.map((item: string) => ({ value: item }));
            });

            setDebuggingContent(debuggingContent);  // Set debugging content first
            setStackContent(debuggingContent[0]);   // Set initial stack content
            setStep(0);                             // Set initial step
            setHasFetchedDebugData(true);
            setIsDebugging(true);

            console.log('debuggingContent: ', debuggingContent);
        }
    } catch (err: any) {
        setError(err.message || "An error occurred");
    } finally {
        setIsLoading(false);
    }
  };

  const handleRunScript = () => {
    runScript("run-script", setIsFetching, setRunError);
    handleEditorDecorations();
  };

  const handleDebugScript = () => {
    runScript("debug-script", setDebugFetch, setDebugError);
    handleEditorDecorations();
  };

  const [split, setSplit] = useState(false);
  const [monacoOne, setMonacoOne] = useState<any>();
  const [monacoTwo, setMonacoTwo] = useState<any>();
  const [monacoSetup, setMonacoSetup] = useState(false);

  const setEditorTheme = (monaco: any, setMonaco: Dispatch<SetStateAction<string>>) => {
    if (monacoSetup) return;
    setMonacoSetup(true);
    setMonaco(monaco);

    // Register the custom language
    monaco.languages.register({ id: "bitcoin-script" });
    monaco.languages.setMonarchTokensProvider(
      "bitcoin-script",
      bitcoinScriptLanguage,
    );

    monaco.languages.registerCompletionItemProvider("bitcoin-script", {
      provideCompletionItems: (model: any, position: any) => {
        const suggestions = bitcoinScriptOpcodes.map(opcodes => ({
          label: opcodes,
          kind: monaco.languages.CompletionItemKind.Keyword,
          insertText: opcodes,
          documentation: opcodes.description
        }));

        return { suggestions };
      }
    });

    // Define the custom theme
    monaco.editor.defineTheme("darker", {
      base: "hc-black",
      inherit: true,
      rules: [
        { token: 'keyword', foreground: 'FAFEFA' },
        { token: 'string', foreground: 'F7A95E' },
        { token: 'number', foreground: '3A998F' },
        { token: 'special-keyword', foreground: 'CB4D8D' },
        { token: 'comment', foreground: '4F72D0' },
        { token: 'error', foreground: 'FF2B2B', fontStyle: 'underline' },
      ],
      colors: {
        "editor.selectionBackground": "#A5FFC240",
        "editorLineNumber.foreground": "#258F42",
        "editorLineNumber.activeForeground": "#A5FFC2",
        "editorSuggestWidget.background": "#002000D0",
        "editorSuggestWidget.border": "#005000D0",
        "editorSuggestWidget.foreground": "#F0F0F0",
        "editorSuggestWidget.selectedBackground": "#25CF4240",
        "editorSuggestWidget.highlightForeground": "#F0F0F0",
        "focusBorder": "#002000D0",
        "scrollbar.shadow": "#00000000",
        "scrollbarSlider.background": "#258F4240",
        "scrollbarSlider.activeBackground": "#258F4260",
        "scrollbarSlider.hoverBackground": "#258F4245",
      },
    });

    monaco.editor.remeasureFonts();
  };

  const [currentDecorationsOne, setCurrentDecorationsOne] = useState<string[]>([]);
  const [currentDecorationsTwo, setCurrentDecorationsTwo] = useState<string[]>([]);

  // Move this outside the useEffect to prevent recreation on every render
  const handleEditorDecorations = () => {
    const sigWords = scriptSig.trim() === "" ? [] : scriptSig.split(/\s+/);
    const pubKeyWords = scriptPubKey.split(/\s+/);
    const totalSigWords = sigWords.length;
    const totalPubKeyWords = pubKeyWords.length;
    const combinedLength = totalSigWords + totalPubKeyWords;

    if (split) {
      if (monacoOne) {
        const editor_one = monacoOne.editor.getModels()[0];
        if (editor_one) {
          const newDecorations = updateEditorDecorations(
            editor_one,
            currentDecorationsOne,
            scriptSig,
            sigWords,
            step,
            0
          );
          setCurrentDecorationsOne(newDecorations);
        }
      }

      if (monacoTwo) {
        const editor_two = monacoTwo.editor.getModels()[1];
        if (editor_two) {
          const newDecorations = updateEditorDecorations(
            editor_two,
            currentDecorationsTwo,
            scriptPubKey,
            pubKeyWords,
            step,
            totalSigWords
          );
          setCurrentDecorationsTwo(newDecorations);
        }
      }
    } else {
      if (monacoTwo) {
        const editor_two = monacoTwo.editor.getModels()[0];
        if (editor_two) {
          editor_two.deltaDecorations(currentDecorationsTwo, []);
          if (step >= 0 && step < combinedLength) {
            const isInSig = step < totalSigWords;
            const script = isInSig ? scriptSig : scriptPubKey;
            const words = script.split(/\s+/);
            const wordToHighlight = words[isInSig ? step : step - totalSigWords];
            const { startLine, startColumn, endLine, endColumn } = findWordPosition(
              script,
              wordToHighlight,
              isInSig ? step : step - totalSigWords
            );
            const newDecorations = editor_two.deltaDecorations(currentDecorationsTwo, [{
              range: {
                startLineNumber: startLine,
                startColumn: startColumn,
                endLineNumber: endLine,
                endColumn: endColumn
              },
              options: {
                isWholeLine: false,
                inlineClassName: 'custom-highlight'
              }
            }]);
            setCurrentDecorationsTwo(newDecorations);
          }
        }
      }
    }
  };

  // Helper function to update editor decorations
  const updateEditorDecorations = (editor: any, currentDecorations: string[], script: string, words: string[], step: number, offset: number) => {
    editor.deltaDecorations(currentDecorations, []);
    if (step >= offset && step < words.length + offset) {
      const wordToHighlight = words[step - offset];
      const { startLine, startColumn, endLine, endColumn } = findWordPosition(
        script,
        wordToHighlight,
        step - offset
      );
      return editor.deltaDecorations(currentDecorations, [{
        range: {
          startLineNumber: startLine,
          startColumn: startColumn,
          endLineNumber: endLine,
          endColumn: endColumn
        },
        options: {
          isWholeLine: false,
          inlineClassName: 'custom-highlight'
        }
      }]);
    }
    return [];
  };

  // Helper function to find word position in a script
  const findWordPosition = (script: string, wordToHighlight: string, step: number) => {
    // This function calculates the start and end positions manually, accounting for new lines
    let matchIndexToUse = 0;
    const words = script.split(/\s+/);
    const occurrencesSoFar = words.slice(0, step + 1).filter(word => word === wordToHighlight).length;
    matchIndexToUse = occurrencesSoFar - 1;

    let charIndex = 0;
    let occurrenceCount = 0;
    let startLine = 1;
    let startColumn = 1;
    let start = 0;
    let end = 0;

    for (let i = 0; i < script.length; i++) {
      if (script[i] === '\n') {
        startLine++;
        startColumn = 1;
        continue;
      }

      if (script.slice(i, i + wordToHighlight.length) === wordToHighlight) {
        if (occurrenceCount === matchIndexToUse) {
          start = i;
          end = i + wordToHighlight.length;
          break;
        }
        occurrenceCount++;
      }
      startColumn++;
      charIndex++;
    }

    // Calculate line and column for the end position
    let endLine = startLine;
    let endColumn = startColumn + (end - start);

    return { startLine, startColumn, endLine, endColumn };
  };

  const renderEditor = (value: string, onChange: Dispatch<SetStateAction<string>>, setMonaco: Dispatch<any>, height: string) => (
    <div
      className={clsx(
        height,
        "w-full border-8 border-[#232523AE] bg-black overflow-y",
      )}
    >
      <Editor
        beforeMount={(monaco) => setEditorTheme(monaco, setMonaco)}
        theme="darker"
        defaultLanguage="bitcoin-script"
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
    <div className="w-full h-full">
      <div className="flex flex-col space-y-0 md:space-y-0 md:flex-row items-start md:space-x-5 w-full">
        <div className="w-full md:w-[65%]">
          <div className="w-full flex flex-row items-center justify-between">
            <div className="w-40 h-10 bg-[#232523AE] clip-trapezium-right flex flex-col items-start justify-center pl-2.5 pt-1.5 rounded-t-xl">
              <p className="text-[#85FFB2] text-lg">Script Editor</p>
            </div>
            <button
              className="flex flex-row items-center space-x-1"
              onClick={() => {
                setStep(-1);
                setSplit(!split);
                handleEditorDecorations();
              }}
            >
              <Image src={split ? unsplitImage : splitImage} alt="" unoptimized />
              <p className="text-white uppercase">
                {split ? "Unsplit" : "Split"} Editor
              </p>
            </button>
          </div>
          {
            !split && renderEditor(scriptPubKey, setScriptPubKey, setMonacoTwo, "rounded-b-xl h-[400px] rounded-tr-xl")
          }
          {
            split && (
              <>
                {renderEditor(scriptSig, setScriptSig, setMonacoOne, "border-b-4 h-[160px] rounded-tr-xl")}
                {renderEditor(scriptPubKey, setScriptPubKey, setMonacoTwo, "border-t-4 rounded-t-0 h-[240px] rounded-b-xl")}
              </>
            )
          }
          <div className="w-full flex flex-col space-y-3.5 sm:space-y-0 sm:flex-row sm:items-center sm:justify-between mb-10">
            <div className="mt-5 space-y-0 flex flex-row items-center space-x-3.5">
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
                {debugError ? debugError : isDebugFetch ? "Loading..." : isDebugging ? "Debugging..." : "Debug Script"}
              </button>
              {
                (isDebugging || hasFetchedDebugData) && !isFetching && (
                  <div className="flex flex-row space-x-3.5">
                    {
                      <button className={`block ${step <= 0 ? "opacity-50" : ""}`} disabled={step <= 0} onClick={() => {
                        let newStep = Math.max(step - 1, 0);
                        setStep(newStep);
                        setStackContent(debuggingContent[newStep]);
                        handleEditorDecorations();
                      }}>
                        <Image src={previous} alt="" unoptimized />
                      </button>
                    }
                    <button className={`block ${step >= debuggingContent.length - 1 ? "opacity-50" : ""}`} disabled={step >= debuggingContent.length - 1} onClick={() => {
                      let newStep = Math.min(step + 1, debuggingContent.length - 1);
                      setStep(newStep);
                      setStackContent(debuggingContent[newStep]);
                      handleEditorDecorations();
                    }}>
                      <Image src={next} alt="" unoptimized />
                    </button>
                    <button className="block" onClick={() => {
                      setStep(-1);
                      setStackContent([]);
                      setHasFetchedDebugData(false);
                      setDebuggingContent([]);
                      setIsDebugging(false);
                    }}>
                      <Image src={stop} alt="" unoptimized />
                    </button>
                  </div>
                )
              }
            </div>
          </div>
        </div>
        <StackVisualizer stackContent={stackContent} />
      </div>
    </div >
  );
}
