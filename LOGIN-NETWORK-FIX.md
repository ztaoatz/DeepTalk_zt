# 登录注册网络请求问题修复报告

## 🐛 问题描述

用户在进行登录、注册等操作时，显示**网络请求失败**。

---

## 🔍 问题诊断

### 1. 后端状态检查 ✅
```powershell
# 检查Java进程
Get-Process -Name java

结果: 
- Java进程正在运行 (PID: 2780, 24272)
- 后端服务已启动
```

### 2. 端口检查 ✅
```powershell
# 检查8080端口
netstat -ano | findstr "8080"

结果:
TCP    0.0.0.0:8080           0.0.0.0:0              LISTENING       2780
TCP    [::]:8080              [::]:0                 LISTENING       2780
```
**后端正在8080端口监听**

### 3. 前端配置检查 ❌
```typescript
// frontend/src/config/api.ts
export const API_BASE_URL = 'https://115.175.45.173'
```

**问题发现**: API_BASE_URL **缺少端口号**！
- ❌ 错误: `https://115.175.45.173` (默认使用443端口)
- ✅ 正确: `https://115.175.45.173:8080`

---

## 🔧 解决方案

### 修复API配置
**文件**: `frontend/src/config/api.ts`

**修改前**:
```typescript
export const API_BASE_URL = 'https://115.175.45.173'
```

**第一次修改** (添加端口):
```typescript
export const API_BASE_URL = 'https://115.175.45.173:8080'
```

**最终修改** (本地开发环境):
```typescript
// 根据环境自动选择API地址
export const API_BASE_URL = import.meta.env.PROD 
  ? 'https://115.175.45.173:8080'  // 生产环境
  : 'http://localhost:8080'         // 开发环境
```

### 为什么会出现这个问题？

1. **端口问题**
   - 原配置缺少端口号: `https://115.175.45.173`
   - HTTPS默认端口是443，但后端运行在8080端口
   - **端口不匹配** → 连接失败

2. **环境问题**
   - 原配置使用远程服务器地址: `115.175.45.173`
   - 但前后端都在**本地运行**
   - 应该使用 `localhost` 而不是远程IP

3. **网络请求失败的根本原因**
   - ❌ 错误配置: 前端 → `https://115.175.45.173:443`
   - ❌ 实际情况: 后端 → `http://localhost:8080`
   - **地址和端口都不匹配** → 连接失败

---

## ✅ 修复验证

### 1. 配置已更新
```typescript
// 开发环境 (本地)
✅ API_BASE_URL = 'http://localhost:8080'

// 生产环境 (部署后)
✅ API_BASE_URL = 'https://115.175.45.173:8080'
```

### 2. 智能环境切换
- **开发模式** (`npm run dev`): 自动使用 `http://localhost:8080`
- **生产模式** (`npm run build`): 自动使用 `https://115.175.45.173:8080`

### 3. 影响的API端点
所有API请求现在会正确连接到**本地后端**：

**登录/注册相关**:
- `POST http://localhost:8080/api/auth/login`
- `POST http://localhost:8080/api/auth/register/check`
- `POST http://localhost:8080/api/auth/register/verify`
- `POST http://localhost:8080/api/auth/forgot-password/send-code`
- `POST http://localhost:8080/api/auth/logout`

**其他功能**:
- 社区API: `POST http://localhost:8080/api/community/*`
- 商店API: `POST http://localhost:8080/api/shop/*`
- WebSocket: `ws://localhost:8080/api/speech/connect`

---

## 🧪 测试步骤

### 方法1: 浏览器测试（推荐）
1. 刷新前端页面
2. 尝试登录或注册
3. 查看浏览器控制台（F12）
4. 确认请求发送到正确的端口

### 方法2: 命令行测试
```powershell
# 测试登录API
$body = @{
    email = "test@example.com"
    password = "password123"
    rememberMe = $false
} | ConvertTo-Json

Invoke-WebRequest -Uri "https://115.175.45.173:8080/api/auth/login" `
  -Method POST `
  -ContentType "application/json" `
  -Body $body
