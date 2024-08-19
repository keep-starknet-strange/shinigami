import Image from "next/image";
import logo from "../../public/logo.png";
import Link from "next/link";
import Github from "@/components/github";
import Split from "@/components/split";
import CodeEditor from "@/components/editor";

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
              <div className="w-full max-w-4xl flex flex-row items-center justify-between">
                <div className="w-full">
                  <div className="w-full flex flex-row items-center justify-between">
                    <div className="w-36 h-10 bg-[#0E0E0E] clip-trapezium flex flex-col items-start justify-center pl-2.5 pt-1.5 rounded-t-xl">
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
                  <div className="mt-5 flex flex-row items-center space-x-3.5">
                    <button className="bg-[#00FF5E] text-black px-7 py-4 rounded-md">RUN SCRIPT</button>
                    <button className="bg-transparent text-[#00FF5E] border border-[#00FF5E] px-5 py-3.5 rounded-md">DEBUG SCRIPT</button>
                  </div>
                </div>
              </div>
            </div>
          </div>
        </div>
      </div>
    </main>
  );
}
