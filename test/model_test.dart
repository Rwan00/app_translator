import 'package:app_translator/features/scan/data/models/translation_result.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('TranslationResult Model Tests', () {
    const mockJson = {
      "id": "scan_001",
      "translation": {
        "en": "An offering which the king gives",
        "ar": "قربان يقدمه الملك"
      },
      "confidence": "medium",
      "signs_detected": 7
    };

    test('deserializes from JSON correctly', () {
      final model = TranslationResult.fromJson(mockJson);

      expect(model.id, equals('scan_001'));
      expect(model.confidence, equals('medium'));
      expect(model.signsDetected, equals(7));
      expect(model.getTranslation('en'), equals('An offering which the king gives'));
      expect(model.getTranslation('ar'), equals('قربان يقدمه الملك'));
    });

    test('serializes to JSON correctly', () {
      final model = TranslationResult.fromJson(mockJson);
      final json = model.toJson();

      expect(json['id'], equals('scan_001'));
      expect(json['signs_detected'], equals(7));
      expect(json['confidence'], equals('medium'));
      expect(json['translation']['en'], equals('An offering which the king gives'));
      expect(json['translation']['ar'], equals('قربان يقدمه الملك'));
    });
  });
}
