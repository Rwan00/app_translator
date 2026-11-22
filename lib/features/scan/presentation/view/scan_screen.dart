import 'dart:io';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../core/tokens/app_tokens.dart';
import '../view_model/scan_cubit.dart';
import '../view_model/scan_state.dart';
import '../widgets/debug_switch_widget.dart';
import 'result_screen.dart';

class ScanScreen extends StatelessWidget {
  const ScanScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.colors.bg,
      appBar: AppBar(
        backgroundColor: context.colors.bg,
        elevation: 0,
        title: Text(
          'scan_screen_title'.tr(),
          style: TextStyle(
            color: context.colors.textPrimary,
            fontSize: context.spacing.fontHeadline,
            fontWeight: FontWeight.w700,
          ),
        ),
        actions: [
          // Language Switcher (En <-> Ar with instant RTL mirroring)
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
        child: BlocConsumer<ScanCubit, ScanState>(
          listener: (context, state) {
            if (state.errorMessage != null &&
                state.status == ScanStatus.initial) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  backgroundColor: context.colors.error,
                  content: Text(
                    state.errorMessage!.tr(),
                    style: TextStyle(
                      color: context.colors.textPrimary,
                      fontSize: context.spacing.fontBody,
                    ),
                  ),
                ),
              );
            }
          },
          builder: (context, state) {
            final hasImage = state.imagePath != null &&
                state.imagePath!.isNotEmpty;

            return Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    padding: context.spacing.insetsMd,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Image Preview or Empty State Box (Aspect ratio 4:3)
                        AspectRatio(
                          aspectRatio: 4 / 3,
                          child: Container(
                            decoration: BoxDecoration(
                              color: context.colors.surface,
                              borderRadius: context.radius.borderLg,
                              border: Border.all(
                                color: hasImage
                                    ? context.colors.brand
                                    : context.colors.surface,
                                width: 1.5,
                              ),
                            ),
                            child: ClipRRect(
                              borderRadius: context.radius.borderLg,
                              child: hasImage
                                  ? _buildImagePreview(context, state.imagePath!)
                                  : _buildPlaceholder(context),
                            ),
                          ),
                        ),
                        context.spacing.gapLg,

                        // Camera and Gallery action buttons
                        Row(
                          children: [
                            Expanded(
                              child: _MediaActionButton(
                                icon: Icons.camera_alt_outlined,
                                label: 'camera'.tr(),
                                onTap: () => context
                                    .read<ScanCubit>()
                                    .pickImage(ImageSource.camera),
                              ),
                            ),
                            context.spacing.gapMd,
                            Expanded(
                              child: _MediaActionButton(
                                icon: Icons.photo_library_outlined,
                                label: 'gallery'.tr(),
                                onTap: () => context
                                    .read<ScanCubit>()
                                    .pickImage(ImageSource.gallery),
                              ),
                            ),
                          ],
                        ),
                        context.spacing.gapLg,

                        // Primary Translate Action Button
                        ElevatedButton(
                          onPressed: hasImage
                              ? () {
                                  context.read<ScanCubit>().translate();
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (_) => BlocProvider.value(
                                        value: context.read<ScanCubit>(),
                                        child: const ResultScreen(),
                                      ),
                                    ),
                                  );
                                }
                              : null,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: context.colors.brand,
                            disabledBackgroundColor:
                                context.colors.surface,
                            foregroundColor: context.colors.bg,
                            disabledForegroundColor:
                                context.colors.textSecondary,
                            padding: context.spacing.insetsVMd,
                            shape: RoundedRectangleBorder(
                              borderRadius: context.radius.borderMd,
                            ),
                            elevation: 0,
                          ),
                          child: Text(
                            'translate_button'.tr(),
                            style: TextStyle(
                              fontSize: context.spacing.fontMd,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Persistent Debug Switcher for easy testing
                const DebugSwitchWidget(),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildImagePreview(BuildContext context, String path) {
    final file = File(path);
    if (file.existsSync()) {
      return Image.file(
        file,
        fit: BoxFit.cover,
        width: double.infinity,
      );
    }
    // Fallback placeholder
    return Container(
      color: context.colors.surface,
      alignment: Alignment.center,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.image,
            size: context.spacing.iconLg,
            color: context.colors.brand,
          ),
          context.spacing.gapSm,
          Text(
            'Sample Image Ready',
            style: TextStyle(
              color: context.colors.textPrimary,
              fontSize: context.spacing.fontBody,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlaceholder(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.document_scanner_outlined,
            size: context.spacing.iconLg,
            color: context.colors.textSecondary,
          ),
          context.spacing.gapMd,
          Text(
            'select_image_prompt'.tr(),
            style: TextStyle(
              color: context.colors.textSecondary,
              fontSize: context.spacing.fontBody,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _MediaActionButton extends StatelessWidget {
  const _MediaActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: onTap,
      icon: Icon(
        icon,
        color: context.colors.brand,
        size: context.spacing.iconSm,
      ),
      label: Text(
        label,
        style: TextStyle(
          color: context.colors.textPrimary,
          fontSize: context.spacing.fontBody,
          fontWeight: FontWeight.w600,
        ),
      ),
      style: OutlinedButton.styleFrom(
        backgroundColor: context.colors.surface,
        side: BorderSide(color: context.colors.surface),
        padding: context.spacing.insetsVMd,
        shape: RoundedRectangleBorder(
          borderRadius: context.radius.borderMd,
        ),
      ),
    );
  }
}
