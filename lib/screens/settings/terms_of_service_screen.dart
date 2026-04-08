import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:riderescue_services/plugins/theme/colors.dart';

class TermsOfServiceScreen extends ConsumerWidget {
  const TermsOfServiceScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = AppColors.fromBrightness(Theme.of(context).brightness);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Terms of Service'),
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
                    Icons.description_outlined,
                    size: 48,
                    color: colors.primary,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Terms of Service',
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

            // Terms Content
            _buildSection(
              colors,
              title: '1. Acceptance of Terms',
              content: '''
By accessing and using the RideRescue service provider platform, you agree to be bound by these Terms of Service. If you do not agree to these terms, please do not use our services.

These terms apply to all service providers, including mechanics, garages, and towing services who use our platform to connect with customers.
              ''',
            ),

            _buildSection(
              colors,
              title: '2. Service Provider Responsibilities',
              content: '''
As a service provider, you agree to:

• Provide accurate and truthful information about your services
• Maintain valid licenses, certifications, and insurance as required
• Respond promptly to customer requests and inquiries
• Provide quality services in a professional manner
• Maintain appropriate business hours and availability
• Handle customer data and privacy in accordance with our privacy policy
• Comply with all applicable laws and regulations
• Pay all applicable fees and commissions
              ''',
            ),

            _buildSection(
              colors,
              title: '3. Service Registration and Verification',
              content: '''
To register as a service provider, you must:

• Complete the registration process with accurate information
• Upload all required documents and certifications
• Pass our verification and approval process
• Maintain current and valid documentation
• Update your information promptly when changes occur

We reserve the right to reject or suspend service providers who do not meet our standards or provide false information.
              ''',
            ),

            _buildSection(
              colors,
              title: '4. Service Quality Standards',
              content: '''
Service providers must maintain high quality standards:

• Provide services that meet or exceed industry standards
• Use appropriate tools, equipment, and parts
• Complete work in a timely manner
• Provide clear and accurate pricing information
• Handle customer complaints professionally
• Maintain a minimum rating of 3.0 stars
• Complete at least 80% of accepted service requests
              ''',
            ),

            _buildSection(
              colors,
              title: '5. Payment and Commission',
              content: '''
Payment terms and commission structure:

• Commission rates vary by service type and location
• Payments are processed weekly for completed services
• Service providers receive payment after customer confirmation
• Platform fees are deducted from service payments
• Disputed payments will be investigated and resolved fairly
• Tax obligations are the responsibility of the service provider
              ''',
            ),

            _buildSection(
              colors,
              title: '6. Customer Communication',
              content: '''
Guidelines for customer communication:

• Respond to customer inquiries within 2 hours
• Provide clear and professional communication
• Use the platform's messaging system for all communications
• Maintain customer confidentiality
• Handle disputes professionally and promptly
• Do not share customer personal information with third parties
              ''',
            ),

            _buildSection(
              colors,
              title: '7. Prohibited Activities',
              content: '''
Service providers are prohibited from:

• Providing false or misleading information
• Engaging in fraudulent or deceptive practices
• Harassing or discriminating against customers
• Sharing customer information without consent
• Providing services without proper licensing
• Circumventing platform fees or commission
• Using the platform for illegal activities
• Violating any applicable laws or regulations
              ''',
            ),

            _buildSection(
              colors,
              title: '8. Platform Usage',
              content: '''
Guidelines for platform usage:

• Use the platform only for legitimate business purposes
• Maintain accurate and up-to-date service information
• Keep your account credentials secure
• Report any suspicious or fraudulent activity
• Do not create multiple accounts for the same business
• Comply with all platform policies and guidelines
              ''',
            ),

            _buildSection(
              colors,
              title: '9. Termination and Suspension',
              content: '''
We may terminate or suspend your account for:

• Violation of these terms of service
• Poor service quality or customer complaints
• Fraudulent or deceptive practices
• Failure to maintain required licenses or insurance
• Repeated policy violations
• Extended periods of inactivity

You may terminate your account at any time by contacting support.
              ''',
            ),

            _buildSection(
              colors,
              title: '10. Liability and Indemnification',
              content: '''
Liability and indemnification terms:

• Service providers are responsible for their own services and actions
• RideRescue is not liable for service provider actions or omissions
• Service providers must maintain appropriate insurance coverage
• Service providers indemnify RideRescue against claims arising from their services
• Platform liability is limited to the amount paid for services
• Force majeure events may affect service availability
              ''',
            ),

            _buildSection(
              colors,
              title: '11. Intellectual Property',
              content: '''
Intellectual property rights:

• RideRescue retains ownership of the platform and its content
• Service providers retain ownership of their business information
• Use of RideRescue branding requires written permission
• Service providers may not reverse engineer or copy platform features
• User-generated content remains the property of the creator
              ''',
            ),

            _buildSection(
              colors,
              title: '12. Changes to Terms',
              content: '''
We may update these terms from time to time:

• Changes will be communicated through the platform
• Continued use constitutes acceptance of updated terms
• Material changes will require explicit consent
• Service providers will be notified of significant changes
• Previous terms remain in effect until new terms are accepted
              ''',
            ),

            _buildSection(
              colors,
              title: '13. Governing Law and Disputes',
              content: '''
Legal jurisdiction and dispute resolution:

• These terms are governed by the laws of the jurisdiction where RideRescue operates
• Disputes will be resolved through arbitration or mediation
• Service providers agree to jurisdiction in our primary business location
• Class action waivers may apply
• Small claims court actions are permitted
              ''',
            ),

            _buildSection(
              colors,
              title: '14. Contact Information',
              content: '''
For questions about these terms, contact us:

Email: legal@riderescue.com
Phone: +1 (555) 123-4567
Address: 123 Main Street, City, State 12345

We will respond to legal inquiries within 5 business days.
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
