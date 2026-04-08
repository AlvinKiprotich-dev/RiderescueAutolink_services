import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:riderescue_services/plugins/providers/app_provider.dart';
import 'package:riderescue_services/constants/route_names.dart';
import '../../notifications_screen.dart';
import '../../active_services_screen.dart';

class HomeTab extends ConsumerStatefulWidget {
  const HomeTab({super.key});

  @override
  ConsumerState<HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends ConsumerState<HomeTab> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: _buildAppBar(context, ref),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        child: Consumer(
          builder: (context, ref, child) {
            final serviceProfiles = ref.watch(serviceProfilesProvider);
            final activeService = ref.watch(activeServiceProvider);
            final isLive = ref.watch(isLiveProvider);
            final shouldShowServiceProgress = ref.watch(
              shouldShowServiceProgressProvider,
            );

            // Only push service progress page if no profiles OR service needs attention
            if (serviceProfiles.isEmpty ||
                (activeService != null &&
                    (activeService.status == 'onboarding' ||
                        activeService.status == 'rejected-approval' ||
                        activeService.status == 'suspended'))) {
              // Automatically navigate to progress page only if flag is true
              if (shouldShowServiceProgress) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  ref
                      .read(appNotifierProvider.notifier)
                      .markServiceProgressAsShown();
                  context.push(Routes.serviceProgress);
                });
              }

