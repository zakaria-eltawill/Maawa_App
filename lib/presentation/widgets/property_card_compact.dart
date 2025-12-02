import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:maawa_project/core/theme/app_theme.dart';
import 'package:maawa_project/domain/entities/property.dart';
import 'package:maawa_project/presentation/widgets/status_badge.dart';
import 'package:maawa_project/presentation/widgets/rating_display.dart';
import 'package:maawa_project/presentation/widgets/network_image_with_timeout.dart';
import 'package:maawa_project/l10n/app_localizations.dart';
import 'package:intl/intl.dart';

class PropertyCardCompact extends StatelessWidget {
  final Property property;
  final VoidCallback? onTap;
  final bool showStatus;

  const PropertyCardCompact({
    super.key,
    required this.property,
    this.onTap,
    this.showStatus = true,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context);
    final priceFormat = NumberFormat.currency(
      symbol: locale.languageCode == 'ar' ? 'دل' : 'LYD',
      decimalDigits: 0,
      customPattern: '#,### \u00A4',
    );

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image with status badge
            Stack(
              children: [
                AspectRatio(
                  aspectRatio: 16 / 9,
                  child: _buildPropertyImage(property),
                ),
                if (showStatus)
                  Positioned(
                    top: 12,
                    left: 12,
                    child: StatusBadge.property(
                      PropertyStatus.available,
                      context,
                      small: true,
                    ),
                  ),
              ],
            ),
            
            // Property info
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  Builder(
                    builder: (context) {
                      if (kDebugMode) {
                        debugPrint('🏠 PropertyCard: ${property.name}');
                        debugPrint('   - Rating: ${property.averageRating} (type: ${property.averageRating.runtimeType})');
                        debugPrint('   - Review Count: ${property.reviewCount} (type: ${property.reviewCount.runtimeType})');
                        debugPrint('   - Will show rating: ${property.averageRating != null}');
                      }
                      return Text(
                        property.name,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.gray900,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      );
                    },
                  ),
                  
                  const SizedBox(height: 4),
                  
                  // Location
                  Text(
                    '${l10n.city} ${property.city}${property.address != null ? '، ${property.address}' : ''}',
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppTheme.gray600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  
                  const SizedBox(height: 8),
                  
                  // Price & Type
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Text(
                            priceFormat.format(property.pricePerNight),
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.primaryBlue,
                            ),
                          ),
                          Text(
                            l10n.perNight,
                            style: const TextStyle(
                              fontSize: 13,
                              color: AppTheme.gray600,
                            ),
                          ),
                        ],
                      ),
                      
                      // Property type icon
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: AppTheme.gray100,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Icon(
                          _getPropertyTypeIcon(property.propertyType),
                          size: 16,
                          color: AppTheme.gray600,
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 8),
                  
                  // Rating (moved below price)
                  RatingDisplay(
                    averageRating: property.averageRating,
                    reviewCount: property.reviewCount,
                    showReviewCount: true,
                    starSize: 14,
                    fontSize: 12,
                    compact: true,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPropertyImage(Property property) {
    // Check if image URLs are valid
    if (property.imageUrls.isEmpty) {
      return _buildPlaceholder();
    }

    final imageUrl = property.imageUrls.first;
    
    return NetworkImageWithTimeout(
      imageUrl: imageUrl,
      fit: BoxFit.cover,
      timeout: const Duration(seconds: 8),
      placeholder: _buildPlaceholder(showLoading: true),
      errorWidget: _buildPlaceholder(),
    );
  }

  Widget _buildPlaceholder({bool showLoading = false}) {
    return Container(
      color: AppTheme.gray200,
      child: showLoading
          ? const Center(
              child: CircularProgressIndicator(
                strokeWidth: 2,
              ),
            )
          : const Icon(
              Icons.home_outlined,
              size: 48,
              color: AppTheme.gray400,
            ),
    );
  }

  IconData _getPropertyTypeIcon(String type) {
    switch (type.toLowerCase()) {
      case 'villa':
        return Icons.villa_outlined;
      case 'apartment':
        return Icons.apartment_outlined;
      case 'chalet':
        return Icons.beach_access_outlined;
      default:
        return Icons.home_outlined;
    }
  }
}

