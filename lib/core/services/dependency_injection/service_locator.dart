import 'package:get_it/get_it.dart';
import '../../../features/scan/data/remote/scan_repository.dart';
import '../../../features/scan/presentation/view_model/scan_cubit.dart';

final GetIt sl = GetIt.instance;

class ServiceLocator {
  static Future<void> init() async {
    // Repository
    sl.registerLazySingleton<ScanRepository>(() => FakeScanRepositoryImpl());

    // Cubit
    sl.registerFactory<ScanCubit>(() => ScanCubit(sl<ScanRepository>()));
  }
}
