"use client";

import { useState } from "react";

import { AboutModal } from "@/components/about-modal";
import Image from "next/image";
import Link from "next/link";
import { FC } from "react";

import githubImage from "@/images/github.svg";
import menu from "@/images/menu.svg";
import xCircle from "@/images/x-circle.svg";
import logo from "../../public/logo.png";
import clsx from "@/utils/lib";

interface MobileMenuProps {
  isOpen: boolean;
  onClose: () => void;
  onOpenModal: () => void;
}

const useModal = () => {
  const [isOpen, setIsOpen] = useState(false);
  const toggle = () => setIsOpen(!isOpen);
  return { isOpen, toggle };
};

const MobileMenu: FC<MobileMenuProps> = ({ isOpen, onClose, onOpenModal }) => {
  if (!isOpen) return null;

  return (
    <div className="w-full h-fit absolute top-8 z-20 inset-x-0 flex flex-row items-center rounded-xl sm:hidden">
      <div className="w-full mx-5 h-[185px] backdrop-blur-md rounded-xl border border-white/10">
        <div className="w-full max-w-4xl flex flex-row items-center justify-between border-b border-white/10 px-3.5 sm:border-0 py-2 sm:py-0">
          <Link href="/">
            <div className="flex flex-row items-center justify-center space-x-0.5">
              <Image src={logo} width={25} height={25} alt="Shinigami" />
              <h6 className="uppercase text-white">Shinigami Script Wizard</h6>
            </div>
          </Link>
          <button className="block sm:hidden py-2.5" onClick={onClose}>
            <Image src={xCircle} alt="menu" />
          </button>
        </div>
        <div className="py-2.5 px-2.5 space-y-2.5">
          <button
            className="text-white w-full text-center bg-[#111111] py-2.5 rounded-md uppercase"
            onClick={onOpenModal}
          >
            About
          </button>
          <button className="text-white w-full text-center bg-[#111111] py-2.5 rounded-md flex row items-center justify-center">
            <div className="flex flex-row items-center space-x-1">
              <Image src={githubImage} alt="" unoptimized />
              <h6 className="text-[#00FF5E] uppercase">Github</h6>
            </div>
          </button>
        </div>
      </div>
    </div>
  );
};

export default function Header() {
  const [isMobileMenuOpen, setIsMobileMenuOpen] = useState(false);
  const { isOpen: isModalOpen, toggle: toggleModal } = useModal();

  return (
    <div className="w-full h-24 border-y border-white/10 flex flex-col justify-center sm:h-fit sm:border-y-0 sm:flex-row">
      <div className={clsx(isMobileMenuOpen ? "hidden" : "", "w-full max-w-4xl flex flex-row items-center justify-between border border-white/10 px-3.5 rounded-3xl py-2.5")}>
        <Link href="/">
          <div className="flex flex-row items-center justify-center space-x-0.5">
            <Image src={logo} width={25} height={25} alt="Shinigami" />
            <h6 className="uppercase text-white pl-3">Shinigami Script Wizard</h6>
          </div>
        </Link>
        <button
          className="block sm:hidden py-2.5"
          onClick={() => setIsMobileMenuOpen(true)}
        >
          <Image src={menu} alt="menu" />
        </button>
        <div className="sm:flex flex-row items-center space-x-5 hidden">
          <button className="uppercase text-white" onClick={toggleModal}>
            About
          </button>
          <Link
            href="https://github.com/keep-starknet-strange/shinigami"
            target="_blank"
          >
            <div className="flex flex-row items-center space-x-1">
              <Image src={githubImage} alt="" unoptimized />
              <h6 className="text-#00FF5E uppercase">Github</h6>
            </div>
          </Link>
        </div>
      </div>
      <AboutModal isOpen={isModalOpen} onClose={toggleModal} />
      <MobileMenu
        isOpen={isMobileMenuOpen}
        onClose={() => setIsMobileMenuOpen(false)}
        onOpenModal={toggleModal}
      />
    </div>
  );
}
