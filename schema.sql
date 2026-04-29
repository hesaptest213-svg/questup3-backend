-- =====================================================
-- QUESTUP - Veritabanı Şeması (PostgreSQL)
-- =====================================================
-- Bu dosya PostgreSQL 12+ ile uyumludur
-- Kullanım: psql questup_db < schema.sql

-- Tüm tabloları sil (gerekirse)
-- DROP SCHEMA public CASCADE;
-- CREATE SCHEMA public;

-- =====================================================
-- 1. USERS (Kullanıcılar)
-- =====================================================
CREATE TABLE users (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    email VARCHAR(255) UNIQUE NOT NULL,
    username VARCHAR(50) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    phone_number VARCHAR(20),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    is_active BOOLEAN DEFAULT TRUE,
    role VARCHAR(20) DEFAULT 'user', -- 'user', 'admin', 'moderator'
    is_verified BOOLEAN DEFAULT FALSE,
    verification_code VARCHAR(6),
    last_login TIMESTAMP
);

-- =====================================================
-- 2. PROFILES (Kullanıcı Profilleri)
-- =====================================================
CREATE TABLE profiles (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID UNIQUE NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    display_name VARCHAR(100),
    avatar_url VARCHAR(500),
    bio VARCHAR(255),
    age INTEGER,
    city VARCHAR(100),
    country VARCHAR(100),
    level INTEGER DEFAULT 1,
    total_xp BIGINT DEFAULT 0,
    total_coins BIGINT DEFAULT 0,
    energy_count INTEGER DEFAULT 100, -- Günlük enerji
    max_energy INTEGER DEFAULT 100,
    completed_tasks_count INTEGER DEFAULT 0,
    total_coins_earned BIGINT DEFAULT 0,
    weekly_streak INTEGER DEFAULT 0,
    last_activity_date DATE,
    trust_score FLOAT DEFAULT 100.0, -- Fraud skoru (0-100)
    CONSTRAINT age_valid CHECK (age >= 13 AND age <= 120)
);

-- =====================================================
-- 3. TASK_CATEGORIES (Görev Kategorileri)
-- =====================================================
CREATE TABLE task_categories (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name VARCHAR(100) NOT NULL UNIQUE,
    description TEXT,
    icon_url VARCHAR(500),
    color_hex VARCHAR(7),
    weight_percentage DECIMAL(5, 2) DEFAULT 1.0, -- Kaç % çıkacak
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Varsayılan kategoriler
INSERT INTO task_categories (name, description, weight_percentage) VALUES
('Sosyal Görevler', 'Arkadaş, tanıdık veya yabancılarla etkileşim', 40),
('Spor & Hareket', 'Yürüyüş, koşu, dans gibi fiziksel aktiviteler', 25),
('Eğlence', 'Komik, yaratıcı ve eğlenceli görevler', 20),
('Cesaret', 'Biraz daha cüretkar ama güvenli görevler', 10),
('Şehir Keşfi', 'Yeni yerler bulma, check-in yapma', 5);

-- =====================================================
-- 4. TASKS (Görevler)
-- =====================================================
CREATE TABLE tasks (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    category_id UUID NOT NULL REFERENCES task_categories(id),
    title VARCHAR(255) NOT NULL,
    description TEXT NOT NULL,
    difficulty VARCHAR(20) NOT NULL, -- 'kolay', 'orta', 'zor', 'efsane'
    energy_cost INTEGER NOT NULL,
    xp_reward INTEGER NOT NULL,
    coin_reward INTEGER NOT NULL,
    requires_photo BOOLEAN DEFAULT FALSE,
    requires_location BOOLEAN DEFAULT FALSE,
    requires_qr BOOLEAN DEFAULT FALSE,
    requires_friend_approval BOOLEAN DEFAULT FALSE,
    safety_warning TEXT, -- "Rahatsızlık veriyorsa yapma" notu
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    created_by UUID REFERENCES users(id),
    min_age INTEGER DEFAULT 13,
    max_age INTEGER DEFAULT 120,
    CONSTRAINT difficulty_valid CHECK (difficulty IN ('kolay', 'orta', 'zor', 'efsane'))
);

-- =====================================================
-- 5. USER_TASKS (Kullanıcıya Atanan Görevler)
-- =====================================================
CREATE TABLE user_tasks (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    task_id UUID NOT NULL REFERENCES tasks(id),
    assigned_date DATE DEFAULT CURRENT_DATE,
    status VARCHAR(20) DEFAULT 'assigned', -- 'assigned', 'in_progress', 'completed', 'expired'
    completed_at TIMESTAMP,
    expires_at TIMESTAMP DEFAULT (CURRENT_TIMESTAMP + INTERVAL '24 hours'),
    CONSTRAINT unique_daily_task UNIQUE(user_id, task_id, assigned_date)
);

-- =====================================================
-- 6. TASK_SUBMISSIONS (Görev Tamamlama Kanıtları)
-- =====================================================
CREATE TABLE task_submissions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_task_id UUID NOT NULL REFERENCES user_tasks(id) ON DELETE CASCADE,
    user_id UUID NOT NULL REFERENCES users(id),
    task_id UUID NOT NULL REFERENCES tasks(id),
    photo_url VARCHAR(500),
    latitude DECIMAL(10, 8),
    longitude DECIMAL(11, 8),
    qr_code_data VARCHAR(500),
    submission_status VARCHAR(20) DEFAULT 'pending', -- 'pending', 'approved', 'rejected', 'fraud_suspected'
    submitted_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    reviewed_at TIMESTAMP,
    reviewed_by UUID REFERENCES users(id),
    rejection_reason TEXT
);

