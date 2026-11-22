import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../core/data/error/app_exception.dart';
import '../../data/remote/scan_repository.dart';
import 'scan_state.dart';

class ScanCubit extends Cubit<ScanState> {
  ScanCubit(
    this._repository, {
    ImagePicker? imagePicker,
  })  : _imagePicker = imagePicker ?? ImagePicker(),
        super(const ScanState());

  final ScanRepository _repository;
  final ImagePicker _imagePicker;

  /// Select an image using Camera or Gallery
  Future<void> pickImage(ImageSource source) async {
    try {
      final pickedFile = await _imagePicker.pickImage(
        source: source,
        imageQuality: 85,
      );

      if (pickedFile != null) {
        emit(state.copyWith(
          imagePath: pickedFile.path,
          status: ScanStatus.initial,
          clearError: true,
        ));
      }
    } catch (e) {
      emit(state.copyWith(
        status: ScanStatus.error,
        errorMessage: 'error_description',
      ));
    }
  }

  /// Manually set image path (useful for testing or fallback)
  void setImagePath(String path) {
    emit(state.copyWith(
      imagePath: path,
      status: ScanStatus.initial,
      clearError: true,
    ));
  }

  /// Toggle debug simulation mode (Normal, Error, No Internet)
  void setDebugMode(DebugSimulationMode mode) {
    emit(state.copyWith(debugMode: mode));
  }

  /// Execute image translation
  Future<void> translate({String? pathOverride}) async {
    final pathToTranslate = pathOverride ?? state.imagePath;

    if (pathToTranslate == null || pathToTranslate.isEmpty) {
      emit(state.copyWith(
        status: ScanStatus.error,
        errorMessage: 'pick_image_first',
      ));
      return;
    }

    emit(state.copyWith(
      status: ScanStatus.loading,
      imagePath: pathToTranslate,
      clearError: true,
    ));

    final result = await _repository.translateImage(
      imagePath: pathToTranslate,
      debugMode: state.debugMode,
    );

    result.fold(
      (Failure failure) {
        if (failure is NoInternetFailure) {
          emit(state.copyWith(
            status: ScanStatus.noInternet,
            errorMessage: failure.errorMessage,
          ));
        } else {
          emit(state.copyWith(
            status: ScanStatus.error,
            errorMessage: failure.errorMessage,
          ));
        }
      },
      (translationResult) {
        emit(state.copyWith(
          status: ScanStatus.success,
          result: translationResult,
          clearError: true,
        ));
      },
    );
  }

  /// Retry the translation
  Future<void> retry() async {
    await translate();
  }
}
