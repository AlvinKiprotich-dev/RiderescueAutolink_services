import 'dart:convert';
import 'dart:developer';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import '../constants/network_constant.dart' show baseUrl;
import '../providers/app_provider.dart';
import 'network_util.dart';

// Base network handler provider (no dependencies)
final baseNetworkHandlerProvider = Provider((ref) {
  return NetworkHandler();
});

// Authenticated network handler provider (depends on app state)
final networkHandlerProvider = Provider((ref) {
  final appState = ref.watch(appNotifierProvider);
  return NetworkHandler(
    isConnected: appState.isInternetConnected,
    authToken: appState.authToken,
  );
});

// Network handler with current auth token access
final currentNetworkHandlerProvider = Provider((ref) {
  final appState = ref.watch(appNotifierProvider);
  return NetworkHandler(
    isConnected: appState.isInternetConnected,
    authToken: appState.authToken,
  );
});

class NetworkHandler {
  final bool isConnected;
  final String? authToken;

  NetworkHandler({this.isConnected = true, this.authToken});

  Map<String, String> get _headers {
    final headers = {'Content-Type': 'application/json'};

    if (authToken != null && authToken!.isNotEmpty) {
      headers['Authorization'] = 'Bearer $authToken';
    }

    return headers;
  }

  /// Check if authentication is valid
  bool get isAuthenticated => authToken != null && authToken!.isNotEmpty;

  /// General function to handle requests (GET, POST, etc.) with internet and cache checks
  Future<Map<String, dynamic>> _handleRequest({
    required String endpoint,
    required Future<http.Response> Function() request,
    bool requiresAuth = false,
  }) async {
    final url = '$baseUrl$endpoint';

    // Check authentication if required
    if (requiresAuth && !isAuthenticated) {
      log('Authentication required but no valid token found.');
      return {'error': 'Authentication required. Please login again.'};
    }

    if (!isConnected) {
      log('No internet connection.');
      final cachedData = await NetworkUtils.getCachedResponse(url);
      if (cachedData != null) {
        return await NetworkUtils.handleResponse(cachedData);
      }

      return {'error': 'No internet connection and no cached response.'};
    }

    try {
      final response = await request();
      return await NetworkUtils.handleResponse(response);
    } catch (e) {
      log('$url request failed: $e');
      return {'error': 'Request failed.'};
    }
  }

  /// Perform GET request with caching and auth validation
  Future<Map<String, dynamic>> getRequest({
    required String endpoint,
    bool requiresAuth = false,
    Map<String, String>? queryParams,
  }) async {
    log('GET /endpoint: $endpoint (requiresAuth: $requiresAuth)');

    // Build URL with query parameters
    String url = '$baseUrl$endpoint';
    if (queryParams != null && queryParams.isNotEmpty) {
      final uri = Uri.parse(url).replace(queryParameters: queryParams);
      url = uri.toString();
    }

    return await _handleRequest(
      endpoint: endpoint,
      requiresAuth: requiresAuth,
      request: () async {
        final response = await http.get(Uri.parse(url), headers: _headers);
        await NetworkUtils.cacheResponse('$baseUrl$endpoint', response);
        return response;
      },
    );
  }

  /// Perform POST request (no caching needed for POST requests)
  Future<Map<String, dynamic>> postRequest({
    required String endpoint,
    required Map<String, dynamic> body,
    bool requiresAuth = false,
  }) async {
    log('POST /endpoint: $endpoint (requiresAuth: $requiresAuth)');
    return await _handleRequest(
      endpoint: endpoint,
      requiresAuth: requiresAuth,
      request: () async {
        final response = await http.post(
          Uri.parse('$baseUrl$endpoint'),
          headers: _headers,
          body: jsonEncode(body),
        );
        return response;
      },
    );
  }

  /// Perform PUT request (no caching needed for PUT requests)
  Future<Map<String, dynamic>> putRequest({
    required String endpoint,
    required Map<String, dynamic> body,
    bool requiresAuth = false,
  }) async {
    log('PUT /endpoint: $endpoint (requiresAuth: $requiresAuth)');
    return await _handleRequest(
      endpoint: endpoint,
      requiresAuth: requiresAuth,
      request: () async {
        final response = await http.put(
          Uri.parse('$baseUrl$endpoint'),
          headers: _headers,
          body: jsonEncode(body),
        );
        return response;
      },
    );
  }

  /// Perform DELETE request (no caching needed for DELETE requests)
  Future<Map<String, dynamic>> deleteRequest({
    required String endpoint,
    bool requiresAuth = false,
  }) async {
    log('DELETE /endpoint: $endpoint (requiresAuth: $requiresAuth)');
    return await _handleRequest(
      endpoint: endpoint,
      requiresAuth: requiresAuth,
      request: () async {
        final response = await http.delete(
          Uri.parse('$baseUrl$endpoint'),
          headers: _headers,
        );
        return response;
      },
    );
  }

  /// Perform PATCH request (no caching needed for PATCH requests)
  Future<Map<String, dynamic>> patchRequest({
    required String endpoint,
    required Map<String, dynamic> body,
    bool requiresAuth = false,
  }) async {
    log('PATCH /endpoint: $endpoint (requiresAuth: $requiresAuth)');
    return await _handleRequest(
      endpoint: endpoint,
      requiresAuth: requiresAuth,
      request: () async {
        final response = await http.patch(
          Uri.parse('$baseUrl$endpoint'),
          headers: _headers,
          body: jsonEncode(body),
        );
        return response;
      },
    );
  }
}
