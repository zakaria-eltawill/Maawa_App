import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:maawa_project/core/theme/app_theme.dart';
import 'package:maawa_project/presentation/widgets/state_badge.dart';

class BookingTimelineScreen extends ConsumerWidget {
  final String bookingId;

  const BookingTimelineScreen({
    super.key,
    required this.bookingId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // TODO: Implement booking timeline with Riverpod provider
    return Scaffold(
      appBar: AppBar(
        title: Text('Booking Timeline'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppTheme.spacingMD),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // TODO: Display booking details and timeline
            Text(
              'Booking Status',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 16),
            // TODO: Display timeline events
            Text('Loading...'),
          ],
        ),
      ),
    );
  }
}

