# AI自动回复功能实现文档

## 功能概述

当用户在DeepTalk社区发布新帖子时，系统会自动调用AI服务（OpenRouter API）生成一条友好、有建设性的回复内容，并保存到数据库中。

## 实现架构

### 后端部分

#### 1. 数据库层
- **新增表**: `replies` - 存储所有回复数据
  - `id`: 回复唯一标识（UUID）
  - `post_id`: 关联的帖子ID
  - `content`: 回复内容
  - `author_id`: 作者ID（AI回复为"ai-assistant"）
  - `author_name`: 作者名称（AI回复为"AI助手"）
  - `author_avatar`: 作者头像URL
  - `created_at`: 创建时间
  - `is_ai_generated`: 是否AI生成（布尔值）

#### 2. 实体层
- **Reply.java**: 回复实体类，映射到replies表
- 使用JPA注解进行ORM映射

#### 3. 数据访问层
- **ReplyRepository.java**: 回复数据访问接口
  - `findByPostIdOrderByCreatedAtAsc()`: 按时间顺序查询帖子的所有回复
  - `countByPostId()`: 统计帖子的回复数量

#### 4. 服务层
- **AIReplyService.java**: AI回复生成服务
  - 调用OpenRouter API生成回复
  - 支持备用回复（当API不可用时）
  - 使用Meta-Llama模型生成自然语言回复

- **ReplyService.java**: 回复业务逻辑服务
  - `getRepliesByPostId()`: 获取帖子的所有回复
  - `addReply()`: 添加新回复
  - `generateAIReply()`: 为帖子生成AI回复
  - `getReplyCount()`: 获取回复数量

#### 5. 控制器层
- **CommunityController.java**: 社区API控制器
  - `POST /api/community/posts/add`: 发布新帖子（已修改，自动生成AI回复）
  - `GET /api/community/posts/{postId}/replies`: 获取帖子的回复列表

#### 6. 配置
- **application.yml**: 应用配置
  ```yaml
  openrouter:
    api:
      key: ${OPENROUTER_API_KEY:}  # 从环境变量读取
      url: https://openrouter.ai/api/v1/chat/completions
  ```

### 前端部分

#### 1. 类型定义
- **CommunityInterface.ts**: 新增Reply接口和相关类型
  - `Reply`: 回复数据结构
  - `GetRepliesResponse`: 获取回复的API响应

#### 2. API层
- **CommunityAPI.ts**: 新增获取回复的API方法
  - `CommunityGetRepliesAPI()`: 调用后端获取回复列表

#### 3. 控制器层
- **CommunityController.ts**: 新增getReplies方法
  - 封装API调用，处理加载状态和错误

#### 4. 视图层
- **PostDetail.vue**: 帖子详情页
  - 显示AI生成的回复
  - 回复带有"AI"标签
  - 响应式加载和显示

## 工作流程

### 发帖流程
1. 用户填写帖子标题和内容
2. 提交到后端 `/api/community/posts/add`
3. 后端保存帖子到数据库
4. **自动调用AI服务生成回复**:
   - 构造Prompt：包含帖子标题和内容
   - 调用OpenRouter API（使用Meta-Llama模型）
   - 解析AI响应
   - 创建Reply对象并保存到数据库
   - 标记为AI生成（`is_ai_generated=true`）
5. 返回成功响应给前端
6. 前端跳转到帖子详情页

### 查看回复流程
1. 用户进入帖子详情页
2. 前端调用 `/api/community/posts/{postId}/replies`
3. 后端从数据库查询回复列表
4. 前端展示回复，AI回复带有特殊标识

## AI回复生成策略

### Prompt设计
```
System: You are a helpful and friendly community member. 
Generate a thoughtful, engaging reply to the following post. 
Keep your response concise (2-3 sentences), natural, and encouraging. 
Respond in the same language as the post.

User: Title: {帖子标题}
Content: {帖子内容}
Please write a friendly and constructive reply to this post.
```

### 备用回复
当API不可用或失败时，使用预设的友好回复：
- "感谢分享！这个话题很有意思，期待看到更多讨论。"
- "很有见地的观点！你提到的内容让我有了新的思考。"
- "这是一个很棒的帖子！希望能看到更多这样的内容。"
- 等...

