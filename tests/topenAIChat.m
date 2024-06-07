classdef topenAIChat < matlab.unittest.TestCase
% Tests for openAIChat

%   Copyright 2023-2024 The MathWorks, Inc.

    properties(TestParameter)
        ValidConstructorInput = iGetValidConstructorInput();
        InvalidConstructorInput = iGetInvalidConstructorInput();
        InvalidGenerateInput = iGetInvalidGenerateInput();  
        InvalidValuesSetters = iGetInvalidValuesSetters();  
    end
    
    methods(Test)
        % Test methods
        function generateAcceptsSingleStringAsInput(testCase)
            chat = openAIChat(APIKey="this-is-not-a-real-key");
            testCase.verifyWarningFree(@()generate(chat,"This is okay"));
            chat = openAIChat(APIKey='this-is-not-a-real-key');
            testCase.verifyWarningFree(@()generate(chat,"This is okay"));
        end

        function generateAcceptsMessagesAsInput(testCase)
            chat = openAIChat(APIKey="this-is-not-a-real-key");
            messages = openAIMessages;
            messages = addUserMessage(messages, "This should be okay.");

            testCase.verifyWarningFree(@()generate(chat,messages));
        end

        function constructChatWithAllNVP(testCase)
            functions = openAIFunction("funName");
            modelName = "gpt-3.5-turbo";
            temperature = 0;
            topP = 1;
            stop = ["[END]", "."];
            apiKey = "this-is-not-a-real-key";
            presenceP = -2;
            frequenceP = 2;
            systemPrompt = "This is a system prompt";
            timeout = 3;
            chat = openAIChat(systemPrompt, Tools=functions, ModelName=modelName, ...
                Temperature=temperature, TopProbabilityMass=topP, StopSequences=stop, APIKey=apiKey,...
                FrequencyPenalty=frequenceP, PresencePenalty=presenceP, TimeOut=timeout);

            testCase.verifyEqual(chat.ModelName, modelName);
            testCase.verifyEqual(chat.Temperature, temperature);
            testCase.verifyEqual(chat.TopProbabilityMass, topP);
            testCase.verifyEqual(chat.StopSequences, stop);
            testCase.verifyEqual(chat.FrequencyPenalty, frequenceP);
            testCase.verifyEqual(chat.PresencePenalty, presenceP);
        end

        function validConstructorCalls(testCase,ValidConstructorInput)
            if isempty(ValidConstructorInput.ExpectedWarning)
                chat = testCase.verifyWarningFree(...
                    @() openAIChat(ValidConstructorInput.Input{:}));
            else
                chat = testCase.verifyWarning(...
                    @() openAIChat(ValidConstructorInput.Input{:}), ...
                    ValidConstructorInput.ExpectedWarning);
            end
            properties = ValidConstructorInput.VerifyProperties;
            for prop=string(fieldnames(properties)).'
                testCase.verifyEqual(chat.(prop),properties.(prop),"Property " + prop);
            end
        end

        function errorsWhenPassingToolChoiceWithEmptyTools(testCase)
            chat = openAIChat(APIKey="this-is-not-a-real-key");

            testCase.verifyError(@()generate(chat,"input", ToolChoice="bla"), "llms:mustSetFunctionsForCall");
        end

        function settingToolChoiceWithNone(testCase)
            functions = openAIFunction("funName");
            chat = openAIChat(APIKey="this-is-not-a-real-key",Tools=functions);

            testCase.verifyWarningFree(@()generate(chat,"This is okay","ToolChoice","none"));
        end

        function settingSeedToInteger(testCase)
            chat = openAIChat(APIKey="this-is-not-a-real-key");

            testCase.verifyWarningFree(@()generate(chat,"This is okay", "Seed", 2));
        end

        function invalidInputsConstructor(testCase, InvalidConstructorInput)
            testCase.verifyError(@()openAIChat(InvalidConstructorInput.Input{:}), InvalidConstructorInput.Error);
        end

        function generateWithTools(testCase)
            import matlab.unittest.constraints.HasField

            f = openAIFunction("writePaperDetails", "Function to write paper details to a table.");
            f = addParameter(f, "name", type="string", description="Name of the paper.");
            f = addParameter(f, "url", type="string", description="URL containing the paper.");
            f = addParameter(f, "explanation", type="string", description="Explanation on why the paper is related to the given topic.");

            paperExtractor = openAIChat("You are an expert in extracting information from a paper.", Tools=f);

            input = join([
            "    <id>http://arxiv.org/abs/2406.04344v1</id>"
            "    <updated>2024-06-06T17:59:56Z</updated>"
            "    <published>2024-06-06T17:59:56Z</published>"
            "    <title>Verbalized Machine Learning: Revisiting Machine Learning with Language"
            "  Models</title>"
            "    <summary>  Motivated by the large progress made by large language models (LLMs), we"
            "introduce the framework of verbalized machine learning (VML). In contrast to"
            "conventional machine learning models that are typically optimized over a"
            "continuous parameter space, VML constrains the parameter space to be"
            "human-interpretable natural language. Such a constraint leads to a new"
            "perspective of function approximation, where an LLM with a text prompt can be"
            "viewed as a function parameterized by the text prompt. Guided by this"
            "perspective, we revisit classical machine learning problems, such as regression"
            "and classification, and find that these problems can be solved by an"
            "LLM-parameterized learner and optimizer. The major advantages of VML include"
            "(1) easy encoding of inductive bias: prior knowledge about the problem and"
            "hypothesis class can be encoded in natural language and fed into the"
            "LLM-parameterized learner; (2) automatic model class selection: the optimizer"
            "can automatically select a concrete model class based on data and verbalized"
            "prior knowledge, and it can update the model class during training; and (3)"
            "interpretable learner updates: the LLM-parameterized optimizer can provide"
            "explanations for why each learner update is performed. We conduct several"
            "studies to empirically evaluate the effectiveness of VML, and hope that VML can"
            "serve as a stepping stone to stronger interpretability and trustworthiness in"
            "ML."
            "</summary>"
            "    <author>"
            "      <name>Tim Z. Xiao</name>"
            "    </author>"
            "    <author>"
            "      <name>Robert Bamler</name>"
            "    </author>"
            "    <author>"
            "      <name>Bernhard Schölkopf</name>"
            "    </author>"
            "    <author>"
            "      <name>Weiyang Liu</name>"
            "    </author>"
            "    <arxiv:comment xmlns:arxiv='http://arxiv.org/schemas/atom'>Technical Report v1 (92 pages, 15 figures)</arxiv:comment>"
            "    <link href='http://arxiv.org/abs/2406.04344v1' rel='alternate' type='text/html'/>"
            "    <link title='pdf' href='http://arxiv.org/pdf/2406.04344v1' rel='related' type='application/pdf'/>"
            "    <arxiv:primary_category xmlns:arxiv='http://arxiv.org/schemas/atom' term='cs.LG' scheme='http://arxiv.org/schemas/atom'/>"
            "    <category term='cs.LG' scheme='http://arxiv.org/schemas/atom'/>"
            "    <category term='cs.CL' scheme='http://arxiv.org/schemas/atom'/>"
            "    <category term='cs.CV' scheme='http://arxiv.org/schemas/atom'/>"
            ], newline);

            topic = "Large Language Models";

            prompt =  "Given the following paper:" + newline + string(input)+ newline +...
                "Given the topic: "+ topic + newline + "Write the details to a table.";
            [~, response] = generate(paperExtractor, prompt);

            testCase.assertThat(response, HasField("tool_calls"));
            testCase.verifyEqual(response.tool_calls.type,'function');
            testCase.verifyEqual(response.tool_calls.function.name,'writePaperDetails');
            data = testCase.verifyWarningFree( ...
                @() jsondecode(response.tool_calls.function.arguments));
            testCase.verifyThat(data,HasField("name"));
            testCase.verifyThat(data,HasField("url"));
            testCase.verifyThat(data,HasField("explanation"));
        end

        function invalidInputsGenerate(testCase, InvalidGenerateInput)
            f = openAIFunction("validfunction");
            chat = openAIChat(Tools=f, APIKey="this-is-not-a-real-key");

            testCase.verifyError(@()generate(chat,InvalidGenerateInput.Input{:}), InvalidGenerateInput.Error);
        end

        function invalidSetters(testCase, InvalidValuesSetters)
            chat = openAIChat(APIKey="this-is-not-a-real-key");
            function assignValueToProperty(property, value)
                chat.(property) = value;
            end
            
            testCase.verifyError(@()assignValueToProperty(InvalidValuesSetters.Property,InvalidValuesSetters.Value), InvalidValuesSetters.Error);
        end

        function invalidGenerateInputforModel(testCase)
            chat = openAIChat(APIKey="this-is-not-a-real-key");
            image_path = "peppers.png";
            emptyMessages = openAIMessages;
            inValidMessages = addUserMessageWithImages(emptyMessages,"What is in the image?",image_path);

            testCase.verifyError(@()generate(chat,inValidMessages), "llms:invalidContentTypeForModel")
        end

        function noStopSequencesNoMaxNumTokens(testCase)
            chat = openAIChat(APIKey="this-is-not-a-real-key");

            testCase.verifyWarningFree(@()generate(chat,"This is okay"));
        end

        function createOpenAIChatWithStreamFunc(testCase)
            function seen = sf(str)
                persistent data;
                if isempty(data)
                    data = strings(1, 0);
                end
                % Append streamed text to an empty string array of length 1
                data = [data, str];
                seen = data;
            end
            chat = openAIChat(APIKey=getenv("OPENAI_KEY"), StreamFun=@sf);

            testCase.verifyWarningFree(@()generate(chat, "Hello world."));
            % Checking that persistent data, which is still stored in
            % memory, is greater than 1. This would mean that the stream
            % function has been called and streamed some text.
            testCase.verifyGreaterThan(numel(sf("")), 1);
        end

        function warningJSONResponseFormatGPT35(testCase)
            chat = @() openAIChat("You are a useful assistant", ...
                APIKey="this-is-not-a-real-key", ...
                ResponseFormat="json", ...
                ModelName="gpt-3.5-turbo");

            testCase.verifyWarning(@()chat(), "llms:warningJsonInstruction");
        end

        function createOpenAIChatWithOpenAIKey(testCase)
            chat = openAIChat("You are a useful assistant", ...
                APIKey=getenv("OPENAI_KEY"));

            testCase.verifyWarningFree(@()generate(chat, "Hello world."));
        end

        function createOpenAIChatWithOpenAIKeyLatestModel(testCase)
            chat = openAIChat("You are a useful assistant", ...
                APIKey=getenv("OPENAI_KEY"), ModelName="gpt-4o");

            testCase.verifyWarningFree(@()generate(chat, "Hello world."));
        end

        function keyNotFound(testCase)
            % to verify the error, we need to unset the environment variable
            % OPENAI_API_KEY, if given. Use a fixture to restore the
            % value on leaving the test point:
            import matlab.unittest.fixtures.EnvironmentVariableFixture
            testCase.applyFixture(EnvironmentVariableFixture("OPENAI_API_KEY","dummy"));
            unsetenv("OPENAI_API_KEY");
            testCase.verifyError(@()openAIChat, "llms:keyMustBeSpecified");
        end
    end    
