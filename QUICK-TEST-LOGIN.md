# 🔧 登录/注册功能快速测试指南

## ✅ 已完成的修复

### 问题
前端API配置缺少端口号，导致请求发送到错误的端口。

### 修复
```typescript
// 修改前
export const API_BASE_URL = 'https://115.175.45.173'

// 修改后
export const API_BASE_URL = 'https://115.175.45.173:8080'
```

---

## 🧪 立即测试步骤

### 步骤1: 刷新页面
1. 打开浏览器访问: https://localhost:5173/
2. 按 `Ctrl + F5` 强制刷新（清除缓存）

### 步骤2: 打开开发者工具
按 `F12` 打开浏览器开发者工具，切换到 **Network（网络）** 标签

### 步骤3: 测试登录
1. 点击"登录"按钮
2. 输入测试账号：
   - 邮箱: `test@example.com`
   - 密码: `password123`
3. 点击"登录"

### 步骤4: 查看网络请求
在Network标签中，应该看到：

✅ **成功的请求**:
```
Request URL: https://115.175.45.173:8080/api/auth/login
Method: POST
Status: 200 OK
Response: 
{
  "token": "eyJhbGc...",
  "username": "testuser",
  "email": "test@example.com",
  ...
}
```

❌ **如果还是失败**，检查：
- Request URL 是否包含 `:8080`
- Status Code 是什么
- Console 是否有错误信息

---

## 🔍 详细诊断步骤

### 检查1: 确认API URL正确
在浏览器Console中运行：
```javascript
// 查看当前配置
import.meta.env
```

### 检查2: 测试后端连接
在浏览器Console中运行：
```javascript
// 直接测试登录API
fetch('https://115.175.45.173:8080/api/auth/login', {
  method: 'POST',
  headers: {
    'Content-Type': 'application/json'
  },
  body: JSON.stringify({
    email: 'test@example.com',
    password: 'password123',
    rememberMe: false
  })
})
.then(res => res.json())
.then(data => console.log('成功:', data))
.catch(err => console.error('失败:', err))
```

### 检查3: 查看请求详情
在Network标签中点击失败的请求，查看：
- **Headers** - 确认URL和请求头
- **Payload** - 确认发送的数据
- **Response** - 查看错误信息

---

## 📊 可能出现的问题及解决方案

### 问题1: SSL证书错误
**症状**: `NET::ERR_CERT_AUTHORITY_INVALID`

**解决方案**:
1. Chrome浏览器中点击 "高级"
2. 点击 "继续前往 115.175.45.173 (不安全)"
3. 或者在浏览器中输入: `thisisunsafe` (不要在任何输入框中)

### 问题2: CORS跨域错误
**症状**: `Access to fetch ... has been blocked by CORS policy`

**检查**: 
- 后端是否配置了CORS: `@CrossOrigin(origins = "*")`
- 请求头是否正确

### 问题3: 连接超时
**症状**: `net::ERR_CONNECTION_TIMED_OUT`

**检查**:
1. 后端是否运行: 
   ```powershell
   Get-Process -Name java
   netstat -ano | findstr "8080"
   ```
2. 防火墙是否允许8080端口
3. 网络连接是否正常

### 问题4: 401 Unauthorized
**症状**: 登录返回401错误

**原因**: 
- 用户名或密码错误
- 数据库中没有该用户

**解决**: 先尝试注册新用户

---

## 🎯 测试清单

### 基础功能测试
- [ ] 登录功能测试
  - [ ] 正确的邮箱密码 → 成功登录
  - [ ] 错误的密码 → 显示错误提示
  - [ ] 不存在的邮箱 → 显示错误提示
  
- [ ] 注册功能测试
  - [ ] 填写信息 → 发送验证码
  - [ ] 输入验证码 → 注册成功
  - [ ] 重复用户名 → 显示错误提示
  
- [ ] 找回密码功能测试
  - [ ] 输入邮箱 → 发送验证码
  - [ ] 验证码验证 → 重置密码成功

### 网络请求检查
- [ ] 请求URL包含 `:8080`
- [ ] Content-Type 是 `application/json`
- [ ] 请求Body格式正确
- [ ] 响应状态码正确

---

## 🚀 快速命令

### 重启前端服务
```powershell
# 如果需要重启前端
cd e:\deeptalk_zt\DeepTalk_zt\frontend
npm run dev
```

### 检查后端状态
```powershell
# 查看Java进程
Get-Process -Name java

# 查看8080端口
netstat -ano | findstr "8080"
```

### 重启后端服务
```powershell
# 如果需要重启后端
cd e:\deeptalk_zt\DeepTalk_zt\backend
.\start.ps1
```

---

## 📝 测试记录模板

```
测试时间: 2025年10月24日 [时间]
测试人员: [你的名字]

【登录测试】
- 测试账号: test@example.com
- 请求URL: https://115.175.45.173:8080/api/auth/login
- 状态码: [200/400/401/500等]
- 结果: [成功/失败]
- 错误信息: [如果有]

【注册测试】
- 新用户名: [用户名]
- 请求URL: https://115.175.45.173:8080/api/auth/register/check
- 状态码: [状态码]
- 结果: [成功/失败]
- 错误信息: [如果有]

【问题记录】
1. [问题描述]
2. [问题描述]

【建议】
1. [改进建议]
2. [改进建议]
```

---

## 💡 调试技巧

### 技巧1: 使用Console.log追踪
在 `frontend/src/utils/http.ts` 中已经有详细的日志：
```typescript
console.log('发送请求(无需token):', {
  url: config.url,
  method: config.method,
  data: config.data,
  headers: config.headers
})
```

### 技巧2: 使用Network瀑布图
在Network标签中查看：
- DNS解析时间
- 连接时间
- 等待时间
- 下载时间

### 技巧3: 使用Postman测试
如果浏览器测试有问题，可以用Postman：
```
POST https://115.175.45.173:8080/api/auth/login
Content-Type: application/json

{
  "email": "test@example.com",
  "password": "password123",
  "rememberMe": false
}
```

---

## 🎉 成功标志

修复成功后，你应该看到：

1. ✅ Network标签显示请求URL包含 `:8080`
2. ✅ 请求返回 200 状态码
3. ✅ 响应包含 token 和用户信息
4. ✅ 页面跳转到首页
5. ✅ 显示用户头像和用户名

---

## 📞 需要帮助？

如果测试失败，请提供以下信息：
1. 浏览器Console的完整错误信息
2. Network标签的请求详情截图
3. 请求URL和响应内容
4. 后端日志（如果可以访问）

---

**现在就开始测试吧！** 🚀

打开浏览器访问: https://localhost:5173/
