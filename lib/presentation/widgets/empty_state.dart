import 'package:flutter/material.dart';
import 'package:maawa_project/core/theme/app_theme.dart';

class EmptyState extends StatefulWidget {
  final String message;
  final String? subtitle;
  final IconData icon;
  final Widget? action;
  final Color? iconColor;

  const EmptyState({
    super.key,
    required this.message,
    this.subtitle,
    this.icon = Icons.inbox_outlined,
    this.action,
    this.iconColor,
  });

  @override
  State<EmptyState> createState() => _EmptyStateState();
}

class _EmptyStateState extends State<EmptyState>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeIn),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.2),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: SlideTransition(
          position: _slideAnimation,
          child: Padding(
            padding: const EdgeInsets.all(40.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Icon with circular background
                Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    color: (widget.iconColor ?? AppTheme.gray400)
                        .withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    widget.icon,
                    size: 56,
                    color: widget.iconColor ?? AppTheme.gray400,
                  ),
                ),
                const SizedBox(height: 24),
                
                // Main message
                Text(
                  widget.message,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: AppTheme.gray900,
                        fontWeight: FontWeight.w600,
                      ),
                  textAlign: TextAlign.center,
                ),
                
                // Subtitle
                if (widget.subtitle != null) ...[
                  const SizedBox(height: 8),
                  Text(
                    widget.subtitle!,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppTheme.gray600,
                        ),
                    textAlign: TextAlign.center,
                  ),
                ],
                
                // Action button
                if (widget.action != null) ...[
                  const SizedBox(height: 32),
                  widget.action!,
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

