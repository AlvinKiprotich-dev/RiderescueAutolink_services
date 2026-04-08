import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:riderescue_services/models/service.dart';
import 'package:riderescue_services/plugins/theme/colors.dart';
import 'package:riderescue_services/constants/route_names.dart';

class ServiceDetailsScreen extends ConsumerWidget {
  final Service service;

  const ServiceDetailsScreen({super.key, required this.service});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = AppColors.fromBrightness(Theme.of(context).brightness);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Service Details'),
        backgroundColor: colors.scaffoldBackground,
        elevation: 4,
        // actions: [
        //   IconButton(
        //     onPressed: () => _editService(context),
        //     icon: Icon(Icons.edit, color: colors.primary),
        //   ),
        // ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Service Header with Photo
            Container(
              width: double.infinity,
              height: 250,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    colors.primary.withOpacity(0.1),
                    colors.primary.withOpacity(0.05),
                  ],
                ),
              ),
              child: Stack(
                children: [
                  // Service Photo
                  Positioned.fill(
                    child: service.photo.isNotEmpty
                        ? ClipRRect(
                            borderRadius: const BorderRadius.only(
                              bottomLeft: Radius.circular(24),
                              bottomRight: Radius.circular(24),
                            ),
                            child: Image.network(
                              service.photo,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  decoration: BoxDecoration(
                                    color: colors.primary.withOpacity(0.1),
                                    borderRadius: const BorderRadius.only(
                                      bottomLeft: Radius.circular(24),
                                      bottomRight: Radius.circular(24),
                                    ),
                                  ),
                                  child: Icon(
                                    Icons.work_outline,
                                    size: 80,
                                    color: colors.primary,
                                  ),
                                );
                              },
                            ),
                          )
                        : Container(
                            decoration: BoxDecoration(
                              color: colors.primary.withOpacity(0.1),
                              borderRadius: const BorderRadius.only(
                                bottomLeft: Radius.circular(24),
                                bottomRight: Radius.circular(24),
                              ),
                            ),
                            child: Icon(
                              Icons.work_outline,
                              size: 80,
                              color: colors.primary,
                            ),
                          ),
                  ),
                  // Service Type Badge
                  Positioned(
                    top: 16,
                    right: 16,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: colors.primary,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        service.type.isNotEmpty
                            ? service.type.toUpperCase()
                            : 'SERVICE',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  // Service Name Overlay
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            Colors.black.withOpacity(0.7),
                          ],
                        ),
                        borderRadius: const BorderRadius.only(
                          bottomLeft: Radius.circular(24),
                          bottomRight: Radius.circular(24),
                        ),
                      ),
                      child: Text(
                        service.name.isNotEmpty
                            ? service.name
                            : 'Unnamed Service',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Service Information Sections
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // About Section
                  _buildInfoSection(
                    context,
                    colors,
                    'About',
                    Icons.info_outline,
                    service.about.isNotEmpty
                        ? service.about
                        : 'No description available',
                  ),
                  const SizedBox(height: 24),

                  // Contact Information
                  _buildInfoSection(
                    context,
                    colors,
                    'Contact Information',
                    Icons.contact_phone,
                    [
                      if (service.phone.isNotEmpty) 'Phone: ${service.phone}',
                      if (service.email != null && service.email!.isNotEmpty)
                        'Email: ${service.email}',
                    ].join('\n'),
                  ),
                  const SizedBox(height: 24),

                  // Location Information
                  _buildInfoSection(
                    context,
                    colors,
                    'Location',
                    Icons.location_on,
                    [
                      if (service.address.isNotEmpty) service.address,
                      if (service.city.isNotEmpty) service.city,
                      if (service.country.isNotEmpty) service.country,
                    ].join(', '),
                  ),
                  const SizedBox(height: 24),

                  // Brands of Expertise
                  if (service.brandOfExpertise.isNotEmpty) ...[
                    _buildInfoSection(
                      context,
                      colors,
                      'Brands of Expertise',
                      Icons.directions_car,
                      service.brandOfExpertise.join(', '),
                    ),
                    const SizedBox(height: 24),
                  ],

                  // Areas of Expertise with Costs
                  if (service.areaOfExpertise.isNotEmpty) ...[
                    _buildExpertiseSection(context, colors),
                    const SizedBox(height: 24),
                  ],

                  // Service Statistics
                  _buildStatsSection(context, colors),
                  const SizedBox(height: 24),

                  // Service Status
                  _buildStatusSection(context, colors),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoSection(
    BuildContext context,
    AppColors colors,
    String title,
    IconData icon,
    String content,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.card,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colors.border.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: colors.primary, size: 20),
              const SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(
                  color: colors.text,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            content,
            style: TextStyle(color: colors.text, fontSize: 14, height: 1.4),
          ),
        ],
      ),
    );
  }

  Widget _buildExpertiseSection(BuildContext context, AppColors colors) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.card,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colors.border.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.work, color: colors.primary, size: 20),
              const SizedBox(width: 8),
              Text(
                'Areas of Expertise',
                style: TextStyle(
                  color: colors.text,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...List.generate(service.areaOfExpertise.length, (index) {
            final area = service.areaOfExpertise[index];

            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      area,
                      style: TextStyle(color: colors.text, fontSize: 14),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildStatsSection(BuildContext context, AppColors colors) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.card,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colors.border.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.analytics, color: colors.primary, size: 20),
              const SizedBox(width: 8),
              Text(
                'Service Statistics',
                style: TextStyle(
                  color: colors.text,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildStatItem(
                  context,
                  colors,
                  'Rating',
                  '${service.rating.toStringAsFixed(1)}★',
                  Icons.star,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildStatItem(
                  context,
                  colors,
                  'Reviews',
                  service.reviewCount.toString(),
                  Icons.rate_review,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(
    BuildContext context,
    AppColors colors,
    String label,
    String value,
    IconData icon,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colors.primary.withOpacity(0.05),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Icon(icon, color: colors.primary, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              color: colors.text,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            label,
            style: TextStyle(color: colors.secondaryText, fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusSection(BuildContext context, AppColors colors) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.card,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colors.border.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.info, color: colors.primary, size: 20),
              const SizedBox(width: 8),
              Text(
                'Service Status',
                style: TextStyle(
                  color: colors.text,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: _getStatusColor(service.status),
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                'Status: ${service.status.toUpperCase()}',
                style: TextStyle(
                  color: colors.text,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: service.isAvailable ? Colors.green : Colors.grey,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                'Availability: ${service.isAvailable ? 'Available' : 'Not Available'}',
                style: TextStyle(
                  color: colors.text,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'active':
        return Colors.green;
      case 'pending':
        return Colors.orange;
      case 'suspended':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  void _editService(BuildContext context) {
    context.push(Routes.onboardingService, extra: service);
  }
}
