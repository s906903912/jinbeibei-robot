# 🔐 安全配置指南

> 金贝贝项目的敏感信息管理和安全最佳实践

## ⚠️ 重要提示

**敏感信息包括：**
- WiFi 密码
- API Key（Qwen、阿里云等）
- 数据库密码
- Token、Secret
- 私人证书、密钥

**这些信息绝对不能提交到 Git！**

---

## 📁 敏感文件管理

### 固件端（ESP32-S3）

**步骤：**

1. 复制配置模板
```bash
cd firmware/src
cp secrets.h.example secrets.h
```

2. 编辑 `secrets.h` 填写真实配置
```cpp
#define WIFI_SSID      "MyHomeWiFi"
#define WIFI_PASSWORD  "MySecretPassword123"
#define QWEN_API_KEY   "sk-xxxxxxxxxxxxx"
```

3. 验证 .gitignore
```bash
# 确保 secrets.h 不会被提交
git check-ignore src/secrets.h
# 应该输出：src/secrets.h
```

**文件结构：**
```
firmware/src/
├── config.h              # ✅ 可以提交 - 公开配置
├── secrets.h.example     # ✅ 可以提交 - 配置模板
└── secrets.h             # ❌ 禁止提交 - 真实配置
```

---

### 服务器端（Node.js）

**步骤：**

1. 复制环境变量模板
```bash
cd server
cp .env.example .env
```

2. 编辑 `.env` 填写真实配置
```env
PORT=8123
QWEN_API_KEY=sk-xxxxxxxxxxxxx
ALLOWED_ORIGINS=*
```

3. 验证 .gitignore
```bash
# 确保 .env 不会被提交
git check-ignore .env
# 应该输出：.env
```

**文件结构：**
```
server/
├── .env.example          # ✅ 可以提交 - 配置模板
├── .env                  # ❌ 禁止提交 - 真实配置
└── .gitignore            # ✅ 已配置忽略 .env
```

---

### 移动端（Flutter）

Flutter APP 通常不需要敏感配置，但如果有：

**步骤：**

1. 创建 `lib/config/secrets.dart`
```dart
// ⚠️ 此文件不要提交到 Git

class Secrets {
  static const String apiKey = 'YOUR_API_KEY';
  static const String apiSecret = 'YOUR_SECRET';
}
```

2. 更新 `.gitignore`
```gitignore
# Flutter 敏感配置
lib/config/secrets.dart
```

3. 创建模板文件 `lib/config/secrets.dart.example`
```dart
// ✅ 可以提交的模板

class Secrets {
  static const String apiKey = 'YOUR_API_KEY_HERE';
  static const String apiSecret = 'YOUR_SECRET_HERE';
}
```

---

## 🔍 检查清单

### 提交前检查

**每次提交前执行：**

```bash
# 1. 检查是否有敏感文件
git status

# 2. 检查 .gitignore 是否生效
git check-ignore -v <文件名>

# 3. 查看即将提交的内容
git diff --cached

# 4. 搜索可能的敏感信息
grep -r "YOUR_API_KEY\|password\|secret" --include="*.cpp" --include="*.h" --include="*.js" .
```

### 已提交敏感信息怎么办？

**如果发现敏感信息已被提交：**

1. **立即撤销提交**（如果还在本地）
```bash
git reset --soft HEAD~1
# 然后移除敏感文件，重新提交
```

2. **如果已推送到 GitHub：**
   - 立即删除 GitHub 仓库
   - 创建新仓库重新推送
   - **或者**使用 BFG Repo-Cleaner 清理历史
   ```bash
   # 安装 BFG
   brew install bfg
   
   # 清理敏感文件
   bfg --delete-files secrets.h
   bfg --delete-files .env
   
   # 推送清理后的历史
   git push --force
   ```

3. **更换所有泄露的密钥**
   - 修改 WiFi 密码
   - 重新生成 API Key
   - 更新所有相关配置

---

## 🛡️ 最佳实践

### 1. 使用环境变量（服务器端）

```javascript
// ✅ 推荐
const apiKey = process.env.QWEN_API_KEY;

// ❌ 不推荐
const apiKey = 'sk-xxxxxxxxxxxxx';
```

### 2. 使用配置模板

始终提供 `.example` 或 `.template` 文件：
- `.env.example`
- `secrets.h.example`
- `config.json.example`

### 3. 最小权限原则

- API Key 只授予必要的权限
- 使用只读 Token 的地方不用读写 Token
- 定期轮换密钥

### 4. 代码审查

提交前检查：
```bash
# 搜索可能的敏感信息
git diff --cached | grep -i "key\|password\|secret\|token"
```

### 5. 使用 Git 钩子（高级）

创建 `.git/hooks/pre-commit`：
```bash
#!/bin/bash

# 检查是否有敏感文件
if git diff --cached --name-only | grep -q "secrets\.h\|\.env$"; then
    echo "❌ 错误：检测到敏感文件！"
    echo "请勿提交 secrets.h 或 .env 文件"
    exit 1
fi
```

---

## 📋 金贝贝项目敏感文件清单

### ❌ 禁止提交的文件

| 文件 | 位置 | 包含内容 |
|------|------|----------|
| `secrets.h` | `firmware/src/` | WiFi 密码、API Key |
| `.env` | `server/` | Qwen API Key、服务器配置 |
| `secrets.dart` | `app/lib/config/` | APP 密钥（如果有） |
| `*.pem` | 任意位置 | SSL 证书、私钥 |
| `*.key` | 任意位置 | 密钥文件 |

### ✅ 可以提交的文件

| 文件 | 位置 | 说明 |
|------|------|------|
| `secrets.h.example` | `firmware/src/` | 配置模板 |
| `.env.example` | `server/` | 环境变量模板 |
| `config.h` | `firmware/src/` | 公开配置（不含密码） |
| `.gitignore` | 项目根目录 | Git 忽略规则 |

---

## 🚨 安全事件响应

### 发现敏感信息泄露

1. **保持冷静**
2. **立即撤销** - 删除 Git 历史中的敏感文件
3. **更换密钥** - 所有泄露的密码、API Key
4. **检查日志** - 是否有未授权访问
5. **记录事件** - 更新本文档

### 联系方式

发现安全问题请联系：
- GitHub Issues: https://github.com/s906903912/jinbeibei-robot/issues
- 邮件：s906903912@qq.com

---

## 📚 相关资源

- [GitHub - 删除敏感信息](https://docs.github.com/en/authentication/keeping-your-account-and-data-secure/removing-sensitive-data-from-a-repository)
- [BFG Repo-Cleaner](https://rtyley.github.io/bfg-repo-cleaner/)
- [Git .gitignore 文档](https://git-scm.com/docs/gitignore)

---

**安全第一！保护好自己的敏感信息！** 🔐🐤

*最后更新：2026-03-17*
