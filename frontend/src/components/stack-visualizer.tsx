export default function StackVisualizer() {
  return (
    <div className="w-full bg-[#0E0E0E] h-fit rounded-lg rounded-b-xl pt-0.5">
      <div className="w-full flex flex-row items-center justify-between pr-1.5">
        <div className="w-44 h-12 bg-[#0E0E0E] clip-trapezium-right flex flex-col items-start justify-center pl-2.5 pt-1.5 rounded-t-xl">
          <p className="text-[#85FFB2]">Stack Visualizer</p>
        </div>
        <div className="w-48 h-12 bg-[#0E0E0E] clip-trapezium-left flex flex-col items-start justify-center px-1.5 pt-1.5 rounded-t-xl">
          <button className="w-full h-full text-center bg-[#00FF5E] clip-trapezium-inner-left rounded-r-sm rounded-bl-sm text-black uppercase">
            Generate Proof
          </button>
        </div>
      </div>
      <div className="w-full border-8 border-[#0E0E0E] h-fit">
        <div className="py-2.5 rounded-t-lg flex flex-row space-x-5 px-3.5 w-full bg-black">
          <span>ID</span>
          <span>Value</span>
        </div>
        <div className="w-full h-[1px] bg-[#2B2B2B]" />
        <div className="w-full bg-black h-40 rounded-b-lg" />
        <div className="w-full bg-black h-48 rounded-t-lg rounded-b-lg mt-2.5">
          <div className="py-2.5 rounded-t-lg rounded-b-lg flex flex-row space-x-5 px-3.5 w-full bg-black">
            <span>Proof of Status:</span>
          </div>
          <div className="w-full h-[1px] bg-[#2B2B2B]" />
          <div className="w-full px-2.5 pt-1 h-40">
            <p className="text-[#959595] text-sm">Ready to generate...</p>
          </div>
        </div>
      </div>
    </div>
  );
}
