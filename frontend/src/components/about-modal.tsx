import { Dialog } from "@material-tailwind/react";
import Image from "next/image";
import Link from "next/link";
import { FC } from "react";

import cancelCircle from "@/images/cancel-circle.svg";
import githubImage from "@/images/github.svg";
import telegram from "@/images/telegram.svg";

interface AboutModalProps {
  isOpen: boolean;
  onClose: () => void;
}

export const AboutModal: FC<AboutModalProps> = ({ isOpen, onClose }) => (
  <Dialog
    open={isOpen}
    handler={onClose}
    className="bg-black w-full"
    nonce={undefined}
    onResize={() => { }}
    onResizeCapture={() => { }} placeholder={undefined} onPointerEnterCapture={undefined} onPointerLeaveCapture={undefined}>
    <button
      className="p-1.5 border-2 border-[#00FF5E] rounded-md absolute right-0 bg-[#00FF5E]/10 z-20"
      onClick={onClose}
    >
      <Image src={cancelCircle} alt="close" className="z-18" />
      <div className="w-3.5 h-3.5 bg-black absolute top-3.5 left-3.5 -z-10" />
    </button>
    <div className="flex flex-col items-start gap-6 p-4 bg-[#080808] w-full">
      <div className="w-full h-28 bg-[url('/banner.png')] bg-cover bg-no-repeat bg-center" />
      <div className="font-medium">
        <p className="text-white mb-4">
          Shinigami is a Bitcoin Script library for generic Script VM execution in Cairo,
          enabling the generation of STARK proofs for Bitcoin Script computation and
          Bitcoin transaction execution.
        </p>
        <ul className="list-disc text-white ml-4">
          <li>Bitcoin Script interpretation and execution</li>
          <li>Frontend Script IDE with STARK prover integration</li>
          <li>Transaction execution and proving</li>
          <li>Easily configurable VM (enable different opcodes)</li>
          <li>In cairo, Bitcoin Script compiler</li>
        </ul>
      </div>
      <div className="flex flex-row items-center space-x-2.5">
        <Link
          href="https://github.com/keep-starknet-strange/shinigami"
          target="_blank"
        >
          <button className="flex justify-center items-center gap-2 bg-[#00FF5E]/10 border border-[#00FF5E] rounded px-6 py-3">
            <Image src={githubImage} alt="" unoptimized />
            <h6 className="text-[#00FF5E] uppercase text-base">Github</h6>
          </button>
        </Link>
        <Link href="https://t.me/ShinigamiStarknet" target="_blank">
          <button className="flex justify-center items-center gap-2 bg-[#00FF5E]/10 border border-[#00FF5E] rounded px-6 py-3">
            <Image src={telegram} alt="" unoptimized />
            <h6 className="text-[#00FF5E] uppercase text-base">Telegram</h6>
          </button>
        </Link>
      </div>
    </div>
  </Dialog>
);
