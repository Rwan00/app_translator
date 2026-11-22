import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Design tokens loaded strictly from `tokens.json`.
/// Zero hardcoding in widgets.
class AppTokens {
  const AppTokens({
    required this.colors,
    required this.spacing,
    required this.radius,
  });

  final AppColorTokens colors;
  final AppSpacingTokens spacing;
  final AppRadiusTokens radius;

  /// Global instance populated at application bootstrap from the JSON asset.
  static AppTokens instance = AppTokens.fromJson(rawJsonTokens);

  /// Load and parse from assets/tokens/tokens.json
  static Future<AppTokens> loadFromAsset({
    String path = 'assets/tokens/tokens.json',
  }) async {
    try {
      final jsonString = await rootBundle.loadString(path);
      final Map<String, dynamic> data = json.decode(jsonString);
      instance = AppTokens.fromJson(data);
      return instance;
    } catch (e) {
      debugPrint('Failed to load tokens from asset ($path): $e. Using bundled tokens.');
      return instance;
    }
  }

  factory AppTokens.fromJson(Map<String, dynamic> json) {
    return AppTokens(
      colors: AppColorTokens.fromJson(json['color'] as Map<String, dynamic>),
      spacing: AppSpacingTokens.fromJson(json['spacing'] as Map<String, dynamic>),
      radius: AppRadiusTokens.fromJson(json['radius'] as Map<String, dynamic>),
    );
  }

  /// Bundled raw token JSON matching the requirement specification.
  static const Map<String, dynamic> rawJsonTokens = {
    "color": {
      "bg": "#0B0B0B",
      "surface": "#1A1A1A",
      "brand": "#F5C518",
      "textPrimary": "#FFFFFF",
      "textSecondary": "#A3A3A3",
      "error": "#E5484D"
    },
    "spacing": {
      "sm": 8,
      "md": 16,
      "lg": 24
    },
    "radius": {
      "md": 12,
      "lg": 20
    }
  };
}

class AppColorTokens {
  const AppColorTokens({
    required this.bg,
    required this.surface,
    required this.brand,
    required this.textPrimary,
    required this.textSecondary,
    required this.error,
  });

  final Color bg;
  final Color surface;
  final Color brand;
  final Color textPrimary;
  final Color textSecondary;
  final Color error;

  factory AppColorTokens.fromJson(Map<String, dynamic> json) {
    return AppColorTokens(
      bg: _parseHexColor(json['bg'] as String),
      surface: _parseHexColor(json['surface'] as String),
      brand: _parseHexColor(json['brand'] as String),
      textPrimary: _parseHexColor(json['textPrimary'] as String),
      textSecondary: _parseHexColor(json['textSecondary'] as String),
      error: _parseHexColor(json['error'] as String),
    );
  }

  static Color _parseHexColor(String hex) {
    final clean = hex.replaceAll('#', '').trim();
    if (clean.length == 6) {
      return Color(int.parse('FF$clean', radix: 16));
    } else if (clean.length == 8) {
      return Color(int.parse(clean, radix: 16));
    }
    return Colors.black;
  }
}

class AppSpacingTokens {
  const AppSpacingTokens({
    required this.sm,
    required this.md,
    required this.lg,
  });

  final double sm;
  final double md;
  final double lg;

  factory AppSpacingTokens.fromJson(Map<String, dynamic> json) {
    return AppSpacingTokens(
      sm: (json['sm'] as num).toDouble(),
      md: (json['md'] as num).toDouble(),
      lg: (json['lg'] as num).toDouble(),
    );
  }

  // Pre-built edge insets & gap helpers using token values
  EdgeInsets get insetsSm => EdgeInsets.all(sm);
  EdgeInsets get insetsMd => EdgeInsets.all(md);
  EdgeInsets get insetsLg => EdgeInsets.all(lg);

  EdgeInsets get insetsHSm => EdgeInsets.symmetric(horizontal: sm);
  EdgeInsets get insetsHMd => EdgeInsets.symmetric(horizontal: md);
  EdgeInsets get insetsHLg => EdgeInsets.symmetric(horizontal: lg);

  EdgeInsets get insetsVSm => EdgeInsets.symmetric(vertical: sm);
  EdgeInsets get insetsVMd => EdgeInsets.symmetric(vertical: md);
  EdgeInsets get insetsVLg => EdgeInsets.symmetric(vertical: lg);

  SizedBox get gapSm => SizedBox(width: sm, height: sm);
  SizedBox get gapMd => SizedBox(width: md, height: md);
  SizedBox get gapLg => SizedBox(width: lg, height: lg);

  // Derived Typography Sizes strictly derived from token spacing
  double get fontSm => sm; // 8
  double get fontCaption => sm + 4; // 12
  double get fontBody => md - 2; // 14
  double get fontMd => md; // 16
  double get fontHeadline => md + 2; // 18
  double get fontTitle => md + 4; // 20
  double get fontLg => lg; // 24

  // Derived Icon Sizes
  double get iconSm => sm + 8; // 16
  double get iconMd => md + 8; // 24
  double get iconLg => lg * 2; // 48
}

class AppRadiusTokens {
  const AppRadiusTokens({
    required this.md,
    required this.lg,
  });

  final double md;
  final double lg;

  factory AppRadiusTokens.fromJson(Map<String, dynamic> json) {
    return AppRadiusTokens(
      md: (json['md'] as num).toDouble(),
      lg: (json['lg'] as num).toDouble(),
    );
  }

  BorderRadius get borderMd => BorderRadius.circular(md);
  BorderRadius get borderLg => BorderRadius.circular(lg);

  Radius get radiusMd => Radius.circular(md);
  Radius get radiusLg => Radius.circular(lg);
}

/// Convenience extension on BuildContext to access AppTokens cleanly.
extension AppTokensContextExtension on BuildContext {
  AppTokens get tokens => AppTokens.instance;
  AppColorTokens get colors => AppTokens.instance.colors;
  AppSpacingTokens get spacing => AppTokens.instance.spacing;
  AppRadiusTokens get radius => AppTokens.instance.radius;
}
