import ScriptEditor from "@/components/script-editor";

export default function Home() {
  return (
    <div className="w-full max-w-4xl flex flex-col items-center justify-between space-y-5">
      <ScriptEditor />
    </div>
  );
}
