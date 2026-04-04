"use client";

export function StarfieldBackground() {
  return (
    <div
      className="pointer-events-none fixed inset-0 overflow-hidden"
      aria-hidden="true"
    >
      {/* Nebula overlays */}
      <div className="absolute inset-0 bg-[radial-gradient(ellipse_at_50%_0%,rgba(255,77,77,0.08)_0%,transparent_60%)]" />
      <div className="absolute inset-0 bg-[radial-gradient(ellipse_at_80%_50%,rgba(0,229,204,0.05)_0%,transparent_40%)]" />

      {/* Stars — small */}
      <div
        className="absolute inset-0"
        style={{
          width: "1px",
          height: "1px",
          background: "transparent",
          boxShadow: "683px 205px #fff, 1492px 41px #fff, 304px 1025px #fff, 1756px 567px #fff, 98px 1432px #fff, 1456px 789px #fff, 234px 456px #fff, 890px 1234px #fff, 1678px 890px #fff, 456px 1678px #fff, 1234px 234px #fff, 789px 1456px #fff, 567px 1756px #fff, 1025px 304px #fff, 41px 1492px #fff, 205px 683px #fff, 1500px 800px #fff, 800px 1500px #fff, 1100px 300px #fff, 300px 1100px #fff, 600px 600px #fff, 1400px 1400px #fff, 200px 1800px #fff, 1800px 200px #fff, 900px 1100px #fff, 1100px 900px #fff, 1300px 700px #fff, 700px 1300px #fff, 500px 100px #fff, 100px 500px #fff, 1600px 400px #fff, 400px 1600px #fff",
          animation: "star-drift 80s linear infinite",
        }}
      />

      {/* Stars — medium */}
      <div
        className="absolute inset-0"
        style={{
          width: "2px",
          height: "2px",
          background: "transparent",
          borderRadius: "50%",
          boxShadow: "500px 300px rgba(255,255,255,0.7), 1200px 600px rgba(255,255,255,0.5), 800px 1400px rgba(255,255,255,0.6), 1400px 200px rgba(255,255,255,0.5), 200px 1000px rgba(255,255,255,0.7), 1000px 200px rgba(255,255,255,0.5), 600px 1200px rgba(255,255,255,0.6), 1300px 900px rgba(255,255,255,0.4), 900px 1300px rgba(255,255,255,0.5), 300px 500px rgba(0,229,204,0.5)",
          animation: "star-drift 120s linear infinite",
        }}
      />

      {/* Stars — large with twinkle */}
      <div
        className="absolute inset-0"
        style={{
          width: "3px",
          height: "3px",
          background: "transparent",
          borderRadius: "50%",
          boxShadow: "400px 400px rgba(255,77,77,0.6), 1000px 800px rgba(0,229,204,0.5), 1500px 300px rgba(255,255,255,0.7), 700px 1500px rgba(255,255,255,0.5), 200px 200px rgba(255,77,77,0.4)",
          animation: "star-drift 150s linear infinite, twinkle 4s ease-in-out infinite",
        }}
      />
    </div>
  );
}
