import { supabase } from '@/lib/supabase';
import ApartmentCard from '@/components/ApartmentCard';

// 强制动态渲染，保证每次刷新都能看到最新分数
export const dynamic = 'force-dynamic';

export default async function Home() {
  // 从数据库获取公寓列表，按评价人数排序
  const { data: apartments } = await supabase
    .from('apartments')
    .select('*')
    .order('rating_count', { ascending: false });

  return (
    <main className="min-h-screen bg-[#f7f7f8] pb-20">
      {/* 头部 Header - 只有标题，没有按钮了 */}
      <header className="bg-white border-b sticky top-0 z-10">
        <div className="max-w-5xl mx-auto px-4 h-16 flex items-center">
          {/* 标题居中或者居左都可以，这里保持左对齐 */}
          <h1 className="text-2xl font-black italic tracking-tighter text-[#c01d2e]">
            Melb<span className="text-black">Score</span>
          </h1>
        </div>
      </header>

      {/* 主体内容 */}
      <div className="max-w-5xl mx-auto px-4 py-6">
        <div className="mb-6">
          <h2 className="text-xl font-bold text-gray-900">热门公寓榜</h2>
        </div>
        
        {/* 数据加载状态处理 */}
        {!apartments || apartments.length === 0 ? (
            <div className="text-center py-20 text-gray-400">
              数据库暂无数据，请检查 Supabase 连接
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