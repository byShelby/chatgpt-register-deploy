#!/usr/bin/env bash
set -euo pipefail

# 颜色输出
info() { echo -e "\033[1;32m[信息]\033[0m $*"; }
warn() { echo -e "\033[1;33m[警告]\033[0m $*" >&2; }
err() { echo -e "\033[1;31m[错误]\033[0m $*" >&2; }

usage() {
  cat <<'USAGE'
ChatGPT 注册机 - 一键部署脚本

用法：
  curl -sSL https://raw.githubusercontent.com/DouDOU-start/chatgpt-register-deploy/main/install.sh | sudo bash

可选参数：
  --install-dir DIR     安装目录（默认 /opt/chatgpt-register）
  --port PORT          服务端口（默认 8082）
  --api-key KEY        API 密钥（可选）
  --image IMAGE        Docker 镜像（默认 ghcr.io/doudou-start/chatgpt-register:latest）
  --install-docker     自动安装 Docker（如果未安装）
  -h, --help           查看帮助

示例：
  # 使用默认配置安装
  curl -sSL <脚本地址> | sudo bash

  # 自定义端口和 API Key
  curl -sSL <脚本地址> | sudo bash -s -- --port 8080 --api-key "your-key"

  # 自定义安装目录
  curl -sSL <脚本地址> | sudo bash -s -- --install-dir /opt/my-app
USAGE
}

require_root() {
  if [[ ${EUID:-$(id -u)} -ne 0 ]]; then
    err "请使用 sudo 执行该脚本"
    exit 1
  fi
}

need_cmd() {
  command -v "$1" >/dev/null 2>&1
}

install_docker() {
  info "开始安装 Docker..."
  if ! curl -fsSL https://get.docker.com | sh; then
    err "Docker 安装失败"
    exit 1
  fi

  info "启动 Docker 服务..."
  systemctl enable docker
  systemctl start docker
}

check_docker_compose() {
  if docker compose version >/dev/null 2>&1; then
    echo "docker compose"
  elif need_cmd docker-compose; then
    echo "docker-compose"
  else
    err "未检测到 docker compose 命令"
    err "请升级 Docker 或安装 docker-compose 插件"
    exit 1
  fi
}

# 默认配置
INSTALL_DIR="${INSTALL_DIR:-/opt/chatgpt-register}"
PORT="${PORT:-8082}"
API_KEY="${API_KEY:-}"
DOCKER_IMAGE="${DOCKER_IMAGE:-ghcr.io/doudou-start/chatgpt-register:latest}"
INSTALL_DOCKER="${INSTALL_DOCKER:-}"

# 解析参数
while [[ $# -gt 0 ]]; do
  case "$1" in
    --install-dir)
      INSTALL_DIR="$2"
      shift 2
      ;;
    --port)
      PORT="$2"
      shift 2
      ;;
    --api-key)
      API_KEY="$2"
      shift 2
      ;;
    --image)
      DOCKER_IMAGE="$2"
      shift 2
      ;;
    --install-docker)
      INSTALL_DOCKER="1"
      shift
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      err "未知参数: $1"
      usage
      exit 1
      ;;
  esac
done

require_root

# 检查 curl
if ! need_cmd curl; then
  err "未检测到 curl，请先安装"
  exit 1
fi

# 检查并安装 Docker
if ! need_cmd docker; then
  if [[ "$INSTALL_DOCKER" == "1" ]]; then
    install_docker
  else
    err "未检测到 Docker，可使用 --install-docker 自动安装"
    err "或手动安装: curl -fsSL https://get.docker.com | sh"
    exit 1
  fi
fi

# 检查 Docker 服务
if ! docker info >/dev/null 2>&1; then
  err "Docker 服务未运行，请启动 Docker 服务"
  err "运行: sudo systemctl start docker"
  exit 1
fi

# 检查 docker compose
COMPOSE_CMD=$(check_docker_compose)

info "📁 准备安装目录: $INSTALL_DIR"
mkdir -p "$INSTALL_DIR"
cd "$INSTALL_DIR"

# GitHub Raw 文件基础 URL
REPO_BASE_URL="https://raw.githubusercontent.com/DouDOU-start/chatgpt-register-deploy/main"

info "📥 下载配置文件..."
curl -fsSL "${REPO_BASE_URL}/docker-compose.yml" -o docker-compose.yml
curl -fsSL "${REPO_BASE_URL}/config.yaml.example" -o config.yaml.example
curl -fsSL "${REPO_BASE_URL}/.env.example" -o .env.example

# 初始化配置文件
if [[ ! -f config.yaml ]]; then
  info "📝 初始化 config.yaml"
  cp config.yaml.example config.yaml
else
  info "✓ 保留已有的 config.yaml"
fi

if [[ ! -f .env ]]; then
  info "📝 初始化 .env"
  cp .env.example .env
else
  info "✓ 保留已有的 .env"
fi

# 更新环境变量
info "⚙️  配置环境变量..."
sed -i "s|^PORT=.*|PORT=${PORT}|" .env
sed -i "s|^DOCKER_IMAGE=.*|DOCKER_IMAGE=${DOCKER_IMAGE}|" .env

if [[ -n "$API_KEY" ]]; then
  sed -i "s|^API_KEY=.*|API_KEY=${API_KEY}|" .env
  info "✓ 已设置 API_KEY"
fi

# 创建数据和日志目录
info "📂 创建数据和日志目录..."
mkdir -p data logs

# 拉取镜像
info "🐳 拉取 Docker 镜像: $DOCKER_IMAGE"
docker pull "$DOCKER_IMAGE"

# 停止旧容器（如果存在）
if docker ps -a --format '{{.Names}}' | grep -q '^chatgpt-register$'; then
  info "🛑 停止旧容器..."
  $COMPOSE_CMD down
fi

# 启动服务
info "🚀 启动服务..."
$COMPOSE_CMD up -d

# 等待服务启动
info "⏳ 等待服务启动..."
sleep 3

# 检查服务状态
if docker ps --format '{{.Names}}' | grep -q '^chatgpt-register$'; then
  info ""
  info "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  info "✅ 安装完成！"
  info "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  info ""
  info "📁 安装目录: $INSTALL_DIR"
  info "🌐 访问地址: http://<服务器IP>:${PORT}"
  info "📝 配置文件: $INSTALL_DIR/config.yaml"
  info "📊 数据目录: $INSTALL_DIR/data"
  info "📋 日志目录: $INSTALL_DIR/logs"
  info ""
  info "常用命令:"
  info "  查看日志: cd $INSTALL_DIR && $COMPOSE_CMD logs -f"
  info "  重启服务: cd $INSTALL_DIR && $COMPOSE_CMD restart"
  info "  停止服务: cd $INSTALL_DIR && $COMPOSE_CMD down"
  info "  更新服务: cd $INSTALL_DIR && docker pull $DOCKER_IMAGE && $COMPOSE_CMD up -d"
  info ""
else
  err "❌ 服务启动失败"
  err "请查看日志: cd $INSTALL_DIR && $COMPOSE_CMD logs"
  exit 1
fi
