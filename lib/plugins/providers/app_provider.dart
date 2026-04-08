import 'dart:convert';
import 'dart:developer' as dev;
import 'package:flutter/material.dart';
import 'package:riderescue_services/models/service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:riderescue_services/constants/local_storage.dart';
import 'package:riderescue_services/models/user.dart';
import 'package:riderescue_services/models/notification.dart';
import 'package:riderescue_services/plugins/utils/error_handler.dart';
import 'package:riderescue_services/plugins/utils/network_service.dart';
import 'package:riderescue_services/plugins/utils/onesignal_service.dart';
import 'package:riderescue_services/plugins/utils/service_availability_service.dart';
import 'package:riderescue_services/constants/api_endpoints.dart';
import 'package:riderescue_services/plugins/utils/background_service.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';

class AppState {
  final User? user;
  final String? authToken;
  final bool isInternetConnected;
  final bool isLoading;
  final String? error;
  final ThemeMode themeMode;
  final List<Service> serviceProfiles;
  final Service? activeService;
  final bool isLive;
  final Map<String, dynamic>? serviceFormState;
  final bool isServiceAvailable;
  final List<Map<String, dynamic>> availableServices;
  final int unreadNotificationCount;
  final bool shouldShowServiceProgress;

  const AppState({
    this.user,
    this.activeService,
    this.isLive = false,
    this.authToken,
    this.isInternetConnected = true,
    this.isLoading = false,
    this.error,
    this.themeMode = ThemeMode.system,
    this.serviceProfiles = const [],
    this.serviceFormState,
    this.unreadNotificationCount = 0,
    this.isServiceAvailable = false,
    this.availableServices = const [],
    this.shouldShowServiceProgress = true,
  });

  bool get isAuthenticated => authToken != null && user != null;

  AppState copyWith({
    User? user,
    String? authToken,
    bool? isInternetConnected,
    bool? isLoading,
    String? error,
    ThemeMode? themeMode,
    List<Service>? serviceProfiles,
    Service? activeService,
    bool? isLive,
    Map<String, dynamic>? serviceFormState,
    int? unreadNotificationCount,
    bool? isServiceAvailable,
    List<Map<String, dynamic>>? availableServices,
    bool? shouldShowServiceProgress,
  }) {
    return AppState(
      user: user ?? this.user,
      authToken: authToken ?? this.authToken,
      isInternetConnected: isInternetConnected ?? this.isInternetConnected,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      themeMode: themeMode ?? this.themeMode,
      serviceProfiles: serviceProfiles ?? this.serviceProfiles,
      activeService: activeService ?? this.activeService,
      isLive: isLive ?? this.isLive,
      serviceFormState: serviceFormState ?? this.serviceFormState,
      unreadNotificationCount:
          unreadNotificationCount ?? this.unreadNotificationCount,
      isServiceAvailable: isServiceAvailable ?? this.isServiceAvailable,
      availableServices: availableServices ?? this.availableServices,
      shouldShowServiceProgress:
          shouldShowServiceProgress ?? this.shouldShowServiceProgress,
    );
  }
}

class AppNotifier extends StateNotifier<AppState> {
  final Ref ref;
  AppNotifier(this.ref) : super(const AppState()) {
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    _initializeConnectionStatus();
    await _loadStoredAuth();
    await _loadTheme();
    await _loadActiveService();
    await _loadLiveStatus();
    await _loadUnreadNotificationCount(); // Load unread count on app start
    await _loadServiceProfilesFromCache(); // Load cached service profiles first

    // Set up OneSignal notification event callback
    oneSignalService.setNotificationEventCallback(handleOneSignalEvent);

    // Only fetch service profiles if user is properly authenticated
    if (state.isAuthenticated &&
        state.authToken != null &&
        state.authToken!.isNotEmpty) {
      await _fetchServiceProfiles();
    }

    // Set up authentication state listener
    _setupAuthStateListener();
  }

