import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:riderescue_services/plugins/providers/app_provider.dart';
import 'package:riderescue_services/plugins/theme/colors.dart';
import 'package:riderescue_services/constants/route_names.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = AppColors.fromBrightness(Theme.of(context).brightness);
    final themeMode = ref.watch(themeModeProvider);
    final appNotifier = ref.read(appNotifierProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        backgroundColor: colors.scaffoldBackground,
        elevation: 4,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Appearance Section
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Appearance',
                    style: TextStyle(
                      color: colors.text,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    decoration: BoxDecoration(
                      color: colors.card,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey.withOpacity(0.1)),
                    ),
                    child: ListTile(
                      leading: Icon(Icons.palette, color: colors.primary),
                      title: Text(
                        'Theme',
                        style: TextStyle(color: colors.text),
                      ),
                      subtitle: Text(
                        _getThemeModeText(themeMode),
                        style: TextStyle(color: colors.secondaryText),
                      ),
                      trailing: DropdownButton<ThemeMode>(
                        value: themeMode,
                        underline: const SizedBox(),
                        items: const [
                          DropdownMenuItem(
                            value: ThemeMode.system,
                            child: Text('System'),
                          ),
                          DropdownMenuItem(
                            value: ThemeMode.light,
                            child: Text('Light'),
                          ),
                          DropdownMenuItem(
                            value: ThemeMode.dark,
                            child: Text('Dark'),
                          ),
                        ],
                        onChanged: (ThemeMode? newValue) {
                          if (newValue != null) {
                            appNotifier.setThemeMode(newValue);
                          }
                        },
                      ),
                      onTap: null,
                    ),
                  ),
                ],
              ),
            ),

            // Support Section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Support & Legal',
                    style: TextStyle(
                      color: colors.text,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    decoration: BoxDecoration(
                      color: colors.card,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey.withOpacity(0.1)),
                    ),
                    child: Column(
                      children: [
                        ListTile(
                          leading: Icon(
                            Icons.help_outline,
                            color: colors.primary,
                          ),
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
                        Divider(height: 1, color: Colors.grey.withOpacity(0.1)),
                        ListTile(
                          leading: Icon(
                            Icons.privacy_tip_outlined,
                            color: colors.primary,
                          ),
                          title: Text(
                            'Privacy Policy',
                            style: TextStyle(color: colors.text),
                          ),
                          subtitle: Text(
                            'How we protect your data',
                            style: TextStyle(color: colors.secondaryText),
                          ),
                          trailing: Icon(
                            Icons.arrow_forward_ios,
                            color: colors.secondaryText,
                            size: 16,
                          ),
                          onTap: () => context.push(Routes.privacyPolicy),
                        ),
                        Divider(height: 1, color: Colors.grey.withOpacity(0.1)),
                        ListTile(
                          leading: Icon(
                            Icons.description_outlined,
                            color: colors.primary,
                          ),
                          title: Text(
                            'Terms of Service',
                            style: TextStyle(color: colors.text),
                          ),
                          subtitle: Text(
                            'Service terms and conditions',
                            style: TextStyle(color: colors.secondaryText),
                          ),
                          trailing: Icon(
                            Icons.arrow_forward_ios,
                            color: colors.secondaryText,
                            size: 16,
                          ),
                          onTap: () => context.push(Routes.termsOfService),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Account Section
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Account',
                    style: TextStyle(
                      color: colors.text,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    decoration: BoxDecoration(
                      color: colors.card,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey.withOpacity(0.1)),
                    ),
                    child: ListTile(
                      leading: Icon(Icons.logout, color: colors.error),
                      title: Text(
                        'Logout',
                        style: TextStyle(color: colors.error),
                      ),
                      subtitle: Text(
                        'Sign out of your account',
                        style: TextStyle(color: colors.secondaryText),
                      ),
                      onTap: () => _showLogoutDialog(context, appNotifier),
                    ),
                  ),
                ],
              ),
            ),

            // App Info Section
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'App Information',
                    style: TextStyle(
                      color: colors.text,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    decoration: BoxDecoration(
                      color: colors.card,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey.withOpacity(0.1)),
                    ),
                    child: Column(
                      children: [
                        ListTile(
                          leading: Icon(
                            Icons.info_outline,
                            color: colors.primary,
                          ),
                          title: Text(
                            'Version',
                            style: TextStyle(color: colors.text),
                          ),
                          subtitle: Text(
                            '1.0.0',
                            style: TextStyle(color: colors.secondaryText),
                          ),
                          onTap: null,
                        ),
                        Divider(height: 1, color: Colors.grey.withOpacity(0.1)),
                        ListTile(
                          leading: Icon(
                            Icons.bug_report_outlined,
                            color: colors.primary,
                          ),
                          title: Text(
                            'Report a Bug',
                            style: TextStyle(color: colors.text),
                          ),
                          subtitle: Text(
                            'Help us improve the app',
                            style: TextStyle(color: colors.secondaryText),
                          ),
                          trailing: Icon(
                            Icons.arrow_forward_ios,
                            color: colors.secondaryText,
                            size: 16,
                          ),
                          onTap: () {
                            context.push('/bug-report');
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getThemeModeText(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.light:
        return 'Light';
      case ThemeMode.dark:
        return 'Dark';
      case ThemeMode.system:
        return 'System';
    }
  }

  void _showLogoutDialog(BuildContext context, AppNotifier appNotifier) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              appNotifier.logout();
              context.go(Routes.login);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }
}
