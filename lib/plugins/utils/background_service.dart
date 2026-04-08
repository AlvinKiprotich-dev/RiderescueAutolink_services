import 'dart:async';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:developer' as dev;

class BackgroundService {
  static const MethodChannel _channel = MethodChannel(
    'com.riderescue.services/background_service',
  );

  static final BackgroundService _instance = BackgroundService._internal();
  factory BackgroundService() => _instance;
  BackgroundService._internal();

  bool _isInitialized = false;
  Timer? _keepAliveTimer;
  Timer? _retryTimer;
  int _retryCount = 0;
  static const int _maxRetries = 6; // 30 minutes total (6 * 5 minutes)
  static const Duration _retryInterval = Duration(minutes: 5);
  static const Duration _maxRetryDuration = Duration(minutes: 30);

  // SharedPreferences keys
  static const String _keyWasLive = 'background_service_was_live';
  static const String _keyRetryCount = 'background_service_retry_count';
  static const String _keyLastRetryTime = 'background_service_last_retry';
  static const String _keyRetryStartTime = 'background_service_retry_start';

  /// Initialize background service
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      if (Platform.isAndroid) {
        await _channel.invokeMethod('createNotificationChannel');
      }
      _isInitialized = true;

      // Load retry state from SharedPreferences
      await _loadRetryState();

      // Check if we need to resume retry attempts
      await _checkAndResumeRetries();

