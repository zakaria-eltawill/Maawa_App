import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:maawa_project/core/di/providers.dart';
import 'package:maawa_project/core/theme/app_theme.dart';
import 'package:maawa_project/domain/entities/booking.dart';
import 'package:maawa_project/domain/entities/property.dart';
import 'package:maawa_project/domain/entities/user.dart';
import 'package:maawa_project/presentation/widgets/app_button.dart';
import 'package:maawa_project/presentation/widgets/app_card.dart';
import 'package:maawa_project/presentation/widgets/success_dialog.dart';
import 'package:maawa_project/l10n/app_localizations.dart';
import 'package:intl/intl.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:url_launcher/url_launcher.dart';

class BookingDetailScreen extends ConsumerWidget {
  final String bookingId;

  const BookingDetailScreen({
    super.key,
    required this.bookingId,
  });

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
  Widget build(BuildContext context, WidgetRef ref) {
    // Use getBookingById which works for both roles
    final bookingAsync = ref.watch(bookingDetailProvider(bookingId));
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.bookingDetails),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              ref.invalidate(bookingDetailProvider(bookingId));
              ref.invalidate(propertyDetailProvider);
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(bookingDetailProvider(bookingId));
          // Also refresh property detail if needed
          final booking = bookingAsync.valueOrNull;
          if (booking != null) {
            ref.invalidate(propertyDetailProvider(booking.propertyId));
          }
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: bookingAsync.when(
            data: (booking) {
          // Always fetch property details for owners to show complete information
          final propertyAsync = ref.watch(propertyDetailProvider(booking.propertyId));
          
          return propertyAsync.when(
            data: (property) {
              // Create enriched booking with property data
              final enrichedBooking = Booking(
                id: booking.id,
                propertyId: booking.propertyId,
                propertyName: booking.propertyName ?? property.name,
                propertyType: booking.propertyType ?? property.propertyType,
                propertyCity: booking.propertyCity ?? property.city,
                propertyThumbnail: property.imageUrls.isNotEmpty 
                    ? property.imageUrls.first 
                    : booking.propertyThumbnail,
                tenantId: booking.tenantId,
                tenantName: booking.tenantName,
                tenantEmail: booking.tenantEmail,
                tenantPhone: booking.tenantPhone,
                tenantRegion: booking.tenantRegion,
                ownerName: booking.ownerName ?? property.ownerName,
                ownerPhone: booking.ownerPhone ?? property.ownerPhone,
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
              
              return _BookingDetailContent(
                booking: enrichedBooking,
                property: property,
                getStatusColor: _getStatusColor,
                getStatusLabel: _getStatusLabel,
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, stack) {
              // If property fetch fails, show booking without property details
              return _BookingDetailContent(
                booking: booking,
                property: null,
                getStatusColor: _getStatusColor,
                getStatusLabel: _getStatusLabel,
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) {
          if (kDebugMode) {
            debugPrint('❌ Booking detail fetch error: $error');
            debugPrint('📋 Stack trace: $stack');
          }
          
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 64, color: AppTheme.dangerRed),
                  const SizedBox(height: 16),
                  Text(
                    l10n.failedToLoadBookingDetails,
                    style: Theme.of(context).textTheme.titleLarge,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    error.toString().contains('404') || error.toString().contains('NotFound')
                        ? l10n.bookingNotFound
                        : error.toString(),
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppTheme.gray600,
                        ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  AppButton(
                    text: l10n.goBack,
                    onPressed: () => context.pop(),
                  ),
                ],
              ),
            ),
          );
        },
          ),
        ),
      ),
    );
  }
}

class _BookingDetailContent extends ConsumerStatefulWidget {
  final Booking booking;
  final Property? property;
  final Color Function(BookingStatus) getStatusColor;
  final String Function(BookingStatus) getStatusLabel;

  const _BookingDetailContent({
    required this.booking,
    this.property,
    required this.getStatusColor,
    required this.getStatusLabel,
  });

