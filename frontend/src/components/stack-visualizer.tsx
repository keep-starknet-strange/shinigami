import { StackVisualizerProps } from "../../types";

export default function StackVisualizer({
  stackContent,
}: StackVisualizerProps) {
  return (
    <div className="w-full h-fit rounded-lg rounded-b-xl pt-0.5">
      <div className="w-full flex flex-row items-center justify-between">
        <div className="w-44 h-12 bg-[#232523AE] clip-trapezium-right flex flex-col items-start justify-center pl-2.5 pt-1.5 rounded-t-xl">
          <p className="text-[#85FFB2]">Stack Visualizer</p>
        </div>
        <div className="w-44 h-12 bg-[#232523AE] clip-trapezium-left flex flex-col items-start justify-center px-1.5 pt-1.5 rounded-t-xl">
          <button className="w-40 h-full text-center bg-[#00FF5E] clip-trapezium-inner-left rounded-r-sm rounded-bl-sm text-black uppercase">
            Generate Proof
          </button>
        </div>
      </div>
      <div className="w-full border-8 border-[#232523AE]/10 rounded-b-xl space-y-2.5 bg-[#232523AE] h-fit">
        <table className="w-full bg-black table-fixed rounded-b-xl rounded-t-xl min-h-20">
          <thead>
            <tr className="border-b border-[#2B2B2B]">
              <th className="py-2.5 pl-3 text-left text-white">Value</th>
            </tr>
          </thead>
          <tbody>
            {/* {stackContent.length === 0 ? (
              <tr>
                <td className="w-full h-12" colSpan={2} />
              </tr>
            ) : (
              stackContent.toReversed().map((item, idx) => (
                <tr key={idx} className="border-t border-[#2B2B2B] w-full">
                  <td className="py-3 pl-4 text-white">{item.value}</td>
                </tr>
              ))
            )} */}
          </tbody>
        </table>

        <div className="w-full bg-black h-48 rounded-t-lg rounded-b-xl mt-2.5">
          <div className="py-2.5 rounded-t-lg rounded-b-lg flex flex-row space-x-5 px-3.5 w-full bg-black">
            <span className="text-white">Proof of Status:</span>
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
