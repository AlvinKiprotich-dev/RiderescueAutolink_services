/// API endpoint constants for the ticketing system
class ApiEndpoints {
  // Authentication
  static const String login = '/auth/login';
  static const String register = '/auth/register';
  static const String forgotPassword = '/auth/forgot-password';
  static const String resetPassword = '/auth/reset-password';

  // Notifications
  static const String notifications = '/notifications';
  static const String notificationById = '/notifications/{id}';
  static const String markNotificationAsRead = '/notifications/{id}/read';
  static const String markAllNotificationsAsRead =
      '/notifications/mark-all-read';
  static const String deleteNotification = '/notifications/{id}';
  static const String unreadNotificationCount = '/notifications/unread-count';
  static const String userNotifications = '/notifications/user/me';

  // User Management
  static const String userProfile = '/users/profile/me';
  static const String changePassword = '/users/change-password';

  // Cloudinary Upload
  static const String cloudinaryUpload = '/uploads/cloudinary';

  // Services
  static const String services = '/services';
  static const String serviceById = '/services/{id}';
  static const String registerService = '/services/register';
  static const String updateService = '/services/{id}';
  static const String deleteService = '/services/{id}';
  static const String serviceDocuments =
      '/services/documents/service/{serviceId}';
  static const String serviceProfiles = '/services/my/profiles';
  static const String serviceAvailability = '/services/{id}/availability';
  static const String servicePendingApproval = '/services/{id}/pending-approval';

  // Bookings
  static const String bookingById = '/bookings/{id}';
  static const String serviceBookings = '/bookings/service/{serviceId}';

  /// Helper method to replace path parameters
  static String replaceParams(String endpoint, Map<String, String> params) {
    String result = endpoint;
    params.forEach((key, value) {
      result = result.replaceAll('{$key}', value);
    });
    return result;
  }
}
