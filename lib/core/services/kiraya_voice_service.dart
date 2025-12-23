import 'package:flutter/foundation.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:speech_to_text/speech_recognition_result.dart';

class KirayaVoiceService {
  final SpeechToText _speech = SpeechToText();
  bool _isInitialized = false;

  Future<bool> initialize() async {
    if (_isInitialized) return true;
    try {
      _isInitialized = await _speech.initialize(
        onStatus: (status) => debugPrint('STT Status: $status'),
        onError: (error) => debugPrint('STT Error: $error'),
      );
      return _isInitialized;
    } catch (e) {
      debugPrint('STT Initialization Error: $e');
      return false;
    }
  }

  Future<void> startListening({
    required Function(String) onResult,
    required VoidCallback onDone,
  }) async {
    final available = await initialize();
    if (!available) return;

    await _speech.listen(
      onResult: (result) {
        onResult(result.recognizedWords);
        if (result.finalResult) {
          onDone();
        }
      },
      listenFor: const Duration(seconds: 30),
      pauseFor: const Duration(seconds: 5),
      partialResults: true,
      cancelOnError: true,
      listenMode: ListenMode.confirmation,
    );
  }

  Future<void> stopListening() async {
    await _speech.stop();
  }

  bool get isListening => _speech.isListening;
}
