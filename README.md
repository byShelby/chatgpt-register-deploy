# ChatGPT 注册机 - 部署指南

> 🚀 ChatGPT 账号自动注册与管理服务 - 一键部署版

## 📋 目录

- [快速开始](#快速开始)
- [系统要求](#系统要求)
- [安装步骤](#安装步骤)
- [配置说明](#配置说明)
- [常用命令](#常用命令)
- [更新升级](#更新升级)
- [故障排查](#故障排查)
- [目录结构](#目录结构)

---

## ⚡ 快速开始

### 一键安装

```bash
curl -sSL https://raw.githubusercontent.com/DouDOU-start/chatgpt-register-deploy/main/install.sh | sudo bash
```

安装完成后访问: `http://<服务器IP>:8082`

### 自定义安装

```bash
# 自定义端口
curl -sSL https://raw.githubusercontent.com/DouDOU-start/chatgpt-register-deploy/main/install.sh | \
  sudo bash -s -- --port 8080

# 自定义安装目录和 API Key
curl -sSL https://raw.githubusercontent.com/DouDOU-start/chatgpt-register-deploy/main/install.sh | \
  sudo bash -s -- --install-dir /opt/my-app --api-key "your-secret-key"

# 自动安装 Docker
curl -sSL https://raw.githubusercontent.com/DouDOU-start/chatgpt-register-deploy/main/install.sh | \
  sudo bash -s -- --install-docker
```

---

## 💻 系统要求

### 最低配置

- **操作系统**: Linux (Ubuntu 20.04+, Debian 10+, CentOS 7+)
- **CPU**: 2 核
- **内存**: 2 GB
- **磁盘**: 10 GB
- **Docker**: 20.10+ (脚本可自动安装)

### 推荐配置

- **CPU**: 4 核+
- **内存**: 4 GB+
- **磁盘**: 20 GB+ SSD

---

## 📦 安装步骤

### 1. 准备服务器

确保服务器可以访问互联网，并开放所需端口(默认 8082)。

### 2. 运行安装脚本

```bash
curl -sSL https://raw.githubusercontent.com/DouDOU-start/chatgpt-register-deploy/main/install.sh | sudo bash
```

### 3. 等待安装完成

脚本会自动完成以下步骤:
- ✅ 检查并安装 Docker(如需要)
- ✅ 创建安装目录 `/opt/chatgpt-register`
- ✅ 下载配置文件模板
- ✅ 拉取 Docker 镜像
- ✅ 启动服务

### 4. 访问服务

```
http://<服务器IP>:8082
```

---

## ⚙️ 配置说明

安装后，所有配置文件位于 `/opt/chatgpt-register/` 目录:

### 环境变量配置 (`.env`)

```bash
# 编辑环境变量
sudo nano /opt/chatgpt-register/.env
```

**主要配置项**:

```env
# Docker 镜像（通常无需修改）
DOCKER_IMAGE=ghcr.io/doudou-start/chatgpt-register:latest

# 服务端口
PORT=8082

# API Key（强烈建议设置，用于保护 API 访问）
API_KEY=your-secret-key-here

# 电话验证码 API（可选）
PHONE_API_KEY_SMS_ACTIVATE=your-sms-activate-key
PHONE_API_KEY_5SIM=your-5sim-key
```

### 应用配置 (`config.yaml`)

```bash
# 编辑应用配置
sudo nano /opt/chatgpt-register/config.yaml
```

**主要配置项**:

```yaml
# Docker 主机配置（支持分布式部署）
docker_hosts:
  - name: 本地 Docker
    url: unix:///var/run/docker.sock
    max_containers: 2

# 浏览器镜像
browser_image: chromedp/headless-shell:latest

# 数据库备份
backup:
  directory: /app/data/backups
  auto_backup_interval: 86400  # 24小时
  keep_days: 7
```

### 应用配置后重启

```bash
cd /opt/chatgpt-register
sudo docker compose restart
```

---

## 🔧 常用命令

### 服务管理

```bash
# 进入安装目录
cd /opt/chatgpt-register

# 查看服务状态
sudo docker compose ps

# 查看实时日志
sudo docker compose logs -f

# 重启服务
sudo docker compose restart

# 停止服务
sudo docker compose down

# 启动服务
sudo docker compose up -d
```

### 数据管理

```bash
# 查看数据文件
ls -lh /opt/chatgpt-register/data/

# 查看日志文件
tail -f /opt/chatgpt-register/logs/chatgpt-register.log

# 手动备份数据库
cp /opt/chatgpt-register/data/chatgpt.db /backup/chatgpt.db.$(date +%Y%m%d)
```

### 容器管理

```bash
# 进入容器
sudo docker exec -it chatgpt-register sh

# 查看容器资源占用
sudo docker stats chatgpt-register

# 查看容器详细信息
sudo docker inspect chatgpt-register
```

---

## 🔄 更新升级

### 方式一: 使用脚本自动更新

```bash
cd /opt/chatgpt-register
sudo docker pull ghcr.io/doudou-start/chatgpt-register:latest
sudo docker compose up -d
```

### 方式二: 重新运行安装脚本

```bash
curl -sSL https://raw.githubusercontent.com/DouDOU-start/chatgpt-register-deploy/main/install.sh | sudo bash
```

> **注意**: 重新安装会保留现有的 `config.yaml` 和 `.env` 配置，不会丢失数据。

### 指定版本更新

```bash
cd /opt/chatgpt-register

# 编辑 .env 修改镜像版本
sudo nano .env
# 将 DOCKER_IMAGE 改为: ghcr.io/doudou-start/chatgpt-register:v1.2.0

# 拉取并重启
sudo docker compose pull
sudo docker compose up -d
```

---

## 🔍 故障排查

### 1. 服务无法启动

**检查 Docker 服务**:
```bash
sudo systemctl status docker
sudo systemctl start docker
```

**查看容器日志**:
```bash
cd /opt/chatgpt-register
sudo docker compose logs
```

### 2. 端口占用

**检查端口占用**:
```bash
sudo lsof -i :8082
```

**更换端口**:
```bash
# 编辑 .env 修改 PORT
sudo nano /opt/chatgpt-register/.env

# 重启服务
cd /opt/chatgpt-register
sudo docker compose down
sudo docker compose up -d
```

### 3. 无法访问服务

**检查防火墙**:
```bash
# Ubuntu/Debian
sudo ufw allow 8082/tcp

# CentOS/RHEL
sudo firewall-cmd --add-port=8082/tcp --permanent
sudo firewall-cmd --reload
```

**检查服务监听**:
```bash
sudo netstat -tlnp | grep 8082
```

### 4. 浏览器容器无法启动

**检查 Docker socket 权限**:
```bash
sudo chmod 666 /var/run/docker.sock
```

**检查 Docker 主机配置**:
```bash
sudo nano /opt/chatgpt-register/config.yaml
# 确保 docker_hosts[0].url 正确
```

### 5. 数据丢失

**恢复备份**:
```bash
# 查看备份文件
ls -lh /opt/chatgpt-register/data/backups/

# 恢复备份（先停止服务）
cd /opt/chatgpt-register
sudo docker compose down
cp data/backups/chatgpt_backup_20260207.db data/chatgpt.db
sudo docker compose up -d
```

---

## 📁 目录结构

```
/opt/chatgpt-register/
├── docker-compose.yml    # Docker Compose 配置
├── config.yaml           # 应用配置文件
├── .env                  # 环境变量配置
├── data/                 # 数据目录
│   ├── chatgpt.db       # SQLite 数据库
│   └── backups/         # 自动备份
│       ├── chatgpt_backup_20260207.db
│       └── ...
└── logs/                 # 日志目录
    └── chatgpt-register.log
```

---

## 🛡️ 安全建议

1. **设置 API Key**: 编辑 `.env` 文件，配置 `API_KEY` 保护 API 访问
2. **配置防火墙**: 只开放必要端口(如 8082)
3. **定期备份**: 备份文件位于 `data/backups/`，建议异地备份
4. **及时更新**: 定期拉取最新镜像，修复安全漏洞
5. **最小权限**: 使用非 root 用户运行应用(已在容器内实现)

---

## 📞 支持与反馈

- **问题反馈**: [GitHub Issues](https://github.com/DouDOU-start/chatgpt-register-deploy/issues)
- **使用文档**: [在线文档](https://github.com/DouDOU-start/chatgpt-register-deploy)

---

## 📄 许可证

本项目仅供学习和研究使用。请遵守 OpenAI 服务条款。

---

**🎉 祝你使用愉快！**