```

### 预期结果
✅ 成功: 返回用户信息和token
```json
{
  "token": "eyJhbGciOiJIUzI1NiIs...",
  "username": "testuser",
  "email": "test@example.com",
  "userId": "123",
  "expiration": "2025-10-25T..."
}
```

❌ 失败: 邮箱或密码错误
```json
"邮箱或密码错误"
```

---

## 📝 完整的请求流程

### 登录请求示例
```
1. 用户输入邮箱密码 → 点击登录
   ↓
2. 前端发送请求
   POST https://115.175.45.173:8080/api/auth/login
   Body: { email, password, rememberMe }
   ↓
3. 后端处理 (AuthController)
   - 查询用户
   - 验证密码
   - 生成JWT token
   ↓
4. 返回响应
   { token, username, email, userId, expiration }
   ↓
5. 前端保存token
   - localStorage (记住我)
   - sessionStorage (不记住我)
   ↓
6. 登录成功 → 跳转首页
```

---

## 🔒 安全说明

### SSL证书问题
如果后端使用自签名证书，可能会遇到SSL证书验证失败：

**临时解决方案** (仅开发环境):
```typescript
// 在axios配置中添加
httpsAgent: new https.Agent({
  rejectUnauthorized: false
})
```

**生产环境解决方案**:
1. 使用Let's Encrypt获取免费SSL证书
2. 或使用正规CA签发的证书
3. 配置Nginx反向代理处理SSL

---

## 📊 诊断清单

验证修复是否成功：

- [x] API_BASE_URL包含端口号 (`:8080`)
- [x] 后端服务正在运行
- [x] 8080端口正在监听
- [ ] 前端页面已刷新
- [ ] 登录功能测试通过
- [ ] 注册功能测试通过
- [ ] 找回密码功能测试通过

---

## 🚨 常见问题

### Q1: 修改后还是失败？
**检查步骤**:
1. 确认前端开发服务器已重启
2. 清除浏览器缓存 (Ctrl+F5)
3. 查看浏览器控制台的网络请求
4. 确认请求URL包含`:8080`

### Q2: CORS跨域问题
**症状**: 报错 `Access-Control-Allow-Origin`

**解决**: 后端已配置CORS
```java
@CrossOrigin(origins = "*")
public class AuthController {
```

### Q3: SSL证书错误
**症状**: `NET::ERR_CERT_AUTHORITY_INVALID`

**临时解决**:
- Chrome: 点击 "高级" → "继续前往"
- 或在浏览器中输入: `chrome://flags/#allow-insecure-localhost`

### Q4: 连接超时
**检查**:
1. 防火墙是否允许8080端口
2. 服务器IP是否正确
3. 网络连接是否正常

---

## 📖 相关文件

### 需要修改的文件
- ✅ `frontend/src/config/api.ts` - API基础配置

### 相关的配置文件
- `backend/src/main/resources/application.properties` - 后端端口配置
- `frontend/src/utils/http.ts` - HTTP客户端配置
- `frontend/src/api/user.ts` - 用户API调用

---

## 🎯 总结

### 问题根源
前端API基础URL缺少端口号，导致请求发送到错误的端口（443而不是8080）。

### 解决方案
在API_BASE_URL中添加端口号 `:8080`

### 影响范围
- ✅ 登录功能
- ✅ 注册功能
- ✅ 找回密码功能
- ✅ 所有需要后端API的功能

### 下一步
1. 刷新前端页面
2. 测试登录/注册功能
3. 如有问题，查看浏览器控制台错误

---

**修复完成时间**: 2025年10月24日  
**问题状态**: ✅ 已修复，等待测试验证

---

## 🎉 预期效果

修复后，用户应该能够：
- ✅ 正常登录
- ✅ 正常注册
- ✅ 正常找回密码
- ✅ 正常使用所有需要后端API的功能

**请刷新页面后重新测试！**
