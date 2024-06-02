# Changelogs 


| Date       | Version  | Description                                                                 |
|------------|----------|-----------------------------------------------------------------------------|
| 2024-06-02 | v3.0.0.9 | Support save profile [#139](https://github.com/chenxizhang/openai-powershell/issues/139) |
| 2024-06-02 | v3.0.0.8 | Bug fix [#245](https://github.com/chenxizhang/openai-powershell/issues/245), update the help content.  |
| 2024-05-27 | v3.0.0.7 | Better profile and function support and bug fix [#175](https://github.com/chenxizhang/openai-powershell/issues/175) [#233](https://github.com/chenxizhang/openai-powershell/issues/233) [#231](https://github.com/chenxizhang/openai-powershell/issues/231) [#236](https://github.com/chenxizhang/openai-powershell/issues/236) [#238](https://github.com/chenxizhang/openai-powershell/issues/238) [#241](https://github.com/chenxizhang/openai-powershell/issues/241) . |
| 2024-05-26 | v3.0.0.6 | Support AAD authentication, and multiple environments. [#227](https://github.com/chenxizhang/openai-powershell/issues/227) |
| 2024-05-11 | v3.0.0.5 | System variables and default value for variable, minor bug fixes. [#211](https://github.com/chenxizhang/openai-powershell/issues/211) [#210](https://github.com/chenxizhang/openai-powershell/issues/210) [#208](https://github.com/chenxizhang/openai-powershell/issues/208)   |
| 2024-05-11 | v3.0.0.4 | Fixed encoding bug for PowerShell 5.1 [#206](https://github.com/chenxizhang/openai-powershell/issues/206)  |
| 2024-05-05 | v3.0.0.3 | Update the help content (both English and Chinese),and minor bug fixes  |
| 2024-05-05 | v3.0.0.2 | Update the help content (both English and Chinese)  |
| 2024-05-04 | v3.0.0.1 | Added function support [#172](https://github.com/chenxizhang/openai-powershell/issues/172)  |
| 2024-05-02 | v3.0.0.0 | Break changes version, re-design the New-ChatGPTConversation with more simple design. [#155](https://github.com/chenxizhang/openai-powershell/issues/155) [#154](https://github.com/chenxizhang/openai-powershell/issues/154) [#153](https://github.com/chenxizhang/openai-powershell/issues/153)  [#152](https://github.com/chenxizhang/openai-powershell/issues/152) |
| 2024-05-01 | v2.0.2.2 | Support databricks dbrx model, and update the readme file, add Chinese version. |
| 2024-05-01 | v2.0.2.1 | Update the help content, fully support Chinese and English.                   |
| 2024-04-29 | v2.0.2.0 | Fixed a bug related to streaming and prompt mode.                            |
| 2024-04-28 | v2.0.1.9 | Fixed a bug related to get content from prompt parameter.                    |
| 2024-04-28 | v2.0.1.8 | Fixed a bug related to get content from prompt parameter.                    |
| 2024-04-28 | v2.0.1.7 | Fixed a bug related to get content from prompt parameter.                    |
| 2024-04-27 | v2.0.1.6 | Fixed a bug related to azure openai service endpoint.                        |
| 2024-04-27 | v2.0.1.5 | Add context support, you can pass variable to prompt (both system and user prompt) at the runtime. |
| 2024-04-25 | v2.0.1.4 | Bug fixes.                                                                  |
| 2024-04-21 | v2.0.1.3 | Simplify the module,and re-design the New-ImageGeneration function.           |
| 2024-04-20 | v2.0.1.2 | Bug fixs.                                                                   |
| 2024-04-20 | v2.0.1.1 | Added local models support and other enhancements.                           |
| 2024-02-17 | v2.0.1.0 | Added json output support for chat.                                          |
| 2024-02-17 | v2.0.0.9 | Use can say "bye" to exit chat.                                              |
| 2024-02-17 | v2.0.0.8 | Fixed several issues on Mac and Linux.                                       |
| 2024-01-08 | v2.0.0.7 | Code signing the module.                                                    |
| 2024-01-06 | v2.0.0.6 | Add support to vision completion, and prompt library support. you can submit prompt by submit-prompt and use a prompt from the library in all the cmdlets. |
| 2023-12-15 | v2.0.0.5 | Enhance support online image, add outFile parameter, add alias to environment parameter. |
| 2023-12-15 | v2.0.0.4 | Support online prompt file (system or user prompt), and online image.        |
| 2023-12-15 | v2.0.0.3 | Add alias to engine parameter (model, or deployment).                        |
| 2023-12-15 | v2.0.0.2 | Add support to gpt-4-vision to generate completion from images.              |
| 2023-12-04 | v2.0.0.1 | Fix a bug (speical character parameter definition, caused by the PowerShell 5.x compatibility). |
| 2023-12-03 | v2.0.0.0 | Add file input function, and custom profile support, and telemetry collection support. |
| 2023-11-26 | v1.1.1.4 | PowerShell 5.x supports.                                                    |
| 2023-11-26 | v1.1.1.3 | Multiple environment and DALL-E 3 support, and fix a lot of bugs.             |
| 2023-10-23 | v1.1.1.2 | Fix a bug (ConvertTo-Json truncate the result).                              |
| 2023-09-25 | v1.1.1.1 | Fix a bug (New-ImageGeneration, or image alias).                             |
| 2023-09-24 | v1.1.1.0 | Add image generation support (New-ImageGeneration, or image alias).          |
| 2023-09-23 | v1.1.1.0 | Add dynamic configuration support for New-ChatGPTConversation,see -config parameter. |
| 2023-09-17 | v1.1.1.0 | Add verbose support.                                                        |
| 2023-09-10 | v1.1.1.0 | Fix the help doc for New-ChatGPTConversation.                                |
| 2023-09-06 | v1.1.1.0 | Bug fix.                                                                    |
| 2023-09-06 | v1.1.1.0 | Added chat completion support.                                               |
| 2023-08-12 | v1.1.1.0 | Added stream support for chat.                                               |
| 2021-05-13 | v1.1.1.0 | Small enhancements (save result to clipboard, print the system prompt, etc.). |
| 2021-05-13 | v1.1.1.0 | Simplify the module structure.                                               |
| 2023-05-07 | v1.0.4.12 | Fixed the network connectivity test logic.                                   |
| 2023-05-07 | v1.0.4.11 | Added azure OpenAI supporrt for New-ChatGPTConversation function.            |
| 2023-05-07 | v1.0.4.10 | Added network connectivity test logic.                                       |
| 2023-03-09 | v1.0.4.9  | Added change logs in the description.                                        |
| 2023-03-08 | v1.0.4.8  | Added error handling.                                                        |