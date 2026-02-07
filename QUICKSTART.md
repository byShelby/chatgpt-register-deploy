# 🚀 快速开始指南

## 已完成的配置

✅ 所有占位符已自动替换:
- GitHub 用户名: `DouDOU-start`
- Docker 镜像: `ghcr.io/doudou-start/chatgpt-register:latest`

✅ 使用 GitHub Container Registry (ghcr.io):
- 无需 Docker Hub 账号
- 免费且无限额
- 与 GitHub 仓库完美集成

---

## 📋 下一步操作

### 1️⃣ 首次构建镜像（在源码仓库）

```bash
cd /Users/huangenjun/code/chatgpt-register

# 方式一: 通过 GitHub Actions 手动触发
# 进入仓库 → Actions → "构建 Docker 镜像" → Run workflow

# 方式二: 打标签自动触发（推荐）
git tag v1.0.0
git push origin v1.0.0
```

等待 GitHub Actions 完成构建，然后:
1. 进入仓库 Packages 页面
2. 找到 `chatgpt-register` 包
3. 设置为 **Public** (Package settings → Change visibility)

### 2️⃣ 创建部署仓库

在 GitHub 创建新仓库:
- 仓库名: `chatgpt-register-deploy`
- 可见性: **Public**
- 不初始化 README

```bash
cd /Users/huangenjun/code/chatgpt-register/deploy-repo

# 初始化并推送
git init
git add .
git commit -m "初始化部署仓库"
git remote add origin https://github.com/DouDOU-start/chatgpt-register-deploy.git
git branch -M main
git push -u origin main
```

### 3️⃣ 测试部署（在测试服务器）

```bash
# 一键安装
curl -sSL https://raw.githubusercontent.com/DouDOU-start/chatgpt-register-deploy/main/install.sh | sudo bash

# 检查服务
sudo docker ps
sudo docker logs chatgpt-register
curl http://localhost:8082/health
```

---

## 📂 文件说明

### 部署仓库文件 ([deploy-repo/](deploy-repo/))

| 文件 | 说明 |
|------|------|
| **install.sh** | 一键安装脚本，用户执行此脚本即可部署 |
| **docker-compose.yml** | 容器编排配置，使用 ghcr.io 镜像 |
| **config.yaml.example** | 应用配置示例 |
| **.env.example** | 环境变量示例 |
| **README.md** | 用户文档（安装、配置、故障排查） |
| **DEPLOY_GUIDE.md** | 开发者部署指南（本文档的详细版） |
| **setup.sh** | 配置工具（如需更改用户名） |

### 源码仓库新增文件

| 文件 | 说明 |
|------|------|
| [.github/workflows/build-image.yml](.github/workflows/build-image.yml) | 自动构建 Docker 镜像的 CI 流程 |
| [.env.example](.env.example) | 更新的环境变量配置 |

---

## 🎯 用户使用流程

用户只需要一行命令:

```bash
curl -sSL https://raw.githubusercontent.com/DouDOU-start/chatgpt-register-deploy/main/install.sh | sudo bash
```

安装后,所有文件在 `/opt/chatgpt-register/`:
```
/opt/chatgpt-register/
├── docker-compose.yml
├── config.yaml
├── .env
├── data/           # SQLite 数据库
│   └── backups/    # 自动备份
└── logs/           # 应用日志
```

---

## 🔄 日常维护

### 发布新版本

```bash
cd /Users/huangenjun/code/chatgpt-register
git tag v1.1.0
git push origin v1.1.0
```

GitHub Actions 自动构建并推送:
- `ghcr.io/doudou-start/chatgpt-register:v1.1.0`
- `ghcr.io/doudou-start/chatgpt-register:latest`

### 用户升级

```bash
cd /opt/chatgpt-register
sudo docker pull ghcr.io/doudou-start/chatgpt-register:latest
sudo docker compose up -d
```

---

## 🔒 镜像访问控制

### 当前配置: 公开镜像（推荐）
- 用户无需认证即可拉取
- 适合免费分发

### 如需私有镜像
1. 保持 Package 为 Private
2. 用户需要登录:
   ```bash
   echo $GITHUB_TOKEN | docker login ghcr.io -u DouDOU-start --password-stdin
   ```

---

## ❓ 常见问题

**Q: 如何查看构建的镜像?**
- 访问: https://github.com/DouDOU-start/chatgpt-register/pkgs/container/chatgpt-register

**Q: 镜像拉取失败?**
- 确保镜像设置为 Public
- 检查网络连接

**Q: 如何指定特定版本?**
```bash
# 编辑 .env
DOCKER_IMAGE=ghcr.io/doudou-start/chatgpt-register:v1.0.0
```

---

## 📚 详细文档

- **用户使用文档**: [deploy-repo/README.md](deploy-repo/README.md)
- **开发者部署指南**: [deploy-repo/DEPLOY_GUIDE.md](deploy-repo/DEPLOY_GUIDE.md)

---

## ✅ 检查清单

部署前请确认:

- [ ] GitHub Actions workflow 可以运行
- [ ] 成功构建并推送第一个镜像到 ghcr.io
- [ ] 镜像已设置为 Public
- [ ] 部署仓库已创建并推送
- [ ] 在测试服务器验证安装流程
- [ ] 文档中的所有 URL 正确
- [ ] 准备好向用户发布

---

**🎉 祝你部署顺利！**
