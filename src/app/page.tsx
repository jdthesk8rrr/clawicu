import { Header } from "@/components/layout/Header";
import { Footer } from "@/components/layout/Footer";
import { Hero } from "@/components/Hero";
import { PatientSymptoms } from "@/components/PatientSymptoms";
import { TrustSection } from "@/components/TrustSection";
import { ExaminationProcess } from "@/components/ExaminationProcess";
import { TreatmentPlan } from "@/components/TreatmentPlan";
import { QuickStartGuides } from "@/components/QuickStartGuides";
import { ContactCTA } from "@/components/ContactCTA";
import { CTASection } from "@/components/CTASection";

export default function Home() {
  return (
    <>
      <Header />
      <main>
        <Hero />
        <PatientSymptoms />
        <TrustSection />
        <ExaminationProcess />
        <TreatmentPlan />
        <QuickStartGuides />
        <ContactCTA />
        <CTASection />
      </main>
      <Footer />
    </>
  );
}
