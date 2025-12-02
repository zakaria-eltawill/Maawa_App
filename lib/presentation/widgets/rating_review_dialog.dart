import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:maawa_project/core/di/providers.dart';
import 'package:maawa_project/core/theme/app_theme.dart';
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
        final errorString = e.toString().toLowerCase();
        if (errorString.contains('403') || 
            errorString.contains('forbidden') ||
            errorString.contains('no completed booking')) {
          errorMessage = l10n.reviewOnlyAfterStay;
        } else if (errorString.contains('404')) {
          errorMessage = l10n.propertyNotFound;
        } else if (errorString.contains('422')) {
          errorMessage = l10n.invalidReviewData;
        }
        
        // Show error dialog instead of snackbar for better visibility
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: Row(
              children: [
                Icon(Icons.error_outline, color: AppTheme.dangerRed, size: 24),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    l10n.error,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            content: Text(errorMessage),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text(
                  l10n.done,
                  style: TextStyle(color: AppTheme.primaryBlue),
                ),
              ),
            ],
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
    final size = MediaQuery.of(context).size;

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
      ),
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: Container(
        constraints: BoxConstraints(
          maxWidth: size.width * 0.9,
          maxHeight: size.height * 0.85,
        ),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Header Icon
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color: AppTheme.primaryBlue.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.star_rounded,
                    color: AppTheme.primaryBlue,
                    size: 32,
                  ),
                ),
                const SizedBox(height: 20),
                
                // Title
                Text(
                  l10n.rateYourExperience,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppTheme.gray900,
                        fontSize: 22,
                      ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                
                // Property Name
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: AppTheme.gray100,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    widget.propertyName,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppTheme.gray700,
                          fontWeight: FontWeight.w500,
                        ),
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(height: 32),
                
                // Rating Section
                Text(
                  l10n.rating,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppTheme.gray900,
                      ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                
                // Star Rating - Fixed overflow
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: List.generate(5, (index) {
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          _rating = index + 1;
                        });
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: Icon(
                          index < _rating ? Icons.star_rounded : Icons.star_border_rounded,
                          color: AppTheme.goldYellow,
                          size: 44,
                        ),
                      ),
                    );
                  }),
                ),
                const SizedBox(height: 8),
                
                // Rating Text
                Text(
                  _getRatingText(_rating, l10n),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppTheme.gray600,
                        fontWeight: FontWeight.w500,
                      ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                
                // Comment field
                AppTextField(
                  label: l10n.comment,
                  controller: _commentController,
                  maxLines: 5,
                  hint: l10n.shareYourExperience,
                ),
                const SizedBox(height: 32),
                
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
                          side: const BorderSide(color: AppTheme.gray300, width: 1.5),
                        ),
                        child: Text(
                          l10n.skip,
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            color: AppTheme.gray700,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      flex: 2,
                      child: ElevatedButton(
                        onPressed: _isSubmitting ? null : _submitReview,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primaryBlue,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 0,
                        ),
                        child: _isSubmitting
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                ),
                              )
                            : Text(
                                l10n.submitReview,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 16,
                                ),
                              ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _getRatingText(int rating, AppLocalizations l10n) {
    switch (rating) {
      case 1:
        return l10n.ratingPoor;
      case 2:
        return l10n.ratingFair;
      case 3:
        return l10n.ratingGood;
      case 4:
        return l10n.ratingVeryGood;
      case 5:
        return l10n.ratingExcellent;
      default:
        return '';
    }
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

