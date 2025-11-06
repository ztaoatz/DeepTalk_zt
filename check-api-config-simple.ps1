# API Key Configuration Check
Write-Host "================================" -ForegroundColor Cyan
Write-Host "OpenRouter API Key Config Check" -ForegroundColor Cyan
Write-Host "================================" -ForegroundColor Cyan

# 1. Check current session env var
Write-Host "`n[1] Current Session Environment Variable:" -ForegroundColor Yellow
if ($env:OPENROUTER_API_KEY) {
    $preview = $env:OPENROUTER_API_KEY.Substring(0, 20)
    Write-Host "  OK: OPENROUTER_API_KEY = $preview..." -ForegroundColor Green
} else {
    Write-Host "  NOT SET in current session" -ForegroundColor Red
}

# 2. Check system env var
Write-Host "`n[2] System Environment Variable:" -ForegroundColor Yellow
$sysKey = [System.Environment]::GetEnvironmentVariable("OPENROUTER_API_KEY", "Machine")
if ($sysKey) {
    $preview = $sysKey.Substring(0, 20)
    Write-Host "  OK: OPENROUTER_API_KEY = $preview..." -ForegroundColor Green
} else {
    Write-Host "  NOT SET in system" -ForegroundColor Gray
}

# 3. Check user env var
Write-Host "`n[3] User Environment Variable:" -ForegroundColor Yellow
$userKey = [System.Environment]::GetEnvironmentVariable("OPENROUTER_API_KEY", "User")
if ($userKey) {
    $preview = $userKey.Substring(0, 20)
    Write-Host "  OK: OPENROUTER_API_KEY = $preview..." -ForegroundColor Green
} else {
    Write-Host "  NOT SET in user profile" -ForegroundColor Gray
}

# 4. Check backend service
Write-Host "`n[4] Backend Service Status:" -ForegroundColor Yellow
$port = Get-NetTCPConnection -LocalPort 8080 -ErrorAction SilentlyContinue
if ($port) {
    Write-Host "  OK: Backend running (PID: $($port.OwningProcess))" -ForegroundColor Green
} else {
    Write-Host "  ERROR: Backend not running" -ForegroundColor Red
}

# 5. Test API
Write-Host "`n[5] Testing API..." -ForegroundColor Yellow
try {
    $body = @{
        title = "Config Test"
        content = "Testing API key configuration"
        authorId = "test"
        authorName = "Tester"
        authorAvatar = "https://via.placeholder.com/150"
    } | ConvertTo-Json
    
    $post = Invoke-RestMethod -Uri "http://localhost:8080/api/community/posts/add" -Method POST -ContentType "application/json" -Body $body -TimeoutSec 10
    Write-Host "  OK: Post created (ID: $($post.id))" -ForegroundColor Green
    
    Start-Sleep -Seconds 6
    
    $replies = Invoke-RestMethod -Uri "http://localhost:8080/api/community/posts/$($post.id)/replies" -Method GET
    
    if ($replies.count -gt 0) {
        $aiReply = $replies.replies[0]
        Write-Host "  Reply Count: $($replies.count)" -ForegroundColor Cyan
        Write-Host "  AI Generated: $($aiReply.isAiGenerated)" -ForegroundColor Cyan
        Write-Host "  Content: $($aiReply.content)" -ForegroundColor White
        
        # Check if using fallback templates
        $fallbackKeywords = @("感谢分享", "很有见地", "很棒的帖子", "非常有价值", "很高兴看到")
        $isFallback = $false
        foreach ($keyword in $fallbackKeywords) {
            if ($aiReply.content -like "*$keyword*") {
                $isFallback = $true
                break
            }
        }
        
        if ($isFallback) {
            Write-Host "`n  WARNING: Using FALLBACK reply template" -ForegroundColor Yellow -BackgroundColor DarkYellow
            Write-Host "  API key may not be working" -ForegroundColor Yellow
        } else {
            Write-Host "`n  SUCCESS: Real AI reply generated!" -ForegroundColor Green -BackgroundColor DarkGreen
        }
    } else {
        Write-Host "  WARNING: No replies generated" -ForegroundColor Yellow
    }
    
} catch {
    Write-Host "  ERROR: $($_.Exception.Message)" -ForegroundColor Red
}

Write-Host "`n================================" -ForegroundColor Cyan
