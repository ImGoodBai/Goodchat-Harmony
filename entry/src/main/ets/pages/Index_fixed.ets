import llmService from '../services/LlmService';
import imageService from '../services/ImageService';
import searchService from '../services/SearchService';
import ChatMessage from '../models/ChatMessage';

@Entry
@Component
struct Index {
  @State inputText: string = '';
  @State title: string = '智能助手';
  @State isLoading: boolean = false;
  @State errorMessage: string = '';
  @State chatMessages: ChatMessage[] = [];
  @State showChat: boolean = false;
  @State modelType: string = 'chat'; // 'chat', 'image' 或 'search'
  @State imageUrl: string = '';

  /**
   * 获取当前模式的图标
   */
  getModelIcon(): string {
    switch (this.modelType) {
      case 'chat':
        return '🤖'; // 机器人
      case 'image':
        return '🎨'; // 画笔
      case 'search':
        return '🔍'; // 放大镜
      default:
        return '🤖';
    }
  }
  
  /**
   * 获取当前模式的标题
   */
  getModelTitle(): string {
    switch (this.modelType) {
      case 'chat':
        return '与智能助手对话';
      case 'image':
        return '生成AI图像';
      case 'search':
        return '实时搜索信息';
      default:
        return '与智能助手对话';
    }
  }
  
  /**
   * 获取输入框提示文本
   */
  getInputPlaceholder(): string {
    switch (this.modelType) {
      case 'chat':
        return '请输入您的问题...';
      case 'image':
        return '请输入图像描述...';
      case 'search':
        return '请输入搜索内容...';
      default:
        return '请输入您的问题...';
    }
  }
  
  /**
   * 获取按钮文本
   */
  getButtonText(): string {
    switch (this.modelType) {
      case 'chat':
        return '发送';
      case 'image':
        return '生成';
      case 'search':
        return '搜索';
      default:
        return '发送';
    }
  }

