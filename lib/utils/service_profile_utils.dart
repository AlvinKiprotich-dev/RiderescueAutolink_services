import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riderescue_services/plugins/providers/network_provider.dart';
import 'package:riderescue_services/plugins/providers/app_provider.dart';
import 'package:riderescue_services/constants/api_endpoints.dart';
import 'package:riderescue_services/models/service.dart'; 
import 'dart:developer' as dev;

Future<void> fetchAndSetServiceProfiles(WidgetRef ref) async {
  NetworkState? response;
  try {
    final network = ref.read(networkProvider);
    response = await network.get(ApiEndpoints.serviceProfiles);

    if (response.success && response.data != null) {
      List<Service> services = [];
      if (response.data is Map<String, dynamic>) {
        final data = response.data as Map<String, dynamic>;
        if (data['services'] != null) {
          final servicesList = data['services'] as List<dynamic>;
          services = servicesList
              .map((serviceJson) {
                try {
                  if (serviceJson is Map<String, dynamic>) {
                    return Service.fromJson(serviceJson);
                  }
                  return null;
                } catch (e) {
                  dev.log('Error parsing service: $e');
                  dev.log('Service data: $serviceJson');
                  return null;
                }
              })
              .where((service) => service != null)
              .cast<Service>()
              .toList();
        }
      }
      if (services.isNotEmpty) {
        await ref
            .read(appNotifierProvider.notifier)
            .setServiceProfiles(services);
      }
    }
  } catch (e) {
    dev.log('Failed to fetch service profiles: $e');
    if (response != null) {
      dev.log('Response data type:  [33m${response.data.runtimeType} [0m');
      dev.log('Response data: ${response.data}');
    }
  }
}
