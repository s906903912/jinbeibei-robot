#!/bin/bash

# 金贝贝项目 - 敏感信息检查脚本
# 用于验证敏感文件是否正确配置，确保不会泄露

echo "╔════════════════════════════════════════╗"
echo "║   金贝贝 - 敏感信息检查工具            ║"
echo "╚════════════════════════════════════════╝"
echo ""

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

ERRORS=0
WARNINGS=0

# 检查固件端配置
echo "📌 检查固件端配置..."
if [ -f "src/secrets.h" ]; then
    echo -e "${GREEN}✓${NC} src/secrets.h 存在"
    
    # 检查是否包含占位符
    if grep -q "YOUR_WIFI_SSID" src/secrets.h; then
        echo -e "${YELLOW}⚠${NC} 警告：secrets.h 中仍有占位符，请替换为真实配置"
        ((WARNINGS++))
    else
        echo -e "${GREEN}✓${NC} secrets.h 已配置"
    fi
else
    echo -e "${YELLOW}⚠${NC} src/secrets.h 不存在，请复制 secrets.h.example 并配置"
    ((WARNINGS++))
fi

# 检查 .gitignore 是否忽略 secrets.h
if grep -q "secrets.h" .gitignore; then
    echo -e "${GREEN}✓${NC} secrets.h 已在 .gitignore 中"
else
    echo -e "${RED}✗${NC} 错误：secrets.h 未加入 .gitignore！"
    ((ERRORS++))
fi

echo ""

# 检查服务器端配置
echo "📌 检查服务器端配置..."
cd server 2>/dev/null || {
    echo -e "${RED}✗${NC} 错误：找不到 server 目录"
    ((ERRORS++))
    cd ..
}

if [ -f ".env" ]; then
    echo -e "${GREEN}✓${NC} server/.env 存在"
    
    # 检查是否包含占位符
    if grep -q "your_qwen_api_key_here" .env; then
        echo -e "${YELLOW}⚠${NC} 警告：.env 中仍有占位符，请替换为真实 API Key"
        ((WARNINGS++))
    else
        echo -e "${GREEN}✓${NC} .env 已配置"
    fi
else
    echo -e "${YELLOW}⚠${NC} server/.env 不存在，请复制 .env.example 并配置"
    ((WARNINGS++))
fi

# 检查 .gitignore 是否忽略 .env
if grep -q "^\.env$" .gitignore || grep -q "\.env$" ../.gitignore; then
    echo -e "${GREEN}✓${NC} .env 已在 .gitignore 中"
else
    echo -e "${RED}✗${NC} 错误：.env 未加入 .gitignore！"
    ((ERRORS++))
fi

cd ..

echo ""

# 检查 Git 状态
echo "📌 检查 Git 状态..."
if git diff --cached --name-only | grep -q "secrets.h\|\.env$"; then
    echo -e "${RED}✗${NC} 错误：检测到敏感文件即将被提交！"
    echo "   请执行：git reset HEAD <文件名>"
    ((ERRORS++))
else
    echo -e "${GREEN}✓${NC} 没有敏感文件即将被提交"
fi

# 检查是否有敏感文件已跟踪
if git ls-files | grep -q "secrets.h\|\.env$"; then
    echo -e "${RED}✗${NC} 错误：敏感文件已在 Git 跟踪中！"
    echo "   请执行以下命令移除："
    echo "   git rm --cached src/secrets.h"
    echo "   git rm --cached server/.env"
    ((ERRORS++))
else
    echo -e "${GREEN}✓${NC} Git 未跟踪敏感文件"
fi

echo ""
echo "═══════════════════════════════════════"

if [ $ERRORS -gt 0 ]; then
    echo -e "${RED}❌ 发现 $ERRORS 个错误，请先修复！${NC}"
    exit 1
elif [ $WARNINGS -gt 0 ]; then
    echo -e "${YELLOW}⚠️  发现 $WARNINGS 个警告，建议检查配置${NC}"
    exit 0
else
    echo -e "${GREEN}✅ 所有检查通过！可以安全提交代码${NC}"
    exit 0
fi
