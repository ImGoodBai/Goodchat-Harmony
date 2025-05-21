/**
 * 聊天消息模型
 */
export class ChatMessage {
  /**
   * 消息内容
   */
  content: string;
  
  /**
   * 消息类型：'user' 表示用户消息，'assistant' 表示AI回复
   */
  type: string;
  
  /**
   * 消息时间戳
   */
  timestamp: number;
  
  constructor(content: string, type: string) {
    this.content = content;
    this.type = type;
    this.timestamp = Date.now();
  }
}

export default ChatMessage;