  @override
  ConsumerState<_BookingDetailContent> createState() =>
      _BookingDetailContentState();
}

class _BookingDetailContentState extends ConsumerState<_BookingDetailContent> {
  bool _isProcessing = false;
  UserRole? _userRole;

  @override
  void initState() {
    super.initState();
    _loadUserRole();
  }

  Future<void> _loadUserRole() async {
    final secureStorage = ref.read(secureStorageProvider);
    final roleString = await secureStorage.getUserRole();
    if (roleString != null) {
      setState(() {
        _userRole = UserRole.fromString(roleString);
      });
    }
  }

  Future<void> _handleOwnerDecision(String decision, {String? reason}) async {
    setState(() => _isProcessing = true);

    try {
      final ownerDecisionUseCase = ref.read(ownerDecisionUseCaseProvider);
      
      await ownerDecisionUseCase(
        bookingId: widget.booking.id,
        decision: decision,
        reason: reason,
      );
      
      // Invalidate bookings lists to refresh
      ref.invalidate(bookingsProvider);
      ref.invalidate(ownerBookingsProvider);
      ref.invalidate(bookingDetailProvider(widget.booking.id));
      
      if (mounted) {
        // Show success animation
        final l10n = AppLocalizations.of(context);
        await SuccessDialog.show(
          context,
          title: decision == 'ACCEPT' ? l10n.bookingAccepted : l10n.bookingRejected,
          message: decision == 'ACCEPT' 
              ? l10n.tenantNotified
              : l10n.tenantWillBeNotified,
        );
        
        if (mounted) {
          context.pop();
        }
      }
    } catch (e) {
      if (mounted) {
        final l10n = AppLocalizations.of(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${l10n.failedToProcessBooking}: ${e.toString()}'),
            backgroundColor: AppTheme.dangerRed,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isProcessing = false);
      }
    }
  }

