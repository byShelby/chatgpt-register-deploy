#!/usr/bin/env bash
# 快速配置部署仓库（使用 GitHub Container Registry）

set -euo pipefail

echo "🔧 部署仓库配置工具"
echo ""
echo "ℹ️  本项目使用 GitHub Container Registry (ghcr.io)"
echo "   无需 Docker Hub 账号，镜像将推送到:"
echo "   ghcr.io/doudou-start/chatgpt-register"
echo ""

# 获取 GitHub 用户名
read -p "请确认你的 GitHub 用户名 [DouDOU-start]: " GITHUB_USERNAME
GITHUB_USERNAME=${GITHUB_USERNAME:-DouDOU-start}

if [[ -z "$GITHUB_USERNAME" ]]; then
  echo "❌ GitHub 用户名不能为空"
  exit 1
fi

# 转换为小写（GitHub Container Registry 使用小写）
GITHUB_USERNAME_LOWER=$(echo "$GITHUB_USERNAME" | tr '[:upper:]' '[:lower:]')

echo ""
echo "📝 将要配置:"
echo "  - GitHub 用户名: $GITHUB_USERNAME"
echo "  - 镜像地址: ghcr.io/$GITHUB_USERNAME_LOWER/chatgpt-register"
echo ""
read -p "确认继续? (y/n): " CONFIRM

if [[ "$CONFIRM" != "y" && "$CONFIRM" != "Y" ]]; then
  echo "❌ 已取消"
  exit 0
fi

echo ""
echo "🔄 开始配置..."

# 替换 GitHub 用户名（保持原始大小写）
if [[ "$GITHUB_USERNAME" != "DouDOU-start" ]]; then
  find . -type f \( -name "*.sh" -o -name "*.md" -o -name "*.yml" -o -name ".env.example" \) \
    -exec sed -i.bak "s/DouDOU-start/$GITHUB_USERNAME/g" {} +
  echo "✓ 已更新 GitHub 用户名"
fi

# 替换镜像地址（使用小写）
if [[ "$GITHUB_USERNAME_LOWER" != "doudou-start" ]]; then
  find . -type f \( -name "*.sh" -o -name "*.md" -o -name "*.yml" -o -name ".env.example" \) \
    -exec sed -i.bak "s/doudou-start/$GITHUB_USERNAME_LOWER/g" {} +
  echo "✓ 已更新镜像地址"
fi

# 删除备份文件
find . -type f -name "*.bak" -delete

echo "✅ 配置完成!"
echo ""
echo "📋 下一步:"
echo "  1. 检查文件内容: cat .env.example docker-compose.yml"
echo "  2. 提交到 Git: git add . && git commit -m '更新配置'"
echo "  3. 推送到 GitHub: git push"
echo ""
echo "🐳 镜像将推送到: ghcr.io/$GITHUB_USERNAME_LOWER/chatgpt-register"
