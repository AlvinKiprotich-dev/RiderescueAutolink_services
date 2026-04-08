import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:riderescue_services/plugins/theme/colors.dart';
import 'package:url_launcher/url_launcher.dart';

class HelpSupportScreen extends ConsumerWidget {
  const HelpSupportScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = AppColors.fromBrightness(Theme.of(context).brightness);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Help & Support'),
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
                  Icon(Icons.support_agent, size: 48, color: colors.primary),
                  const SizedBox(height: 12),
                  Text(
                    'How can we help you?',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: colors.text,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'We\'re here to help you succeed with your service business',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: colors.secondaryText, fontSize: 14),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Quick Help Section
            Text(
              'Quick Help',
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
                border: Border.all(color: colors.border.withOpacity(0.2)),
              ),
              child: Column(
                children: [
                  _buildHelpItem(
                    context,
                    colors,
                    icon: Icons.how_to_reg,
                    title: 'Getting Started',
                    subtitle: 'Learn how to set up your service profile',
                    onTap: () => _showGettingStartedHelp(context, colors),
                  ),
                  Divider(height: 1, color: colors.border.withOpacity(0.2)),
                  _buildHelpItem(
                    context,
                    colors,
                    icon: Icons.upload_file,
                    title: 'Document Upload',
                    subtitle: 'How to upload required documents',
                    onTap: () => _showDocumentUploadHelp(context, colors),
                  ),
                  Divider(height: 1, color: colors.border.withOpacity(0.2)),
                  _buildHelpItem(
                    context,
                    colors,
                    icon: Icons.location_on,
                    title: 'Going Live',
                    subtitle: 'How to start receiving customer requests',
                    onTap: () => _showGoingLiveHelp(context, colors),
                  ),
                  Divider(height: 1, color: colors.border.withOpacity(0.2)),
                  _buildHelpItem(
                    context,
                    colors,
                    icon: Icons.payment,
                    title: 'Payments & Earnings',
                    subtitle: 'Understanding your earnings and payments',
                    onTap: () => _showPaymentsHelp(context, colors),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Contact Support Section
            Text(
              'Contact Support',
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
                border: Border.all(color: colors.border.withOpacity(0.2)),
              ),
              child: Column(
                children: [
                  _buildContactItem(
                    context,
                    colors,
                    icon: Icons.email,
                    title: 'Email Support',
                    subtitle: 'support@riderescue.com',
                    onTap: () => _launchEmail('support@riderescue.com'),
                  ),
                  Divider(height: 1, color: colors.border.withOpacity(0.2)),
                  _buildContactItem(
                    context,
                    colors,
                    icon: Icons.phone,
                    title: 'Phone Support',
                    subtitle: '+1 (555) 123-4567',
                    onTap: () => _launchPhone('+15551234567'),
                  ),
                  Divider(height: 1, color: colors.border.withOpacity(0.2)),
                  _buildContactItem(
                    context,
                    colors,
                    icon: Icons.chat,
                    title: 'Live Chat',
                    subtitle: 'Available 24/7',
                    onTap: () => _showLiveChatInfo(context, colors),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // FAQ Section
            Text(
              'Frequently Asked Questions',
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
                border: Border.all(color: colors.border.withOpacity(0.2)),
              ),
              child: Column(
                children: [
                  _buildFAQItem(
                    context,
                    colors,
                    question: 'How long does approval take?',
                    answer:
                        'Service approval typically takes 1-3 business days after all required documents are submitted.',
                  ),
                  Divider(height: 1, color: colors.border.withOpacity(0.2)),
                  _buildFAQItem(
                    context,
                    colors,
                    question: 'What documents do I need?',
                    answer:
                        'Required documents vary by service type. Mechanics need ID, good conduct certificate, and professional certification. Garages and towing services need business licenses and insurance.',
                  ),
                  Divider(height: 1, color: colors.border.withOpacity(0.2)),
                  _buildFAQItem(
                    context,
                    colors,
                    question: 'How do I get paid?',
                    answer:
                        'Payments are processed weekly. You\'ll receive earnings directly to your registered bank account or mobile money account.',
                  ),
                  Divider(height: 1, color: colors.border.withOpacity(0.2)),
                  _buildFAQItem(
                    context,
                    colors,
                    question: 'Can I have multiple service profiles?',
                    answer:
                        'Yes! You can create multiple service profiles for different service types or locations.',
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildHelpItem(
    BuildContext context,
    AppColors colors, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: colors.primary),
      title: Text(title, style: TextStyle(color: colors.text)),
      subtitle: Text(subtitle, style: TextStyle(color: colors.secondaryText)),
      trailing: Icon(
        Icons.arrow_forward_ios,
        color: colors.secondaryText,
        size: 16,
      ),
      onTap: onTap,
    );
  }

  Widget _buildContactItem(
    BuildContext context,
    AppColors colors, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: colors.primary),
      title: Text(title, style: TextStyle(color: colors.text)),
      subtitle: Text(subtitle, style: TextStyle(color: colors.secondaryText)),
      trailing: Icon(
        Icons.arrow_forward_ios,
        color: colors.secondaryText,
        size: 16,
      ),
      onTap: onTap,
    );
  }

  Widget _buildFAQItem(
    BuildContext context,
    AppColors colors, {
    required String question,
    required String answer,
  }) {
    return ExpansionTile(
      collapsedShape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(0),
        side: BorderSide(color: Colors.transparent),
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(0),
        side: BorderSide(color: Colors.transparent),
      ),
      title: Text(
        question,
        style: TextStyle(color: colors.text, fontWeight: FontWeight.w600),
      ),
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          child: Text(
            answer,
            style: TextStyle(color: colors.secondaryText, fontSize: 14),
          ),
        ),
      ],
    );
  }

  void _showGettingStartedHelp(BuildContext context, AppColors colors) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Getting Started', style: TextStyle(color: colors.text)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '1. Create your service profile',
              style: TextStyle(color: colors.text),
            ),
            Text(
              '2. Upload required documents',
              style: TextStyle(color: colors.text),
            ),
            Text(
              '3. Wait for approval (1-3 days)',
              style: TextStyle(color: colors.text),
            ),
            Text(
              '4. Go live to receive requests',
              style: TextStyle(color: colors.text),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Got it'),
          ),
        ],
      ),
    );
  }

  void _showDocumentUploadHelp(BuildContext context, AppColors colors) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Document Upload', style: TextStyle(color: colors.text)),
        content: Text(
          'Upload clear, high-quality images of your documents. Make sure all text is readable and the document is not expired.',
          style: TextStyle(color: colors.text),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Got it'),
          ),
        ],
      ),
    );
  }

  void _showGoingLiveHelp(BuildContext context, AppColors colors) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Going Live', style: TextStyle(color: colors.text)),
        content: Text(
          'Toggle the live button in your home tab to start receiving customer requests. Make sure you\'re available to respond quickly.',
          style: TextStyle(color: colors.text),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Got it'),
          ),
        ],
      ),
    );
  }

  void _showPaymentsHelp(BuildContext context, AppColors colors) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Payments & Earnings',
          style: TextStyle(color: colors.text),
        ),
        content: Text(
          'Earnings are calculated based on completed jobs. Payments are processed weekly and sent to your registered payment method.',
          style: TextStyle(color: colors.text),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Got it'),
          ),
        ],
      ),
    );
  }

  void _showLiveChatInfo(BuildContext context, AppColors colors) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Live Chat', style: TextStyle(color: colors.text)),
        content: Text(
          'Live chat is available 24/7 for immediate assistance. Our support team will help you with any questions or issues.',
          style: TextStyle(color: colors.text),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Got it'),
          ),
        ],
      ),
    );
  }

  Future<void> _launchEmail(String email) async {
    final Uri emailUri = Uri(
      scheme: 'mailto',
      path: email,
      query: 'subject=RideRescue Support Request',
    );

    if (await canLaunchUrl(emailUri)) {
      await launchUrl(emailUri);
    }
  }

  Future<void> _launchPhone(String phone) async {
    final Uri phoneUri = Uri(scheme: 'tel', path: phone);

    if (await canLaunchUrl(phoneUri)) {
      await launchUrl(phoneUri);
    }
  }
}
