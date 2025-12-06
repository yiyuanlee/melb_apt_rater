import { createClient } from '@supabase/supabase-js';

const supabaseUrl = process.env.NEXT_PUBLIC_SUPABASE_URL!;
const supabaseAnonKey = process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY!;

// 🚀 核心修改：添加 global fetch 配置
export const supabase = createClient(supabaseUrl, supabaseAnonKey, {
  auth: {
    persistSession: false, // 服务端组件不需要持久化 Session
  },
  global: {
    // 强制每次请求都不使用缓存 (no-store)
    fetch: (url, options) => {
      return fetch(url, {
        ...options,
        cache: 'no-store', 
        next: { revalidate: 0 }, // 双重保险：告诉 Next.js 永不缓存
      });
    },
  },
});