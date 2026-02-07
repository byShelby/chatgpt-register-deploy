# 部署仓库创建指南

本文档指导你如何完成从私有源码仓库到公开部署仓库的完整流程。

## 📋 部署流程概览

```
私有源码仓库 → 构建 Docker 镜像 → 推送到 GitHub Container Registry → 公开部署仓库 → 用户一键安装
```

---

## 🚀 第一步: 启用 GitHub Container Registry

### 1. 无需额外配置

GitHub Container Registry (ghcr.io) 是 GitHub 提供的免费容器镜像服务:
- ✅ 与 GitHub 仓库集成
- ✅ 支持私有和公开镜像
- ✅ 免费且无限额
- ✅ 无需注册额外账号

### 2. 确保仓库权限

GitHub Actions 默认有推送镜像的权限,无需额外配置。

---

## 📦 第二步: 构建并推送镜像

### 方式一: 手动触发 (推荐测试)

1. 进入私有源码仓库 Actions 页面
2. 选择 "构建 Docker 镜像" workflow
3. 点击 "Run workflow"
4. 选择分支 (如 `main`)
5. 输入镜像标签 (留空则使用 `latest`)
6. 点击 "Run workflow"

### 方式二: 通过 Git Tag 自动触发

```bash
# 在本地仓库打标签
cd /Users/huangenjun/code/chatgpt-register
git tag v1.0.0
git push origin v1.0.0
```

GitHub Actions 会自动:
- 构建 amd64 和 arm64 双架构镜像
- 推送到 `ghcr.io/doudou-start/chatgpt-register:v1.0.0`
- 同时更新 `ghcr.io/doudou-start/chatgpt-register:latest`

### 验证镜像构建成功

1. 查看 GitHub Actions 运行日志
2. 访问仓库 Packages 页面查看镜像
3. 本地测试拉取:

```bash
docker pull ghcr.io/doudou-start/chatgpt-register:latest
```

### 设置镜像为公开

1. 进入仓库 → Packages → chatgpt-register
2. Package settings → Change visibility
3. 选择 "Public" 让用户无需认证即可拉取

---

## 🌐 第三步: 创建公开部署仓库

### 1. 创建新的 GitHub 仓库

- 仓库名: `chatgpt-register-deploy` (推荐)
- 可见性: **Public**
- 不要初始化 README (我们已经准备好了)

### 2. 推送部署文件

```bash
cd /Users/huangenjun/code/chatgpt-register/deploy-repo

# 初始化 Git 仓库
git init
git add .
git commit -m "初始化部署仓库"

# 关联远程仓库
git remote add origin https://github.com/DouDOU-start/chatgpt-register-deploy.git

# 推送到 GitHub
git branch -M main
git push -u origin main
```

### 3. 验证文件已正确配置

所有占位符已自动替换为:
- GitHub 用户名: `DouDOU-start`
- Docker 镜像: `ghcr.io/doudou-start/chatgpt-register:latest`

检查关键文件:
- ✅ `.env.example` - 镜像地址已更新
- ✅ `docker-compose.yml` - 镜像地址已更新
- ✅ `install.sh` - 仓库 URL 已更新
- ✅ `README.md` - 所有 URL 已更新

---

## ✅ 第四步: 测试部署流程

### 在测试服务器上验证

```bash
# 使用部署脚本安装
curl -sSL https://raw.githubusercontent.com/DouDOU-start/chatgpt-register-deploy/main/install.sh | sudo bash

# 检查服务状态
sudo docker ps
sudo docker logs chatgpt-register

# 访问服务
curl http://localhost:8082/health
```

### 验证清单

- [ ] Docker 镜像可以从 ghcr.io 正常拉取
- [ ] 配置文件正确下载
- [ ] 服务成功启动
- [ ] 健康检查通过
- [ ] Web 界面可以访问
- [ ] 数据和日志正确持久化在 `/opt/chatgpt-register/`

---

## 🔄 日常维护流程

### 发布新版本

1. **在私有仓库打标签**:
   ```bash
   cd /Users/huangenjun/code/chatgpt-register
   git tag v1.1.0
   git push origin v1.1.0
   ```

2. **GitHub Actions 自动构建镜像**:
   - 自动推送 `ghcr.io/doudou-start/chatgpt-register:v1.1.0`
   - 自动更新 `ghcr.io/doudou-start/chatgpt-register:latest`

3. **用户升级**:
   ```bash
   cd /opt/chatgpt-register
   sudo docker pull ghcr.io/doudou-start/chatgpt-register:latest
   sudo docker compose up -d
   ```

### 更新部署仓库

当配置文件格式变更时:

