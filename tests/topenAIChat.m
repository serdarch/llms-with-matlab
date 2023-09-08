classdef topenAIChat < matlab.unittest.TestCase
% Tests for openAIChat

%   Copyright 2023 The MathWorks, Inc.

    methods (TestClassSetup)
        function saveEnvVar(testCase)
            % Ensures key is not in environment variable for tests
            openAIEnvVar = "OPENAI_API_KEY";
            if isenv(openAIEnvVar)
                key = getenv(openAIEnvVar);
                unsetenv(openAIEnvVar);
                testCase.addTeardown(@(x) setenv(openAIEnvVar, x), key);
            end
        end
    end

    properties(TestParameter)
        InvalidConstructorInput = iGetInvalidConstructorInput;
        InvalidGenerateInput = iGetInvalidGenerateInput;  
        InvalidValuesSetters = iGetInvalidValuesSetters;  
    end
    
    methods(Test)
        % Test methods
        function generateAcceptsSingleStringAsInput(testCase)
            chat = openAIChat(ApiKey="this-is-not-a-real-key");
            testCase.verifyWarningFree(@()generate(chat,"This is okay"));
        end

        function generateAcceptsMessagesAsInput(testCase)
            chat = openAIChat(ApiKey="this-is-not-a-real-key");
            messages = openAIMessages;
            messages = addUserMessage(messages, "This should be okay.");
            testCase.verifyWarningFree(@()generate(chat,messages));
        end

        function keyNotFound(testCase)
            testCase.verifyError(@()openAIChat, "llms:keyMustBeSpecified");
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
            chat = openAIChat(systemPrompt, Functions=functions, ModelName=modelName, ...
                Temperature=temperature, TopProbabilityMass=topP, StopSequences=stop, ApiKey=apiKey,...
                FrequencyPenalty=frequenceP, PresencePenalty=presenceP);
            testCase.verifyEqual(chat.ModelName, modelName);
            testCase.verifyEqual(chat.Temperature, temperature);
            testCase.verifyEqual(chat.TopProbabilityMass, topP);
            testCase.verifyEqual(chat.StopSequences, stop);
            testCase.verifyEqual(chat.FrequencyPenalty, frequenceP);
            testCase.verifyEqual(chat.PresencePenalty, presenceP);
        end

        function errorsWhenPassingFunctionCallWithEmptyFunctions(testCase)
            chat = openAIChat(ApiKey="this-is-not-a-real-key");
            testCase.verifyError(@()generate(chat,"input", FunctionCall="bla"), "llms:mustSetFunctionsForCall");
        end

        function invalidInputsConstructor(testCase, InvalidConstructorInput)
            testCase.verifyError(@()openAIChat(InvalidConstructorInput.Input{:}), InvalidConstructorInput.Error);
        end

        function invalidInputsGenerate(testCase, InvalidGenerateInput)
            f = openAIFunction("validfunction");
            chat = openAIChat(Functions=f, ApiKey="this-is-not-a-real-key");
            testCase.verifyError(@()generate(chat,InvalidGenerateInput.Input{:}), InvalidGenerateInput.Error);
        end

        function invalidSetters(testCase, InvalidValuesSetters)
            chat = openAIChat(ApiKey="this-is-not-a-real-key");
            function assignValueToProperty(property, value)
                chat.(property) = value;
            end
            
            testCase.verifyError(@()assignValueToProperty(InvalidValuesSetters.Property,InvalidValuesSetters.Value), InvalidValuesSetters.Error);
        end      
    end    
end

function invalidValuesSetters = iGetInvalidValuesSetters

