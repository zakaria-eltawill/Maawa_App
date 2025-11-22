import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:maawa_project/core/theme/app_theme.dart';
import 'package:maawa_project/core/di/providers.dart';
import 'package:maawa_project/domain/entities/property.dart';
import 'package:maawa_project/presentation/widgets/app_button.dart';
import 'package:maawa_project/presentation/widgets/app_card.dart';
import 'package:maawa_project/presentation/widgets/success_dialog.dart';
import 'package:maawa_project/presentation/widgets/unavailable_date_picker.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:maawa_project/l10n/app_localizations.dart';
import 'package:intl/intl.dart';

class BookingCreateScreen extends ConsumerStatefulWidget {
  final String propertyId;

  const BookingCreateScreen({
    super.key,
    required this.propertyId,
  });

  @override
  ConsumerState<BookingCreateScreen> createState() =>
      _BookingCreateScreenState();
}

class _BookingCreateScreenState extends ConsumerState<BookingCreateScreen> {
  final _formKey = GlobalKey<FormState>();
  final _notesController = TextEditingController();
  DateTime? _checkIn;
  DateTime? _checkOut;
  int _numberOfGuests = 1;
  bool _isLoading = false;

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  int get _numberOfNights {
    if (_checkIn == null || _checkOut == null) return 0;
    return _checkOut!.difference(_checkIn!).inDays;
  }

  Future<void> _selectCheckIn(Property property) async {
    final l10n = AppLocalizations.of(context);
    
    if (kDebugMode) {
      debugPrint('📅 BookingCreateScreen._selectCheckIn: Property unavailable dates count: ${property.unavailableDates.length}');
      if (property.unavailableDates.isNotEmpty) {
        debugPrint('📅 BookingCreateScreen._selectCheckIn: Sample unavailable dates: ${property.unavailableDates.take(5).toList()}');
      }
    }
    
    final date = await UnavailableDatePicker.show(
      context: context,
      unavailableDates: property.unavailableDates,
      initialDate: _checkIn ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      unavailableMessage: l10n.dateUnavailableMessage,
    );
    
    if (date != null) {
      setState(() {
        _checkIn = date;
        // Reset checkout if it's before or same as checkin
        if (_checkOut != null && !_checkOut!.isAfter(_checkIn!)) {
          _checkOut = null;
        }
      });
    }
  }

