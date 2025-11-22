import 'package:equatable/equatable.dart';

enum NotificationType {
  booking,
  proposal,
  review,
  payment,
  system,
}

enum NotificationStatus {
  read,
  unread,
}

class Notification extends Equatable {
  final String id;
  final String title;
  final String body;
  final NotificationType type;
  final NotificationStatus status;
  final DateTime createdAt;
  final Map<String, dynamic>? data; // Additional data (booking_id, proposal_id, etc.)

  const Notification({
    required this.id,
    required this.title,
    required this.body,
    required this.type,
    required this.status,
    required this.createdAt,
    this.data,
  });

  @override
  List<Object?> get props => [id, title, body, type, status, createdAt, data];
}

