import 'package:app_translator/core/tokens/app_tokens.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AppTokens Design Tokens Tests', () {
    test('parses colors, spacing, and radius correctly from token JSON', () {
      final tokens = AppTokens.fromJson(AppTokens.rawJsonTokens);

      // Verify colors
      expect(tokens.colors.bg, equals(const Color(0xFF0B0B0B)));
      expect(tokens.colors.surface, equals(const Color(0xFF1A1A1A)));
      expect(tokens.colors.brand, equals(const Color(0xFFF5C518)));
      expect(tokens.colors.textPrimary, equals(const Color(0xFFFFFFFF)));
      expect(tokens.colors.textSecondary, equals(const Color(0xFFA3A3A3)));
      expect(tokens.colors.error, equals(const Color(0xFFE5484D)));

      // Verify spacing
      expect(tokens.spacing.sm, equals(8.0));
      
      expect(tokens.spacing.md, equals(16.0));
      expect(tokens.spacing.lg, equals(24.0));

      // Verify radius
      expect(tokens.radius.md, equals(12.0));
      expect(tokens.radius.lg, equals(20.0));
    });

    test('spacing helpers generate correct EdgeInsets and SizedBox', () {
      final spacing = AppTokens.instance.spacing;
      expect(spacing.insetsSm, equals(const EdgeInsets.all(8.0)));
      expect(spacing.insetsMd, equals(const EdgeInsets.all(16.0)));
      expect(spacing.insetsLg, equals(const EdgeInsets.all(24.0)));

      expect(spacing.gapSm.width, equals(8.0));
      expect(spacing.gapMd.height, equals(16.0));
    });

    test('radius helpers generate correct BorderRadius', () {
      final radius = AppTokens.instance.radius;
      expect(radius.borderMd, equals(BorderRadius.circular(12.0)));
      expect(radius.borderLg, equals(BorderRadius.circular(20.0)));
    });
  });
}
