import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:riderescue_services/models/booking.dart';
import 'package:riderescue_services/plugins/theme/colors.dart';
import 'package:riderescue_services/plugins/providers/network_provider.dart';
import 'package:riderescue_services/plugins/providers/app_provider.dart';
import 'package:intl/intl.dart';

class PairingScreen extends ConsumerStatefulWidget {
  const PairingScreen({super.key});

  @override
  ConsumerState<PairingScreen> createState() => _PairingScreenState();
}

class _PairingScreenState extends ConsumerState<PairingScreen> {
  final TextEditingController _pairingCodeController = TextEditingController();
  bool isLoading = false;
  String? error;
  Booking? previewBooking;

  @override
  void dispose() {
    _pairingCodeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.fromBrightness(Theme.of(context).brightness);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Pair with Customer'),
        backgroundColor: colors.scaffoldBackground,
        elevation: 4,
      ),
      body: _buildBody(colors),
    );
  }

  Widget _buildBody(AppColors colors) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Instructions Card
          _buildInstructionsCard(colors),
          const SizedBox(height: 16),

          // Pairing Code Input
          _buildPairingCodeInput(colors),
          const SizedBox(height: 16),

          // Preview Button
          if (_pairingCodeController.text.length == 5)
            _buildPreviewButton(colors),
          const SizedBox(height: 16),

          // Error Display
          if (error != null) _buildErrorCard(colors),
          if (error != null) const SizedBox(height: 16),

          // Booking Preview
          if (previewBooking != null) _buildBookingPreview(colors),
        ],
      ),
    );
  }

  Widget _buildInstructionsCard(AppColors colors) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.info_outline, color: colors.primary, size: 24),
                const SizedBox(width: 12),
                Text(
                  'How to Pair',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: colors.text,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              '1. Ask the customer for their 5-digit pairing code\n'
              '2. Enter the code below\n'
              '3. Review the booking details\n'
              '4. Accept the pairing to start the service',
              style: TextStyle(
                fontSize: 14,
                color: colors.secondaryText,
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPairingCodeInput(AppColors colors) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.qr_code, color: colors.primary, size: 24),
                const SizedBox(width: 12),
                Text(
                  'Enter Pairing Code',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: colors.text,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _pairingCodeController,
              decoration: InputDecoration(
                hintText: 'Enter 5-digit code (e.g., A1B2C)',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                prefixIcon: Icon(Icons.code, color: colors.primary),
              ),
              maxLength: 5,
              onChanged: (value) {
                setState(() {
                  error = null;
                  previewBooking = null;
                });
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPreviewButton(AppColors colors) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: _previewBooking,
        icon: const Icon(Icons.preview),
        label: const Text('Preview Booking'),
        style: ElevatedButton.styleFrom(
          backgroundColor: colors.primary,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 12),
        ),
      ),
    );
  }

  Widget _buildErrorCard(AppColors colors) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: colors.error.withOpacity(0.1),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(Icons.error_outline, color: colors.error, size: 24),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                error!,
                style: TextStyle(fontSize: 14, color: colors.error),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBookingPreview(AppColors colors) {
    if (previewBooking == null) return const SizedBox.shrink();

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.assignment, color: colors.primary, size: 24),
                const SizedBox(width: 12),
                Text(
                  'Booking Preview',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: colors.text,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Customer Info
            _buildDetailRow('Customer', previewBooking!.user.name),
            _buildDetailRow('Phone', previewBooking!.user.phone),
            _buildDetailRow('Email', previewBooking!.user.email),

            const SizedBox(height: 12),

            // Vehicle Info
            _buildDetailRow(
              'Vehicle',
              '${previewBooking!.vehicle.make} ${previewBooking!.vehicle.model}',
            ),
            _buildDetailRow('Year', previewBooking!.vehicle.year.toString()),
            _buildDetailRow('Color', previewBooking!.vehicle.color),
            _buildDetailRow('Plate', previewBooking!.vehicle.numberPlate),

            const SizedBox(height: 12),

            // Service Info
            _buildDetailRow(
              'Scheduled Date',
              DateFormat('MMM dd, yyyy').format(previewBooking!.scheduledDate),
            ),
            _buildDetailRow(
              'Scheduled Time',
              DateFormat('hh:mm a').format(previewBooking!.scheduledDate),
            ),
            _buildDetailRow('Description', previewBooking!.description),
            if (previewBooking!.issues.isNotEmpty)
              _buildDetailRow('Issues', previewBooking!.issues.join(', ')),

            const SizedBox(height: 16),

            // Accept Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _acceptPairing,
                icon: const Icon(Icons.check_circle),
                label: const Text('Accept Pairing'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    final colors = AppColors.fromBrightness(Theme.of(context).brightness);

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 14,
                color: colors.secondaryText,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(fontSize: 14, color: colors.text),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _previewBooking() async {
    if (_pairingCodeController.text.length != 5) {
      setState(() {
        error = 'Please enter a 5-digit pairing code';
      });
      return;
    }

    setState(() {
      isLoading = true;
      error = null;
    });

    try {
      final appState = ref.read(appNotifierProvider);

      if (!appState.isAuthenticated || appState.authToken == null) {
        throw Exception('Authentication required');
      }

      final endpoint =
          '/bookings/pairing/preview?pairingCode=${_pairingCodeController.text}';

      final network = ref.read(networkProvider);
      final response = await network.get(endpoint);

      if (!response.success) {
        throw Exception(response.message ?? 'Failed to preview booking');
      }

      final data = response.data;
      if (data != null && data['request'] != null) {
        try {
          final booking = Booking.fromJson(data['request']);
          if (mounted) {
            setState(() {
              previewBooking = booking;
              isLoading = false;
            });
          }
        } catch (e) {
          throw Exception('Invalid booking data format: ${e.toString()}');
        }
      } else {
        throw Exception('Invalid response format');
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          error = 'Failed to preview booking: ${e.toString()}';
          isLoading = false;
        });
      }
    }
  }

  Future<void> _acceptPairing() async {
    if (previewBooking == null) return;

    setState(() {
      isLoading = true;
      error = null;
    });

    try {
      final appState = ref.read(appNotifierProvider);

      if (!appState.isAuthenticated || appState.authToken == null) {
        throw Exception('Authentication required');
      }

      final endpoint = '/bookings/pairing/accept';

      final network = ref.read(networkProvider);
      final response = await network.submit(
        method: HttpMethod.post,
        path: endpoint,
        body: {'pairingCode': _pairingCodeController.text},
      );

      if (!response.success) {
        throw Exception(response.message ?? 'Failed to accept pairing');
      }

      // Show success message and navigate back
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Successfully paired with customer!'),
            backgroundColor: Colors.green,
          ),
        );
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          error = 'Failed to accept pairing: ${e.toString()}';
          isLoading = false;
        });
      }
    }
  }
}
