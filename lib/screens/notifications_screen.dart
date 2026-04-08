import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../plugins/providers/app_provider.dart';
import '../plugins/providers/network_provider.dart';
import '../constants/api_endpoints.dart';
import '../models/notification.dart';

class NotificationsScreen extends ConsumerStatefulWidget {
  const NotificationsScreen({super.key});

  @override
  ConsumerState<NotificationsScreen> createState() =>
      _NotificationsScreenState();
}

class _NotificationsScreenState extends ConsumerState<NotificationsScreen>
    with TickerProviderStateMixin {
  String _selectedTab = 'All';
  late TabController _tabController;
  List<NotificationModel> _notifications = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(() {
      if (_tabController.indexIsChanging) {
        final tabNames = ['All', 'Unread', 'Read'];
        setState(() {
          _selectedTab = tabNames[_tabController.index];
        });
        _loadNotificationsWithFilter(_selectedTab);
      }
    });
    // Load notifications with initial filter
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadNotificationsWithFilter(_selectedTab);
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadNotificationsWithFilter(String tab) async {
    setState(() {
      _isLoading = true;
    });

    try {
      final network = ref.read(networkProvider);
      Map<String, dynamic>? query;

      switch (tab) {
        case 'Read':
          query = {'status': 'read'};
          break;
        case 'Unread':
          query = {'status': 'sent'};
          break;
        case 'All':
        default:
          query = null;
          break;
      }

      final response = await network.get(
        ApiEndpoints.userNotifications,
        query: query,
        refresh: true,
      );

      if (response.success && response.data != null) {
        final notificationsData =
            response.data!['notifications'] as List<dynamic>? ?? [];
        final notifications = notificationsData
            .map((notification) => NotificationModel.fromJson(notification))
            .toList();

        setState(() {
          _notifications = notifications;
          _isLoading = false;
        });
      } else {
        setState(() {
          _notifications = [];
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _notifications = [];
        _isLoading = false;
      });
    }
  }

  Future<void> _markNotificationAsRead(String notificationId) async {
    try {
      final network = ref.read(networkProvider);
      final response = await network.submit(
        method: HttpMethod.patch,
        path: ApiEndpoints.markNotificationAsRead.replaceAll(
          '{id}',
          notificationId,
        ),
        body: {},
      );

      if (response.success) {
        // Refresh notifications and unread count
        await _loadNotificationsWithFilter(_selectedTab);
        await ref.read(appNotifierProvider.notifier).refreshUnreadCount();
      }
    } catch (e) {
      // Handle error
    }
  }

  Future<void> _deleteNotification(String notificationId) async {
    try {
      final network = ref.read(networkProvider);
      final response = await network.submit(
        method: HttpMethod.delete,
        path: ApiEndpoints.deleteNotification.replaceAll(
          '{id}',
          notificationId,
        ),
      );

      if (response.success) {
        // Refresh notifications and unread count
        await _loadNotificationsWithFilter(_selectedTab);
        await ref.read(appNotifierProvider.notifier).refreshUnreadCount();
      }
    } catch (e) {
      // Handle error
    }
  }

  Future<void> _markAllAsRead() async {
    try {
      final network = ref.read(networkProvider);
      final response = await network.submit(
        method: HttpMethod.patch,
        path: ApiEndpoints.markAllNotificationsAsRead,
        body: {},
      );

      if (response.success) {
        // Refresh notifications and unread count
        await _loadNotificationsWithFilter(_selectedTab);
        await ref.read(appNotifierProvider.notifier).refreshUnreadCount();
      }
    } catch (e) {
      // Handle error
    }
  }

  @override
  Widget build(BuildContext context) {
    final unreadCount = ref.watch(unreadNotificationCountProvider);

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.background,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: Icon(
            Icons.arrow_back,
            color: Theme.of(context).colorScheme.onBackground,
          ),
        ),
        title: Text(
          'Notifications',
          style: TextStyle(
            color: Theme.of(context).colorScheme.onBackground,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          if (unreadCount > 0)
            TextButton(
              onPressed: _markAllAsRead,
              child: Text(
                'Mark all read',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.primary,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          const SizedBox(width: 10),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Theme.of(context).colorScheme.primary,
          indicatorWeight: 2,
          labelColor: Theme.of(context).colorScheme.primary,
          unselectedLabelColor: Theme.of(
            context,
          ).colorScheme.onBackground.withOpacity(0.6),
          labelStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
          unselectedLabelStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
          tabs: [
            const Tab(text: 'All'),
            Tab(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Unread'),
                  if (unreadCount > 0) ...[
                    const SizedBox(width: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        '$unreadCount',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const Tab(text: 'Read'),
          ],
        ),
      ),
      body: _isLoading
          ? _buildLoadingState(context)
          : _notifications.isEmpty
          ? _buildEmptyState(context)
          : _buildNotificationsList(context, _notifications),
    );
  }

  Widget _buildLoadingState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(height: 16),
          Text(
            'Loading notifications...',
            style: TextStyle(
              color: Theme.of(
                context,
              ).colorScheme.onBackground.withOpacity(0.7),
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    String message;
    String subtitle;

    switch (_selectedTab) {
      case 'Read':
        message = 'No read notifications';
        subtitle = 'You haven\'t read any notifications yet';
        break;
      case 'Unread':
        message = 'No unread notifications';
        subtitle = 'All caught up! No new notifications';
        break;
      case 'All':
      default:
        message = 'No notifications yet';
        subtitle = 'You\'ll see your notifications here';
        break;
    }

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(40),
            ),
            child: Icon(
              Icons.notifications_none,
              size: 40,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            message,
            style: TextStyle(
              color: Theme.of(context).colorScheme.onBackground,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: TextStyle(
              color: Theme.of(
                context,
              ).colorScheme.onBackground.withOpacity(0.7),
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationsList(
    BuildContext context,
    List<NotificationModel> notifications,
  ) {
    return RefreshIndicator(
      onRefresh: () => _loadNotificationsWithFilter(_selectedTab),
      color: Theme.of(context).colorScheme.primary,
      backgroundColor: Theme.of(context).colorScheme.surface,
      child: ListView.builder(
        padding: EdgeInsets.zero,
        itemCount: notifications.length,
        itemBuilder: (context, index) {
          final notification = notifications[index];
          return Dismissible(
            key: Key(notification.id),
            direction: DismissDirection.endToStart,
            confirmDismiss: (direction) =>
                _showDeleteConfirmation(context, notification),
            onDismissed: (direction) {
              _deleteNotification(notification.id);
            },
            background: _buildDismissBackground(context),
            child: _buildNotificationTile(context, notification),
          );
        },
      ),
    );
  }

  Widget _buildDismissBackground(BuildContext context) {
    return Container(
      decoration: BoxDecoration(color: Colors.red),
      child: const Align(
        alignment: Alignment.centerRight,
        child: Padding(
          padding: EdgeInsets.only(right: 20),
          child: Icon(Icons.delete, color: Colors.white, size: 24),
        ),
      ),
    );
  }

  Future<bool?> _showDeleteConfirmation(
    BuildContext context,
    NotificationModel notification,
  ) {
    return showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Notification'),
          content: Text(
            'Are you sure you want to delete this notification? This action cannot be undone.',
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

  Widget _buildNotificationTile(
    BuildContext context,
    NotificationModel notification,
  ) {
    final isRead = !notification.isUnread;
    final type = notification.type;
    final title = notification.title;
    final message = notification.message;
    final timestamp = notification.createdAt;

    IconData icon;
    Color iconColor;

    switch (type.toLowerCase()) {
      case 'service_approved':
        icon = Icons.check_circle;
        iconColor = Colors.green;
        break;
      case 'service_rejected':
        icon = Icons.cancel;
        iconColor = Colors.red;
        break;
      case 'new_request':
        icon = Icons.add_circle;
        iconColor = Colors.blue;
        break;
      case 'payment_received':
        icon = Icons.payment;
        iconColor = Colors.green;
        break;
      case 'service_update':
        icon = Icons.update;
        iconColor = Colors.orange;
        break;
      case 'booking_status_update':
        icon = Icons.schedule;
        iconColor = Colors.purple;
        break;
      case 'system_message':
        icon = Icons.info;
        iconColor = Colors.grey;
        break;
      default:
        icon = Icons.info;
        iconColor = Theme.of(context).colorScheme.primary;
    }

    return GestureDetector(
      onTap: () {
        if (!isRead) {
          _markNotificationAsRead(notification.id);
        }
      },
      child: Container(
        decoration: BoxDecoration(
          color: isRead
              ? Theme.of(context).colorScheme.background
              : Theme.of(context).colorScheme.primary.withOpacity(0.02),
          border: Border(
            bottom: BorderSide(
              color: Theme.of(context).colorScheme.outline.withOpacity(0.1),
              width: 1,
            ),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Icon
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: iconColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Icon(icon, color: iconColor, size: 24),
              ),
              const SizedBox(width: 16),
              // Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onBackground,
                        fontSize: 16,
                        fontWeight: isRead ? FontWeight.w500 : FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      message,
                      style: TextStyle(
                        color: Theme.of(
                          context,
                        ).colorScheme.onBackground.withOpacity(0.7),
                        fontSize: 14,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              // Timestamp and unread indicator
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    _formatTimestamp(timestamp),
                    style: TextStyle(
                      color: Theme.of(
                        context,
                      ).colorScheme.onBackground.withOpacity(0.5),
                      fontSize: 12,
                    ),
                  ),
                  if (!isRead) ...[
                    const SizedBox(height: 4),
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primary,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }
}