end

function invalidValuesSetters = iGetInvalidValuesSetters()

invalidValuesSetters = struct( ...
    "InvalidTemperatureType", struct( ...
        "Property", "Temperature", ...
        "Value", "2", ...
        "Error", "MATLAB:invalidType"), ...
    ...
    "InvalidTemperatureSize", struct( ...
        "Property", "Temperature", ...
        "Value", [1 1 1], ...
        "Error", "MATLAB:expectedScalar"), ...
    ...
    "TemperatureTooLarge", struct( ...
        "Property", "Temperature", ...
        "Value", 20, ...
        "Error", "MATLAB:notLessEqual"), ...
    ...
    "TemperatureTooSmall", struct( ...
        "Property", "Temperature", ...
        "Value", -20, ...
        "Error", "MATLAB:expectedNonnegative"), ...
    ...
    "InvalidTopProbabilityMassType", struct( ...
        "Property", "TopProbabilityMass", ...
        "Value", "2", ...
        "Error", "MATLAB:invalidType"), ...
    ...
    "InvalidTopProbabilityMassSize", struct( ...
        "Property", "TopProbabilityMass", ...
        "Value", [1 1 1], ...
        "Error", "MATLAB:expectedScalar"), ...
    ...
    "TopProbabilityMassTooLarge", struct( ...
        "Property", "TopProbabilityMass", ...
        "Value", 20, ...
        "Error", "MATLAB:notLessEqual"), ...
    ...
    "TopProbabilityMassTooSmall", struct( ...
        "Property", "TopProbabilityMass", ...
        "Value", -20, ...
        "Error", "MATLAB:expectedNonnegative"), ...
    ...
    "WrongTypeStopSequences", struct( ...
        "Property", "StopSequences", ...
        "Value", 123, ...
        "Error", "MATLAB:validators:mustBeNonzeroLengthText"), ...
    ...
    "WrongSizeStopNonVector", struct( ...
        "Property", "StopSequences", ...
        "Value", repmat("stop", 4), ...
        "Error", "MATLAB:validators:mustBeVector"), ...
    ...
    "EmptyStopSequences", struct( ...
        "Property", "StopSequences", ...
        "Value", "", ...
        "Error", "MATLAB:validators:mustBeNonzeroLengthText"), ...
    ...
    "WrongSizeStopSequences", struct( ...
        "Property", "StopSequences", ...
        "Value", ["1" "2" "3" "4" "5"], ...
        "Error", "llms:stopSequencesMustHaveMax4Elements"), ...
    ...
    "InvalidPresencePenalty", struct( ...
        "Property", "PresencePenalty", ...
        "Value", "2", ...
        "Error", "MATLAB:invalidType"), ...
    ...
    "InvalidPresencePenaltySize", struct( ...
        "Property", "PresencePenalty", ...
        "Value", [1 1 1], ...
        "Error", "MATLAB:expectedScalar"), ...
    ...
    "PresencePenaltyTooLarge", struct( ...
        "Property", "PresencePenalty", ...
        "Value", 20, ...
        "Error", "MATLAB:notLessEqual"), ...
    ...
    "PresencePenaltyTooSmall", struct( ...
        "Property", "PresencePenalty", ...
        "Value", -20, ...
        "Error", "MATLAB:notGreaterEqual"), ...
    ...
    "InvalidFrequencyPenalty", struct( ...
        "Property", "FrequencyPenalty", ...
        "Value", "2", ...
        "Error", "MATLAB:invalidType"), ...
    ...
    "InvalidFrequencyPenaltySize", struct( ...
        "Property", "FrequencyPenalty", ...
        "Value", [1 1 1], ...
        "Error", "MATLAB:expectedScalar"), ...
    ...
    "FrequencyPenaltyTooLarge", struct( ...
        "Property", "FrequencyPenalty", ...
        "Value", 20, ...
        "Error", "MATLAB:notLessEqual"), ...
    ...
    "FrequencyPenaltyTooSmall", struct( ...
        "Property", "FrequencyPenalty", ...
        "Value", -20, ...
        "Error", "MATLAB:notGreaterEqual"));
