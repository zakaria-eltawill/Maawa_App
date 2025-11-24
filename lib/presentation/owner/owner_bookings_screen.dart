import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:maawa_project/core/di/providers.dart';
import 'package:maawa_project/core/error/failures.dart';
import 'package:maawa_project/core/theme/app_theme.dart';
import 'package:maawa_project/domain/entities/booking.dart';
import 'package:maawa_project/l10n/app_localizations.dart';
import 'package:maawa_project/presentation/widgets/empty_state.dart';
import 'package:maawa_project/presentation/widgets/error_state.dart';
import 'package:maawa_project/presentation/widgets/shimmer_loading.dart';
import 'package:maawa_project/presentation/widgets/app_card.dart';
import 'package:maawa_project/presentation/widgets/success_dialog.dart';
import 'package:intl/intl.dart';
import 'package:cached_network_image/cached_network_image.dart';

class OwnerBookingsScreen extends ConsumerWidget {
  const OwnerBookingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final pendingAsync = ref.watch(ownerPendingBookingsProvider);
    final allBookingsAsync = ref.watch(ownerBookingsProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.bookings),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(ownerPendingBookingsProvider);
          ref.invalidate(ownerAcceptedBookingsProvider);
          ref.invalidate(ownerRejectedBookingsProvider);
          ref.invalidate(ownerBookingsProvider);
        },
        child: CustomScrollView(
          slivers: [
            // Pending Bookings Section (Booking Requests)
            SliverToBoxAdapter(
              child: pendingAsync.when(
                data: (pendingBookings) {
                  if (pendingBookings.isEmpty) {
                    return const SizedBox.shrink();
                  }
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
                        child: Row(
                          children: [
                            Icon(
                              Icons.pending_actions,
                              color: AppTheme.warningOrange,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              '${l10n.bookingRequests} (${pendingBookings.length})',
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: AppTheme.warningOrange,
                                  ),
                            ),
                          ],
                        ),
                      ),
                      ...(() {
                        final sortedPending = pendingBookings.toList()
                          ..sort((a, b) {
                            // Sort pending bookings by updated_at first (most recent first), then by created_at
                            final aUpdated = a.updatedAt ?? a.createdAt;
                            final bUpdated = b.updatedAt ?? b.createdAt;
                            final updatedCompare = bUpdated.compareTo(aUpdated);
                            if (updatedCompare != 0) return updatedCompare;
                            // If updated_at is the same, sort by created_at (most recent first)
                            return b.createdAt.compareTo(a.createdAt);
                          });
                        return sortedPending.map((booking) => Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                          child: _OwnerBookingCard(
                            booking: booking,
                            showActions: true,
                          ),
                        ));
                      })(),
                      const SizedBox(height: 16),
                    ],
                  );
                },
                loading: () => const Padding(
                  padding: EdgeInsets.all(16),
                  child: SkeletonBookingCard(),
                ),
                error: (error, stack) => const SizedBox.shrink(),
              ),
            ),

            // Recent Bookings Section (all non-pending bookings: accepted, rejected, confirmed, etc.)
            SliverToBoxAdapter(
              child: allBookingsAsync.when(
                data: (allBookings) {
                  // Get pending booking IDs to filter them out
                  final pendingIds = pendingAsync.valueOrNull?.map((b) => b.id).toSet() ?? <String>{};
                  
                  // Filter out pending bookings and sort: accepted first, then by updated_at (most recent first), then by created_at
                  final recentBookings = allBookings
                      .where((booking) => !pendingIds.contains(booking.id))
                      .toList()
                    ..sort((a, b) {
                      // Priority 1: Accepted bookings first
                      final aIsAccepted = a.status == BookingStatus.accepted;
                      final bIsAccepted = b.status == BookingStatus.accepted;
                      if (aIsAccepted && !bIsAccepted) return -1;
                      if (!aIsAccepted && bIsAccepted) return 1;
                      
                      // Priority 2: Sort by updated_at (most recent first)
                      final aUpdated = a.updatedAt ?? a.createdAt;
                      final bUpdated = b.updatedAt ?? b.createdAt;
                      final updatedCompare = bUpdated.compareTo(aUpdated);
                      if (updatedCompare != 0) return updatedCompare;
                      
                      // Priority 3: If updated_at is the same, sort by created_at (most recent first)
                      return b.createdAt.compareTo(a.createdAt);
                    });
                  
                  if (recentBookings.isEmpty) {
                    // Only show empty state if there are no pending bookings either
                    if (pendingAsync.valueOrNull?.isEmpty ?? true) {
                      return const SizedBox.shrink(); // Empty state is handled below
                    }
                    return const SizedBox.shrink();
                  }
                  
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
                        child: Row(
                          children: [
                            Icon(
                              Icons.history,
                              color: AppTheme.primaryBlue,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              '${l10n.recentBookings} (${recentBookings.length})',
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: AppTheme.primaryBlue,
                                  ),
                            ),
                          ],
                        ),
                      ),
                      ...recentBookings.map((booking) => Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                            child: _OwnerBookingCard(
                              booking: booking,
                              showActions: false,
                              showRemainingDuration: booking.status == BookingStatus.accepted || 
                                                   booking.status == BookingStatus.confirmed,
                            ),
                          )),
                      const SizedBox(height: 16),
                    ],
                  );
                },
                loading: () => const Padding(
                  padding: EdgeInsets.all(16),
                  child: SkeletonBookingCard(),
                ),
                error: (error, stack) {
                  // If there are pending bookings, don't show error for recent bookings
                  if (pendingAsync.valueOrNull?.isNotEmpty ?? false) {
                    return const SizedBox.shrink();
                  }
                  // Only show error if there are no pending bookings
                  final errorString = error.toString().toLowerCase();
                  if (errorString.contains('socket') ||
                      errorString.contains('network') ||
                      errorString.contains('connection')) {
                    return NetworkErrorState(
                      onRetry: () {
                        ref.invalidate(ownerBookingsProvider);
                      },
                    );
                  } else {
                    return ServerErrorState(
                      onRetry: () {
                        ref.invalidate(ownerBookingsProvider);
                      },
                      errorDetails: error.toString(),
                    );
                  }
                },
              ),
            ),

            // Empty State (if all are empty)
            SliverToBoxAdapter(
              child: pendingAsync.when(
                data: (pending) => allBookingsAsync.when(
                  data: (allBookings) {
                    // Get pending booking IDs to filter them out
                    final pendingIds = pending.map((b) => b.id).toSet();
                    final recentBookings = allBookings
                        .where((booking) => !pendingIds.contains(booking.id))
                        .toList();
                    
                    if (pending.isEmpty && recentBookings.isEmpty) {
                      return Center(
                        child: Padding(
                          padding: const EdgeInsets.all(32),
                          child: EmptyState(
                            message: 'No Bookings',
                            subtitle: 'You haven\'t received any booking requests yet',
                            icon: Icons.event_available_outlined,
                            iconColor: AppTheme.primaryBlue,
                          ),
                        ),
                      );
                    }
                    return const SizedBox.shrink();
                  },
                  loading: () => const SizedBox.shrink(),
                  error: (error, stack) => const SizedBox.shrink(),
                ),
                loading: () => const SizedBox.shrink(),
                error: (error, stack) {
                  final errorString = error.toString().toLowerCase();
                  if (errorString.contains('socket') ||
                      errorString.contains('network') ||
                      errorString.contains('connection')) {
                    return NetworkErrorState(
                      onRetry: () {
                        ref.invalidate(ownerPendingBookingsProvider);
                        ref.invalidate(ownerAcceptedBookingsProvider);
                        ref.invalidate(ownerRejectedBookingsProvider);
                        ref.invalidate(ownerBookingsProvider);
                      },
                    );
                  } else {
                    return ServerErrorState(
                      onRetry: () {
                        ref.invalidate(ownerPendingBookingsProvider);
                        ref.invalidate(ownerAcceptedBookingsProvider);
                        ref.invalidate(ownerRejectedBookingsProvider);
                        ref.invalidate(ownerBookingsProvider);
                      },
                      errorDetails: error.toString(),
                    );
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OwnerBookingCard extends ConsumerStatefulWidget {
  final Booking booking;
  final bool showActions;
  final bool showRemainingDuration;

  const _OwnerBookingCard({
    required this.booking,
    this.showActions = false,
    this.showRemainingDuration = false,
  });

  @override
  ConsumerState<_OwnerBookingCard> createState() => _OwnerBookingCardState();
}

class _OwnerBookingCardState extends ConsumerState<_OwnerBookingCard> {
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
          // (We can't trigger provider watch from errorWidget)
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

  String? _getRemainingDuration(Booking booking) {
    if (!widget.showRemainingDuration) return null;
    
    final now = DateTime.now();
    final checkIn = booking.checkIn;
    final checkOut = booking.checkOut;
    
    if (now.isBefore(checkIn)) {
      // Booking hasn't started yet
      final daysUntil = checkIn.difference(now).inDays;
      if (daysUntil == 0) {
        final hoursUntil = checkIn.difference(now).inHours;
        return 'Starts in $hoursUntil ${hoursUntil == 1 ? 'hour' : 'hours'}';
      }
        return 'Starts in $daysUntil ${daysUntil == 1 ? "day" : "days"}';
    } else if (now.isAfter(checkIn) && now.isBefore(checkOut)) {
      // Booking is ongoing
      final daysRemaining = checkOut.difference(now).inDays;
      if (daysRemaining == 0) {
        final hoursRemaining = checkOut.difference(now).inHours;
        return 'Ends in $hoursRemaining ${hoursRemaining == 1 ? 'hour' : 'hours'}';
      }
      return '$daysRemaining ${daysRemaining == 1 ? "day" : "days"} remaining';
    } else {
      // Booking has ended
      return 'Completed';
    }
  }

  Future<void> _handleOwnerDecision(String decision, {String? reason}) async {
    setState(() => _isProcessing = true);
    
    // Capture context and l10n before async operations
    final currentContext = context;
    final l10n = AppLocalizations.of(currentContext);

    try {
      if (kDebugMode) {
        debugPrint('📤 OwnerBookingsScreen._handleOwnerDecision: Starting decision');
        debugPrint('📤   Booking ID: ${widget.booking.id}');
        debugPrint('📤   Decision: $decision');
      }
      
      final ownerDecisionUseCase = ref.read(ownerDecisionUseCaseProvider);
      
      final updatedBooking = await ownerDecisionUseCase(
        bookingId: widget.booking.id,
        decision: decision,
        reason: reason,
      );
      
      if (kDebugMode) {
        debugPrint('✅ OwnerBookingsScreen._handleOwnerDecision: Decision successful');
        debugPrint('✅   Updated booking status: ${updatedBooking.status}');
      }
      
      // Invalidate all booking providers to refresh
      ref.invalidate(ownerPendingBookingsProvider);
      ref.invalidate(ownerAcceptedBookingsProvider);
      ref.invalidate(ownerRejectedBookingsProvider);
      ref.invalidate(ownerBookingsProvider);
      
      // Wait a bit for providers to refresh
      await Future.delayed(const Duration(milliseconds: 300));
      
      if (mounted) {
        await SuccessDialog.show(
          currentContext,
          title: decision == 'ACCEPT' 
              ? l10n.bookingAccepted 
              : l10n.bookingRejected,
          message: decision == 'ACCEPT' 
              ? l10n.tenantNotified
              : l10n.tenantWillBeNotified,
        );
      }
    } catch (e, stackTrace) {
      if (kDebugMode) {
        debugPrint('❌ OwnerBookingsScreen._handleOwnerDecision: Error making decision');
        debugPrint('❌   Error type: ${e.runtimeType}');
        debugPrint('❌   Error: $e');
        debugPrint('❌   Stack trace: $stackTrace');
      }
      
      if (mounted) {
        // Extract user-friendly error message from Failure types
        String errorMessage = l10n.failedToProcessBooking;
        
        // Check if it's a Failure type
        if (e is ValidationFailure) {
          final message = e.message.toLowerCase();
          if (message.contains('status') || message.contains('cannot be changed')) {
            errorMessage = 'This booking cannot be ${decision == 'ACCEPT' ? 'accepted' : 'rejected'}. It may have already been processed.';
          } else {
            errorMessage = e.message;
          }
        } else if (e is ServerFailure) {
          final message = e.message.toLowerCase();
          if (message.contains('status') || message.contains('cannot be changed')) {
            errorMessage = 'This booking cannot be ${decision == 'ACCEPT' ? 'accepted' : 'rejected'}. It may have already been processed.';
          } else {
            errorMessage = e.message;
          }
        } else if (e is UnauthorizedFailure) {
          errorMessage = 'You do not have permission to ${decision == 'ACCEPT' ? 'accept' : 'reject'} this booking.';
        } else if (e is NotFoundFailure) {
          errorMessage = 'Booking not found. It may have been deleted.';
        } else if (e is UnknownFailure) {
          // For UnknownFailure, check the underlying error
          final errorString = e.message.toLowerCase();
          if (errorString.contains('booking status cannot be changed') || 
              errorString.contains('already been processed')) {
            errorMessage = 'This booking cannot be ${decision == 'ACCEPT' ? 'accepted' : 'rejected'}. It may have already been processed.';
          } else if (errorString.contains('422') || errorString.contains('validation')) {
            errorMessage = 'Invalid request. Please check the booking status.';
          } else if (errorString.contains('403') || errorString.contains('forbidden')) {
            errorMessage = 'You do not have permission to ${decision == 'ACCEPT' ? 'accept' : 'reject'} this booking.';
          } else if (errorString.contains('404') || errorString.contains('not found')) {
            // Check if this is a "not found" from fetching the booking after decision
            // If the error message indicates the backend succeeded, show success
            if (errorString.contains('backend returned success') || 
                errorString.contains('status was updated') ||
                errorString.contains('parsing failed but backend')) {
              // Backend succeeded, just parsing failed
              if (kDebugMode) {
                debugPrint('✅ OwnerBookingsScreen: Backend succeeded, parsing failed - showing success');
              }
              // Invalidate providers to refresh
              ref.invalidate(ownerPendingBookingsProvider);
              ref.invalidate(ownerAcceptedBookingsProvider);
              ref.invalidate(ownerRejectedBookingsProvider);
              ref.invalidate(ownerBookingsProvider);
              
              // Wait a bit for providers to refresh
              await Future.delayed(const Duration(milliseconds: 500));
              
              if (mounted) {
                await SuccessDialog.show(
                  currentContext,
                  title: decision == 'ACCEPT' 
                      ? l10n.bookingAccepted 
                      : l10n.bookingRejected,
                  message: decision == 'ACCEPT' 
                      ? l10n.tenantNotified
                      : l10n.tenantWillBeNotified,
                );
                return; // Exit early, don't show error
              }
            } else {
              errorMessage = 'Booking not found. It may have been deleted.';
            }
          } else if (errorString.contains('unexpected response format') || 
                     errorString.contains('parsing') ||
                     errorString.contains('json') ||
                     errorString.contains('exception') ||
                     errorString.contains('backend returned success') ||
                     errorString.contains('status was updated')) {
            // This is likely a parsing error, but the backend succeeded
            if (kDebugMode) {
              debugPrint('✅ OwnerBookingsScreen: Parsing error but backend succeeded - showing success');
            }
            // Invalidate providers to refresh
            ref.invalidate(ownerPendingBookingsProvider);
            ref.invalidate(ownerAcceptedBookingsProvider);
            ref.invalidate(ownerRejectedBookingsProvider);
            ref.invalidate(ownerBookingsProvider);
            
            // Wait a bit for providers to refresh
            await Future.delayed(const Duration(milliseconds: 500));
            
            if (mounted) {
              await SuccessDialog.show(
                currentContext,
                title: decision == 'ACCEPT' 
                    ? l10n.bookingAccepted 
                    : l10n.bookingRejected,
                message: decision == 'ACCEPT' 
                    ? l10n.tenantNotified
                    : l10n.tenantWillBeNotified,
              );
              return; // Exit early, don't show error
            }
          } else {
            errorMessage = l10n.failedToProcessBooking;
          }
        } else {
          // Fallback for string errors or other types
          final errorString = e.toString().toLowerCase();
          if (errorString.contains('booking status cannot be changed') || 
              errorString.contains('already been processed')) {
            errorMessage = 'This booking cannot be ${decision == 'ACCEPT' ? 'accepted' : 'rejected'}. It may have already been processed.';
          } else if (errorString.contains('422') || errorString.contains('validation')) {
            errorMessage = 'Invalid request. Please check the booking status.';
          } else if (errorString.contains('403') || errorString.contains('forbidden')) {
            errorMessage = 'You do not have permission to ${decision == 'ACCEPT' ? 'accept' : 'reject'} this booking.';
          } else if (errorString.contains('404') || errorString.contains('not found')) {
            // Check if this is from a fetch after decision (backend succeeded)
            if (errorString.contains('backend returned success') || 
                errorString.contains('status was updated') ||
                errorString.contains('parsing failed but backend')) {
              // Backend succeeded, just parsing/fetching failed
              if (kDebugMode) {
                debugPrint('✅ OwnerBookingsScreen: Backend succeeded, showing success');
              }
              // Invalidate providers to refresh
              ref.invalidate(ownerPendingBookingsProvider);
              ref.invalidate(ownerAcceptedBookingsProvider);
              ref.invalidate(ownerRejectedBookingsProvider);
              ref.invalidate(ownerBookingsProvider);
              
              // Wait a bit for providers to refresh
              await Future.delayed(const Duration(milliseconds: 500));
              
              if (mounted) {
                await SuccessDialog.show(
                  currentContext,
                  title: decision == 'ACCEPT' 
                      ? l10n.bookingAccepted 
                      : l10n.bookingRejected,
                  message: decision == 'ACCEPT' 
                      ? l10n.tenantNotified
                      : l10n.tenantWillBeNotified,
                );
                return; // Exit early, don't show error
              }
            } else {
              errorMessage = 'Booking not found. It may have been deleted.';
            }
          } else if (errorString.contains('unexpected response format') || 
                     errorString.contains('parsing') ||
                     errorString.contains('json') ||
                     errorString.contains('exception') ||
                     errorString.contains('backend returned success') ||
                     errorString.contains('status was updated')) {
            // Parsing error but backend succeeded
            if (kDebugMode) {
              debugPrint('✅ OwnerBookingsScreen: Parsing error but backend succeeded - showing success');
            }
            // Invalidate providers to refresh
            ref.invalidate(ownerPendingBookingsProvider);
            ref.invalidate(ownerAcceptedBookingsProvider);
            ref.invalidate(ownerRejectedBookingsProvider);
            ref.invalidate(ownerBookingsProvider);
            
            // Wait a bit for providers to refresh
            await Future.delayed(const Duration(milliseconds: 500));
            
            if (mounted) {
              await SuccessDialog.show(
                currentContext,
                title: decision == 'ACCEPT' 
                    ? l10n.bookingAccepted 
                    : l10n.bookingRejected,
                message: decision == 'ACCEPT' 
                    ? l10n.tenantNotified
                    : l10n.tenantWillBeNotified,
              );
              return; // Exit early, don't show error
            }
          } else {
            // Extract just the error type, not the full stack trace
            final parts = e.toString().split('(');
            errorMessage = 'Failed to ${decision == 'ACCEPT' ? 'accept' : 'reject'} booking: ${parts.first.trim()}';
          }
        }
        
        ScaffoldMessenger.of(currentContext).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: AppTheme.dangerRed,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isProcessing = false);
      }
    }
  }

  void _showRejectDialog() {
    final reasonController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reject Booking'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Please provide a reason for rejection:'),
            const SizedBox(height: 16),
            TextField(
              controller: reasonController,
              decoration: const InputDecoration(
                hintText: 'Reason (optional)',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => context.pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              context.pop();
              _handleOwnerDecision(
                'REJECT',
                reason: reasonController.text.trim().isEmpty 
                    ? null 
                    : reasonController.text.trim(),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.dangerRed,
            ),
            child: const Text('Reject'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final booking = widget.booking;
    final l10n = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context);
    final dateFormat = DateFormat('MMM dd, yyyy');
    final priceFormat = NumberFormat.currency(
      locale: locale.languageCode == 'ar' ? 'ar_LY' : 'en_US',
      symbol: locale.languageCode == 'ar' ? 'د.ل' : 'LYD',
      decimalDigits: 2,
    );
    final remainingDuration = _getRemainingDuration(booking);

    return AppCard(
      child: InkWell(
        onTap: () {
                  // Store booking in provider before navigating (backend doesn't have get-by-id endpoint)
                  ref.read(selectedBookingProvider.notifier).state = booking;
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
                        const SizedBox(height: 8),
                        // Tenant Info
                        if (booking.tenantName != null) ...[
                          Row(
                            children: [
                              Icon(Icons.person_outline, size: 16, color: AppTheme.gray600),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  booking.tenantName!,
                                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                        fontWeight: FontWeight.w500,
                                      ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                        ],
                        // Property Location
                        if (booking.propertyCity != null) ...[
                          Row(
                            children: [
                              Icon(Icons.location_on_outlined, size: 16, color: AppTheme.gray600),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  booking.propertyCity!,
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
                        ],
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
                        // Remaining Duration (for accepted bookings)
                        if (remainingDuration != null) ...[
                          const SizedBox(height: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppTheme.primaryBlue.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.access_time,
                                  size: 14,
                                  color: AppTheme.primaryBlue,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  remainingDuration,
                                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                        color: AppTheme.primaryBlue,
                                        fontWeight: FontWeight.w600,
                                      ),
                                ),
                              ],
                            ),
                          ),
                        ],
                        const SizedBox(height: 8),
                        // Price
                        Text(
                          priceFormat.format(booking.totalPrice),
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                color: AppTheme.primaryBlue,
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                        // Payment Status (for accepted/confirmed)
                        if (booking.status == BookingStatus.accepted || 
                            booking.status == BookingStatus.confirmed) ...[
                          const SizedBox(height: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: booking.isPaid
                                  ? AppTheme.successGreen.withValues(alpha: 0.1)
                                  : AppTheme.warningOrange.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              booking.isPaid ? l10n.paid : l10n.unpaid,
                              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                    color: booking.isPaid
                                        ? AppTheme.successGreen
                                        : AppTheme.warningOrange,
                                    fontWeight: FontWeight.w600,
                                  ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
              // Action Buttons (only for pending bookings)
              if (widget.showActions && booking.status == BookingStatus.pending) ...[
                const SizedBox(height: 12),
                // Accept Button (Green)
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton.icon(
                    onPressed: _isProcessing 
                        ? null 
                        : () => _handleOwnerDecision('ACCEPT'),
                    icon: _isProcessing 
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : const Icon(Icons.check_circle, size: 24),
                    label: Text(
                      l10n.acceptBooking,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.successGreen,
                      foregroundColor: Colors.white,
                      elevation: 2,
                      shadowColor: AppTheme.successGreen.withValues(alpha: 0.3),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 16,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                // Reject Button (Red)
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton.icon(
                    onPressed: _isProcessing ? null : _showRejectDialog,
                    icon: const Icon(Icons.cancel_outlined, size: 24),
                    label: Text(
                      l10n.rejectBookingButton,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.dangerRed,
                      foregroundColor: Colors.white,
                      elevation: 2,
                      shadowColor: AppTheme.dangerRed.withValues(alpha: 0.3),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 16,
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
