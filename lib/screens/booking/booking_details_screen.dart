import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:math';
import 'package:riderescue_services/plugins/theme/colors.dart';
import 'package:riderescue_services/plugins/providers/app_provider.dart';
import 'package:riderescue_services/plugins/providers/network_provider.dart';
import 'package:riderescue_services/models/booking.dart';
import 'package:riderescue_services/constants/api_endpoints.dart';
import 'package:intl/intl.dart';
import 'dart:developer' as dev;

class BookingDetailsScreen extends ConsumerStatefulWidget {
  final String bookingId;

  const BookingDetailsScreen({super.key, required this.bookingId});

  @override
  ConsumerState<BookingDetailsScreen> createState() =>
      _BookingDetailsScreenState();
}

class _BookingDetailsScreenState extends ConsumerState<BookingDetailsScreen> {
  Booking? booking;
  bool isLoading = true;
  String? error;
  Position? currentPosition;
  GoogleMapController? mapController;
  Set<Marker> markers = {};

  @override
  void initState() {
    super.initState();
    _loadBookingDetails();
    _getCurrentLocation();
  }

  Future<void> _loadBookingDetails() async {
    setState(() {
      isLoading = true;
      error = null;
    });

    try {
      final appState = ref.read(appNotifierProvider);

      if (!appState.isAuthenticated || appState.authToken == null) {
        throw Exception('Authentication required');
      }

      final endpoint = ApiEndpoints.replaceParams(ApiEndpoints.bookingById, {
        'id': widget.bookingId,
      });

      final network = ref.read(networkProvider);
      final response = await network.get(endpoint, refresh: true);

      if (!response.success) {
        throw Exception(response.message ?? 'Failed to load booking details');
      }

      final data = response.data;
      if (data != null && data['request'] != null) {
        final loadedBooking = Booking.fromJson(data['request']);
        setState(() {
          booking = loadedBooking;
          isLoading = false;
        });
        _updateMapMarkers();
      } else {
        throw Exception('Invalid booking data');
      }
    } catch (e) {
      setState(() {
        error = 'Failed to load booking details: ${e.toString()}';
        isLoading = false;
      });
    }
  }

