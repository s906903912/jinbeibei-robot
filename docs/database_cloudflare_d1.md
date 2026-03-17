# Cloudflare D1 数据库集成方案

## 📊 数据库选型

**Cloudflare D1** - 基于 SQLite 的无服务器数据库

**优势：**
- ✅ 免费额度充足（5GB 存储、500 万次读取/月）
- ✅ 无需管理服务器
- ✅ 全球边缘节点加速
- ✅ 与 Cloudflare Workers 无缝集成
- ✅ SQL 兼容，开发简单

**对比方案：**

| 方案 | 成本 | 运维 | 性能 | 推荐度 |
|------|------|------|------|--------|
| **Cloudflare D1** | 免费 | 无 | ⭐⭐⭐⭐ | ⭐⭐⭐⭐⭐ |
| SQLite (本地) | 免费 | 自行备份 | ⭐⭐⭐ | ⭐⭐⭐ |
| MySQL (云端) | ¥20+/月 | 需要管理 | ⭐⭐⭐⭐ | ⭐⭐⭐ |
| MongoDB Atlas | 免费额度有限 | 无 | ⭐⭐⭐⭐ | ⭐⭐⭐⭐ |

---

## 🏗️ 数据库设计

### 表结构

#### 1. 设备表 (devices)

```sql
CREATE TABLE devices (
    id TEXT PRIMARY KEY,
    name TEXT NOT NULL DEFAULT '金贝贝',
    type TEXT NOT NULL DEFAULT 'esp32-s3',
    status TEXT NOT NULL DEFAULT 'offline',
    last_seen INTEGER,
    ip_address TEXT,
    firmware_version TEXT,
    created_at INTEGER NOT NULL,
    updated_at INTEGER NOT NULL
);
```

#### 2. 用户表 (users)

```sql
CREATE TABLE users (
    id TEXT PRIMARY KEY,
    username TEXT UNIQUE NOT NULL,
    email TEXT,
    created_at INTEGER NOT NULL,
    updated_at INTEGER NOT NULL
);
```

#### 3. 设备 - 用户关联表 (device_users)

```sql
CREATE TABLE device_users (
    user_id TEXT NOT NULL,
    device_id TEXT NOT NULL,
    role TEXT NOT NULL DEFAULT 'owner',
    created_at INTEGER NOT NULL,
    PRIMARY KEY (user_id, device_id),
    FOREIGN KEY (user_id) REFERENCES users(id),
    FOREIGN KEY (device_id) REFERENCES devices(id)
);
```

#### 4. 闹钟表 (alarms)

```sql
CREATE TABLE alarms (
    id TEXT PRIMARY KEY,
    device_id TEXT NOT NULL,
    user_id TEXT NOT NULL,
    time TEXT NOT NULL,
    enabled INTEGER NOT NULL DEFAULT 1,
    repeat_days TEXT,  -- JSON 数组：["mon","tue","wed"]
    label TEXT,
    sound TEXT DEFAULT 'default',
    created_at INTEGER NOT NULL,
    updated_at INTEGER NOT NULL,
    FOREIGN KEY (device_id) REFERENCES devices(id),
    FOREIGN KEY (user_id) REFERENCES users(id)
);
```

#### 5. 对话历史表 (chat_messages)

```sql
CREATE TABLE chat_messages (
    id TEXT PRIMARY KEY,
    device_id TEXT NOT NULL,
    user_id TEXT,
    role TEXT NOT NULL,  -- 'user' or 'assistant'
    content TEXT NOT NULL,
    emotion TEXT,
    created_at INTEGER NOT NULL,
    FOREIGN KEY (device_id) REFERENCES devices(id),
    FOREIGN KEY (user_id) REFERENCES users(id)
);

-- 创建索引加速查询
CREATE INDEX idx_chat_device ON chat_messages(device_id, created_at DESC);
```

#### 6. 设备状态表 (device_states)

```sql
CREATE TABLE device_states (
    device_id TEXT PRIMARY KEY,
    volume INTEGER DEFAULT 70,
    brightness INTEGER DEFAULT 80,
    current_emotion TEXT DEFAULT 'happy',
    wifi_ssid TEXT,
    wifi_strength INTEGER,
    battery_level INTEGER,
    is_charging INTEGER DEFAULT 0,
    updated_at INTEGER NOT NULL,
    FOREIGN KEY (device_id) REFERENCES devices(id)
);
```

---

## 🔧 集成方式

### 方案一：Cloudflare Workers + D1（推荐）⭐

**架构：**
```
Node.js 服务器 → HTTP API → Cloudflare Workers → D1 数据库
```

**优势：**
- 完全无服务器架构
- 自动扩展
- 免费额度充足

**实现步骤：**

1. **创建 Workers 项目**
```bash
npm create cloudflare@latest jinbeibei-worker
```

2. **配置 wrangler.toml**
```toml
name = "jinbeibei-worker"
main = "src/index.js"
compatibility_date = "2024-01-01"

[[d1_databases]]
binding = "DB"
database_name = "jinbeibei-db"
database_id = "your-database-id"
```

3. **创建数据库**
```bash
wrangler d1 create jinbeibei-db
wrangler d1 execute jinbeibei-db --file=sql/schema.sql
```

4. **部署 Workers**
```bash
wrangler deploy
```

---

### 方案二：Node.js 直接连接（备选）

使用 `@cloudflare/d1-client` 库：

