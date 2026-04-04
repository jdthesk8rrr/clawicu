export function FloatingOrbs() {
  return (
    <div className="pointer-events-none fixed inset-0 overflow-hidden" aria-hidden="true">
      {/* Orb 1 - Top left, cyan */}
      <div
        className="absolute -left-32 -top-32 h-96 w-96 rounded-full bg-[#ff4d4d]/20 blur-[100px]"
        style={{ animation: "float 8s ease-in-out infinite" }}
      />
      {/* Orb 2 - Top right, accent */}
      <div
        className="absolute -right-32 top-1/4 h-80 w-80 rounded-full bg-[#00e5cc]/15 blur-[80px]"
        style={{ animation: "float 10s ease-in-out infinite 2s" }}
      />
      {/* Orb 3 - Bottom, secondary */}
      <div
        className="absolute bottom-0 left-1/3 h-64 w-64 rounded-full bg-[#111827]/30 blur-[60px]"
        style={{ animation: "float 12s ease-in-out infinite 4s" }}
      />
    </div>
  );
}
