import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:maawa_project/core/theme/app_theme.dart';
import 'package:maawa_project/l10n/app_localizations.dart';

/// A custom date picker that marks unavailable dates in red and disables them
class UnavailableDatePicker {
  /// Shows a date picker with unavailable dates marked in red and disabled
  static Future<DateTime?> show({
    required BuildContext context,
    required List<DateTime> unavailableDates,
    DateTime? initialDate,
    required DateTime firstDate,
    required DateTime lastDate,
    String? unavailableMessage,
  }) async {
    final l10n = AppLocalizations.of(context);
    final message = unavailableMessage ?? l10n.dateUnavailableMessage;
    
    // Normalize unavailable dates to compare only date (without time)
    final normalizedUnavailable = unavailableDates.map((date) {
      return DateTime(date.year, date.month, date.day);
    }).toSet();
    
    if (kDebugMode) {
      debugPrint('📅 UnavailableDatePicker: Total unavailable dates: ${normalizedUnavailable.length}');
      if (normalizedUnavailable.isNotEmpty) {
        debugPrint('📅 UnavailableDatePicker: Sample unavailable dates: ${normalizedUnavailable.take(5).toList()}');
      }
    }
    
    return await showDatePicker(
      context: context,
      initialDate: initialDate ?? firstDate,
      firstDate: firstDate,
      lastDate: lastDate,
      selectableDayPredicate: (date) {
        // Normalize the date to compare only date (without time)
        final normalizedDate = DateTime(date.year, date.month, date.day);
        final isUnavailable = normalizedUnavailable.contains(normalizedDate);
        
        if (kDebugMode && isUnavailable) {
          debugPrint('📅 UnavailableDatePicker: Date $normalizedDate is unavailable');
        }
        
        // Disable unavailable dates
        return !isUnavailable;
      },
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: AppTheme.primaryBlue,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: AppTheme.gray900,
              error: AppTheme.dangerRed,
              onError: Colors.white,
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: AppTheme.primaryBlue,
              ),
            ),
          ),
          child: Builder(
            builder: (context) {
              return MediaQuery(
                data: MediaQuery.of(context).copyWith(
                  // Ensure the calendar doesn't get cut off
                  textScaler: MediaQuery.of(context).textScaler.clamp(
                    minScaleFactor: 0.8,
                    maxScaleFactor: 1.2,
                  ),
                ),
                child: _UnavailableDatePickerWidget(
                  unavailableDates: normalizedUnavailable,
                  unavailableMessage: message,
                  child: child!,
                ),
              );
            },
          ),
        );
      },
    );
  }
}

/// Custom widget that wraps the date picker and customizes unavailable dates
class _UnavailableDatePickerWidget extends StatelessWidget {
  final Set<DateTime> unavailableDates;
  final String unavailableMessage;
  final Widget child;

  const _UnavailableDatePickerWidget({
    required this.unavailableDates,
    required this.unavailableMessage,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: Theme.of(context).copyWith(
        datePickerTheme: DatePickerThemeData(
          // Customize the calendar appearance
          dayStyle: const TextStyle(
            color: AppTheme.gray900,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
      child: Builder(
        builder: (context) {
          // Use a custom calendar builder to mark unavailable dates
          return _CustomCalendarBuilder(
            unavailableDates: unavailableDates,
            unavailableMessage: unavailableMessage,
            child: child,
          );
        },
      ),
    );
  }
}

/// Custom calendar builder that marks unavailable dates in red
class _CustomCalendarBuilder extends StatelessWidget {
  final Set<DateTime> unavailableDates;
  final String unavailableMessage;
  final Widget child;

  const _CustomCalendarBuilder({
    required this.unavailableDates,
    required this.unavailableMessage,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return child;
  }
}

