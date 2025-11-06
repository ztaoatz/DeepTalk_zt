# Test Post Creation and AI Reply Generation
Write-Host "=================================" -ForegroundColor Cyan
Write-Host "Testing Post Creation & AI Reply" -ForegroundColor Cyan
Write-Host "=================================" -ForegroundColor Cyan

$testPost = @{
    title = "Test AI Reply Generation"
    content = "This is a test post to verify that AI auto-reply is working correctly with qwen/qwen2.5-vl-32b-instruct:free model."
    authorId = "test-user-$(Get-Date -Format 'yyyyMMddHHmmss')"
    authorName = "Test User"
    authorAvatar = "https://via.placeholder.com/150"
} | ConvertTo-Json

Write-Host "`n1. Creating post..." -ForegroundColor Yellow
try {
    $postResponse = Invoke-RestMethod `
        -Uri "http://localhost:8080/api/community/posts/add" `
        -Method POST `
        -ContentType "application/json" `
        -Body $testPost `
        -TimeoutSec 10
    
    Write-Host "   ✅ Post created successfully!" -ForegroundColor Green
    Write-Host "   Post ID: $($postResponse.id)" -ForegroundColor Cyan
    $postId = $postResponse.id
    
    Write-Host "`n2. Waiting 8 seconds for AI reply generation..." -ForegroundColor Yellow
    Start-Sleep -Seconds 8
    
    Write-Host "`n3. Fetching replies..." -ForegroundColor Yellow
    $repliesUrl = "http://localhost:8080/api/community/posts/$postId/replies"
    Write-Host "   URL: $repliesUrl" -ForegroundColor Gray
    
    $repliesResponse = Invoke-RestMethod -Uri $repliesUrl -Method GET
    
    Write-Host "`n=================================" -ForegroundColor Cyan
    Write-Host "RESULTS" -ForegroundColor Cyan
    Write-Host "=================================" -ForegroundColor Cyan
    Write-Host "Reply Count: $($repliesResponse.count)" -ForegroundColor White
    
    if ($repliesResponse.count -gt 0) {
        foreach ($reply in $repliesResponse.replies) {
            Write-Host "`n---Reply---" -ForegroundColor DarkGray
            Write-Host "Author: $($reply.authorName)" -ForegroundColor Yellow
            Write-Host "AI Generated: $($reply.isAiGenerated)" -ForegroundColor $(if ($reply.isAiGenerated) {"Green"} else {"Red"})
            Write-Host "Content: $($reply.content)" -ForegroundColor White
            Write-Host "Created: $($reply.createdAt)" -ForegroundColor Gray
            
            # Check if it's a fallback template
            $fallbackKeywords = @("感谢分享", "很有见地", "很棒的帖子", "有价值的分享", "很高兴")
            $isFallback = $false
            foreach ($kw in $fallbackKeywords) {
                if ($reply.content -like "*$kw*") {
                    $isFallback = $true
                    break
                }
            }
            
            if ($isFallback) {
                Write-Host "`n⚠️ WARNING: Using fallback template!" -ForegroundColor Yellow
                Write-Host "This means the API call failed or timed out." -ForegroundColor Yellow
            } else {
                Write-Host "`n✅ SUCCESS: Real AI response generated!" -ForegroundColor Green
            }
        }
    } else {
        Write-Host "`n❌ No replies found!" -ForegroundColor Red
        Write-Host "Check backend logs for errors." -ForegroundColor Yellow
    }
    
} catch {
    Write-Host "`n❌ Error: $($_.Exception.Message)" -ForegroundColor Red
    if ($_.ErrorDetails.Message) {
        Write-Host "Details: $($_.ErrorDetails.Message)" -ForegroundColor Gray
    }
}

Write-Host "`n=================================" -ForegroundColor Cyan
Write-Host "`nNext Steps:" -ForegroundColor Yellow
Write-Host "1. Check backend console for detailed logs" -ForegroundColor Gray
Write-Host "2. Look for '🤖 开始生成AI回复' messages" -ForegroundColor Gray
Write-Host "3. Check for any error messages from OpenRouter API" -ForegroundColor Gray
