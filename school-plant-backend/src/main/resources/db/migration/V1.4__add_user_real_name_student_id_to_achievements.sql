-- 1. Add new columns to the achievements table
ALTER TABLE achievements
ADD COLUMN user_real_name VARCHAR(255) COMMENT '用户真实姓名',
ADD COLUMN student_id VARCHAR(50) COMMENT '学号/职工号';

-- 2. Update existing records by joining with the users table based on user_id
UPDATE achievements a
JOIN users u ON a.user_id = u.id
SET a.user_real_name = u.real_name,
    a.student_id = u.student_id
WHERE a.user_real_name IS NULL OR a.student_id IS NULL;
