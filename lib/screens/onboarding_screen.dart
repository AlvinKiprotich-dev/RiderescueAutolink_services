import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:riderescue_services/constants/route_names.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _controller = PageController();
  int _page = 0;

  final List<Map<String, String>> _pages = [
    {
      'image': 'assets/images/onboarding1.png',
      'title': 'Offer Mechanic Services',
      'desc':
          'Become a trusted mechanic and help drivers get back on the road quickly.',
    },
    {
      'image': 'assets/images/onboarding2.png',
      'title': 'Provide Towing Assistance',
      'desc': 'Join as a towing provider and assist drivers in need of a tow.',
    },
    {
      'image': 'assets/images/onboarding3.png',
      'title': 'List Your Garage',
      'desc':
          'Register your garage to receive more customers and grow your business.',
    },
    {
      'image': 'assets/images/onboarding4.png',
      'title': 'Get Linked & Earn',
      'desc':
          'Connect with new drivers, receive service requests, and earn for every job you complete.',
    },
  ];

  void _completeOnboarding() async {
    try {
      // Set onboarding as completed
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('is_onboarded', true);

      // Navigate to login
      if (mounted) {
        context.go(Routes.login);
      }
    } catch (e) {
      throw Exception(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageView.builder(
                controller: _controller,
                itemCount: _pages.length,
                onPageChanged: (i) => setState(() => _page = i),
                itemBuilder: (context, i) {
                  final page = _pages[i];
                  return Padding(
                    padding: const EdgeInsets.all(32.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.asset(page['image']!, height: 220),
                        const SizedBox(height: 32),
                        Text(
                          page['title']!,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          page['desc']!,
                          style: const TextStyle(fontSize: 16),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                _pages.length,
                (i) => Container(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 4,
                    vertical: 16,
                  ),
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: i == _page
                        ? Theme.of(context).colorScheme.primary
                        : Colors.grey[300],
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
              child: Row(
                children: [
                  if (_page < _pages.length - 1)
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => _controller.nextPage(
                          duration: const Duration(milliseconds: 400),
                          curve: Curves.easeInOut,
                        ),
                        child: const Text('Next'),
                      ),
                    ),
                  if (_page == _pages.length - 1)
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          _completeOnboarding();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Theme.of(
                            context,
                          ).colorScheme.primary,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: const Text(
                          'Get Started',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
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
}
