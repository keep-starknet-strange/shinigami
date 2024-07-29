"use client";

import React from "react";
import {
  BarChart,
  Bar,
  XAxis,
  YAxis,
  Tooltip,
  ResponsiveContainer,
} from "recharts";

interface StackItem {
  id: number;
  value: string;
}

interface StackVisualizerProps {
  stackContent: StackItem[];
}

const StackVisualizer: React.FC<StackVisualizerProps> = ({ stackContent }) => {
  const chartData = stackContent.map((item) => ({
    name: `Item ${item.id}`,
    value: item.value.length,
  }));

  return (
    <div className="h-80">
      <ResponsiveContainer width="100%" height="100%">
        <BarChart data={chartData}>
          <XAxis dataKey="name" />
          <YAxis />
          <Tooltip />
          <Bar dataKey="value" fill="#8884d8" />
        </BarChart>
      </ResponsiveContainer>
      <div className="mt-4">
        <h3 className="text-xl font-semibold mb-2">Stack Contents:</h3>
        <ul className="list-disc pl-5">
          {stackContent.map((item) => (
            <li key={item.id}>{item.value}</li>
          ))}
        </ul>
      </div>
    </div>
  );
};

export default StackVisualizer;
