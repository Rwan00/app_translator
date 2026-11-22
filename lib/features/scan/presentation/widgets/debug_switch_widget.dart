import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/tokens/app_tokens.dart';
import '../../data/remote/scan_repository.dart';
import '../view_model/scan_cubit.dart';
import '../view_model/scan_state.dart';

class DebugSwitchWidget extends StatelessWidget {
  const DebugSwitchWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ScanCubit, ScanState>(
      buildWhen: (previous, current) => previous.debugMode != current.debugMode,
      builder: (context, state) {
        return Container(
          margin: context.spacing.insetsHSm + context.spacing.insetsVSm,
          padding: context.spacing.insetsSm,
          decoration: BoxDecoration(
            color: context.colors.surface,
            borderRadius: context.radius.borderMd,
            border: Border.all(
              color: context.colors.brand.withValues(alpha: 0.3),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: context.spacing.insetsHSm,
                child: Row(
                  children: [
                    Icon(
                      Icons.bug_report_outlined,
                      size: context.spacing.iconSm,
                      color: context.colors.brand,
                    ),
                    context.spacing.gapSm,
                    Text(
                      'debug_options'.tr(),
                      style: TextStyle(
                        color: context.colors.textSecondary,
                        fontSize: context.spacing.fontCaption,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              context.spacing.gapSm,
              Row(
                children: [
                  Expanded(
                    child: _ModeChip(
                      label: 'simulate_success'.tr(),
                      isSelected: state.debugMode == DebugSimulationMode.normal,
                      onTap: () {
                        context
                            .read<ScanCubit>()
                            .setDebugMode(DebugSimulationMode.normal);
                        context.read<ScanCubit>().retry();
                      },
                    ),
                  ),
                  context.spacing.gapSm,
                  Expanded(
                    child: _ModeChip(
                      label: 'simulate_error'.tr(),
                      isSelected: state.debugMode == DebugSimulationMode.error,
                      onTap: () {
                        context
                            .read<ScanCubit>()
                            .setDebugMode(DebugSimulationMode.error);
                        context.read<ScanCubit>().retry();
                      },
                    ),
                  ),
                  context.spacing.gapSm,
                  Expanded(
                    child: _ModeChip(
                      label: 'simulate_no_internet'.tr(),
                      isSelected:
                          state.debugMode == DebugSimulationMode.noInternet,
                      onTap: () {
                        context
                            .read<ScanCubit>()
                            .setDebugMode(DebugSimulationMode.noInternet);
                        context.read<ScanCubit>().retry();
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

class _ModeChip extends StatelessWidget {
  const _ModeChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: context.radius.borderMd,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: context.spacing.insetsVSm + context.spacing.insetsHSm,
        decoration: BoxDecoration(
          color: isSelected ? context.colors.brand : context.colors.bg,
          borderRadius: context.radius.borderMd,
          border: Border.all(
            color: isSelected
                ? context.colors.brand
                : context.colors.surface,
          ),
        ),
        child: Center(
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: isSelected
                  ? context.colors.bg
                  : context.colors.textSecondary,
              fontSize: context.spacing.fontCaption,
              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }
}