invalidValuesSetters = struct( ...        
    "InvalidTemperatureType", struct( ...
        "Property", "Temperature", ...
        "Value", "2", ...
        "Error", "MATLAB:validators:mustBeNumericOrLogical"), ...
    ...
    "InvalidTemperatureSize", struct( ...
        "Property", "Temperature", ...
        "Value", [1 1 1], ...
        "Error", "MATLAB:validation:IncompatibleSize"), ...
    ...
    "TemperatureTooLarge", struct( ...
        "Property", "Temperature", ...
        "Value", 20, ...
        "Error", "MATLAB:validators:mustBeLessThanOrEqual"), ...
    ...
    "TemperatureTooSmall", struct( ...
        "Property", "Temperature", ...
        "Value", -20, ...
        "Error", "MATLAB:validators:mustBeNonnegative"), ...
    ...
    "InvalidTopProbabilityMassType", struct( ...
        "Property", "TopProbabilityMass", ...
        "Value", "2", ...
        "Error", "MATLAB:validators:mustBeNumericOrLogical"), ...
    ...
    "InvalidTopProbabilityMassSize", struct( ...
        "Property", "TopProbabilityMass", ...
        "Value", [1 1 1], ...
        "Error", "MATLAB:validation:IncompatibleSize"), ...
    ...
    "TopProbabilityMassTooLarge", struct( ...
        "Property", "TopProbabilityMass", ...
        "Value", 20, ...
        "Error", "MATLAB:validators:mustBeLessThanOrEqual"), ...
    ...
    "TopProbabilityMassTooSmall", struct( ...
        "Property", "TopProbabilityMass", ...
        "Value", -20, ...
        "Error", "MATLAB:validators:mustBeNonnegative"), ...
    ...
    "WrongTypeStopSequences", struct( ...
        "Property", "StopSequences", ...
        "Value", 123, ...
        "Error", "MATLAB:validators:mustBeNonzeroLengthText"), ...
    ...
    "WrongSizeStopNonVector", struct( ...
        "Property", "StopSequences", ...
        "Value", repmat("stop", 4), ...
        "Error", "MATLAB:validation:IncompatibleSize"), ...
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
        "Error", "MATLAB:validators:mustBeNumericOrLogical"), ...
    ...
    "InvalidPresencePenaltySize", struct( ...
        "Property", "PresencePenalty", ...
        "Value", [1 1 1], ...
        "Error", "MATLAB:validation:IncompatibleSize"), ...
    ...
    "PresencePenaltyTooLarge", struct( ...
        "Property", "PresencePenalty", ...
        "Value", 20, ...
        "Error", "MATLAB:validators:mustBeLessThanOrEqual"), ...
    ...
    "PresencePenaltyTooSmall", struct( ...
        "Property", "PresencePenalty", ...
        "Value", -20, ...
        "Error", "MATLAB:validators:mustBeGreaterThanOrEqual"), ...
    ...
    "InvalidFrequencyPenalty", struct( ...
        "Property", "FrequencyPenalty", ...
        "Value", "2", ...
        "Error", "MATLAB:validators:mustBeNumericOrLogical"), ...
    ...
    "InvalidFrequencyPenaltySize", struct( ...
        "Property", "FrequencyPenalty", ...
        "Value", [1 1 1], ...
        "Error", "MATLAB:validation:IncompatibleSize"), ...
    ...
    "FrequencyPenaltyTooLarge", struct( ...
        "Property", "FrequencyPenalty", ...
        "Value", 20, ...
        "Error", "MATLAB:validators:mustBeLessThanOrEqual"), ...
    ...
    "FrequencyPenaltyTooSmall", struct( ...
        "Property", "FrequencyPenalty", ...
        "Value", -20, ...
        "Error", "MATLAB:validators:mustBeGreaterThanOrEqual"));
end

