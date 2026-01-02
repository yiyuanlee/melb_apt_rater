-- 1. 重新更新算分函数 (加强版)
-- SECURITY DEFINER: 关键！强制以管理员权限运行，防止 RLS 导致算分不准
CREATE OR REPLACE FUNCTION update_apartment_stats()
RETURNS TRIGGER AS $$
DECLARE
    target_apt_id UUID;
BEGIN
    -- 智能判断：如果是删除操作，用旧ID；如果是新增/修改，用新ID
    IF (TG_OP = 'DELETE') THEN
        target_apt_id := OLD.apartment_id;
    ELSE
        target_apt_id := NEW.apartment_id;
    END IF;

    UPDATE apartments
    SET 
        rating_avg = (
            SELECT COALESCE(ROUND(AVG(score), 1), 0) 
            FROM reviews 
            WHERE apartment_id = target_apt_id
        ),
        rating_count = (
            SELECT COUNT(*) 
            FROM reviews 
            WHERE apartment_id = target_apt_id
        )
    WHERE id = target_apt_id;
    
    RETURN NULL;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER; -- 👈 这里加了权限提升

-- 2. 重新挂载触发器 (覆盖 增、删、改 所有情况)
DROP TRIGGER IF EXISTS on_review_added ON reviews;   -- 清理旧的
DROP TRIGGER IF EXISTS on_review_changes ON reviews; -- 清理可能存在的同名旧触发器

CREATE TRIGGER on_review_changes
AFTER INSERT OR UPDATE OR DELETE ON reviews
FOR EACH ROW
EXECUTE FUNCTION update_apartment_stats();

-- 3. 【无损修复】强制重新计算一遍所有公寓的分数
-- 这会立刻修复当前页面上所有显示错误的分数
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