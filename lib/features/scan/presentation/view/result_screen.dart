import 'dart:io';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/tokens/app_tokens.dart';
import '../view_model/scan_cubit.dart';
import '../view_model/scan_state.dart';
import '../widgets/confidence_badge.dart';
import '../widgets/debug_switch_widget.dart';

class ResultScreen extends StatelessWidget {
  const ResultScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.colors.bg,
      appBar: AppBar(
        backgroundColor: context.colors.bg,
        elevation: 0,
        iconTheme: IconThemeData(color: context.colors.textPrimary),
        title: Text(
          'result_screen_title'.tr(),
          style: TextStyle(
            color: context.colors.textPrimary,
            fontSize: context.spacing.fontHeadline,
            fontWeight: FontWeight.w700,
          ),
        ),
        actions: [
          // Language switcher on Result Screen for live RTL/LTR testing
          TextButton.icon(
            onPressed: () {
              final newLocale = context.locale.languageCode == 'en'
                  ? const Locale('ar')
                  : const Locale('en');
              context.setLocale(newLocale);
            },
            icon: Icon(
              Icons.language,
              color: context.colors.brand,
              size: context.spacing.iconSm,
            ),
            label: Text(
              'language_switch'.tr(),
              style: TextStyle(
                color: context.colors.brand,
                fontSize: context.spacing.fontBody,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          context.spacing.gapSm,
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: BlocBuilder<ScanCubit, ScanState>(
                builder: (context, state) {
                  switch (state.status) {
                    case ScanStatus.loading:
                      return _buildLoadingState(context);
                    case ScanStatus.success:
                      return _buildSuccessState(context, state);
                    case ScanStatus.error:
                      return _buildErrorState(context, state);
                    case ScanStatus.noInternet:
                      return _buildNoInternetState(context, state);
                    case ScanStatus.initial:
                      return _buildLoadingState(context);
                  }
                },
              ),
            ),
            // Persistent Debug Switcher enabling quick state toggles
            const DebugSwitchWidget(),
          ],
        ),
      ),
    );
  }

  // 1. Loading State
  Widget _buildLoadingState(BuildContext context) {
    return Center(
      child: Padding(
        padding: context.spacing.insetsLg,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: context.spacing.iconLg,
              height: context.spacing.iconLg,
              child: CircularProgressIndicator(
                strokeWidth: 3.0,
                valueColor: AlwaysStoppedAnimation<Color>(context.colors.brand),
              ),
            ),
            context.spacing.gapLg,
            Text(
              'loading_translation'.tr(),
              style: TextStyle(
                color: context.colors.textSecondary,
                fontSize: context.spacing.fontMd,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  // 2. Success State
  Widget _buildSuccessState(BuildContext context, ScanState state) {
    final result = state.result;
    if (result == null) return const SizedBox.shrink();

    final currentLang = context.locale.languageCode;
    final translatedText = result.getTranslation(currentLang);

    return SingleChildScrollView(
      padding: context.spacing.insetsMd,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Picked Image Card (16:9 Aspect Ratio)
          if (state.imagePath != null && state.imagePath!.isNotEmpty)
            AspectRatio(
              aspectRatio: 16 / 9,
              child: Container(
                decoration: BoxDecoration(
                  color: context.colors.surface,
                  borderRadius: context.radius.borderLg,
                ),
                child: ClipRRect(
                  borderRadius: context.radius.borderLg,
                  child: _buildThumbnail(context, state.imagePath!),
                ),
              ),
            ),
          context.spacing.gapMd,

          // Metadata Row: Confidence Badge and Signs Detected Pill
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              ConfidenceBadge(confidence: result.confidence),
              Container(
                padding: context.spacing.insetsHSm + context.spacing.insetsVSm,
                decoration: BoxDecoration(
                  color: context.colors.surface,
                  borderRadius: context.radius.borderMd,
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.auto_awesome,
                      size: context.spacing.iconSm,
                      color: context.colors.brand,
                    ),
                    context.spacing.gapSm,
                    Text(
                      'signs_detected'.tr(args: [result.signsDetected.toString()]),
                      style: TextStyle(
                        color: context.colors.textPrimary,
                        fontSize: context.spacing.fontCaption,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          context.spacing.gapMd,

          // Translation Card
          Container(
            padding: context.spacing.insetsMd,
            decoration: BoxDecoration(
              color: context.colors.surface,
              borderRadius: context.radius.borderLg,
              border: Border.all(
                color: context.colors.brand.withValues(alpha: 0.2),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.translate,
                      size: context.spacing.iconSm,
                      color: context.colors.brand,
                    ),
                    context.spacing.gapSm,
                    Text(
                      'detected_text'.tr(),
                      style: TextStyle(
                        color: context.colors.textSecondary,
                        fontSize: context.spacing.fontCaption,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                context.spacing.gapSm,
                Text(
                  translatedText,
                  style: TextStyle(
                    color: context.colors.textPrimary,
                    fontSize: context.spacing.fontTitle,
                    fontWeight: FontWeight.w700,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // 3. Error State
  Widget _buildErrorState(BuildContext context, ScanState state) {
    return Center(
      child: Padding(
        padding: context.spacing.insetsLg,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: context.spacing.insetsMd,
              decoration: BoxDecoration(
                color: context.colors.error.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.error_outline_rounded,
                size: context.spacing.iconLg,
                color: context.colors.error,
              ),
            ),
            context.spacing.gapMd,
            Text(
              'error_title'.tr(),
              style: TextStyle(
                color: context.colors.textPrimary,
                fontSize: context.spacing.fontHeadline,
                fontWeight: FontWeight.bold,
              ),
            ),
            context.spacing.gapSm,
            Text(
              'error_description'.tr(),
              textAlign: TextAlign.center,
              style: TextStyle(
                color: context.colors.textSecondary,
                fontSize: context.spacing.fontBody,
              ),
            ),
            context.spacing.gapLg,
            _buildRetryButton(context),
          ],
        ),
      ),
    );
  }

  // 4. No Internet State
  Widget _buildNoInternetState(BuildContext context, ScanState state) {
    return Center(
      child: Padding(
        padding: context.spacing.insetsLg,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: context.spacing.insetsMd,
              decoration: BoxDecoration(
                color: context.colors.surface,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.wifi_off_rounded,
                size: context.spacing.iconLg,
                color: context.colors.brand,
              ),
            ),
            context.spacing.gapMd,
            Text(
              'no_internet_title'.tr(),
              style: TextStyle(
                color: context.colors.textPrimary,
                fontSize: context.spacing.fontHeadline,
                fontWeight: FontWeight.bold,
              ),
            ),
            context.spacing.gapSm,
            Text(
              'no_internet_description'.tr(),
              textAlign: TextAlign.center,
              style: TextStyle(
                color: context.colors.textSecondary,
                fontSize: context.spacing.fontBody,
              ),
            ),
            context.spacing.gapLg,
            _buildRetryButton(context),
          ],
        ),
      ),
    );
  }

  Widget _buildRetryButton(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: () => context.read<ScanCubit>().retry(),
      icon: Icon(Icons.refresh, color: context.colors.bg),
      label: Text(
        'retry'.tr(),
        style: TextStyle(
          color: context.colors.bg,
          fontSize: context.spacing.fontBody,
          fontWeight: FontWeight.bold,
        ),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: context.colors.brand,
        padding: context.spacing.insetsHMd + context.spacing.insetsVSm,
        shape: RoundedRectangleBorder(
          borderRadius: context.radius.borderMd,
        ),
        elevation: 0,
      ),
    );
  }

  Widget _buildThumbnail(BuildContext context, String path) {
    final file = File(path);
    if (file.existsSync()) {
      return Image.file(
        file,
        fit: BoxFit.cover,
        width: double.infinity,
      );
    }
    return Container(
      color: context.colors.surface,
      alignment: Alignment.center,
      child: Icon(
        Icons.image_outlined,
        size: context.spacing.iconLg,
        color: context.colors.brand,
      ),
    );
  }
}
