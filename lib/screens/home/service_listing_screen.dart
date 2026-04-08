import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riderescue_services/plugins/theme/colors.dart';
import 'package:riderescue_services/plugins/providers/network_provider.dart';
import 'package:riderescue_services/plugins/providers/app_provider.dart';
import 'package:riderescue_services/models/service.dart';
import 'package:riderescue_services/constants/api_endpoints.dart';

class ServiceListingScreen extends ConsumerStatefulWidget {
  const ServiceListingScreen({super.key});

  @override
  ConsumerState<ServiceListingScreen> createState() =>
      _ServiceListingScreenState();
}

class _ServiceListingScreenState extends ConsumerState<ServiceListingScreen> {
  List<Service> services = [];
  bool isLoading = false;
  String? error;
  Map<String, List<Service>> groupedServices = {};

  @override
  void initState() {
    super.initState();
    _loadServices();
  }

  Future<void> _loadServices({bool refresh = false}) async {
    setState(() {
      isLoading = true;
      error = null;
    });

    try {
      final appState = ref.read(appNotifierProvider);

      if (!appState.isAuthenticated || appState.authToken == null) {
        throw Exception('Authentication required');
      }

      final network = ref.read(networkProvider);
      final response = await network.get(
        ApiEndpoints.services,
        refresh: refresh,
      );

      if (!response.success) {
        throw Exception(response.message ?? 'Failed to load services');
      }

      final data = response.data;
      if (data != null && data['services'] != null) {
        final servicesData = data['services'] as List<dynamic>;
        final loadedServices = servicesData
            .map((service) => Service.fromJson(service))
            .toList();

        setState(() {
          services = loadedServices;
          _groupServices();
          isLoading = false;
        });
      } else {
        setState(() {
          services = [];
          groupedServices = {};
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        error = 'Failed to load services: ${e.toString()}';
        isLoading = false;
      });
    }
  }

  void _groupServices() {
    final grouped = <String, List<Service>>{};

    for (final service in services) {
      final type = service.type.isNotEmpty ? service.type : 'Other';
      if (!grouped.containsKey(type)) {
        grouped[type] = [];
      }
      grouped[type]!.add(service);
    }

    // Sort services within each group by rating (descending)
    for (final type in grouped.keys) {
      grouped[type]!.sort((a, b) => b.rating.compareTo(a.rating));
    }

    setState(() {
      groupedServices = grouped;
    });
  }

  IconData _getServiceTypeIcon(String type) {
    switch (type.toLowerCase()) {
      case 'mechanic':
        return Icons.build;
      case 'towing':
        return Icons.local_shipping;
      case 'fuel':
        return Icons.local_gas_station;
      case 'battery':
        return Icons.battery_charging_full;
      case 'tire':
        return Icons.tire_repair;
      case 'emergency':
        return Icons.emergency;
      case 'diagnostic':
        return Icons.analytics;
      case 'maintenance':
        return Icons.engineering;
      case 'repair':
        return Icons.handyman;
      case 'inspection':
        return Icons.visibility;
      default:
        return Icons.miscellaneous_services;
    }
  }

  Color _getServiceTypeColor(String type) {
    switch (type.toLowerCase()) {
      case 'mechanic':
        return Colors.orange;
      case 'towing':
        return Colors.blue;
      case 'fuel':
        return Colors.green;
      case 'battery':
        return Colors.yellow.shade700;
      case 'tire':
        return Colors.red;
      case 'emergency':
        return Colors.red.shade700;
      case 'diagnostic':
        return Colors.purple;
      case 'maintenance':
        return Colors.teal;
      case 'repair':
        return Colors.indigo;
      case 'inspection':
        return Colors.cyan;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.fromBrightness(Theme.of(context).brightness);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Available Services'),
        backgroundColor: colors.scaffoldBackground,
        elevation: 4,
        actions: [
          IconButton(
            icon: Icon(Icons.refresh, color: colors.text),
            onPressed: () => _loadServices(refresh: true),
          ),
        ],
      ),
      body: _buildBody(colors),
    );
  }

  Widget _buildBody(AppColors colors) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (error != null) {
      return _buildErrorView(colors);
    }

