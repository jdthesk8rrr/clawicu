interface ECGLineProps {
  className?: string;
}

export function ECGLine({ className = "" }: ECGLineProps) {
  return (
    <svg
      className={`w-full ${className}`}
      viewBox="0 0 800 60"
      preserveAspectRatio="none"
      xmlns="http://www.w3.org/2000/svg"
      aria-hidden="true"
    >
      <defs>
        <linearGradient id="ecg-gradient" x1="0%" y1="0%" x2="100%" y2="0%">
          <stop offset="0%" stopColor="rgba(255, 77, 77, 0.3)" />
          <stop offset="50%" stopColor="rgba(255, 77, 77, 0.8)" />
          <stop offset="100%" stopColor="rgba(255, 77, 77, 0.3)" />
        </linearGradient>
      </defs>
      <path
        d="M 0 30 L 100 30 L 120 30 L 140 10 L 160 50 L 180 10 L 200 30 L 300 30 L 320 30 L 340 5 L 360 55 L 380 5 L 400 30 L 600 30 L 620 30 L 640 15 L 660 45 L 680 15 L 700 30 L 800 30"
        fill="none"
        stroke="url(#ecg-gradient)"
        strokeWidth="2"
        strokeLinecap="round"
        strokeLinejoin="round"
        className="animate-[ecg-draw_3s_linear_infinite]"
        style={{ strokeDasharray: 1600, strokeDashoffset: 1600 }}
      />
    </svg>
  );
}
