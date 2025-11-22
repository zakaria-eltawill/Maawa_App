import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:maawa_project/core/di/providers.dart';
import 'package:maawa_project/core/theme/app_theme.dart';
import 'package:maawa_project/domain/entities/booking.dart';
import 'package:maawa_project/presentation/widgets/empty_state.dart';
import 'package:maawa_project/presentation/widgets/error_state.dart';
import 'package:maawa_project/presentation/widgets/state_badge.dart';
import 'package:maawa_project/presentation/widgets/shimmer_loading.dart';
import 'package:intl/intl.dart';
import 'package:cached_network_image/cached_network_image.dart';

class BookingListScreen extends ConsumerWidget {
  const BookingListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bookingsAsync = ref.watch(bookingsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Bookings'),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(bookingsProvider);
        },
        child: bookingsAsync.when(
                data: (bookings) {
                  if (bookings.isEmpty) {
                    return Center(
                      child: EmptyState(
                        message: 'No Bookings Yet',
                        subtitle: 'Start exploring properties and make your first booking!',
                        icon: Icons.event_available_outlined,
                        iconColor: AppTheme.primaryBlue,
                        action: ElevatedButton.icon(
                          onPressed: () {
                            // Navigate to discover tab (assuming index 0)
                            DefaultTabController.of(context).animateTo(0);
                          },
                          icon: const Icon(Icons.search),
                          label: const Text('Browse Properties'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.primaryBlue,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 12,
                            ),
                          ),
                        ),
                      ),
                    );
                  }
            return ListView.builder(
              padding: const EdgeInsets.all(AppTheme.spacingMD),
              itemCount: bookings.length,
              itemBuilder: (context, index) {
                final booking = bookings[index];
                return _BookingCardWithImage(booking: booking);
              },
            );
          },
                loading: () => ListView.builder(
                  padding: const EdgeInsets.all(AppTheme.spacingMD),
                  itemCount: 3,
                  itemBuilder: (context, index) => const SkeletonBookingCard(),
                ),
          error: (error, stack) {
            final errorString = error.toString().toLowerCase();
            
            if (errorString.contains('socket') || 
                errorString.contains('network') ||
                errorString.contains('connection')) {
              return NetworkErrorState(
                onRetry: () => ref.invalidate(bookingsProvider),
              );
            } else if (errorString.contains('404')) {
              return const NotFoundErrorState(
                itemName: 'Bookings',
              );
            } else {
              return ServerErrorState(
                onRetry: () => ref.invalidate(bookingsProvider),
                errorDetails: error.toString(),
              );
            }
          },
        ),
      ),
    );
  }
}

// Wrapper that fetches property image if missing from booking
class _BookingCardWithImage extends ConsumerWidget {
  final Booking booking;

  const _BookingCardWithImage({required this.booking});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // If booking already has thumbnail, show it directly
    if (booking.propertyThumbnail != null && booking.propertyThumbnail!.isNotEmpty) {
      return _BookingCard(booking: booking);
    }

    // Otherwise, fetch property details to get the image
    final propertyAsync = ref.watch(propertyDetailProvider(booking.propertyId));

    return propertyAsync.when(
      data: (property) {
        // Create enriched booking with property image
        final enrichedBooking = Booking(
          id: booking.id,
          propertyId: booking.propertyId,
          propertyName: booking.propertyName ?? property.name,
          propertyType: booking.propertyType ?? property.propertyType,
          propertyCity: booking.propertyCity ?? property.city,
          propertyThumbnail: property.imageUrls.isNotEmpty 
              ? property.imageUrls.first 
              : null,
          tenantId: booking.tenantId,
          tenantName: booking.tenantName,
          tenantEmail: booking.tenantEmail,
          tenantPhone: booking.tenantPhone,
          checkIn: booking.checkIn,
          checkOut: booking.checkOut,
          status: booking.status,
          guests: booking.guests,
          totalPrice: booking.totalPrice,
          isPaid: booking.isPaid,
          createdAt: booking.createdAt,
          updatedAt: booking.updatedAt,
          rejectionReason: booking.rejectionReason,
          timeline: booking.timeline,
        );
        return _BookingCard(booking: enrichedBooking);
      },
      loading: () => _BookingCard(booking: booking), // Show card with placeholder while loading
      error: (error, stack) => _BookingCard(booking: booking), // Show card with placeholder on error
    );
  }
}

class _BookingCard extends StatelessWidget {
  final Booking booking;

  const _BookingCard({required this.booking});

