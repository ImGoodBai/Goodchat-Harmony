import http from '@ohos.net.http';

// 定义图像生成请求接口
interface ImageGenerationRequest {
  model: string;
  prompt: string;
  response_format: string;
  size: string;
  seed: number;
  guidance_scale: number;
  watermark: boolean;
}

// 定义URL接口
interface ImageUrl {
  url: string;
}

// 定义使用统计接口
interface ImageUsage {
  generated_images: number;
}

// 定义图像生成响应接口
interface ImageGenerationResponse {
  model: string;
  created: number;
  data: ImageUrl[];
  usage: ImageUsage;
}

export class ImageService {
  private static readonly API_KEY: string = 'a97309e6-5dfa-4b76-afd9-7ef5a8487726';
  private static readonly API_BASE: string = 'https://ark.cn-beijing.volces.com/api/v3';
  private static readonly MODEL: string = 'doubao-seedream-3-0-t2i-250415';

  /**
   * 调用豆包画图API生成图像
   * @param prompt 用户输入的提示词
   * @returns 返回Promise，包含生成图像的URL
   */
  async generateImage(prompt: string): Promise<string> {
    try {
      // 创建HTTP请求对象
      let httpRequest = http.createHttp();
      
      // 构建请求数据
      const requestData: ImageGenerationRequest = {
        model: ImageService.MODEL,
        prompt: prompt,
        response_format: 'url',
        size: '1024x1024',
        seed: Math.floor(Math.random() * 1000), // 随机种子
        guidance_scale: 2.5,
        watermark: true
      };
      
      // 构建请求头
      const headerObj: Record<string, string> = {
        'Content-Type': 'application/json',
        'Authorization': `Bearer ${ImageService.API_KEY}`
      };
      
      // 定义请求选项接口
      interface RequestOptions {
        method: http.RequestMethod;
        header: Record<string, string>;
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
        `${ImageService.API_BASE}/images/generations`,
        options
      );
      
      // 检查响应状态
      if (response.responseCode === 200) {
        // 解析响应数据
        const responseData: ImageGenerationResponse = JSON.parse(response.result.toString());
        // 返回生成图像的URL
        return responseData.data[0].url;
      } else {
        // 返回错误信息
        return `错误: ${response.responseCode}, ${response.result}`;
      }
    } catch (error) {
      // 捕获并返回异常信息
      console.error(`图像生成API调用失败: ${error}`);
      return `调用失败: ${error}`;
    }
  }
}

export default new ImageService();
