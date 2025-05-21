import http from '@ohos.net.http';

// 定义消息接口
interface Message {
  role: string;
  content: string;
}

// 定义搜索请求接口
interface SearchRequest {
  model: string;
  messages: Message[];
  stream: boolean;
}

// 定义消息内容接口
interface MessageContent {
  content: string;
}

// 定义选择接口
interface Choice {
  message: MessageContent;
}

// 定义搜索响应接口
interface SearchResponse {
  choices: Choice[];
}

export class SearchService {
  private static readonly API_KEY: string = 'a97309e6-5dfa-4b76-afd9-7ef5a8487726';
  private static readonly API_BASE: string = 'https://ark.cn-beijing.volces.com/api/v3';
  private static readonly MODEL: string = 'bot-20250521164120-wklvq';

  /**
   * 调用搜索API获取回复
   * @param query 用户输入的查询内容
   * @returns 返回Promise，包含搜索结果
   */
  async search(query: string): Promise<string> {
    try {
      // 创建HTTP请求对象
      let httpRequest = http.createHttp();
      
      // 创建消息对象
      const message: Message = {
        role: 'user',
        content: query
      };
      
      // 构建请求数据
      const requestData: SearchRequest = {
        model: SearchService.MODEL,
        messages: [message],
        stream: false // 在鸿蒙应用中不使用流式响应
      };
      
      // 定义请求头类型
      type HeaderType = Record<string, string>;
      
      // 构建请求头
      const headerObj: HeaderType = {
        'Content-Type': 'application/json',
        'Authorization': `Bearer ${SearchService.API_KEY}`
      };
      
      // 定义请求选项接口
      interface RequestOptions {
        method: http.RequestMethod;
        header: HeaderType;
        extraData: string;
        readTimeout: number;
        connectTimeout: number;
      }
      
      // 构建请求选项
      const options: RequestOptions = {
        method: http.RequestMethod.POST,
        header: headerObj,
        extraData: JSON.stringify(requestData),
        readTimeout: 60000, // 60秒超时
        connectTimeout: 60000
      };
      
      // 发送请求
      let response = await httpRequest.request(
        `${SearchService.API_BASE}/bots/chat/completions`,
        options
      );
      
      // 检查响应状态
      if (response.responseCode === 200) {
        // 解析响应数据
        const responseData: SearchResponse = JSON.parse(response.result.toString());
        // 返回搜索结果
        return responseData.choices[0].message.content;
      } else {
        // 返回错误信息
        return `错误: ${response.responseCode}, ${response.result}`;
      }
    } catch (error) {
      // 捕获并返回异常信息
      console.error(`搜索API调用失败: ${error}`);
      return `调用失败: ${error}`;
    }
  }
}

export default new SearchService();
