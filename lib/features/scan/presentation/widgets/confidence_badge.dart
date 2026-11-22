import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import '../../../../core/tokens/app_tokens.dart';

class ConfidenceBadge extends StatelessWidget {
  const ConfidenceBadge({
    super.key,
    required this.confidence,
  });

  final String confidence;

  String _getConfidenceText() {
    switch (confidence.toLowerCase()) {
      case 'high':
        return 'confidence_high'.tr();
      case 'medium':
        return 'confidence_medium'.tr();
      case 'low':
      default:
        return 'confidence_low'.tr();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: context.spacing.insetsHSm + context.spacing.insetsVSm,
      decoration: BoxDecoration(
        color: context.colors.brand.withValues(alpha: 0.15),
        borderRadius: context.radius.borderMd,
        border: Border.all(
          color: context.colors.brand,
          width: 1.0,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.verified_outlined,
            size: context.spacing.iconSm,
            color: context.colors.brand,
          ),
          context.spacing.gapSm,
          Text(
            '${'confidence_label'.tr()}: ${_getConfidenceText()}',
            style: TextStyle(
              color: context.colors.brand,
              fontSize: context.spacing.fontCaption,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
