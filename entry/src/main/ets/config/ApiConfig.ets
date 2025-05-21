/**
 * API配置文件
 * 统一管理所有API相关的配置信息
 */

// API服务配置接口
interface ApiServiceConfig {
  MODEL: string;
  URL: string;
}

export default class ApiConfig {
  // API密钥
  static readonly API_KEY: string = 'a97309e6-5dfa-4b76-afd9-7ef5a8487726';
  static readonly API_BASE: string = 'https://ark.cn-beijing.volces.com/api/v3';
  
  // 聊天服务配置
  static readonly CHAT_API: ApiServiceConfig = {
    MODEL: 'doubao-1-5-pro-256k-250115',
    URL: 'https://ark.cn-beijing.volces.com/api/v3/chat/completions'
  };
  
  // 图像生成服务配置
  static readonly IMAGE_API: ApiServiceConfig = {
    MODEL: 'doubao-seedream-3-0-t2i-250415',
    URL: 'https://ark.cn-beijing.volces.com/api/v3/images/generations'
  };
  
  // 搜索服务配置
  static readonly SEARCH_API: ApiServiceConfig = {
    MODEL: 'bot-20250521164120-wklvq',
    URL: 'https://ark.cn-beijing.volces.com/api/v3/bots/chat/completions'
  };
}
