import type { NextConfig } from "next";

const nextConfig: NextConfig = {
  images: {
    remotePatterns: [
      // 1. Supabase (你自己的图床，最推荐)
      {
        protocol: 'https',
        hostname: '*.supabase.co',
      },
      // 2. Unsplash (找风景图、概念图)
      {
        protocol: 'https',
        hostname: 'images.unsplash.com',
      },
      // 3. Booking.com (找公寓酒店图，如 Scape, Iglu, Avant)
      {
        protocol: 'https',
        hostname: 'cf.bstatic.com',
      },
      // 4. Realestate.com.au (澳洲最大的房产图源)
      {
        protocol: 'https',
        hostname: 'i2.au.reastatic.net',
      },
      // 5. Domain.com.au (澳洲第二大房产图源)
      {
        protocol: 'https',
        hostname: 'bucket-api.domain.com.au',
      },
    ],
  },
};

export default nextConfig;