  Future<void> _getCurrentLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        return;
      }

      Position position = await Geolocator.getCurrentPosition();
      setState(() {
        currentPosition = position;
      });
      _updateMapMarkers();
    } catch (e) {
      dev.log('Error getting current location: $e');
    }
  }

  void _updateMapMarkers() {
    if (booking == null) return;

    final bookingLocation = booking!.location;

    markers.clear();

    // Add booking location marker
    markers.add(
      Marker(
        markerId: const MarkerId('booking_location'),
        position: LatLng(
          bookingLocation.coordinates[1].toDouble(), // latitude
          bookingLocation.coordinates[0].toDouble(), // longitude
        ),
        infoWindow: InfoWindow(
          title: 'Booking Location',
          snippet: 'Customer location',
        ),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
      ),
    );

    // Add current location marker if available
    if (currentPosition != null) {
      markers.add(
        Marker(
          markerId: const MarkerId('current_location'),
          position: LatLng(
            currentPosition!.latitude,
            currentPosition!.longitude,
          ),
          infoWindow: const InfoWindow(
            title: 'Your Location',
            snippet: 'Current position',
          ),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
        ),
      );
    }

    // Update map bounds
    if (mapController != null && markers.isNotEmpty) {
      _fitMapBounds();
    }
  }

  void _fitMapBounds() {
    if (markers.isEmpty) return;

    double minLat = double.infinity;
    double maxLat = -double.infinity;
    double minLng = double.infinity;
    double maxLng = -double.infinity;

    for (Marker marker in markers) {
      minLat = min(minLat, marker.position.latitude);
      maxLat = max(maxLat, marker.position.latitude);
      minLng = min(minLng, marker.position.longitude);
      maxLng = max(maxLng, marker.position.longitude);
    }

    mapController!.animateCamera(
      CameraUpdate.newLatLngBounds(
        LatLngBounds(
          southwest: LatLng(minLat, minLng),
          northeast: LatLng(maxLat, maxLng),
        ),
        50.0, // padding
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return Colors.orange;
      case 'accepted':
        return Colors.blue;
      case 'rejected':
        return Colors.red;
      case 'completed':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return Icons.schedule;
      case 'accepted':
        return Icons.check_circle;
      case 'rejected':
        return Icons.cancel;
      case 'completed':
        return Icons.done_all;
      default:
        return Icons.assignment;
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.fromBrightness(Theme.of(context).brightness);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Booking Details'),
        backgroundColor: colors.scaffoldBackground,
        elevation: 4,
        actions: [
          IconButton(
            icon: Icon(Icons.refresh, color: colors.text),
            onPressed: _loadBookingDetails,
          ),
        ],
      ),
      body: _buildBody(colors),
    );
  }

  Widget _buildBody(AppColors colors) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (error != null) {
      return _buildErrorView(colors);
    }

    if (booking == null) {
      return _buildErrorView(colors);
    }

    return _buildBookingDetails(colors);
  }

  Widget _buildErrorView(AppColors colors) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.red.withOpacity(0.5),
            ),
            const SizedBox(height: 16),
            Text(
              'Failed to Load Booking',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: colors.text,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              error ?? 'Unknown error occurred',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, color: colors.secondaryText),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _loadBookingDetails,
              icon: const Icon(Icons.refresh),
              label: const Text('Try Again'),
              style: ElevatedButton.styleFrom(
                backgroundColor: colors.primary,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBookingDetails(AppColors colors) {
    final statusColor = _getStatusColor(booking!.status);
    final formattedDate = DateFormat(
      'EEEE, MMMM dd, yyyy',
    ).format(booking!.scheduledDate);
    final formattedTime = DateFormat('hh:mm a').format(booking!.scheduledDate);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Status Card
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: BorderSide(color: statusColor.withOpacity(0.2), width: 1),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      _getStatusIcon(booking!.status),
                      color: statusColor,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Status',
                          style: TextStyle(
                            fontSize: 14,
                            color: colors.secondaryText,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          booking!.status.toUpperCase(),
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: statusColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Customer Information
          _buildInfoCard(
            colors,
            title: 'Customer Information',
            icon: Icons.person,
            children: [
              _buildInfoRow('Name', booking!.user.name),
              _buildInfoRow('Phone', booking!.user.phone),
              _buildInfoRow('Email', booking!.user.email),
            ],
          ),
          const SizedBox(height: 16),

          // Vehicle Information
          _buildInfoCard(
            colors,
            title: 'Vehicle Information',
            icon: Icons.directions_car,
            children: [
              _buildInfoRow('Make', booking!.vehicle.make),
              _buildInfoRow('Model', booking!.vehicle.model),
              _buildInfoRow('Year', booking!.vehicle.year.toString()),
              _buildInfoRow('Color', booking!.vehicle.color),
            ],
          ),
          const SizedBox(height: 16),

          // Service Details
          _buildInfoCard(
            colors,
            title: 'Service Details',
            icon: Icons.build,
            children: [
              _buildInfoRow('Scheduled Date', formattedDate),
              _buildInfoRow('Scheduled Time', formattedTime),
              _buildInfoRow('Issues', booking!.issues.join(', ')),
              if (booking!.description.isNotEmpty)
                _buildInfoRow('Description', booking!.description),
            ],
          ),
          const SizedBox(height: 16),

          // Location Map
          ...[
          _buildInfoCard(
            colors,
            title: 'Location',
            icon: Icons.location_on,
            children: [
              Container(
                height: 200,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: colors.secondaryText.withOpacity(0.2),
                  ),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: GoogleMap(
                    initialCameraPosition: CameraPosition(
                      target: LatLng(
                        booking!.location.coordinates[1].toDouble(),
                        booking!.location.coordinates[0].toDouble(),
                      ),
                      zoom: 15,
                    ),
                    markers: markers,
                    onMapCreated: (GoogleMapController controller) {
                      mapController = controller;
                      _updateMapMarkers();
                    },
                    myLocationEnabled: true,
                    myLocationButtonEnabled: true,
                    zoomControlsEnabled: false,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
        ],

          // Action Buttons
          if (booking!.status.toLowerCase() == 'pending') ...[
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _updateBookingStatus('accepted'),
                    icon: const Icon(Icons.check),
                    label: const Text('Accept'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _updateBookingStatus('rejected'),
                    icon: const Icon(Icons.close),
                    label: const Text('Reject'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
              ],
            ),
          ] else if (booking!.status.toLowerCase() == 'accepted') ...[
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => _updateBookingStatus('completed'),
                icon: const Icon(Icons.done_all),
                label: const Text('Mark as Completed'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildInfoCard(
    AppColors colors, {
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: colors.primary, size: 20),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: colors.text,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
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
                fontWeight: FontWeight.w500,
                color: colors.secondaryText,
              ),
            ),
          ),
          const SizedBox(width: 8),
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

  Future<void> _updateBookingStatus(String newStatus) async {
    try {
      final appState = ref.read(appNotifierProvider);

      if (!appState.isAuthenticated || appState.authToken == null) {
        throw Exception('Authentication required');
      }

      final endpoint = ApiEndpoints.replaceParams(ApiEndpoints.bookingById, {
        'id': widget.bookingId,
      });

      final network = ref.read(networkProvider);
      final response = await network.submit(
        method: HttpMethod.patch,
        path: '$endpoint/status',
        body: {'status': newStatus},
      );

      if (!response.success) {
        throw Exception(response.message ?? 'Failed to update booking status');
      }

      // Reload booking details
      await _loadBookingDetails();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Booking status updated to ${newStatus.toUpperCase()}',
            ),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update status: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
