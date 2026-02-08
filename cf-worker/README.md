# Cloudflare Email Worker

自动接收 OpenAI/Anthropic 验证邮件并转发到后端。

**部署说明请查看：[../README.md](../README.md#邮件接收配置必需)**

## 配置文件

编辑 `wrangler.jsonc` 设置你的 API 地址：

```jsonc
"vars": {
  "API_URL": "https://your-domain.com/api/email/receive"
}
```

## 工作原理

```
邮件 → CF Worker → 解析 → POST /api/email/receive → 后端提取验证码
```

- Worker: 接收并转发所有邮件
- 后端: 验证白名单 + 提取验证码（有效期 15 分钟）
- 无需认证

## 查看日志

```bash
npx wrangler tail
```
