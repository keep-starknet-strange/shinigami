import Image from "next/image";
import Link from "next/link";
import logo from "../../public/logo.png";
import Github from "@/components/github";
import ScriptEditor from "@/components/script-editor";
import StackVisualizer from "@/components/stack-visualizer";

const Header = () => (
  <div className="w-full max-w-4xl flex flex-row items-center justify-between">
    <Link href="/">
      <div className="flex flex-row items-center justify-center space-x-0.5">
        <Image src={logo} width={25} height={25} alt="Shinigami" />
        <h6>SHINIGAMI</h6>
      </div>
    </Link>
    <div className="flex flex-row items-center space-x-5">
      <h6>ABOUT</h6>
      <Link href="/">
        <div className="flex flex-row items-center space-x-1">
          <Github />
          <h6 className="text-[#00FF5E]">GITHUB</h6>
        </div>
      </Link>
    </div>
  </div>
);

const Footer = () => (
  <div className="flex flex-row items-center justify-center pt-5 pb-8">
    <p className="text-white text-lg">SHINIGAMI SCRIPT WIZARD. V.10</p>
  </div>
);

export default function Home() {
  return (
    <main className="w-full min-h-screen bg-black bg-contain bg-top bg-no-repeat bg-[url('/stars.png')]">
      <div className="w-full min-h-screen bg-[url('/background.png')] bg-cover bg-no-repeat bg-center">
        <div className="w-full min-h-screen bg-black bg-contain bg-top bg-no-repeat bg-[url('/grid-lines.png')] bg-opacity-5">
          <div className="w-full min-h-screen flex flex-col justify-start items-center pt-10 px-5 space-y-14">
            <Header />
            <div className="flex flex-row items-center justify-center w-full">
              <div className="w-full max-w-4xl flex flex-col items-center justify-between space-y-5">
                <ScriptEditor />
                <StackVisualizer />
                <Footer />
              </div>
            </div>
          </div>
        </div>
      </div>
    </main>
  );
}
