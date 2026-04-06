"use client";

/* Medical particle background: drifting faint medical crosses + dots */
export function StarfieldBackground() {
  const crosses = [
    { x: 8,   y: 12, s: 10, o: 0.04, d: "0s" },
    { x: 23,  y: 35, s: 8,  o: 0.03, d: "3s" },
    { x: 42,  y: 8,  s: 12, o: 0.05, d: "6s" },
    { x: 58,  y: 55, s: 9,  o: 0.04, d: "1s" },
    { x: 74,  y: 20, s: 11, o: 0.03, d: "9s" },
    { x: 88,  y: 70, s: 8,  o: 0.04, d: "4s" },
    { x: 15,  y: 75, s: 10, o: 0.03, d: "7s" },
    { x: 65,  y: 85, s: 9,  o: 0.04, d: "2s" },
    { x: 35,  y: 60, s: 7,  o: 0.03, d: "11s" },
    { x: 92,  y: 40, s: 10, o: 0.04, d: "5s" },
    { x: 50,  y: 30, s: 8,  o: 0.03, d: "8s" },
    { x: 78,  y: 92, s: 11, o: 0.04, d: "12s" },
  ];

  const dots = [
    { x: 20,  y: 25, r: 1.5, o: 0.12 },
    { x: 45,  y: 15, r: 1,   o: 0.10 },
    { x: 70,  y: 45, r: 1.5, o: 0.12 },
    { x: 30,  y: 80, r: 1,   o: 0.08 },
    { x: 85,  y: 60, r: 1.5, o: 0.10 },
    { x: 55,  y: 72, r: 1,   o: 0.09 },
    { x: 12,  y: 50, r: 1.5, o: 0.11 },
    { x: 95,  y: 18, r: 1,   o: 0.10 },
    { x: 62,  y: 95, r: 1,   o: 0.08 },
    { x: 38,  y: 42, r: 1.5, o: 0.12 },
    { x: 82,  y: 28, r: 1,   o: 0.09 },
    { x: 5,   y: 90, r: 1,   o: 0.08 },
  ];

  return (
    <div className="pointer-events-none fixed inset-0 overflow-hidden" aria-hidden="true">
      {/* Ambient radial glows */}
      <div className="absolute inset-0 bg-[radial-gradient(ellipse_at_50%_0%,rgba(255,77,77,0.07)_0%,transparent_60%)]" />
      <div className="absolute inset-0 bg-[radial-gradient(ellipse_at_80%_60%,rgba(0,232,122,0.04)_0%,transparent_40%)]" />

      <svg className="absolute inset-0 w-full h-full" xmlns="http://www.w3.org/2000/svg">
        <defs>
          {/* Medical cross symbol */}
          <symbol id="med-cross" viewBox="-6 -6 12 12">
            <rect x="-1.5" y="-5" width="3" height="10" rx="0.8" fill="currentColor" />
            <rect x="-5"   y="-1.5" width="10" height="3" rx="0.8" fill="currentColor" />
          </symbol>
        </defs>

        {/* Drifting medical crosses */}
        <g style={{ animation: "star-drift 180s linear infinite" }}>
          {crosses.map((c, i) => (
            <use
              key={i}
              href="#med-cross"
              x={`${c.x}%`}
              y={`${c.y}%`}
              width={c.s}
              height={c.s}
              style={{
                color: "rgba(255,77,77,1)",
                opacity: c.o,
                animation: `twinkle 8s ease-in-out ${c.d} infinite`,
              }}
            />
          ))}
        </g>

        {/* Static glow dots */}
        {dots.map((d, i) => (
          <circle
            key={i}
            cx={`${d.x}%`}
            cy={`${d.y}%`}
            r={d.r}
            fill="rgba(255,255,255,0.5)"
            opacity={d.o}
            style={{ animation: `twinkle ${5 + (i % 4)}s ease-in-out ${i * 0.5}s infinite` }}
          />
        ))}
      </svg>
    </div>
  );
}
