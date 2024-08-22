interface StackItem {
  id: number;
  value: string;
}

interface StackVisualizerProps {
  stackContent: StackItem[];
}

export default function StackVisualizer({
  stackContent,
}: StackVisualizerProps) {
  return (
    <div className="w-full bg-[#000000] h-fit rounded-lg rounded-b-xl pt-0.5">
      <div className="w-full flex flex-row items-center justify-between pr-1.5">
        <div className="w-44 h-12 bg-[#232523AE] clip-trapezium-right flex flex-col items-start justify-center pl-2.5 pt-1.5 rounded-t-xl">
          <p className="text-[#85FFB2]">Stack Visualizer</p>
        </div>
        <div className="w-56 h-12 bg-[#232523AE] clip-trapezium-left flex flex-col items-start justify-center px-1.5 pt-1.5 rounded-t-xl">
          <button className="w-full h-full text-center bg-[#00FF5E] clip-trapezium-inner-left rounded-r-sm rounded-bl-sm text-black uppercase ml-3.5 sm:ml-0">
            Generate Proof
          </button>
        </div>
      </div>
      <div className="w-full border-8 border-[#232523AE] h-fit rounded-b-xl">
        <table className="w-full bg-black table-fixed">
          <thead>
            <tr className="border-b border-[#2B2B2B]">
              <th className="py-2.5 pl-3.5 pr-1 text-left w-16">ID</th>
              <th className="py-2.5 pl-1 text-left">Value</th>
            </tr>
          </thead>
          <tbody className="h-40">
            {stackContent.map((item) => (
              <tr key={item.id} className="border-t border-[#2B2B2B]">
                <td className="py-2 pl-3.5 pr-1 w-16 truncate">{item.id}</td>
                <td className="py-2 pl-1">{item.value}</td>
              </tr>
            ))}
          </tbody>
        </table>

        <div className="w-full bg-black h-48 rounded-t-lg rounded-b-xl mt-2.5">
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
