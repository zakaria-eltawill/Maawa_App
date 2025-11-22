import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:maawa_project/core/di/providers.dart';
import 'package:maawa_project/core/theme/app_theme.dart';
import 'package:maawa_project/domain/entities/booking.dart';
import 'package:maawa_project/l10n/app_localizations.dart';
import 'package:maawa_project/presentation/widgets/empty_state.dart';
import 'package:maawa_project/presentation/widgets/error_state.dart';
import 'package:maawa_project/presentation/widgets/shimmer_loading.dart';
import 'package:maawa_project/presentation/widgets/app_button.dart';
import 'package:maawa_project/presentation/widgets/app_card.dart';
import 'package:intl/intl.dart';
import 'package:cached_network_image/cached_network_image.dart';

class TenantBookingsScreen extends ConsumerWidget {
  const TenantBookingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bookingsAsync = ref.watch(bookingsProvider);
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.myBookings),
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
                  message: l10n.noBookingsYet,
                  subtitle: 'Start exploring properties and make your first booking!',
                  icon: Icons.event_available_outlined,
                  iconColor: AppTheme.primaryBlue,
                  action: ElevatedButton.icon(
                    onPressed: () {
                      // Navigate to home tab
                      DefaultTabController.of(context).animateTo(0);
                    },
                    icon: const Icon(Icons.search),
                    label: Text(l10n.browseProperties),
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
              padding: const EdgeInsets.all(16),
              itemCount: bookings.length,
              itemBuilder: (context, index) {
                final booking = bookings[index];
                return _TenantBookingCard(booking: booking);
              },
            );
          },
          loading: () => ListView.builder(
            padding: const EdgeInsets.all(16),
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

class _TenantBookingCard extends ConsumerStatefulWidget {
  final Booking booking;

  const _TenantBookingCard({required this.booking});

  @override
  ConsumerState<_TenantBookingCard> createState() => _TenantBookingCardState();
}

class _TenantBookingCardState extends ConsumerState<_TenantBookingCard> {
  bool _isProcessing = false;

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

  Widget _buildPropertyImage(Booking booking) {
    // If booking has thumbnail, try to use it first
    if (booking.propertyThumbnail != null && 
        booking.propertyThumbnail!.isNotEmpty) {
      return CachedNetworkImage(
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
          // If image fails to load, show placeholder
          return _buildPlaceholder();
        },
      );
    }
    // If no thumbnail, fetch property details as fallback
    return _buildPropertyImageFallback(booking.propertyId);
  }

  Widget _buildPropertyImageFallback(String propertyId) {
    final propertyAsync = ref.watch(propertyDetailProvider(propertyId));
    
    return propertyAsync.when(
      data: (property) {
        if (property.imageUrls.isNotEmpty) {
          return CachedNetworkImage(
            imageUrl: property.imageUrls.first,
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
            errorWidget: (context, url, error) => _buildPlaceholder(),
          );
        }
        return _buildPlaceholder();
      },
      loading: () => Container(
        width: 80,
        height: 80,
        color: AppTheme.gray200,
        child: const Center(
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      ),
      error: (_, __) => _buildPlaceholder(),
    );
  }

  Widget _buildPlaceholder() {
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

  Future<void> _handlePayment() async {
    // Only navigate to payment screen - payment processing happens there
    context.push('/home/booking/${widget.booking.id}/payment');
  }

  @override
  Widget build(BuildContext context) {
    final booking = widget.booking;
    final dateFormat = DateFormat('MMM dd, yyyy');
    final priceFormat = NumberFormat.currency(
      locale: 'ar_LY',
      symbol: 'د.ل',
      decimalDigits: 2,
    );

    // Show Pay button only if: status == accepted AND isPaid == false
    final showPayButton = booking.status == BookingStatus.accepted && !booking.isPaid;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: AppCard(
        child: InkWell(
          onTap: () {
            // Store booking in provider before navigating (backend doesn't have get-by-id endpoint)
            ref.read(selectedBookingProvider.notifier).state = booking;
            context.push('/home/booking/${booking.id}');
          },
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Property Image & Info
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: _buildPropertyImage(booking),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  booking.propertyName ?? 'Property',
                                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                        fontWeight: FontWeight.w600,
                                      ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: _getStatusColor(booking.status).withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(8),
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
                          if (booking.propertyCity != null) ...[
                            const SizedBox(height: 4),
                            Text(
                              booking.propertyCity!,
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: AppTheme.gray600,
                                  ),
                            ),
                          ],
                          const SizedBox(height: 8),
                          // Dates
                          Row(
                            children: [
                              Icon(Icons.calendar_today_outlined, size: 16, color: AppTheme.gray600),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  '${dateFormat.format(booking.checkIn)} - ${dateFormat.format(booking.checkOut)}',
                                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                        color: AppTheme.gray600,
                                      ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          // Price
                          Text(
                            priceFormat.format(booking.totalPrice),
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  color: AppTheme.primaryBlue,
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                // Pay Button (only for accepted and unpaid bookings)
                if (showPayButton) ...[
                  const SizedBox(height: 12),
                  AppButton(
                    text: 'Pay Now',
                    icon: Icons.payment,
                    onPressed: _isProcessing ? null : _handlePayment,
                    isLoading: _isProcessing,
                  ),
                ],
                // Paid Label
                if (booking.isPaid) ...[
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                    color: AppTheme.successGreen.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppTheme.successGreen),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.check_circle, color: AppTheme.successGreen, size: 20),
                        const SizedBox(width: 8),
                        Text(
                          'Paid',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: AppTheme.successGreen,
                                fontWeight: FontWeight.w600,
                              ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

