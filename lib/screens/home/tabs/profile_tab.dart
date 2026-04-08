import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:riderescue_services/plugins/providers/app_provider.dart';
import 'package:riderescue_services/plugins/theme/colors.dart';
import 'package:riderescue_services/constants/route_names.dart';
import 'package:riderescue_services/models/service.dart';
import 'package:riderescue_services/widgets/retry_status_widget.dart';

class ProfileTab extends ConsumerWidget {
  const ProfileTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = AppColors.fromBrightness(Theme.of(context).brightness);
    final user = ref.watch(userProvider);
    final serviceProfiles = ref.watch(serviceProfilesProvider);
    final activeService = ref.watch(activeServiceProvider);

    if (user == null) {
      return const Center(child: Text('Please login to view profile'));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        backgroundColor: colors.scaffoldBackground,
        elevation: 4,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Profile Header Section
            Container(
              width: double.infinity,
              padding: const EdgeInsets.only(
                top: 16.0,
                left: 16.0,
                right: 16.0,
              ),
              child: Column(
                children: [
                  // Profile Avatar and Info
                  Row(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: colors.primary.withOpacity(0.3),
                            width: 3,
                          ),
                        ),
                        child: CircleAvatar(
                          radius: 35,
                          backgroundColor: colors.primary.withOpacity(0.2),
                          backgroundImage:
                              user.avatar != null && user.avatar!.isNotEmpty
                              ? NetworkImage(user.avatar!)
                              : null,
                          child: user.avatar == null || user.avatar!.isEmpty
                              ? Text(
                                  _getUserInitial(user.name),
                                  style: TextStyle(
                                    fontSize: 28,
                                    fontWeight: FontWeight.bold,
                                    color: colors.primary,
                                  ),
                                )
                              : null,
                        ),
                      ),
                      const SizedBox(width: 20),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              user.name,
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: colors.text,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 2),
                            Text(
                              user.email,
                              style: TextStyle(
                                color: colors.secondaryText,
                                fontSize: 14,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      Container(
                        decoration: BoxDecoration(
                          color: colors.primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: IconButton(
                          onPressed: () => context.push(Routes.editProfile),
                          icon: Icon(
                            Icons.edit,
                            color: colors.primary,
                            size: 20,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // // Retry Status Widget (shows connection retry status)
            const RetryStatusWidget(),

            // Service Management Section
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Container(
                decoration: BoxDecoration(
                  color: colors.card,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.withOpacity(0.1)),
                ),
                child: Column(
                  children: [
                    // Add New Service Profile
                    ListTile(
                      enabled: serviceProfiles.length < 3,
                      leading: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: serviceProfiles.length < 3
                              ? colors.primary.withOpacity(0.1)
                              : colors.secondaryText.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          Icons.add_circle_outline,
                          color: serviceProfiles.length < 3
                              ? colors.primary
                              : colors.secondaryText.withOpacity(0.5),
                          size: 20,
                        ),
                      ),
                      title: Text(
                        'Add New Service Profile',
                        style: TextStyle(
                          color: serviceProfiles.length < 3
                              ? colors.text
                              : colors.secondaryText.withOpacity(0.5),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      subtitle: Text(
                        serviceProfiles.length < 3
                            ? 'Create a new service profile'
                            : 'Maximum 3 service profiles allowed',
                        style: TextStyle(
                          color: serviceProfiles.length < 3
                              ? colors.secondaryText
                              : Colors.orange.withOpacity(0.8),
                        ),
                      ),
                      trailing: Icon(
                        Icons.arrow_forward_ios,
                        color: serviceProfiles.length < 3
                            ? colors.secondaryText
                            : colors.secondaryText.withOpacity(0.3),
                        size: 16,
                      ),
                      onTap: serviceProfiles.length < 3
                          ? () {
                              context.push(Routes.onboardingService);
                            }
                          : () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    'You cannot add more than 3 service profiles',
                                  ),
                                  backgroundColor: Colors.orange,
                                  duration: Duration(seconds: 2),
                                ),
                              );
                            },
                    ),

                    // Current Active Service
                    if (activeService != null) ...[
                      Divider(height: 1, color: Colors.grey.withOpacity(0.1)),
                      ListTile(
                        leading: CircleAvatar(
                          radius: 20,
                          backgroundImage: NetworkImage(
                            activeService.photo.isNotEmpty
                                ? activeService.photo
                                : 'https://via.placeholder.com/40',
                          ),
                          backgroundColor: colors.primary.withOpacity(0.1),
                        ),
                        title: Text(
                          activeService.name.isNotEmpty
                              ? activeService.name
                              : 'Unnamed Service',
                          style: TextStyle(
                            color: colors.text,
                            fontWeight: FontWeight.bold,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        subtitle: Text(
                          '${activeService.type.isNotEmpty ? activeService.type : 'Service'} • Active',
                          style: TextStyle(
                            color: colors.primary,
                            fontWeight: FontWeight.w500,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        trailing: Icon(
                          Icons.check_circle,
                          color: colors.primary,
                          size: 20,
                        ),
                        onTap: () {
                          context.push(
                            Routes.serviceDetails,
                            extra: activeService,
                          );
                        },
                      ),
                    ],

                    // Switch Service Profile
                    Divider(height: 1, color: Colors.grey.withOpacity(0.1)),
                    ListTile(
                      enabled: serviceProfiles.isNotEmpty,
                      leading: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: serviceProfiles.isNotEmpty
                              ? colors.primary.withOpacity(0.1)
                              : colors.secondaryText.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          Icons.swap_horiz,
                          color: serviceProfiles.isNotEmpty
                              ? colors.primary
                              : colors.secondaryText.withOpacity(0.5),
                          size: 20,
                        ),
                      ),
                      title: Text(
                        'Switch Profiles',
                        style: TextStyle(
                          color: serviceProfiles.isNotEmpty
                              ? colors.text
                              : colors.secondaryText.withOpacity(0.5),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      subtitle: Text(
                        serviceProfiles.isNotEmpty
                            ? '${serviceProfiles.length} profile${serviceProfiles.length == 1 ? '' : 's'} available'
                            : 'No service profiles available',
                        style: TextStyle(
                          color: serviceProfiles.isNotEmpty
                              ? colors.secondaryText
                              : Colors.orange.withOpacity(0.8),
                        ),
                      ),
                      trailing: Icon(
                        Icons.arrow_forward_ios,
                        color: serviceProfiles.isNotEmpty
                            ? colors.secondaryText
                            : colors.secondaryText.withOpacity(0.3),
                        size: 16,
                      ),
                      onTap: serviceProfiles.isNotEmpty
                          ? () => _showServiceProfileSelector(
                              context,
                              ref,
                              serviceProfiles,
                              activeService,
                            )
                          : () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    'You need to add service profiles first',
                                  ),
                                  backgroundColor: Colors.orange,
                                  duration: Duration(seconds: 2),
                                ),
                              );
                            },
                    ),
                  ],
                ),
              ),
            ),

            // App Settings Section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Container(
                decoration: BoxDecoration(
                  color: colors.card,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.withOpacity(0.1)),
                ),
                child: Column(
                  children: [
                    // // Phone Number Management
                    // ListTile(
                    //   leading: Icon(Icons.phone, color: colors.primary),
                    //   title: Text(
                    //     'Phone Number',
                    //     style: TextStyle(color: colors.text),
                    //   ),
                    //   subtitle: Text(
                    //     user.phone.isNotEmpty
                    //         ? 'Manage phone number'
                    //         : 'Add phone number',
                    //     style: TextStyle(color: colors.secondaryText),
                    //   ),
                    //   trailing: Icon(
                    //     Icons.arrow_forward_ios,
                    //     color: colors.secondaryText,
                    //     size: 16,
                    //   ),
                    //   onTap: () => context.push('/phone-number'),
                    // ),
                    // Divider(height: 1, color: Colors.grey.withOpacity(0.1)),

                    // Theme Toggle
                    ListTile(
                      leading: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: colors.primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          Theme.of(context).brightness == Brightness.dark
                              ? Icons.light_mode
                              : Icons.dark_mode,
                          color: colors.primary,
                          size: 20,
                        ),
                      ),
                      title: Text(
                        'Toggle Theme',
                        style: TextStyle(
                          color: colors.text,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      subtitle: Text(
                        Theme.of(context).brightness == Brightness.dark
                            ? 'Switch to light mode'
                            : 'Switch to dark mode',
                        style: TextStyle(color: colors.secondaryText),
                      ),
                      trailing: Icon(
                        Icons.arrow_forward_ios,
                        color: colors.secondaryText,
                        size: 16,
                      ),
                      onTap: () => _showThemeSelector(context, ref),
                    ),

                    // Settings
                    Divider(height: 1, color: Colors.grey.withOpacity(0.1)),
                    ListTile(
                      leading: Icon(Icons.settings, color: colors.primary),
                      title: Text(
                        'Settings',
                        style: TextStyle(color: colors.text),
                      ),
                      subtitle: Text(
                        'Privacy and account settings',
                        style: TextStyle(color: colors.secondaryText),
                      ),
                      trailing: Icon(
                        Icons.arrow_forward_ios,
                        color: colors.secondaryText,
                        size: 16,
                      ),
                      onTap: () => context.push(Routes.settings),
                    ),

                    // Help & Support
                    Divider(height: 1, color: Colors.grey.withOpacity(0.1)),
                    ListTile(
                      leading: Icon(Icons.help_outline, color: colors.primary),
                      title: Text(
                        'Help & Support',
                        style: TextStyle(color: colors.text),
                      ),
                      subtitle: Text(
                        'Get help and contact support',
                        style: TextStyle(color: colors.secondaryText),
                      ),
                      trailing: Icon(
                        Icons.arrow_forward_ios,
                        color: colors.secondaryText,
                        size: 16,
                      ),
                      onTap: () => context.push(Routes.helpSupport),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Account Actions Section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Container(
                decoration: BoxDecoration(
                  color: colors.card,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.withOpacity(0.1)),
                ),
                child: ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.red.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(Icons.logout, color: Colors.red, size: 20),
                  ),
                  title: Text(
                    'Logout',
                    style: TextStyle(
                      color: Colors.red,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  subtitle: Text(
                    'Sign out of your account',
                    style: TextStyle(color: colors.secondaryText),
                  ),
                  trailing: Icon(
                    Icons.arrow_forward_ios,
                    color: colors.secondaryText,
                    size: 16,
                  ),
                  onTap: () => _showLogoutConfirmation(context, ref),
                ),
              ),
            ),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  String _getUserInitial(String? name) {
    if (name == null || name.isEmpty) {
      return 'U';
    }
    return name.substring(0, 1).toUpperCase();
  }

  void _showServiceProfileSelector(
    BuildContext context,
    WidgetRef ref,
    List<Service> serviceProfiles,
    Service? activeService,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Switch Service Profile',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurface,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Select a service profile to make active',
                style: TextStyle(
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurface.withOpacity(0.7),
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 16),
              ...serviceProfiles.map(
                (service) => _ServiceProfileOption(
                  service: service,
                  isActive: activeService?.id == service.id,
                  onTap: () async {
                    try {
                      await ref
                          .read(appNotifierProvider.notifier)
                          .switchServiceProfile(service);
                      Navigator.of(context).pop();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            'Switched to ${service.name.isNotEmpty ? service.name : 'service'}',
                          ),
                          backgroundColor: Colors.green,
                        ),
                      );
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Failed to switch service: $e'),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  },
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

  void _showThemeSelector(BuildContext context, WidgetRef ref) {
    final currentTheme = ref.watch(appNotifierProvider).themeMode;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Choose Theme',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurface,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Select your preferred theme mode',
                style: TextStyle(
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurface.withOpacity(0.7),
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 16),
              _ThemeOption(
                title: 'Light',
                subtitle: 'Use light theme',
                icon: Icons.light_mode,
                isSelected: currentTheme == ThemeMode.light,
                onTap: () {
                  ref
                      .read(appNotifierProvider.notifier)
                      .setThemeMode(ThemeMode.light);
                  Navigator.of(context).pop();
                },
              ),
              const SizedBox(height: 8),
              _ThemeOption(
                title: 'Dark',
                subtitle: 'Use dark theme',
                icon: Icons.dark_mode,
                isSelected: currentTheme == ThemeMode.dark,
                onTap: () {
                  ref
                      .read(appNotifierProvider.notifier)
                      .setThemeMode(ThemeMode.dark);
                  Navigator.of(context).pop();
                },
              ),
              const SizedBox(height: 8),
              _ThemeOption(
                title: 'System',
                subtitle: 'Follow system settings',
                icon: Icons.settings_system_daydream,
                isSelected: currentTheme == ThemeMode.system,
                onTap: () {
                  ref
                      .read(appNotifierProvider.notifier)
                      .setThemeMode(ThemeMode.system);
                  Navigator.of(context).pop();
                },
              ),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

  void _showLogoutConfirmation(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.red.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(Icons.logout, color: Colors.red, size: 24),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      'Logout',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurface,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                'Are you sure you want to logout?',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurface,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'You will be signed out of your account and will need to sign in again to access your services.',
                style: TextStyle(
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurface.withOpacity(0.7),
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        side: BorderSide(
                          color: Theme.of(context).colorScheme.outline,
                        ),
                      ),
                      child: Text(
                        'Cancel',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onSurface,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () async {
                        Navigator.of(context).pop();

                        try {
                          await ref.read(appNotifierProvider.notifier).logout();

                          if (context.mounted) {
                            // Navigate to login page after successful logout
                            context.go(Routes.login);
                          }
                        } catch (e) {
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Failed to logout: $e'),
                                backgroundColor: Colors.red,
                                duration: const Duration(seconds: 3),
                              ),
                            );
                          }
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        elevation: 0,
                      ),
                      child: const Text(
                        'Logout',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }
}

class _ServiceProfileOption extends StatelessWidget {
  final Service service;
  final bool isActive;
  final VoidCallback onTap;

  const _ServiceProfileOption({
    required this.service,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(
          color: isActive
              ? Theme.of(context).colorScheme.primary.withOpacity(0.1)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isActive
                ? Theme.of(context).colorScheme.primary
                : Colors.grey.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 20,
              backgroundImage: NetworkImage(
                service.photo.isNotEmpty
                    ? service.photo
                    : 'https://via.placeholder.com/40',
              ),
              backgroundColor: Theme.of(
                context,
              ).colorScheme.primary.withOpacity(0.1),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    service.name.isNotEmpty ? service.name : 'Unnamed Service',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: isActive
                          ? Theme.of(context).colorScheme.primary
                          : Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  Text(
                    service.type.isNotEmpty
                        ? service.type.toUpperCase()
                        : 'SERVICE',
                    style: TextStyle(
                      fontSize: 12,
                      color: Theme.of(
                        context,
                      ).colorScheme.onSurface.withOpacity(0.7),
                    ),
                  ),
                ],
              ),
            ),
            if (isActive)
              Icon(
                Icons.check_circle,
                color: Theme.of(context).colorScheme.primary,
                size: 24,
              ),
          ],
        ),
      ),
    );
  }
}

class _ThemeOption extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _ThemeOption({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(
          color: isSelected
              ? Theme.of(context).colorScheme.primary.withOpacity(0.1)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected
                ? Theme.of(context).colorScheme.primary
                : Colors.grey.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: isSelected
                    ? Theme.of(context).colorScheme.primary.withOpacity(0.2)
                    : Theme.of(context).colorScheme.onSurface.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                color: isSelected
                    ? Theme.of(context).colorScheme.primary
                    : Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: isSelected
                          ? Theme.of(context).colorScheme.primary
                          : Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 12,
                      color: Theme.of(
                        context,
                      ).colorScheme.onSurface.withOpacity(0.7),
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              Icon(
                Icons.check_circle,
                color: Theme.of(context).colorScheme.primary,
                size: 24,
              ),
          ],
        ),
      ),
    );
  }
}
