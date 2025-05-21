import http from '@ohos.net.http';

// 定义消息接口
interface Message {
  role: string;
  content: string;
}

// 定义请求数据接口
interface RequestData {
  model: string;
  messages: Message[];
  temperature: number;
  max_tokens: number;
}

// 定义请求选项接口
interface RequestOptions {
  method: http.RequestMethod;
  header: Record<string, string>;
  extraData: string;
  readTimeout: number;
  connectTimeout: number;
}

// 定义消息内容接口
interface MessageContent {
  content: string;
}

// 定义选择接口
interface Choice {
  message: MessageContent;
}

// 定义响应数据接口
interface ResponseData {
  choices: Choice[];
}

export class LlmService {
  private static readonly API_KEY: string = 'a97309e6-5dfa-4b76-afd9-7ef5a8487726';
  private static readonly API_BASE: string = 'https://ark.cn-beijing.volces.com/api/v3';
  private static readonly MODEL: string = 'doubao-1-5-pro-256k-250115';

  /**
   * 调用LLM API获取回复
   * @param prompt 用户输入的提示词
   * @returns 返回Promise，包含LLM的回复
   */
  async queryLlm(prompt: string): Promise<string> {
    try {
      // 创建HTTP请求对象
      let httpRequest = http.createHttp();
      
      // 构建请求数据
      const message: Message = {
        role: 'user',
        content: prompt
      };
      
      const requestData: RequestData = {
        model: LlmService.MODEL,
        messages: [message],
        temperature: 0.7,
        max_tokens: 800
      };
      
      // 构建请求选项
      const headerObj: Record<string, string> = {
        'Content-Type': 'application/json',
        'Authorization': `Bearer ${LlmService.API_KEY}`
      };
      
      let options: RequestOptions = {
        method: http.RequestMethod.POST,
        header: headerObj,
        extraData: JSON.stringify(requestData),
        readTimeout: 60000, // 60秒超时
        connectTimeout: 60000
      };
      
      // 发送请求
      let response = await httpRequest.request(
        `${LlmService.API_BASE}/chat/completions`,
        options
      );
      
      // 检查响应状态
      if (response.responseCode === 200) {
        // 解析响应数据
        const responseData: ResponseData = JSON.parse(response.result.toString());
        // 返回LLM的回复内容
        return responseData.choices[0].message.content;
      } else {
        // 返回错误信息
        return `错误: ${response.responseCode}, ${response.result}`;
      }
    } catch (error) {
      // 捕获并返回异常信息
      console.error(`LLM API调用失败: ${error}`);
      return `调用失败: ${error}`;
    }
  }
}

export default new LlmService();