## 配置说明

### 环境变量
需要设置OpenRouter API密钥：
```bash
# Windows PowerShell
$env:OPENROUTER_API_KEY = "your-api-key-here"

# Linux/Mac
export OPENROUTER_API_KEY="your-api-key-here"
```

如果未设置API密钥，系统会自动使用备用回复，不会影响核心功能。

## 特性亮点

### 1. 非阻塞设计
- AI回复生成不会阻塞发帖流程
- 即使AI生成失败，帖子也能成功发布

### 2. 错误容错
- API失败时自动使用备用回复
- 详细的错误日志便于调试

### 3. 用户体验
- AI回复有明显标识（机器人图标+AI标签）
- 回复按时间顺序排列
- 响应式设计，适配各种屏幕

### 4. 可扩展性
- 易于切换AI模型
- 可以添加更多类型的回复（用户回复、@提醒等）
- 可以添加点赞、删除等功能

## 文件清单

### 后端新增文件
1. `Reply.java` - 回复实体
2. `ReplyRepository.java` - 回复数据访问
3. `AIReplyService.java` - AI回复生成服务
4. `ReplyService.java` - 回复业务逻辑
5. `GetRepliesResponse.java` - 回复响应DTO
6. `create-replies-table.sql` - 数据库建表脚本

### 后端修改文件
1. `CommunityController.java` - 添加回复API接口
2. `application.yml` - 添加OpenRouter配置

### 前端修改文件
1. `CommunityInterface.ts` - 添加Reply类型定义
2. `CommunityAPI.ts` - 添加获取回复API
3. `CommunityController.ts` - 添加getReplies方法
4. `PostDetail.vue` - 显示回复列表
5. `api.ts` - 添加回复API端点配置

## 测试指南

### 1. 后端测试
```bash
# 启动后端
cd backend
mvn spring-boot:run

# 测试发帖并生成AI回复
curl -X POST http://localhost:8080/api/community/posts/add \
  -H "Content-Type: application/json" \
  -d '{
    "authorId": "test_user",
    "post": {
      "title": "测试帖子",
      "content": "这是一个测试帖子内容",
      "author": {
        "id": "test_user",
        "username": "测试用户",
        "avatar": "",
        "authorLikes": 0,
        "authorPosts": 0
      }
    }
  }'

# 测试获取回复
curl http://localhost:8080/api/community/posts/{postId}/replies
```

### 2. 前端测试
1. 登录系统
2. 进入社区页面
3. 点击"发布新帖"
4. 填写标题和内容
5. 提交帖子
6. 跳转到帖子详情页
7. 查看AI自动生成的回复（带有AI标签）

### 3. 验证点
- ✅ 帖子发布成功
- ✅ AI回复自动生成
- ✅ 回复显示在详情页
- ✅ AI回复有明显标识
- ✅ 回复内容相关且友好
- ✅ 备用回复正常工作（未配置API时）

## 后续优化方向

1. **多语言支持**: 根据帖子语言自动调整回复语言
2. **个性化回复**: 根据帖子类型（技术、生活、讨论等）调整回复风格
3. **情感分析**: 识别帖子情绪，生成更贴合的回复
4. **用户反馈**: 允许用户对AI回复点赞或举报
5. **回复管理**: 管理员可以编辑或删除AI回复
6. **批量生成**: 为历史帖子批量生成AI回复

## 注意事项

1. **API费用**: OpenRouter API可能产生费用，建议监控使用量
2. **内容审核**: AI生成的内容可能需要人工审核
3. **性能影响**: 大量并发发帖时，AI生成可能需要排队处理
4. **数据隐私**: 帖子内容会发送到OpenRouter，注意隐私政策

## 技术栈

- **后端**: Spring Boot + JPA + MySQL
- **AI服务**: OpenRouter API (Meta-Llama 3.1)
- **前端**: Vue 3 + TypeScript + Vuetify
- **数据库**: MySQL 8.0

## 联系与支持

如有问题，请查看：
- OpenRouter文档: https://openrouter.ai/docs
- DeepTalk项目文档: README.md
