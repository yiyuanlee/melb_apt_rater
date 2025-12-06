🏢 MelbScore - 墨尔本公寓评分网
一个基于 Next.js + Supabase 构建的“虎扑风格”墨尔本公寓点评社区。
📖 项目简介
MelbScore 是一个专为墨尔本留学生和租房群体打造的公寓评分平台。灵感来源于“虎扑评分”，用户可以浏览墨尔本热门的公寓大楼，查看实时评分，并提交自己的居住体验和打分。
✨ 核心功能
热门榜单：首页根据热度（评论数）自动排序展示热门公寓。
实时评分：采用 1-10 分制，用户打分后，系统通过数据库触发器自动计算平均分。
视觉冲击：详情页采用沉浸式大图背景，醒目的分数展示。
防刷机制：基于 IP Hash 的简单风控，限制同一 IP 在 24 小时内重复打分。
评论社区：用户可以发表对公寓的详细评价（如隔音、电梯速度、周边设施等）。
混合图源：支持 Supabase 云端存储图片、Unsplash 网络图以及本地静态图片。
🛠 技术栈
前端框架: Next.js 15 (App Router)
语言: TypeScript
样式库: Tailwind CSS
后端/数据库: Supabase (PostgreSQL)
图标库: Lucide React
部署: Vercel
🚀 快速开始
1. 克隆项目
git clone [https://github.com/your-username/melb-apt-rater.git](https://github.com/your-username/melb-apt-rater.git)
cd melb-apt-rater


2. 安装依赖
npm install


3. 配置环境变量
在项目根目录创建一个 .env.local 文件，并填入你的 Supabase 密钥：
# .env.local
NEXT_PUBLIC_SUPABASE_URL=你的_Supabase_Project_URL
NEXT_PUBLIC_SUPABASE_ANON_KEY=你的_Supabase_Anon_Key


4. 运行开发服务器
npm run dev


打开浏览器访问 http://localhost:3000 即可看到项目。
🗄️ 数据库配置 (Supabase)
本项目依赖 Supabase 的 PostgreSQL 数据库。请在 Supabase 的 SQL Editor 中运行以下脚本以初始化表结构和触发器。
1. 建表 SQL
-- 创建公寓表
CREATE TABLE apartments (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    name TEXT NOT NULL,
    location TEXT,
    cover_image TEXT,
    rating_avg NUMERIC(3, 1) DEFAULT 0.0,
    rating_count INTEGER DEFAULT 0,
    tags TEXT[],
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- 创建评论表
CREATE TABLE reviews (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    apartment_id UUID REFERENCES apartments(id) ON DELETE CASCADE,
    content TEXT,
    score INTEGER CHECK (score >= 1 AND score <= 10),
    upvotes INTEGER DEFAULT 0,
    ip_hash TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW()
);


2. 配置自动算分触发器 (Trigger)
此逻辑确保每当有新评论插入时，无需后端代码干预，数据库自动更新公寓的平均分。
-- 定义算分函数
CREATE OR REPLACE FUNCTION update_apartment_stats()
RETURNS TRIGGER AS $$
BEGIN
    UPDATE apartments
    SET 
        rating_avg = (SELECT COALESCE(ROUND(AVG(score), 1), 0) FROM reviews WHERE apartment_id = NEW.apartment_id),
        rating_count = (SELECT COUNT(*) FROM reviews WHERE apartment_id = NEW.apartment_id)
    WHERE id = NEW.apartment_id;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- 挂载触发器
CREATE TRIGGER on_review_added
AFTER INSERT ON reviews
FOR EACH ROW
EXECUTE FUNCTION update_apartment_stats();


📂 项目结构
my_melb_apt_rater/
├── app/
│   ├── page.tsx               # 首页 (公寓列表)
│   ├── actions.ts             # Server Actions (处理评分提交逻辑)
│   └── apartment/[id]/        # 详情页动态路由
├── components/
│   ├── ApartmentCard.tsx      # 公寓卡片组件
│   └── ReviewForm.tsx         # 打分表单组件
├── lib/
│   └── supabase.ts            # Supabase 客户端配置
├── public/                    # 静态资源 (本地公寓图片)
└── next.config.ts             # 图片域名白名单配置


🚢 部署 (Deployment)
推荐使用 Vercel 进行部署，因为它与 Next.js 完美兼容。
将代码推送到 GitHub。
在 Vercel 中导入该 GitHub 仓库。
在 Vercel 的 Environment Variables 设置中添加 NEXT_PUBLIC_SUPABASE_URL 和 NEXT_PUBLIC_SUPABASE_ANON_KEY。
点击 Deploy。
📝 待办计划 (Roadmap)
[x] 基础评分与评论功能
[x] 图片展示 (支持本地与网络图)
[ ] 搜索功能: 支持按公寓名字搜索
[ ] 地图模式: 在地图上查看公寓位置
[ ] 用户登录: 支持 Google/微信 登录，管理自己的评论
[ ] 图片上传: 允许用户在评论中上传实拍图
🤝 贡献
欢迎提交 Issue 或 Pull Request！
📄 许可证
MIT License