  /// Load service profiles from SharedPreferences cache
  Future<void> _loadServiceProfilesFromCache() async {
    await catchErrorVoid(
      operation: () async {
        final prefs = await SharedPreferences.getInstance();
        final cachedProfilesJson = prefs.getString(
          LocalStorageKeys.serviceProfiles,
        );

        if (cachedProfilesJson != null) {
          try {
            final profilesData =
                json.decode(cachedProfilesJson) as List<dynamic>;
            final cachedProfiles = profilesData
                .map((profile) => Service.fromJson(profile))
                .toList();

            state = state.copyWith(serviceProfiles: cachedProfiles);

            // Set active service if none is set
            if (state.activeService == null && cachedProfiles.isNotEmpty) {
              await setActiveService(cachedProfiles.first);
            }
          } catch (e) {
            // If cached data is corrupted, clear it
            await prefs.remove(LocalStorageKeys.serviceProfiles);
          }
        }
      },
      onError: (error) {
        // Clear corrupted cache on error
        _clearServiceProfilesCache();
      },
    );
  }

  /// Save service profiles to SharedPreferences cache
  Future<void> _saveServiceProfilesToCache(List<Service> profiles) async {
    await catchErrorVoid(
      operation: () async {
        final prefs = await SharedPreferences.getInstance();
        final profilesJson = json.encode(
          profiles.map((profile) => profile.toJson()).toList(),
        );
        await prefs.setString(LocalStorageKeys.serviceProfiles, profilesJson);
      },
      onError: (error) {
        state = state.copyWith(
          error: 'Failed to cache service profiles: ${error.toString()}',
        );
      },
    );
  }

  /// Clear service profiles cache
  Future<void> _clearServiceProfilesCache() async {
    await catchErrorVoid(
      operation: () async {
        final prefs = await SharedPreferences.getInstance();
        await prefs.remove(LocalStorageKeys.serviceProfiles);
      },
      onError: (error) {
        // Ignore errors when clearing cache
      },
    );
  }

  /// Toggle service availability
  Future<void> toggleServiceAvailability(bool isAvailable) async {
    if (!state.isAuthenticated ||
        state.activeService == null ||
        state.activeService!.id == null ||
        state.authToken == null) {
      return;
    }

    try {
      final success = await serviceAvailabilityService
          .toggleServiceAvailability(
            serviceId: state.activeService!.id!,
            isAvailable: isAvailable,
            authToken: state.authToken!,
            isConnected: state.isInternetConnected,
          );

      if (success) {
        state = state.copyWith(isServiceAvailable: isAvailable);

        // Notify background service about live/offline state
        if (isAvailable) {
          await backgroundService.userWentLive();
        } else {
          await backgroundService.userWentOffline();
        }
      }
    } catch (e) {
      state = state.copyWith(
        error: 'Failed to toggle service availability: ${e.toString()}',
      );
    }
  }

  Future<void> _fetchServiceProfilesFresh() async {
    if (!state.isAuthenticated) return;

    state = state.copyWith(isLoading: true, error: null);

    await catchErrorVoid(
      operation: () async {
        // Ensure token is loaded and valid before making request
        if (state.authToken == null || state.authToken!.isEmpty) {
          state = state.copyWith(
            isLoading: false,
            error: 'Authentication token not available. Please login again.',
          );
          await logout();
          return;
        }

        // Create network handler with current auth token directly (avoid circular dependency)
        final networkHandler = NetworkHandler(
          isConnected: state.isInternetConnected,
          authToken: state.authToken,
        );

        // Verify authentication is valid
        if (!networkHandler.isAuthenticated) {
          state = state.copyWith(
            isLoading: false,
            error: 'Authentication token is invalid. Please login again.',
          );
          await logout();
          return;
        }

        final response = await networkHandler.getRequest(
          endpoint: ApiEndpoints.serviceProfiles,
          requiresAuth: true, // Explicitly require authentication
        );

        if (response.containsKey('error')) {
          final error = response['error'] as String;
          if (error.contains('401') ||
              error.contains('Unauthorized') ||
              error.contains('Authentication required')) {
            // Handle 401 - user needs to re-authenticate
            state = state.copyWith(
              isLoading: false,
              error: 'Session expired. Please login again.',
            );
            // Trigger logout
            await logout();
            return;
          }
          throw Exception(error);
        }

        if (response['services'] != null) {
          final servicesData = response['services'] as List<dynamic>;
          final services = servicesData
              .map((service) => Service.fromJson(service))
              .toList();

          // Update state with fresh data from network
          await setServiceProfiles(services);

          // Save fresh data to cache for offline access
          await _saveServiceProfilesToCache(services);
        }

        state = state.copyWith(isLoading: false);
      },
      onError: (error) {
        state = state.copyWith(
          isLoading: false,
          error: 'Failed to fetch service profiles: ${error.toString()}',
        );
      },
    );
  }

