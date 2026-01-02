-- 1. 先清理可能存在的旧触发器（防止冲突）
DROP TRIGGER IF EXISTS on_review_added ON reviews;
DROP FUNCTION IF EXISTS update_apartment_stats();

-- 2. 重新创建【核心算分函数】
-- 它的作用是：每当执行时，去 reviews 表里把对应公寓的所有分数拿出来求平均值
CREATE OR REPLACE FUNCTION update_apartment_stats()
RETURNS TRIGGER AS $$
BEGIN
    UPDATE apartments
    SET 
        -- 计算平均分 (保留1位小数，如果没评论就是0)
        rating_avg = (
            SELECT COALESCE(ROUND(AVG(score), 1), 0) 
            FROM reviews 
            WHERE apartment_id = NEW.apartment_id
        ),
        -- 计算总人数
        rating_count = (
            SELECT COUNT(*) 
            FROM reviews 
            WHERE apartment_id = NEW.apartment_id
        )
    WHERE id = NEW.apartment_id;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- 3. 重新安装【触发器】
-- 它的作用是：每当 reviews 表新增一条数据，就自动运行上面的算分函数
CREATE TRIGGER on_review_added
AFTER INSERT ON reviews
FOR EACH ROW
EXECUTE FUNCTION update_apartment_stats();

-- 4. 🚨【强制修复现有数据】(最重要的一步)
-- 这一步会强制把所有公寓现在的分数重新算一遍，修复 Swanston Central 的 0 分问题
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