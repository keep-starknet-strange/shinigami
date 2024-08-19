"use client";

import Editor from "@monaco-editor/react";

export default function CodeEditor() {
  return <Editor height={310} defaultLanguage="rust" theme="vs-dark" />;
}
