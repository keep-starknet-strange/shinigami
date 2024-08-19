import Image from "next/image";
import logo from "../../public/logo.png";
import Link from "next/link";
import Github from "@/components/github";
import Split from "@/components/split";
import CodeEditor from "@/components/editor";
import RefreshIcon from "@/components/refresh-icon";

export default function Home() {
  return (
    <main className="w-full min-h-screen bg-black bg-contain bg-top bg-no-repeat bg-[url('/stars.png')]">
      <div className="w-full min-h-screen bg-[url('/background.png')] bg-cover bg-no-repeat bg-center">
        <div className="w-full min-h-screen bg-black bg-contain bg-top bg-no-repeat bg-[url('/grid-lines.png')] bg-opacity-5">
          <div className="w-full min-h-screen flex flex-col justify-start items-center pt-10 px-5 space-y-14">
            <div className="w-full max-w-4xl flex flex-row items-center justify-between">
              <Link href={"/"}>
                <div className="flex flex-row items-center justify-center space-x-0.5">
                  <Image src={logo} width={25} height={25} alt="Shinigami" />
                  <h6>SHINIGAMI</h6>
                </div>
              </Link>
              <div className="flex flex-row items-center space-x-5">
                <h6>ABOUT</h6>
                <Link href={"/"}>
                  <div className="flex flex-row items-center space-x-1">
                    <Github />
                    <h6 className="text-[#00FF5E]">GITHUB</h6>
                  </div>
                </Link>
              </div>
            </div>
            <div className="flex flex-row items-center justify-center w-full">
              <div className="w-full max-w-4xl flex flex-col items-center justify-between space-y-5">
                {/* Script editor */}
                <div className="w-full">
                  <div className="w-full flex flex-row items-center justify-between">
                    <div className="w-36 h-10 bg-[#0E0E0E] clip-trapezium-right flex flex-col items-start justify-center pl-2.5 pt-1.5 rounded-t-xl">
                      <p className="text-[#85FFB2]">Script Editor</p>
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
                      <button className="bg-[#00FF5E] text-black px-7 py-4 rounded-md">RUN SCRIPT</button>
                      <button className="bg-transparent text-[#00FF5E] border border-[#00FF5E] px-5 py-3.5 rounded-md">DEBUG SCRIPT</button>
                    </div>
                    <button className="flex flex-row items-center justify-center space-x-1.5">
                      <RefreshIcon />
                      <p className="text-white">REFRESH</p>
                    </button>
                  </div>
                </div>
                {/* Stack Visualizer */}
                <div className="w-full bg-[#0E0E0E] h-fit rounded-lg rounded-b-xl pt-0.5">
                  <div className="w-full flex flex-row items-center justify-between pr-1.5">
                    <div className="w-44 h-12 bg-[#0E0E0E] clip-trapezium-right flex flex-col items-start justify-center pl-2.5 pt-1.5 rounded-t-xl">
                      <p className="text-[#85FFB2]">Stack Visualizer</p>
                    </div>
                    <div className="w-48 h-12 bg-[#0E0E0E] clip-trapezium-left flex flex-col items-start justify-center px-1.5 pt-1.5 rounded-t-xl">
                      <button className="w-full h-full text-right pr-2.5 bg-[#00FF5E] clip-trapezium-inner-left rounded-r-sm rounded-bl-sm text-black">GENERATE PROOF</button>
                    </div>
                  </div>
                  <div className="w-full border-8 border-[#0E0E0E] h-fit">
                    <div className="py-2.5 rounded-t-lg flex flex-row space-x-5 px-3.5 w-full bg-black">
                      <span>ID</span>
                      <span>Value</span>
                    </div>
                    <div className="w-full h-[1px] bg-[#2B2B2B]" />
                    {/* render data in this div */}
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
                {/* Footer */}
                <div className="flex flex-row items-center justify-center pt-5 pb-8">
                  <p className="text-white text-lg">SHINIGAMI SCRIPT WIZARD. V.10</p>
                </div>
              </div>
            </div>
          </div>
        </div>
      </div>
    </main>
  );
}
