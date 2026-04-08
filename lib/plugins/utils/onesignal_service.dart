import 'package:flutter/foundation.dart';
import 'dart:io';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:riderescue_services/constants/onesignal.dart';

class OneSignalService {
  static final OneSignalService _instance = OneSignalService._internal();
  factory OneSignalService() => _instance;
  OneSignalService._internal();

  // Callback function to handle notification events
  Function(Map<String, dynamic>)? _onNotificationEvent;

//check if device is mobile
   bool get isMobile {
    if (kIsWeb) return false;
    try {
      return Platform.isAndroid || Platform.isIOS;
    } catch (_) {
      return false;
    }
  }

  /// Set the notification event callback
  void setNotificationEventCallback(Function(Map<String, dynamic>) callback) {
    _onNotificationEvent = callback;
  }

  /// Initialize OneSignal with the app ID
  Future<void> initialize() async {
    //check if device is mobile
    if (!isMobile) {
      debugPrint("OneSignal initialization skipped on Web/Desktop");
      return;
    }
    // Initialize OneSignal
    OneSignal.initialize(oneSignalAppId);

    // Request notification permission
    OneSignal.Notifications.requestPermission(true);

    // Set up notification handlers
    _setupNotificationHandlers();
  }

  /// Set up notification handlers
  void _setupNotificationHandlers() {
    if (!isMobile) return;
    // Handle notification received while app is in foreground
    OneSignal.Notifications.addForegroundWillDisplayListener((event) {

      // Create notification event data
      final eventData = {
        'type': 'notification_received',
        'data': {
          'id': event.notification.notificationId,
          'title': event.notification.title,
          'message': event.notification.body,
          'type':
              event.notification.additionalData?['type'] ?? 'system_message',
          'data': event.notification.additionalData ?? {},
          'status': 'sent',
          'sentAt': DateTime.now().toIso8601String(),
          'createdAt': DateTime.now().toIso8601String(),
          'updatedAt': DateTime.now().toIso8601String(),
        },
      };

      // Trigger the callback if set
      _onNotificationEvent?.call(eventData);
    });

    // Handle notification opened
    OneSignal.Notifications.addClickListener((event) {

      // Create notification opened event data
      final eventData = {
        'type': 'opened_notification',
        'data': {
          'notification_id': event.notification.notificationId,
          'title': event.notification.title,
          'message': event.notification.body,
          'type':
              event.notification.additionalData?['type'] ?? 'system_message',
          'additional_data': event.notification.additionalData ?? {},
        },
      };

      // Trigger the callback if set
      _onNotificationEvent?.call(eventData);

      // Handle notification click - navigate to specific screen based on notification data
      _handleNotificationClick(event.notification);
    });
  }

  /// Subscribe user to OneSignal using their user ID as external user ID
  Future<bool> subscribeUser(String userId) async {
    if (!isMobile) {
      debugPrint("subscribeUser skipped on Web");
      return false;
    }
    // Set external user ID (this is how you identify the user in OneSignal)
    await OneSignal.login(userId);

    return true;
  }

  /// Unsubscribe user from OneSignal
  Future<bool> unsubscribeUser() async {
    if (!isMobile) {
      debugPrint("unsubscribeUser skipped on Web");
      return false;
    }
    await OneSignal.logout();
    return true;
  }

  /// Get current player ID
  Future<String?> getPlayerId() async {
    if (!isMobile) return null;
    return  OneSignal.User.pushSubscription.id;
  }

  /// Check if user is subscribed
  Future<bool> isUserSubscribed() async {
    if (!isMobile) return false;
    final playerId =  OneSignal.User.pushSubscription.id;
    return playerId != null && playerId.isNotEmpty;
  }

  /// Handle notification click based on notification data
  void _handleNotificationClick(OSNotification notification) {
    if (!isMobile) return;
    final data = notification.additionalData;

    if (data != null) {
      // Handle different types of notifications based on data
      final type = data['type'] as String?;

      switch (type) {
        case 'service_approved':
          // Navigate to service details or show approval message
          
          break;
        case 'service_rejected':
          // Navigate to service details or show rejection message
          break;
        case 'new_request':
          // Navigate to requests screen
          break;
        case 'payment_received':
          // Navigate to payments screen
          break;
        default:
          // Handle generic notification
          break;
      }
    }
  }

  /// Send local notification (for testing purposes)
  Future<void> sendLocalNotification({
    required String title,
    required String body,
    Map<String, dynamic>? additionalData,
  }) async {
    // Note: OneSignal doesn't provide a direct method to send local notifications
    // This would typically be handled through the backend or using flutter_local_notifications
  }

  /// Set notification categories for different types of notifications
  Future<void> setNotificationCategories() async {
    // Note: OneSignal categories are typically set through the OneSignal dashboard
    // or through the backend when sending notifications
  }

  /// Enable/disable notifications
  Future<void> setNotificationsEnabled(bool enabled) async {
    if (!isMobile) return;
    if (enabled) {
      await OneSignal.Notifications.requestPermission(true);
    } else {
      // Note: OneSignal doesn't provide a direct way to disable notifications
      // This would typically be handled through device settings
    }
  }
}

// Global instance for easy access
final oneSignalService = OneSignalService();
