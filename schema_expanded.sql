-- ============================================================
-- QuestUp - Genişletilmiş Veritabanı Şeması
-- Orijinal 18 tablo + 25 yeni tablo = 43 tablo
-- ============================================================

-- ============================================================
-- MEVCUT TABLOLAR (Hafifçe Güncellendi)
-- ============================================================

-- Kullanıcı temel bilgileri (güncellenmiş)
CREATE TABLE IF NOT EXISTS users (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    email VARCHAR(255) UNIQUE NOT NULL,
    username VARCHAR(100) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    role VARCHAR(20) DEFAULT 'user' CHECK (role IN ('user', 'admin', 'partner')),
    verification_status VARCHAR(20) DEFAULT 'pending',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    last_login TIMESTAMP,
    is_active BOOLEAN DEFAULT true,
    location_permission BOOLEAN DEFAULT false, -- YENİ: Konum izni
    location_visible BOOLEAN DEFAULT true,      -- YENİ: Yakındaki kullanıcılara görünsün
    age_group VARCHAR(20),                      -- YENİ: 13-17, 18-25, 26-35, vb
    is_verified BOOLEAN DEFAULT false            -- YENİ: Email doğrulandı mı
);

-- Kullanıcı profili (güncellenmiş)
CREATE TABLE IF NOT EXISTS profiles (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID UNIQUE NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    display_name VARCHAR(255),
    avatar_url VARCHAR(500),
    age INT CHECK (age >= 13),
    city VARCHAR(255),
    country VARCHAR(255),
    bio TEXT,
    level INT DEFAULT 1,
    total_xp INT DEFAULT 0,
    total_coins INT DEFAULT 0,
    current_energy INT DEFAULT 100,
    max_energy INT DEFAULT 100,
    tasks_completed INT DEFAULT 0,
    weekly_streak INT DEFAULT 0,
    trust_score FLOAT DEFAULT 100,             -- 0-100: 100 = tam güvenilir
    reputation_score INT DEFAULT 0,             -- Toplamsal puan
    daily_task_changes_used INT DEFAULT 0,     -- YENİ: Günlük görev değiştirme
    daily_ads_watched INT DEFAULT 0,           -- YENİ: Reklam izleme sayısı
    referral_code VARCHAR(50) UNIQUE,          -- YENİ: Kendi davet kodu
    referred_by_user_id UUID REFERENCES users(id),  -- YENİ: Kimi tarafından davet edildim
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Görev kategorileri (mevcut)
CREATE TABLE IF NOT EXISTS task_categories (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name VARCHAR(100) UNIQUE NOT NULL,
    description TEXT,
    weight_percentage INT CHECK (weight_percentage > 0 AND weight_percentage <= 100),
    icon_emoji VARCHAR(10)
);

-- Görevler (güncellenmiş)
CREATE TABLE IF NOT EXISTS tasks (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    category_id UUID NOT NULL REFERENCES task_categories(id),
    title VARCHAR(255) NOT NULL,
    description TEXT,
    difficulty VARCHAR(20) CHECK (difficulty IN ('kolay', 'orta', 'zor', 'efsane')),
    energy_cost INT DEFAULT 10,
    xp_reward INT,
    coin_reward INT,
    safety_warning TEXT,
    is_location_based BOOLEAN DEFAULT false,   -- YENİ: Konum tabanlı
    latitude FLOAT,                             -- YENİ: Harita koordinatı
    longitude FLOAT,                            -- YENİ: Harita koordinatı
    location_radius INT,                        -- YENİ: Konum yarıçapı (metre)
    requires_proof BOOLEAN DEFAULT true,        -- YENİ: Kanıt gerekli mi
    proof_type VARCHAR(50) DEFAULT 'photo',    -- YENİ: 'photo', 'video', 'qr', 'description'
    is_matchable BOOLEAN DEFAULT false,         -- YENİ: Eşleşmeli görev mi
    min_age INT DEFAULT 13,                     -- YENİ: Minimum yaş
    max_age INT,                                -- YENİ: Maksimum yaş
    is_ai_generated BOOLEAN DEFAULT false,      -- YENİ: AI tarafından oluşturuldu
    created_by UUID REFERENCES users(id),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    expires_at TIMESTAMP,
    is_active BOOLEAN DEFAULT true
);

-- Diğer mevcut tablolar...
CREATE TABLE IF NOT EXISTS user_tasks (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    task_id UUID NOT NULL REFERENCES tasks(id),
    status VARCHAR(50) DEFAULT 'assigned',
    assigned_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    completed_at TIMESTAMP,
    expires_at TIMESTAMP
);

CREATE TABLE IF NOT EXISTS task_submissions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES users(id),
    task_id UUID NOT NULL REFERENCES tasks(id),
    submission_status VARCHAR(50) DEFAULT 'pending',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    reviewed_at TIMESTAMP,
    reviewed_by UUID REFERENCES users(id),
    review_notes TEXT
);

