import 'package:flutter/foundation.dart';
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
import 'package:maawa_project/presentation/widgets/rating_review_dialog.dart';
import 'package:maawa_project/presentation/widgets/network_image_with_timeout.dart';
import 'package:intl/intl.dart';

class TenantBookingsScreen extends ConsumerStatefulWidget {
  const TenantBookingsScreen({super.key});

  @override
  ConsumerState<TenantBookingsScreen> createState() => _TenantBookingsScreenState();
}

class _TenantBookingsScreenState extends ConsumerState<TenantBookingsScreen> {
  @override
  void initState() {
    super.initState();
    // Check for completed bookings after the first frame
    // This will also run when user navigates to this tab (data is refreshed automatically via role_based_shell)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkForCompletedBookings();
    });
  }

  /// Check for completed bookings and show review dialog
  /// Note: Backend automatically updates booking status from CONFIRMED/ACCEPTED to COMPLETED
  /// daily at midnight when check_out date has passed. The frontend will see the updated
  /// status on the next data fetch (tab navigation, pull-to-refresh, etc.)
  Future<void> _checkForCompletedBookings() async {
    final bookingsAsync = ref.read(bookingsProvider);
    await bookingsAsync.when(
      data: (bookings) async {
        if (kDebugMode) {
          debugPrint('🔍 Checking ${bookings.length} bookings for completed status...');
          for (final booking in bookings) {
            final now = DateTime.now();
            final checkOutDate = DateTime(booking.checkOut.year, booking.checkOut.month, booking.checkOut.day);
            final today = DateTime(now.year, now.month, now.day);
            final isCheckOutPassed = today.isAfter(checkOutDate);
            debugPrint('📋 Booking ${booking.id}:');
            debugPrint('   Status: ${booking.status}');
            debugPrint('   Check-out: ${booking.checkOut}');
            debugPrint('   Today: $today');
            debugPrint('   Check-out passed: $isCheckOutPassed');
            debugPrint('   Should be completed: ${booking.shouldBeCompleted}');
          }
        }
        
        // Find the first completed booking that hasn't been reviewed
        // Backend automatically updates status to "completed" when check_out date passes
        for (final booking in bookings) {
          if (booking.status == BookingStatus.completed && booking.propertyName != null) {
            final hasBeenReviewed = await hasBookingBeenReviewed(booking.id);
            if (!hasBeenReviewed && mounted) {
              if (kDebugMode) {
                debugPrint('✅ Found completed booking: ${booking.id}, showing review dialog');
              }
              // Show dialog for this booking
              await RatingReviewDialog.show(
                context,
                propertyId: booking.propertyId,
                bookingId: booking.id,
                propertyName: booking.propertyName!,
              );
              // Only show one dialog at a time
              break;
            }
          }
        }
      },
      loading: () {},
      error: (_, __) {},
    );
  }

  @override
  Widget build(BuildContext context) {
    final bookingsAsync = ref.watch(bookingsProvider);
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.myBookings),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          if (kDebugMode) {
            debugPrint('🔄 Refreshing bookings data...');
          }
          // Force refresh by invalidating the provider
          ref.invalidate(bookingsProvider);
          // Wait for data to refresh, then check for completed bookings
          // Backend automatically updates status to "completed" daily at midnight, so refresh will fetch updated status
          // Note: If the scheduled task hasn't run yet, the status may still show as CONFIRMED/ACCEPTED
          await Future.delayed(const Duration(milliseconds: 1000));
          if (mounted) {
            _checkForCompletedBookings();
          }
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

  String _getStatusLabel(BookingStatus status, BuildContext context) {
    final l10n = AppLocalizations.of(context);
    switch (status) {
      case BookingStatus.pending:
        return l10n.statusPending;
      case BookingStatus.accepted:
        return l10n.statusAccepted;
      case BookingStatus.confirmed:
        return l10n.statusConfirmed;
      case BookingStatus.completed:
        return l10n.statusCompleted;
      case BookingStatus.rejected:
        return l10n.statusRejected;
      case BookingStatus.canceled:
        return l10n.statusCanceled;
      case BookingStatus.expired:
        return l10n.statusExpired;
    }
  }

  Widget _buildPropertyImage(Booking booking) {
    // If booking has thumbnail, try to use it first
    if (booking.propertyThumbnail != null && 
        booking.propertyThumbnail!.isNotEmpty) {
      final thumbnailUrl = booking.propertyThumbnail!;
      
      // Validate URL format
      if (thumbnailUrl.isEmpty || 
          (!thumbnailUrl.startsWith('http://') && !thumbnailUrl.startsWith('https://'))) {
        if (kDebugMode) {
          debugPrint('⚠️ Invalid thumbnail URL: $thumbnailUrl');
        }
        return _buildPropertyImageFallback(booking.propertyId);
      }

      return NetworkImageWithTimeout(
        imageUrl: thumbnailUrl,
        width: 80,
        height: 80,
        fit: BoxFit.cover,
        timeout: const Duration(seconds: 8),
        errorWidget: _buildPropertyImageFallback(booking.propertyId),
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
          final imageUrl = property.imageUrls.first;
          
          // Validate URL format
          if (imageUrl.isEmpty || 
              (!imageUrl.startsWith('http://') && !imageUrl.startsWith('https://'))) {
            if (kDebugMode) {
              debugPrint('⚠️ Invalid property image URL: $imageUrl');
            }
            return _buildPlaceholder();
          }

          return NetworkImageWithTimeout(
            imageUrl: imageUrl,
            width: 80,
            height: 80,
            fit: BoxFit.cover,
            timeout: const Duration(seconds: 8),
            errorWidget: _buildPlaceholder(),
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
    final l10n = AppLocalizations.of(context);
    final dateFormat = DateFormat('MMM dd, yyyy');
    final locale = Localizations.localeOf(context);
    final priceFormat = NumberFormat.currency(
      locale: locale.languageCode == 'ar' ? 'ar_LY' : 'en_US',
      symbol: locale.languageCode == 'ar' ? 'د.ل' : 'LYD',
      decimalDigits: 2,
    );

    // Show Pay button only if: status == accepted AND isPaid == false
    final showPayButton = booking.status == BookingStatus.accepted && !booking.isPaid;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: AppCard(
        child: InkWell(
          onTap: () {
            // Store booking in provider as fallback before navigating
            ref.read(selectedBookingProvider.notifier).state = booking;
            // Navigate to booking detail - provider will use list booking first, then refresh from API
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
                                _getStatusLabel(booking.status, context),
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
                    text: AppLocalizations.of(context).payNow,
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
                          l10n.paid,
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
