import 'dart:developer' as dev;
import 'package:riderescue_services/constants/api_endpoints.dart';
import 'package:riderescue_services/plugins/utils/network_service.dart';
import 'package:riderescue_services/plugins/utils/error_handler.dart';

class ServiceAvailabilityService {
  static final ServiceAvailabilityService _instance =
      ServiceAvailabilityService._internal();
  factory ServiceAvailabilityService() => _instance;
  ServiceAvailabilityService._internal();

  /// Toggle service availability using HTTP API
  Future<bool> toggleServiceAvailability({
    required String serviceId,
    required bool isAvailable,
    required String authToken,
    required bool isConnected,
  }) async {
    return await catchError(
      operation: () async {
        final networkHandler = NetworkHandler(
          isConnected: isConnected,
          authToken: authToken,
        );

        if (!networkHandler.isAuthenticated) {
          throw Exception('Authentication required');
        }

        final endpoint = ApiEndpoints.serviceAvailability.replaceAll(
          '{id}',
          serviceId,
        );

        final response = await networkHandler.patchRequest(
          endpoint: endpoint,
          body: {'isAvailable': isAvailable},
          requiresAuth: true,
        );

        if (response.containsKey('error')) {
          final error = response['error'] as String;
          if (error.contains('401') ||
              error.contains('Unauthorized') ||
              error.contains('Authentication required')) {
            throw Exception('Session expired. Please login again.');
          }
          throw Exception(error);
        }

        dev.log(
          '[ServiceAvailability] Service availability updated successfully: $isAvailable',
        );
        return true;
      },
      onError: (error) {
        dev.log('[ServiceAvailability] Error toggling availability: $error');
        throw Exception('Failed to toggle service availability: $error');
      },
    );
  }

  /// Check if service is available
  Future<bool> checkServiceAvailability({
    required String serviceId,
    required String authToken,
    required bool isConnected,
  }) async {
    return await catchError(
      operation: () async {
        final networkHandler = NetworkHandler(
          isConnected: isConnected,
          authToken: authToken,
        );

        if (!networkHandler.isAuthenticated) {
          throw Exception('Authentication required');
        }

        final endpoint = ApiEndpoints.serviceById.replaceAll('{id}', serviceId);

        final response = await networkHandler.getRequest(
          endpoint: endpoint,
          requiresAuth: true,
        );

        if (response.containsKey('error')) {
          final error = response['error'] as String;
          if (error.contains('401') ||
              error.contains('Unauthorized') ||
              error.contains('Authentication required')) {
            throw Exception('Session expired. Please login again.');
          }
          throw Exception(error);
        }

        if (response['service'] != null) {
          final service = response['service'] as Map<String, dynamic>;
          return service['isAvailable'] ?? false;
        }

        return false;
      },
      onError: (error) {
        dev.log('[ServiceAvailability] Error checking availability: $error');
        throw Exception('Failed to check service availability: $error');
      },
    );
  }
}

// Global instance
final serviceAvailabilityService = ServiceAvailabilityService();
