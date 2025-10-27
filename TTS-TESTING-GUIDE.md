# TTS功能快速测试指南

## 测试前准备

### 1. 确认配置
检查OpenRouter API密钥是否已配置：
```bash
# 查看环境变量文件
cat frontend/.env
```

应该包含：
```
VITE_OPENROUTER_API_KEY=sk-or-v1-xxxxx
```

### 2. 启动应用
```bash
cd frontend
npm install
npm run dev
```

---

## 功能测试步骤

### 测试1: 基础AI对话
1. 打开浏览器访问应用
2. 选择 **"AI辅助"** 模式
3. 点击麦克风按钮开始说话
4. 说一句话（例如："My favorite book is Harry Potter"）
5. 等待语音识别完成
6. **预期结果**:
   - ✅ 看到"AI正在思考..."状态
   - ✅ AI回复文本出现在对话记录中
   - ✅ 听到TTS朗读AI的回复（英文语音）
   - ✅ 朗读完成后状态恢复正常

### 测试2: 连续对话
1. 等待第一轮AI回复完成
2. 继续说话回应AI的问题
3. 重复3-5轮对话
4. **预期结果**:
   - ✅ 每次都能正确识别
   - ✅ AI回复基于对话历史
   - ✅ TTS正常朗读每次回复
   - ✅ 对话历史完整保存

### 测试3: 打断功能
1. 等待AI开始朗读
2. 在朗读过程中点击麦克风开始说话
3. **预期结果**:
   - ✅ TTS朗读应该停止
   - ✅ 可以开始新的对话

### 测试4: 错误处理
1. 临时断开网络
2. 尝试进行对话
3. **预期结果**:
   - ✅ 显示错误提示
   - ✅ 使用备用回复
   - ✅ TTS朗读备用回复
   - ✅ 状态正确恢复

---

## 浏览器控制台检查

打开浏览器开发者工具（F12），查看Console输出：

### 正常流程应该看到：
```
用户说: My favorite book is Harry Potter
Generating AI response using openrouter: My favorite book is Harry Potter
AI response generated: That's great! What do you like most about Harry Potter?
TTS开始朗读
AI回复: That's great! What do you like most about Harry Potter?
TTS朗读完成
```

### 如果有问题，检查：
- ❌ API密钥错误: `OpenRouter API error: 401`
- ❌ 网络错误: `Error generating AI response: Network error`
- ❌ 语音不支持: `TTS错误: Voice not available`

---

## 状态监控

### UI状态检查表
- [ ] **思考状态**: 显示加载动画或"思考中"文字
- [ ] **说话状态**: 显示"AI正在说话"指示器
- [ ] **对话记录**: 用户和AI的消息正确显示
- [ ] **时间戳**: 每条消息都有时间记录

---

## 性能检查

### 响应时间
- 语音识别完成 → AI思考开始: < 500ms
- AI思考开始 → AI回复生成: 2-5秒
- AI回复生成 → TTS开始: < 100ms
- TTS朗读速度: 自然流畅

### 资源使用
- CPU使用: 正常范围
- 内存: 无明显泄漏
- 网络请求: 仅API调用

---

## 常见问题排查

### 问题1: 听不到TTS声音
**可能原因**:
- 浏览器静音
- 系统音量设置
- 浏览器不支持Web Speech API

**解决方案**:
```javascript
// 在浏览器控制台测试TTS
const utterance = new SpeechSynthesisUtterance('Hello, this is a test')
speechSynthesis.speak(utterance)
```

### 问题2: AI没有回复
**可能原因**:
- API密钥未配置或错误
- 网络连接问题
- API配额用完

**解决方案**:
1. 检查 `.env` 文件
2. 查看控制台错误信息
3. 测试API连接：
```bash
# 使用测试脚本
.\quick-test-api.ps1
```

### 问题3: 语音识别不工作
**可能原因**:
- 麦克风权限未授予
- 浏览器不支持
- HTTPS要求

**解决方案**:
- 授予麦克风权限
- 使用Chrome/Edge浏览器
- 使用HTTPS或localhost

---

## 测试清单

### 基础功能
- [ ] TTS朗读英文
- [ ] TTS朗读中文（切换到真人对战模式测试）
- [ ] AI回复生成
- [ ] 对话历史记录
- [ ] 状态正确更新

### 边界情况
- [ ] 网络断开时的错误处理
- [ ] 长文本朗读
- [ ] 快速连续对话
- [ ] 模式切换时的资源清理

### 用户体验
- [ ] 响应速度可接受
- [ ] 语音自然流畅
- [ ] UI状态清晰
- [ ] 错误提示友好

---

## 调试命令

### 查看TTS状态
```javascript
// 在浏览器控制台
console.log('TTS支持:', 'speechSynthesis' in window)
console.log('可用语音:', speechSynthesis.getVoices())
console.log('正在朗读:', speechSynthesis.speaking)
```

### 查看AI服务状态
```javascript
// 需要访问controller实例
console.log('当前提供商:', controller.aiService.getCurrentProvider())
console.log('是否处理中:', controller.aiService.isProcessing)
```

### 强制停止TTS
```javascript
// 在浏览器控制台
speechSynthesis.cancel()
```

---

## 成功标准

✅ **测试通过条件**:
1. AI能够生成合理的回复
2. TTS能够清晰朗读回复
3. 状态转换流畅自然
4. 错误处理机制正常工作
5. 无控制台错误（除了预期的警告）

---

## 下一步

测试通过后，可以考虑：
1. 添加语速控制UI
2. 添加语音选择功能
3. 优化对话质量
4. 添加更多对话场景

测试发现问题请记录并反馈！