end

function validConstructorInput = iGetValidConstructorInput()
% while it is valid to provide the key via an environment variable,
% this test set does not use that, for easier setup
validFunction = openAIFunction("funName");
validConstructorInput = struct( ...
    "JustKey", struct( ...
        "Input",{{"APIKey","this-is-not-a-real-key"}}, ...
        "ExpectedWarning", '', ...
        "VerifyProperties", struct( ...
                "Temperature", {1}, ...
                "TopProbabilityMass", {1}, ...
                "StopSequences", {{}}, ...
                "PresencePenalty", {0}, ...
                "FrequencyPenalty", {0}, ...
                "TimeOut", {10}, ...
                "FunctionNames", {[]}, ...
                "ModelName", {"gpt-3.5-turbo"}, ...
                "SystemPrompt", {[]}, ...
                "ResponseFormat", {"text"} ...
            ) ...
        ), ...
    "SystemPrompt", struct( ...
        "Input",{{"system prompt","APIKey","this-is-not-a-real-key"}}, ...
        "ExpectedWarning", '', ...
        "VerifyProperties", struct( ...
                "Temperature", {1}, ...
                "TopProbabilityMass", {1}, ...
                "StopSequences", {{}}, ...
                "PresencePenalty", {0}, ...
                "FrequencyPenalty", {0}, ...
                "TimeOut", {10}, ...
                "FunctionNames", {[]}, ...
                "ModelName", {"gpt-3.5-turbo"}, ...
                "SystemPrompt", {{struct("role","system","content","system prompt")}}, ...
                "ResponseFormat", {"text"} ...
            ) ...
        ), ...
    "Temperature", struct( ...
        "Input",{{"APIKey","this-is-not-a-real-key","Temperature",2}}, ...
        "ExpectedWarning", '', ...
        "VerifyProperties", struct( ...
                "Temperature", {2}, ...
                "TopProbabilityMass", {1}, ...
                "StopSequences", {{}}, ...
                "PresencePenalty", {0}, ...
                "FrequencyPenalty", {0}, ...
                "TimeOut", {10}, ...
                "FunctionNames", {[]}, ...
                "ModelName", {"gpt-3.5-turbo"}, ...
                "SystemPrompt", {[]}, ...
                "ResponseFormat", {"text"} ...
            ) ...
        ), ...
    "TopProbabilityMass", struct( ...
        "Input",{{"APIKey","this-is-not-a-real-key","TopProbabilityMass",0.2}}, ...
        "ExpectedWarning", '', ...
        "VerifyProperties", struct( ...
                "Temperature", {1}, ...
                "TopProbabilityMass", {0.2}, ...
                "StopSequences", {{}}, ...
                "PresencePenalty", {0}, ...
                "FrequencyPenalty", {0}, ...
                "TimeOut", {10}, ...
                "FunctionNames", {[]}, ...
                "ModelName", {"gpt-3.5-turbo"}, ...
                "SystemPrompt", {[]}, ...
                "ResponseFormat", {"text"} ...
            ) ...
        ), ...
    "StopSequences", struct( ...
        "Input",{{"APIKey","this-is-not-a-real-key","StopSequences",["foo","bar"]}}, ...
        "ExpectedWarning", '', ...
        "VerifyProperties", struct( ...
                "Temperature", {1}, ...
                "TopProbabilityMass", {1}, ...
                "StopSequences", {["foo","bar"]}, ...
                "PresencePenalty", {0}, ...
                "FrequencyPenalty", {0}, ...
                "TimeOut", {10}, ...
                "FunctionNames", {[]}, ...
                "ModelName", {"gpt-3.5-turbo"}, ...
                "SystemPrompt", {[]}, ...
                "ResponseFormat", {"text"} ...
            ) ...
        ), ...
    "PresencePenalty", struct( ...
        "Input",{{"APIKey","this-is-not-a-real-key","PresencePenalty",0.1}}, ...
        "ExpectedWarning", '', ...
        "VerifyProperties", struct( ...
                "Temperature", {1}, ...
                "TopProbabilityMass", {1}, ...
                "StopSequences", {{}}, ...
                "PresencePenalty", {0.1}, ...
                "FrequencyPenalty", {0}, ...
                "TimeOut", {10}, ...
                "FunctionNames", {[]}, ...
                "ModelName", {"gpt-3.5-turbo"}, ...
                "SystemPrompt", {[]}, ...
                "ResponseFormat", {"text"} ...
            ) ...
        ), ...
    "FrequencyPenalty", struct( ...
        "Input",{{"APIKey","this-is-not-a-real-key","FrequencyPenalty",0.1}}, ...
        "ExpectedWarning", '', ...
        "VerifyProperties", struct( ...
                "Temperature", {1}, ...
                "TopProbabilityMass", {1}, ...
                "StopSequences", {{}}, ...
                "PresencePenalty", {0}, ...
                "FrequencyPenalty", {0.1}, ...
                "TimeOut", {10}, ...
                "FunctionNames", {[]}, ...
                "ModelName", {"gpt-3.5-turbo"}, ...
                "SystemPrompt", {[]}, ...
                "ResponseFormat", {"text"} ...
            ) ...
        ), ...
    "TimeOut", struct( ...
        "Input",{{"APIKey","this-is-not-a-real-key","TimeOut",0.1}}, ...
        "ExpectedWarning", '', ...
        "VerifyProperties", struct( ...
                "Temperature", {1}, ...
                "TopProbabilityMass", {1}, ...
                "StopSequences", {{}}, ...
                "PresencePenalty", {0}, ...
                "FrequencyPenalty", {0}, ...
                "TimeOut", {0.1}, ...
                "FunctionNames", {[]}, ...
                "ModelName", {"gpt-3.5-turbo"}, ...
                "SystemPrompt", {[]}, ...
                "ResponseFormat", {"text"} ...
            ) ...
        ), ...
    "ResponseFormat", struct( ...
        "Input",{{"APIKey","this-is-not-a-real-key","ResponseFormat","json"}}, ...
        "ExpectedWarning", "llms:warningJsonInstruction", ...
        "VerifyProperties", struct( ...
                "Temperature", {1}, ...
                "TopProbabilityMass", {1}, ...
                "StopSequences", {{}}, ...
                "PresencePenalty", {0}, ...
                "FrequencyPenalty", {0}, ...
                "TimeOut", {10}, ...
                "FunctionNames", {[]}, ...
                "ModelName", {"gpt-3.5-turbo"}, ...
                "SystemPrompt", {[]}, ...
                "ResponseFormat", {"json"} ...
            ) ...
        ) ...
    );
