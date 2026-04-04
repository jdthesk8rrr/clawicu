import type { Metadata } from "next";
import { Header } from "@/components/layout/Header";
import { Footer } from "@/components/layout/Footer";
import { DownloadClient } from "@/components/DownloadClient";

export const metadata: Metadata = {
  title: "Download — ClawICU",
  description:
    "Download ClawICU rescue toolkit for macOS and Linux. Install via curl, npm, Docker, Podman, or build from source.",
};

export default function DownloadPage() {
  return (
    <>
      <Header />
      <main>
        <DownloadClient />
      </main>
      <Footer />
    </>
  );
}
