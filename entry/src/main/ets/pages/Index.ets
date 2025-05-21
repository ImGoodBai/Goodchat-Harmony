import llmService from '../services/LlmService';
import ChatMessage from '../models/ChatMessage';

@Entry
@Component
struct Index {
  @State inputText: string = '';
  @State title: string = '智能聊天助手';
  @State isLoading: boolean = false;
  @State errorMessage: string = '';
  @State chatMessages: ChatMessage[] = [];
  @State showChat: boolean = false;

  build() {
    Column() {
      // 标题区域
      Text(this.title)
        .id('Title')
        .fontSize(28)
        .fontWeight(FontWeight.Bold)
        .margin({ top: 20, bottom: 20 })

      if (!this.showChat) {
        // 首页搜索界面
        Column() {
          // 使用文本替代图标
          Text('🤖')
            .fontSize(80)
            .margin({ top: 80, bottom: 40 })

          Text('与智能助手对话')
            .fontSize(24)
            .fontWeight(FontWeight.Medium)
            .margin({ bottom: 60 })

          Row() {
            TextInput({ placeholder: '请输入您的问题...' })
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
                  // 用户消息 - 左侧
                  Row() {
                    Column() {
                      Text(message.content)
                        .fontSize(16)
                        .backgroundColor('#DCF8C6')
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
                } else {
                  // AI回复 - 右侧
                  Row() {
                    Column() {
                      Text(message.content)
                        .fontSize(16)
                        .backgroundColor('#EAEAEA')
                        .padding(15)
                        .borderRadius(10)
                        .width('100%')
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
    .height('100%')
    .backgroundColor('#ffffff')
  }

  /**
   * 发送消息并获取AI回复
   */
  async sendMessage() {
    if (this.inputText.trim() === '') {
      this.errorMessage = '请输入消息';
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

      // 调用LLM服务
      const response = await llmService.queryLlm(userMessage.content);
      
      // 创建AI回复消息
      const aiMessage = new ChatMessage(response, 'assistant');
      
      // 添加AI回复
      this.chatMessages.push(aiMessage);
    } catch (error) {
      this.errorMessage = `查询失败: ${error}`;
      console.error(`LLM查询失败: ${error}`);
    } finally {
      this.isLoading = false;
    }
  }
}