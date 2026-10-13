-- Chạy 1 lần trên database hiện tại (an toàn nếu chạy lại).
-- username = số điện thoại; password_hash lưu dạng pbkdf2$lặp$salt$hash (xem PasswordHasher.java).
ALTER TABLE users ADD COLUMN IF NOT EXISTS full_name VARCHAR(150);
ALTER TABLE users ADD COLUMN IF NOT EXISTS id_number VARCHAR(20);
CREATE UNIQUE INDEX IF NOT EXISTS ux_users_id_number ON users(id_number) WHERE id_number IS NOT NULL;
