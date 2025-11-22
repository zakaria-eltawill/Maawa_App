import 'package:json_annotation/json_annotation.dart';
import 'package:maawa_project/domain/entities/notification.dart';

part 'notification_dto.g.dart';

@JsonSerializable()
class NotificationDto {
  final String id;
  final String title;
  final String body;
  final String type;
  final bool read;
  @JsonKey(name: 'created_at')
  final String createdAt;
  final Map<String, dynamic>? data;

  NotificationDto({
    required this.id,
    required this.title,
    required this.body,
    required this.type,
    required this.read,
    required this.createdAt,
    this.data,
  });

  factory NotificationDto.fromJson(Map<String, dynamic> json) =>
      _$NotificationDtoFromJson(json);

  Map<String, dynamic> toJson() => _$NotificationDtoToJson(this);

  Notification toDomain() {
    return Notification(
      id: id,
      title: title,
      body: body,
      type: _parseType(type),
      status: read ? NotificationStatus.read : NotificationStatus.unread,
      createdAt: DateTime.parse(createdAt),
      data: data,
    );
  }

  NotificationType _parseType(String type) {
    switch (type.toLowerCase()) {
      case 'booking':
        return NotificationType.booking;
      case 'proposal':
        return NotificationType.proposal;
      case 'review':
        return NotificationType.review;
      case 'payment':
        return NotificationType.payment;
      case 'system':
        return NotificationType.system;
      default:
        return NotificationType.system;
    }
  }
}

