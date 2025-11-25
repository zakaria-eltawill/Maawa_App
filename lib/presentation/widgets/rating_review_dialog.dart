import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:maawa_project/core/di/providers.dart';
import 'package:maawa_project/core/theme/app_theme.dart';
import 'package:maawa_project/presentation/widgets/app_button.dart';
import 'package:maawa_project/presentation/widgets/app_text_field.dart';
import 'package:maawa_project/presentation/widgets/success_dialog.dart';
import 'package:maawa_project/l10n/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';

class RatingReviewDialog extends ConsumerStatefulWidget {
  final String propertyId;
  final String bookingId;
  final String propertyName;

  const RatingReviewDialog({
    super.key,
    required this.propertyId,
    required this.bookingId,
    required this.propertyName,
  });

  static Future<void> show(
    BuildContext context, {
    required String propertyId,
    required String bookingId,
    required String propertyName,
  }) async {
    return showDialog(
      context: context,
      barrierDismissible: false, // Prevent dismissing by tapping outside
      builder: (context) => RatingReviewDialog(
        propertyId: propertyId,
        bookingId: bookingId,
        propertyName: propertyName,
      ),
    );
  }

  @override
  ConsumerState<RatingReviewDialog> createState() => _RatingReviewDialogState();
}

class _RatingReviewDialogState extends ConsumerState<RatingReviewDialog> {
  final _formKey = GlobalKey<FormState>();
  final _commentController = TextEditingController();
  int _rating = 5;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _submitReview() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final postReviewUseCase = ref.read(postReviewUseCaseProvider);
      
      await postReviewUseCase(
        propertyId: widget.propertyId,
        rating: _rating,
        comment: _commentController.text.trim().isEmpty 
            ? null 
            : _commentController.text.trim(),
      );

      // Mark this booking as reviewed
      await _markBookingAsReviewed(widget.bookingId);

      if (mounted) {
        // Invalidate property providers to refresh ratings
        ref.invalidate(propertyDetailProvider(widget.propertyId));
        ref.invalidate(propertiesProvider);
        
        // Show success dialog
        Navigator.of(context).pop(); // Close rating dialog first
        await SuccessDialog.show(
          context,
          title: AppLocalizations.of(context).reviewSubmitted,
          message: AppLocalizations.of(context).thankYouForReview,
        );
      }
    } catch (e) {
      if (mounted) {
        final l10n = AppLocalizations.of(context);
        String errorMessage = l10n.failedToSubmitReview;
        
        // Handle specific errors
        if (e.toString().contains('403') || e.toString().contains('forbidden')) {
          errorMessage = l10n.reviewOnlyAfterStay;
        } else if (e.toString().contains('404')) {
          errorMessage = l10n.propertyNotFound;
        } else if (e.toString().contains('422')) {
          errorMessage = l10n.invalidReviewData;
        }
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: AppTheme.dangerRed,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  Future<void> _markBookingAsReviewed(String bookingId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final reviewedBookings = prefs.getStringList('reviewed_bookings') ?? [];
      if (!reviewedBookings.contains(bookingId)) {
        reviewedBookings.add(bookingId);
        await prefs.setStringList('reviewed_bookings', reviewedBookings);
      }
    } catch (e) {
      // Silently fail - not critical
      debugPrint('Failed to mark booking as reviewed: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 400),
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Title
              Text(
                l10n.rateYourExperience,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppTheme.gray900,
                    ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                widget.propertyName,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppTheme.gray600,
                    ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 24),
              
              // Rating stars
              Text(
                l10n.rating,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(5, (index) {
                  return IconButton(
                    icon: Icon(
                      index < _rating ? Icons.star : Icons.star_border,
                      color: Colors.amber,
                      size: 40,
                    ),
                    onPressed: () {
                      setState(() {
                        _rating = index + 1;
                      });
                    },
                  );
                }),
              ),
              const SizedBox(height: 24),
              
              // Comment field
              AppTextField(
                label: l10n.comment,
                controller: _commentController,
                maxLines: 4,
                hint: l10n.shareYourExperience,
              ),
              const SizedBox(height: 24),
              
              // Buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _isSubmitting ? null : () => Navigator.of(context).pop(),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(l10n.skip),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: AppButton(
                      text: l10n.submitReview,
                      onPressed: _isSubmitting ? null : _submitReview,
                      isLoading: _isSubmitting,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Helper function to check if a booking has been reviewed
Future<bool> hasBookingBeenReviewed(String bookingId) async {
  try {
    final prefs = await SharedPreferences.getInstance();
    final reviewedBookings = prefs.getStringList('reviewed_bookings') ?? [];
    return reviewedBookings.contains(bookingId);
  } catch (e) {
    return false;
  }
}