  Future<void> _fetchServiceProfiles() async {
    if (!state.isAuthenticated) return;

    state = state.copyWith(isLoading: true, error: null);

    await catchErrorVoid(
      operation: () async {
        // Ensure token is loaded and valid before making request
        if (state.authToken == null || state.authToken!.isEmpty) {
          state = state.copyWith(
            isLoading: false,
            error: 'Authentication token not available. Please login again.',
          );
          await logout();
          return;
        }

        // Create network handler with current auth token directly
        final networkHandler = NetworkHandler(
          isConnected: state.isInternetConnected,
          authToken: state.authToken,
        );

        // Verify authentication is valid
        if (!networkHandler.isAuthenticated) {
          state = state.copyWith(
            isLoading: false,
            error: 'Authentication token is invalid. Please login again.',
          );
          await logout();
          return;
        }

        final response = await networkHandler.getRequest(
          endpoint: ApiEndpoints.serviceProfiles,
          requiresAuth: true, // Explicitly require authentication
        );

        if (response.containsKey('error')) {
          final error = response['error'] as String;
          if (error.contains('401') ||
              error.contains('Unauthorized') ||
              error.contains('Authentication required')) {
            // Handle 401 - user needs to re-authenticate
            state = state.copyWith(
              isLoading: false,
              error: 'Session expired. Please login again.',
            );
            // Trigger logout
            await logout();
            return;
          }
          throw Exception(error);
        }

        if (response['services'] != null) {
          final servicesData = response['services'] as List<dynamic>;
          final services = servicesData
              .map((service) => Service.fromJson(service))
              .toList();

          // Update state with fresh data from network
          await setServiceProfiles(services);

          // Save to cache for offline access
          await _saveServiceProfilesToCache(services);
        }

        state = state.copyWith(isLoading: false);
      },
      onError: (error) {
        state = state.copyWith(
          isLoading: false,
          error: 'Failed to fetch service profiles: ${error.toString()}',
        );
      },
    );
  }

  Future<void> refreshServiceProfiles() async {
    await _fetchServiceProfiles();
  }

  /// Refresh service profiles with fresh data from server (ignores cache)
  Future<void> refreshServiceProfilesFresh() async {
    await _fetchServiceProfilesFresh();
  }

  Future<void> login({required String token, required User user}) async {
    state = state.copyWith(isLoading: true, error: null);

    await catchErrorVoid(
      operation: () async {
        await _saveAuthData(token, user);
        state = state.copyWith(authToken: token, user: user, isLoading: false);

        // Subscribe user to OneSignal for push notifications
        await _subscribeUserToNotifications(user);
        // Reload app data after successful login
        await _reloadAppData();
      },
      onError: (error) {
        state = state.copyWith(
          isLoading: false,
          error: 'Failed to save authentication data',
        );
      },
    );
  }

  Future<void> setServiceProfiles(List<Service> serviceProfiles) async {
    state = state.copyWith(serviceProfiles: serviceProfiles);

    if (state.activeService == null && serviceProfiles.isNotEmpty) {
      await setActiveService(serviceProfiles.first);
    }
  }

  /// Handle service profile switching
  Future<void> switchServiceProfile(Service newService) async {
    // If currently live with a different service, go offline first
    if (state.activeService != null &&
        state.activeService!.id != newService.id &&
        state.isServiceAvailable) {
      await toggleServiceAvailability(false);
    }

    await setActiveService(newService);
  }

  Future<void> setActiveService(Service service) async {
    await catchErrorVoid(
      operation: () async {
        // If there's a currently active service and user is live, go offline first
        if (state.activeService != null && state.isServiceAvailable) {
          await toggleServiceAvailability(false);
        }

        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(
          LocalStorageKeys.activeService,
          json.encode(service.toJson()),
        );
        state = state.copyWith(activeService: service);
      },
      onError: (error) {
        state = state.copyWith(error: 'Failed to save active service');
      },
    );
  }

