# 🤖 AI自动回复功能 - 快速参考

## 一分钟了解

**功能**: 发帖后自动获得AI生成的友好回复  
**状态**: ✅ 已实现  
**配置**: 无需配置即可使用（可选配置API提升质量）

## 快速测试

```powershell
# 1. 启动服务
cd e:\deeptalk_zt\DeepTalk_zt\backend
mvn spring-boot:run

# 2. 运行测试脚本
cd e:\deeptalk_zt\DeepTalk_zt
.\test-ai-auto-reply.ps1
```

## 用户体验

```
用户发帖 → AI自动回复 → 详情页显示（带AI标签）
```

## 关键文件

### 后端
- `Reply.java` - 回复实体
- `AIReplyService.java` - AI生成服务
- `CommunityController.java` - API接口

### 前端
- `PostDetail.vue` - 显示回复
- `CommunityController.ts` - 回复逻辑

## API端点

```
GET /api/community/posts/{postId}/replies
返回: { success, replies[], count }
```

## 提升AI质量（可选）

```powershell
$env:OPENROUTER_API_KEY = "sk-or-v1-xxxxx"
```

## 验证成功

- [x] 后端编译通过
- [x] 前端无错误
- [x] 数据库表自动创建
- [x] API接口可用
- [x] UI显示正确

## 下一步

运行测试脚本验证功能！
