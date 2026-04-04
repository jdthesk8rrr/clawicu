"use client";

import { useState, useEffect } from "react";

export type OS = "macos" | "linux";

export function useOSDetector(): OS {
  const [os, setOs] = useState<OS>("linux");

  useEffect(() => {
    const platform = navigator.platform.toLowerCase();
    if (platform.includes("mac") || platform.includes("darwin")) {
      setOs("macos");
    } else {
      setOs("linux");
    }
  }, []);

  return os;
}
