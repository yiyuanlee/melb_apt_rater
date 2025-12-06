# 🏢 MelbScore - 墨尔本公寓评分网  
**一个基于 Next.js + Supabase 构建的“虎扑风格”墨尔本公寓点评社区**

MelbScore 是专为 **墨尔本留学生、上班族与租房群体** 打造的公寓评分与点评平台。  
灵感来源于「虎扑评分」，旨在让租客快速了解公寓真实居住体验，避免踩坑。

平台提供 **公寓评分、热门榜单、大图沉浸式详情页、评论社区、简单风控等功能**，帮助用户更透明地了解墨尔本各大公寓。

---

## 📖 项目简介

**MelbScore 的核心目标：让每一个准备在墨尔本租房的人都能看到真实评价。**

用户可以：

- 🔥 浏览墨尔本热门公寓排名（按评论数自动排序）  
- ⭐ 查看实时公寓平均分（1–10 分制）  
- 📝 提交自己的居住体验评分与评论  
- 🖼️ 体验沉浸式的大图详情页  
- 🛡️ 在简单风控机制下防止重复刷分  
- 📡 浏览来自 Supabase、本地与 Unsplash 的混合图源  

---

## ✨ 核心功能亮点

### 🔥 热门榜单（自动排序）
首页根据评论数量计算热度，展示最热门的公寓。

### ⭐ 实时评分系统
- 用户打分后数据直接写入数据库  
- PostgreSQL 触发器自动更新平均分与评分人数  
- 无需后端手动计算  

### 🖼️ 沉浸式视觉体验
- 公寓详情页采用大图背景  
- 醒目的评分展示  
- 页面风格“虎扑味”十足  

### 🛡️ 防刷票机制
基于 **IP Hash** 的简单风控：
- 限制同一 IP 24 小时内重复打分  
- 保证评分更客观  

### 💬 评论社区
用户可以评论以下维度：
- 隔音
- 电梯速度
- 物业质量
- 安全性
- 周边配套  
等等……

### 🖼️ 多来源图像系统
支持多图源混用：
- Supabase storage（云端上传）  
- 本地 public/ 静态图  
- Unsplash（网络图）  

---

## 🛠 技术栈

| 分类 | 技术 |
|------|------|
| 前端框架 | **Next.js 15 (App Router)** |
| 语言 | **TypeScript** |
| CSS | Tailwind CSS |
| 后端 | Supabase (PostgreSQL) |
| 图标库 | Lucide React |
| 部署 | Vercel |

---

## 🚀 快速开始

### 1. 克隆项目

```bash
git clone https://github.com/your-username/melbscore.git
cd melbscore
```

### 2. 安装依赖

```bash
npm install
```

### 3. 配置环境变量

在项目根目录创建 **.env.local**：

```env
NEXT_PUBLIC_SUPABASE_URL=你的_Supabase_Project_URL
NEXT_PUBLIC_SUPABASE_ANON_KEY=你的_Supabase_Anon_Key
```

### 4. 启动开发环境

```bash
npm run dev
```

访问：http://localhost:3000

---

## 🗄️ 数据库配置（Supabase）

本项目依赖 Supabase 的 PostgreSQL。  
请在 Supabase 的 **SQL Editor** 中运行以下内容。

---

### 1. 建表 SQL

```sql
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

CREATE TABLE reviews (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    apartment_id UUID REFERENCES apartments(id) ON DELETE CASCADE,
    content TEXT,
    score INTEGER CHECK (score >= 1 AND score <= 10),
    upvotes INTEGER DEFAULT 0,
    ip_hash TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW()
);
```

---

### 2. 自动评分触发器（Trigger）

```sql
CREATE OR REPLACE FUNCTION update_apartment_stats()
RETURNS TRIGGER AS $$
BEGIN
    UPDATE apartments
    SET 
        rating_avg = (
            SELECT COALESCE(ROUND(AVG(score), 1), 0)
            FROM reviews
            WHERE apartment_id = NEW.apartment_id
        ),
        rating_count = (
            SELECT COUNT(*)
            FROM reviews
            WHERE apartment_id = NEW.apartment_id
        )
    WHERE id = NEW.apartment_id;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER on_review_added
AFTER INSERT ON reviews
FOR EACH ROW
EXECUTE FUNCTION update_apartment_stats();
```

---

## 📂 项目结构

```
melbscore/
├── app/
│   ├── page.tsx
│   ├── actions.ts
│   └── apartment/[id]/
├── components/
│   ├── ApartmentCard.tsx
│   └── ReviewForm.tsx
├── lib/
│   └── supabase.ts
├── public/
└── next.config.ts
```

---

## 🚢 部署 (Deployment)

使用 Vercel：

1. 推送代码到 GitHub  
2. 在 Vercel 导入此仓库  
3. 填写环境变量  
4. 点击 Deploy  

---

## 📝 Roadmap

- [x] 基础评分与评论系统  
- [x] 图片展示（本地 + 网络图）  
- [ ] 搜索功能  
- [ ] 地图模式  
- [ ] 用户登录  
- [ ] 评论图片上传  
- [ ] 多维评分（隔音、安全等）  

---

## 🤝 贡献

欢迎提交 Issue 或 PR，欢迎 Star 项目支持！

---

## 📄 License

MIT License
