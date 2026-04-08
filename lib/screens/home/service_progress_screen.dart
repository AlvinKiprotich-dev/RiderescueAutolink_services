import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:riderescue_services/plugins/providers/app_provider.dart';
import 'package:riderescue_services/models/service.dart';
import 'package:riderescue_services/constants/route_names.dart';

class ServiceProgressScreen extends ConsumerWidget {
  const ServiceProgressScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final serviceProfiles = ref.watch(serviceProfilesProvider);
    final activeService = ref.watch(activeServiceProvider);

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.background,
        elevation: 4,
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Text(
              'You are almost done',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Let\'s ensure everything is in order for a secure and compliant experience, including identity verification.',
              style: TextStyle(
                fontSize: 16,
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                height: 1.4,
              ),
            ),
            const SizedBox(height: 32),

            // Progress Steps
            Expanded(
              child: _buildProgressSteps(
                context,
                serviceProfiles,
                activeService,
              ),
            ),

            // Action Buttons
            _buildActionButtons(context, serviceProfiles, activeService),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressSteps(
    BuildContext context,
    List<Service> serviceProfiles,
    Service? activeService,
  ) {
    return Column(
      children: [
        _buildProgressStep(
          context,
          stepNumber: 1,
          title: 'Create Account',
          subtitle: 'Finalize your account setup to begin providing services.',
          isCompleted: true,
          status: 'Complete',
          statusColor: Colors.green,
          showConnector: true,
        ),
        const SizedBox(height: 24),
        _buildProgressStep(
          context,
          stepNumber: 2,
          title: 'Service Profile Setup',
          subtitle: serviceProfiles.isEmpty
              ? 'Create your first service profile to start earning.'
              : 'Complete your service profile setup.',
          isCompleted: serviceProfiles.isNotEmpty,
          status: serviceProfiles.isEmpty ? 'Incomplete' : 'Complete',
          statusColor: serviceProfiles.isEmpty ? Colors.grey : Colors.green,
          showConnector: true,
        ),
        const SizedBox(height: 24),
        _buildProgressStep(
          context,
          stepNumber: 3,
          title: 'Identity Verification',
          subtitle: _getVerificationSubtitle(activeService),
          isCompleted: activeService?.status == 'approved',
          status: _getVerificationStatus(activeService),
          statusColor: _getVerificationStatusColor(activeService),
          showConnector: false,
        ),
      ],
    );
  }

  Widget _buildProgressStep(
    BuildContext context, {
    required int stepNumber,
    required String title,
    required String subtitle,
    required bool isCompleted,
    required String status,
    required Color statusColor,
    required bool showConnector,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Step indicator with connector
        Column(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: isCompleted
                    ? Colors.green
                    : Theme.of(context).colorScheme.onSurface.withOpacity(0.2),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Center(
                child: isCompleted
                    ? const Icon(Icons.check, color: Colors.white, size: 18)
                    : Text(
                        stepNumber.toString(),
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onSurface,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ),
            if (showConnector) ...[
              const SizedBox(height: 8),
              Container(
                width: 4,
                height: 40,
                decoration: BoxDecoration(
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurface.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ],
          ],
        ),
        const SizedBox(width: 16),
        // Content
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 14,
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurface.withOpacity(0.7),
                  height: 1.3,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        // Status badge
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: statusColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            status,
            style: TextStyle(
              color: statusColor,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  String _getVerificationStatus(Service? activeService) {
    if (activeService == null) return 'Incomplete';

    switch (activeService.status) {
      case 'approved':
        return 'Complete';
      case 'pending-approval':
        return 'Under Review';
      case 'rejected-approval':
        return 'Rejected';
      case 'onboarding':
        return 'In Progress';
      case 'suspended':
        return 'Suspended';
      default:
        return 'Incomplete';
    }
  }

  String _getVerificationSubtitle(Service? activeService) {
    if (activeService == null) {
      return 'Complete document verification to start receiving requests.';
    }

    switch (activeService.status) {
      case 'approved':
        return 'Your documents have been verified successfully.';
      case 'pending-approval':
        return 'Your documents are under review. Please wait for approval.';
      case 'rejected-approval':
        return 'Your documents were rejected. Please upload additional or corrected documents.';
      case 'onboarding':
        return 'Upload required documents for verification.';
      case 'suspended':
        return 'Your service has been suspended. Please contact support for assistance.';
      default:
        return 'Complete document verification to start receiving requests.';
    }
  }

  Color _getVerificationStatusColor(Service? activeService) {
    if (activeService == null) return Colors.grey;

    switch (activeService.status) {
      case 'approved':
        return Colors.green;
      case 'pending-approval':
        return Colors.orange;
      case 'rejected-approval':
        return Colors.red;
      case 'onboarding':
        return Colors.blue;
      case 'suspended':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  Widget _buildActionButtons(
    BuildContext context,
    List<Service> serviceProfiles,
    Service? activeService,
  ) {
    // Show different buttons for pending approval
    if (activeService?.status == 'pending-approval') {
      return Column(
        children: [
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => Navigator.of(context).pop(),
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.primary,
                foregroundColor: Theme.of(context).colorScheme.onPrimary,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'OK',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
            ),
          ),
          const SizedBox(height: 12),
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              'I understand',
              style: TextStyle(
                color: Theme.of(context).colorScheme.primary,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      );
    }

    // Default buttons for other statuses
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () =>
                _handleProceedAction(context, serviceProfiles, activeService),
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.primary,
              foregroundColor: Theme.of(context).colorScheme.onPrimary,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(
              _getProceedButtonText(serviceProfiles, activeService),
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
          ),
        ),
        const SizedBox(height: 12),
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(
            'I will do this later',
            style: TextStyle(
              color: Theme.of(context).colorScheme.primary,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  String _getProceedButtonText(
    List<Service> serviceProfiles,
    Service? activeService,
  ) {
    if (serviceProfiles.isEmpty) {
      return 'Create Service Profile';
    }

    if (activeService?.status == 'onboarding') {
      return 'Upload Documents';
    }

    if (activeService?.status == 'rejected-approval') {
      return 'Upload Documents';
    }

    if (activeService?.status == 'suspended') {
      return 'Contact Support';
    }

    if (activeService?.status == 'pending-approval') {
      return 'OK';
    }

    return 'Proceed';
  }

  void _handleProceedAction(
    BuildContext context,
    List<Service> serviceProfiles,
    Service? activeService,
  ) {
    // Always close the current page first
    Navigator.of(context).pop();

    if (serviceProfiles.isEmpty) {
      // Navigate to service onboarding
      context.push(Routes.onboardingService);
    } else if (activeService?.status == 'onboarding' ||
        activeService?.status == 'rejected-approval') {
      // Navigate to documents upload
      context.push('${Routes.serviceDocuments}?serviceId=${activeService!.id}');
    } else if (activeService?.status == 'suspended') {
      // Navigate to help and support
      context.push('/help-support');
    }
  }
}
