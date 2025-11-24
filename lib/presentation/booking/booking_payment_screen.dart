import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:maawa_project/core/di/providers.dart';
import 'package:maawa_project/core/error/failures.dart';
import 'package:maawa_project/core/theme/app_theme.dart';
import 'package:maawa_project/presentation/widgets/app_button.dart';
import 'package:maawa_project/presentation/widgets/app_card.dart';
import 'package:maawa_project/presentation/widgets/success_dialog.dart';
import 'package:maawa_project/l10n/app_localizations.dart';
import 'package:intl/intl.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:maawa_project/core/config/app_config.dart';
import 'package:maawa_project/domain/entities/booking.dart';

enum PaymentMethod {
  edfaaly,
  mobiCash,
}

class BookingPaymentScreen extends ConsumerStatefulWidget {
  final String bookingId;

  const BookingPaymentScreen({
    super.key,
    required this.bookingId,
  });

  @override
  ConsumerState<BookingPaymentScreen> createState() => _BookingPaymentScreenState();
}

class _BookingPaymentScreenState extends ConsumerState<BookingPaymentScreen> {
  PaymentMethod? _selectedPaymentMethod;
  final _phoneNumberController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  @override
  void dispose() {
    _phoneNumberController.dispose();
    super.dispose();
  }

  int _calculateNumberOfNights(DateTime checkIn, DateTime checkOut) {
    return checkOut.difference(checkIn).inDays;
  }

  double _calculateTotal(double pricePerNight, int nights) {
    return pricePerNight * nights;
  }

  Future<void> _processPayment() async {
    // Capture context and l10n before async operations
    final currentContext = context;
    final l10n = AppLocalizations.of(currentContext);
    
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedPaymentMethod == null) {
      if (mounted) {
        ScaffoldMessenger.of(currentContext).showSnackBar(
          SnackBar(
            content: Text(l10n.selectPaymentMethod),
            backgroundColor: AppTheme.dangerRed,
          ),
        );
      }
      return;
    }

    // Get fresh booking data to verify status before payment
    // Force a refresh to ensure we have the latest status from API
    ref.invalidate(bookingDetailProvider(widget.bookingId));
    
    // Wait a moment for the refresh to complete, then check status
    await Future.delayed(const Duration(milliseconds: 300));
    
    // Try to get current booking status
    final bookingAsync = ref.read(bookingDetailProvider(widget.bookingId));
    bool shouldProceed = true;
    
    bookingAsync.whenOrNull(
      data: (booking) {
        if (kDebugMode) {
          debugPrint('💳 PaymentScreen: Booking status check - Status: ${booking.status}, IsPaid: ${booking.isPaid}');
        }
        
        // Verify booking is in a valid status for payment (ACCEPTED or CONFIRMED)
        if (booking.status != BookingStatus.accepted && 
            booking.status != BookingStatus.confirmed) {
          shouldProceed = false;
          if (mounted) {
            ScaffoldMessenger.of(currentContext).showSnackBar(
              SnackBar(
                content: Text(
                  booking.status == BookingStatus.pending
                      ? 'Booking is still pending owner approval. Please wait for owner to accept.'
                      : 'This booking cannot be paid in its current status (${booking.status}).',
                ),
                backgroundColor: AppTheme.dangerRed,
                duration: const Duration(seconds: 4),
              ),
            );
          }
        }
      },
    );
    
    // If status check failed, don't proceed with payment
    if (!shouldProceed) {
      setState(() => _isLoading = false);
      return;
    }
    
    // Note: Backend will also validate the status, but frontend check provides better UX

    setState(() => _isLoading = true);

