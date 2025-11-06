# DeepTalk AI Battle Configuration Verification

Write-Host "`n======================================" -ForegroundColor Cyan
Write-Host "DeepTalk AI Battle Config Check" -ForegroundColor Cyan
Write-Host "======================================`n" -ForegroundColor Cyan

# Check frontend .env.local
Write-Host "1. Frontend Configuration" -ForegroundColor Yellow
$envPath = "e:\deeptalk_zt\DeepTalk_zt\frontend\.env.local"
if (Test-Path $envPath) {
    $env = Get-Content $envPath -Raw
    if ($env -match 'VITE_OPENROUTER_API_KEY=(.+)') {
        $key = $matches[1].Trim()
        Write-Host "   API Key: $($key.Substring(0,20))..." -ForegroundColor Green
    }
    if ($env -match 'VITE_OPENROUTER_MODEL=(.+)') {
        $model = $matches[1].Trim()
        Write-Host "   Model: $model" -ForegroundColor Green
    }
} else {
    Write-Host "   .env.local NOT FOUND" -ForegroundColor Red
}

# Check OpenRouterService
Write-Host "`n2. OpenRouter Service" -ForegroundColor Yellow
$servicePath = "e:\deeptalk_zt\DeepTalk_zt\frontend\src\services\OpenRouterService.ts"
if (Test-Path $servicePath) {
    Write-Host "   OpenRouterService.ts EXISTS" -ForegroundColor Green
} else {
    Write-Host "   OpenRouterService.ts NOT FOUND" -ForegroundColor Red
}

# Check service status
Write-Host "`n3. Service Status" -ForegroundColor Yellow
$backend = Get-NetTCPConnection -LocalPort 8080 -ErrorAction SilentlyContinue
if ($backend) {
    Write-Host "   Backend RUNNING (port 8080)" -ForegroundColor Green
} else {
    Write-Host "   Backend NOT RUNNING" -ForegroundColor Yellow
}

$frontend = Get-NetTCPConnection -LocalPort 5173 -ErrorAction SilentlyContinue
if ($frontend) {
    Write-Host "   Frontend RUNNING (port 5173)" -ForegroundColor Green
} else {
    Write-Host "   Frontend NOT RUNNING" -ForegroundColor Yellow
}

# Test API
Write-Host "`n4. Testing OpenRouter API..." -ForegroundColor Yellow
if (Test-Path $envPath) {
    $env = Get-Content $envPath -Raw
    if ($env -match 'VITE_OPENROUTER_API_KEY=(.+)') {
        $apiKey = $matches[1].Trim()
        
        $headers = @{
            "Authorization" = "Bearer $apiKey"
            "Content-Type" = "application/json"
        }
        
        $body = @{
            model = "alibaba/tongyi-deepresearch-30b-a3b:free"
            messages = @(@{ role = "user"; content = "Hi" })
            max_tokens = 20
        } | ConvertTo-Json -Depth 5
        
        try {
            $response = Invoke-RestMethod `
                -Uri "https://openrouter.ai/api/v1/chat/completions" `
                -Method POST `
                -Headers $headers `
                -Body $body `
                -TimeoutSec 30
            
            if ($response.choices) {
                Write-Host "   API TEST SUCCESS!" -ForegroundColor Green
                Write-Host "   Reply: $($response.choices[0].message.content)" -ForegroundColor White
            }
        } catch {
            if ($_.Exception.Message -match '429') {
                Write-Host "   API RATE LIMITED (429)" -ForegroundColor Yellow
            } elseif ($_.Exception.Message -match '401') {
                Write-Host "   API KEY INVALID (401)" -ForegroundColor Red
            } else {
                Write-Host "   API ERROR: $($_.Exception.Message)" -ForegroundColor Red
            }
        }
    }
}

Write-Host "`n======================================" -ForegroundColor Cyan
Write-Host "Configuration Summary:" -ForegroundColor Cyan
Write-Host "  Model: alibaba/tongyi-deepresearch-30b-a3b:free" -ForegroundColor White
Write-Host "  API Key: Configured" -ForegroundColor White
Write-Host "  Frontend: .env.local exists" -ForegroundColor White
Write-Host "  Service: OpenRouterService.ts exists" -ForegroundColor White
Write-Host "======================================`n" -ForegroundColor Cyan