  Future<void> setLiveStatus(bool isLive) async {
    await catchErrorVoid(
      operation: () async {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool(LocalStorageKeys.isLive, isLive);
        state = state.copyWith(isLive: isLive);
      },
      onError: (error) {
        state = state.copyWith(error: 'Failed to save live status');
      },
    );
  }

  Future<void> logout() async {
    state = state.copyWith(isLoading: true, error: null);

    await catchErrorVoid(
      operation: () async {
        // Unsubscribe user from OneSignal notifications
        await _unsubscribeUserFromNotifications();
        await _clearAuthData();
        await _clearThemeData();
        await _clearServiceData();
        await _clearServiceProfilesCache(); // Clear service profiles cache
        await clearServiceFormState();

        // Reset state to initial unauthenticated state
        state = AppState(
          isInternetConnected: state.isInternetConnected,
          themeMode: state.themeMode,
        );

        // Clear any cached data and reset providers
        _clearAppData();
      },
      onError: (error) {
        state = state.copyWith(isLoading: false, error: 'Failed to logout');
      },
    );
  }

  /// Subscribe user to OneSignal notifications using their user ID
  Future<void> _subscribeUserToNotifications(User user) async {
    if (user.id.isNotEmpty) {
      // Set up notification event callback
      oneSignalService.setNotificationEventCallback(handleOneSignalEvent);

      final success = await oneSignalService.subscribeUser(user.id);
      if (success) {
      } else {}
    } else {}
  }

  /// Unsubscribe user from OneSignal notifications
  Future<void> _unsubscribeUserFromNotifications() async {
    final success = await oneSignalService.unsubscribeUser();
    if (success) {
    } else {}
  }

  Future<void> updateUserDetails(User updatedUser) async {
    if (!state.isAuthenticated) return;

    state = state.copyWith(isLoading: true, error: null);

    await catchErrorVoid(
      operation: () async {
        await _saveUserData(updatedUser);
        state = state.copyWith(user: updatedUser, isLoading: false);
      },
      onError: (error) {
        state = state.copyWith(
          isLoading: false,
          error: 'Failed to update user details',
        );
      },
    );
  }

  void _initializeConnectionStatus() {
    InternetConnection().onStatusChange.listen((status) {
      updateInternetStatus(status == InternetStatus.connected);
    });
  }

  void updateInternetStatus(bool status) {
    state = state.copyWith(isInternetConnected: status);
  }

  Future<void> _loadStoredAuth() async {
    await catchErrorVoid(
      operation: () async {
        final prefs = await SharedPreferences.getInstance();
        final token = prefs.getString(LocalStorageKeys.authToken);
        final userJson = prefs.getString(LocalStorageKeys.user);

        if (token != null && userJson != null) {
          final userData = User.fromJson(
            Map<String, dynamic>.from(json.decode(userJson)),
          );
          state = state.copyWith(authToken: token, user: userData);

          // Subscribe user to OneSignal notifications if they're already authenticated
          await _subscribeUserToNotifications(userData);
        }
      },
      onError: (error) {
        state = state.copyWith(error: 'Failed to load stored authentication');
      },
    );
  }

  Future<void> _saveAuthData(String token, User user) async {
    final prefs = await SharedPreferences.getInstance();
    await Future.wait([
      prefs.setString(LocalStorageKeys.authToken, token),
      _saveUserData(user),
    ]);
  }

  Future<void> _saveUserData(User user) async {
    await catchErrorVoid(
      operation: () async {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(
          LocalStorageKeys.user,
          json.encode(user.toJson()),
        );
      },
      onError: (error) {
        throw Exception('Failed to save user data: $error');
      },
    );
  }

  Future<void> _clearAuthData() async {
    final prefs = await SharedPreferences.getInstance();
    await Future.wait([
      prefs.remove(LocalStorageKeys.authToken),
      prefs.remove(LocalStorageKeys.user),
    ]);
  }

  Future<void> _clearServiceData() async {
    final prefs = await SharedPreferences.getInstance();
    await Future.wait([
      prefs.remove(LocalStorageKeys.activeService),
      prefs.remove(LocalStorageKeys.isLive),
      prefs.remove(LocalStorageKeys.serviceProfileForm),
      prefs.remove(
        LocalStorageKeys.serviceProfiles,
      ), // Clear service profiles cache
    ]);
  }

