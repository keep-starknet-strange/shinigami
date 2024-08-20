import type { Metadata } from "next";
import { Jura } from "next/font/google";
import "./globals.css";
import Image from "next/image";
import Link from "next/link";
import logo from "../../public/logo.png";
import githubImage from "@/images/github.svg";

const jura = Jura({ subsets: ["latin"] });

export const metadata: Metadata = {
  title: "Shinigami Bitcoin Script IDE",
  description: "Bitcoin Script IDE powered by Shinigami",
};

const Header = () => (
  <div className="w-full max-w-4xl flex flex-row items-center justify-between">
    <Link href="/">
      <div className="flex flex-row items-center justify-center space-x-0.5">
        <Image src={logo} width={25} height={25} alt="Shinigami" />
        <h6 className="uppercase">Shinigami Script Wizard</h6>
      </div>
    </Link>
    <div className="flex flex-row items-center space-x-5">
      <h6 className="uppercase">About</h6>
      <Link
        href="https://github.com/keep-starknet-strange/shinigami"
        target="_blank"
      >
        <div className="flex flex-row items-center space-x-1">
          <Image src={githubImage} alt="" unoptimized />
          <h6 className="text-[#00FF5E] uppercase">Github</h6>
        </div>
      </Link>
    </div>
  </div>
);

const Footer = () => (
  <div className="flex flex-row items-center justify-center pt-5 pb-8">
    <p className="text-white text-lg uppercase">
      Shinigami Script Wizard. V.10
    </p>
  </div>
);

const commonClasses = "w-full min-h-screen";

export default function RootLayout({
  children,
}: Readonly<{
  children: React.ReactNode;
}>) {
  return (
    <html lang="en">
      <body className={jura.className}>
        <main
          className={`
            ${commonClasses}
            bg-black bg-contain bg-top bg-no-repeat
            bg-[url('/stars.png')]
          `}
        >
          <div
            className={`
              ${commonClasses}
              bg-[url('/background.png')] bg-cover bg-no-repeat bg-center
            `}
          >
            <div
              className={`
                ${commonClasses}
                bg-black bg-contain bg-top bg-no-repeat
                bg-[url('/grid-lines.png')] bg-opacity-5
              `}
            >
              <div
                className={`
                  ${commonClasses}
                  flex flex-col justify-start items-center
                  pt-10 px-5 space-y-14
                `}
              >
                <Header />
                {children}
                <Footer />
              </div>
            </div>
          </div>
        </main>
      </body>
    </html>
  );
}
