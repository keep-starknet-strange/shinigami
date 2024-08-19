import Split from "@/components/split";
import CodeEditor from "@/components/editor";
import RefreshIcon from "@/components/refresh-icon";

export default function ScriptEditor() {
  return (
    <div className="w-full">
      <div className="w-full flex flex-row items-center justify-between">
        <div className="w-36 h-10 bg-[#0E0E0E] clip-trapezium-right flex flex-col items-start justify-center pl-2.5 pt-1.5 rounded-t-xl">
          <p className="text-[#85FFB2] text-lg">Script Editor</p>
        </div>
        <button className="flex flex-row items-center space-x-1">
          <Split />
          <p className="text-white">SPLIT EDITOR</p>
        </button>
      </div>
      <div className="w-full border-8 border-[#0E0E0E] h-80 bg-black overflow-y-scroll rounded-b-xl rounded-tr-xl">
        <CodeEditor />
      </div>
      <div className="w-full flex flex-col space-y-3.5 sm:space-y-0 sm:flex-row sm:items-center sm:justify-between">
        <div className="mt-5 flex flex-col space-y-3.5 sm:space-y-0 sm:flex-row sm:items-center sm:space-x-3.5">
          <button className="bg-[#00FF5E] text-black px-6 py-3 rounded-[3px] opacity-50 shadow-[0px_4px_8px_2px_rgba(0,255,94,0.20)]">
            RUN SCRIPT
          </button>
          <button className="bg-[rgba(0,255,94,0.10)] text-[#00FF5E] border border-[#00FF5E] border-opacity-50 px-3 py-3 rounded-[3px] opacity-50">
            DEBUG SCRIPT
          </button>
        </div>
        <button className="flex flex-row items-center justify-center space-x-1.5">
          <RefreshIcon />
          <p className="text-white">REFRESH</p>
        </button>
      </div>
    </div>
  );
}
