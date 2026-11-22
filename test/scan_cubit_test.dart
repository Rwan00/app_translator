import 'package:app_translator/core/data/error/app_exception.dart';
import 'package:app_translator/features/scan/data/models/translation_result.dart';
import 'package:app_translator/features/scan/data/remote/scan_repository.dart';
import 'package:app_translator/features/scan/presentation/view_model/scan_cubit.dart';
import 'package:app_translator/features/scan/presentation/view_model/scan_state.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockScanRepository extends Mock implements ScanRepository {}

void main() {
  late MockScanRepository mockRepository;
  late ScanCubit scanCubit;

  const tMockResult = TranslationResult(
    id: 'scan_001',
    translation: {
      'en': 'An offering which the king gives',
      'ar': 'قربان يقدمه الملك',
    },
    confidence: 'medium',
    signsDetected: 7,
  );

  setUpAll(() {
    registerFallbackValue(DebugSimulationMode.normal);
  });

  setUp(() {
    mockRepository = MockScanRepository();
    scanCubit = ScanCubit(mockRepository);
  });

  tearDown(() {
    scanCubit.close();
  });

  group('ScanCubit Unit Tests', () {
    test('initial state should have ScanStatus.initial and no errors', () {
      expect(scanCubit.state.status, equals(ScanStatus.initial));
      expect(scanCubit.state.imagePath, isNull);
      expect(scanCubit.state.result, isNull);
      expect(scanCubit.state.errorMessage, isNull);
    });

    // ─────────────────────────────────────────────────────────────────────────
    // Required Unit Test Covering The Error Path
    // ─────────────────────────────────────────────────────────────────────────
    blocTest<ScanCubit, ScanState>(
      'emits [ScanStatus.loading, ScanStatus.error] when translation fails with ServerFailure',
      setUp: () {
        when(
          () => mockRepository.translateImage(
            imagePath: any(named: 'imagePath'),
            debugMode: any(named: 'debugMode'),
          ),
        ).thenAnswer(
          (_) async => const Left(ServerFailure('error_description')),
        );
      },
      build: () => scanCubit,
      seed: () => const ScanState(imagePath: '/test/image.jpg'),
      act: (cubit) => cubit.translate(),
      expect: () => [
        const ScanState(
          status: ScanStatus.loading,
          imagePath: '/test/image.jpg',
        ),
        const ScanState(
          status: ScanStatus.error,
          imagePath: '/test/image.jpg',
          errorMessage: 'error_description',
        ),
      ],
      verify: (_) {
        verify(
          () => mockRepository.translateImage(
            imagePath: '/test/image.jpg',
            debugMode: DebugSimulationMode.normal,
          ),
        ).called(1);
      },
    );

    // ─────────────────────────────────────────────────────────────────────────
    // Unit Test Covering The No Internet Path
    // ─────────────────────────────────────────────────────────────────────────
    blocTest<ScanCubit, ScanState>(
      'emits [ScanStatus.loading, ScanStatus.noInternet] when repository returns NoInternetFailure',
      setUp: () {
        when(
          () => mockRepository.translateImage(
            imagePath: any(named: 'imagePath'),
            debugMode: any(named: 'debugMode'),
          ),
        ).thenAnswer(
          (_) async => const Left(NoInternetFailure('no_internet_description')),
        );
      },
      build: () => scanCubit,
      seed: () => const ScanState(
        imagePath: '/test/image.jpg',
        debugMode: DebugSimulationMode.noInternet,
      ),
      act: (cubit) => cubit.translate(),
      expect: () => [
        const ScanState(
          status: ScanStatus.loading,
          imagePath: '/test/image.jpg',
          debugMode: DebugSimulationMode.noInternet,
        ),
        const ScanState(
          status: ScanStatus.noInternet,
          imagePath: '/test/image.jpg',
          debugMode: DebugSimulationMode.noInternet,
          errorMessage: 'no_internet_description',
        ),
      ],
    );

    // ─────────────────────────────────────────────────────────────────────────
    // Unit Test Covering The Success Path
    // ─────────────────────────────────────────────────────────────────────────
    blocTest<ScanCubit, ScanState>(
      'emits [ScanStatus.loading, ScanStatus.success] when translation succeeds',
      setUp: () {
        when(
          () => mockRepository.translateImage(
            imagePath: any(named: 'imagePath'),
            debugMode: any(named: 'debugMode'),
          ),
        ).thenAnswer(
          (_) async => const Right(tMockResult),
        );
      },
      build: () => scanCubit,
      seed: () => const ScanState(imagePath: '/test/image.jpg'),
      act: (cubit) => cubit.translate(),
      expect: () => [
        const ScanState(
          status: ScanStatus.loading,
          imagePath: '/test/image.jpg',
        ),
        const ScanState(
          status: ScanStatus.success,
          imagePath: '/test/image.jpg',
          result: tMockResult,
        ),
      ],
    );

    // ─────────────────────────────────────────────────────────────────────────
    // Unit Test for validation (no image path)
    // ─────────────────────────────────────────────────────────────────────────
    blocTest<ScanCubit, ScanState>(
      'emits ScanStatus.error when translate is called without image',
      build: () => scanCubit,
      act: (cubit) => cubit.translate(),
      expect: () => [
        const ScanState(
          status: ScanStatus.error,
          errorMessage: 'pick_image_first',
        ),
      ],
    );
  });
}