  void clearError() {
    state = state.copyWith(error: null);
  }

  Future<void> _loadTheme() async {
    await catchErrorVoid(
      operation: () async {
        final prefs = await SharedPreferences.getInstance();
        final themeString = prefs.getString(LocalStorageKeys.theme) ?? 'system';
        ThemeMode mode;
        switch (themeString) {
          case 'light':
            mode = ThemeMode.light;
            break;
          case 'dark':
            mode = ThemeMode.dark;
            break;
          default:
            mode = ThemeMode.system;
        }
        state = state.copyWith(themeMode: mode);
      },
      onError: (error) {
        state = state.copyWith(themeMode: ThemeMode.system);
      },
    );
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    await catchErrorVoid(
      operation: () async {
        await _saveThemeData(mode);
        state = state.copyWith(themeMode: mode);
      },
      onError: (error) {
        state = state.copyWith(error: 'Failed to save theme preference');
      },
    );
  }

  Future<void> _saveThemeData(ThemeMode mode) async {
    await catchErrorVoid(
      operation: () async {
        final prefs = await SharedPreferences.getInstance();
        String themeString = 'system';
        switch (mode) {
          case ThemeMode.light:
            themeString = 'light';
            break;
          case ThemeMode.dark:
            themeString = 'dark';
            break;
          case ThemeMode.system:
            themeString = 'system';
            break;
        }
        await prefs.setString(LocalStorageKeys.theme, themeString);
      },
      onError: (error) {
        throw Exception('Failed to save theme data: $error');
      },
    );
  }

