import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'core/services/dependency_injection/service_locator.dart';
import 'core/tokens/app_tokens.dart';
import 'features/scan/presentation/view/scan_screen.dart';
import 'features/scan/presentation/view_model/scan_cubit.dart';

Future<void> main() async {
  final widgetsBinding = WidgetsFlutterBinding.ensureInitialized();

  // Preserve native splash screen while initializing resources
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);

  await EasyLocalization.ensureInitialized();

  // Load design tokens strictly from tokens.json
  await AppTokens.loadFromAsset();

  // Initialize Dependency Injection
  await ServiceLocator.init();

  runApp(
    EasyLocalization(
      supportedLocales: const [
        Locale('en'),
        Locale('ar'),
      ],
      path: 'assets/translations',
      fallbackLocale: const Locale('en'),
      child: const AppTranslatorApp(),
    ),
  );

  // Remove native splash screen once initial frame is rendered
  WidgetsBinding.instance.addPostFrameCallback((_) {
    FlutterNativeSplash.remove();
  });
}

class AppTranslatorApp extends StatelessWidget {
  const AppTranslatorApp({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = AppTokens.instance.colors;

    return MaterialApp(
      title: 'app_title'.tr(),
      debugShowCheckedModeBanner: false,
      localizationsDelegates: context.localizationDelegates,
      supportedLocales: context.supportedLocales,
      locale: context.locale,
      themeMode: ThemeMode.dark,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: colors.bg,
        colorScheme: ColorScheme.dark(
          primary: colors.brand,
          surface: colors.surface,
          error: colors.error,
          onPrimary: colors.bg,
          onSurface: colors.textPrimary,
        ),
        appBarTheme: AppBarTheme(
          backgroundColor: colors.bg,
          elevation: 0,
          centerTitle: false,
          iconTheme: IconThemeData(color: colors.textPrimary),
          titleTextStyle: TextStyle(
            color: colors.textPrimary,
            fontSize: AppTokens.instance.spacing.fontHeadline,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      home: BlocProvider<ScanCubit>(
        create: (_) => sl<ScanCubit>(),
        child: const ScanScreen(),
      ),
    );
  }
}
