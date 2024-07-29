'use client'

import ShinigamiIDE from '../components/ShinigamiIDE'
import { FaGithub } from 'react-icons/fa'

export default function Home() {
  return (
    <div className="min-h-screen bg-black p-4">
      <header className="flex justify-between items-center mb-8">
        <h1 className="text-4xl font-bold text-green-400">SHINIGAMI SCRIPT WIZARD</h1>
        <a
          href="https://github.com/keep-starknet-strange/shinigami"
          target="_blank"
          rel="noopener noreferrer"
          className="text-green-400 hover:text-green-300 transition-colors"
        >
          <FaGithub size={32} />
        </a>
      </header>
      <main>
        <ShinigamiIDE />
      </main>
    </div>
  )
}