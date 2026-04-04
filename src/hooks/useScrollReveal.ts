"use client";
import { useEffect, useRef, useState } from "react";

export function useScrollReveal(
  options?: IntersectionObserverInit & { rootMargin?: string; triggerOnce?: boolean }
) {
  const ref = useRef<HTMLElement>(null);
  const [isVisible, setIsVisible] = useState(false);

  useEffect(() => {
    const element = ref.current;
    if (!element) return;

    const { rootMargin = "0px 0px -50px 0px", triggerOnce = true, ...observerOptions } = options ?? {};

    const observer = new IntersectionObserver(
      ([entry]) => {
        if (entry.isIntersecting) {
          setIsVisible(true);
          if (triggerOnce) observer.disconnect();
        }
      },
      { threshold: 0.1, rootMargin, ...observerOptions }
    );

    observer.observe(element);
    return () => observer.disconnect();
  }, [options]);

  return { ref, isVisible };
}
