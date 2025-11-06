# AI自动回复功能测试脚本

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "   DeepTalk AI自动回复功能测试" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

$baseUrl = "http://localhost:8080"
$headers = @{
    "Content-Type" = "application/json"
}

# 测试1: 发布新帖子（会自动生成AI回复）
Write-Host "📝 测试1: 发布新帖子..." -ForegroundColor Yellow
$postData = @{
    authorId = "test_user_123"
    post = @{
        id = ""
        title = "如何提高英语口语水平？"
        content = "我一直想提高自己的英语口语能力，但不知道从何入手。有没有什么好的方法或经验可以分享？最好是不需要花太多钱的那种。"
        author = @{
            id = "test_user_123"
            username = "学习者小王"
            avatar = "https://ui-avatars.com/api/?name=XW&background=random"
            authorLikes = 10
            authorPosts = 5
        }
        likesCount = 0
        createdAt = (Get-Date).ToString("o")
    }
} | ConvertTo-Json -Depth 5

try {
    $response = Invoke-RestMethod -Uri "$baseUrl/api/community/posts/add" -Method Post -Body $postData -Headers $headers
    
    if ($response.success) {
        Write-Host "✅ 发帖成功！" -ForegroundColor Green
        Write-Host "   帖子ID: $($response.post.id)" -ForegroundColor Gray
        Write-Host "   标题: $($response.post.title)" -ForegroundColor Gray
        
        $postId = $response.post.id
        
        # 等待AI回复生成
        Write-Host ""
        Write-Host "⏳ 等待AI回复生成（5秒）..." -ForegroundColor Yellow
        Start-Sleep -Seconds 5
        
        # 测试2: 获取帖子回复
        Write-Host ""
        Write-Host "🤖 测试2: 获取帖子回复..." -ForegroundColor Yellow
        
        $repliesResponse = Invoke-RestMethod -Uri "$baseUrl/api/community/posts/$postId/replies" -Method Get -Headers $headers
        
        if ($repliesResponse.success) {
            Write-Host "✅ 获取回复成功！" -ForegroundColor Green
            Write-Host "   回复数量: $($repliesResponse.count)" -ForegroundColor Gray
            
            if ($repliesResponse.count -gt 0) {
                Write-Host ""
                Write-Host "📨 回复列表:" -ForegroundColor Cyan
                Write-Host "========================================" -ForegroundColor Gray
                
                foreach ($reply in $repliesResponse.replies) {
                    Write-Host ""
                    if ($reply.isAiGenerated) {
                        Write-Host "🤖 AI助手 (AI生成)" -ForegroundColor Magenta
                    } else {
                        Write-Host "👤 $($reply.authorName)" -ForegroundColor Blue
                    }
                    Write-Host "   $($reply.content)" -ForegroundColor White
                    Write-Host "   时间: $($reply.createdAt)" -ForegroundColor Gray
                }
                
                Write-Host ""
                Write-Host "========================================" -ForegroundColor Gray
                Write-Host "✅ AI自动回复功能正常工作！" -ForegroundColor Green
            } else {
                Write-Host "⚠️  未找到AI回复，可能API未配置或生成失败" -ForegroundColor Yellow
                Write-Host "   请检查后端日志查看详细信息" -ForegroundColor Gray
            }
        } else {
            Write-Host "❌ 获取回复失败: $($repliesResponse.message)" -ForegroundColor Red
        }
        
    } else {
        Write-Host "❌ 发帖失败: $($response.message)" -ForegroundColor Red
    }
    
} catch {
    Write-Host "❌ 请求失败: $($_.Exception.Message)" -ForegroundColor Red
    Write-Host "   请确保后端服务正在运行 (http://localhost:8080)" -ForegroundColor Gray
}

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "测试完成！" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "提示:" -ForegroundColor Yellow
Write-Host "1. 如果AI回复未生成，请检查是否配置了OPENROUTER_API_KEY环境变量" -ForegroundColor Gray
Write-Host "2. 未配置API密钥时，会使用备用回复（预设的友好消息）" -ForegroundColor Gray
Write-Host "3. 可以在前端社区页面查看完整效果" -ForegroundColor Gray
Write-Host ""
