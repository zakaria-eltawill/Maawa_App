import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:maawa_project/core/di/providers.dart';
import 'package:maawa_project/core/theme/app_theme.dart';
import 'package:maawa_project/presentation/widgets/app_button.dart';
import 'package:maawa_project/presentation/widgets/app_text_field.dart';
import 'package:maawa_project/presentation/widgets/success_dialog.dart';

class ReviewCreateScreen extends ConsumerStatefulWidget {
  final String propertyId;

  const ReviewCreateScreen({
    super.key,
    required this.propertyId,
  });

  @override
  ConsumerState<ReviewCreateScreen> createState() =>
      _ReviewCreateScreenState();
}

class _ReviewCreateScreenState extends ConsumerState<ReviewCreateScreen> {
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

      if (mounted) {
        // Show success animation
        await SuccessDialog.show(
          context,
          title: 'Review Submitted!',
          message: 'Thank you for sharing your experience',
        );
        
        if (mounted) {
          context.pop();
        }
      }
    } catch (e) {
      if (mounted) {
        String errorMessage = 'Failed to submit review';
        
        // Handle specific errors
        if (e.toString().contains('403') || e.toString().contains('forbidden')) {
          errorMessage = 'You can only review properties after completing a stay';
        } else if (e.toString().contains('404')) {
          errorMessage = 'Property not found';
        } else if (e.toString().contains('422')) {
          errorMessage = 'Invalid review data. Please check your input.';
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Write Review'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppTheme.spacingLG),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Rating',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(5, (index) {
                    return IconButton(
                      icon: Icon(
                        index < _rating ? Icons.star : Icons.star_border,
                        color: Colors.amber,
                        size: 48,
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
                AppTextField(
                  label: 'Comment',
                  controller: _commentController,
                  maxLines: 5,
                  hint: 'Share your experience...',
                ),
                const SizedBox(height: 24),
                AppButton(
                  text: 'Submit Review',
                  onPressed: _isSubmitting ? null : _submitReview,
                  isLoading: _isSubmitting,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

