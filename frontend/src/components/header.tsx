"use client";

import Image from "next/image";
import Link from "next/link";
import logo from "../../public/logo.png";
import githubImage from "@/images/github.svg";
import telegram from "@/images/telegram.svg";
import menu from "@/images/menu.svg";
import x_circle from "@/images/x-circle.svg";
import cancel_circle from "@/images/cancel-circle.svg";
import { useState } from "react";
import {
    Dialog,
} from "@material-tailwind/react";

export default function Header() {
    const [open, setOpen] = useState(false);
    const [openModal, setOpenModal] = useState(false);
    const handleOpen = () => setOpenModal(!open);
    return (
        <div className="w-full h-24 border-y border-white/10 flex flex-col justify-center sm:h-fit sm:border-y-0 sm:flex-row">
            <div className="w-full max-w-4xl flex flex-row items-center justify-between border border-white/10 px-3.5 rounded-3xl sm:rounded-none sm:border-0">
                <Link href="/">
                    <div className="flex flex-row items-center justify-center space-x-0.5">
                        <Image src={logo} width={25} height={25} alt="Shinigami" />
                        <h6 className="uppercase text-white">Shinigami Script Wizard</h6>
                    </div>
                </Link>
                <button className="block sm:hidden py-2.5" onClick={() => setOpen(true)}>
                    <Image src={menu} alt="menu" />
                </button>
                <div className="sm:flex flex-row items-center space-x-5 hidden">
                    <button className="uppercase text-white" onClick={handleOpen}>About</button>
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
            <Dialog open={openModal} handler={handleOpen} className="bg-black w-full" nonce={() => { }} onResize={() => { }} onResizeCapture={() => { }}>
                <button className="p-0.5 border-2 border-[#00FF5E] rounded-md absolute -top-3.5 -right-3 bg-[#00FF5E]/10 z-20" onClick={() => setOpenModal(false)}>
                    <Image src={cancel_circle} alt="close" className="z-20" />
                    <div className="w-2.5 h-2.5 bg-black absolute top-2.5 left-2.5 -z-10" />
                </button>
                <div className="w-full h-full pb-3.5">
                    <div className="w-full h-24 bg-[url('/banner.png')] bg-cover bg-no-repeat bg-center" />
                    <div className="p-2.5 font-medium">
                        <p className="text-white">shinigami is a library enabling Bitcoin Script VM execution in Cairo, thus allowing the generation of STARK proofs of generic Bitcoin Script computation.</p>
                        <ul className="list-disc text-white ml-3.5">
                            <li>Bitcoin script interpretation and execution</li>
                            <li>Easily configurable VM (enable different opcodes)</li>
                            <li>In cairo, Bitcoin Script compiler</li>
                        </ul>
                    </div>
                    <div className="flex flex-row items-center space-x-2.5 px-2.5">
                        <button className="flex flex-row items-center space-x-1 bg-[#00FF5E]/10 border-[#00FF5E] border-2 py-2.5 px-5">
                            <Image src={githubImage} alt="" unoptimized />
                            <h6 className="text-[#00FF5E] uppercase text-base">GITHUB</h6>
                        </button>
                        <button className="flex flex-row items-center space-x-1 bg-[#00FF5E]/10 border-[#00FF5E] border-2 py-2.5 px-5">
                            <Image src={telegram} alt="" unoptimized />
                            <h6 className="text-[#00FF5E] uppercase text-base">TELEGRAM</h6>
                        </button>
                    </div>
                </div>
            </Dialog>
            {open && <div className="w-full h-fit absolute top-16 z-20 inset-x-0 flex flex-row items-center rounded-xl sm:hidden">
                <div className="w-full mx-5 h-full backdrop-blur-md rounded-xl border-2 border-white/10">
                    <div className="w-full max-w-4xl flex flex-row items-center justify-between border-b border-white/10 px-3.5 sm:border-0">
                        <Link href="/">
                            <div className="flex flex-row items-center justify-center space-x-0.5">
                                <Image src={logo} width={25} height={25} alt="Shinigami" />
                                <h6 className="uppercase text-white">Shinigami Script Wizard</h6>
                            </div>
                        </Link>
                        <button className="block sm:hidden py-2.5" onClick={() => setOpen(false)}>
                            <Image src={x_circle} alt="menu" />
                        </button>
                    </div>
                    <div className="py-2.5 px-2.5 space-y-2.5">
                        <button className="text-white w-full text-center bg-[#111111] py-2.5 rounded-md" onClick={() => setOpenModal(true)}>ABOUT</button>
                        <button className="text-white w-full text-center bg-[#111111] py-2.5 rounded-md flex row items-center justify-center">
                            <div className="flex flex-row items-center space-x-1">
                                <Image src={githubImage} alt="" unoptimized />
                                <h6 className="text-[#00FF5E] uppercase">Github</h6>
                            </div>
                        </button>
                    </div>
                </div>
            </div>}
        </div>)
};