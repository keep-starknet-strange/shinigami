"use client";

import React from "react";

interface StackItem {
  id: number;
  value: string;
}

interface StackVisualizerProps {
  stackContent: StackItem[];
}

const StackVisualizer: React.FC<StackVisualizerProps> = ({ stackContent }) => {
  return (
    <div className="h-64 overflow-y-auto retro-container p-2">
      <table className="w-full">
        <thead>
          <tr>
            <th className="text-left">ID</th>
            <th className="text-left">Value</th>
          </tr>
        </thead>
        <tbody>
          {stackContent.map((item) => (
            <tr key={item.id} className="border-t border-green-500">
              <td className="py-2">{item.id}</td>
              <td className="py-2">{item.value}</td>
            </tr>
          ))}
        </tbody>
      </table>
    </div>
  );
};

export default StackVisualizer;