  Future<void> _selectCheckOut(Property property) async {
    if (!mounted) return;
    final l10n = AppLocalizations.of(context);
    
    if (_checkIn == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${l10n.checkIn} ${l10n.fieldRequired}'),
            backgroundColor: AppTheme.dangerRed,
          ),
        );
      }
      return;
    }

    if (kDebugMode) {
      debugPrint('📅 BookingCreateScreen._selectCheckOut: Property unavailable dates count: ${property.unavailableDates.length}');
      if (property.unavailableDates.isNotEmpty) {
        debugPrint('📅 BookingCreateScreen._selectCheckOut: Sample unavailable dates: ${property.unavailableDates.take(5).toList()}');
      }
    }

    final date = await UnavailableDatePicker.show(
      context: context,
      unavailableDates: property.unavailableDates,
      initialDate: _checkOut ?? _checkIn!.add(const Duration(days: 1)),
      firstDate: _checkIn!.add(const Duration(days: 1)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      unavailableMessage: l10n.dateUnavailableMessage,
    );
    
    if (!mounted) return;
    
    if (date != null) {
      setState(() {
        _checkOut = date;
      });
    }
  }

  Future<void> _createBooking(double pricePerNight, Property property) async {
    // Capture context and l10n before async operations
    final currentContext = context;
    final l10n = AppLocalizations.of(currentContext);
    
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_checkIn == null || _checkOut == null) {
      ScaffoldMessenger.of(currentContext).showSnackBar(
        SnackBar(
          content: Text('${l10n.checkIn} و ${l10n.checkOut} ${l10n.fieldRequired}'),
          backgroundColor: AppTheme.dangerRed,
        ),
      );
      return;
    }

    // Validate that selected dates don't overlap with unavailable dates
    final normalizedUnavailable = property.unavailableDates.map((date) {
      return DateTime(date.year, date.month, date.day);
    }).toSet();
    
    final normalizedCheckIn = DateTime(_checkIn!.year, _checkIn!.month, _checkIn!.day);
    final normalizedCheckOut = DateTime(_checkOut!.year, _checkOut!.month, _checkOut!.day);
    
    if (kDebugMode) {
      debugPrint('📅 BookingCreateScreen._createBooking: Validating dates');
      debugPrint('📅   Check-in: $normalizedCheckIn');
      debugPrint('📅   Check-out: $normalizedCheckOut');
      debugPrint('📅   Unavailable dates count: ${normalizedUnavailable.length}');
      if (normalizedUnavailable.isNotEmpty) {
        debugPrint('📅   Sample unavailable dates: ${normalizedUnavailable.take(5).toList()}');
      }
    }
    
    // Check if any date in the selected range is unavailable
    var currentDate = normalizedCheckIn;
    final conflictingDates = <DateTime>[];
    while (currentDate.isBefore(normalizedCheckOut)) {
      if (normalizedUnavailable.contains(currentDate)) {
        conflictingDates.add(DateTime(currentDate.year, currentDate.month, currentDate.day));
      }
      currentDate = currentDate.add(const Duration(days: 1));
    }
    
    if (conflictingDates.isNotEmpty) {
      if (kDebugMode) {
        debugPrint('❌ BookingCreateScreen._createBooking: Found ${conflictingDates.length} conflicting dates');
        debugPrint('❌   Conflicting dates: ${conflictingDates.take(5).toList()}');
      }
      if (mounted) {
        ScaffoldMessenger.of(currentContext).showSnackBar(
          SnackBar(
            content: Text(l10n.dateUnavailableMessage),
            backgroundColor: AppTheme.dangerRed,
            duration: const Duration(seconds: 4),
          ),
        );
      }
      return;
    }
    
    if (kDebugMode) {
      debugPrint('✅ BookingCreateScreen._createBooking: Date validation passed');
    }

    setState(() => _isLoading = true);

    try {
      if (kDebugMode) {
        debugPrint('📤 BookingCreateScreen._createBooking: Starting booking creation');
      }
      
      final createBookingUseCase = ref.read(createBookingUseCaseProvider);
      
      final booking = await createBookingUseCase(
        propertyId: widget.propertyId,
        checkIn: _checkIn!,
        checkOut: _checkOut!,
        guests: _numberOfGuests,
      );
      
      if (kDebugMode) {
        debugPrint('✅ BookingCreateScreen._createBooking: Booking created successfully');
        debugPrint('✅   Booking ID: ${booking.id}');
        debugPrint('✅   Status: ${booking.status}');
      }
      
      // Invalidate bookings list to refresh
      ref.invalidate(bookingsProvider);
      ref.invalidate(ownerPendingBookingsProvider);
      ref.invalidate(ownerBookingsProvider);
      
      if (mounted) {
        // Show success animation
        await SuccessDialog.show(
          currentContext,
          title: l10n.bookingRequested,
          message: l10n.waitingForOwnerApproval,
        );
        
        if (mounted) {
          Navigator.of(currentContext).pop();
        }
      }
    } catch (e, stackTrace) {
      if (kDebugMode) {
        debugPrint('❌ BookingCreateScreen._createBooking: Error creating booking');
        debugPrint('❌   Error type: ${e.runtimeType}');
        debugPrint('❌   Error: $e');
        debugPrint('❌   Stack trace: $stackTrace');
      }
      
      if (mounted) {
        // Capture context and l10n before async operations
        final currentContext = context;
        final l10n = AppLocalizations.of(currentContext);
        
        // Check if this is a parsing error but backend succeeded
        final errorString = e.toString().toLowerCase();
        final isBackendSuccess = errorString.contains('backend returned success') ||
                                 errorString.contains('booking was created') ||
                                 errorString.contains('parsing failed but backend');
        
        if (isBackendSuccess) {
          // Backend succeeded, just parsing failed - show success dialog
          if (kDebugMode) {
            debugPrint('✅ BookingCreateScreen: Backend succeeded, parsing failed - showing success');
          }
          
          // Invalidate bookings list to refresh
          ref.invalidate(bookingsProvider);
          ref.invalidate(ownerPendingBookingsProvider);
          ref.invalidate(ownerBookingsProvider);
          
          // Wait a bit for providers to refresh
          await Future.delayed(const Duration(milliseconds: 300));
          
          if (mounted) {
            // Show success animation
            await SuccessDialog.show(
              currentContext,
              title: l10n.bookingRequested,
              message: l10n.waitingForOwnerApproval,
            );
            
        if (mounted) {
          Navigator.of(currentContext).pop();
        }
          }
          return; // Exit early, don't show error
        }
        
        // Real error - show error message
        String errorMessage = l10n.somethingWentWrong;
        
        // Handle specific errors
        if (e.toString().contains('409') || 
            e.toString().contains('date_range_unavailable') ||
            e.toString().contains('Conflict')) {
          errorMessage = l10n.dateUnavailableMessage;
          
          // Don't clear dates - let user see what they selected and choose different dates
          // The calendar will prevent selecting unavailable dates, but if they somehow
          // selected them, we show the error without clearing their selection
        } else if (e.toString().contains('422')) {
          errorMessage = 'Invalid booking data. Please check your dates and try again.';
        }
        
        ScaffoldMessenger.of(currentContext).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: AppTheme.dangerRed,
            duration: const Duration(seconds: 4),
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
    final propertyAsync = ref.watch(propertyDetailProvider(widget.propertyId));
    final l10n = AppLocalizations.of(context);
    final priceFormat = NumberFormat.currency(
      symbol: 'دل',
      decimalDigits: 0,
      customPattern: '#,### \u00A4',
    );

    return Scaffold(
      backgroundColor: AppTheme.gray50,
      appBar: AppBar(
        title: Text(l10n.bookingRequest),
        centerTitle: true,
      ),
      body: propertyAsync.when(
        data: (property) {
          final subtotal = property.pricePerNight * _numberOfNights;
          final serviceFee = subtotal * 0.05; // 5% service fee
          final total = subtotal + serviceFee;

          return SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  // Property summary card
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: AppCard(
                      child: Row(
                        children: [
                          // Property image
                          ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: SizedBox(
                              width: 80,
                              height: 80,
                              child: property.imageUrls.isNotEmpty
                                  ? CachedNetworkImage(
                                      imageUrl: property.imageUrls.first,
                                      fit: BoxFit.cover,
                                    )
                                  : Container(
                                      color: AppTheme.gray200,
                                      child: const Icon(
                                        Icons.home_outlined,
                                        color: AppTheme.gray400,
                                      ),
                                    ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          
                          // Property info
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  property.name,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: AppTheme.gray900,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '${l10n.city} ${property.city}',
                                  style: const TextStyle(
                                    fontSize: 13,
                                    color: AppTheme.gray600,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    Text(
                                      priceFormat.format(property.pricePerNight),
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: AppTheme.primaryBlue,
                                      ),
                                    ),
                                    Text(
                                      ' ${l10n.perNight}',
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: AppTheme.gray600,
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
                  
                  // Booking details
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: AppCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            l10n.bookingDetails,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: AppTheme.gray900,
                            ),
                          ),
                          const SizedBox(height: 20),
                          
                          // Check-in
                          _DateField(
                            label: l10n.checkIn,
                            date: _checkIn,
                            onTap: () => _selectCheckIn(property),
                          ),
                          const SizedBox(height: 16),
                          
                          // Check-out
                          _DateField(
                            label: l10n.checkOut,
                            date: _checkOut,
                            onTap: () => _selectCheckOut(property),
                          ),
                          const SizedBox(height: 16),
                          
                          // Number of guests
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                l10n.numberOfGuests,
                                style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w500,
                                  color: AppTheme.gray700,
                                ),
                              ),
                              Row(
                                children: [
                                  IconButton(
                                    onPressed: _numberOfGuests > 1
                                        ? () => setState(() => _numberOfGuests--)
                                        : null,
                                    icon: const Icon(Icons.remove_circle_outline),
                                    color: AppTheme.primaryBlue,
                                  ),
                                  Container(
                                    width: 40,
                                    alignment: Alignment.center,
                                    child: Text(
                                      _numberOfGuests.toString(),
                                      style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w600,
                                        color: AppTheme.gray900,
                                      ),
                                    ),
                                  ),
                                  IconButton(
                                    onPressed: () => setState(() => _numberOfGuests++),
                                    icon: const Icon(Icons.add_circle_outline),
                                    color: AppTheme.primaryBlue,
                                  ),
                                ],
                              ),
                            ],
                          ),
                          
                          if (_numberOfNights > 0) ...[
                            const SizedBox(height: 8),
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: AppTheme.infoBlue.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                children: [
                                  const Icon(
                                    Icons.nights_stay,
                                    size: 20,
                                    color: AppTheme.infoBlue,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    '$_numberOfNights ${l10n.nights}',
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: AppTheme.infoBlue,
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
                  
                  const SizedBox(height: 16),
                  
                  // Additional notes
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: AppCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            l10n.additionalNotes,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: AppTheme.gray900,
                            ),
                          ),
                          const SizedBox(height: 12),
                          TextField(
                            controller: _notesController,
                            maxLines: 4,
                            decoration: InputDecoration(
                              hintText: l10n.addNotesPlaceholder,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(color: AppTheme.gray300),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Price summary
                  if (_numberOfNights > 0)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: AppCard(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              l10n.bookingSummary,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: AppTheme.gray900,
                              ),
                            ),
                            const SizedBox(height: 16),
                            _PriceRow(
                              label: '${priceFormat.format(property.pricePerNight)} × $_numberOfNights ${l10n.nights}',
                              value: priceFormat.format(subtotal),
                            ),
                            const Divider(height: 24),
                            _PriceRow(
                              label: l10n.serviceFee,
                              value: priceFormat.format(serviceFee),
                            ),
                            const Divider(height: 24),
                            _PriceRow(
                              label: l10n.totalPrice,
                              value: priceFormat.format(total),
                              isTotal: true,
                            ),
                          ],
                        ),
                      ),
                    ),
                  
                  const SizedBox(height: 100), // Space for button
                ],
              ),
            ),
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
                  l10n.failedToLoad,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: propertyAsync.when(
        data: (property) => Container(
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
            text: _numberOfNights > 0
                ? '${l10n.requestBooking} • ${priceFormat.format(property.pricePerNight * _numberOfNights + (property.pricePerNight * _numberOfNights * 0.05))}'
                : l10n.requestBooking,
            onPressed: _numberOfNights > 0
                ? () => _createBooking(property.pricePerNight, property)
                : null,
            isLoading: _isLoading,
          ),
        ),
        loading: () => const SizedBox.shrink(),
        error: (_, __) => const SizedBox.shrink(),
      ),
    );
  }
}

class _DateField extends StatelessWidget {
  final String label;
  final DateTime? date;
  final VoidCallback onTap;

  const _DateField({
    required this.label,
    required this.date,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('dd/MM/yyyy');
    
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(color: AppTheme.gray300),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppTheme.primaryBlue.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.calendar_today,
                size: 20,
                color: AppTheme.primaryBlue,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppTheme.gray500,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    date != null ? dateFormat.format(date!) : 'اختر التاريخ',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: date != null ? AppTheme.gray900 : AppTheme.gray400,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.chevron_left,
              color: AppTheme.gray400,
            ),
          ],
        ),
      ),
    );
  }
}

class _PriceRow extends StatelessWidget {
  final String label;
  final String value;
  final bool isTotal;

  const _PriceRow({
    required this.label,
    required this.value,
    this.isTotal = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: isTotal ? 16 : 15,
            fontWeight: isTotal ? FontWeight.w600 : FontWeight.normal,
            color: isTotal ? AppTheme.gray900 : AppTheme.gray700,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: isTotal ? 18 : 15,
            fontWeight: FontWeight.bold,
            color: isTotal ? AppTheme.primaryBlue : AppTheme.gray900,
          ),
        ),
      ],
    );
  }
}