-- =====================================================
-- 7. REWARD_CATEGORIES (Ödül Kategorileri)
-- =====================================================
CREATE TABLE reward_categories (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name VARCHAR(100) NOT NULL UNIQUE,
    description TEXT,
    icon_url VARCHAR(500)
);

INSERT INTO reward_categories (name, description) VALUES
('Kahve & Çay', 'Kahve mağazası kuponları'),
('Yemek & İçecek', 'Restoran ve fast-food kuponları'),
('Dijital Kodlar', 'Netflix, Spotify, oyun kodları'),
('Mağaza İndirimi', 'Alışveriş merkezi indirimleri'),
('Deneyim', 'Etkinlik biletleri ve aktiviteler');

-- =====================================================
-- 8. REWARDS (Ödüller)
-- =====================================================
CREATE TABLE rewards (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    category_id UUID NOT NULL REFERENCES reward_categories(id),
    title VARCHAR(255) NOT NULL,
    description TEXT,
    coin_cost INTEGER NOT NULL,
    stock_count INTEGER NOT NULL,
    stock_used INTEGER DEFAULT 0,
    image_url VARCHAR(500),
    partner_name VARCHAR(255),
    partner_contact VARCHAR(255),
    code_format VARCHAR(50), -- 'ALPHANUMERIC', 'NUMERIC', 'QR'
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    created_by UUID REFERENCES users(id),
    CONSTRAINT stock_valid CHECK (stock_used <= stock_count AND stock_count >= 0)
);

-- =====================================================
-- 9. REWARD_CODES (Kupon Kodları)
-- =====================================================
CREATE TABLE reward_codes (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    reward_id UUID NOT NULL REFERENCES rewards(id),
    code VARCHAR(50) UNIQUE NOT NULL,
    is_used BOOLEAN DEFAULT FALSE,
    used_by UUID REFERENCES users(id),
    used_at TIMESTAMP,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    qr_code_url VARCHAR(500)
);

-- =====================================================
-- 10. REWARD_CLAIMS (Ödül Talepleri)
-- =====================================================
CREATE TABLE reward_claims (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES users(id),
    reward_id UUID NOT NULL REFERENCES rewards(id),
    status VARCHAR(20) DEFAULT 'pending', -- 'pending', 'approved', 'rejected', 'delivered'
    claimed_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    approved_at TIMESTAMP,
    approved_by UUID REFERENCES users(id),
    code_id UUID REFERENCES reward_codes(id),
    delivery_method VARCHAR(50) DEFAULT 'digital', -- 'digital', 'email', 'sms'
    rejection_reason TEXT
);

-- =====================================================
-- 11. TRANSACTIONS (Coin/XP İşlemleri)
-- =====================================================
CREATE TABLE transactions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    transaction_type VARCHAR(30) NOT NULL, -- 'task_completion', 'reward_claim', 'admin_give', 'daily_bonus'
    amount INTEGER NOT NULL,
    currency VARCHAR(10) DEFAULT 'coin', -- 'coin', 'xp'
    reason VARCHAR(255),
    related_task_id UUID REFERENCES tasks(id),
    related_reward_id UUID REFERENCES rewards(id),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- =====================================================