end

function invalidConstructorInput = iGetInvalidConstructorInput()
validFunction = openAIFunction("funName");
invalidConstructorInput = struct( ...
    "InvalidResponseFormatValue", struct( ...
        "Input",{{"ResponseFormat", "foo" }},...
        "Error", "MATLAB:validators:mustBeMember"), ...
    ...
    "InvalidResponseFormatSize", struct( ...
        "Input",{{"ResponseFormat", ["text" "text"] }},...
        "Error", "MATLAB:validation:IncompatibleSize"), ...
    ...
    "InvalidResponseFormatModelCombination", struct( ...
        "Input", {{"APIKey", "this-is-not-a-real-key", "ModelName", "gpt-4", "ResponseFormat", "json"}}, ...
        "Error", "llms:invalidOptionAndValueForModel"), ...
    ...
    "InvalidStreamFunType", struct( ...
        "Input",{{"StreamFun", "2" }},...
        "Error", "MATLAB:validators:mustBeA"), ...
    ...
    "InvalidStreamFunSize", struct( ...
        "Input",{{"StreamFun", [1 1 1] }},...
        "Error", "MATLAB:validation:IncompatibleSize"), ...
    ...
    "InvalidTimeOutType", struct( ...
        "Input",{{"TimeOut", "2" }},...
        "Error", "MATLAB:validators:mustBeReal"), ...
    ...
    "InvalidTimeOutSize", struct( ...
        "Input",{{"TimeOut", [1 1 1] }},...
        "Error", "MATLAB:validation:IncompatibleSize"), ...
    ...
    "WrongTypeSystemPrompt",struct( ...
        "Input",{{ 123 }},...
        "Error","MATLAB:validators:mustBeTextScalar"),...
    ...
    "WrongSizeSystemPrompt",struct( ...
        "Input",{{ ["test"; "test"] }},...
        "Error","MATLAB:validators:mustBeTextScalar"),...
    ...
    "InvalidToolsType",struct( ...
        "Input",{{"Tools", "a" }},...
        "Error","MATLAB:validators:mustBeA"),...
    ...
    "InvalidToolsSize",struct( ...
        "Input",{{"Tools", repmat(validFunction, 2, 2) }},...
        "Error","MATLAB:validation:IncompatibleSize"),...
    ...
    "InvalidModelNameType",struct( ...
        "Input",{{ "ModelName", 0 }},...
        "Error","MATLAB:validators:mustBeMember"),...
    ...
    "InvalidModelNameSize",struct( ...
        "Input",{{ "ModelName", ["gpt-3.5-turbo",  "gpt-3.5-turbo"] }},...
        "Error","MATLAB:validation:IncompatibleSize"),...
    ...
    "InvalidModelNameOption",struct( ...
        "Input",{{ "ModelName", "gpt" }},...
        "Error","MATLAB:validators:mustBeMember"),...
    ...
    "InvalidTemperatureType",struct( ...
        "Input",{{ "Temperature" "2" }},...
        "Error","MATLAB:invalidType"),...
    ...
    "InvalidTemperatureSize",struct( ...
        "Input",{{ "Temperature" [1 1 1] }},...
        "Error","MATLAB:expectedScalar"),...
    ...
    "TemperatureTooLarge",struct( ...
        "Input",{{ "Temperature" 20 }},...
        "Error","MATLAB:notLessEqual"),...
    ...
    "TemperatureTooSmall",struct( ...
        "Input",{{ "Temperature" -20 }},...
        "Error","MATLAB:expectedNonnegative"),...
    ...
    "InvalidTopProbabilityMassType",struct( ...
        "Input",{{  "TopProbabilityMass" "2" }},...
        "Error","MATLAB:invalidType"),...
    ...
    "InvalidTopProbabilityMassSize",struct( ...
        "Input",{{  "TopProbabilityMass" [1 1 1] }},...
        "Error","MATLAB:expectedScalar"),...
    ...
    "TopProbabilityMassTooLarge",struct( ...
        "Input",{{  "TopProbabilityMass" 20 }},...
        "Error","MATLAB:notLessEqual"),...
    ...
    "TopProbabilityMassTooSmall",struct( ...
        "Input",{{ "TopProbabilityMass" -20 }},...
        "Error","MATLAB:expectedNonnegative"),...
    ...
    "WrongTypeStopSequences",struct( ...
        "Input",{{ "StopSequences" 123}},...
        "Error","MATLAB:validators:mustBeNonzeroLengthText"),...
    ...
    "WrongSizeStopNonVector",struct( ...
        "Input",{{ "StopSequences" repmat("stop", 4) }},...
        "Error","MATLAB:validators:mustBeVector"),...
    ...
    "EmptyStopSequences",struct( ...
        "Input",{{ "StopSequences" ""}},...
        "Error","MATLAB:validators:mustBeNonzeroLengthText"),...
    ...
    "WrongSizeStopSequences",struct( ...
        "Input",{{ "StopSequences" ["1" "2" "3" "4" "5"]}},...
        "Error","llms:stopSequencesMustHaveMax4Elements"),...
    ...
    "InvalidPresencePenalty",struct( ...
        "Input",{{ "PresencePenalty" "2" }},...
        "Error","MATLAB:invalidType"),...
    ...
    "InvalidPresencePenaltySize",struct( ...
        "Input",{{ "PresencePenalty" [1 1 1] }},...
        "Error","MATLAB:expectedScalar"),...
    ...
    "PresencePenaltyTooLarge",struct( ...
        "Input",{{ "PresencePenalty" 20 }},...
        "Error","MATLAB:notLessEqual"),...
    ...
    "PresencePenaltyTooSmall",struct( ...
        "Input",{{ "PresencePenalty" -20 }},...
        "Error","MATLAB:notGreaterEqual"),...
    ...
    "InvalidFrequencyPenalty",struct( ...
        "Input",{{ "FrequencyPenalty" "2" }},...
        "Error","MATLAB:invalidType"),...
    ...
    "InvalidFrequencyPenaltySize",struct( ...
        "Input",{{ "FrequencyPenalty" [1 1 1] }},...
        "Error","MATLAB:expectedScalar"),...
    ...
    "FrequencyPenaltyTooLarge",struct( ...
        "Input",{{ "FrequencyPenalty" 20 }},...
        "Error","MATLAB:notLessEqual"),...
    ...
    "FrequencyPenaltyTooSmall",struct( ...
        "Input",{{ "FrequencyPenalty" -20 }},...
        "Error","MATLAB:notGreaterEqual"),...
    ...
    "InvalidApiKeyType",struct( ...
        "Input",{{ "APIKey" 123 }},...
        "Error","MATLAB:validators:mustBeNonzeroLengthText"),...
    ...
    "InvalidApiKeySize",struct( ...
        "Input",{{ "APIKey" ["abc" "abc"] }},...
        "Error","MATLAB:validators:mustBeTextScalar"));
