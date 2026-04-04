import type { NextConfig } from "next";

const nextConfig: NextConfig = {
  // Image optimization for server deployment
  images: {
    unoptimized: true,
  },
  // Set trailing slash for consistent static hosting
  trailingSlash: true,
};

export default nextConfig;