      dev.log('[BackgroundService] Initialized successfully');
    } catch (e) {
      dev.log('[BackgroundService] Error initializing: $e');
    }
  }

  /// Load retry state from SharedPreferences
  Future<void> _loadRetryState() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _retryCount = prefs.getInt(_keyRetryCount) ?? 0;
      dev.log('[BackgroundService] Loaded retry count: $_retryCount');
    } catch (e) {
      dev.log('[BackgroundService] Error loading retry state: $e');
      _retryCount = 0;
    }
  }

  /// Save retry state to SharedPreferences
  Future<void> _saveRetryState() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(_keyRetryCount, _retryCount);
      await prefs.setInt(
        _keyLastRetryTime,
        DateTime.now().millisecondsSinceEpoch,
      );
      dev.log('[BackgroundService] Saved retry count: $_retryCount');
    } catch (e) {
      dev.log('[BackgroundService] Error saving retry state: $e');
    }
  }

  /// Save that user was live when going offline
  Future<void> _saveWasLiveState(bool wasLive) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_keyWasLive, wasLive);
      if (wasLive) {
        await prefs.setInt(
          _keyRetryStartTime,
          DateTime.now().millisecondsSinceEpoch,
        );
      }
      dev.log('[BackgroundService] Saved was live state: $wasLive');
    } catch (e) {
      dev.log('[BackgroundService] Error saving was live state: $e');
    }
  }

  /// Check if user was live when going offline
  Future<bool> _wasLiveWhenOffline() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getBool(_keyWasLive) ?? false;
    } catch (e) {
      dev.log('[BackgroundService] Error checking was live state: $e');
      return false;
    }
  }

  /// Check if retry time limit has been exceeded
  Future<bool> _isRetryTimeExceeded() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final retryStartTime = prefs.getInt(_keyRetryStartTime);
      if (retryStartTime == null) return false;

      final startTime = DateTime.fromMillisecondsSinceEpoch(retryStartTime);
      final now = DateTime.now();
      final difference = now.difference(startTime);

      return difference > _maxRetryDuration;
    } catch (e) {
      dev.log('[BackgroundService] Error checking retry time: $e');
      return false;
    }
  }

  /// Check and resume retry attempts if needed
  Future<void> _checkAndResumeRetries() async {
    try {
      final wasLive = await _wasLiveWhenOffline();
      final timeExceeded = await _isRetryTimeExceeded();

      if (wasLive && !timeExceeded && _retryCount < _maxRetries) {
        dev.log(
          '[BackgroundService] Resuming retry attempts. Count: $_retryCount',
        );
        _startRetryTimer();
      } else if (timeExceeded) {
        dev.log(
          '[BackgroundService] Retry time limit exceeded, terminating retries',
        );
        await _clearRetryState();
      }
    } catch (e) {
      dev.log('[BackgroundService] Error checking retry state: $e');
    }
  }

  /// Clear retry state
  Future<void> _clearRetryState() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_keyWasLive);
      await prefs.remove(_keyRetryCount);
      await prefs.remove(_keyLastRetryTime);
      await prefs.remove(_keyRetryStartTime);
      _retryCount = 0;
      _stopRetryTimer();
      dev.log('[BackgroundService] Cleared retry state');
    } catch (e) {
      dev.log('[BackgroundService] Error clearing retry state: $e');
    }
  }

  /// Start background service
  Future<void> startService() async {
    try {
      if (Platform.isAndroid) {
        await _channel.invokeMethod('startBackgroundService');
      }

      // Start keep-alive timer for service availability
      _startKeepAliveTimer();

      dev.log('[BackgroundService] Service started');
    } catch (e) {
      dev.log('[BackgroundService] Error starting service: $e');
    }
  }

  /// Stop background service
  Future<void> stopService() async {
    try {
      if (Platform.isAndroid) {
        await _channel.invokeMethod('stopBackgroundService');
      }

      _stopKeepAliveTimer();
      _stopRetryTimer();

      dev.log('[BackgroundService] Service stopped');
    } catch (e) {
      dev.log('[BackgroundService] Error stopping service: $e');
    }
  }

  /// Start keep-alive timer for service availability
  void _startKeepAliveTimer() {
    _stopKeepAliveTimer();

    _keepAliveTimer = Timer.periodic(const Duration(minutes: 5), (timer) {
      _checkServiceAvailability();
    });
  }

  /// Stop keep-alive timer
  void _stopKeepAliveTimer() {
    _keepAliveTimer?.cancel();
    _keepAliveTimer = null;
  }

  /// Start retry timer
  void _startRetryTimer() {
    _stopRetryTimer();

    _retryTimer = Timer.periodic(_retryInterval, (timer) async {
      await _attemptReconnection();
    });

    dev.log('[BackgroundService] Retry timer started');
  }

  /// Stop retry timer
  void _stopRetryTimer() {
    _retryTimer?.cancel();
    _retryTimer = null;
  }

  /// Check service availability
  void _checkServiceAvailability() {
    try {
      dev.log('[BackgroundService] Checking service availability');
      // This will be called by the app provider when needed
      // The app provider will handle the actual availability check
    } catch (e) {
      dev.log('[BackgroundService] Error checking service availability: $e');
      _handleDisconnection();
    }
  }

  /// Handle service disconnection
  void _handleDisconnection() async {
    try {
      // Check if user was live when disconnected
      final wasLive = await _wasLiveWhenOffline();

      if (wasLive) {
        dev.log('[BackgroundService] User was live, starting retry attempts');
        _retryCount = 0;
        await _saveRetryState();
        _startRetryTimer();
      }
    } catch (e) {
      dev.log('[BackgroundService] Error handling disconnection: $e');
    }
  }

  /// Attempt reconnection with retry logic
  Future<void> _attemptReconnection() async {
    try {
      // Check if retry time limit has been exceeded
      final timeExceeded = await _isRetryTimeExceeded();
      if (timeExceeded) {
        dev.log(
          '[BackgroundService] Retry time limit exceeded, terminating retries',
        );
        await _clearRetryState();
        return;
      }

      // Check if max retries reached
      if (_retryCount >= _maxRetries) {
        dev.log('[BackgroundService] Max retries reached, terminating retries');
        await _clearRetryState();
        return;
      }

      _retryCount++;
      await _saveRetryState();

      dev.log(
        '[BackgroundService] Attempting reconnection (attempt $_retryCount/$_maxRetries)',
      );

      // Wait a bit to see if connection is successful
      await Future.delayed(const Duration(seconds: 10));

      // Check if we should continue retrying
      final wasLive = await _wasLiveWhenOffline();
      if (!wasLive) {
        dev.log('[BackgroundService] User no longer live, stopping retries');
        await _clearRetryState();
        _stopRetryTimer();
      } else {
        dev.log(
          '[BackgroundService] Reconnection attempt completed, will retry in ${_retryInterval.inMinutes} minutes',
        );
      }
    } catch (e) {
      dev.log('[BackgroundService] Error during reconnection attempt: $e');
    }
  }

  /// Notify that user is going live
  Future<void> userWentLive() async {
    await _saveWasLiveState(true);
    await _clearRetryState(); // Clear any existing retry state
    dev.log('[BackgroundService] User went live, cleared retry state');
  }

  /// Notify that user is going offline
  Future<void> userWentOffline() async {
    final wasLive = await _wasLiveWhenOffline();
    if (wasLive) {
      dev.log(
        '[BackgroundService] User went offline while live, will attempt reconnection',
      );
      _handleDisconnection();
    }
  }

  /// Handle app lifecycle changes
  void handleAppLifecycleChange(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.resumed:
        dev.log('[BackgroundService] App resumed');
        _checkAndResumeRetries();
        break;
      case AppLifecycleState.inactive:
        dev.log('[BackgroundService] App inactive');
        break;
      case AppLifecycleState.paused:
        dev.log(
          '[BackgroundService] App paused - checking service availability',
        );
        _checkServiceAvailability();
        break;
      case AppLifecycleState.detached:
        dev.log('[BackgroundService] App detached');
        break;
      case AppLifecycleState.hidden:
        dev.log('[BackgroundService] App hidden');
        break;
    }
  }

  /// Get current retry status
  Future<Map<String, dynamic>> getRetryStatus() async {
    try {
      final wasLive = await _wasLiveWhenOffline();
      final timeExceeded = await _isRetryTimeExceeded();

      return {
        'wasLive': wasLive,
        'retryCount': _retryCount,
        'maxRetries': _maxRetries,
        'timeExceeded': timeExceeded,
        'isRetrying': _retryTimer != null,
        'isConnected': true, // Always true since we're using HTTP now
      };
    } catch (e) {
      dev.log('[BackgroundService] Error getting retry status: $e');
      return {};
    }
  }

  /// Dispose resources
  void dispose() {
    _stopKeepAliveTimer();
    _stopRetryTimer();
    _isInitialized = false;
  }
}

// Global instance
final backgroundService = BackgroundService();
