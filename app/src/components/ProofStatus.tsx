import React from "react";

interface ProofStatusProps {
  isGenerating: boolean;
}

const ProofStatus: React.FC<ProofStatusProps> = ({ isGenerating }) => {
  return (
    <div className="mt-4 retro-container p-2">
      <h3 className="text-lg mb-2">PROOF STATUS:</h3>
      {isGenerating ? (
        <p className="text-yellow-400 blink">GENERATING PROOF...</p>
      ) : (
        <p className="text-green-400">READY TO GENERATE</p>
      )}
    </div>
  );
};

export default ProofStatus;
