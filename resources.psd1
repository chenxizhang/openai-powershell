ConvertFrom-StringData -StringData @'
    error_missing_api_key = API key is missing. Please set the environment variable OPENAI_API_KEY or OPENAI_API_KEY_AZURE, or you can specify the parameter -api_key.
    error_missing_engine = Model is missing, Please set the environment variable OPENAI_ENGINE or OPENAI_ENGINE_AZURE, or you can specify the parameter -engine.
    error_missing_endpoint = Endpoint is missing, Please set the environment variable OPENAI_ENDPOINT or OPENAI_ENDPOINT_AZURE, or you can specify the parameter -endpoint.
    welcome = Welcome to OpenAI{0}'s world, The model you are currently using is: {1}, Please start with your prompt.
    shortcuts=Shortcuts：Press q and Enter to exit, Press m and Enter to input multi-lines prompt， Press f and Enter to select a file from disk.
    azure_version = (Azure)
    prompt = Prompt
    response = Answered as below, consumed tokes are : {0} = {1} + {2}
    multi_line_prompt = Please enter multiple lines of text
    cancel_button_message = You pressed the cancel button.
    multi_line_message = Your inputs are:
    file_prompt = Please select a file
    dialog_okbutton_text = Ok
    dialog_cancelbutton_text = Cancel
    update_prompt=We found new version of this module.`n`n{0}`n`nDo you want to update it now? [Y/N]
    update_success=Update successfully, please restart your PowerShell session.
    welcome_chatgpt = Welcome to ChatGPT {0}'s world, The model you are currently using is: {1}, Please start with your prompt.
    openai_unavaliable = You can't connect to openai service now, please check your network connection.

'@
