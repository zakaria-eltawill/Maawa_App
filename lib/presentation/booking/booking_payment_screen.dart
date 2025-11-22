import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:maawa_project/core/di/providers.dart';
import 'package:maawa_project/core/theme/app_theme.dart';
import 'package:maawa_project/presentation/widgets/app_button.dart';
import 'package:maawa_project/presentation/widgets/app_card.dart';
import 'package:maawa_project/presentation/widgets/success_dialog.dart';
import 'package:maawa_project/l10n/app_localizations.dart';
import 'package:intl/intl.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:maawa_project/core/config/app_config.dart';

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

    setState(() => _isLoading = true);

    try {
      final processPaymentUseCase = ref.read(processMockPaymentUseCaseProvider);
      
      await processPaymentUseCase(
        bookingId: widget.bookingId,
        fail: false,
      );

      // Invalidate all booking providers to refresh (tenant and owner)
      ref.invalidate(bookingsProvider);
      ref.invalidate(ownerBookingsProvider);
      ref.invalidate(ownerPendingBookingsProvider);
      ref.invalidate(ownerAcceptedBookingsProvider);
      ref.invalidate(ownerRejectedBookingsProvider);

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
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(currentContext).showSnackBar(
          SnackBar(
            content: Text(l10n.paymentFailed),
            backgroundColor: AppTheme.dangerRed,
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
    final priceFormat = NumberFormat.currency(
      symbol: 'دل',
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
                                        '${property.propertyType} - ${property.city}',
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
                              Icons.account_balance_wallet,
                              Colors.purple,
                            ),
                            const SizedBox(height: 12),
                            // Mobi Cash Option
                            _buildPaymentMethodOption(
                              context,
                              PaymentMethod.mobiCash,
                              l10n.mobiCash,
                              Icons.phone_android,
                              Colors.green,
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
    IconData icon,
    Color color,
  ) {
    final isSelected = _selectedPaymentMethod == method;

    return InkWell(
      onTap: () {
        setState(() {
          _selectedPaymentMethod = method;
        });
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(
            color: isSelected ? AppTheme.primaryBlue : AppTheme.gray300,
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(12),
          color: isSelected ? AppTheme.primaryBlue.withValues(alpha: 0.05) : Colors.transparent,
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      color: isSelected ? AppTheme.primaryBlue : AppTheme.gray900,
                    ),
              ),
            ),
            Radio<PaymentMethod>(
              value: method,
              groupValue: _selectedPaymentMethod,
              onChanged: (value) {
                setState(() {
                  _selectedPaymentMethod = value;
                });
              },
              activeColor: AppTheme.primaryBlue,
            ),
          ],
        ),
      ),
    );
  }
}

