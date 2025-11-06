# 🎯 AI对战界面 - 快速参考

## 📍 配置位置

```
frontend/
├── .env.local                        ← API密钥配置
└── src/services/OpenRouterService.ts ← AI服务类
```

## 🔑 当前配置

```bash
API端点: https://openrouter.ai/api/v1/chat/completions
模型: alibaba/tongyi-deepresearch-30b-a3b:free
密钥: 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
```

## 🚀 快速命令

```powershell
# 检查配置
.\check-battle-config.ps1

# 启动服务
cd frontend && npm run dev

# 访问应用
http://localhost:5173
```

## ⚠️ 当前状态

- ✅ 配置完成
- ✅ 前端运行中
- ⚠️ API服务临时不可用（503）
- ✅ 备用回复系统已启用

## 🔄 备用模型

```bash
# 编辑 frontend/.env.local

# 选项1: Google Gemini
VITE_OPENROUTER_MODEL=google/gemini-pro-1.5:free

# 选项2: Meta Llama
VITE_OPENROUTER_MODEL=meta-llama/llama-3.1-8b-instruct:free

# 选项3: Mistral
VITE_OPENROUTER_MODEL=mistralai/mistral-7b-instruct:free
```

## 📊 API限制

- 免费版: ~20 请求/分钟
- 每日配额: ~200 请求
- 超时: 30秒

## 🐛 常见问题

**503 错误**: API服务临时不可用，稍后重试
**429 错误**: 请求过多，等待1-2分钟
**401 错误**: API密钥无效，检查配置

## 💡 提示

系统已配置智能备用回复，即使API不可用也能正常使用！
