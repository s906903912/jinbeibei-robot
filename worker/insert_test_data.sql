-- 金贝贝桌面精灵 - 测试数据
-- 插入测试设备

-- 插入测试设备
INSERT INTO devices (id, name, type, status, last_seen, ip_address, firmware_version, created_at, updated_at)
VALUES (
    'device-001',
    '金贝贝 #001',
    'esp32-s3',
    'online',
    (strftime('%s', 'now') * 1000),
    '192.168.1.100',
    '0.1.0',
    (strftime('%s', 'now') * 1000),
    (strftime('%s', 'now') * 1000)
);

-- 插入设备状态
INSERT INTO device_states (device_id, volume, brightness, current_emotion, wifi_ssid, wifi_strength, is_charging, temperature, uptime_seconds, updated_at)
VALUES (
    'device-001',
    70,
    80,
    'happy',
    'Home-WiFi',
    -65,
    1,
    45.5,
    3600,
    (strftime('%s', 'now') * 1000)
);

-- 插入测试用户
INSERT INTO users (id, username, email, avatar_url, created_at, updated_at)
VALUES (
    'user-001',
    'auther',
    'auther@example.com',
    'https://api.dicebear.com/7.x/avataaars/svg?seed=auther',
    (strftime('%s', 'now') * 1000),
    (strftime('%s', 'now') * 1000)
);

-- 关联用户和设备
INSERT INTO device_users (user_id, device_id, role, created_at)
VALUES (
    'user-001',
    'device-001',
    'owner',
    (strftime('%s', 'now') * 1000)
);

-- 插入测试闹钟
INSERT INTO alarms (id, device_id, user_id, time, enabled, repeat_days, label, sound, created_at, updated_at)
VALUES (
    'alarm-001',
    'device-001',
    'user-001',
    '08:00',
    1,
    '["mon","tue","wed","thu","fri"]',
    '起床啦',
    'default',
    (strftime('%s', 'now') * 1000),
    (strftime('%s', 'now') * 1000)
);

-- 插入测试对话
INSERT INTO chat_messages (id, device_id, user_id, role, content, emotion, created_at)
VALUES
    (
        'msg-001',
        'device-001',
        'user-001',
        'user',
        '你好，金贝贝！',
        NULL,
        (strftime('%s', 'now') * 1000)
    ),
    (
        'msg-002',
        'device-001',
        'user-001',
        'assistant',
        '主人好！我是你的桌面小精灵金贝贝~ 今天有什么可以帮你的吗？',
        'happy',
        (strftime('%s', 'now') * 1000)
    );
