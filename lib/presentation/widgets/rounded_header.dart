import 'package:flutter/material.dart';
import 'package:maawa_project/core/theme/app_theme.dart';

class RoundedHeader extends StatelessWidget {
  final String? title;
  final String? subtitle;
  final Widget? icon;
  final double height;
  final Color backgroundColor;

  const RoundedHeader({
    super.key,
    this.title,
    this.subtitle,
    this.icon,
    this.height = 200,
    this.backgroundColor = AppTheme.primaryBlue,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(32),
          bottomRight: Radius.circular(32),
        ),
      ),
      child: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (icon != null) ...[
              icon!,
              const SizedBox(height: 16),
            ],
            if (title != null)
              Text(
                title!,
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
              ),
            if (subtitle != null) ...[
              const SizedBox(height: 8),
              Text(
                subtitle!,
                style: TextStyle(
                  fontSize: 15,
                  color: Colors.white.withOpacity(0.9),
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

