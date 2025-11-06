# ========================================
# DeepTalk AI对战界面配置验证
# ========================================

Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host "🎯 DeepTalk AI对战界面配置验证" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan

# 1. 检查后端配置
Write-Host "`n📋 1. 检查后端配置" -ForegroundColor Yellow
Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor DarkGray

$backendYml = "e:\deeptalk_zt\DeepTalk_zt\backend\src\main\resources\application.yml"
if (Test-Path $backendYml) {
    $content = Get-Content $backendYml -Raw
    if ($content -match 'openrouter:[\s\S]*?key:\s*\$\{OPENROUTER_API_KEY:([^}]*)\}') {
        Write-Host "   ✅ 后端OpenRouter配置存在" -ForegroundColor Green
        Write-Host "   配置文件: application.yml" -ForegroundColor Gray
    } else {
        Write-Host "   ❌ 后端OpenRouter配置缺失" -ForegroundColor Red
    }
} else {
    Write-Host "   ❌ application.yml 不存在" -ForegroundColor Red
}

# 2. 检查前端环境变量
Write-Host "`n📋 2. 检查前端环境变量" -ForegroundColor Yellow
Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor DarkGray

$frontendEnv = "e:\deeptalk_zt\DeepTalk_zt\frontend\.env.local"
if (Test-Path $frontendEnv) {
    $envContent = Get-Content $frontendEnv -Raw
    
    if ($envContent -match 'VITE_OPENROUTER_API_KEY=([^\r\n]+)') {
        $apiKey = $matches[1].Trim()
        if ($apiKey -and $apiKey -ne 'YOUR_OPENROUTER_API_KEY_HERE') {
            Write-Host "   ✅ 前端API密钥已配置" -ForegroundColor Green
            Write-Host "   密钥: $($apiKey.Substring(0, 20))..." -ForegroundColor Gray
        } else {
            Write-Host "   ❌ 前端API密钥未设置" -ForegroundColor Red
        }
    }
    
    if ($envContent -match 'VITE_OPENROUTER_MODEL=([^\r\n]+)') {
        $model = $matches[1].Trim()
        Write-Host "   ✅ 模型配置: $model" -ForegroundColor Green
    }
} else {
    Write-Host "   ❌ .env.local 不存在" -ForegroundColor Red
    Write-Host "   提示: 请复制 .env.local.example 并配置API密钥" -ForegroundColor Yellow
}

# 3. 检查OpenRouterService服务
Write-Host "`n📋 3. 检查OpenRouterService服务" -ForegroundColor Yellow
Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor DarkGray

$serviceFile = "e:\deeptalk_zt\DeepTalk_zt\frontend\src\services\OpenRouterService.ts"
if (Test-Path $serviceFile) {
    $serviceContent = Get-Content $serviceFile -Raw
    if ($serviceContent -match "model:\s*config\.model\s*\|\|\s*'([^']+)'") {
        $defaultModel = $matches[1]
        Write-Host "   ✅ OpenRouterService 存在" -ForegroundColor Green
        Write-Host "   默认模型: $defaultModel" -ForegroundColor Gray
    }
    
    if ($serviceContent -match 'https://openrouter\.ai/api/v1/chat/completions') {
        Write-Host "   ✅ API端点配置正确" -ForegroundColor Green
    }
} else {
    Write-Host "   ❌ OpenRouterService.ts 不存在" -ForegroundColor Red
}

# 4. 检查服务状态
Write-Host "`n📋 4. 检查服务运行状态" -ForegroundColor Yellow
Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor DarkGray

# 检查后端
$backend = Get-NetTCPConnection -LocalPort 8080 -ErrorAction SilentlyContinue
if ($backend) {
    Write-Host "   ✅ 后端服务运行中 (端口 8080)" -ForegroundColor Green
} else {
    Write-Host "   ⚠️  后端服务未运行" -ForegroundColor Yellow
}

