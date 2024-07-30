import { languages } from "monaco-editor";

export const bitcoinScriptLanguage: languages.IMonarchLanguage = {
  tokenizer: {
    root: [
      [/OP_[A-Z0-9]+/, "keyword"],
      [/<[^>]+>/, "string"],
      [/[0-9]+/, "number"],
      [/[a-zA-Z_]\w*/, "identifier"],
    ],
  },
};

export function registerBitcoinScriptLanguage(monaco: any) {
  monaco.languages.register({ id: "bitcoin-script" });
  monaco.languages.setMonarchTokensProvider(
    "bitcoin-script",
    bitcoinScriptLanguage,
  );
}
