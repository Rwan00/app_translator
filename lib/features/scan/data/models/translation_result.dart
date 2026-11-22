import 'package:equatable/equatable.dart';

class TranslationResult extends Equatable {
  const TranslationResult({
    required this.id,
    required this.translation,
    required this.confidence,
    required this.signsDetected,
  });

  final String id;
  final Map<String, String> translation;
  final String confidence;
  final int signsDetected;

  String getTranslation(String languageCode) {
    return translation[languageCode] ?? translation['en'] ?? '';
  }

  factory TranslationResult.fromJson(Map<String, dynamic> json) {
    final translationMap = (json['translation'] as Map<String, dynamic>? ?? {})
        .map((key, value) => MapEntry(key, value.toString()));

    return TranslationResult(
      id: json['id'] as String? ?? '',
      translation: translationMap,
      confidence: json['confidence'] as String? ?? 'low',
      signsDetected: (json['signs_detected'] as num?)?.toInt() ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'translation': translation,
      'confidence': confidence,
      'signs_detected': signsDetected,
    };
  }

  @override
  List<Object?> get props => [id, translation, confidence, signsDetected];
}

