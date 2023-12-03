# This is the profile file for openai-powershell module, you can define your own functions here and environment variables here, and this file can be reused for multiple machines.
# Author: Ares Chen (https://github.com/chenxizhang/openai-powershell)

# environment variables (you can define your own variables here, uncomment below lines to use them)

# # OPEN AI default environment
# $env:OPENAI_API_KEY =
# # AZURE OPENAI SERVICE default environment
# $env:OPENAI_API_KEY_AZURE =
# $env:OPENAI_ENDPOINT_AZURE =
# $env:OPENAI_ENGINE_AZURE =
# $env:OPENAI_CHAT_ENGINE_AZURE =

# # AZURE OPENAI SERVICE dev environment
# $env:OPENAI_API_KEY_AZURE_DEV =
# $env:OPENAI_ENDPOINT_AZURE_DEV =
# $env:OPENAI_ENGINE_AZURE_DEV =
# $env:OPENAI_CHAT_ENGINE_AZURE_DEV =

# Custom functions
# You can define some functions here, to simplify the usage of openai-powershell module, please don't forget to add the "global" keyword before the function name, so that the function can be used in other scripts.

# function global:gptcs($inputfile,$outfile){
#     chat -azure -system "c:\temp\cs.md" -prompt $inputfile | Out-File $outfile -Encoding utf8
# }
# Then you can use gptcs function in your powershell script like this:
# gptcs "c:\temp\mycode.cs" "c:\temp\out.cs"

# if you modify this file, please re-open the powershell console to make the changes take effect.