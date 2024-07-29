import React from "react";

interface ProofStatusProps {
  isGenerating: boolean;
}

const ProofStatus: React.FC<ProofStatusProps> = ({ isGenerating }) => {
  return (
    <div className="mt-4">
      <h3 className="text-xl font-semibold mb-2">Proof Status:</h3>
      {isGenerating ? (
        <p className="text-yellow-600">Generating proof...</p>
      ) : (
        <p className="text-green-600">Ready to generate proof</p>
      )}
    </div>
  );
};

export default ProofStatus;