    try {
      if (kDebugMode) {
        debugPrint('💳 PaymentScreen: Starting payment for booking ${widget.bookingId}');
      }
      
      final processPaymentUseCase = ref.read(processMockPaymentUseCaseProvider);
      
      await processPaymentUseCase(
        bookingId: widget.bookingId,
        fail: false,
      );
      
      if (kDebugMode) {
        debugPrint('✅ PaymentScreen: Payment API call succeeded');
      }

      // Small delay to ensure backend has processed the payment and updated the database
      await Future.delayed(const Duration(milliseconds: 800));

      if (kDebugMode) {
        debugPrint('🔄 PaymentScreen: Invalidating booking providers to refresh data');
      }

      // Invalidate all booking providers to refresh (tenant and owner)
      ref.invalidate(bookingsProvider);
      ref.invalidate(ownerBookingsProvider);
      ref.invalidate(ownerPendingBookingsProvider);
      ref.invalidate(ownerAcceptedBookingsProvider);
      ref.invalidate(ownerRejectedBookingsProvider);
      // Invalidate the specific booking detail to refresh payment status
      // This will now fetch fresh data from API (prioritized over cached lists)
      ref.invalidate(bookingDetailProvider(widget.bookingId));
      
      // Force a refresh by reading the provider again to ensure fresh data
      await ref.read(bookingDetailProvider(widget.bookingId).future);
      
      if (kDebugMode) {
        debugPrint('✅ PaymentScreen: Booking data refreshed after payment');
      }

      if (mounted) {
        // Show success dialog
        await SuccessDialog.show(
          currentContext,
          title: l10n.paymentSuccessful,
          message: l10n.paymentProcessedSuccessfully,
          displayDuration: const Duration(seconds: 2),
        );

        if (mounted) {
          // Navigate back to bookings screen (dialog auto-closes, so just pop payment screen)
          Navigator.of(currentContext).pop();
        }
      }
    } on Failure catch (failure) {
      // Handle Failure objects (from ErrorHandler)
      if (mounted) {
        String errorMessage = failure.message;
        
        // Provide user-friendly messages for common payment errors
        if (errorMessage.contains('410') || 
            errorMessage.contains('Gone') ||
            errorMessage.contains('not in ACCEPTED or CONFIRMED')) {
          errorMessage = 'This booking cannot be paid. The booking status may have changed. Please refresh and try again.';
        } else if (errorMessage.contains('402') || 
                   errorMessage.contains('Payment Failed')) {
          errorMessage = 'Payment processing failed. Please check your payment method and try again.';
        }
        
        ScaffoldMessenger.of(currentContext).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: AppTheme.dangerRed,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    } on DioException catch (dioError) {
      // Handle DioException directly (fallback)
      if (mounted) {
        String errorMessage = l10n.paymentFailed;
        final statusCode = dioError.response?.statusCode;
        final responseData = dioError.response?.data;
        
        if (statusCode == 410) {
          errorMessage = 'This booking cannot be paid. The booking is not in ACCEPTED or CONFIRMED status. Please refresh and try again.';
        } else if (statusCode == 402) {
          errorMessage = 'Payment processing failed. Please try again.';
        } else if (responseData is Map<String, dynamic>) {
          final detail = responseData['detail'] ?? responseData['message'];
          if (detail != null) {
            errorMessage = detail.toString();
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
    } catch (e) {
      // Handle any other exceptions
      if (mounted) {
        String errorMessage = l10n.paymentFailed;
        final errorString = e.toString();
        
        // Try to extract meaningful error message
        if (errorString.contains('410') || errorString.contains('Gone')) {
          errorMessage = 'This booking cannot be paid. The booking status may have changed. Please refresh and try again.';
        } else if (errorString.contains('402') || errorString.contains('Payment')) {
          errorMessage = 'Payment processing failed. Please try again.';
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
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final bookingAsync = ref.watch(bookingDetailProvider(widget.bookingId));
    final l10n = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context);
    final priceFormat = NumberFormat.currency(
      symbol: locale.languageCode == 'ar' ? 'دل' : 'LYD',
      decimalDigits: 0,
      customPattern: '#,### \u00A4',
    );
    final dateFormat = DateFormat('d MMM yyyy', Localizations.localeOf(context).languageCode);

    return Scaffold(
      backgroundColor: AppTheme.gray50,
      appBar: AppBar(
        title: Text(l10n.payment),
        centerTitle: true,
      ),
      body: bookingAsync.when(
        data: (booking) {
          // Store booking data locally to avoid refetch issues
          // Fetch property details for booking summary
          final propertyAsync = ref.watch(propertyDetailProvider(booking.propertyId));
          
          return propertyAsync.when(
            data: (property) {
              final nights = _calculateNumberOfNights(booking.checkIn, booking.checkOut);
              final total = _calculateTotal(property.pricePerNight, nights);

              return SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Booking Summary Card
                      AppCard(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              l10n.bookingSummary,
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: AppTheme.gray900,
                                  ),
                            ),
                            const SizedBox(height: 16),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Property Image
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: SizedBox(
                                    width: 100,
                                    height: 100,
                                    child: property.imageUrls.isNotEmpty
                                        ? CachedNetworkImage(
                                            imageUrl: AppConfig.resolveAssetUrl(property.imageUrls.first),
                                            fit: BoxFit.cover,
                                            placeholder: (context, url) => Container(
                                              color: AppTheme.gray200,
                                              child: const Center(
                                                child: CircularProgressIndicator(),
                                              ),
                                            ),
                                            errorWidget: (context, url, error) => Container(
                                              color: AppTheme.gray200,
                                              child: const Icon(Icons.image_not_supported),
                                            ),
                                          )
                                        : Container(
                                            color: AppTheme.gray200,
                                            child: const Icon(Icons.home),
                                          ),
                                  ),
                                ),
                                const SizedBox(width: 16),
                                // Property Details
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        property.name,
                                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                              fontWeight: FontWeight.bold,
                                              color: AppTheme.gray900,
                                            ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        '${_getPropertyTypeLabel(property.propertyType, l10n)} - ${property.city}',
                                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                              color: AppTheme.gray600,
                                            ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        property.address ?? property.city,
                                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                              color: AppTheme.gray600,
                                            ),
                                      ),
                                      if (property.averageRating != null && property.averageRating! > 0) ...[
                                        const SizedBox(height: 4),
                                        Row(
                                          children: [
                                            Icon(Icons.star, size: 16, color: Colors.amber),
                                            const SizedBox(width: 4),
                                            Text(
                                              property.averageRating!.toStringAsFixed(1),
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
                              ],
                            ),
                            const SizedBox(height: 16),
                            const Divider(),
                            const SizedBox(height: 16),
                            // Booking Details
                            _buildDetailRow(
                              context,
                              l10n.arrivalDate,
                              dateFormat.format(booking.checkIn),
                            ),
                            const SizedBox(height: 8),
                            _buildDetailRow(
                              context,
                              l10n.departureDate,
                              dateFormat.format(booking.checkOut),
                            ),
                            const SizedBox(height: 8),
                            _buildDetailRow(
                              context,
                              l10n.numberOfNights,
                              '$nights ${l10n.nights}',
                            ),
                            const SizedBox(height: 8),
                            _buildDetailRow(
                              context,
                              l10n.numberOfGuests,
                              '${booking.guests ?? 1} ${l10n.people}',
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      // Price Details Card
                      AppCard(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              l10n.priceDetails,
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: AppTheme.gray900,
                                  ),
                            ),
                            const SizedBox(height: 16),
                            _buildPriceRow(
                              context,
                              l10n.pricePerNight,
                              priceFormat.format(property.pricePerNight),
                            ),
                            const SizedBox(height: 8),
                            _buildPriceRow(
                              context,
                              '$nights ${l10n.nights} × ${priceFormat.format(property.pricePerNight)}',
                              priceFormat.format(total),
                            ),
                            const SizedBox(height: 16),
                            const Divider(),
                            const SizedBox(height: 8),
                            _buildPriceRow(
                              context,
                              l10n.totalAmount,
                              priceFormat.format(total),
                              isTotal: true,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      // Payment Method Selection
                      AppCard(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              l10n.paymentMethod,
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: AppTheme.gray900,
                                  ),
                            ),
                            const SizedBox(height: 16),
                            // Edfaaly Option
                            _buildPaymentMethodOption(
                              context,
                              PaymentMethod.edfaaly,
                              l10n.edfaaly,
                              'assets/images/Edfaaly.png',
                            ),
                            const SizedBox(height: 12),
                            // Mobi Cash Option
                            _buildPaymentMethodOption(
                              context,
                              PaymentMethod.mobiCash,
                              l10n.mobiCash,
                              'assets/images/MobiCash.png',
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      // Service Information Card
                      AppCard(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              l10n.serviceInformation,
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: AppTheme.gray900,
                                  ),
                            ),
                            const SizedBox(height: 16),
                            // Phone/Service Number Field
                            TextFormField(
                              controller: _phoneNumberController,
                              keyboardType: TextInputType.number,
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly,
                              ],
                              decoration: InputDecoration(
                                labelText: l10n.enterPhoneOrServiceNumber,
                                hintText: l10n.enterPhoneOrServiceNumber,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                prefixIcon: const Icon(Icons.phone),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return l10n.fieldRequired;
                                }
                                if (value.length < 7 || value.length > 10) {
                                  return l10n.invalidPhoneNumber;
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 16),
                            // Total Amount Field (Disabled)
                            TextFormField(
                              initialValue: priceFormat.format(total),
                              enabled: false,
                              decoration: InputDecoration(
                                labelText: l10n.totalAmount,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                prefixIcon: const Icon(Icons.attach_money),
                                disabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(color: AppTheme.gray300),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                      // Pay Button
                      AppButton(
                        text: '${l10n.pay} ${priceFormat.format(total)}',
                        icon: Icons.lock,
                        onPressed: _isLoading ? null : _processPayment,
                        isLoading: _isLoading,
                      ),
                      const SizedBox(height: 8),
                      // Terms Note
                      Center(
                        child: Text(
                          l10n.byClickingPayYouAgree,
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: AppTheme.gray600,
                              ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, stack) {
              // If property fails to load, show error but don't block the screen
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.error_outline, size: 48, color: AppTheme.dangerRed),
                      const SizedBox(height: 16),
                      Text(
                        l10n.somethingWentWrong,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Failed to load property details',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppTheme.gray600,
                            ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) {
          // Show user-friendly error message with retry option
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 48, color: AppTheme.dangerRed),
                  const SizedBox(height: 16),
                  Text(
                    l10n.somethingWentWrong,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Failed to load booking details. Please try again.',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppTheme.gray600,
                        ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: () {
                      // Retry loading booking
                      ref.invalidate(bookingDetailProvider(widget.bookingId));
                    },
                    icon: const Icon(Icons.refresh),
                    label: Text(l10n.retry),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryBlue,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildDetailRow(BuildContext context, String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppTheme.gray600,
              ),
        ),
        Text(
          value,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
                color: AppTheme.gray900,
              ),
        ),
      ],
    );
  }

  Widget _buildPriceRow(BuildContext context, String label, String value, {bool isTotal = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: isTotal ? AppTheme.gray900 : AppTheme.gray600,
                fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
              ),
        ),
        Text(
          value,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: isTotal ? AppTheme.primaryBlue : AppTheme.gray900,
                fontWeight: FontWeight.bold,
              ),
        ),
      ],
    );
  }

  Widget _buildPaymentMethodOption(
    BuildContext context,
    PaymentMethod method,
    String label,
    String logoPath,
  ) {
    final isSelected = _selectedPaymentMethod == method;
    
    // Determine border color based on payment method
    final Color borderColor;
    final Color selectedTextColor;
    final Color selectedBackgroundColor;
    
    if (method == PaymentMethod.edfaaly) {
      // Green for Edfaaly
      borderColor = isSelected ? Colors.green : AppTheme.gray300;
      selectedTextColor = Colors.green.shade700;
      selectedBackgroundColor = Colors.green.withValues(alpha: 0.05);
    } else {
      // Blue for Mobi Cash
      borderColor = isSelected ? AppTheme.primaryBlue : AppTheme.gray300;
      selectedTextColor = AppTheme.primaryBlue;
      selectedBackgroundColor = AppTheme.primaryBlue.withValues(alpha: 0.05);
    }

    return InkWell(
      onTap: () {
        setState(() {
          _selectedPaymentMethod = method;
        });
      },
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(
            color: borderColor,
            width: isSelected ? 2.5 : 1.5,
          ),
          borderRadius: BorderRadius.circular(16),
          color: isSelected ? selectedBackgroundColor : Colors.transparent,
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: borderColor.withValues(alpha: 0.2),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Row(
          children: [
            // Logo Container - Bigger for Mobi Cash
            Container(
              width: method == PaymentMethod.mobiCash ? 72 : 56,
              height: method == PaymentMethod.mobiCash ? 72 : 56,
              padding: method == PaymentMethod.mobiCash 
                  ? const EdgeInsets.all(6) 
                  : const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isSelected ? borderColor.withValues(alpha: 0.3) : AppTheme.gray200,
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Image.asset(
                logoPath,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) {
                  // Fallback icon if image fails to load
                  return Icon(
                    method == PaymentMethod.edfaaly
                        ? Icons.account_balance_wallet
                        : Icons.phone_android,
                    color: borderColor,
                    size: method == PaymentMethod.mobiCash ? 36 : 28,
                  );
                },
              ),
            ),
            const SizedBox(width: 16),
            // Payment Method Label
            Expanded(
              child: Text(
                label,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                      color: isSelected ? selectedTextColor : AppTheme.gray900,
                      fontSize: 16,
                    ),
              ),
            ),
            // Radio Button
            Radio<PaymentMethod>(
              value: method,
              groupValue: _selectedPaymentMethod,
              onChanged: (value) {
                setState(() {
                  _selectedPaymentMethod = value;
                });
              },
              activeColor: borderColor,
              fillColor: WidgetStateProperty.resolveWith<Color>((states) {
                if (states.contains(WidgetState.selected)) {
                  return borderColor;
                }
                return AppTheme.gray400;
              }),
            ),
          ],
        ),
      ),
    );
  }

  String _getPropertyTypeLabel(String type, AppLocalizations l10n) {
    switch (type.toLowerCase()) {
      case 'villa':
        return l10n.villa;
      case 'apartment':
        return l10n.apartment;
      case 'chalet':
        return l10n.chalet;
      default:
        return type;
    }
  }
}

