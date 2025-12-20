import 'dart:convert';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// TODO: Replace with your actual Gemini API Key or use flutter_dotenv
const String _kGeminiApiKey = 'AIzaSyD8jvkkNgB7J1NauZsSiG4qQRduC7vFLHQ';

class AiParsingService {
  late final GenerativeModel _model;

  AiParsingService() {
    // using gemini-1.5-flash for speed and cost efficiency
    _model = GenerativeModel(
      model: 'gemini-1.5-flash',
      apiKey: _kGeminiApiKey,
      generationConfig: GenerationConfig(
        responseMimeType: 'application/json',
      ),
    );
  }

  /// Uses Gemini to intelligently parse raw OCR text into structured data.
  /// Handles Context, Spelling corrections, and Multi-lingual (Hindi/English) data.
  Future<Map<String, dynamic>> parseIdCard(String rawText) async {
    if (rawText.trim().length < 10) {
      throw Exception('Insufficient text to parse');
    }

    const promptText = '''
    Analyze the following raw OCR text extracted from an Indian Identity Card (Aadhaar, PAN, Voting Card, or Driving License).
    
    The text may contain English and Hindi (Devanagari).
    Some text might be garbled due to OCR errors. Use context to correct them.
    
    Task:
    1. Identify the card type (Aadhaar, PAN, DL, VoterID, or Unknown).
    2. Extract the Name (Name of the person). 
       - If it's Aadhaar, name usually appears at the top or near DOB.
       - Ignore titles like "Govt of India".
    3. Extract the ID Number.
       - Aadhaar: 12 digits (XXXX XXXX XXXX).
       - PAN: 10 chars (ABCDE1234F).
    4. Extract DOB (DD/MM/YYYY) and Gender (Male/Female).
    5. Extract Address (Full address usually on the back, combine lines).
    
    Return ONLY a valid JSON object with these keys:
    {
      "card_type": "string",
      "name": "string or null",
      "id_number": "string or null",
      "dob": "string or null",
      "gender": "string or null",
      "address": "string or null",
      "confidence": "high/medium/low"
    }
    ''';

    try {
      final content = [Content.text('$promptText\n\nRaw Text:\n$rawText')];
      final response = await _model.generateContent(content);
      
      final notification = response.text;
      if (notification == null) return {};

      // Clean up json if needed (though responseMimeType should handle it)
      final cleanJson = notification.replaceAll('```json', '').replaceAll('```', '').trim();
      
      return jsonDecode(cleanJson) as Map<String, dynamic>;
    } catch (e) {
      print('AI Parsing Error: $e');
      return {};
    }
  }
}

final aiParsingServiceProvider = Provider<AiParsingService>((ref) {
  return AiParsingService();
});