  Future<void> _handlePayment() async {
    setState(() => _isProcessing = true);

    try {
      final processMockPaymentUseCase = ref.read(processMockPaymentUseCaseProvider);
      
      await processMockPaymentUseCase(
        bookingId: widget.booking.id,
        fail: false, // Set to true to test payment failure
      );
      
      // Invalidate bookings lists to refresh
      ref.invalidate(bookingsProvider);
      ref.invalidate(bookingDetailProvider(widget.booking.id));
      
      if (mounted) {
        // Show success animation
        final l10n = AppLocalizations.of(context);
        await SuccessDialog.show(
          context,
          title: l10n.paymentSuccessful,
          message: l10n.bookingConfirmedMessage,
        );
        
        if (mounted) {
          context.pop();
        }
      }
    } catch (e) {
      if (mounted) {
        final l10n = AppLocalizations.of(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${l10n.paymentFailed}: ${e.toString()}'),
            backgroundColor: AppTheme.dangerRed,
            duration: const Duration(seconds: 4),
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
    final l10n = AppLocalizations.of(context);
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.rejectBooking),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(l10n.provideRejectionReason),
            const SizedBox(height: AppTheme.spacingMD),
            TextField(
              controller: reasonController,
              decoration: InputDecoration(
                hintText: l10n.reasonOptional,
                border: const OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => context.pop(),
            child: Text(l10n.cancel),
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
            child: Text(l10n.reject),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final booking = widget.booking;
    final getStatusColor = widget.getStatusColor;
    final getStatusLabel = widget.getStatusLabel;
    final l10n = AppLocalizations.of(context);
    
    final dateFormat = DateFormat('MMM dd, yyyy');
    final priceFormat = NumberFormat.currency(
      locale: 'ar_LY',
      symbol: 'د.ل',
      decimalDigits: 2,
    );

    final nights = booking.checkOut.difference(booking.checkIn).inDays;

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Property Image - Use property images if available, otherwise use booking thumbnail
          Builder(
            builder: (context) {
              // Priority: property images > booking thumbnail > placeholder
              String? imageUrl;
              if (widget.property != null && widget.property!.imageUrls.isNotEmpty) {
                imageUrl = widget.property!.imageUrls.first;
                if (kDebugMode) {
                  debugPrint('🖼️ Using property image: $imageUrl');
                }
              } else if (booking.propertyThumbnail != null && booking.propertyThumbnail!.isNotEmpty) {
                imageUrl = booking.propertyThumbnail!;
                if (kDebugMode) {
                  debugPrint('🖼️ Using booking thumbnail: $imageUrl');
                }
              } else {
                if (kDebugMode) {
                  debugPrint('⚠️ No image available, showing placeholder');
                }
              }
              
              if (imageUrl != null && imageUrl.isNotEmpty) {
                return CachedNetworkImage(
                  imageUrl: imageUrl,
                  height: 250,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => Container(
                    height: 250,
                    color: AppTheme.gray200,
                    child: const Center(child: CircularProgressIndicator()),
                  ),
                  errorWidget: (context, url, error) {
                    if (kDebugMode) {
                      debugPrint('❌ Image load error for URL: $url');
                      debugPrint('❌ Error: $error');
                    }
                    return _buildPlaceholderImage();
                  },
                );
              }
              
              return _buildPlaceholderImage();
            },
          ),

          Padding(
            padding: const EdgeInsets.all(AppTheme.spacingLG),
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
                            booking.propertyName ?? widget.property?.name ?? 'Property',
                            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                          if (booking.propertyType != null || widget.property != null) ...[
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                Icon(Icons.category_outlined, size: 16, color: AppTheme.gray600),
                                const SizedBox(width: 4),
                                Text(
                                  booking.propertyType ?? widget.property?.propertyType ?? '',
                                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                        color: AppTheme.gray600,
                                      ),
                                ),
                              ],
                            ),
                          ],
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppTheme.spacingMD,
                        vertical: AppTheme.spacingSM,
                      ),
                      decoration: BoxDecoration(
                        color: getStatusColor(booking.status).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(AppTheme.radiusSM),
                      ),
                      child: Text(
                        getStatusLabel(booking.status),
                        style: Theme.of(context).textTheme.labelLarge?.copyWith(
                              color: getStatusColor(booking.status),
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                    ),
                  ],
                ),
                if (booking.propertyCity != null || widget.property?.city != null) ...[
                  const SizedBox(height: AppTheme.spacingXS),
                  Row(
                    children: [
                      Icon(Icons.location_on, size: 16, color: AppTheme.gray600),
                      const SizedBox(width: AppTheme.spacingXS),
                      Expanded(
                        child: Text(
                          booking.propertyCity ?? widget.property?.city ?? '',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: AppTheme.gray600,
                              ),
                        ),
                      ),
                    ],
                  ),
                ],
                if (widget.property?.address != null && widget.property!.address!.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.place_outlined, size: 14, color: AppTheme.gray500),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          widget.property!.address!,
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: AppTheme.gray500,
                              ),
                        ),
                      ),
                    ],
                  ),
                ],
                const SizedBox(height: AppTheme.spacingLG),

                // Property Details Section (if property data available)
                if (widget.property != null) ...[
                  AppCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.home_outlined, color: AppTheme.primaryBlue, size: 24),
                            const SizedBox(width: 8),
                            Text(
                              l10n.propertyDetails,
                              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                            ),
                          ],
                        ),
                        const SizedBox(height: AppTheme.spacingLG),
                        if (widget.property!.description != null && widget.property!.description!.isNotEmpty) ...[
                          Text(
                            l10n.description,
                            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: AppTheme.gray700,
                                ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            widget.property!.description!,
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: AppTheme.gray600,
                                  height: 1.5,
                                ),
                          ),
                          const SizedBox(height: AppTheme.spacingMD),
                        ],
                        _InfoRow(
                          icon: Icons.attach_money_outlined,
                          label: l10n.pricePerNight,
                          value: priceFormat.format(widget.property!.pricePerNight),
                          valueStyle: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                color: AppTheme.primaryBlue,
                                fontWeight: FontWeight.w600,
                              ),
                        ),
                        if (widget.property!.amenities.isNotEmpty) ...[
                          const SizedBox(height: AppTheme.spacingMD),
                          Text(
                            l10n.amenities,
                            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: AppTheme.gray700,
                                ),
                          ),
                          const SizedBox(height: 8),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: [
                              for (final amenity in widget.property!.amenities)
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppTheme.gray50,
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(color: AppTheme.gray200),
                                  ),
                                  child: Text(
                                    amenity,
                                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                          color: AppTheme.gray700,
                                        ),
                                  ),
                                ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: AppTheme.spacingMD),
                ],

                // Booking Information Card
                AppCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.bookingInformation,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                      const SizedBox(height: AppTheme.spacingLG),
                      _InfoRow(
                        icon: Icons.calendar_today_outlined,
                        label: l10n.checkIn,
                        value: dateFormat.format(booking.checkIn),
                      ),
                      const SizedBox(height: AppTheme.spacingMD),
                      _InfoRow(
                        icon: Icons.calendar_today_outlined,
                        label: l10n.checkOut,
                        value: dateFormat.format(booking.checkOut),
                      ),
                      const SizedBox(height: AppTheme.spacingMD),
                      _InfoRow(
                        icon: Icons.nights_stay_outlined,
                        label: l10n.nights,
                        value: nights == 1 ? '$nights ${l10n.night}' : '$nights ${l10n.nightsPlural}',
                      ),
                      if (booking.guests != null) ...[
                        const SizedBox(height: AppTheme.spacingMD),
                        _InfoRow(
                          icon: Icons.people_outline,
                          label: l10n.guests,
                          value: '${booking.guests}',
                        ),
                      ],
                      const Divider(height: AppTheme.spacingLG * 2),
                      _InfoRow(
                        icon: Icons.attach_money,
                        label: l10n.totalPrice,
                        value: priceFormat.format(booking.totalPrice),
                        valueStyle: Theme.of(context).textTheme.titleLarge?.copyWith(
                              color: AppTheme.primaryBlue,
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      if (booking.status == BookingStatus.accepted || 
                          booking.status == BookingStatus.confirmed) ...[
                        const SizedBox(height: AppTheme.spacingMD),
                        Row(
                          children: [
                            Icon(
                              booking.isPaid ? Icons.check_circle : Icons.pending_outlined,
                              size: 20,
                              color: booking.isPaid 
                                  ? AppTheme.successGreen 
                                  : AppTheme.warningOrange,
                            ),
                            const SizedBox(width: AppTheme.spacingMD),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    l10n.paymentStatus,
                                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                          color: AppTheme.gray600,
                                        ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    booking.isPaid ? l10n.paid : l10n.unpaid,
                                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                          color: booking.isPaid 
                                              ? AppTheme.successGreen 
                                              : AppTheme.warningOrange,
                                          fontWeight: FontWeight.w600,
                                        ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                      const SizedBox(height: AppTheme.spacingXS),
                      _InfoRow(
                        icon: Icons.access_time,
                        label: l10n.bookingCreated,
                        value: dateFormat.format(booking.createdAt),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppTheme.spacingMD),

                // Tenant Information (for owners only)
                if (_userRole == UserRole.owner &&
                    (booking.tenantName != null ||
                        booking.tenantEmail != null ||
                        booking.tenantPhone != null)) ...[
                  AppCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.person_outlined, color: AppTheme.primaryBlue, size: 24),
                            const SizedBox(width: 8),
                            Text(
                              l10n.tenantInformation,
                              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                            ),
                          ],
                        ),
                        const SizedBox(height: AppTheme.spacingLG),
                        if (booking.tenantName != null)
                          _InfoRow(
                            icon: Icons.person_outline,
                            label: l10n.fullName,
                            value: booking.tenantName!,
                            valueStyle: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                          ),
                        if (booking.tenantEmail != null) ...[
                          const SizedBox(height: AppTheme.spacingMD),
                          _InfoRow(
                            icon: Icons.email_outlined,
                            label: l10n.emailAddress,
                            value: booking.tenantEmail!,
                          ),
                        ],
                        if (booking.tenantPhone != null) ...[
                          const SizedBox(height: AppTheme.spacingMD),
                          _InfoRow(
                            icon: Icons.phone_outlined,
                            label: l10n.phoneNumber,
                            value: booking.tenantPhone!,
                          ),
                          const SizedBox(height: AppTheme.spacingMD),
                          OutlinedButton.icon(
                            onPressed: () async {
                              final phoneNumber = booking.tenantPhone!;
                              final uri = Uri.parse('tel:$phoneNumber');
                              final messenger = ScaffoldMessenger.of(context);
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
                            icon: const Icon(Icons.phone),
                            label: Text(l10n.contactTenant),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(
                                horizontal: AppTheme.spacingLG,
                                vertical: AppTheme.spacingMD,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: AppTheme.spacingMD),
                ],

                // Owner Information (for tenants only)
                if (_userRole == UserRole.tenant && 
                    (booking.ownerName != null || booking.ownerPhone != null ||
                     (widget.property != null && (widget.property!.ownerName != null || widget.property!.ownerPhone != null)))) ...[
                  AppCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.person_outlined, color: AppTheme.primaryBlue, size: 24),
                            const SizedBox(width: 8),
                            Text(
                              l10n.ownerInfo,
                              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                            ),
                          ],
                        ),
                        const SizedBox(height: AppTheme.spacingLG),
                        if (booking.ownerName != null || (widget.property != null && widget.property!.ownerName != null))
                          _InfoRow(
                            icon: Icons.person_outline,
                            label: l10n.fullName,
                            value: booking.ownerName ?? widget.property?.ownerName ?? '',
                            valueStyle: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                          ),
                        if (booking.ownerPhone != null || (widget.property != null && widget.property!.ownerPhone != null)) ...[
                          if (booking.ownerName != null || (widget.property != null && widget.property!.ownerName != null))
                            const SizedBox(height: AppTheme.spacingMD),
                          _InfoRow(
                            icon: Icons.phone_outlined,
                            label: l10n.phoneNumber,
                            value: booking.ownerPhone ?? widget.property?.ownerPhone ?? '',
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: AppTheme.spacingMD),
                ],

                // Booking Timeline (if available)
                if (booking.timeline.isNotEmpty) ...[
                  AppCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.timeline_outlined, color: AppTheme.primaryBlue, size: 24),
                            const SizedBox(width: 8),
                            Text(
                              l10n.bookingTimeline,
                              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                            ),
                          ],
                        ),
                        const SizedBox(height: AppTheme.spacingLG),
                        ...booking.timeline.asMap().entries.map((entry) {
                          final index = entry.key;
                          final event = entry.value;
                          final isLast = index == booking.timeline.length - 1;
                          
                          return Column(
                            children: [
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    width: 24,
                                    height: 24,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: getStatusColor(event.status).withValues(alpha: 0.1),
                                      border: Border.all(
                                        color: getStatusColor(event.status),
                                        width: 2,
                                      ),
                                    ),
                                    child: Icon(
                                      _getTimelineIcon(event.status),
                                      size: 12,
                                      color: getStatusColor(event.status),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          getStatusLabel(event.status),
                                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                                fontWeight: FontWeight.w600,
                                                color: getStatusColor(event.status),
                                              ),
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          DateFormat('MMM dd, yyyy • hh:mm a').format(event.timestamp),
                                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                                color: AppTheme.gray500,
                                              ),
                                        ),
                                        if (event.note != null && event.note!.isNotEmpty) ...[
                                          const SizedBox(height: 4),
                                          Text(
                                            event.note!,
                                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                                  color: AppTheme.gray600,
                                                  fontStyle: FontStyle.italic,
                                                ),
                                          ),
                                        ],
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              if (!isLast) ...[
                                const SizedBox(height: 12),
                                Container(
                                  margin: const EdgeInsets.only(left: 11),
                                  width: 2,
                                  height: 20,
                                  color: AppTheme.gray300,
                                ),
                                const SizedBox(height: 12),
                              ],
                            ],
                          );
                        }),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppTheme.spacingMD),
                ],

                // Rejection Reason (if rejected)
                if (booking.status == BookingStatus.rejected && booking.rejectionReason != null) ...[
                  AppCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.info_outline, color: AppTheme.dangerRed, size: 20),
                            const SizedBox(width: 8),
                            Text(
                              l10n.rejectionReason,
                              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                    fontWeight: FontWeight.w600,
                                    color: AppTheme.dangerRed,
                                  ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          booking.rejectionReason!,
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: AppTheme.gray700,
                              ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppTheme.spacingMD),
                ],

                // Action Buttons (for owners only)
                if (_userRole == UserRole.owner && booking.status == BookingStatus.pending) ...[
                  AppButton(
                    text: l10n.acceptBooking,
                    onPressed: _isProcessing 
                        ? null 
                        : () => _handleOwnerDecision('ACCEPT'),
                    isLoading: _isProcessing,
                  ),
                  const SizedBox(height: AppTheme.spacingSM),
                  AppButton(
                    text: l10n.rejectBookingButton,
                    isOutlined: true,
                    onPressed: _isProcessing ? null : _showRejectDialog,
                  ),
                ],
                
                // Payment Button (for tenants only: status == accepted AND isPaid == false)
                if (_userRole == UserRole.tenant && 
                    booking.status == BookingStatus.accepted && 
                    !booking.isPaid) ...[
                  Container(
                    padding: const EdgeInsets.all(AppTheme.spacingMD),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryBlue.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(AppTheme.radiusMD),
                      border: Border.all(color: AppTheme.primaryBlue),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.info_outline, color: AppTheme.primaryBlue),
                        const SizedBox(width: AppTheme.spacingMD),
                        Expanded(
                          child: Text(
                            l10n.bookingAcceptedCompletePayment,
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppTheme.spacingMD),
                  AppButton(
                    text: l10n.payNow,
                    icon: Icons.payment,
                    onPressed: _isProcessing ? null : _handlePayment,
                    isLoading: _isProcessing,
                  ),
                ],
                
                // Paid Label (for tenants)
                if (_userRole == UserRole.tenant && booking.isPaid) ...[
                  Container(
                    padding: const EdgeInsets.all(AppTheme.spacingMD),
                    decoration: BoxDecoration(
                      color: AppTheme.successGreen.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(AppTheme.radiusMD),
                      border: Border.all(color: AppTheme.successGreen),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.check_circle, color: AppTheme.successGreen),
                        const SizedBox(width: AppTheme.spacingMD),
                        Expanded(
                          child: Text(
                            l10n.paymentCompleted,
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: AppTheme.successGreen,
                                  fontWeight: FontWeight.w600,
                                ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                const SizedBox(height: AppTheme.spacingLG),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlaceholderImage() {
    return Container(
      height: 250,
      color: AppTheme.gray200,
      child: Center(
        child: Icon(
          Icons.home_outlined,
          size: 64,
          color: AppTheme.gray500,
        ),
      ),
    );
  }

  IconData _getTimelineIcon(BookingStatus status) {
    switch (status) {
      case BookingStatus.pending:
        return Icons.pending_outlined;
      case BookingStatus.accepted:
        return Icons.check_circle_outline;
      case BookingStatus.confirmed:
        return Icons.verified_outlined;
      case BookingStatus.completed:
        return Icons.done_all_outlined;
      case BookingStatus.rejected:
        return Icons.cancel_outlined;
      case BookingStatus.canceled:
        return Icons.close_outlined;
      case BookingStatus.expired:
        return Icons.schedule_outlined;
    }
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final TextStyle? valueStyle;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
    this.valueStyle,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 20, color: AppTheme.gray600),
        const SizedBox(width: AppTheme.spacingMD),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppTheme.gray600,
                    ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: valueStyle ??
                    Theme.of(context).textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.w500,
                        ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

