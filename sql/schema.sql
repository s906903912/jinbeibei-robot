-- 金贝贝桌面精灵 - Cloudflare D1 数据库架构
-- JinBeibei Desktop Pet - D1 Database Schema

-- 版本：0.1.0
-- 日期：2026-03-17

-- ==================== 设备表 ====================

CREATE TABLE IF NOT EXISTS devices (
    id TEXT PRIMARY KEY,
    name TEXT NOT NULL DEFAULT '金贝贝',
    type TEXT NOT NULL DEFAULT 'esp32-s3',
    status TEXT NOT NULL DEFAULT 'offline',  -- online, offline, sleeping
    last_seen INTEGER,  -- Unix timestamp (ms)
    ip_address TEXT,
    firmware_version TEXT DEFAULT '0.1.0',
    created_at INTEGER NOT NULL,
    updated_at INTEGER NOT NULL
);

-- ==================== 用户表 ====================

CREATE TABLE IF NOT EXISTS users (
    id TEXT PRIMARY KEY,
    username TEXT UNIQUE NOT NULL,
    email TEXT,
    avatar_url TEXT,
    created_at INTEGER NOT NULL,
    updated_at INTEGER NOT NULL
);

-- ==================== 设备 - 用户关联表 ====================

CREATE TABLE IF NOT EXISTS device_users (
    user_id TEXT NOT NULL,
    device_id TEXT NOT NULL,
    role TEXT NOT NULL DEFAULT 'owner',  -- owner, admin, viewer
    created_at INTEGER NOT NULL,
    PRIMARY KEY (user_id, device_id),
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (device_id) REFERENCES devices(id) ON DELETE CASCADE
);

-- ==================== 闹钟表 ====================

CREATE TABLE IF NOT EXISTS alarms (
    id TEXT PRIMARY KEY,
    device_id TEXT NOT NULL,
    user_id TEXT NOT NULL,
    time TEXT NOT NULL,  -- HH:mm 格式
    enabled INTEGER NOT NULL DEFAULT 1,  -- 0=disabled, 1=enabled
    repeat_days TEXT,  -- JSON 数组：["mon","tue","wed","thu","fri","sat","sun"]
    label TEXT,
    sound TEXT DEFAULT 'default',
    snooze_enabled INTEGER DEFAULT 0,
    snooze_minutes INTEGER DEFAULT 5,
    created_at INTEGER NOT NULL,
    updated_at INTEGER NOT NULL,
    FOREIGN KEY (device_id) REFERENCES devices(id) ON DELETE CASCADE,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
);

CREATE INDEX IF NOT EXISTS idx_alarms_device ON alarms(device_id, time ASC);
CREATE INDEX IF NOT EXISTS idx_alarms_user ON alarms(user_id);

-- ==================== 对话历史表 ====================

CREATE TABLE IF NOT EXISTS chat_messages (
    id TEXT PRIMARY KEY,
    device_id TEXT NOT NULL,
    user_id TEXT,
    role TEXT NOT NULL,  -- 'user', 'assistant', 'system'
    content TEXT NOT NULL,
    emotion TEXT,  -- happy, sad, angry, sleepy, excited, caring
    tokens INTEGER,
    created_at INTEGER NOT NULL,
    FOREIGN KEY (device_id) REFERENCES devices(id) ON DELETE CASCADE,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE SET NULL
);

CREATE INDEX IF NOT EXISTS idx_chat_device ON chat_messages(device_id, created_at DESC);
CREATE INDEX IF NOT EXISTS idx_chat_user ON chat_messages(user_id, created_at DESC);
CREATE INDEX IF NOT EXISTS idx_chat_created ON chat_messages(created_at DESC);

-- ==================== 设备状态表 ====================

CREATE TABLE IF NOT EXISTS device_states (
    device_id TEXT PRIMARY KEY,
    volume INTEGER DEFAULT 70,  -- 0-100
    brightness INTEGER DEFAULT 80,  -- 0-100
    current_emotion TEXT DEFAULT 'happy',
    wifi_ssid TEXT,
    wifi_strength INTEGER,  -- dBm
    battery_level INTEGER,  -- 0-100 (如果有电池)
    is_charging INTEGER DEFAULT 0,  -- 0=no, 1=yes
    temperature REAL,  -- CPU 温度
    uptime_seconds INTEGER DEFAULT 0,
    updated_at INTEGER NOT NULL,
    FOREIGN KEY (device_id) REFERENCES devices(id) ON DELETE CASCADE
);

-- ==================== 系统配置表 ====================

CREATE TABLE IF NOT EXISTS system_config (
    key TEXT PRIMARY KEY,
    value TEXT NOT NULL,
    description TEXT,
    updated_at INTEGER NOT NULL
);

-- ==================== 操作日志表 ====================

CREATE TABLE IF NOT EXISTS audit_logs (
    id TEXT PRIMARY KEY,
    user_id TEXT,
    device_id TEXT,
    action TEXT NOT NULL,  -- create, update, delete, login, etc.
    resource_type TEXT,  -- device, alarm, chat, etc.
    resource_id TEXT,
    details TEXT,  -- JSON
    ip_address TEXT,
    created_at INTEGER NOT NULL,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE SET NULL,
    FOREIGN KEY (device_id) REFERENCES devices(id) ON DELETE SET NULL
);

CREATE INDEX IF NOT EXISTS idx_logs_user ON audit_logs(user_id, created_at DESC);
CREATE INDEX IF NOT EXISTS idx_logs_device ON audit_logs(device_id, created_at DESC);
CREATE INDEX IF NOT EXISTS idx_logs_created ON audit_logs(created_at DESC);

-- ==================== 初始数据 ====================

-- 插入默认系统配置
INSERT OR IGNORE INTO system_config (key, value, description, updated_at) VALUES
    ('version', '0.1.0', '数据库版本', strftime('%s', 'now') * 1000),
    ('created_at', datetime('now'), '系统创建时间', strftime('%s', 'now') * 1000),
    ('max_alarms_per_device', '10', '每个设备最大闹钟数', strftime('%s', 'now') * 1000),
    ('chat_history_days', '30', '对话历史保留天数', strftime('%s', 'now') * 1000);

-- ==================== 视图 ====================

-- 设备详细信息视图
CREATE VIEW IF NOT EXISTS device_details AS
SELECT 
    d.id,
    d.name,
    d.type,
    d.status,
    d.last_seen,
    d.ip_address,
    d.firmware_version,
    ds.volume,
    ds.brightness,
    ds.current_emotion,
    ds.wifi_strength,
    ds.is_charging,
    d.created_at,
    d.updated_at
FROM devices d
LEFT JOIN device_states ds ON d.id = ds.device_id;

-- 闹钟详细信息视图
CREATE VIEW IF NOT EXISTS alarm_details AS
SELECT 
    a.id,
    a.device_id,
    a.user_id,
    a.time,
    a.enabled,
    a.repeat_days,
    a.label,
    a.sound,
    d.name as device_name,
    u.username as user_name,
    a.created_at,
    a.updated_at
FROM alarms a
LEFT JOIN devices d ON a.device_id = d.id
LEFT JOIN users u ON a.user_id = u.id;

-- ==================== 备注 ====================

-- 时间戳统一使用 Unix timestamp (毫秒)
-- JSON 字段使用 TEXT 类型存储
-- 所有表都包含 created_at 和 updated_at 字段
-- 外键约束使用 ON DELETE CASCADE 或 ON DELETE SET NULL

-- 数据库设计原则：
-- 1. 简单优先，避免过度设计
-- 2. 预留扩展字段
-- 3. 使用索引优化查询
-- 4. 审计日志记录重要操作
