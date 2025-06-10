// lib/constants/design_constants.dart
// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import '../app_colors.dart';

class DesignConstants {
  // Breakpoints responsivos
  static const double mobileBreakpoint = 768.0;
  static const double tabletBreakpoint = 1024.0;
  static const double maxContentWidth = 1400.0;

  // Espaçamentos padronizados
  static const double sectionSpacing = 48.0;
  static const double cardSpacing = 16.0;
  static const double smallSpacing = 8.0;
  static const double mediumSpacing = 16.0;
  static const double largeSpacing = 24.0;
  static const double extraLargeSpacing = 32.0;

  // Cores padronizadas
  static const Color primaryCardColor = Color(0xFFE1F5FE);
  static const Color secondaryCardColor = Color(0xFFF3E5F5);
  static const Color accentCardColor = Color(0xFFE8F5E8);
  static const Color highlightCardColor = Color(0xFFFFF3E0);

  // Bordas e raios
  static const double borderRadius = 12.0;
  static const double largeBorderRadius = 16.0;
  static const double extraLargeBorderRadius = 24.0;

  // Elevações padronizadas
  static const double lowElevation = 2.0;
  static const double mediumElevation = 4.0;
  static const double highElevation = 8.0;

  // Tamanhos de texto
  static const double headingFontSize = 28.0;
  static const double subheadingFontSize = 24.0;
  static const double bodyFontSize = 16.0;
  static const double captionFontSize = 14.0;
  static const double smallFontSize = 12.0;

  // Sombras padronizadas
  static List<BoxShadow> get lightShadow => [
        BoxShadow(
          color: Colors.black.withOpacity(0.05),
          blurRadius: 4,
          offset: const Offset(0, 2),
        ),
      ];

  static List<BoxShadow> get mediumShadow => [
        BoxShadow(
          color: Colors.black.withOpacity(0.1),
          blurRadius: 8,
          offset: const Offset(0, 4),
        ),
      ];

  static List<BoxShadow> get heavyShadow => [
        BoxShadow(
          color: Colors.black.withOpacity(0.1),
          blurRadius: 20,
          offset: const Offset(0, 10),
        ),
      ];

  // Gradientes padronizados
  static LinearGradient get primaryGradient => LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          primaryCardColor,
          secondaryCardColor.withOpacity(0.7),
        ],
      );

  static LinearGradient get featureGradient => LinearGradient(
        colors: [
          AppColors.primaria.withOpacity(0.1),
          AppColors.secundaria.withOpacity(0.1),
        ],
      );

  // Estilos de texto padronizados
  static const TextStyle headingStyle = TextStyle(
    fontSize: headingFontSize,
    fontWeight: FontWeight.bold,
    color: Colors.black87,
  );

  static const TextStyle subheadingStyle = TextStyle(
    fontSize: subheadingFontSize,
    fontWeight: FontWeight.bold,
    color: Colors.black87,
  );

  static const TextStyle bodyStyle = TextStyle(
    fontSize: bodyFontSize,
    color: Colors.black54,
    height: 1.5,
  );

  static const TextStyle captionStyle = TextStyle(
    fontSize: captionFontSize,
    color: Colors.black54,
  );

  // Estilos de botão padronizados
  static ButtonStyle get primaryButtonStyle => ElevatedButton.styleFrom(
        backgroundColor: AppColors.primaria,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(borderRadius),
        ),
        elevation: mediumElevation,
      );

  static ButtonStyle get secondaryButtonStyle => OutlinedButton.styleFrom(
        foregroundColor: AppColors.primaria,
        side: const BorderSide(color: AppColors.primaria),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(borderRadius),
        ),
      );

  // Decoração de container padronizada
  static BoxDecoration get cardDecoration => BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(largeBorderRadius),
        boxShadow: mediumShadow,
      );

  static BoxDecoration get primaryContainerDecoration => BoxDecoration(
        gradient: primaryGradient,
        borderRadius: BorderRadius.circular(extraLargeBorderRadius),
        boxShadow: heavyShadow,
      );

  // Padding responsivo
  static EdgeInsets responsivePadding(bool isMobile) => EdgeInsets.symmetric(
        horizontal: isMobile ? 16.0 : 24.0,
        vertical: 24.0,
      );

  // Container com largura máxima
  static Widget constrainedContent({
    required Widget child,
    bool isMobile = false,
  }) {
    return Container(
      width: double.infinity,
      constraints: BoxConstraints(
        maxWidth: isMobile ? double.infinity : maxContentWidth,
      ),
      padding: responsivePadding(isMobile),
      child: child,
    );
  }
} 