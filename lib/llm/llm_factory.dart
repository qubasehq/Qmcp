import 'openai_client.dart';
import 'claude_client.dart';
import 'deepseek_client.dart';
import 'base_llm_client.dart';
import 'ollama_client.dart';
import 'package:qubase_mcp/provider/provider_manager.dart';
import 'package:qubase_mcp/provider/settings_provider.dart';
import 'package:logging/logging.dart';
import 'model.dart' as llm_model;

enum LLMProvider { openai, claude, ollama, deepseek }

class LLMFactory {
  static BaseLLMClient create(LLMProvider provider,
      {required String apiKey, required String baseUrl}) {
    switch (provider) {
      case LLMProvider.openai:
        return OpenAIClient(apiKey: apiKey, baseUrl: baseUrl);
      case LLMProvider.claude:
        return ClaudeClient(apiKey: apiKey, baseUrl: baseUrl);
      case LLMProvider.deepseek:
        return DeepSeekClient(apiKey: apiKey, baseUrl: baseUrl);
      case LLMProvider.ollama:
        return OllamaClient(baseUrl: baseUrl);
    }
  }
}

class LLMFactoryHelper {
  static final nonChatModelKeywords = {"whisper", "tts", "dall-e", "embedding"};

  static bool isChatModel(llm_model.Model model) {
    return !nonChatModelKeywords.any((keyword) => model.name.contains(keyword));
  }

  static final Map<String, LLMProvider> providerMap = {
    "openai": LLMProvider.openai,
    "claude": LLMProvider.claude,
    "deepseek": LLMProvider.deepseek,
    "ollama": LLMProvider.ollama,
  };

  static BaseLLMClient createFromModel(llm_model.Model currentModel) {
    try {
      final setting = ProviderManager.settingsProvider.apiSettings.firstWhere(
          (element) => element.providerId == currentModel.providerId);

      // 获取配置信息
      final apiKey = setting.apiKey;
      final baseUrl = setting.apiEndpoint;

      Logger.root.fine(
          'Using API Key: ${apiKey.isEmpty ? 'empty' : apiKey.substring(0, 10)}***** for provider: ${currentModel.providerId} model: $currentModel');

      // 创建 LLM 客户端
      return LLMFactory.create(
          LLMFactoryHelper.providerMap[currentModel.providerId] ??
              (throw ArgumentError("Unknown provider: $currentModel")),
          apiKey: apiKey,
          baseUrl: baseUrl);
    } catch (e) {
      // 如果找不到匹配的提供商，使用默认的OpenAI
      Logger.root
          .warning('未找到匹配的提供商配置: ${currentModel.providerId}，使用默认OpenAI配置');

      var openAISetting = ProviderManager.settingsProvider.apiSettings
          .firstWhere((element) => element.providerId == "openai",
              orElse: () => KeysSetting(
                  apiKey: '', apiEndpoint: '', providerId: 'openai'));

      return OpenAIClient(
          apiKey: openAISetting.apiKey, baseUrl: openAISetting.apiEndpoint);
    }
  }
}

