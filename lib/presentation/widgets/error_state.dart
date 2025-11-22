import 'package:flutter/material.dart';
import 'package:maawa_project/core/theme/app_theme.dart';
import 'package:maawa_project/presentation/widgets/app_button.dart';

class ErrorState extends StatelessWidget {
  final String message;
  final String? subtitle;
  final VoidCallback? onRetry;
  final bool showDetails;
  final String? errorDetails;

  const ErrorState({
    super.key,
    required this.message,
    this.subtitle,
    this.onRetry,
    this.showDetails = false,
    this.errorDetails,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Error icon with pulsing animation
            TweenAnimationBuilder<double>(
              tween: Tween(begin: 0.8, end: 1.0),
              duration: const Duration(milliseconds: 1000),
              curve: Curves.easeInOut,
              builder: (context, value, child) {
                return Transform.scale(
                  scale: value,
                  child: Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      color: AppTheme.dangerRed.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.error_outline,
                      size: 48,
                      color: AppTheme.dangerRed,
                    ),
                  ),
                );
              },
              onEnd: () {
                // Animation loop handled by TweenAnimationBuilder
              },
            ),
            const SizedBox(height: 24),
            
            // Error message
            Text(
              message,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: AppTheme.gray900,
                    fontWeight: FontWeight.w600,
                  ),
              textAlign: TextAlign.center,
            ),
            
            // Subtitle
            if (subtitle != null) ...[
              const SizedBox(height: 8),
              Text(
                subtitle!,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppTheme.gray600,
                    ),
                textAlign: TextAlign.center,
              ),
            ],
            
            // Error details (collapsible)
            if (showDetails && errorDetails != null) ...[
              const SizedBox(height: 16),
              ExpansionTile(
                title: Text(
                  'Technical Details',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppTheme.gray600,
                      ),
                ),
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppTheme.gray100,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: SelectableText(
                      errorDetails!,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            fontFamily: 'monospace',
                            color: AppTheme.gray700,
                          ),
                    ),
                  ),
                ],
              ),
            ],
            
            // Retry button
            if (onRetry != null) ...[
              const SizedBox(height: 32),
              AppButton(
                text: 'Try Again',
                icon: Icons.refresh,
                onPressed: onRetry,
                isOutlined: true,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// Specific error states for common scenarios
class NetworkErrorState extends StatelessWidget {
  final VoidCallback? onRetry;

  const NetworkErrorState({
    super.key,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return ErrorState(
      message: 'Connection Error',
      subtitle: 'Please check your internet connection and try again',
      onRetry: onRetry,
    );
  }
}

class ServerErrorState extends StatelessWidget {
  final VoidCallback? onRetry;
  final String? errorDetails;

  const ServerErrorState({
    super.key,
    this.onRetry,
    this.errorDetails,
  });

  @override
  Widget build(BuildContext context) {
    return ErrorState(
      message: 'Server Error',
      subtitle: 'Something went wrong on our end. Please try again later.',
      onRetry: onRetry,
      showDetails: errorDetails != null,
      errorDetails: errorDetails,
    );
  }
}

class NotFoundErrorState extends StatelessWidget {
  final String? itemName;
  final VoidCallback? onGoBack;

  const NotFoundErrorState({
    super.key,
    this.itemName,
    this.onGoBack,
  });

  @override
  Widget build(BuildContext context) {
    return ErrorState(
      message: '${itemName ?? 'Item'} Not Found',
      subtitle: 'The ${itemName?.toLowerCase() ?? 'item'} you\'re looking for doesn\'t exist or has been removed.',
      onRetry: onGoBack,
    );
  }
}