-- 12. ENERGY_LOGS (Enerji Logları)
-- =====================================================
CREATE TABLE energy_logs (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    energy_change INTEGER NOT NULL, -- Pozitif veya negatif
    reason VARCHAR(255),
    task_id UUID REFERENCES tasks(id),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- =====================================================
-- 13. XP_LOGS (XP Logları)
-- =====================================================
CREATE TABLE xp_logs (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    xp_gained INTEGER NOT NULL,
    old_level INTEGER,
    new_level INTEGER,
    reason VARCHAR(255),
    task_id UUID REFERENCES tasks(id),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- =====================================================
-- 14. FRAUD_LOGS (Şüpheli Aktivite Logları)
-- =====================================================
CREATE TABLE fraud_logs (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES users(id) ON DELETE SET NULL,
    fraud_type VARCHAR(100) NOT NULL, -- 'duplicate_photo', 'fake_gps', 'rapid_completion', 'multi_account'
    severity VARCHAR(20) DEFAULT 'medium', -- 'low', 'medium', 'high'
    description TEXT,
    related_task_id UUID REFERENCES tasks(id),
    status VARCHAR(20) DEFAULT 'flagged', -- 'flagged', 'investigated', 'confirmed', 'false_alarm'
    admin_notes TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    resolved_at TIMESTAMP,
    resolved_by UUID REFERENCES users(id)
);

-- =====================================================
-- 15. ADMIN_LOGS (Admin İşlemleri)
-- =====================================================
CREATE TABLE admin_logs (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    admin_id UUID NOT NULL REFERENCES users(id),
    action VARCHAR(100) NOT NULL,
    target_type VARCHAR(50), -- 'user', 'task', 'reward', 'task_submission'
    target_id UUID,
    old_values JSONB,
    new_values JSONB,
    reason TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- =====================================================
-- 16. NOTIFICATIONS (Bildirimler)
-- =====================================================
CREATE TABLE notifications (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    title VARCHAR(255) NOT NULL,
    message TEXT,
    notification_type VARCHAR(50) NOT NULL, -- 'task_assigned', 'energy_restored', 'reward_approved', 'level_up'
    is_read BOOLEAN DEFAULT FALSE,
    read_at TIMESTAMP,
    action_url VARCHAR(500),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- =====================================================
-- 17. LEADERBOARD (Liderlik Tablosu - Snapshot)
-- =====================================================
CREATE TABLE leaderboard (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    rank_global INTEGER,
    rank_city INTEGER,
    rank_weekly INTEGER,
    total_coins_this_week INTEGER,
    tasks_completed_this_week INTEGER,
    update_date DATE DEFAULT CURRENT_DATE,
    CONSTRAINT unique_weekly_rank UNIQUE(user_id, update_date)
);

-- =====================================================
-- 18. SYSTEM_SETTINGS (Sistem Ayarları)
-- =====================================================
CREATE TABLE system_settings (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    setting_key VARCHAR(100) UNIQUE NOT NULL,
    setting_value VARCHAR(1000),
    setting_type VARCHAR(20), -- 'string', 'integer', 'boolean', 'json'
    description TEXT,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_by UUID REFERENCES users(id)
);

-- Varsayılan sistem ayarları
INSERT INTO system_settings (setting_key, setting_value, setting_type, description) VALUES
('daily_energy_amount', '100', 'integer', 'Kullanıcıya günde verilen enerji miktarı'),
('daily_tasks_count', '5', 'integer', 'Günde atanan görev sayısı'),
('fraud_auto_flag_threshold', '3', 'integer', 'Kaç şüpheli aktivite sonrası otomatik flag'),
('min_task_completion_time', '60', 'integer', 'Bir görevid tamamlamak için minimum saniye'),
('admin_approval_required_for_reward', 'true', 'boolean', 'Ödül çekimi için admin onayı gerekli mi'),
('enable_referral_system', 'false', 'boolean', 'Davet sistemi açık mı'),
('referral_bonus_coins', '50', 'integer', 'Arkadaş davet bonusu'),
('max_daily_energy_purchase', '50', 'integer', 'Günde satın alınabilecek maximum enerji');

-- =====================================================
-- İNDEKSLER (Performans İçin)
-- =====================================================

-- Kullanıcı sorguları
CREATE INDEX idx_users_email ON users(email);
CREATE INDEX idx_users_username ON users(username);
CREATE INDEX idx_users_role ON users(role);

-- Profil sorguları
CREATE INDEX idx_profiles_user_id ON profiles(user_id);
CREATE INDEX idx_profiles_level ON profiles(level);
CREATE INDEX idx_profiles_city ON profiles(city);

-- Görev sorguları
CREATE INDEX idx_tasks_category ON tasks(category_id);
CREATE INDEX idx_tasks_is_active ON tasks(is_active);

-- Kullanıcı görevleri
CREATE INDEX idx_user_tasks_user ON user_tasks(user_id);
CREATE INDEX idx_user_tasks_task ON user_tasks(task_id);
CREATE INDEX idx_user_tasks_status ON user_tasks(status);
CREATE INDEX idx_user_tasks_assigned_date ON user_tasks(assigned_date);

-- Görev tamamlama
CREATE INDEX idx_submissions_user ON task_submissions(user_id);
CREATE INDEX idx_submissions_status ON task_submissions(submission_status);
CREATE INDEX idx_submissions_submitted_at ON task_submissions(submitted_at);

-- Ödül sorguları
CREATE INDEX idx_rewards_category ON rewards(category_id);
CREATE INDEX idx_rewards_is_active ON rewards(is_active);

-- Ödül talepleri
CREATE INDEX idx_reward_claims_user ON reward_claims(user_id);
CREATE INDEX idx_reward_claims_status ON reward_claims(status);

-- İşlem sorguları
CREATE INDEX idx_transactions_user ON transactions(user_id);
CREATE INDEX idx_transactions_type ON transactions(transaction_type);
CREATE INDEX idx_transactions_created_at ON transactions(created_at);

-- Fraud logları
CREATE INDEX idx_fraud_logs_user ON fraud_logs(user_id);
CREATE INDEX idx_fraud_logs_status ON fraud_logs(status);

-- Bildirimler
CREATE INDEX idx_notifications_user ON notifications(user_id);
CREATE INDEX idx_notifications_is_read ON notifications(is_read);

-- Liderlik tablosu
CREATE INDEX idx_leaderboard_user ON leaderboard(user_id);
CREATE INDEX idx_leaderboard_date ON leaderboard(update_date);

-- =====================================================
-- VERİLER OLUŞTUR (Test Amaçlı)
-- =====================================================

-- Test kullanıcılar (Şifreler bcrypt ile hashlenecek)
-- Şifre: Test123!@
INSERT INTO users (email, username, password_hash, phone_number, role, is_verified) VALUES
('test@questup.com', 'testuser', '$2b$10$YOixvMLmkksStfREiWUl.e8DZ5QIkb8Rc6pgUDoz4SM7s/jPPsSm', '+905551234567', 'user', TRUE),
('admin@questup.com', 'admin', '$2b$10$YOixvMLmkksStfREiWUl.e8DZ5QIkb8Rc6pgUDoz4SM7s/jPPsSm', '+905559999999', 'admin', TRUE);

-- Test profilleri
INSERT INTO profiles (user_id, display_name, avatar_url, age, city, level, total_xp, total_coins, energy_count, completed_tasks_count, weekly_streak) 
SELECT id, 'Test Kullanıcı', 'https://api.dicebear.com/7.x/avataaars/svg?seed=testuser', 22, 'İstanbul', 5, 2500, 500, 100, 45, 7 
FROM users WHERE username = 'testuser';

INSERT INTO profiles (user_id, display_name, avatar_url, age, city, level, total_xp, total_coins, energy_count, completed_tasks_count, weekly_streak) 
SELECT id, 'Admin', 'https://api.dicebear.com/7.x/avataaars/svg?seed=admin', 25, 'Ankara', 50, 50000, 100000, 100, 500, 100 
FROM users WHERE username = 'admin';

-- =====================================================
-- KONTROL SORGUSU
-- =====================================================
-- Veritabanı başarıyla oluşturuldu mu?
-- SELECT COUNT(*) as table_count FROM information_schema.tables WHERE table_schema = 'public';
-- 18 tablo olmalı
