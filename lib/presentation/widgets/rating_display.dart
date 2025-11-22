import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:maawa_project/core/theme/app_theme.dart';
import 'package:maawa_project/l10n/app_localizations.dart';

/// A beautiful widget that displays property rating and review count
class RatingDisplay extends StatelessWidget {
  final double? averageRating;
  final int? reviewCount;
  final bool showReviewCount;
  final double starSize;
  final double fontSize;
  final bool compact;

  const RatingDisplay({
    super.key,
    required this.averageRating,
    this.reviewCount,
    this.showReviewCount = true,
    this.starSize = 16,
    this.fontSize = 14,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    
    // Debug: Log rating data
    if (kDebugMode) {
      debugPrint('⭐ RatingDisplay.build: averageRating=$averageRating, reviewCount=$reviewCount, compact=$compact');
    }
    
    // Backend now always returns numbers (0.0 for rating, 0 for count when no reviews)
    // Show "No rating and reviews yet" when rating is null or 0
    final hasRating = averageRating != null && averageRating! > 0;
    
    if (!hasRating) {
      if (compact) {
        return _buildNoRatingCompact(context, l10n);
      }
      return _buildNoRatingFull(context, l10n);
    }

    if (compact) {
      return _buildCompactRating(context, l10n);
    }

    return _buildFullRating(context, l10n);
  }

  Widget _buildNoRatingCompact(BuildContext context, AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppTheme.gray200.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppTheme.gray300,
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.star_outline_rounded,
            size: starSize,
            color: AppTheme.gray500,
          ),
          const SizedBox(width: 4),
          Text(
            l10n.noRatingAndReviews,
            style: TextStyle(
              fontSize: fontSize - 1,
              fontWeight: FontWeight.w500,
              color: AppTheme.gray600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNoRatingFull(BuildContext context, AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.gray100,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppTheme.gray300,
          width: 1.5,
        ),
      ),
      child: Row(
        children: [
          // Star outline icon
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppTheme.gray200,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.star_outline_rounded,
              size: starSize + 4,
              color: AppTheme.gray500,
            ),
          ),
          const SizedBox(width: 16),
          // No rating message
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.noRatingAndReviews,
                  style: TextStyle(
                    fontSize: fontSize + 2,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.gray700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  l10n.noReviews,
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppTheme.gray600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCompactRating(BuildContext context, AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppTheme.goldYellow.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppTheme.goldYellow.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.star_rounded,
            size: starSize,
            color: AppTheme.goldYellow,
          ),
          const SizedBox(width: 4),
          Text(
            averageRating!.toStringAsFixed(1),
            style: TextStyle(
              fontSize: fontSize,
              fontWeight: FontWeight.w600,
              color: AppTheme.gray900,
            ),
          ),
          if (showReviewCount && reviewCount != null && reviewCount! > 0) ...[
            const SizedBox(width: 6),
            Container(
              width: 1,
              height: 12,
              color: AppTheme.gray300,
            ),
            const SizedBox(width: 6),
            Text(
              '($reviewCount)',
              style: TextStyle(
                fontSize: fontSize - 2,
                color: AppTheme.gray600,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildFullRating(BuildContext context, AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.goldYellow.withValues(alpha: 0.1),
            AppTheme.goldYellow.withValues(alpha: 0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppTheme.goldYellow.withValues(alpha: 0.2),
          width: 1.5,
        ),
      ),
      child: Row(
        children: [
          // Star icon with rating
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppTheme.goldYellow.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.star_rounded,
              size: starSize + 4,
              color: AppTheme.goldYellow,
            ),
          ),
          const SizedBox(width: 16),
          // Rating and review count
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      averageRating!.toStringAsFixed(1),
                      style: TextStyle(
                        fontSize: fontSize + 4,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.gray900,
                      ),
                    ),
                    const SizedBox(width: 8),
                    ...List.generate(5, (index) {
                      return Icon(
                        index < averageRating!.round()
                            ? Icons.star_rounded
                            : Icons.star_border_rounded,
                        size: starSize - 2,
                        color: index < averageRating!.round()
                            ? AppTheme.goldYellow
                            : AppTheme.gray300,
                      );
                    }),
                  ],
                ),
                if (showReviewCount && reviewCount != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    reviewCount == 0
                        ? l10n.noReviews
                        : reviewCount == 1
                            ? '1 ${l10n.reviews.toLowerCase()}'
                            : '$reviewCount ${l10n.reviews.toLowerCase()}',
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppTheme.gray600,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

