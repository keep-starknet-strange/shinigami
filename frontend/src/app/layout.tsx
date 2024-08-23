import Header from "@/components/header";
import "./globals.css";
import { Jura } from "next/font/google";
import Footer from "@/components/footer";
import { Metadata } from "next";

const jura = Jura({ subsets: ["latin"] });

const commonClasses = "w-full min-h-screen";

export const metadata: Metadata = {
  title: "Shinigami Script Wizard",
  description: "Shinigami Script Wizard",
};

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
            bg-black bg-contain bg-top bg-no-repeat min-h-screen
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
                  pt-5 px-5 space-y-8
                `}
              >
                <Header />
                {children}
              </div>
            </div>
          </div>
        </main>
      </body>
    </html>
  );
}
