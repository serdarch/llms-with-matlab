# Large Language Models (LLMs) with MATLAB®

[![Open in MATLAB Online](https://www.mathworks.com/images/responsive/global/open-in-matlab-online.svg)](https://matlab.mathworks.com/open/github/v1?repo=matlab-deep-learning/llms-with-matlab) [![View Large Language Models (LLMs) with MATLAB on File Exchange](https://www.mathworks.com/matlabcentral/images/matlab-file-exchange.svg)](https://www.mathworks.com/matlabcentral/fileexchange/163796-large-language-models-llms-with-matlab) 

This repository contains code to connect MATLAB to the [OpenAI™ Chat Completions API](https://platform.openai.com/docs/guides/text-generation/chat-completions-api) (which powers ChatGPT™), OpenAI Images API (which powers DALL·E™), [Azure® OpenAI Service](https://learn.microsoft.com/en-us/azure/ai-services/openai/), and local [Ollama®](https://ollama.com/) models. This allows you to leverage the natural language processing capabilities of large language models directly within your MATLAB environment.

## Requirements

### MathWorks Products (https://www.mathworks.com)

- Requires MATLAB release R2024a or newer.
- Some examples require Text Analytics Toolbox™.

### 3rd Party Products:

- For OpenAI connections: An active OpenAI API subscription and API key.
- For Azure OpenAI Services: An active Azure subscription with OpenAI access, deployment, and API key.
- For Ollama: A local Ollama installation. Currently, only connections on `localhost` are supported, i.e., Ollama and MATLAB must run on the same machine.

## Setup

See these pages for instructions specific to the 3rd party product selected:

* [OpenAI](doc/OpenAI.md)
* [Azure](doc/Azure.md)
* [Ollama](doc/Ollama.md)


### MATLAB Online

To use this repository with MATLAB Online, click [![Open in MATLAB Online](https://www.mathworks.com/images/responsive/global/open-in-matlab-online.svg)](https://matlab.mathworks.com/open/github/v1?repo=matlab-deep-learning/llms-with-matlab)


### MATLAB Desktop

To use this repository with a local installation of MATLAB, first clone the repository. 

1. In the system command prompt, run:

    ```bash
    git clone https://github.com/matlab-deep-learning/llms-with-matlab.git
    ```
   
2. Open MATLAB and navigate to the directory where you cloned the repository.

3. Add the directory to the MATLAB path.

    ```matlab
    addpath('path/to/llms-with-matlab');
    ```

## Examples
To learn how to use this in your workflows, see [Examples](/examples/).

- [ProcessGeneratedTextinRealTimebyUsingChatGPTinStreamingMode.mlx](/examples/ProcessGeneratedTextinRealTimebyUsingChatGPTinStreamingMode.mlx): Learn to implement a simple chat that stream the response. 
- [SummarizeLargeDocumentsUsingChatGPTandMATLAB.mlx](/examples/SummarizeLargeDocumentsUsingChatGPTandMATLAB.mlx): Learn to create concise summaries of long texts with ChatGPT. (Requires Text Analytics Toolbox™)
- [CreateSimpleChatBot.mlx](/examples/CreateSimpleChatBot.mlx): Build a conversational chatbot capable of handling various dialogue scenarios using ChatGPT. (Requires Text Analytics Toolbox)
- [AnalyzeScientificPapersUsingFunctionCalls.mlx](/examples/AnalyzeScientificPapersUsingFunctionCalls.mlx): Learn how to create agents capable of executing MATLAB functions. 
- [AnalyzeTextDataUsingParallelFunctionCallwithChatGPT.mlx](/examples/AnalyzeTextDataUsingParallelFunctionCallwithChatGPT.mlx): Learn how to take advantage of parallel function calling. 
- [RetrievalAugmentedGenerationUsingChatGPTandMATLAB.mlx](/examples/RetrievalAugmentedGenerationUsingChatGPTandMATLAB.mlx): Learn about retrieval augmented generation with a simple use case. (Requires Text Analytics Toolbox™)
- [DescribeImagesUsingChatGPT.mlx](/examples/DescribeImagesUsingChatGPT.mlx): Learn how to use GPT-4 Turbo with Vision to understand the content of an image. 
- [AnalyzeSentimentinTextUsingChatGPTinJSONMode.mlx](/examples/AnalyzeSentimentinTextUsingChatGPTinJSONMode.mlx): Learn how to use JSON mode in chat completions
- [UsingDALLEToEditImages.mlx](/examples/UsingDALLEToEditImages.mlx): Learn how to generate images
- [UsingDALLEToGenerateImages.mlx](/examples/UsingDALLEToGenerateImages.mlx): Create variations of images and editimages. 

## License

The license is available in the [license.txt](license.txt) file in this GitHub repository.

## Community Support
[MATLAB Central](https://www.mathworks.com/matlabcentral)

Copyright 2023-2024 The MathWorks, Inc.
