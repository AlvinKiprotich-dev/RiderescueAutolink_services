import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riderescue_services/plugins/providers/app_provider.dart';

class ServiceAvailabilityWidget extends ConsumerWidget {
  const ServiceAvailabilityWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isServiceAvailable = ref.watch(isServiceAvailableProvider);
    final isServiceProvider = ref.watch(serviceProfilesProvider).isNotEmpty;

    if (!isServiceProvider) {
      return const SizedBox.shrink();
    }

    return Card(
      margin: const EdgeInsets.all(16.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.work,
                  color: Theme.of(context).primaryColor,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Service Status',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      Text(
                        isServiceAvailable ? 'Available for requests' : 'Currently offline',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                Switch(
                  value: isServiceAvailable,
                  onChanged: (value) {
                    ref.read(appNotifierProvider.notifier).toggleServiceAvailability(value);
                  },
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (isServiceAvailable) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.check_circle,
                      color: Colors.green,
                      size: 16,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'You are now live and will receive service requests',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.green[700],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
} 