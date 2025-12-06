import { supabase } from '@/lib/supabase';
import ApartmentCard from '@/components/ApartmentCard';

// 🛑 核心修复：强制动态渲染
// 这告诉 Vercel："不要缓存这个页面，每次有人访问都去数据库读最新的数据"
export const dynamic = 'force-dynamic';

export default async function Home() {
  // 从数据库获取公寓列表，按评价人数排序
  const { data: apartments } = await supabase
    .from('apartments')
    .select('*')
    .order('rating_count', { ascending: false });

  return (
    <main className="min-h-screen bg-[#f7f7f8] pb-20">
      {/* 头部 Header */}
      <header className="bg-white border-b sticky top-0 z-10 shadow-sm">
        <div className="max-w-5xl mx-auto px-4 h-16 flex items-center justify-between">
          <h1 className="text-2xl font-black italic tracking-tighter text-[#c01d2e]">
            Melb<span className="text-black">Score</span>
          </h1>
        </div>
      </header>

      {/* 主体内容 */}
      <div className="max-w-5xl mx-auto px-4 py-6">
        <div className="mb-6 flex items-end gap-2">
          <h2 className="text-xl font-bold text-gray-900">热门公寓榜</h2>
          <span className="text-xs text-gray-500 mb-1">实时更新</span>
        </div>
        
        {/* 列表区域 */}
        {!apartments || apartments.length === 0 ? (
            <div className="text-center py-20 text-gray-400">
              加载中或暂无数据...
            </div>
        ) : (
            <div className="grid grid-cols-1 sm:grid-cols-2 md:grid-cols-3 gap-6">
            {apartments.map((apt) => (
                <ApartmentCard key={apt.id} apartment={apt} />
            ))}
            </div>
        )}
      </div>
    </main>
  );
}