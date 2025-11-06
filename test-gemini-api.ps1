# Test Gemini API Configuration
Write-Host "=====================================" -ForegroundColor Cyan
Write-Host "Gemini API Configuration Test" -ForegroundColor Cyan
Write-Host "=====================================" -ForegroundColor Cyan

$apiKey = "AIzaSyDbkdu50nrNDYgKuGaYowc_B0EXlKO_yzQ"
$apiUrl = "https://zjxx.lol/v1beta/models/gemini-2.5-flash:generateContent"

Write-Host "`n1. Testing Gemini API directly..." -ForegroundColor Yellow

$headers = @{
    "x-goog-api-key" = $apiKey
    "Content-Type" = "application/json"
}

$body = @{
    contents = @(
        @{
            parts = @(
                @{
                    text = "用一句话介绍人工智能。"
                }
            )
        }
    )
} | ConvertTo-Json -Depth 10

try {
    $response = Invoke-RestMethod -Uri $apiUrl -Method POST -Headers $headers -Body $body -TimeoutSec 30
    
    if ($response.candidates -and $response.candidates.Count -gt 0) {
        $text = $response.candidates[0].content.parts[0].text
        Write-Host "`n✅ Gemini API Test Successful!" -ForegroundColor Green
        Write-Host "Response: $text" -ForegroundColor White
    } else {
        Write-Host "`n⚠️ Unexpected response structure" -ForegroundColor Yellow
        Write-Host ($response | ConvertTo-Json -Depth 5) -ForegroundColor Gray
    }
} catch {
    Write-Host "`n❌ Gemini API Test Failed" -ForegroundColor Red
    Write-Host "Error: $($_.Exception.Message)" -ForegroundColor Red
}

Write-Host "`n2. Testing backend post creation with AI reply..." -ForegroundColor Yellow

$postBody = @{
    title = "Gemini API测试帖子"
    content = "这是一个测试帖子，用于验证Gemini API是否能正确生成回复。"
    authorId = "test-gemini-001"
    authorName = "Gemini测试员"
    authorAvatar = "https://via.placeholder.com/150"
} | ConvertTo-Json

try {
    $postResponse = Invoke-RestMethod -Uri "http://localhost:8080/api/community/posts/add" -Method POST -ContentType "application/json" -Body $postBody
    Write-Host "`n✅ Post created successfully!" -ForegroundColor Green
    Write-Host "Post ID: $($postResponse.id)" -ForegroundColor Cyan
    
    Write-Host "`n⏳ Waiting 8 seconds for AI reply generation..." -ForegroundColor Yellow
    Start-Sleep -Seconds 8
    
    $repliesResponse = Invoke-RestMethod -Uri "http://localhost:8080/api/community/posts/$($postResponse.id)/replies" -Method GET
    
    if ($repliesResponse.count -gt 0) {
        Write-Host "`n✅ AI Reply Generated!" -ForegroundColor Green
        $reply = $repliesResponse.replies[0]
        Write-Host "Author: $($reply.authorName)" -ForegroundColor Yellow
        Write-Host "AI Generated: $($reply.isAiGenerated)" -ForegroundColor Magenta
        Write-Host "Content: $($reply.content)" -ForegroundColor White
        
        # Check if it's a real AI response (not fallback)
        $fallbackKeywords = @("感谢分享", "很有见地", "很棒的帖子", "有价值", "很高兴")
        $isFallback = $false
        foreach ($keyword in $fallbackKeywords) {
            if ($reply.content -like "*$keyword*") {
                $isFallback = $true
                break
            }
        }
        
        if ($isFallback) {
            Write-Host "`n⚠️ Using fallback template - API may not be working" -ForegroundColor Yellow
        } else {
            Write-Host "`n🎉 Real Gemini AI response detected!" -ForegroundColor Green
        }
    } else {
        Write-Host "`n⚠️ No replies found" -ForegroundColor Yellow
    }
} catch {
    Write-Host "`n❌ Backend test failed" -ForegroundColor Red
    Write-Host "Error: $($_.Exception.Message)" -ForegroundColor Red
}

Write-Host "`n=====================================" -ForegroundColor Cyan
Write-Host "Test Complete" -ForegroundColor Cyan
Write-Host "=====================================" -ForegroundColor Cyan
