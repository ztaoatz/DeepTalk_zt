# Direct OpenRouter API Test
# Test the API key and model directly without going through backend

Write-Host "==================================" -ForegroundColor Cyan
Write-Host "OpenRouter API Direct Test" -ForegroundColor Cyan
Write-Host "==================================" -ForegroundColor Cyan

$apiKey = [System.Environment]::GetEnvironmentVariable("OPENROUTER_API_KEY", "User")
if (-not $apiKey) {
    Write-Host "ERROR: API key not found in user environment variables" -ForegroundColor Red
    exit 1
}

Write-Host "`nAPI Key: $($apiKey.Substring(0,20))..." -ForegroundColor Green
Write-Host "Model: alibaba/tongyi-deepresearch-30b-a3b:free" -ForegroundColor Cyan

$headers = @{
    "Authorization" = "Bearer $apiKey"
    "Content-Type" = "application/json"
    "HTTP-Referer" = "http://localhost:8080"
    "X-Title" = "DeepTalk"
}

$body = @{
    model = "alibaba/tongyi-deepresearch-30b-a3b:free"
    messages = @(
        @{
            role = "system"
            content = "You are a helpful assistant. Reply in Chinese."
        },
        @{
            role = "user"
            content = "请用一句话介绍人工智能。"
        }
    )
    temperature = 0.7
    max_tokens = 100
} | ConvertTo-Json -Depth 10

Write-Host "`nSending request to OpenRouter..." -ForegroundColor Yellow

try {
    $response = Invoke-RestMethod `
        -Uri "https://openrouter.ai/api/v1/chat/completions" `
        -Method POST `
        -Headers $headers `
        -Body $body `
        -TimeoutSec 30
    
    Write-Host "`n=== SUCCESS ===" -ForegroundColor Green
    Write-Host "Response received!" -ForegroundColor Green
    
    if ($response.choices -and $response.choices.Count -gt 0) {
        $content = $response.choices[0].message.content
        Write-Host "`nAI Reply:" -ForegroundColor Cyan
        Write-Host $content -ForegroundColor White
        Write-Host "`n=== API KEY IS WORKING ===" -ForegroundColor Green -BackgroundColor DarkGreen
    } else {
        Write-Host "WARNING: No content in response" -ForegroundColor Yellow
        Write-Host ($response | ConvertTo-Json -Depth 5) -ForegroundColor Gray
    }
    
} catch {
    Write-Host "`n=== FAILED ===" -ForegroundColor Red
    Write-Host "Error: $($_.Exception.Message)" -ForegroundColor Red
    
    if ($_.Exception.Response) {
        $reader = [System.IO.StreamReader]::new($_.Exception.Response.GetResponseStream())
        $errorBody = $reader.ReadToEnd()
        Write-Host "`nError Details:" -ForegroundColor Yellow
        Write-Host $errorBody -ForegroundColor Gray
    }
    
    Write-Host "`nPossible Issues:" -ForegroundColor Yellow
    Write-Host "1. API key invalid or expired" -ForegroundColor Gray
    Write-Host "2. Model not available" -ForegroundColor Gray
    Write-Host "3. Network connection problem" -ForegroundColor Gray
    Write-Host "4. Rate limit exceeded" -ForegroundColor Gray
}

Write-Host "`n==================================" -ForegroundColor Cyan
