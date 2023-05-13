ConvertFrom-StringData -StringData @'
    error_missing_api_key = 请设置环境变量 OPENAI_API_KEY 或 OPENAI_API_KEY_AZURE 或者使用参数 -api_key
    error_missing_engine = 请设置环境变量 OPENAI_ENGINE 或 OPENAI_ENGINE_AZURE 或者使用参数 -engine
    error_missing_endpoint = 请设置环境变量 OPENAI_ENDPOINT 或 OPENAI_ENDPOINT_AZURE 或者使用参数 -endpoint
    welcome = 欢迎来到OpenAI{0}的世界, 当前使用的模型是: {1}, 请输入你的提示。
    shortcuts = 快捷键：按 q 并回车可退出对话, 按 m 并回车可输入多行文本， 按 f 并回车可从文件输入.
    azure_version = (Azure 版本)
    prompt = 提示
    response = 回答: 如下, 消耗的token数量: {0} = {1} + {2}
    multi_line_prompt = 请输入多行文本
    cancel_button_message = 你按下了取消按钮
    multi_line_message = 你输入的多行文本是:
    file_prompt = 请选择一个文件
    dialog_okbutton_text = 确定
    dialog_cancelbutton_text = 取消
    update_prompt=我们检测到了新版本，`n`n{0}`n`n推荐你立即更新，是否同意? [Y/N]
    update_success=更新已完成，你需要重新执行命令.
    welcome_chatgpt =欢迎来到 ChatGPT{0}的世界, 当前使用的模型是: {1}, 请开始对话吧.
    openai_unavaliable = 当前OpenAI服务无法访问，请检查网络链接.
'@