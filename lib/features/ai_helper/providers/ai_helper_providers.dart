import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../domain/ai_service.dart';
import '../data/template_message_service.dart';

part 'ai_helper_providers.g.dart';

@Riverpod(keepAlive: true)
AIService aiService(AiServiceRef ref) {
  // For now, returning the template-based implementation.
  // In the future, this can be switched to a Gemini-based implementation
  // if the user's plan/subscription allows.
  return TemplateMessageService();
}
