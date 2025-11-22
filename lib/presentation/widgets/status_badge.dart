import 'package:flutter/material.dart';
import 'package:maawa_project/core/theme/app_theme.dart';
import 'package:maawa_project/l10n/app_localizations.dart';

enum PropertyStatus {
  available,
  rented,
  reserved,
}

enum BookingStatus {
  pending,
  confirmed,
  completed,
  cancelled,
}

class StatusBadge extends StatelessWidget {
  final String label;
  final Color? backgroundColor;
  final Color? textColor;
  final bool small;

  const StatusBadge({
    super.key,
    required this.label,
    this.backgroundColor,
    this.textColor,
    this.small = false,
  });

  factory StatusBadge.property(PropertyStatus status, BuildContext context, {bool small = false}) {
    final l10n = AppLocalizations.of(context);
    final Map<PropertyStatus, Map<String, dynamic>> styles = {
      PropertyStatus.available: {
        'bg': const Color(0xFF10B981).withOpacity(0.15), // Brighter green with more opacity
        'text': const Color(0xFF059669), // Brighter, more visible green
        'label': l10n.available,
      },
      PropertyStatus.rented: {
        'bg': AppTheme.gray300,
        'text': AppTheme.gray700,
        'label': l10n.rented,
      },
      PropertyStatus.reserved: {
        'bg': AppTheme.warningOrange.withOpacity(0.1),
        'text': AppTheme.warningOrange,
        'label': l10n.reserved,
      },
    };

    final style = styles[status]!;
    return StatusBadge(
      label: style['label'],
      backgroundColor: style['bg'],
      textColor: style['text'],
      small: small,
    );
  }

  factory StatusBadge.booking(BookingStatus status, {bool small = false}) {
    final Map<BookingStatus, Map<String, dynamic>> styles = {
      BookingStatus.pending: {
        'bg': AppTheme.warningOrange.withOpacity(0.1),
        'text': AppTheme.warningOrange,
        'labelAr': 'قيد المراجعة',
      },
      BookingStatus.confirmed: {
        'bg': AppTheme.infoBlue.withOpacity(0.1),
        'text': AppTheme.infoBlue,
        'labelAr': 'مؤكدة',
      },
      BookingStatus.completed: {
        'bg': AppTheme.successGreen.withOpacity(0.1),
        'text': AppTheme.successGreen,
        'labelAr': 'مكتمل',
      },
      BookingStatus.cancelled: {
        'bg': AppTheme.dangerRed.withOpacity(0.1),
        'text': AppTheme.dangerRed,
        'labelAr': 'ملغي',
      },
    };

    final style = styles[status]!;
    return StatusBadge(
      label: style['labelAr'],
      backgroundColor: style['bg'],
      textColor: style['text'],
      small: small,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: small ? 8 : 12,
        vertical: small ? 4 : 6,
      ),
      decoration: BoxDecoration(
        color: backgroundColor ?? AppTheme.gray200,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: textColor ?? AppTheme.gray700,
          fontSize: small ? 11 : 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

