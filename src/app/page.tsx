import { Header } from "@/components/layout/Header";
import { Footer } from "@/components/layout/Footer";
import { Hero } from "@/components/Hero";
import { IssueGrid } from "@/components/IssueGrid";
import { CTAGrid } from "@/components/CTAGrid";
import { TrustSection } from "@/components/TrustSection";
import { HowItWorks } from "@/components/HowItWorks";
import { ChatDemos } from "@/components/ChatDemos";
import { TestimonialMarquee } from "@/components/TestimonialMarquee";
import { NewsletterSection } from "@/components/NewsletterSection";
import { CTASection } from "@/components/CTASection";

export default function Home() {
  return (
    <>
      <Header />
      <main>
        <Hero />
        <IssueGrid />
        <CTAGrid />
        <TrustSection />
        <HowItWorks />
        <ChatDemos />
        <TestimonialMarquee />
        <NewsletterSection />
        <CTASection />
      </main>
      <Footer />
    </>
  );
}
