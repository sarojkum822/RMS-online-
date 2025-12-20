import 'dart:io';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'ai_parsing_service.dart';

class OcrResult {
  final String? name;
  final String? idNumber;
  final String? dob;
  final String? gender;
  final String? address;
  final String rawText;
  final String source; // 'AI' or 'Regex'

  OcrResult({
    this.name, 
    this.idNumber, 
    this.dob, 
    this.gender, 
    this.address, 
    required this.rawText,
    this.source = 'Regex',
  });
}

final ocrServiceProvider = Provider.autoDispose<OcrService>((ref) {
  final aiService = ref.watch(aiParsingServiceProvider);
  final service = OcrService(aiService);
  ref.onDispose(() => service.dispose());
  return service;
});

class OcrService {
  // Using Devanagari script to support Hindi text in Aadhaar cards
  final _textRecognizer = TextRecognizer(script: TextRecognitionScript.devanagiri);
  final AiParsingService _aiParsingService;

  OcrService(this._aiParsingService);

  Future<OcrResult> scanImage(File imageFile) async {
    final inputImage = InputImage.fromFile(imageFile);
    final RecognizedText recognizedText = await _textRecognizer.processImage(inputImage);
    
    String rawText = recognizedText.text;

    // 1. Try AI Parsing (Best Accuracy)
    try {
      final aiData = await _aiParsingService.parseIdCard(rawText);
      if (aiData.isNotEmpty && (aiData['name'] != null || aiData['id_number'] != null)) {
         return OcrResult(
            name: aiData['name'],
            idNumber: aiData['id_number'],
            dob: aiData['dob'],
            gender: aiData['gender'],
            address: aiData['address'],
            rawText: rawText,
            source: 'Gemini AI',
         );
      }
    } catch (e) {
      print('AI Parsing Failed, falling back to Regex: $e');
      // Continue to Regex fallback
    }

    // 2. Fallback: Regex Parsing (Offline)
    String? name;
    String? idNumber;
    String? dob;
    String? gender;
    String? address;

    // ID Number (Aadhaar/PAN)
    final aadhaarRegex = RegExp(r'\d{4}\s\d{4}\s\d{4}');
    final match = aadhaarRegex.firstMatch(rawText);
    if (match != null) {
      idNumber = match.group(0);
    } else {
      final simpleAadhaarRegex = RegExp(r'\d{12}');
      final simpleMatch = simpleAadhaarRegex.firstMatch(rawText);
      if (simpleMatch != null) {
        idNumber = simpleMatch.group(0);
      } else {
        // PAN Regex: 5 letters, 4 digits, 1 letter
        final panRegex = RegExp(r'[A-Z]{5}[0-9]{4}[A-Z]{1}');
        final panMatch = panRegex.firstMatch(rawText);
        if (panMatch != null) idNumber = panMatch.group(0);
      }
    }

    // DOB (DD/MM/YYYY or YYYY)
    final dobRegex = RegExp(r'\d{2}/\d{2}/\d{4}');
    final dobMatch = dobRegex.firstMatch(rawText);
    if (dobMatch != null) {
      dob = dobMatch.group(0);
    } else {
      final yearRegex = RegExp(r'Year of Birth\s*[:|-]?\s*(\d{4})', caseSensitive: false);
      final yearMatch = yearRegex.firstMatch(rawText);
      if (yearMatch != null) dob = "01/01/${yearMatch.group(1)}"; // Approx
    }

    // Gender
    if (rawText.contains(RegExp(r'\bMale\b', caseSensitive: false))) {
        gender = 'Male';
    } else if (rawText.contains(RegExp(r'\bFemale\b', caseSensitive: false))) {
        gender = 'Female';
    }

    // Address
    final addressRegex = RegExp(r'Address\s*[:|-]?\s*([\s\S]+?)(?=\d{6}|$)', caseSensitive: false);
    final addressMatch = addressRegex.firstMatch(rawText);
    if (addressMatch != null) {
       address = addressMatch.group(1)?.trim().replaceAll('\n', ', ');
       final pincodeRegex = RegExp(r'\d{6}');
       final pinMatch = pincodeRegex.firstMatch(rawText);
       if (pinMatch != null && address != null) {
          address = "$address, ${pinMatch.group(0)}";
       }
    }

    // Name Extraction Heuristic (Front side)
    if (gender != null || dob != null) {
      List<String> lines = rawText.split('\n');
      final stopWords = ['govt', 'government', 'india', 'male', 'female', 'dob', 'year', 'birth', 'address', 'father', 'husband', 'card', 'identity'];
      
      for (var line in lines) {
        String cleanLine = line.trim().toLowerCase();
        if (cleanLine.length > 3 && 
            !cleanLine.contains(RegExp(r'\d')) &&
            !stopWords.any((word) => cleanLine.contains(word))) {
            
            if (line.toUpperCase() == line && line.length > 4) {
               name = line.trim();
               break;
            }
        }
      }
    }

    return OcrResult(
      name: name,
      idNumber: idNumber,
      dob: dob,
      gender: gender,
      address: address,
      rawText: rawText,
      source: 'Regex (Offline)',
    );
  }

  void dispose() {
    _textRecognizer.close();
  }
}