  Future<void> _clearThemeData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(LocalStorageKeys.theme);
  }

  Future<void> refreshTheme() async {
    await _loadTheme();
  }

  Future<void> resetThemeToDefault() async {
    await setThemeMode(ThemeMode.system);
  }

  Future<void> _loadActiveService() async {
    await catchErrorVoid(
      operation: () async {
        final prefs = await SharedPreferences.getInstance();
        final serviceJson = prefs.getString(LocalStorageKeys.activeService);

        if (serviceJson != null) {
          final serviceData = Service.fromJson(
            Map<String, dynamic>.from(json.decode(serviceJson)),
          );
          state = state.copyWith(activeService: serviceData);
        }
      },
      onError: (error) {
        state = state.copyWith(error: 'Failed to load active service');
      },
    );
  }

  Future<void> _loadLiveStatus() async {
    await catchErrorVoid(
      operation: () async {
        final prefs = await SharedPreferences.getInstance();
        final isLive = prefs.getBool(LocalStorageKeys.isLive) ?? false;
        state = state.copyWith(isLive: isLive);
      },
      onError: (error) {
        state = state.copyWith(error: 'Failed to load live status');
      },
    );
  }

  /// Save service form state
  Future<void> saveServiceFormState(Map<String, dynamic> formData) async {
    await catchErrorVoid(
      operation: () async {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(
          LocalStorageKeys.serviceProfileForm,
          json.encode(formData),
        );
        state = state.copyWith(serviceFormState: formData);
      },
      onError: (error) {
        state = state.copyWith(error: 'Failed to save form state');
      },
    );
  }

  /// Load service form state
  Future<void> loadServiceFormState() async {
    await catchErrorVoid(
      operation: () async {
        final prefs = await SharedPreferences.getInstance();
        final formStateJson = prefs.getString(
          LocalStorageKeys.serviceProfileForm,
        );

        if (formStateJson != null) {
          final formData = Map<String, dynamic>.from(
            json.decode(formStateJson),
          );
          state = state.copyWith(serviceFormState: formData);
        }
      },
      onError: (error) {
        state = state.copyWith(error: 'Failed to load form state');
      },
    );
  }

  /// Clear service form state
  Future<void> clearServiceFormState() async {
    await catchErrorVoid(
      operation: () async {
        final prefs = await SharedPreferences.getInstance();
        await prefs.remove(LocalStorageKeys.serviceProfileForm);
        state = state.copyWith(serviceFormState: null);
      },
      onError: (error) {
        state = state.copyWith(error: 'Failed to clear form state');
      },
    );
  }

  /// Reload all app data after authentication changes
  Future<void> _reloadAppData() async {
    await catchErrorVoid(
      operation: () async {
        // Reload service profiles
        await _fetchServiceProfiles();

        // Reload active service if needed
        if (state.activeService == null && state.serviceProfiles.isNotEmpty) {
          await _loadActiveService();
        }

        // Reload live status
        await _loadLiveStatus();
      },
      onError: (error) {
        state = state.copyWith(error: 'Failed to reload app data');
      },
    );
  }

  /// Clear all app data and reset state
  void _clearAppData() {
    // Clear service profiles
    state = state.copyWith(
      serviceProfiles: const [],
      activeService: null,
      isLive: false,
      serviceFormState: null,
    );
  }

  /// Update authentication token and reload data
  Future<void> updateAuthToken(String newToken) async {
    if (state.authToken == newToken) return; // No change needed

    await catchErrorVoid(
      operation: () async {
        // Update token in storage
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(LocalStorageKeys.authToken, newToken);

        // Update state
        state = state.copyWith(authToken: newToken);

        // Reload app data with new token
        await _reloadAppData();
      },
      onError: (error) {
        state = state.copyWith(error: 'Failed to update authentication token');
      },
    );
  }

  /// Handle token refresh from API responses
  Future<void> handleTokenRefresh(String? newToken) async {
    if (newToken != null &&
        newToken.isNotEmpty &&
        newToken != state.authToken) {
      await updateAuthToken(newToken);
    }
  }

  /// Check if current token is valid and refresh if needed
  Future<bool> validateAndRefreshToken() async {
    if (!state.isAuthenticated || state.authToken == null) return false;

    try {
      // Create network handler to test token validity
      final networkHandler = NetworkHandler(
        isConnected: state.isInternetConnected,
        authToken: state.authToken,
      );

      // Test token with a simple API call
      final response = await networkHandler.getRequest(
        endpoint: ApiEndpoints.userProfile,
        requiresAuth: true,
      );

      // Check if response contains a new token
      if (response.containsKey('token')) {
        await handleTokenRefresh(response['token'] as String?);
      }

      return !response.containsKey('error');
    } catch (e) {
      // Token is invalid, trigger logout
      await logout();
      return false;
    }
  }

  /// Set up listener for authentication state changes
  void _setupAuthStateListener() {
    // This method sets up internal state tracking
    // The actual listening is done through Riverpod's reactive system
    // When authToken or user changes, the UI will automatically rebuild
  }

  /// Force refresh all app data
  Future<void> refreshAppData() async {
    if (!state.isAuthenticated) return;

    await catchErrorVoid(
      operation: () async {
        state = state.copyWith(isLoading: true, error: null);

        // Refresh all data
        await _reloadAppData();

        state = state.copyWith(isLoading: false);
      },
      onError: (error) {
        state = state.copyWith(
          isLoading: false,
          error: 'Failed to refresh app data',
        );
      },
    );
  }

  /// Load unread notification count
  Future<void> _loadUnreadNotificationCount() async {
    if (!state.isAuthenticated) return;

    await catchErrorVoid(
      operation: () async {
        final networkHandler = NetworkHandler(
          isConnected: state.isInternetConnected,
          authToken: state.authToken,
        );

        if (!networkHandler.isAuthenticated) {
          state = state.copyWith(unreadNotificationCount: 0);
          return;
        }

        final response = await networkHandler.getRequest(
          endpoint: ApiEndpoints.unreadNotificationCount,
          requiresAuth: true,
        );

        if (response.containsKey('error')) {
          final error = response['error'] as String;
          if (error.contains('401') ||
              error.contains('Unauthorized') ||
              error.contains('Authentication required')) {
            state = state.copyWith(unreadNotificationCount: 0);
            await logout();
            return;
          }
          throw Exception(error);
        }

        final count = response['unreadCount'] as int? ?? 0;
        state = state.copyWith(unreadNotificationCount: count);
      },
      onError: (error) {
        state = state.copyWith(unreadNotificationCount: 0);
      },
    );
  }

  /// Handle OneSignal event
  Future<void> handleOneSignalEvent(Map<String, dynamic> event) async {
    final type = event['type'] as String?;
    final data = event['data'] as Map<String, dynamic>?;
    dev.log(data.toString());

    if (type == 'opened_notification') {
      // Refresh unread count when notification is opened
      await _loadUnreadNotificationCount();
    } else if (type == 'notification_received') {
      // Increment unread count when new notification is received
      final currentCount = state.unreadNotificationCount;
      state = state.copyWith(unreadNotificationCount: currentCount + 1);

      // Trigger notification reload for seamless experience
      // This will be handled by the notifications screen
    }
  }

  /// Check and sync service availability status
  Future<void> checkServiceAvailabilityStatus() async {
    if (!state.isAuthenticated ||
        state.activeService == null ||
        state.activeService!.id == null ||
        state.authToken == null) {
      return;
    }

    try {
      final isAvailable = await serviceAvailabilityService
          .checkServiceAvailability(
            serviceId: state.activeService!.id!,
            authToken: state.authToken!,
            isConnected: state.isInternetConnected,
          );

      // Update state if different from current
      if (state.isServiceAvailable != isAvailable) {
        state = state.copyWith(isServiceAvailable: isAvailable);
      }
    } catch (e) {
      dev.log('[AppProvider] Error checking service availability: $e');
    }
  }

  /// Load notifications with optional type filter
  Future<void> loadNotificationsWithFilter(String? notificationType) async {
    // This will be handled by the network provider in the screen
  }

  /// Refresh notifications (uses current filter)
  Future<void> refreshNotifications() async {
    // This will be handled by the network provider in the screen
  }

  /// Mark notification as read
  Future<void> markNotificationAsRead(String notificationId) async {
    if (!state.isAuthenticated) return;

    await catchErrorVoid(
      operation: () async {
        final networkHandler = NetworkHandler(
          isConnected: state.isInternetConnected,
          authToken: state.authToken,
        );

        if (!networkHandler.isAuthenticated) {
          return;
        }

        final response = await networkHandler.patchRequest(
          endpoint: ApiEndpoints.markNotificationAsRead.replaceAll(
            '{id}',
            notificationId,
          ),
          body: {},
          requiresAuth: true,
        );

        if (response.containsKey('error')) {
          final error = response['error'] as String;
          if (error.contains('401') ||
              error.contains('Unauthorized') ||
              error.contains('Authentication required')) {
            await logout();
            return;
          }
          throw Exception(error);
        }

        // Refresh unread count after marking as read
        await _loadUnreadNotificationCount();
      },
      onError: (error) {
        state = state.copyWith(
          error: 'Failed to mark notification as read: ${error.toString()}',
        );
      },
    );
  }

  /// Mark all notifications as read
  Future<void> markAllNotificationsAsRead() async {
    if (!state.isAuthenticated) return;

    await catchErrorVoid(
      operation: () async {
        final networkHandler = NetworkHandler(
          isConnected: state.isInternetConnected,
          authToken: state.authToken,
        );

        if (!networkHandler.isAuthenticated) {
          return;
        }

        final response = await networkHandler.patchRequest(
          endpoint: ApiEndpoints.markAllNotificationsAsRead,
          body: {},
          requiresAuth: true,
        );

        if (response.containsKey('error')) {
          final error = response['error'] as String;
          if (error.contains('401') ||
              error.contains('Unauthorized') ||
              error.contains('Authentication required')) {
            await logout();
            return;
          }
          throw Exception(error);
        }

        // Refresh unread count after marking all as read
        await _loadUnreadNotificationCount();
      },
      onError: (error) {
        state = state.copyWith(
          error:
              'Failed to mark all notifications as read: ${error.toString()}',
        );
      },
    );
  }

  /// Delete notification
  Future<void> deleteNotification(String notificationId) async {
    if (!state.isAuthenticated) return;

    await catchErrorVoid(
      operation: () async {
        final networkHandler = NetworkHandler(
          isConnected: state.isInternetConnected,
          authToken: state.authToken,
        );

        if (!networkHandler.isAuthenticated) {
          return;
        }

        final response = await networkHandler.deleteRequest(
          endpoint: ApiEndpoints.deleteNotification.replaceAll(
            '{id}',
            notificationId,
          ),
          requiresAuth: true,
        );

        if (response.containsKey('error')) {
          final error = response['error'] as String;
          if (error.contains('401') ||
              error.contains('Unauthorized') ||
              error.contains('Authentication required')) {
            await logout();
            return;
          }
          throw Exception(error);
        }

        // Refresh unread count after deleting
        await _loadUnreadNotificationCount();
      },
      onError: (error) {
        state = state.copyWith(
          error: 'Failed to delete notification: ${error.toString()}',
        );
      },
    );
  }

  /// Refresh unread count (public method)
  Future<void> refreshUnreadCount() async {
    await _loadUnreadNotificationCount();
  }

  /// Mark service progress as shown to prevent repeated navigation
  void markServiceProgressAsShown() {
    state = state.copyWith(shouldShowServiceProgress: false);
  }

  /// Reset service progress flag (called on app restart)
  void resetServiceProgressFlag() {
    state = state.copyWith(shouldShowServiceProgress: true);
  }
}

