import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:maawa_project/core/di/providers.dart';
import 'package:maawa_project/core/theme/app_theme.dart';
import 'package:maawa_project/domain/entities/property.dart';
import 'package:maawa_project/domain/entities/user.dart';
import 'package:maawa_project/presentation/widgets/app_button.dart';
import 'package:maawa_project/presentation/widgets/app_card.dart';
import 'package:maawa_project/presentation/widgets/rating_display.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:maawa_project/l10n/app_localizations.dart';
import 'package:intl/intl.dart';

class PropertyDetailScreen extends ConsumerStatefulWidget {
  final String propertyId;

  const PropertyDetailScreen({
    super.key,
    required this.propertyId,
  });

  @override
  ConsumerState<PropertyDetailScreen> createState() =>
      _PropertyDetailScreenState();
}

class _PropertyDetailScreenState extends ConsumerState<PropertyDetailScreen> {
  int _currentImageIndex = 0;
  final _pageController = PageController();

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final propertyAsync = ref.watch(propertyDetailProvider(widget.propertyId));
    final currentUserAsync = ref.watch(currentUserProvider);
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              ref.invalidate(propertyDetailProvider(widget.propertyId));
            },
          ),
        ],
      ),
      body: propertyAsync.when(
        data: (property) {
          return RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(propertyDetailProvider(widget.propertyId));
            },
            child: _buildPropertyContent(property, currentUserAsync, l10n),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.error_outline,
                  size: 64,
                  color: AppTheme.dangerRed,
                ),
                const SizedBox(height: 16),
                Text(
                  AppLocalizations.of(context).failedToLoad,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 8),
                Text(
                  error.toString(),
                  style: Theme.of(context).textTheme.bodySmall,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: () {
                    ref.invalidate(propertyDetailProvider(widget.propertyId));
                  },
                  icon: const Icon(Icons.refresh),
                  label: Text(AppLocalizations.of(context).retry),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPropertyContent(Property property, AsyncValue<User> currentUserAsync, AppLocalizations l10n) {
    // Debug: Log owner information
    if (kDebugMode) {
      debugPrint('🏠 Property Detail - Property ID: ${property.id}');
      debugPrint('🏠 Property Detail - Owner ID: ${property.ownerId}');
      debugPrint('🏠 Property Detail - Owner Name: ${property.ownerName}');
      debugPrint('🏠 Property Detail - Owner Phone: ${property.ownerPhone}');
    }
    
    // Check if current user is the owner of this property
    // If property has ownerId, check if it matches user.id
    // If property doesn't have ownerId but user is owner, assume they own it
    // (owner endpoint doesn't return ownerId since owner already knows their own info)
    final isOwner = currentUserAsync.maybeWhen(
      data: (user) {
        final isOwnerRole = user.role == UserRole.owner;
        
        // If property has ownerId, check if it matches
        if (property.ownerId != null && property.ownerId!.isNotEmpty) {
          final isPropertyOwner = property.ownerId == user.id;
          if (kDebugMode) {
            debugPrint('🔍 Property Detail - User ID: ${user.id}, Role: ${user.role}');
            debugPrint('🔍 Property Detail - Property Owner ID: ${property.ownerId}');
            debugPrint('🔍 Property Detail - Is Owner Role: $isOwnerRole, Is Property Owner: $isPropertyOwner');
          }
          return isOwnerRole && isPropertyOwner;
        } else {
          // Property doesn't have ownerId - if user is owner, assume they own it
          // (This happens when using /owner/properties/:id endpoint)
          if (kDebugMode) {
            debugPrint('🔍 Property Detail - User ID: ${user.id}, Role: ${user.role}');
            debugPrint('🔍 Property Detail - Property Owner ID: null (owner endpoint)');
            debugPrint('🔍 Property Detail - Is Owner Role: $isOwnerRole, Assuming owner (owner endpoint)');
          }
          return isOwnerRole;
        }
      },
      orElse: () {
        if (kDebugMode) {
          debugPrint('🔍 Property Detail - No current user data');
        }
        return false;
      },
    );
    
    final locale = Localizations.localeOf(context);
    final priceFormat = NumberFormat.currency(
      symbol: locale.languageCode == 'ar' ? 'دل' : 'LYD',
      decimalDigits: 0,
      customPattern: '#,### \u00A4',
    );
    
    return Stack(
      children: [
        // Content
        CustomScrollView(
                slivers: [
                  // Image gallery
                  SliverToBoxAdapter(
                    child: SizedBox(
                      height: 350,
                      child: Stack(
                        children: [
                          if (property.imageUrls.isNotEmpty)
                            PageView.builder(
                              controller: _pageController,
                              itemCount: property.imageUrls.length,
                              onPageChanged: (index) {
                                setState(() => _currentImageIndex = index);
                              },
                              itemBuilder: (context, index) {
                                return CachedNetworkImage(
                                  imageUrl: property.imageUrls[index],
                                  fit: BoxFit.cover,
                                  placeholder: (context, url) => Container(
                                    color: AppTheme.gray200,
                                    child: const Center(
                                      child: CircularProgressIndicator(),
                                    ),
                                  ),
                                  errorWidget: (context, url, error) =>
                                      Container(
                                    color: AppTheme.gray200,
                                    child: const Icon(
                                      Icons.image_not_supported,
                                      size: 64,
                                      color: AppTheme.gray400,
                                    ),
                                  ),
                                );
                              },
                            )
                          else
                            Container(
                              color: AppTheme.gray200,
                              child: const Center(
                                child: Icon(
                                  Icons.home_outlined,
                                  size: 64,
                                  color: AppTheme.gray400,
                                ),
                              ),
                            ),
                          
                          // Page indicators
                          if (property.imageUrls.length > 1)
                            Positioned(
                              bottom: 16,
                              left: 0,
                              right: 0,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: List.generate(
                                  property.imageUrls.length,
                                  (index) => Container(
                                    width: 8,
                                    height: 8,
                                    margin: const EdgeInsets.symmetric(
                                        horizontal: 4),
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: _currentImageIndex == index
                                          ? Colors.white
                                          : Colors.white.withValues(alpha: 0.5),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                  
                  // Property details
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Title
                          Text(
                            property.name,
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.gray900,
                            ),
                          ),
                          const SizedBox(height: 12),
                          
                          // Rating & Reviews (only for tenants)
                          // Always show rating widget - it will handle null internally
                          if (!isOwner) ...[
                            Builder(
                              builder: (context) {
                                if (kDebugMode) {
                                  debugPrint('🏠 PropertyDetail: ${property.name}');
                                  debugPrint('   - Rating: ${property.averageRating}, Reviews: ${property.reviewCount}');
                                  debugPrint('   - Is Owner: $isOwner');
                                }
                                return RatingDisplay(
                                  averageRating: property.averageRating,
                                  reviewCount: property.reviewCount,
                                  showReviewCount: true,
                                  starSize: 20,
                                  fontSize: 16,
                                  compact: false,
                                );
                              },
                            ),
                            const SizedBox(height: 16),
                          ] else
                            const SizedBox(height: 8),
                          
                          // Location
                          Row(
                            children: [
                              const Icon(
                                Icons.location_on,
                                size: 18,
                                color: AppTheme.gray500,
                              ),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  '${l10n.city} ${property.city}${property.address != null ? '، ${property.address}' : ''}',
                                  style: const TextStyle(
                                    fontSize: 15,
                                    color: AppTheme.gray600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),
                          
                          // Price
                          Row(
                            children: [
                              Text(
                                priceFormat.format(property.pricePerNight),
                                style: const TextStyle(
                                  fontSize: 28,
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.primaryBlue,
                                ),
                              ),
                              Text(
                                ' ${l10n.perNight}',
                                style: const TextStyle(
                                  fontSize: 16,
                                  color: AppTheme.gray600,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),
                          
                          // Owner card (only show for non-owners)
                          // Show if owner name or phone exists (and phone is not empty)
                          if (!isOwner && ((property.ownerName != null && property.ownerName!.isNotEmpty) || 
                              (property.ownerPhone != null && property.ownerPhone!.isNotEmpty)))
                            AppCard(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Container(
                                        width: 50,
                                        height: 50,
                                        decoration: BoxDecoration(
                                          color: AppTheme.primaryBlue.withValues(alpha: 0.1),
                                          shape: BoxShape.circle,
                                        ),
                                        child: const Icon(
                                          Icons.person,
                                          color: AppTheme.primaryBlue,
                                          size: 28,
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              l10n.ownerInfo,
                                              style: const TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.w600,
                                                color: AppTheme.gray900,
                                              ),
                                            ),
                                            if (property.ownerName != null && property.ownerName!.isNotEmpty) ...[
                                              const SizedBox(height: 2),
                                              Text(
                                                property.ownerName!,
                                                style: const TextStyle(
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.w500,
                                                  color: AppTheme.gray700,
                                                ),
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ],
                                            if (property.ownerPhone != null && property.ownerPhone!.isNotEmpty) ...[
                                              const SizedBox(height: 4),
                                              Row(
                                                children: [
                                                  const Icon(
                                                    Icons.phone_outlined,
                                                    size: 14,
                                                    color: AppTheme.gray600,
                                                  ),
                                                  const SizedBox(width: 4),
                                                  Flexible(
                                                    child: Text(
                                                      property.ownerPhone!,
                                                      style: const TextStyle(
                                                        fontSize: 13,
                                                        color: AppTheme.gray600,
                                                      ),
                                                      maxLines: 1,
                                                      overflow: TextOverflow.ellipsis,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                  if (property.ownerPhone != null && property.ownerPhone!.isNotEmpty) ...[
                                    const SizedBox(height: 12),
                                    Builder(
                                      builder: (buttonContext) {
                                        final messenger = ScaffoldMessenger.of(buttonContext);
                                        return SizedBox(
                                          width: double.infinity,
                                          child: ElevatedButton.icon(
                                            onPressed: () async {
                                              final phoneNumber = property.ownerPhone!;
                                              final uri = Uri.parse('tel:$phoneNumber');
                                              try {
                                                if (await canLaunchUrl(uri)) {
                                                  await launchUrl(uri, mode: LaunchMode.externalApplication);
                                                } else {
                                                  if (!mounted) return;
                                                  messenger.showSnackBar(
                                                    SnackBar(
                                                      content: Text('Cannot make phone call to $phoneNumber'),
                                                      backgroundColor: AppTheme.dangerRed,
                                                    ),
                                                  );
                                                }
                                              } catch (e) {
                                                if (!mounted) return;
                                                messenger.showSnackBar(
                                                  SnackBar(
                                                    content: Text('Failed to open phone dialer: $e'),
                                                    backgroundColor: AppTheme.dangerRed,
                                                  ),
                                                );
                                              }
                                            },
                                            icon: const Icon(Icons.phone, color: Colors.white),
                                            label: Text(l10n.contactOwner),
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: AppTheme.primaryBlue,
                                              foregroundColor: Colors.white,
                                              padding: const EdgeInsets.symmetric(
                                                horizontal: 24,
                                                vertical: 16,
                                              ),
                                              shape: RoundedRectangleBorder(
                                                borderRadius: BorderRadius.circular(12),
                                              ),
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          
                          // Owner statistics (only show for owners)
                          if (isOwner)
                            AppCard(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'إحصائيات العقار',
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w600,
                                      color: AppTheme.gray900,
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: _buildStatCard(
                                          icon: Icons.calendar_today,
                                          label: 'الحجوزات',
                                          value: (property.bookingsCount ?? 0).toString(),
                                          color: AppTheme.primaryBlue,
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: _buildStatCard(
                                          icon: Icons.attach_money,
                                          label: 'إجمالي الإيرادات',
                                          value: priceFormat.format(property.totalRevenue ?? 0),
                                          color: AppTheme.successGreen,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 12),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: _buildStatCard(
                                          icon: Icons.star,
                                          label: 'التقييمات',
                                          value: (property.reviewCount ?? 0).toString(),
                                          color: AppTheme.goldYellow,
                                        ),
                                      ),
                                      if (property.averageRating != null) ...[
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: _buildStatCard(
                                            icon: Icons.star_rate,
                                            label: 'متوسط التقييم',
                                            value: property.averageRating!.toStringAsFixed(1),
                                            color: AppTheme.goldYellow,
                                          ),
                                        ),
                                      ] else
                                        const SizedBox(width: 12),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          
                          const SizedBox(height: 24),
                          
                          // Description
                          if (property.description != null && property.description!.isNotEmpty) ...[
                            Text(
                              l10n.description,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: AppTheme.gray900,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              property.description!,
                              style: const TextStyle(
                                fontSize: 15,
                                height: 1.5,
                                color: AppTheme.gray700,
                              ),
                            ),
                            const SizedBox(height: 24),
                          ],
                          
                          // Amenities
                          if (property.amenities.isNotEmpty) ...[
                            Text(
                              l10n.amenities,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: AppTheme.gray900,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: property.amenities.map((amenity) {
                                return Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 10,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppTheme.gray100,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        _getAmenityIcon(amenity),
                                        size: 18,
                                        color: AppTheme.primaryBlue,
                                      ),
                                      const SizedBox(width: 6),
                                      Text(
                                        amenity,
                                        style: const TextStyle(
                                          fontSize: 14,
                                          color: AppTheme.gray800,
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              }).toList(),
                            ),
                            const SizedBox(height: 24),
                          ],
                          
                          // Map button
                          if (property.mapUrl.isNotEmpty)
                            SizedBox(
                              width: double.infinity,
                              child: OutlinedButton.icon(
                                onPressed: () async {
                                  final uri = Uri.parse(property.mapUrl);
                                  if (await canLaunchUrl(uri)) {
                                    await launchUrl(uri, mode: LaunchMode.externalApplication);
                                  } else {
                                    if (context.mounted) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(
                                          content: Text('Could not open map'),
                                        ),
                                      );
                                    }
                                  }
                                },
                                icon: const Icon(Icons.map_outlined),
                                label: Text(l10n.viewOnMap),
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: AppTheme.primaryBlue,
                                  side: BorderSide(color: AppTheme.primaryBlue, width: 1.5),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 24,
                                    vertical: 16,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                              ),
                            ),
                          
                          const SizedBox(height: 100), // Space for bottom button
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              
              // Bottom action button (Book for tenants, Edit for owners)
              if (!isOwner)
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.1),
                          blurRadius: 10,
                          offset: const Offset(0, -4),
                        ),
                      ],
                    ),
                    child: AppButton(
                      text: l10n.bookNow,
                      icon: Icons.calendar_today,
                      onPressed: () {
                        context.push('/home/booking/create/${widget.propertyId}');
                      },
                    ),
                  ),
                )
        else
          Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.1),
                          blurRadius: 10,
                          offset: const Offset(0, -4),
                        ),
                      ],
                    ),
                    child: AppButton(
                      text: l10n.editProperty,
                      icon: Icons.edit_outlined,
                      onPressed: () {
                        context.push('/home/owner/property/edit/${widget.propertyId}');
                      },
                    ),
                  ),
                ),
            ],
          );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            color: color,
            size: 24,
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: AppTheme.gray600,
            ),
          ),
        ],
      ),
    );
  }

  IconData _getAmenityIcon(String amenity) {
    final lower = amenity.toLowerCase();
    if (lower.contains('wifi') || lower.contains('واي')) {
      return Icons.wifi;
    } else if (lower.contains('parking') || lower.contains('موقف')) {
      return Icons.local_parking;
    } else if (lower.contains('pool') || lower.contains('مسبح')) {
      return Icons.pool;
    } else if (lower.contains('gym') || lower.contains('رياضة')) {
      return Icons.fitness_center;
    } else if (lower.contains('balcony') || lower.contains('شرفة')) {
      return Icons.balcony;
    } else if (lower.contains('kitchen') || lower.contains('مطبخ')) {
      return Icons.kitchen;
    } else if (lower.contains('tv') || lower.contains('تلفزيون')) {
      return Icons.tv;
    } else if (lower.contains('air') || lower.contains('تكييف')) {
      return Icons.ac_unit;
    } else if (lower.contains('security') || lower.contains('حراسة')) {
      return Icons.security;
    } else if (lower.contains('elevator') || lower.contains('مصعد')) {
      return Icons.elevator;
    } else {
      return Icons.check_circle_outline;
    }
  }
}
