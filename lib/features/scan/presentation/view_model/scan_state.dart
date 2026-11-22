import 'package:equatable/equatable.dart';
import '../../data/models/translation_result.dart';
import '../../data/remote/scan_repository.dart';

enum ScanStatus {
  initial,
  loading,
  success,
  error,
  noInternet,
}

class ScanState extends Equatable {
  const ScanState({
    this.status = ScanStatus.initial,
    this.imagePath,
    this.result,
    this.errorMessage,
    this.debugMode = DebugSimulationMode.normal,
  });

  final ScanStatus status;
  final String? imagePath;
  final TranslationResult? result;
  final String? errorMessage;
  final DebugSimulationMode debugMode;

  ScanState copyWith({
    ScanStatus? status,
    String? imagePath,
    TranslationResult? result,
    String? errorMessage,
    DebugSimulationMode? debugMode,
    bool clearError = false,
  }) {
    return ScanState(
      status: status ?? this.status,
      imagePath: imagePath ?? this.imagePath,
      result: result ?? this.result,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      debugMode: debugMode ?? this.debugMode,
    );
  }

  @override
  List<Object?> get props => [
        status,
        imagePath,
        result,
        errorMessage,
        debugMode,
      ];
}
