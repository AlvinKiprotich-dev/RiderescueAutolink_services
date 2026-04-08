import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:riderescue_services/plugins/theme/colors.dart';

class PrivacyPolicyScreen extends ConsumerWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = AppColors.fromBrightness(Theme.of(context).brightness);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Privacy Policy'),
        backgroundColor: colors.scaffoldBackground,
        elevation: 4,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: colors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: colors.primary.withOpacity(0.2)),
              ),
              child: Column(
                children: [
                  Icon(
                    Icons.privacy_tip_outlined,
                    size: 48,
                    color: colors.primary,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Privacy Policy',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: colors.text,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Last updated: ${DateTime.now().year}',
                    style: TextStyle(color: colors.secondaryText, fontSize: 14),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Privacy Policy Content
            _buildSection(
              colors,
              title: '1. Information We Collect',
              content: '''
We collect information you provide directly to us, such as when you create an account, register a service, or contact us for support. This may include:

• Personal information (name, email, phone number)
• Service-related information (business details, documents, location)
• Payment information (processed securely through our payment partners)
• Communication records (support tickets, messages)
• Usage data (app interactions, service requests)
              ''',
            ),

            _buildSection(
              colors,
              title: '2. How We Use Your Information',
              content: '''
We use the information we collect to:

• Provide and maintain our services
• Process service registrations and payments
• Connect you with customers seeking your services
• Send important updates and notifications
• Provide customer support
• Improve our services and user experience
• Comply with legal obligations
              ''',
            ),

            _buildSection(
              colors,
              title: '3. Information Sharing',
              content: '''
We do not sell your personal information. We may share your information in the following circumstances:

• With customers seeking your services (limited to necessary details)
• With service providers who help us operate our platform
• When required by law or to protect our rights
• With your consent for specific purposes
              ''',
            ),

            _buildSection(
              colors,
              title: '4. Data Security',
              content: '''
We implement appropriate security measures to protect your information:

• Encryption of sensitive data in transit and at rest
• Regular security assessments and updates
• Access controls and authentication
• Secure payment processing
• Regular backups and disaster recovery
              ''',
            ),

            _buildSection(
              colors,
              title: '5. Your Rights',
              content: '''
You have the right to:

• Access your personal information
• Correct inaccurate information
• Request deletion of your data
• Opt out of marketing communications
• Export your data
• Lodge complaints with supervisory authorities
              ''',
            ),

            _buildSection(
              colors,
              title: '6. Data Retention',
              content: '''
We retain your information for as long as necessary to:

• Provide our services
• Comply with legal obligations
• Resolve disputes
• Enforce our agreements

You may request deletion of your account and associated data at any time.
              ''',
            ),

            _buildSection(
              colors,
              title: '7. Location Services',
              content: '''
Our app may request access to your location to:

• Show your service area to potential customers
• Help customers find nearby service providers
• Provide location-based features

You can control location permissions in your device settings.
              ''',
            ),

            _buildSection(
              colors,
              title: '8. Third-Party Services',
              content: '''
We may use third-party services for:

• Payment processing
• Analytics and performance monitoring
• Customer support tools
• Cloud storage and hosting

These services have their own privacy policies and data handling practices.
              ''',
            ),

            _buildSection(
              colors,
              title: '9. Children\'s Privacy',
              content: '''
Our services are not intended for children under 18. We do not knowingly collect personal information from children under 18. If you believe we have collected such information, please contact us immediately.
              ''',
            ),

            _buildSection(
              colors,
              title: '10. Changes to This Policy',
              content: '''
We may update this privacy policy from time to time. We will notify you of any material changes by:

• Posting the updated policy in the app
• Sending email notifications
• Displaying in-app notifications

Your continued use of our services after changes constitutes acceptance of the updated policy.
              ''',
            ),

            _buildSection(
              colors,
              title: '11. Contact Us',
              content: '''
If you have questions about this privacy policy or our data practices, please contact us:

Email: privacy@riderescue.com
Phone: +1 (555) 123-4567
Address: 123 Main Street, City, State 12345

We will respond to your inquiry within 30 days.
              ''',
            ),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(
    AppColors colors, {
    required String title,
    required String content,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              color: colors.text,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: colors.card,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: colors.border.withOpacity(0.2)),
            ),
            child: Text(
              content,
              style: TextStyle(color: colors.text, fontSize: 14, height: 1.5),
            ),
          ),
        ],
      ),
    );
  }
}
