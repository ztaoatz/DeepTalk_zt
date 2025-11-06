# Test AI Reply - Simple Version
Write-Host "Testing AI Reply Generation..." -ForegroundColor Cyan

$body = @{
    title = "AI Technology Discussion"
    content = "I want to discuss the impact of artificial intelligence on modern education."
    authorId = "test-001"
    authorName = "Tester"
    authorAvatar = "https://via.placeholder.com/150"
} | ConvertTo-Json

Write-Host "Creating post..." -ForegroundColor Yellow
$post = Invoke-RestMethod -Uri "http://localhost:8080/api/community/posts/add" -Method POST -ContentType "application/json" -Body $body
Write-Host "Post ID: $($post.id)" -ForegroundColor Green

Write-Host "Waiting for AI reply..." -ForegroundColor Yellow
Start-Sleep -Seconds 8

Write-Host "Getting replies..." -ForegroundColor Yellow
$replies = Invoke-RestMethod -Uri "http://localhost:8080/api/community/posts/$($post.id)/replies" -Method GET

Write-Host "`n=== RESULTS ===" -ForegroundColor Cyan
Write-Host "Count: $($replies.count)"
if ($replies.count -gt 0) {
    $r = $replies.replies[0]
    Write-Host "Author: $($r.authorName)"
    Write-Host "AI: $($r.isAiGenerated)"
    Write-Host "Content: $($r.content)"
} else {
    Write-Host "No replies!" -ForegroundColor Red
}
