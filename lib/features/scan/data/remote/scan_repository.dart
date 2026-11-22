import 'dart:async';
import 'package:dartz/dartz.dart';
import '../../../../core/data/error/app_exception.dart';
import '../models/translation_result.dart';

enum DebugSimulationMode {
  normal,
  error,
  noInternet,
}

abstract class ScanRepository {
  Future<Either<Failure, TranslationResult>> translateImage({
    required String imagePath,
    DebugSimulationMode debugMode = DebugSimulationMode.normal,
  });
}

class FakeScanRepositoryImpl implements ScanRepository {
  static const Map<String, dynamic> mockResponse = {
    "id": "scan_001",
    "translation": {
      "en": "An offering which the king gives",
      "ar": "قربان يقدمه الملك"
    },
    "confidence": "medium",
    "signs_detected": 7
  };

  @override
  Future<Either<Failure, TranslationResult>> translateImage({
    required String imagePath,
    DebugSimulationMode debugMode = DebugSimulationMode.normal,
  }) async {
    // Simulate network delay of 1.5 seconds as per requirements
    await Future.delayed(const Duration(milliseconds: 1500));

    switch (debugMode) {
      case DebugSimulationMode.noInternet:
        return const Left(
          NoInternetFailure('no_internet_description'),
        );
      case DebugSimulationMode.error:
        return const Left(
          ServerFailure('error_description'),
        );
      case DebugSimulationMode.normal:
        return Right(TranslationResult.fromJson(mockResponse));
    }
  }
}
