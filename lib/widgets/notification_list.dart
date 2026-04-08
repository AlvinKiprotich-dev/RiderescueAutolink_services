import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riderescue_services/models/notification.dart';
import 'package:riderescue_services/plugins/providers/app_provider.dart';
import 'package:intl/intl.dart';

class NotificationList extends ConsumerStatefulWidget {
  const NotificationList({super.key});

  @override
  ConsumerState<NotificationList> createState() => _NotificationListState();
}

class _NotificationListState extends ConsumerState<NotificationList> {
  @override
  void initState() {
    super.initState();
    // Refresh notifications when the list is opened
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(appNotifierProvider.notifier).refreshNotifications();
    });
  }

  @override
  Widget build(BuildContext context) {
    final notifications = ref.watch(notificationsProvider);
    final isLoading = ref.watch(isLoadingNotificationsProvider);
    final unreadCount = ref.watch(unreadNotificationCountProvider);

    return Container(
      height: MediaQuery.of(context).size.height * 0.8,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Icon(
                Icons.notifications_outlined,
                color: Theme.of(context).colorScheme.primary,
                size: 24,
              ),
              const SizedBox(width: 12),
              Text(
                'Notifications',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              const Spacer(),
              if (unreadCount > 0)
                TextButton.icon(
                  onPressed: _markAllAsRead,
                  icon: const Icon(Icons.done_all, size: 16),
                  label: const Text('Mark all read'),
                  style: TextButton.styleFrom(
                    foregroundColor: Theme.of(context).colorScheme.primary,
                  ),
                ),
              IconButton(
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(Icons.close),
                tooltip: 'Close',
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Content
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : notifications.isEmpty
                ? _buildEmptyState()
                : _buildNotificationList(notifications),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.notifications_none_outlined,
            size: 64,
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          Text(
            'No notifications yet',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'You\'ll see notifications here when you receive them',
            style: TextStyle(
              fontSize: 14,
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationList(List<NotificationModel> notifications) {
    return RefreshIndicator(
      onRefresh: () async {
        await ref.read(appNotifierProvider.notifier).refreshNotifications();
      },
      child: ListView.builder(
        itemCount: notifications.length,
        itemBuilder: (context, index) {
          final notification = notifications[index];
          return Dismissible(
            key: Key(notification.id),
            direction: DismissDirection.endToStart,
            background: Container(
              alignment: Alignment.centerRight,
              padding: const EdgeInsets.only(right: 20),
              color: Colors.red,
              child: const Icon(Icons.delete, color: Colors.white),
            ),
            confirmDismiss: (direction) async {
              return await _showDeleteConfirmation(notification);
            },
            onDismissed: (direction) {
              ref
                  .read(appNotifierProvider.notifier)
                  .deleteNotification(notification.id);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('${notification.title} deleted'),
                  action: SnackBarAction(
                    label: 'Undo',
                    onPressed: () {
                      // Note: In a real app, you'd want to implement undo functionality
                      // For now, just refresh the list
                      ref
                          .read(appNotifierProvider.notifier)
                          .refreshNotifications();
                    },
                  ),
                ),
              );
            },
            child: _buildNotificationTile(notification),
          );
        },
      ),
    );
  }

  Widget _buildNotificationTile(NotificationModel notification) {
    final isUnread = notification.isUnread;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: isUnread
            ? Theme.of(context).colorScheme.primary.withOpacity(0.05)
            : Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isUnread
              ? Theme.of(context).colorScheme.primary.withOpacity(0.2)
              : Theme.of(context).colorScheme.outline.withOpacity(0.1),
        ),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: _getNotificationColor(notification.type).withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            _getNotificationIcon(notification.type),
            color: _getNotificationColor(notification.type),
            size: 24,
          ),
        ),
        title: Text(
          notification.title,
          style: TextStyle(
            fontWeight: isUnread ? FontWeight.bold : FontWeight.w500,
            fontSize: 16,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              notification.message,
              style: TextStyle(
                fontSize: 14,
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 8),
            Text(
              _formatDate(notification.createdAt),
              style: TextStyle(
                fontSize: 12,
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
              ),
            ),
          ],
        ),
        trailing: isUnread
            ? Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary,
                  shape: BoxShape.circle,
                ),
              )
            : null,
        onTap: () {
          if (isUnread) {
            ref
                .read(appNotifierProvider.notifier)
                .markNotificationAsRead(notification.id);
          }
          // You can add navigation logic here based on notification type
          _handleNotificationTap(notification);
        },
      ),
    );
  }

  Color _getNotificationColor(String type) {
    switch (type.toLowerCase()) {
      case 'service_approved':
        return Colors.green;
      case 'service_rejected':
        return Colors.red;
      case 'new_request':
        return Colors.blue;
      case 'payment_received':
        return Colors.orange;
      case 'booking_status_update':
        return Colors.teal;
      case 'system_message':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }

  IconData _getNotificationIcon(String type) {
    switch (type.toLowerCase()) {
      case 'service_approved':
        return Icons.check_circle;
      case 'service_rejected':
        return Icons.error;
      case 'new_request':
        return Icons.assignment;
      case 'payment_received':
        return Icons.payment;
      case 'booking_status_update':
        return Icons.update;
      case 'system_message':
        return Icons.info;
      default:
        return Icons.notifications;
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays > 0) {
      return DateFormat('MMM d, y').format(date);
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }

  void _handleNotificationTap(NotificationModel notification) {
    // Handle navigation based on notification type
    switch (notification.type.toLowerCase()) {
      case 'service_approved':
      case 'service_rejected':
        // Navigate to service profile
        Navigator.of(context).pop();
        // You can add navigation logic here
        break;
      case 'new_request':
        // Navigate to booking details
        Navigator.of(context).pop();
        // You can add navigation logic here
        break;
      case 'booking_status_update':
        // Navigate to booking details
        Navigator.of(context).pop();
        // You can add navigation logic here
        break;
      case 'payment_received':
        // Navigate to payment details
        Navigator.of(context).pop();
        // You can add navigation logic here
        break;
      default:
        // Just close the modal for other types
        Navigator.of(context).pop();
    }
  }

  Future<void> _markAllAsRead() async {
    await ref.read(appNotifierProvider.notifier).markAllNotificationsAsRead();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('All notifications marked as read')),
      );
    }
  }

  Future<bool?> _showDeleteConfirmation(NotificationModel notification) async {
    return await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Notification'),
          content: Text(
            'Are you sure you want to delete "${notification.title}"?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }
}