    if (groupedServices.isEmpty) {
      return _buildEmptyView(colors);
    }

    return _buildServicesList(colors);
  }

  Widget _buildErrorView(AppColors colors) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: colors.secondaryText.withOpacity(0.5),
            ),
            const SizedBox(height: 16),
            Text(
              'Failed to load services',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: colors.text,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              error ?? 'Unknown error occurred',
              style: TextStyle(fontSize: 14, color: colors.secondaryText),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => _loadServices(refresh: true),
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyView(AppColors colors) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off,
              size: 64,
              color: colors.secondaryText.withOpacity(0.5),
            ),
            const SizedBox(height: 16),
            Text(
              'No services found',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: colors.text,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'There are currently no services available in your area',
              style: TextStyle(fontSize: 14, color: colors.secondaryText),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildServicesList(AppColors colors) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: groupedServices.length,
      itemBuilder: (context, index) {
        final type = groupedServices.keys.elementAt(index);
        final servicesInGroup = groupedServices[type]!;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Group Header
            Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: _getServiceTypeColor(type).withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: _getServiceTypeColor(type).withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    _getServiceTypeIcon(type),
                    color: _getServiceTypeColor(type),
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      type,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: _getServiceTypeColor(type),
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: _getServiceTypeColor(type),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '${servicesInGroup.length}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Services in this group
            ...servicesInGroup.map(
              (service) => _buildServiceCard(service, colors),
            ),

            const SizedBox(height: 16),
          ],
        );
      },
    );
  }

  Widget _buildServiceCard(Service service, AppColors colors) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: colors.card,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colors.border.withOpacity(0.2), width: 1),
        boxShadow: [
          BoxShadow(
            color: colors.text.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            // Service Image or Icon
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: _getServiceTypeColor(service.type).withOpacity(0.1),
              ),
              child: service.photo.isNotEmpty
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        service.photo,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Icon(
                          _getServiceTypeIcon(service.type),
                          color: _getServiceTypeColor(service.type),
                          size: 24,
                        ),
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return Icon(
                            _getServiceTypeIcon(service.type),
                            color: _getServiceTypeColor(service.type),
                            size: 24,
                          );
                        },
                      ),
                    )
                  : Icon(
                      _getServiceTypeIcon(service.type),
                      color: _getServiceTypeColor(service.type),
                      size: 24,
                    ),
            ),

            const SizedBox(width: 16),

            // Service Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    service.name.isNotEmpty ? service.name : 'Unnamed Service',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: colors.text,
                    ),
                  ),
                  const SizedBox(height: 4),

                  // Rating and Reviews
                  Row(
                    children: [
                      Icon(Icons.star, size: 16, color: Colors.amber),
                      const SizedBox(width: 4),
                      Text(
                        '${service.rating.toStringAsFixed(1)}',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: colors.text,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '(${service.reviewCount} reviews)',
                        style: TextStyle(
                          fontSize: 12,
                          color: colors.secondaryText,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 4),

                  // Location
                  Row(
                    children: [
                      Icon(
                        Icons.location_on,
                        size: 14,
                        color: colors.secondaryText,
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          service.address.isNotEmpty
                              ? '${service.address}, ${service.city}'
                              : 'Location not specified',
                          style: TextStyle(
                            fontSize: 12,
                            color: colors.secondaryText,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 8),

                  // Expertise Tags
                  if (service.areaOfExpertise.isNotEmpty)
                    Wrap(
                      spacing: 4,
                      runSpacing: 4,
                      children: service.areaOfExpertise.take(3).map((
                        expertise,
                      ) {
                        return Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: _getServiceTypeColor(
                              service.type,
                            ).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            expertise,
                            style: TextStyle(
                              fontSize: 10,
                              color: _getServiceTypeColor(service.type),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                ],
              ),
            ),

            // Status Indicator
            Column(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: service.isAvailable ? Colors.green : Colors.grey,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    service.isAvailable ? 'Available' : 'Unavailable',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: service.status == 'approved'
                        ? Colors.green
                        : Colors.orange,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    service.status.toUpperCase(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
