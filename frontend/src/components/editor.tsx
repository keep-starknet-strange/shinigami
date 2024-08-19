"use client"

import Editor from '@monaco-editor/react';

export default function CodeEditor() {
    return (
        <Editor height={310} defaultLanguage="javascript" theme="vs-dark" />
    )
}