  Color _getStatusColor(BookingStatus status) {
    switch (status) {
      case BookingStatus.accepted:
        return AppTheme.primaryBlue;
      case BookingStatus.confirmed:
        return AppTheme.successGreen;
      case BookingStatus.completed:
        return const Color(0xFF10B981);
      case BookingStatus.pending:
        return AppTheme.warningOrange;
      case BookingStatus.rejected:
      case BookingStatus.canceled:
        return AppTheme.dangerRed;
      case BookingStatus.expired:
        return AppTheme.gray500;
    }
  }

  String _getStatusLabel(BookingStatus status) {
    return status.name.toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('MMM dd, yyyy');
    final priceFormat = NumberFormat.currency(
      locale: 'ar_LY',
      symbol: 'د.ل',
      decimalDigits: 2,
    );

    if (kDebugMode) {
      debugPrint('🎨 Building booking card for: ${booking.propertyName}');
      debugPrint('🖼️  Thumbnail URL: ${booking.propertyThumbnail}');
    }

    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: AppTheme.spacingMD),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppTheme.radiusLG),
      ),
      child: InkWell(
        onTap: () {
          context.push('/home/booking/${booking.id}');
        },
        borderRadius: BorderRadius.circular(AppTheme.radiusLG),
        child: Padding(
          padding: const EdgeInsets.all(AppTheme.spacingMD),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Property Thumbnail
              ClipRRect(
                borderRadius: BorderRadius.circular(AppTheme.radiusMD),
                child: booking.propertyThumbnail != null && 
                       booking.propertyThumbnail!.isNotEmpty
                    ? CachedNetworkImage(
                        imageUrl: booking.propertyThumbnail!,
                        width: 80,
                        height: 80,
                        fit: BoxFit.cover,
                        placeholder: (context, url) => Container(
                          width: 80,
                          height: 80,
                          color: AppTheme.gray200,
                          child: const Center(
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                        ),
                        errorWidget: (context, url, error) {
                          debugPrint('❌ Failed to load booking image: $url');
                          debugPrint('❌ Error: $error');
                          return _buildPlaceholderImage();
                        },
                      )
                    : _buildPlaceholderImage(),
              ),
              const SizedBox(width: AppTheme.spacingMD),
              // Booking Details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Property Name & Status
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                booking.propertyName ?? 'Property',
                                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                      fontWeight: FontWeight.w600,
                                      color: AppTheme.gray900,
                                    ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              if (booking.propertyCity != null)
                                Text(
                                  booking.propertyCity!,
                                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                        color: AppTheme.gray600,
                                      ),
                                ),
                            ],
                          ),
                        ),
                        const SizedBox(width: AppTheme.spacingSM),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppTheme.spacingSM,
                            vertical: AppTheme.spacingXS,
                          ),
                          decoration: BoxDecoration(
                            color: _getStatusColor(booking.status).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(AppTheme.radiusSM),
                          ),
                          child: Text(
                            _getStatusLabel(booking.status),
                            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                  color: _getStatusColor(booking.status),
                                  fontWeight: FontWeight.w600,
                                ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppTheme.spacingSM),
                    // Tenant Name (for owners)
                    if (booking.tenantName != null) ...[
                      Row(
                        children: [
                          Icon(
                            Icons.person_outline,
                            size: 14,
                            color: AppTheme.gray600,
                          ),
                          const SizedBox(width: AppTheme.spacingXS),
                          Text(
                            booking.tenantName!,
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: AppTheme.gray700,
                                ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppTheme.spacingXS),
                    ],
                    // Dates
                    Row(
                      children: [
                        Icon(
                          Icons.calendar_today_outlined,
                          size: 14,
                          color: AppTheme.gray600,
                        ),
                        const SizedBox(width: AppTheme.spacingXS),
                        Expanded(
                          child: Text(
                            '${dateFormat.format(booking.checkIn)} - ${dateFormat.format(booking.checkOut)}',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: AppTheme.gray700,
                                ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppTheme.spacingXS),
                    // Guests & Price
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        if (booking.guests != null)
                          Row(
                            children: [
                              Icon(
                                Icons.people_outline,
                                size: 14,
                                color: AppTheme.gray600,
                              ),
                              const SizedBox(width: AppTheme.spacingXS),
                              Text(
                                '${booking.guests} Guests',
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: AppTheme.gray700,
                                    ),
                              ),
                            ],
                          ),
                        Text(
                          priceFormat.format(booking.totalPrice),
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                color: AppTheme.primaryBlue,
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPlaceholderImage() {
    return Container(
      width: 80,
      height: 80,
      color: AppTheme.gray200,
      child: Icon(
        Icons.home_outlined,
        color: AppTheme.gray500,
        size: 32,
      ),
    );
  }
}

