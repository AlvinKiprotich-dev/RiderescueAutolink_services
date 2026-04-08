import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riderescue_services/plugins/providers/app_provider.dart';
import 'tabs/home_tab.dart';
import 'tabs/activity_tab.dart';
import 'tabs/profile_tab.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  int _selectedIndex = 0;
  bool _isInitializing = true;

  @override
  void initState() {
    super.initState();
    _initializeHomeScreen();
  }

  Future<void> _initializeHomeScreen() async {
    // Delay the provider modification until after the widget tree is built
    Future.microtask(() async {
      final isConnected = ref.read(isConnectedProvider);

      if (isConnected) {
        // Refresh service profiles if connected to internet
        await ref
            .read(appNotifierProvider.notifier)
            .refreshServiceProfilesFresh();
      }

      if (mounted) {
        setState(() {
          _isInitializing = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> tabs = [HomeTab(), ActivityTab(), ProfileTab()];
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    // Show loading screen while initializing
    if (_isInitializing) {
      return Scaffold(
        backgroundColor: theme.colorScheme.background,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Bouncing three dots loader
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(3, (index) {
                  return TweenAnimationBuilder<double>(
                    tween: Tween(begin: 0.0, end: 1.0),
                    duration: Duration(milliseconds: 600 + (index * 200)),
                    builder: (context, value, child) {
                      return Container(
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        child: Transform.translate(
                          offset: Offset(0, -10 * value),
                          child: Container(
                            width: 12,
                            height: 12,
                            decoration: BoxDecoration(
                              color: colorScheme.primary,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                      );
                    },
                    onEnd: () {
                      // Restart animation when it ends
                      if (mounted) {
                        setState(() {});
                      }
                    },
                  );
                }),
              ),
              const SizedBox(height: 24),
              Text(
                'Loading your services...',
                style: TextStyle(
                  color: colorScheme.onSurface.withOpacity(0.7),
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      body: tabs[_selectedIndex],
      bottomNavigationBar: BottomAppBar(
        padding: EdgeInsets.zero,
        color: theme.scaffoldBackgroundColor,
        height: 60,
        elevation: 8,
        child: Container(
          decoration: BoxDecoration(
            color: colorScheme.surface,
            border: Border(
              top: BorderSide(
                color: colorScheme.onSurface.withOpacity(0.05),
                width: 1,
              ),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _TabButton(
                icon: Icons.home,
                label: 'Home',
                selected: _selectedIndex == 0,
                onTap: () => setState(() => _selectedIndex = 0),
                colorScheme: colorScheme,
              ),
              _TabButton(
                icon: Icons.history,
                label: 'Activity',
                selected: _selectedIndex == 1,
                onTap: () => setState(() => _selectedIndex = 1),
                colorScheme: colorScheme,
              ),
              _TabButton(
                icon: Icons.person,
                label: 'Profile',
                selected: _selectedIndex == 2,
                onTap: () => setState(() => _selectedIndex = 2),
                colorScheme: colorScheme,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TabButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;
  final ColorScheme colorScheme;
  const _TabButton({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
    required this.colorScheme,
  });

  IconData _getIcon() {
    switch (icon) {
      case Icons.home:
        return selected ? Icons.home : Icons.home_outlined;
      case Icons.history:
        return selected ? Icons.history : Icons.history_outlined;
      case Icons.person:
        return selected ? Icons.person : Icons.person_outlined;
      default:
        return icon;
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = selected
        ? colorScheme.primary
        : colorScheme.onSurface.withOpacity(0.5);
    return Expanded(
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(_getIcon(), color: color),
              const SizedBox(height: 2),
              Text(
                label,
                style: TextStyle(
                  color: color,
                  fontWeight: selected ? FontWeight.bold : FontWeight.normal,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