              // Return appropriate view based on condition
              if (serviceProfiles.isEmpty) {
                return _buildGetStartedView(context);
              } else {
                return _buildDocumentUploadPendingView(context, activeService);
              }
            }

            // Show pending approval view without auto-navigation
            if (activeService != null &&
                activeService.status == 'pending-approval') {
              return _buildPendingApprovalView(context, activeService);
            }

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (activeService != null &&
                    activeService.status == 'approved') ...[
                  _buildSearchSection(context),
                  const SizedBox(height: 24),
                ],
                if (activeService != null) ...[
                  _buildFeaturedServiceCard(context, activeService, isLive),
                  const SizedBox(height: 24),
                  _buildServiceStatusSection(context, activeService),
                  const SizedBox(height: 24),
                  if (activeService.status == 'approved') ...[
                    _buildQuickStats(context, activeService),
                    const SizedBox(height: 24),
                    _buildEarningsOverview(context),
                    const SizedBox(height: 24),
                    _buildRecentActivities(context),
                    const SizedBox(height: 24),
                    _buildQuickActions(context),
                    const SizedBox(height: 24),
                    _buildActionButtons(context),
                  ],
                ],
              ],
            );
          },
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context, WidgetRef ref) {
    final user = ref.watch(userProvider);
    final fullUserName = user?.name ?? 'Driver';
    final unreadCount = ref.watch(unreadNotificationCountProvider);
    final serviceProfiles = ref.watch(serviceProfilesProvider);

    return AppBar(
      backgroundColor: Theme.of(context).colorScheme.background,
      elevation: 0,
      automaticallyImplyLeading: false,
      titleSpacing: 5,
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Welcome',
                  style: TextStyle(
                    color: Theme.of(
                      context,
                    ).colorScheme.onBackground.withOpacity(0.7),
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  fullUserName,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onBackground,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          Row(
            children: [
              // // Service count indicator
              // if (serviceProfiles.isNotEmpty)
              //   Stack(
              //     children: [
              //       IconButton(
              //         onPressed: () {
              //           Navigator.of(context).push(
              //             MaterialPageRoute(
              //               builder: (context) => const ActiveServicesScreen(),
              //             ),
              //           );
              //         },
              //         icon: Icon(
              //           Icons.directions_car,
              //           color: Theme.of(context).colorScheme.onBackground,
              //           size: 24,
              //         ),
              //       ),
              //       Positioned(
              //         top: 8,
              //         right: 8,
              //         child: Container(
              //           padding: const EdgeInsets.symmetric(
              //             horizontal: 6,
              //             vertical: 2,
              //           ),
              //           decoration: BoxDecoration(
              //             color: Theme.of(context).colorScheme.primary,
              //             borderRadius: BorderRadius.circular(10),
              //           ),
              //           constraints: const BoxConstraints(
              //             minWidth: 16,
              //             minHeight: 16,
              //           ),
              //           child: Text(
              //             serviceProfiles.length.toString(),
              //             style: TextStyle(
              //               color: Theme.of(context).colorScheme.onPrimary,
              //               fontSize: 10,
              //               fontWeight: FontWeight.bold,
              //             ),
              //             textAlign: TextAlign.center,
              //           ),
              //         ),
              //       ),
              //     ],
              //   ),
              // const SizedBox(width: 8),

              // Notifications with badge
              Stack(
                children: [
                  IconButton(
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => const NotificationsScreen(),
                        ),
                      );
                    },
                    icon: Icon(
                      Icons.notifications_outlined,
                      color: Theme.of(context).colorScheme.onBackground,
                      size: 24,
                    ),
                  ),
                  if (unreadCount > 0)
                    Positioned(
                      top: 8,
                      right: 8,
                      child: Container(
                        padding: const EdgeInsets.all(2),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        constraints: const BoxConstraints(
                          minWidth: 16,
                          minHeight: 16,
                        ),
                        child: Text(
                          unreadCount > 99 ? '99+' : unreadCount.toString(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildGetStartedView(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Center(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 60),
            // Large circular illustration
            Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                color: theme.colorScheme.primary,
                borderRadius: BorderRadius.circular(100),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(100),
                child: Image.asset(
                  'assets/images/setup.webp',
                  width: 200,
                  height: 200,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const SizedBox(height: 32),
            // Title
            Text(
              'Create Your Service Profile',
              textAlign: TextAlign.center,
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 12),
            // Description
            Text(
              'Start earning money by enrolling your services. Complete your profile to begin receiving requests.',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyLarge?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 60),
            // Single button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  context.push(Routes.serviceProgress);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.colorScheme.primary,
                  foregroundColor: theme.colorScheme.onPrimary,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Complete Now',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPendingApprovalView(
    BuildContext context,
    dynamic activeService,
  ) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Center(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 60),
            // Large circular illustration
            Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                color: theme.colorScheme.primary,
                borderRadius: BorderRadius.circular(100),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(100),
                child: Image.asset(
                  'assets/images/pending.webp',
                  width: 200,
                  height: 200,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const SizedBox(height: 32),
            // Title
            Text(
              'Application Under Review',
              textAlign: TextAlign.center,
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 12),
            // Description
            Text(
              'Your service profile "${activeService.name}" is currently being reviewed. We\'ll notify you once the verification is complete.',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyLarge?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 24),
            // Service Profile Tile
            _buildServiceProfileTile(context, activeService),
            const SizedBox(height: 36),
            // Single button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  context.push(Routes.serviceProgress);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.colorScheme.primary,
                  foregroundColor: theme.colorScheme.onPrimary,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Check Status',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDocumentUploadPendingView(
    BuildContext context,
    dynamic activeService,
  ) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Center(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 60),
            // Large circular illustration
            Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                color: theme.colorScheme.primary,
                borderRadius: BorderRadius.circular(100),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(100),
                child: Image.asset(
                  'assets/images/upload.webp',
                  width: 200,
                  height: 200,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const SizedBox(height: 32),
            // Title
            Text(
              'Upload Verification Documents',
              textAlign: TextAlign.center,
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 12),
            // Description
            Text(
              'Your service profile "${activeService.name}" is ready! Complete your verification to start receiving requests.',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyLarge?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 24),
            // Service Profile Tile
            _buildServiceProfileTile(context, activeService),
            const SizedBox(height: 36),
            // Single button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  context.push(Routes.serviceProgress);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.colorScheme.primary,
                  foregroundColor: theme.colorScheme.onPrimary,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Complete Now',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildServiceProfileTile(BuildContext context, dynamic activeService) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withOpacity(0.1),
        ),
      ),
      child: Row(
        children: [
          // Service Image
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              image: DecorationImage(
                image: NetworkImage(
                  activeService.photo.isNotEmpty
                      ? activeService.photo
                      : 'https://via.placeholder.com/60',
                ),
                fit: BoxFit.cover,
              ),
            ),
          ),
          const SizedBox(width: 16),
          // Service Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  activeService.name.isNotEmpty
                      ? activeService.name
                      : 'Unnamed Service',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurface,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  activeService.type.isNotEmpty
                      ? activeService.type
                      : 'Service',
                  style: TextStyle(
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withOpacity(0.7),
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Theme.of(
                      context,
                    ).colorScheme.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    activeService.status ?? 'Unknown',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.primary,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildServiceStatusSection(
    BuildContext context,
    dynamic activeService,
  ) {
    final status = activeService.status ?? 'draft';

    switch (status) {
      case 'pending-approval':
        return _buildStatusCard(
          context,
          title: 'Pending Approval',
          message:
              'Your service is currently under review. Please wait while we verify your information.',
          icon: Icons.schedule,
          color: Colors.orange,
          actionText: 'Check Status',
          onAction: () {
            // Navigate to service details or status page
          },
        );

      case 'rejected-approval':
        return _buildStatusCard(
          context,
          title: 'Application Rejected',
          message:
              'Your service application was not approved. Please review and upload additional documents.',
          icon: Icons.error_outline,
          color: Colors.red,
          actionText: 'Upload Documents',
          onAction: () {
            // Navigate to documents upload screen
            context.push('/service-documents/${activeService.id}');
          },
        );

      case 'onboarding':
        return _buildStatusCard(
          context,
          title: 'Complete Onboarding',
          message:
              'Please complete your service setup by uploading all required documents.',
          icon: Icons.upload_file,
          color: Colors.blue,
          actionText: 'Upload Documents',
          onAction: () {
            // Navigate to documents upload screen
            context.push('/service-documents/${activeService.id}');
          },
        );

      case 'suspended':
        return _buildStatusCard(
          context,
          title: 'Service Suspended',
          message:
              'Your service has been suspended. Please contact support for assistance.',
          icon: Icons.block,
          color: Colors.red,
          actionText: 'Contact Support',
          onAction: () {
            // Navigate to support page
            context.push('/help-support');
          },
        );

      case 'draft':
        return _buildStatusCard(
          context,
          title: 'Complete Setup',
          message:
              'Please complete your service profile setup to start receiving requests.',
          icon: Icons.edit,
          color: Colors.grey,
          actionText: 'Complete Setup',
          onAction: () {
            // Navigate to service onboarding
            context.push('/onboarding-service');
          },
        );

      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildStatusCard(
    BuildContext context, {
    required String title,
    required String message,
    required IconData icon,
    required Color color,
    required String actionText,
    required VoidCallback onAction,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurface,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      message,
                      style: TextStyle(
                        color: Theme.of(
                          context,
                        ).colorScheme.onSurface.withOpacity(0.7),
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: TextButton(
              onPressed: onAction,
              style: TextButton.styleFrom(
                foregroundColor: color,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                actionText,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchSection(BuildContext context) {
    return Consumer(
      builder: (context, ref, child) {
        final isLive = ref.watch(isLiveProvider);
        final isConnected = ref.watch(isConnectedProvider);

        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: isLive
                ? Theme.of(context).colorScheme.primary.withOpacity(0.05)
                : Theme.of(context).colorScheme.onSurface.withOpacity(0.05),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: isLive
                      ? Theme.of(context).colorScheme.primary.withOpacity(0.1)
                      : Theme.of(
                          context,
                        ).colorScheme.onSurface.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(
                  isLive
                      ? Icons.radio_button_checked
                      : Icons.radio_button_unchecked,
                  color: isLive
                      ? Theme.of(context).colorScheme.primary
                      : Theme.of(
                          context,
                        ).colorScheme.onSurface.withOpacity(0.6),
                  size: 16,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isLive ? 'You\'re Live' : 'Go Live',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurface,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      !isConnected
                          ? 'Connect to the internet to go live'
                          : (isLive
                                ? 'Receiving service requests'
                                : 'Start accepting requests'),
                      style: TextStyle(
                        color: !isConnected
                            ? Colors.red
                            : Theme.of(
                                context,
                              ).colorScheme.onSurface.withOpacity(0.7),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              Tooltip(
                message: !isConnected
                    ? 'You must be connected to the internet to go live.'
                    : '',
                child: Switch(
                  value: isLive,
                  onChanged: !isConnected
                      ? null
                      : (value) {
                          ref
                              .read(appNotifierProvider.notifier)
                              .setLiveStatus(value);
                        },
                  activeColor: Theme.of(context).colorScheme.primary,
                  activeTrackColor: Theme.of(
                    context,
                  ).colorScheme.primary.withOpacity(0.3),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildFeaturedServiceCard(
    BuildContext context,
    dynamic activeService,
    bool isLive,
  ) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withOpacity(0.1),
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  image: DecorationImage(
                    image: NetworkImage(
                      activeService.photo.isNotEmpty
                          ? activeService.photo
                          : 'https://via.placeholder.com/80',
                    ),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      activeService.name.isNotEmpty
                          ? activeService.name
                          : 'Unnamed Service',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurface,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      activeService.type.isNotEmpty
                          ? activeService.type
                          : 'Service',
                      style: TextStyle(
                        color: Theme.of(
                          context,
                        ).colorScheme.onSurface.withOpacity(0.7),
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(
                          Icons.star,
                          color: Theme.of(context).colorScheme.primary,
                          size: 16,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${activeService?.rating.toStringAsFixed(1) ?? '0.0'} (${activeService?.reviewCount ?? 0}+ reviews)',
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.onSurface,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Column(
                children: [
                  IconButton(
                    onPressed: () {},
                    icon: Icon(
                      Icons.more_vert,
                      color: Theme.of(
                        context,
                      ).colorScheme.onSurface.withOpacity(0.6),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primary,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: IconButton(
                      onPressed: () {},
                      icon: Icon(
                        Icons.phone,
                        color: Theme.of(context).colorScheme.onPrimary,
                        size: 18,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickStats(BuildContext context, dynamic activeService) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Service Overview',
              style: TextStyle(
                color: Theme.of(context).colorScheme.onBackground,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            TextButton(
              onPressed: () {},
              child: Text(
                'See All',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.primary,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                context,
                title: 'Rating',
                value: '${activeService?.rating.toStringAsFixed(1) ?? '0.0'}★',
                icon: Icons.star,
                color: Colors.amber,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                context,
                title: 'Reviews',
                value: '${activeService?.reviewCount ?? 0}',
                icon: Icons.rate_review,
                color: Colors.blue,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                context,
                title: 'Status',
                value: activeService?.status ?? 'N/A',
                icon: Icons.info_outline,
                color: (activeService?.status == 'approved')
                    ? Colors.green
                    : Colors.orange,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildEarningsOverview(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Earnings Overview',
              style: TextStyle(
                color: Theme.of(context).colorScheme.onBackground,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            TextButton(
              onPressed: () {},
              child: Text(
                'View Details',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.primary,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: Theme.of(context).colorScheme.outline.withOpacity(0.1),
            ),
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'This Week',
                        style: TextStyle(
                          color: Theme.of(
                            context,
                          ).colorScheme.onSurface.withOpacity(0.7),
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'KES 12,500',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onSurface,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.green.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.trending_up, color: Colors.green, size: 16),
                        const SizedBox(width: 4),
                        Text(
                          '+15%',
                          style: TextStyle(
                            color: Colors.green,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: _buildEarningStat(
                      context,
                      title: 'Today',
                      amount: 'KES 2,100',
                      icon: Icons.today,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildEarningStat(
                      context,
                      title: 'This Month',
                      amount: 'KES 45,200',
                      icon: Icons.calendar_month,
                      color: Colors.blue,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildEarningStat(
    BuildContext context, {
    required String title,
    required String amount,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurface.withOpacity(0.7),
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            amount,
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurface,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentActivities(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Recent Activities',
              style: TextStyle(
                color: Theme.of(context).colorScheme.onBackground,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            TextButton(
              onPressed: () {},
              child: Text(
                'See All',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.primary,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: Theme.of(context).colorScheme.outline.withOpacity(0.1),
            ),
          ),
          child: Column(
            children: [
              _buildActivityItem(
                context,
                icon: Icons.check_circle,
                title: 'Service Completed',
                subtitle: 'Battery jump start - KES 1,500',
                time: '2 hours ago',
                color: Colors.green,
              ),
              const SizedBox(height: 16),
              _buildActivityItem(
                context,
                icon: Icons.schedule,
                title: 'New Booking',
                subtitle: 'Tire change service - KES 2,200',
                time: '4 hours ago',
                color: Colors.blue,
              ),
              const SizedBox(height: 16),
              _buildActivityItem(
                context,
                icon: Icons.star,
                title: '5-Star Review',
                subtitle: 'Excellent service, very professional',
                time: '1 day ago',
                color: Colors.amber,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildActivityItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required String time,
    required Color color,
  }) {
    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurface,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                subtitle,
                style: TextStyle(
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurface.withOpacity(0.7),
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
        Text(
          time,
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quick Actions',
          style: TextStyle(
            color: Theme.of(context).colorScheme.onBackground,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildQuickActionCard(
                context,
                icon: Icons.add_circle_outline,
                title: 'Add Service',
                subtitle: 'Create new service profile',
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildQuickActionCard(
                context,
                icon: Icons.schedule,
                title: 'Schedule',
                subtitle: 'Manage your availability',
                color: Colors.blue,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildQuickActionCard(
                context,
                icon: Icons.analytics,
                title: 'Analytics',
                subtitle: 'View performance metrics',
                color: Colors.green,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildQuickActionCard(
                context,
                icon: Icons.support_agent,
                title: 'Support',
                subtitle: 'Get help & contact us',
                color: Colors.orange,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildQuickActionCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withOpacity(0.1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(height: 12),
          Text(
            title,
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurface,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(
    BuildContext context, {
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withOpacity(0.1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurface.withOpacity(0.7),
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurface,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: () {
              // Add profile management navigation
            },
            icon: const Icon(Icons.settings, size: 20),
            label: const Text('Manage Profile'),
            style: OutlinedButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.onSurface,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
