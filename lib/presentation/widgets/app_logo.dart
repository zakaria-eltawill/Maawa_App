import 'package:flutter/material.dart';

/// A reusable logo widget that displays the app logo
/// Can be used in various sizes and contexts
class AppLogo extends StatelessWidget {
  final double? width;
  final double? height;
  final BoxFit fit;
  final Color? color;

  const AppLogo({
    super.key,
    this.width,
    this.height,
    this.fit = BoxFit.contain,
    this.color,
  });

  /// Logo for use in headers (e.g., RoundedHeader)
  const AppLogo.header({
    super.key,
    this.width = 80,
    this.height = 80,
    this.fit = BoxFit.contain,
    this.color,
  });

  /// Logo for use in splash screen
  const AppLogo.splash({
    super.key,
    this.width = 150,
    this.height = 150,
    this.fit = BoxFit.contain,
    this.color,
  });

  /// Logo for use in app bars or small contexts
  const AppLogo.small({
    super.key,
    this.width = 40,
    this.height = 40,
    this.fit = BoxFit.contain,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      'assets/images/Logo.png',
      width: width,
      height: height,
      fit: fit,
      color: color,
      errorBuilder: (context, error, stackTrace) {
        // Fallback if logo is not found
        return Icon(
          Icons.home,
          size: width ?? height ?? 40,
          color: color,
        );
      },
    );
  }
}