```bash
npm install @cloudflare/d1-client
```

```javascript
const { D1Client } = require('@cloudflare/d1-client');

const client = new D1Client({
  databaseId: 'your-database-id',
  accountId: 'your-account-id',
  apiToken: 'your-api-token'
});

const result = await client.prepare('SELECT * FROM devices').all();
```

---

## 📝 代码示例

### 设备管理 DAO

```javascript
// src/dao/device-dao.js

class DeviceDAO {
  constructor(db) {
    this.db = db;
  }

  async create(device) {
    const stmt = this.db.prepare(`
      INSERT INTO devices (id, name, type, status, created_at, updated_at)
      VALUES (?, ?, ?, ?, ?, ?)
    `);
    
    await stmt.bind(
      device.id,
      device.name || '金贝贝',
      device.type || 'esp32-s3',
      'offline',
      Date.now(),
      Date.now()
    ).run();
  }

  async findById(id) {
    const stmt = this.db.prepare('SELECT * FROM devices WHERE id = ?');
    return await stmt.bind(id).first();
  }

  async updateStatus(id, status) {
    const stmt = this.db.prepare(`
      UPDATE devices 
      SET status = ?, last_seen = ?, updated_at = ?
      WHERE id = ?
    `);
    
    await stmt.bind(status, Date.now(), Date.now(), id).run();
  }

  async list() {
    const stmt = this.db.prepare('SELECT * FROM devices ORDER BY created_at DESC');
    return await stmt.all();
  }

  async delete(id) {
    const stmt = this.db.prepare('DELETE FROM devices WHERE id = ?');
    await stmt.bind(id).run();
  }
}

module.exports = DeviceDAO;
```

### 闹钟管理 DAO

```javascript
// src/dao/alarm-dao.js

class AlarmDAO {
  constructor(db) {
    this.db = db;
  }

  async create(alarm) {
    const stmt = this.db.prepare(`
      INSERT INTO alarms (id, device_id, user_id, time, enabled, repeat_days, label, sound, created_at, updated_at)
      VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
    `);
    
    await stmt.bind(
      alarm.id,
      alarm.deviceId,
      alarm.userId,
      alarm.time,
      alarm.enabled ? 1 : 0,
      JSON.stringify(alarm.repeat || []),
      alarm.label || '',
      alarm.sound || 'default',
      Date.now(),
      Date.now()
    ).run();
  }

  async findByDevice(deviceId) {
    const stmt = this.db.prepare(`
      SELECT * FROM alarms WHERE device_id = ? ORDER BY time ASC
    `);
    return await stmt.bind(deviceId).all();
  }

  async update(id, updates) {
    const fields = [];
    const values = [];
    
    if (updates.time !== undefined) {
      fields.push('time = ?');
      values.push(updates.time);
    }
    if (updates.enabled !== undefined) {
      fields.push('enabled = ?');
      values.push(updates.enabled ? 1 : 0);
    }
    
    fields.push('updated_at = ?');
    values.push(Date.now());
    values.push(id);
    
    const stmt = this.db.prepare(`
      UPDATE alarms SET ${fields.join(', ')} WHERE id = ?
    `);
    
    await stmt.bind(...values).run();
  }

  async delete(id) {
    const stmt = this.db.prepare('DELETE FROM alarms WHERE id = ?');
    await stmt.bind(id).run();
  }
}

module.exports = AlarmDAO;
```

---

## 🚀 迁移步骤

### 当前状态
- ✅ 使用内存存储（Map）
- ✅ 代码结构清晰，DAO 模式

### 迁移计划

**阶段 1：准备（1 天）**
- [ ] 创建 Cloudflare 账号
- [ ] 创建 D1 数据库
- [ ] 执行建表 SQL

**阶段 2：开发（2 天）**
- [ ] 实现 DeviceDAO
- [ ] 实现 AlarmDAO
- [ ] 实现 ChatMessageDAO
- [ ] 更新路由层调用 DAO

**阶段 3：测试（1 天）**
- [ ] 单元测试
- [ ] 集成测试
- [ ] 性能测试

**阶段 4：部署（1 天）**
- [ ] 部署 Workers
- [ ] 配置环境变量
- [ ] 切换流量

---

## 📊 数据库初始化 SQL

详见：`sql/schema.sql`（待创建）

---

## 🔐 安全考虑

1. **API Token 管理**
   - 使用环境变量存储
   - 定期轮换
   - 最小权限原则

2. **数据备份**
   - D1 自动备份
   - 定期导出 SQL

3. **访问控制**
   - 设备认证
   - 用户权限验证
   - SQL 注入防护（使用参数化查询）

---

## 💰 成本估算

**Cloudflare D1 免费额度：**
- 存储：5 GB
- 读取：500 万次/月
- 写入：100 万次/月
- 删除：10 万次/月

**金贝贝项目预估：**
- 存储：< 100 MB（绰绰有余）
- 读取：~10 万次/月（对话历史查询）
- 写入：~1 万次/月（设备状态更新）

**结论：** 完全在免费额度内！✅

---

## 📚 相关资源

- [Cloudflare D1 文档](https://developers.cloudflare.com/d1/)
- [Workers 文档](https://developers.cloudflare.com/workers/)
- [Wrangler CLI](https://developers.cloudflare.com/workers/wrangler/)

---

*金贝贝 D1 数据库集成方案 - 等待主人提供登录方式后实施！* 🐤💾