// Providers
final appNotifierProvider = StateNotifierProvider<AppNotifier, AppState>((ref) {
  return AppNotifier(ref);
});

final userProvider = Provider<User?>((ref) {
  return ref.watch(appNotifierProvider).user;
});

final authTokenProvider = Provider<String?>((ref) {
  return ref.watch(appNotifierProvider).authToken;
});

final isAuthenticatedProvider = Provider<bool>((ref) {
  return ref.watch(appNotifierProvider).isAuthenticated;
});

final isConnectedProvider = Provider<bool>((ref) {
  return ref.watch(appNotifierProvider).isInternetConnected;
});

final themeModeProvider = Provider<ThemeMode>((ref) {
  return ref.watch(appNotifierProvider).themeMode;
});

final serviceProfilesProvider = Provider<List<Service>>((ref) {
  return ref.watch(appNotifierProvider).serviceProfiles;
});

final activeServiceProvider = Provider<Service?>((ref) {
  return ref.watch(appNotifierProvider).activeService;
});

final isLiveProvider = Provider<bool>((ref) {
  return ref.watch(appNotifierProvider).isLive;
});

final serviceFormStateProvider = Provider<Map<String, dynamic>?>((ref) {
  return ref.watch(appNotifierProvider).serviceFormState;
});

final notificationsProvider = Provider<List<NotificationModel>>((ref) {
  // This will be handled by the notifications screen directly
  return [];
});

