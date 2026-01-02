-- 1. 清理旧逻辑 (防止报错)
DROP TRIGGER IF EXISTS on_review_added ON reviews;
DROP FUNCTION IF EXISTS update_apartment_stats();

-- 2. 创建核心算分函数
-- 逻辑：当被触发时，查找该公寓的所有评论，算出平均分和总人数，更新到 apartments 表
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

-- 3. 创建触发器
-- 逻辑：每当 reviews 表新增一行数据，自动执行上面的算分函数
CREATE TRIGGER on_review_added
AFTER INSERT ON reviews
FOR EACH ROW
EXECUTE FUNCTION update_apartment_stats();

-- 4. 【立即执行】全量修复现有数据
-- 逻辑：不管以前数据对不对，现在强制把所有公寓的分数重新算一遍
UPDATE apartments a
SET 
    rating_avg = (
        SELECT COALESCE(ROUND(AVG(score), 1), 0) 
        FROM reviews r 
        WHERE r.apartment_id = a.id
    ),
    rating_count = (
        SELECT COUNT(*) 
        FROM reviews r 
        WHERE r.apartment_id = a.id
    );