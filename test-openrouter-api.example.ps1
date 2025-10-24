# OpenRouter API 快速测试脚本 (示例)
# 使用PowerShell运行此脚本
# 
# ⚠️ 重要提示: 
# 1. 将此文件复制为 test-openrouter-api.ps1
# 2. 将 YOUR_API_KEY_HERE 替换为您的真实API密钥
# 3. 不要将包含真实密钥的文件提交到Git

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  OpenRouter AI API 快速测试工具" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# 配置信息 - 请在复制后的文件中替换为真实密钥
$API_KEY = "YOUR_API_KEY_HERE"  # ⚠️ 替换为您的OpenRouter API密钥
$MODEL = "alibaba/tongyi-deepresearch-30b-a3b:free"
$API_URL = "https://openrouter.ai/api/v1/chat/completions"

# 检查API密钥是否已配置
if ($API_KEY -eq "YOUR_API_KEY_HERE") {
    Write-Host "❌ 错误: API密钥未配置" -ForegroundColor Red
    Write-Host ""
    Write-Host "请按以下步骤配置:" -ForegroundColor Yellow
    Write-Host "1. 复制本文件为: test-openrouter-api.ps1" -ForegroundColor Gray
    Write-Host "2. 在新文件中将 YOUR_API_KEY_HERE 替换为您的真实API密钥" -ForegroundColor Gray
    Write-Host "3. 保存后运行: .\test-openrouter-api.ps1" -ForegroundColor Gray
    Write-Host ""
    Write-Host "💡 获取API密钥: https://openrouter.ai/keys" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "Press any key to exit..." -ForegroundColor Gray
    $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
    exit 1
}

Write-Host "📋 配置信息:" -ForegroundColor Yellow
Write-Host "   API端点: $API_URL" -ForegroundColor Gray
Write-Host "   模型: $MODEL" -ForegroundColor Gray
Write-Host "   密钥: $($API_KEY.Substring(0, 20))..." -ForegroundColor Gray
Write-Host ""

# 测试API连接
Write-Host "🔍 测试1: 检查API连接..." -ForegroundColor Yellow

$headers = @{
    "Authorization" = "Bearer $API_KEY"
    "Content-Type" = "application/json"
}

$body = @{
    model = $MODEL
    messages = @(
        @{
            role = "user"
            content = "你好，请用一句话介绍你自己"
        }
    )
    max_tokens = 100
    temperature = 0.7
} | ConvertTo-Json -Depth 10

try {
    Write-Host "   发送请求..." -ForegroundColor Gray
    $startTime = Get-Date
    
    $response = Invoke-RestMethod -Uri $API_URL -Method Post -Headers $headers -Body $body -ContentType "application/json"
    
    $endTime = Get-Date
    $duration = ($endTime - $startTime).TotalSeconds
    
    Write-Host "   ✅ 连接成功!" -ForegroundColor Green
    Write-Host "   响应时间: $([math]::Round($duration, 2))秒" -ForegroundColor Gray
    Write-Host ""
    
    Write-Host "🤖 AI回复:" -ForegroundColor Yellow
    Write-Host "   $($response.choices[0].message.content)" -ForegroundColor Cyan
    Write-Host ""
    
    Write-Host "📊 使用统计:" -ForegroundColor Yellow
    Write-Host "   模型: $($response.model)" -ForegroundColor Gray
    Write-Host "   总Token: $($response.usage.total_tokens)" -ForegroundColor Gray
    Write-Host "   输入Token: $($response.usage.prompt_tokens)" -ForegroundColor Gray
    Write-Host "   输出Token: $($response.usage.completion_tokens)" -ForegroundColor Gray
    Write-Host ""
    
} catch {
    Write-Host "   ❌ 连接失败!" -ForegroundColor Red
    Write-Host "   错误信息: $($_.Exception.Message)" -ForegroundColor Red
    Write-Host ""
    
    Write-Host "💡 请检查:" -ForegroundColor Yellow
    Write-Host "   1. API密钥是否正确" -ForegroundColor Gray
    Write-Host "   2. 网络连接是否正常" -ForegroundColor Gray
    Write-Host "   3. 模型名称是否正确" -ForegroundColor Gray
    Write-Host ""
    exit 1
}

# 测试中文对话
Write-Host "🔍 测试2: 中文对话测试..." -ForegroundColor Yellow

$body2 = @{
    model = $MODEL
    messages = @(
        @{
            role = "system"
            content = "你是一个友好的AI助手，擅长用中文交流。"
        }
        @{
            role = "user"
            content = "请简单介绍一下DeepTalk项目的主要功能"
        }
    )
    max_tokens = 200
    temperature = 0.7
} | ConvertTo-Json -Depth 10

try {
    Write-Host "   发送请求..." -ForegroundColor Gray
    $response2 = Invoke-RestMethod -Uri $API_URL -Method Post -Headers $headers -Body $body2 -ContentType "application/json"
    
    Write-Host "   ✅ 对话成功!" -ForegroundColor Green
    Write-Host ""
    
    Write-Host "🤖 AI回复:" -ForegroundColor Yellow
    Write-Host "   $($response2.choices[0].message.content)" -ForegroundColor Cyan
    Write-Host ""
    
} catch {
    Write-Host "   ❌ 对话失败!" -ForegroundColor Red
    Write-Host "   错误信息: $($_.Exception.Message)" -ForegroundColor Red
    Write-Host ""
}

# 测试英文对话
Write-Host "🔍 测试3: 英文对话测试..." -ForegroundColor Yellow

$body3 = @{
    model = $MODEL
    messages = @(
        @{
            role = "system"
            content = "You are a helpful English conversation partner."
        }
        @{
            role = "user"
            content = "What are the main features of DeepTalk project?"
        }
    )
    max_tokens = 200
    temperature = 0.7
} | ConvertTo-Json -Depth 10

try {
    Write-Host "   发送请求..." -ForegroundColor Gray
    $response3 = Invoke-RestMethod -Uri $API_URL -Method Post -Headers $headers -Body $body3 -ContentType "application/json"
    
    Write-Host "   ✅ 对话成功!" -ForegroundColor Green
    Write-Host ""
    
    Write-Host "🤖 AI Reply:" -ForegroundColor Yellow
    Write-Host "   $($response3.choices[0].message.content)" -ForegroundColor Cyan
    Write-Host ""
    
} catch {
    Write-Host "   ❌ 对话失败!" -ForegroundColor Red
    Write-Host "   错误信息: $($_.Exception.Message)" -ForegroundColor Red
    Write-Host ""
}

# 总结
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  测试完成!" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

Write-Host "📝 接下来你可以:" -ForegroundColor Yellow
Write-Host "   1. 启动前端项目: cd frontend && npm run dev" -ForegroundColor Gray
Write-Host "   2. 打开测试页面: http://localhost:5173/test-openrouter.html" -ForegroundColor Gray
Write-Host "   3. 在项目中使用 AIService 进行对话" -ForegroundColor Gray
Write-Host ""

Write-Host "📚 查看文档:" -ForegroundColor Yellow
Write-Host "   OPENROUTER-API-SETUP.md" -ForegroundColor Gray
Write-Host "   API-KEY-SECURITY-GUIDE.md" -ForegroundColor Gray
Write-Host ""

Write-Host "Press any key to exit..." -ForegroundColor Gray
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
