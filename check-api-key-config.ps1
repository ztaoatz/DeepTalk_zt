# 检查API密钥配置状态
Write-Host "==================================" -ForegroundColor Cyan
Write-Host "🔍 OpenRouter API密钥配置检查" -ForegroundColor Cyan
Write-Host "==================================" -ForegroundColor Cyan

# 1. 检查当前PowerShell会话的环境变量
Write-Host "`n1️⃣ 当前会话环境变量:" -ForegroundColor Yellow
if ($env:OPENROUTER_API_KEY) {
    $keyPreview = $env:OPENROUTER_API_KEY.Substring(0, [Math]::Min(20, $env:OPENROUTER_API_KEY.Length))
    Write-Host "   ✅ OPENROUTER_API_KEY = $keyPreview..." -ForegroundColor Green
} else {
    Write-Host "   ❌ OPENROUTER_API_KEY 未设置" -ForegroundColor Red
}

# 2. 检查系统环境变量
Write-Host "`n2️⃣ 系统环境变量:" -ForegroundColor Yellow
$systemKey = [System.Environment]::GetEnvironmentVariable("OPENROUTER_API_KEY", "Machine")
if ($systemKey) {
    $keyPreview = $systemKey.Substring(0, [Math]::Min(20, $systemKey.Length))
    Write-Host "   ✅ OPENROUTER_API_KEY = $keyPreview..." -ForegroundColor Green
} else {
    Write-Host "   ℹ️ OPENROUTER_API_KEY 未在系统环境变量中设置" -ForegroundColor Gray
}

# 3. 检查用户环境变量
Write-Host "`n3️⃣ 用户环境变量:" -ForegroundColor Yellow
$userKey = [System.Environment]::GetEnvironmentVariable("OPENROUTER_API_KEY", "User")
if ($userKey) {
    $keyPreview = $userKey.Substring(0, [Math]::Min(20, $userKey.Length))
    Write-Host "   ✅ OPENROUTER_API_KEY = $keyPreview..." -ForegroundColor Green
} else {
    Write-Host "   ℹ️ OPENROUTER_API_KEY 未在用户环境变量中设置" -ForegroundColor Gray
}

# 4. 检查application.yml配置
Write-Host "`n4️⃣ application.yml配置:" -ForegroundColor Yellow
$ymlPath = "e:\deeptalk_zt\DeepTalk_zt\backend\src\main\resources\application.yml"
if (Test-Path $ymlPath) {
    $ymlContent = Get-Content $ymlPath -Raw
    if ($ymlContent -match 'openrouter:[\s\S]*?key:\s*\$\{OPENROUTER_API_KEY:([^}]*)\}') {
        $defaultValue = $matches[1]
        if ($defaultValue) {
            Write-Host "   ℹ️ 配置为从环境变量读取，默认值: '$defaultValue'" -ForegroundColor Gray
        } else {
            Write-Host "   ✅ 配置为从环境变量读取，无默认值（正确）" -ForegroundColor Green
        }
    } else {
        Write-Host "   ❌ 未找到openrouter.api.key配置" -ForegroundColor Red
    }
} else {
    Write-Host "   ❌ application.yml文件不存在" -ForegroundColor Red
}

# 5. 检查后端服务状态
Write-Host "`n5️⃣ 后端服务状态:" -ForegroundColor Yellow
$port8080 = Get-NetTCPConnection -LocalPort 8080 -ErrorAction SilentlyContinue
if ($port8080) {
    Write-Host "   ✅ 后端服务运行中 (PID: $($port8080.OwningProcess))" -ForegroundColor Green
    $process = Get-Process -Id $port8080.OwningProcess -ErrorAction SilentlyContinue
    if ($process) {
        Write-Host "   📅 启动时间: $($process.StartTime)" -ForegroundColor Gray
    }
} else {
    Write-Host "   ❌ 后端服务未运行" -ForegroundColor Red
}

# 6. 测试API连接
Write-Host "`n6️⃣ 测试后端API连接:" -ForegroundColor Yellow
try {
    $testBody = @{
        title = "API密钥配置测试"
        content = "这是一个自动化测试帖子，用于验证API密钥配置"
        authorId = "config-test"
        authorName = "配置测试"
        authorAvatar = "https://via.placeholder.com/150"
    } | ConvertTo-Json
    
    $response = Invoke-RestMethod -Uri "http://localhost:8080/api/community/posts/add" `
        -Method POST `
        -ContentType "application/json" `
        -Body $testBody `
        -TimeoutSec 10
    
    Write-Host "   ✅ API连接成功" -ForegroundColor Green
    Write-Host "   📝 帖子ID: $($response.id)" -ForegroundColor Gray
    
    # 等待AI回复
    Write-Host "   ⏳ 等待AI回复生成..." -ForegroundColor Gray
    Start-Sleep -Seconds 6
    
    # 获取回复
    $repliesResponse = Invoke-RestMethod -Uri "http://localhost:8080/api/community/posts/$($response.id)/replies" -Method GET
    
    if ($repliesResponse.count -gt 0) {
        $aiReply = $repliesResponse.replies | Where-Object { $_.isAiGenerated -eq $true } | Select-Object -First 1
        if ($aiReply) {
            Write-Host "   ✅ AI回复生成成功！" -ForegroundColor Green
            Write-Host "   💬 回复内容: $($aiReply.content)" -ForegroundColor White
            Write-Host "`n   🎉 API密钥配置正确！" -ForegroundColor Green -BackgroundColor DarkGreen
        } else {
            Write-Host "   ⚠️ 未检测到AI生成的回复" -ForegroundColor Yellow
            Write-Host "   💬 回复内容: $($repliesResponse.replies[0].content)" -ForegroundColor Gray
            if ($repliesResponse.replies[0].content -match "感谢分享|很有见地|很棒的帖子") {
                Write-Host "`n   ⚠️ 使用了备用回复模板，API密钥可能未生效" -ForegroundColor Yellow -BackgroundColor DarkYellow
            }
        }
    } else {
        Write-Host "   ❌ 未生成任何回复" -ForegroundColor Red
    }
    
} catch {
    Write-Host "   ❌ API测试失败: $($_.Exception.Message)" -ForegroundColor Red
}

Write-Host "`n==================================" -ForegroundColor Cyan
Write-Host "检查完成" -ForegroundColor Cyan
Write-Host "==================================" -ForegroundColor Cyan

# 提供建议
Write-Host "`n💡 建议:" -ForegroundColor Cyan
if (-not $env:OPENROUTER_API_KEY) {
    Write-Host "   1. 在启动Maven前设置环境变量:" -ForegroundColor Yellow
    Write-Host '      $env:OPENROUTER_API_KEY="your-api-key-here"' -ForegroundColor Gray
    Write-Host "   2. 或者设置为用户级环境变量（永久）:" -ForegroundColor Yellow
    Write-Host '      [System.Environment]::SetEnvironmentVariable("OPENROUTER_API_KEY", "your-key", "User")' -ForegroundColor Gray
}