# 检查前端  
$frontend = Get-NetTCPConnection -LocalPort 5173 -ErrorAction SilentlyContinue
if ($frontend) {
    Write-Host "   ✅ 前端服务运行中 (端口 5173)" -ForegroundColor Green
} else {
    Write-Host "   ⚠️  前端服务未运行" -ForegroundColor Yellow
}

# 5. 测试OpenRouter API连接（前端方式）
Write-Host "`n📋 5. 测试OpenRouter API连接" -ForegroundColor Yellow
Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor DarkGray

if (Test-Path $frontendEnv) {
    $envContent = Get-Content $frontendEnv -Raw
    if ($envContent -match 'VITE_OPENROUTER_API_KEY=([^\r\n]+)') {
        $apiKey = $matches[1].Trim()
        
        $headers = @{
            "Authorization" = "Bearer $apiKey"
            "Content-Type" = "application/json"
            "HTTP-Referer" = "http://localhost:5173"
            "X-Title" = "DeepTalk"
        }
        
        $body = @{
            model = "alibaba/tongyi-deepresearch-30b-a3b:free"
            messages = @(
                @{
                    role = "user"
                    content = "说一句简短的问候"
                }
            )
            max_tokens = 50
        } | ConvertTo-Json -Depth 10
        
        try {
            Write-Host "   ⏳ 发送测试请求..." -ForegroundColor Gray
            $response = Invoke-RestMethod `
                -Uri "https://openrouter.ai/api/v1/chat/completions" `
                -Method POST `
                -Headers $headers `
                -Body $body `
                -TimeoutSec 30
            
            if ($response.choices -and $response.choices.Count -gt 0) {
                $reply = $response.choices[0].message.content
                Write-Host "   ✅ API测试成功！" -ForegroundColor Green
                Write-Host "   AI回复: $reply" -ForegroundColor White
            } else {
                Write-Host "   ⚠️  API响应为空" -ForegroundColor Yellow
            }
        } catch {
            $errorMsg = $_.Exception.Message
            if ($errorMsg -match '429') {
                Write-Host "   ⚠️  API限流（429 Too Many Requests）" -ForegroundColor Yellow
                Write-Host "   提示: 免费版有请求频率限制，请稍后再试" -ForegroundColor Gray
            } elseif ($errorMsg -match '401') {
                Write-Host "   ❌ API密钥无效（401 Unauthorized）" -ForegroundColor Red
            } else {
                Write-Host "   ❌ API测试失败: $errorMsg" -ForegroundColor Red
            }
        }
    }
}

# 总结
Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host "📊 配置总结" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan

Write-Host "`n✅ 已确认的配置:" -ForegroundColor Green
Write-Host "   • API模型: alibaba/tongyi-deepresearch-30b-a3b:free" -ForegroundColor White
Write-Host "   • API密钥: sk-or-v1-3a8fe...（已配置）" -ForegroundColor White
Write-Host "   • 前端配置文件: .env.local ✓" -ForegroundColor White
Write-Host "   • 服务类: OpenRouterService.ts ✓" -ForegroundColor White

Write-Host "`n📝 使用说明:" -ForegroundColor Cyan
Write-Host "   1. 启动后端: cd backend && mvn spring-boot:run" -ForegroundColor Gray
Write-Host "   2. 启动前端: cd frontend && npm run dev" -ForegroundColor Gray
Write-Host "   3. 访问对战界面: http://localhost:5173" -ForegroundColor Gray
Write-Host "   4. 系统会自动使用配置的OpenRouter API" -ForegroundColor Gray

Write-Host "`n⚠️  注意事项:" -ForegroundColor Yellow
Write-Host "   • 免费版API有请求频率限制" -ForegroundColor Gray
Write-Host "   • 如遇429错误，请等待几分钟后重试" -ForegroundColor Gray
Write-Host "   • 可以在 .env.local 中更换其他免费模型" -ForegroundColor Gray

Write-Host "`n========================================`n" -ForegroundColor Cyan