final unreadNotificationCountProvider = Provider<int>((ref) {
  return ref.watch(appNotifierProvider).unreadNotificationCount;
});

final isLoadingNotificationsProvider = Provider<bool>((ref) {
  // This will be handled by the notifications screen directly
  return false;
});

final isServiceAvailableProvider = Provider<bool>((ref) {
  return ref.watch(appNotifierProvider).isServiceAvailable;
});

final availableServicesProvider = Provider<List<Map<String, dynamic>>>((ref) {
  return ref.watch(appNotifierProvider).availableServices;
});

final shouldShowServiceProgressProvider = Provider<bool>((ref) {
  return ref.watch(appNotifierProvider).shouldShowServiceProgress;
});

// Provider that automatically refreshes data when authentication changes
final authStateListenerProvider = Provider<void>((ref) {
  // This provider will rebuild whenever authentication state changes
  // The UI can listen to this provider to trigger data refresh
  ref.listen<bool>(isAuthenticatedProvider, (previous, next) {
    if (previous != next) {
      // Authentication state changed
      if (next == true) {
        // User logged in - refresh data
        Future.microtask(() {
          ref.read(appNotifierProvider.notifier).refreshAppData();
        });
      }
      // If false, logout already cleared the data
    }
  });

  ref.listen<String?>(authTokenProvider, (previous, next) {
    if (previous != next && next != null) {
      // Token changed - refresh data with new token
      Future.microtask(() {
        ref.read(appNotifierProvider.notifier).refreshAppData();
      });
    }
  });
});

extension AppStateContext on BuildContext {
  AppState get appState =>
      ProviderScope.containerOf(this).read(appNotifierProvider);
  bool get isAuthenticated => appState.isAuthenticated;
  bool get isConnected => appState.isInternetConnected;
  User? get currentUser => appState.user;
  String? get authToken => appState.authToken;
  List<Service> get serviceProfiles => appState.serviceProfiles;
  Service? get activeService => appState.activeService;
  bool get isLive => appState.isLive;
  int get unreadNotificationCount => appState.unreadNotificationCount;
  bool get isServiceAvailable => appState.isServiceAvailable;
  List<Map<String, dynamic>> get availableServices =>
      appState.availableServices;
}