function invalidConstructorInput = iGetInvalidConstructorInput
validFunction = openAIFunction("funName");
invalidConstructorInput = struct( ...
    "WrongTypeSystemPrompt",struct( ...
        "Input",{{ 123 }},...
        "Error","MATLAB:validators:mustBeTextScalar"),...
    ...
    "WrongSizeSystemPrompt",struct( ...
        "Input",{{ ["test"; "test"] }},...
        "Error","MATLAB:validators:mustBeTextScalar"),...
    ...
    "InvalidFunctionsType",struct( ...
        "Input",{{"Functions", "a" }},...
        "Error","MATLAB:validators:mustBeA"),...
    ...
    "InvalidFunctionsSize",struct( ...
        "Input",{{"Functions", repmat(validFunction, 2, 2) }},...
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
        "Error","MATLAB:validators:mustBeNumericOrLogical"),...
    ...
    "InvalidTemperatureSize",struct( ...
        "Input",{{ "Temperature" [1 1 1] }},...
        "Error","MATLAB:validation:IncompatibleSize"),...
    ...
    "TemperatureTooLarge",struct( ...
        "Input",{{ "Temperature" 20 }},...
        "Error","MATLAB:validators:mustBeLessThanOrEqual"),...
    ...
    "TemperatureTooSmall",struct( ...
        "Input",{{ "Temperature" -20 }},...
        "Error","MATLAB:validators:mustBeNonnegative"),...
    ...
    "InvalidTopProbabilityMassType",struct( ...
        "Input",{{  "TopProbabilityMass" "2" }},...
        "Error","MATLAB:validators:mustBeNumericOrLogical"),...
    ...
    "InvalidTopProbabilityMassSize",struct( ...
        "Input",{{  "TopProbabilityMass" [1 1 1] }},...
        "Error","MATLAB:validation:IncompatibleSize"),...
    ...
    "TopProbabilityMassTooLarge",struct( ...
        "Input",{{  "TopProbabilityMass" 20 }},...
        "Error","MATLAB:validators:mustBeLessThanOrEqual"),...
    ...
    "TopProbabilityMassTooSmall",struct( ...
        "Input",{{ "TopProbabilityMass" -20 }},...
        "Error","MATLAB:validators:mustBeNonnegative"),...
    ...
    "WrongTypeStopSequences",struct( ...
        "Input",{{ "StopSequences" 123}},...
        "Error","MATLAB:validators:mustBeNonzeroLengthText"),...
    ...
    "WrongSizeStopNonVector",struct( ...
        "Input",{{ "StopSequences" repmat("stop", 4) }},...
        "Error","MATLAB:validation:IncompatibleSize"),...
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
        "Error","MATLAB:validators:mustBeNumericOrLogical"),...
    ...
    "InvalidPresencePenaltySize",struct( ...
        "Input",{{ "PresencePenalty" [1 1 1] }},...
        "Error","MATLAB:validation:IncompatibleSize"),...
    ...
    "PresencePenaltyTooLarge",struct( ...
        "Input",{{ "PresencePenalty" 20 }},...
        "Error","MATLAB:validators:mustBeLessThanOrEqual"),...
    ...
    "PresencePenaltyTooSmall",struct( ...
        "Input",{{ "PresencePenalty" -20 }},...
        "Error","MATLAB:validators:mustBeGreaterThanOrEqual"),...
    ...
    "InvalidFrequencyPenalty",struct( ...
        "Input",{{ "FrequencyPenalty" "2" }},...
        "Error","MATLAB:validators:mustBeNumericOrLogical"),...
    ...
    "InvalidFrequencyPenaltySize",struct( ...
        "Input",{{ "FrequencyPenalty" [1 1 1] }},...
        "Error","MATLAB:validation:IncompatibleSize"),...
    ...
    "FrequencyPenaltyTooLarge",struct( ...
        "Input",{{ "FrequencyPenalty" 20 }},...
        "Error","MATLAB:validators:mustBeLessThanOrEqual"),...
    ...
    "FrequencyPenaltyTooSmall",struct( ...
        "Input",{{ "FrequencyPenalty" -20 }},...
        "Error","MATLAB:validators:mustBeGreaterThanOrEqual"),...
    ...
    "InvalidApiKeyType",struct( ...
        "Input",{{ "ApiKey" 123 }},...
        "Error","MATLAB:validators:mustBeNonzeroLengthText"),...
    ...
    "InvalidApiKeySize",struct( ...
        "Input",{{ "ApiKey" ["abc" "abc"] }},...
        "Error","MATLAB:validation:IncompatibleSize"));
end

function invalidGenerateInput = iGetInvalidGenerateInput
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
        "InvalidFunctionCallValue",struct( ...
            "Input",{{ validMessages  "FunctionCall" "functionDoesNotExist" }},...
            "Error","MATLAB:validators:mustBeMember"),...
        ...
        "InvalidFunctionCallType",struct( ...
            "Input",{{ validMessages  "FunctionCall" 0 }},...
            "Error","MATLAB:validators:mustBeTextScalar"),...
        ...
        "InvalidFunctionCallSize",struct( ...
            "Input",{{ validMessages  "FunctionCall" ["validfunction", "validfunction"] }},...
            "Error","MATLAB:validators:mustBeTextScalar"));
end