CREATE TABLE IF NOT EXISTS reward_categories (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name VARCHAR(100) UNIQUE NOT NULL,
    icon_emoji VARCHAR(10)
);

CREATE TABLE IF NOT EXISTS rewards (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    category_id UUID REFERENCES reward_categories(id),
    title VARCHAR(255) NOT NULL,
    description TEXT,
    coin_cost INT NOT NULL,
    stock INT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS reward_codes (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    reward_id UUID NOT NULL REFERENCES rewards(id),
    code VARCHAR(100) UNIQUE NOT NULL,
    is_used BOOLEAN DEFAULT false,
    used_by UUID REFERENCES users(id),
    used_at TIMESTAMP,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS reward_claims (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES users(id),
    reward_id UUID NOT NULL REFERENCES rewards(id),
    status VARCHAR(50) DEFAULT 'pending',
    claimed_code UUID REFERENCES reward_codes(id),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    approved_at TIMESTAMP,
    approved_by UUID REFERENCES users(id)
);

CREATE TABLE IF NOT EXISTS transactions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    type VARCHAR(50),
    amount INT,
    description TEXT,
    related_id UUID,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS energy_logs (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES users(id),
    change INT,
    reason VARCHAR(100),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS xp_logs (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES users(id),
    xp_amount INT,
    level_before INT,
    level_after INT,
    reason VARCHAR(100),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS fraud_logs (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES users(id),
    type VARCHAR(100),
    description TEXT,
    severity VARCHAR(20),
    is_resolved BOOLEAN DEFAULT false,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS admin_logs (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    admin_id UUID REFERENCES users(id),
    action VARCHAR(100),
    table_name VARCHAR(100),
    record_id UUID,
    details JSONB,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS notifications (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    type VARCHAR(50),
    title VARCHAR(255),
    message TEXT,
    is_read BOOLEAN DEFAULT false,
    related_id UUID,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS leaderboard (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES users(id),
    rank INT,
    total_coins INT,
    tasks_completed INT,
    season_id UUID,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS system_settings (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    setting_key VARCHAR(100) UNIQUE NOT NULL,
    setting_value TEXT,
    data_type VARCHAR(50),
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- ============================================================
-- YENİ TABLOLAR (25 tane)
-- ============================================================

-- 1. Partner İşletmeler
CREATE TABLE IF NOT EXISTS partners (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES users(id),
    business_name VARCHAR(255) NOT NULL,
    business_type VARCHAR(100),  -- 'kafe', 'restoran', 'avm', vb
    description TEXT,
    logo_url VARCHAR(500),
    website VARCHAR(500),
    phone VARCHAR(20),
    email VARCHAR(255),
    status VARCHAR(50) DEFAULT 'pending',  -- 'pending', 'approved', 'rejected', 'suspended'
    approval_date TIMESTAMP,
    approved_by UUID REFERENCES users(id),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    is_active BOOLEAN DEFAULT true,
    wallet_balance INT DEFAULT 0
);

-- 2. Partner Lokasyonları
CREATE TABLE IF NOT EXISTS partner_locations (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    partner_id UUID NOT NULL REFERENCES partners(id) ON DELETE CASCADE,
    address VARCHAR(500) NOT NULL,
    city VARCHAR(100),
    latitude FLOAT NOT NULL,
    longitude FLOAT NOT NULL,
    phone VARCHAR(20),
    opening_hours VARCHAR(200),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 3. Partner Kuponları
CREATE TABLE IF NOT EXISTS partner_coupons (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    partner_id UUID NOT NULL REFERENCES partners(id) ON DELETE CASCADE,
    title VARCHAR(255),
    description TEXT,
    discount_percent INT,
    discount_amount INT,
    code VARCHAR(50) UNIQUE,
    max_uses INT,
    current_uses INT DEFAULT 0,
    valid_from TIMESTAMP,
    valid_until TIMESTAMP,
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 4. Sponsorlu Görevler
CREATE TABLE IF NOT EXISTS sponsored_tasks (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    partner_id UUID NOT NULL REFERENCES partners(id),
    task_id UUID NOT NULL REFERENCES tasks(id),
    budget INT,  -- Toplam bütçe
    cost_per_completion INT,  -- Tamamlama başına maliyet
    impressions INT DEFAULT 0,  -- Kaç kişiye gösterildi
    completions INT DEFAULT 0,  -- Kaç kişi tamamladı
    status VARCHAR(50) DEFAULT 'pending',  -- 'pending', 'approved', 'active', 'completed'
    approval_date TIMESTAMP,
    approved_by UUID REFERENCES users(id),
    start_date TIMESTAMP,
    end_date TIMESTAMP,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 5. QR Görev Noktaları
CREATE TABLE IF NOT EXISTS qr_points (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    partner_location_id UUID NOT NULL REFERENCES partner_locations(id),
    qr_code VARCHAR(500) UNIQUE NOT NULL,
    qr_token VARCHAR(100) UNIQUE NOT NULL,
    task_title VARCHAR(255),
    coin_reward INT DEFAULT 100,
    expiry_date TIMESTAMP,
    max_scans_per_day INT,
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 6. QR Tarama Logları
CREATE TABLE IF NOT EXISTS qr_scans (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES users(id),
    qr_point_id UUID NOT NULL REFERENCES qr_points(id),
    location_latitude FLOAT,
    location_longitude FLOAT,
    is_fraud_flagged BOOLEAN DEFAULT false,
    fraud_reason TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 7. Kullanıcı Eşleşmeleri
CREATE TABLE IF NOT EXISTS user_matches (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    task_id UUID NOT NULL REFERENCES tasks(id),
    user1_id UUID NOT NULL REFERENCES users(id),
    user2_id UUID NOT NULL REFERENCES users(id),
    match_score INT,  -- 0-100: Uyum yüzdesi
    distance_km FLOAT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    accepted_at TIMESTAMP,
    completed_at TIMESTAMP,
    is_active BOOLEAN DEFAULT true
);

-- 8. Arkadaş İstekleri
CREATE TABLE IF NOT EXISTS friend_requests (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    requester_id UUID NOT NULL REFERENCES users(id),
    recipient_id UUID NOT NULL REFERENCES users(id),
    status VARCHAR(50) DEFAULT 'pending',  -- 'pending', 'accepted', 'rejected', 'blocked'
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    responded_at TIMESTAMP
);

-- 9. Arkadaşlıklar
CREATE TABLE IF NOT EXISTS friendships (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user1_id UUID NOT NULL REFERENCES users(id),
    user2_id UUID NOT NULL REFERENCES users(id),
    is_blocked BOOLEAN DEFAULT false,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(user1_id, user2_id)
);

-- 10. Grup Challenge'ları
CREATE TABLE IF NOT EXISTS group_challenges (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    challenger_id UUID NOT NULL REFERENCES users(id),
    challenge_type VARCHAR(50),  -- 'task', 'mini_game', vb
    challenge_data JSONB,
    status VARCHAR(50) DEFAULT 'pending',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    expires_at TIMESTAMP
);

-- 11. Grup Challenge Üyeleri
CREATE TABLE IF NOT EXISTS group_challenge_members (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    challenge_id UUID NOT NULL REFERENCES group_challenges(id),
    user_id UUID NOT NULL REFERENCES users(id),
    status VARCHAR(50) DEFAULT 'pending',  -- 'pending', 'accepted', 'completed', 'declined'
    joined_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 12. Sezonlar
CREATE TABLE IF NOT EXISTS seasons (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name VARCHAR(255),
    description TEXT,
    start_date TIMESTAMP NOT NULL,
    end_date TIMESTAMP NOT NULL,
    theme VARCHAR(100),
    icon_url VARCHAR(500),
    is_active BOOLEAN DEFAULT false,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 13. Sezon Görevleri
CREATE TABLE IF NOT EXISTS season_tasks (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    season_id UUID NOT NULL REFERENCES seasons(id),
    task_id UUID NOT NULL REFERENCES tasks(id),
    season_points INT,  -- Sezon puanı
    is_required BOOLEAN DEFAULT false,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 14. Sezon Ödülleri
CREATE TABLE IF NOT EXISTS season_rewards (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    season_id UUID NOT NULL REFERENCES seasons(id),
    reward_id UUID REFERENCES rewards(id),
    min_rank INT,  -- Minimum rank
    max_rank INT,  -- Maksimum rank (-1 = sınırsız)
    reward_data JSONB,  -- Özel ödül verisi
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 15. Battle Pass Progress
CREATE TABLE IF NOT EXISTS battle_pass_progress (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES users(id),
    season_id UUID NOT NULL REFERENCES seasons(id),
    is_premium BOOLEAN DEFAULT false,
    level INT DEFAULT 1,
    progress_points INT DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(user_id, season_id)
);

-- 16. Kullanıcı Cüzdanı
CREATE TABLE IF NOT EXISTS user_wallet (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID UNIQUE NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    total_coins INT DEFAULT 0,
    available_coins INT DEFAULT 0,
    pending_coins INT DEFAULT 0,
    total_earned INT DEFAULT 0,
    total_spent INT DEFAULT 0,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 17. Cüzdan İşlemleri
CREATE TABLE IF NOT EXISTS wallet_transactions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    transaction_type VARCHAR(50),  -- 'earn', 'spend', 'referral', 'admin', 'season_reward'
    amount INT,
    balance_before INT,
    balance_after INT,
    description VARCHAR(500),
    related_id UUID,  -- İlgili görev, ödül vb
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 18. Davet Kodları
CREATE TABLE IF NOT EXISTS referral_codes (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES users(id),
    code VARCHAR(50) UNIQUE NOT NULL,
    uses INT DEFAULT 0,
    max_uses INT,
    bonus_coins INT,
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 19. Davet Ödülleri
CREATE TABLE IF NOT EXISTS referral_rewards (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    referrer_id UUID NOT NULL REFERENCES users(id),
    referred_user_id UUID NOT NULL REFERENCES users(id),
    status VARCHAR(50) DEFAULT 'pending',  -- 'pending', 'earned'
    bonus_coins INT,
    required_tasks INT DEFAULT 3,
    completed_tasks INT DEFAULT 0,
    earned_at TIMESTAMP,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 20. Rozetler
CREATE TABLE IF NOT EXISTS badges (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name VARCHAR(255),
    description TEXT,
    icon_emoji VARCHAR(10),
    icon_url VARCHAR(500),
    requirement TEXT,  -- Nasıl kazanılır
    rarity VARCHAR(50),  -- 'common', 'rare', 'epic', 'legendary'
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 21. Kullanıcı Rozetleri
CREATE TABLE IF NOT EXISTS user_badges (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    badge_id UUID NOT NULL REFERENCES badges(id),
    earned_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(user_id, badge_id)
);

-- 22. Mini Oyunlar
CREATE TABLE IF NOT EXISTS mini_games (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name VARCHAR(255),
    description TEXT,
    game_type VARCHAR(50),  -- 'spin_wheel', 'card_flip', 'scratch', 'puzzle'
    reward_type VARCHAR(50),  -- 'energy', 'coins', 'xp'
    min_reward INT,
    max_reward INT,
    daily_limit INT,
    daily_limit_per_user INT,
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 23. Mini Oyun Logları
CREATE TABLE IF NOT EXISTS mini_game_logs (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES users(id),
    game_id UUID NOT NULL REFERENCES mini_games(id),
    reward_earned INT,
    is_cheated BOOLEAN DEFAULT false,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 24. Reklam Izleme Ödülleri
CREATE TABLE IF NOT EXISTS ad_energy_rewards (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES users(id),
    energy_earned INT,
    ad_type VARCHAR(50),
    watched_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 25. Konum İzni ve Snapshot'ları
CREATE TABLE IF NOT EXISTS location_permissions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID UNIQUE NOT NULL REFERENCES users(id),
    permission_granted BOOLEAN DEFAULT false,
    is_visible_to_nearby BOOLEAN DEFAULT false,
    last_updated TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS user_location_snapshots (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES users(id),
    latitude FLOAT NOT NULL,
    longitude FLOAT NOT NULL,
    accuracy INT,  -- metres
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 26. Görev Değiştirme Logları
CREATE TABLE IF NOT EXISTS task_change_logs (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES users(id),
    old_task_id UUID REFERENCES tasks(id),
    new_task_id UUID REFERENCES tasks(id),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 27. Görev Medya Submission'ları
CREATE TABLE IF NOT EXISTS task_media_submissions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    submission_id UUID NOT NULL REFERENCES task_submissions(id),
    media_type VARCHAR(50),  -- 'photo', 'video', 'description'
    media_url VARCHAR(500),
    media_duration INT,  -- video için saniye
    description TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- ============================================================
-- İNDEKSLER (Performance)
-- ============================================================

CREATE INDEX idx_users_email ON users(email);
CREATE INDEX idx_users_location_permission ON users(location_permission);
CREATE INDEX idx_profiles_user_id ON profiles(user_id);
CREATE INDEX idx_tasks_category ON tasks(category_id);
CREATE INDEX idx_tasks_location ON tasks(latitude, longitude) WHERE is_location_based = true;
CREATE INDEX idx_user_tasks_user ON user_tasks(user_id);
CREATE INDEX idx_user_tasks_task ON user_tasks(task_id);
CREATE INDEX idx_partners_user ON partners(user_id);
CREATE INDEX idx_partners_status ON partners(status);
CREATE INDEX idx_partner_locations_coords ON partner_locations(latitude, longitude);
CREATE INDEX idx_qr_points_token ON qr_points(qr_token);
CREATE INDEX idx_qr_scans_user ON qr_scans(user_id);
CREATE INDEX idx_user_matches_users ON user_matches(user1_id, user2_id);
CREATE INDEX idx_friendships_users ON friendships(user1_id, user2_id);
CREATE INDEX idx_seasons_active ON seasons(is_active, start_date, end_date);
CREATE INDEX idx_battle_pass_user_season ON battle_pass_progress(user_id, season_id);
CREATE INDEX idx_wallet_user ON user_wallet(user_id);
CREATE INDEX idx_wallet_transactions_user ON wallet_transactions(user_id, created_at);
CREATE INDEX idx_user_badges_user ON user_badges(user_id);
CREATE INDEX idx_mini_game_logs_user ON mini_game_logs(user_id, created_at);
CREATE INDEX idx_ad_energy_rewards_user ON ad_energy_rewards(user_id, watched_at);
CREATE INDEX idx_location_snapshots_user_time ON user_location_snapshots(user_id, created_at);
CREATE INDEX idx_fraud_logs_user ON fraud_logs(user_id);
CREATE INDEX idx_notifications_user_read ON notifications(user_id, is_read);
CREATE INDEX idx_leaderboard_rank ON leaderboard(rank);

-- ============================================================
-- TEST VERİLERİ
-- ============================================================

-- Sezonları ekle
INSERT INTO seasons (name, description, start_date, end_date, theme, is_active) VALUES
('Nisan Hızlısı', 'Hızlı görevler, büyük ödüller', NOW(), NOW() + INTERVAL '30 days', 'spring', true),
('Mayıs Sezonu', 'Sosyal görevlerin ödüllendirildiği ay', NOW() + INTERVAL '30 days', NOW() + INTERVAL '60 days', 'social', false)
ON CONFLICT DO NOTHING;

-- Mini oyunları ekle
INSERT INTO mini_games (name, description, game_type, reward_type, min_reward, max_reward, daily_limit, daily_limit_per_user) VALUES
('Günlük Çark', 'Çarkı döndür ve ödül kazan', 'spin_wheel', 'energy', 5, 50, 1000, 3),
('Kart Seç', '3 karttan birini seç, ödülünü kazan', 'card_flip', 'coins', 10, 100, 500, 2),
('Sürpriz Kutusu', 'Kutuyu aç, sürpriz ödülü kazan', 'scratch', 'xp', 50, 200, 300, 1)
ON CONFLICT DO NOTHING;

-- Rozetler ekle
INSERT INTO badges (name, description, icon_emoji, requirement, rarity) VALUES
('Sabahçı', '7 gün üst üste sabah 06:00 - 09:00 arasında görev yap', '☀️', 'Haftalık sabah görevi', 'common'),
('Sporcu', '50 spor görevini tamamla', '💪', '50 spor görevi', 'rare'),
('Sosyal Kral', '50 sosyal görev tamamla', '👑', '50 sosyal görev', 'epic'),
('Şehir Kaşifi', 'İstanbulun 20 farklı yerinde görev yap', '🗺️', '20 lokasyon', 'epic'),
('Kahve Avcısı', '100 kafe QR görevini tamamla', '☕', '100 kafe görev', 'legendary'),
('QR Ustası', '500 QR kodu okut', '📱', '500 QR tarama', 'legendary'),
('Yedi Günlük Seri', '7 gün üst üste görev tamamla', '🔥', '7 günlük streak', 'rare')
ON CONFLICT DO NOTHING;

-- Partner kategorileri (eğer yoksa)
INSERT INTO reward_categories (name, icon_emoji) VALUES
('Kahve & Çay', '☕'),
('Yemek & İçecek', '🍕'),
('Dijital Kodlar', '🎮'),
('Mağaza İndirimi', '🛍️'),
('Deneyim', '🎪')
ON CONFLICT DO NOTHING;

-- ============================================================
-- VİEW'LAR (Kolay Sorgu için)
-- ============================================================

-- Aktif partner işletmelerinin konum bilgileri
CREATE OR REPLACE VIEW active_partner_locations AS
SELECT 
    pl.id,
    pl.partner_id,
    p.business_name,
    p.business_type,
    pl.latitude,
    pl.longitude,
    pl.address,
    pl.city
FROM partner_locations pl
JOIN partners p ON pl.partner_id = p.id
WHERE p.status = 'approved' AND p.is_active = true;

-- Kullanıcı liderlik tablosu (güncel)
CREATE OR REPLACE VIEW user_leaderboard_view AS
SELECT 
    u.id,
    p.display_name,
    p.total_coins,
    p.level,
    p.weekly_streak,
    p.tasks_completed,
    ROW_NUMBER() OVER (ORDER BY p.total_coins DESC) as rank
FROM users u
JOIN profiles p ON u.id = p.user_id
WHERE u.is_active = true
ORDER BY p.total_coins DESC;

-- Sezon dashboard
CREATE OR REPLACE VIEW season_dashboard_view AS
SELECT 
    s.id,
    s.name,
    s.start_date,
    s.end_date,
    COUNT(DISTINCT st.task_id) as task_count,
    COUNT(DISTINCT bp.user_id) as participant_count
FROM seasons s
LEFT JOIN season_tasks st ON s.id = st.season_id
LEFT JOIN battle_pass_progress bp ON s.id = bp.season_id
GROUP BY s.id;

-- ============================================================
-- FONKSIYONLAR (PostgreSQL Procedures)
-- ============================================================

-- Kullanıcı seviyelendirmesini güncelle
CREATE OR REPLACE FUNCTION update_user_level(user_id UUID)
RETURNS INT AS $$
DECLARE
    xp INT;
    new_level INT;
    old_level INT;
BEGIN
    SELECT total_xp, level INTO xp, old_level FROM profiles WHERE id = (SELECT id FROM profiles WHERE user_id = user_id);
    new_level := FLOOR(xp / 1000) + 1;  -- Her 1000 XP = 1 seviye
    
    UPDATE profiles SET level = new_level WHERE user_id = user_id;
    
    IF new_level > old_level THEN
        INSERT INTO notifications (user_id, type, title, message)
        VALUES (user_id, 'level_up', 'Level Atladın!', 'Tebrikler ' || new_level || '. seviyeye ulaştın!');
    END IF;
    
    RETURN new_level;
END;
$$ LANGUAGE plpgsql;

-- Eşleşme skoru hesapla
CREATE OR REPLACE FUNCTION calculate_match_score(user1_id UUID, user2_id UUID, task_id UUID)
RETURNS INT AS $$
DECLARE
    score INT := 0;
    age_diff INT;
    same_city BOOLEAN;
    trust1 FLOAT;
    trust2 FLOAT;
BEGIN
    -- Yaş farkı kontrol et
    SELECT ABS(COALESCE(p1.age, 0) - COALESCE(p2.age, 0)) INTO age_diff
    FROM profiles p1, profiles p2
    WHERE p1.user_id = user1_id AND p2.user_id = user2_id;
    
    IF age_diff <= 5 THEN score := score + 30; END IF;
    
    -- Şehir kontrol et
    SELECT p1.city = p2.city INTO same_city
    FROM profiles p1, profiles p2
    WHERE p1.user_id = user1_id AND p2.user_id = user2_id;
    
    IF same_city THEN score := score + 20; END IF;
    
    -- Güven skoru kontrol et
    SELECT trust_score INTO trust1 FROM profiles WHERE user_id = user1_id;
    SELECT trust_score INTO trust2 FROM profiles WHERE user_id = user2_id;
    
    IF trust1 > 80 AND trust2 > 80 THEN score := score + 30; END IF;
    IF trust1 > 60 AND trust2 > 60 THEN score := score + 15; END IF;
    
    RETURN MIN(score, 100);
END;
$$ LANGUAGE plpgsql;

-- Yakındaki görevleri bul (lokasyon tabanlı)
CREATE OR REPLACE FUNCTION find_nearby_tasks(user_lat FLOAT, user_lon FLOAT, distance_km INT)
RETURNS TABLE (
    task_id UUID,
    title VARCHAR,
    distance_km FLOAT,
    reward INT,
    difficulty VARCHAR
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        t.id,
        t.title,
        ROUND(CAST(111.111 * DEGREES(ACOS(LEAST(1, GREATEST(-1, 
            SIN(RADIANS(user_lat)) * SIN(RADIANS(t.latitude)) + 
            COS(RADIANS(user_lat)) * COS(RADIANS(t.latitude)) * 
            COS(RADIANS(user_lon - t.longitude))
        )))) AS NUMERIC), 2)::FLOAT,
        t.coin_reward,
        t.difficulty
    FROM tasks t
    WHERE t.is_location_based = true
    AND 111.111 * DEGREES(ACOS(LEAST(1, GREATEST(-1, 
        SIN(RADIANS(user_lat)) * SIN(RADIANS(t.latitude)) + 
        COS(RADIANS(user_lat)) * COS(RADIANS(t.latitude)) * 
        COS(RADIANS(user_lon - t.longitude))
    )))) <= distance_km;
END;
$$ LANGUAGE plpgsql;

COMMIT;
