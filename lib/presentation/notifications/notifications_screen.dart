import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:maawa_project/core/di/providers.dart';
import 'package:maawa_project/core/theme/app_theme.dart';
import 'package:maawa_project/domain/entities/notification.dart' as domain;
import 'package:maawa_project/l10n/app_localizations.dart';
import 'package:maawa_project/presentation/widgets/app_card.dart';
import 'package:maawa_project/presentation/widgets/empty_state.dart';
import 'package:maawa_project/presentation/widgets/error_state.dart';
import 'package:maawa_project/presentation/widgets/shimmer_loading.dart';

class NotificationsScreen extends ConsumerStatefulWidget {
  const NotificationsScreen({super.key});

  @override
  ConsumerState<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends ConsumerState<NotificationsScreen> {
  bool? _filterRead; // null = all, true = read, false = unread

  IconData _getNotificationIcon(domain.NotificationType type) {
    switch (type) {
      case domain.NotificationType.booking:
        return Icons.calendar_today_outlined;
      case domain.NotificationType.proposal:
        return Icons.edit_note_outlined;
      case domain.NotificationType.review:
        return Icons.star_outline;
      case domain.NotificationType.payment:
        return Icons.payment_outlined;
      case domain.NotificationType.system:
        return Icons.info_outline;
    }
  }

  Color _getNotificationColor(domain.NotificationType type) {
    switch (type) {
      case domain.NotificationType.booking:
        return AppTheme.primaryBlue;
      case domain.NotificationType.proposal:
        return AppTheme.warningOrange;
      case domain.NotificationType.review:
        return Colors.amber;
      case domain.NotificationType.payment:
        return AppTheme.successGreen;
      case domain.NotificationType.system:
        return AppTheme.gray600;
    }
  }

  Future<void> _markAsRead(String notificationId) async {
    try {
      final useCase = ref.read(markNotificationReadUseCaseProvider);
      await useCase(notificationId);
      ref.invalidate(notificationsProvider(_filterRead));
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to mark as read: ${e.toString()}'),
            backgroundColor: AppTheme.dangerRed,
          ),
        );
      }
    }
  }

  Future<void> _markAllAsRead() async {
    try {
      final useCase = ref.read(markAllNotificationsReadUseCaseProvider);
      await useCase();
      ref.invalidate(notificationsProvider(_filterRead));
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('All notifications marked as read'),
            backgroundColor: AppTheme.successGreen,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to mark all as read: ${e.toString()}'),
            backgroundColor: AppTheme.dangerRed,
          ),
        );
      }
    }
  }

  void _handleNotificationTap(domain.Notification notification) {
    // Mark as read if unread
    if (notification.status == domain.NotificationStatus.unread) {
      _markAsRead(notification.id);
    }

    // Navigate based on notification type
    if (notification.data != null) {
      if (notification.type == domain.NotificationType.booking &&
          notification.data!['booking_id'] != null) {
        context.push('/home/booking/${notification.data!['booking_id']}');
      } else if (notification.type == domain.NotificationType.proposal &&
          notification.data!['proposal_id'] != null) {
        context.push('/home/proposal/${notification.data!['proposal_id']}');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final notificationsAsync = ref.watch(notificationsProvider(_filterRead));

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.notifications),
        actions: [
          if (_filterRead == false) // Only show if filtering unread
            IconButton(
              icon: const Icon(Icons.done_all),
              tooltip: 'Mark all as read',
              onPressed: _markAllAsRead,
            ),
        ],
      ),
      body: Column(
        children: [
          // Filter chips
          Container(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                _FilterChip(
                  label: l10n.all,
                  selected: _filterRead == null,
                  onTap: () {
                    setState(() => _filterRead = null);
                  },
                ),
                const SizedBox(width: 8),
                _FilterChip(
                  label: 'Unread',
                  selected: _filterRead == false,
                  onTap: () {
                    setState(() => _filterRead = false);
                  },
                ),
                const SizedBox(width: 8),
                _FilterChip(
                  label: 'Read',
                  selected: _filterRead == true,
                  onTap: () {
                    setState(() => _filterRead = true);
                  },
                ),
              ],
            ),
          ),

          // Notifications list
          Expanded(
            child: RefreshIndicator(
              onRefresh: () async {
                ref.invalidate(notificationsProvider(_filterRead));
              },
              child: notificationsAsync.when(
                data: (notifications) {
                  if (notifications.isEmpty) {
                    return Center(
                      child: EmptyState(
                        message: _filterRead == null
                            ? 'No notifications'
                            : _filterRead == false
                                ? 'No unread notifications'
                                : 'No read notifications',
                        subtitle: _filterRead == null
                            ? 'You\'re all caught up!'
                            : 'Try selecting a different filter',
                        icon: Icons.notifications_none_outlined,
                        iconColor: AppTheme.primaryBlue,
                      ),
                    );
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: notifications.length,
                    itemBuilder: (context, index) {
                      final notification = notifications[index];
                      final isUnread =
                          notification.status == domain.NotificationStatus.unread;

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: _NotificationCard(
                          notification: notification,
                          isUnread: isUnread,
                          icon: _getNotificationIcon(notification.type),
                          iconColor: _getNotificationColor(notification.type),
                          onTap: () => _handleNotificationTap(notification),
                        ),
                      );
                    },
                  );
                },
                loading: () => ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: 5,
                  itemBuilder: (context, index) => const SkeletonNotificationCard(),
                ),
                error: (error, stack) {
                  final errorString = error.toString().toLowerCase();
                  if (errorString.contains('socket') ||
                      errorString.contains('network') ||
                      errorString.contains('connection')) {
                    return NetworkErrorState(
                      onRetry: () =>
                          ref.invalidate(notificationsProvider(_filterRead)),
                    );
                  } else {
                    return ServerErrorState(
                      onRetry: () =>
                          ref.invalidate(notificationsProvider(_filterRead)),
                      errorDetails: error.toString(),
                    );
                  }
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return FilterChip(
      label: Text(label),
      selected: selected,
      onSelected: (_) => onTap(),
      backgroundColor: Colors.white,
      selectedColor: AppTheme.primaryBlue.withOpacity(0.2),
      checkmarkColor: AppTheme.primaryBlue,
      labelStyle: TextStyle(
        color: selected ? AppTheme.primaryBlue : AppTheme.gray700,
        fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
      ),
      side: BorderSide(
        color: selected ? AppTheme.primaryBlue : AppTheme.gray300,
      ),
    );
  }
}

class _NotificationCard extends StatelessWidget {
  final domain.Notification notification;
  final bool isUnread;
  final IconData icon;
  final Color iconColor;
  final VoidCallback onTap;

  const _NotificationCard({
    required this.notification,
    required this.isUnread,
    required this.icon,
    required this.iconColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final timeAgo = _getTimeAgo(notification.createdAt);

    return AppCard(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Icon
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: iconColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: iconColor, size: 24),
              ),
              const SizedBox(width: 12),
              // Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            notification.title,
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: isUnread
                                  ? FontWeight.bold
                                  : FontWeight.w600,
                              color: AppTheme.gray900,
                            ),
                          ),
                        ),
                        if (isUnread)
                          Container(
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(
                              color: AppTheme.primaryBlue,
                              shape: BoxShape.circle,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      notification.body,
                      style: TextStyle(
                        fontSize: 13,
                        color: AppTheme.gray600,
                        fontWeight: isUnread
                            ? FontWeight.w500
                            : FontWeight.normal,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      timeAgo,
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppTheme.gray400,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _getTimeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 7) {
      return DateFormat('MMM dd, yyyy').format(dateTime);
    } else if (difference.inDays > 0) {
      return '${difference.inDays} day${difference.inDays > 1 ? 's' : ''} ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hour${difference.inHours > 1 ? 's' : ''} ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} minute${difference.inMinutes > 1 ? 's' : ''} ago';
    } else {
      return 'Just now';
    }
  }
}

class SkeletonNotificationCard extends StatelessWidget {
  const SkeletonNotificationCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: AppCard(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SkeletonBox(width: 44, height: 44, borderRadius: BorderRadius.circular(10)),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SkeletonBox(width: double.infinity, height: 16),
                    const SizedBox(height: 8),
                    SkeletonBox(width: double.infinity, height: 14),
                    const SizedBox(height: 4),
                    SkeletonBox(width: 100, height: 12),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