end

function invalidGenerateInput = iGetInvalidGenerateInput()
emptyMessages = openAIMessages;
validMessages = addUserMessage(emptyMessages,"Who invented the telephone?");

invalidGenerateInput = struct( ...
        "EmptyInput",struct( ...
            "Input",{{ [] }},...
            "Error","MATLAB:validation:IncompatibleSize"),...
        ...
        "InvalidInputType",struct( ...
            "Input",{{ 123 }},...
            "Error","llms:mustBeMessagesOrTxt"),...
        ...
        "EmptyMessages",struct( ...
            "Input",{{ emptyMessages }},...
            "Error","llms:mustHaveMessages"),...
        ...
        "InvalidMaxNumTokensType",struct( ...
            "Input",{{ validMessages  "MaxNumTokens" "2" }},...
            "Error","MATLAB:validators:mustBeNumericOrLogical"),...
        ...
        "InvalidMaxNumTokensValue",struct( ...
            "Input",{{ validMessages  "MaxNumTokens" 0 }},...
            "Error","MATLAB:validators:mustBePositive"),...
        ...
        "InvalidNumCompletionsType",struct( ...
            "Input",{{ validMessages  "NumCompletions" "2" }},...
            "Error","MATLAB:validators:mustBeNumericOrLogical"),...
        ...
        "InvalidNumCompletionsValue",struct( ...
            "Input",{{ validMessages  "NumCompletions" 0 }},...
            "Error","MATLAB:validators:mustBePositive"), ...
        ...
        "InvalidToolChoiceValue",struct( ...
            "Input",{{ validMessages  "ToolChoice" "functionDoesNotExist" }},...
            "Error","MATLAB:validators:mustBeMember"),...
        ...
        "InvalidToolChoiceType",struct( ...
            "Input",{{ validMessages  "ToolChoice" 0 }},...
            "Error","MATLAB:validators:mustBeTextScalar"),...
        ...
        "InvalidToolChoiceSize",struct( ...
            "Input",{{ validMessages  "ToolChoice" ["validfunction", "validfunction"] }},...
            "Error","MATLAB:validators:mustBeTextScalar"),...
        ...
        "InvalidSeed",struct( ...
            "Input",{{ validMessages  "Seed" "2" }},...
            "Error","MATLAB:validators:mustBeNumericOrLogical"));   
end