```bash
cd /Users/huangenjun/code/chatgpt-register/deploy-repo

# 更新配置文件示例
cp ../app/config.yaml config.yaml.example
# 调整路径为 Docker 环境路径 (/app/data/backups)

# 提交更改
git add .
git commit -m "更新配置示例"
git push
```

---

## 📝 用户使用流程

用户只需要:

### 1. 一键安装
```bash
curl -sSL https://raw.githubusercontent.com/DouDOU-start/chatgpt-register-deploy/main/install.sh | sudo bash
```

### 2. 配置服务
```bash
sudo nano /opt/chatgpt-register/.env
sudo nano /opt/chatgpt-register/config.yaml
```

### 3. 重启服务
```bash
cd /opt/chatgpt-register
sudo docker compose restart
```

---

## 🛡️ 镜像访问控制

### 公开镜像 (推荐)

- 用户无需认证即可拉取
- 适合开源或免费分发

### 私有镜像 (需要授权)

如果需要限制访问:

1. **保持镜像为私有**
2. **用户需要登录后才能拉取**:
   ```bash
   # 用户需要创建 GitHub Personal Access Token (PAT)
   echo $PAT | docker login ghcr.io -u USERNAME --password-stdin
   docker pull ghcr.io/doudou-start/chatgpt-register:latest
   ```

3. **在 install.sh 中添加登录步骤**:
   ```bash
   read -p "请输入 GitHub 用户名: " GITHUB_USER
   read -sp "请输入 GitHub Token: " GITHUB_TOKEN
   echo $GITHUB_TOKEN | docker login ghcr.io -u $GITHUB_USER --password-stdin
   ```

---

## 🔧 高级配置

### 多架构支持

当前构建支持:
- `linux/amd64` (x86_64 服务器)
- `linux/arm64` (ARM 服务器,如树莓派)

### 自定义镜像标签

```bash
# 推送到不同的标签
git tag beta-v1.2.0
git push origin beta-v1.2.0

# 用户使用特定版本
sed -i 's/:latest/:beta-v1.2.0/' .env
docker compose up -d
```

---

## ❓ 常见问题

### Q1: 如何查看构建的镜像?

访问: https://github.com/DouDOU-start/chatgpt-register/pkgs/container/chatgpt-register

### Q2: 镜像拉取失败怎么办?

**检查镜像可见性**:
- 确保镜像设置为 Public
- 或用户已登录 ghcr.io

**检查网络**:
```bash
docker pull ghcr.io/doudou-start/chatgpt-register:latest
```

### Q3: 如何实现 License 验证?

**在应用中集成**:
- 启动时连接 License 服务器验证
- 定期检查 License 有效性
- 过期后限制功能

### Q4: GitHub Actions 构建失败?

**检查日志**:
1. 进入 Actions 页面查看详细错误
2. 常见问题:
   - Dockerfile 语法错误
   - 依赖安装失败
   - 权限不足

---

## 📊 部署架构总结

```
┌─────────────────────────────────────────────┐
│  私有源码仓库                                │
│  chatgpt-register                           │
│  ├── GitHub Actions (构建镜像)               │
│  └── 推送到 ghcr.io                          │
└─────────────────────────────────────────────┘
              │
              ▼
┌─────────────────────────────────────────────┐
│  GitHub Container Registry                  │
│  ghcr.io/doudou-start/chatgpt-register     │
│  ├── :latest (最新版本)                      │
│  ├── :v1.0.0 (版本标签)                      │
│  └── :v1.1.0                                │
└─────────────────────────────────────────────┘
              │
              ▼
┌─────────────────────────────────────────────┐
│  公开部署仓库                                │
│  chatgpt-register-deploy                    │
│  ├── install.sh (一键部署)                   │
│  ├── docker-compose.yml (镜像配置)           │
│  └── 配置文件模板                            │
└─────────────────────────────────────────────┘
              │
              ▼
┌─────────────────────────────────────────────┐
│  用户服务器                                  │
│  /opt/chatgpt-register/                     │
│  ├── 拉取镜像                                │
│  ├── 配置文件                                │
│  └── 启动服务                                │
└─────────────────────────────────────────────┘
```

---

## 📞 需要帮助?

如有问题,请检查:
1. GitHub Actions 构建日志
2. GitHub Packages 中镜像是否存在
3. 镜像可见性是否为 Public
4. 部署仓库文件是否正确
5. install.sh 中的 URL 是否正确

---

**🎉 完成以上步骤后,用户就可以通过一键脚本部署你的应用了！**

## 🚦 快速开始检查清单

- [ ] GitHub Actions workflow 已创建并可运行
- [ ] 成功构建并推送第一个镜像
- [ ] 镜像已设置为 Public
- [ ] 部署仓库已创建并推送
- [ ] 在测试服务器验证安装流程
- [ ] 文档中的所有 URL 正确
- [ ] 准备好向用户发布