  build() {
    Column() {
      // 内容区域限制最大宽度
      Column() {
        // 标题区域和模型切换
        Row() {
          Text(this.title)
            .id('Title')
            .fontSize(28)
            .fontWeight(FontWeight.Bold)
          
          Blank()
          
          // 模型切换按钮
          Row() {
            Radio({ value: 'chat', group: 'modelType' })
              .checked(this.modelType === 'chat')
              .onChange((isChecked: boolean) => {
                if (isChecked) {
                  this.modelType = 'chat';
                }
              })
            Text('聊天')
              .fontSize(16)
              .margin({ right: 10 })
            
            Radio({ value: 'image', group: 'modelType' })
              .checked(this.modelType === 'image')
              .onChange((isChecked: boolean) => {
                if (isChecked) {
                  this.modelType = 'image';
                }
              })
            Text('画图')
              .fontSize(16)
              .margin({ right: 10 })
              
            Radio({ value: 'search', group: 'modelType' })
              .checked(this.modelType === 'search')
              .onChange((isChecked: boolean) => {
                if (isChecked) {
                  this.modelType = 'search';
                }
              })
            Text('搜索')
              .fontSize(16)
          }
          .width('auto')
        }
        .width('100%')
        .margin({ top: 20, bottom: 20 })

        if (!this.showChat) {
          // 首页搜索界面
          Column() {
            // 使用文本替代图标
            Text(this.getModelIcon())
              .fontSize(80)
              .margin({ top: 80, bottom: 40 })

            Text(this.getModelTitle())
              .fontSize(24)
              .fontWeight(FontWeight.Medium)
              .margin({ bottom: 60 })

            Row() {
              TextInput({ placeholder: this.getInputPlaceholder() })
                .width('70%')
                .height(50)
                .borderRadius(25)
                .backgroundColor('#f5f5f5')
                .padding({ left: 20, right: 20 })
                .onChange((value: string) => {
                  this.inputText = value;
                })

              Button() {
                Row() {
                  if (this.isLoading) {
                    LoadingProgress()
                      .width(20)
                      .height(20)
                      .color(Color.White)
                  } else {
                    Text(this.getButtonText())
                      .fontColor(Color.White)
                  }
                }
              }
              .width('15%')
              .height(50)
              .borderRadius(25)
              .backgroundColor('#1976D2')
              .margin({ left: 10 })
              .onClick(() => {
                this.sendMessage();
              })
            }
            .width('90%')
            .justifyContent(FlexAlign.Center)
          }
          .width('100%')
          .height('100%')
          .justifyContent(FlexAlign.Start)
          .alignItems(HorizontalAlign.Center)
        } else {
          // 聊天界面
          Column() {
            // 聊天消息区域
            Scroll() {
              Column() {
                ForEach(this.chatMessages, (message: ChatMessage) => {
                  // 根据消息类型显示不同样式
                  if (message.type === 'user') {
                    // 用户消息 - 右侧
                    Row() {
                      Column() {
                        Text(message.content)
                          .fontSize(16)
                          .backgroundColor('#DCF8C6')
                          .padding(15)
                          .borderRadius(10)
                          .width('100%')
                      }
                      .alignItems(HorizontalAlign.End)
                      .width('80%')
                    }
                    .width('100%')
                    .justifyContent(FlexAlign.End)
                    .margin({ top: 10, bottom: 10 })
                  } else if (message.type === 'assistant') {
                    // AI文本回复 - 左侧
                    Row() {
                      Column() {
                        Text(message.content)
                          .fontSize(16)
                          .padding(15)
                          .borderRadius(10)
                          .width('100%')
                      }
                      .alignItems(HorizontalAlign.Start)
                      .width('80%')
                    }
                    .width('100%')
                    .justifyContent(FlexAlign.Start)
                    .margin({ top: 10, bottom: 10 })
                  } else if (message.type === 'image') {
                    // AI图像回复 - 右侧
                    Row() {
                      Column() {
                        if (message.content.startsWith('http')) {
                          Image(message.content)
                            .width('100%')
                            .aspectRatio(1)
                            .objectFit(ImageFit.Cover)
                            .borderRadius(10)
                        } else {
                          Text(message.content)
                            .fontSize(16)
                            .backgroundColor('#EAEAEA')
                            .padding(15)
                            .borderRadius(10)
                            .width('100%')
                        }
                      }
                      .alignItems(HorizontalAlign.Start)
                      .width('80%')
                    }
                    .width('100%')
                    .justifyContent(FlexAlign.End)
                    .margin({ top: 10, bottom: 10 })
                  }
                })

                // 加载中指示器
                if (this.isLoading) {
                  Row() {
                    LoadingProgress()
                      .width(24)
                      .height(24)
                      .color('#1976D2')
                    Text('正在思考...')
                      .fontSize(14)
                      .fontColor('#666666')
                      .margin({ left: 10 })
                  }
                  .width('100%')
                  .justifyContent(FlexAlign.Start)
                  .padding({ left: 20 })
                  .margin({ top: 10, bottom: 10 })
                }
              }
              .width('90%')
              .padding(10)
            }
            .scrollBar(BarState.Auto)
            .scrollBarColor(Color.Gray)
            .scrollBarWidth(4)
            .edgeEffect(EdgeEffect.Spring)
            .width('100%')
            .height('85%')

            // 错误信息显示
            if (this.errorMessage !== '') {
              Text(this.errorMessage)
                .fontSize(14)
                .fontColor(Color.Red)
                .width('90%')
                .margin({ top: 5, bottom: 5 })
            }

            // 底部输入区
            Row() {
              TextInput({ placeholder: '输入消息...' })
                .width('75%')
                .height(50)
                .borderRadius(25)
                .backgroundColor('#f5f5f5')
                .padding({ left: 20, right: 20 })
                .onChange((value: string) => {
                  this.inputText = value;
                })

              Button() {
                Row() {
                  if (this.isLoading) {
                    LoadingProgress()
                      .width(20)
                      .height(20)
                      .color(Color.White)
                  } else {
                    Text('发送')
                      .fontColor(Color.White)
                  }
                }
              }
              .width('15%')
              .height(50)
              .borderRadius(25)
              .backgroundColor('#1976D2')
              .margin({ left: 10 })
              .onClick(() => {
                this.sendMessage();
              })
            }
            .width('90%')
            .justifyContent(FlexAlign.Center)
            .margin({ top: 10 })
          }
          .width('100%')
          .height('100%')
        }
      }
      .width('100%')
      .maxWidth('900px')
      .alignSelf(ItemAlign.Center)
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#ffffff')
  }

  /**
   * 发送消息并获取AI回复
   */
  async sendMessage() {
    if (this.inputText.trim() === '') {
      this.errorMessage = this.getInputPlaceholder();
      return;
    }

    try {
      // 设置状态
      this.isLoading = true;
      this.errorMessage = '';
      
      // 创建用户消息
      const userMessage = new ChatMessage(this.inputText, 'user');
      
      // 如果是第一条消息，切换到聊天界面
      if (this.chatMessages.length === 0) {
        this.showChat = true;
      }
      
      // 添加用户消息
      this.chatMessages.push(userMessage);
      
      // 清空输入框
      this.inputText = '';

      // 根据模型类型调用不同的服务
      switch (this.modelType) {
        case 'chat':
          // 调用LLM服务
          const chatResponse = await llmService.queryLlm(userMessage.content);
          
          // 创建AI回复消息
          const aiMessage = new ChatMessage(chatResponse, 'assistant');
          
          // 添加AI回复
          this.chatMessages.push(aiMessage);
          break;
          
        case 'image':
          // 调用画图服务
          const loadingMessage = new ChatMessage('正在生成图像...', 'image');
          this.chatMessages.push(loadingMessage);
          
          // 调用图像生成服务
          const imageUrl = await imageService.generateImage(userMessage.content);
          
          // 移除加载中消息
          this.chatMessages.pop();
          
          // 创建AI图像回复消息
          const imageMessage = new ChatMessage(imageUrl, 'image');
          
          // 添加AI图像回复
          this.chatMessages.push(imageMessage);
          break;
          
        case 'search':
          // 调用搜索服务
          const searchLoadingMessage = new ChatMessage('正在搜索信息...', 'assistant');
          this.chatMessages.push(searchLoadingMessage);
          
          // 调用搜索服务
          const searchResponse = await searchService.search(userMessage.content);
          
          // 移除加载中消息
          this.chatMessages.pop();
          
          // 创建搜索结果消息
          const searchResultMessage = new ChatMessage(searchResponse, 'assistant');
          
          // 添加搜索结果
          this.chatMessages.push(searchResultMessage);
          break;
      }
    } catch (error) {
      this.errorMessage = `查询失败: ${error}`;
      console.error(`API调用失败: ${error}`);
    } finally {
      this.isLoading = false;
    }
  }
}
