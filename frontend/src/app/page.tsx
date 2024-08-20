import ScriptEditor from "@/components/script-editor";
import StackVisualizer from "@/components/stack-visualizer";

export default function Home() {
  return (
    <div className="w-full max-w-4xl flex flex-col items-center justify-between space-y-5">
      <ScriptEditor />
      <StackVisualizer />
    </div>
  );
}
