import type { Metadata } from "next";
import { Jura } from "next/font/google";
import "./globals.css";
import Image from "next/image";
import Link from "next/link";
import logo from "../../public/logo.png";
import githubImage from "@/images/github.svg";
import menu from "@/images/menu.svg";
import React from "react";

const jura = Jura({ subsets: ["latin"] });

export const metadata: Metadata = {
  title: "Shinigami Bitcoin Script IDE",
  description: "Bitcoin Script IDE powered by Shinigami",
};

const Header = () => (
  <div className="w-full h-24 border-y border-white/10 flex flex-col justify-center sm:h-fit sm:border-y-0 sm:flex-row">
    <div className="w-full max-w-4xl flex flex-row items-center justify-between border border-white/10 px-3.5 rounded-3xl sm:rounded-none sm:border-0">
      <Link href="/">
        <div className="flex flex-row items-center justify-center space-x-0.5">
          <Image src={logo} width={25} height={25} alt="Shinigami" />
          <h6 className="uppercase text-white">Shinigami Script Wizard</h6>
        </div>
      </Link>
      <button className="block sm:hidden py-2.5">
        <Image src={menu} alt="menu" />
      </button>
      <div className="sm:flex flex-row items-center space-x-5 hidden">
        <h6 className="uppercase text-white">About</h6>
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
                  pt-10 px-5 space-y-10
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
