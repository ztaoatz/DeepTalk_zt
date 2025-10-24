// src/services/AIService.ts
import { HuggingFaceService, type ConversationContext } from './HuggingFaceService'
import { OpenRouterService } from './OpenRouterService'

export type AIServiceProvider = 'openrouter' | 'huggingface';

export class AIService {
  private aiSpeakingTimeout: number | null = null
  private huggingFaceService: HuggingFaceService
  private openRouterService: OpenRouterService
  private currentProvider: AIServiceProvider
  private isProcessing: boolean = false
  
  // 回调函数
  onSpeakingStateChange?: (isSpeaking: boolean) => void
  onResponseGenerated?: (response: string) => void
  onThinkingStateChange?: (isThinking: boolean) => void
  onErrorOccurred?: (error: string) => void

  constructor(provider: AIServiceProvider = 'openrouter') {
    this.huggingFaceService = new HuggingFaceService()
    this.openRouterService = new OpenRouterService()
    this.currentProvider = provider
    
    // 如果首选provider没有配置API密钥，自动切换
    if (provider === 'openrouter' && !this.openRouterService.isConfigured()) {
      console.warn('OpenRouter not configured, falling back to HuggingFace')
      this.currentProvider = 'huggingface'
    } else if (provider === 'huggingface' && !this.huggingFaceService.isConfigured()) {
      console.warn('HuggingFace not configured, trying OpenRouter')
      this.currentProvider = 'openrouter'
    }
  }

  /**
   * 获取当前活动的AI服务
   */
  private getCurrentService(): HuggingFaceService | OpenRouterService {
    return this.currentProvider === 'openrouter' 
      ? this.openRouterService 
      : this.huggingFaceService;
  }

  /**
   * 切换AI服务提供商
   */
  switchProvider(provider: AIServiceProvider): void {
    this.currentProvider = provider;
    console.log(`Switched to ${provider} provider`);
  }

  /**
   * 获取当前提供商
   */
  getCurrentProvider(): AIServiceProvider {
    return this.currentProvider;
  }

  /**
   * 设置对话上下文（主题、难度等）
   */
  setConversationContext(context: Partial<ConversationContext>): void {
    this.getCurrentService().setConversationContext(context)
  }
  /**
   * 基于用户语音文本生成AI回复
   */
  async generateResponseFromSpeech(userSpeechText: string): Promise<void> {
    if (this.isProcessing) {
      console.warn('AI is already processing a response')
      return
    }

    this.isProcessing = true
    
    try {
      // 通知开始思考
      this.onThinkingStateChange?.(true)
      
      console.log(`Generating AI response using ${this.currentProvider}:`, userSpeechText)
      
      // 调用当前AI服务生成回复
      const aiResponse = await this.getCurrentService().generateResponse(userSpeechText)
      
      console.log('AI response generated:', aiResponse)
      
      // 通知停止思考，开始说话
      this.onThinkingStateChange?.(false)
      this.onSpeakingStateChange?.(true)
      
      // 模拟AI说话时间（基于文本长度）
      const speakingDuration = Math.max(2000, Math.min(8000, aiResponse.length * 100))
      
      this.aiSpeakingTimeout = window.setTimeout(() => {
        this.onSpeakingStateChange?.(false)
        this.onResponseGenerated?.(aiResponse)
        this.aiSpeakingTimeout = null
      }, speakingDuration)

    } catch (error) {
      console.error('Error generating AI response:', error)
      this.onThinkingStateChange?.(false)
      this.onSpeakingStateChange?.(false)
      this.onErrorOccurred?.('AI回复生成失败，请稍后重试')
      
      // 使用备用回复
      this.generateFallbackResponse()
    } finally {
      this.isProcessing = false
    }
  }

  /**
   * 生成备用回复（当API失败时）
   */
  private generateFallbackResponse(): void {
    const fallbackResponses = [
      "That's a very interesting perspective. Could you tell me more about your experience with this?",
      "I understand your point. Have you considered the alternative viewpoint?",
      "That's a great example. How do you think this applies in different situations?",
      "Very thoughtful response. What do you think are the main challenges in this area?",
      "I see what you mean. How has this changed over the years in your opinion?"
    ]
    
    const randomResponse = fallbackResponses[Math.floor(Math.random() * fallbackResponses.length)]
    
    setTimeout(() => {
      this.onSpeakingStateChange?.(true)
      
      setTimeout(() => {
        this.onSpeakingStateChange?.(false)
        this.onResponseGenerated?.(randomResponse)
      }, 3000)
    }, 1000)
  }

  /**
   * 旧的开始说话方法（保持兼容性）
   */
  startSpeaking(): void {
    this.stopSpeaking()
    
    setTimeout(() => {
      if (this.onSpeakingStateChange) {
        this.onSpeakingStateChange(true)
      }
      
      // 模拟AI发言时长（随机5-15秒）
      const speakingDuration = Math.random() * 10000 + 5000
      
      this.aiSpeakingTimeout = window.setTimeout(() => {
        if (this.onSpeakingStateChange) {
          this.onSpeakingStateChange(false)
        }
        
        // 生成AI回复
        const aiResponses = [
          "That's a very interesting perspective. Could you tell me more about your experience with this?",
          "I understand your point. Have you considered the alternative viewpoint?",
          "That's a great example. How do you think this applies in different situations?",
          "Very thoughtful response. What do you think are the main challenges in this area?",
          "I see what you mean. How has this changed over the years in your opinion?"
        ]
        
        const randomResponse = aiResponses[Math.floor(Math.random() * aiResponses.length)]
        
        if (this.onResponseGenerated) {
          this.onResponseGenerated(randomResponse)
        }
        
        this.aiSpeakingTimeout = null
      }, speakingDuration)
    }, 1000)
  }

  stopSpeaking(): void {
    if (this.aiSpeakingTimeout) {
      clearTimeout(this.aiSpeakingTimeout)
      this.aiSpeakingTimeout = null
    }
    
    if (this.onSpeakingStateChange) {
      this.onSpeakingStateChange(false)
    }
  }

  cleanup(): void {
    this.stopSpeaking()
  }
}