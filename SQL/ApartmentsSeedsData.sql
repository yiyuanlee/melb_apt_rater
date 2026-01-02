ALTER TABLE apartments 
ADD COLUMN IF NOT EXISTS image_url TEXT,
ADD COLUMN IF NOT EXISTS address TEXT,
ADD COLUMN IF NOT EXISTS tags TEXT[],       -- 注意这里是数组类型
ADD COLUMN IF NOT EXISTS rating_avg NUMERIC DEFAULT 0,
ADD COLUMN IF NOT EXISTS rating_count INTEGER DEFAULT 0;
-- 1. 清空现有数据 (重新开始，ID 从 1 开始)
TRUNCATE TABLE apartments RESTART IDENTITY CASCADE;

-- 2. 插入所有公寓数据
-- 根据你的文件夹截图整理，包含文件名对应的图片路径
INSERT INTO apartments (name, image_url, address, tags, rating_avg, rating_count)
VALUES
  (
    'Aurora Melbourne Central', 
    '/aurora.jpg', 
    '228 La Trobe St, Melbourne VIC 3000', 
    ARRAY['近RMIT', '电梯慢', '无敌景'], 
    0, 0
  ),
  (
    'Victoria One', 
    '/victoria-one.jpg', 
    '462 Elizabeth St, Melbourne VIC 3000', 
    ARRAY['户型小', '位置好', '很多留学生'], 
    0, 0
  ),
  (
    'Avant', 
    '/avant.jpg', 
    '60 A''Beckett St, Melbourne VIC 3000', 
    ARRAY['外墙酷', '近维妈', '网红楼'], 
    0, 0
  ),
  (
    'Swanston Central', 
    '/swanstoncentral.jpg', 
    '168 Victoria St, Carlton VIC 3053', 
    ARRAY['地标建筑', '设施豪华', '近墨大'], 
    0, 0
  ),
  (
    'Empire Melbourne', 
    '/empire.jpg', 
    '81 A''Beckett St, Melbourne VIC 3000', 
    ARRAY['市中心', '交通便利', '健身房'], 
    0, 0
  ),
  (
    'EQ Tower', 
    '/eq-tower.jpg', 
    '135 A''Beckett St, Melbourne VIC 3000', 
    ARRAY['近市场', '高层景观', '公共设施佳'], 
    0, 0
  ),
  (
    'Light House', 
    '/lighthouse.jpg', 
    '450 Elizabeth St, Melbourne VIC 3000', 
    ARRAY['采光好', '紫色楼', '近超市'], 
    0, 0
  ),
  (
    'Uno Melbourne', 
    '/uno.jpg', 
    '111 A''Beckett St, Melbourne VIC 3000', 
    ARRAY['全新交付', '近Central', '设计现代'], 
    0, 0
  ),
  (
    'Scape Swanston', 
    '/Scape_Swanston.jpg', 
    '393 Swanston St, Melbourne VIC 3000', 
    ARRAY['学生公寓', '包含Bill', 'RMIT对面'], 
    0, 0
  ),
  (
    'UniLodge Lincoln House', 
    '/unilodge-lincoln-house.jpg', 
    '125 Bouverie St, Carlton VIC 3053', 
    ARRAY['近墨大', '社交氛围好', '工业风'], 
    0, 0
  );