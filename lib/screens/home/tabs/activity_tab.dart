import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:riderescue_services/plugins/theme/colors.dart';
import 'package:riderescue_services/plugins/providers/app_provider.dart';
import 'package:riderescue_services/plugins/providers/network_provider.dart';
import 'package:riderescue_services/models/booking.dart';
import 'package:riderescue_services/models/service.dart';
import 'package:riderescue_services/constants/api_endpoints.dart';
import 'package:riderescue_services/constants/route_names.dart';

class ActivityTab extends ConsumerStatefulWidget {
  const ActivityTab({super.key});

  @override
  ConsumerState<ActivityTab> createState() => _ActivityTabState();
}

class _ActivityTabState extends ConsumerState<ActivityTab> {
  List<Booking> bookings = [];
  bool isLoading = false;
  String? error;

  @override
  void initState() {
    super.initState();
    _loadBookings();
  }

  Future<void> _loadBookings({bool? refresh = false}) async {
    final activeService = ref.read(activeServiceProvider);

    if (activeService == null) {
      setState(() {
        error = 'No active service found';
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

      final endpoint = ApiEndpoints.serviceBookings.replaceAll(
        '{serviceId}',
        activeService.id!,
      );

      final network = ref.read(networkProvider);
      final response = await network.get(endpoint, refresh: refresh ?? false);

      if (!response.success) {
        throw Exception(response.message ?? 'Failed to load bookings');
      }

      final data = response.data;
      if (data != null && data['bookings'] != null) {
        final bookingsData = data['bookings'] as List<dynamic>;
        final loadedBookings = bookingsData
            .map((booking) => Booking.fromJson(booking))
            .toList();

        setState(() {
          bookings = loadedBookings;
          isLoading = false;
        });
      } else {
        setState(() {
          bookings = [];
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        error = 'Failed to load bookings: ${e.toString()}';
        isLoading = false;
      });
    }
  }

  String _getTimeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 0) {
      return '${difference.inDays} day${difference.inDays == 1 ? '' : 's'} ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hour${difference.inHours == 1 ? '' : 's'} ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} minute${difference.inMinutes == 1 ? '' : 's'} ago';
    } else {
      return 'Just now';
    }
  }

  IconData _getBookingIcon(String status) {
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

  Color _getBookingColor(String status, AppColors colors) {
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
        return colors.secondaryText;
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.fromBrightness(Theme.of(context).brightness);
    final activeService = ref.watch(activeServiceProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Activity'),
        backgroundColor: colors.scaffoldBackground,
        elevation: 4,
        actions: [
          IconButton(
            icon: Icon(Icons.refresh, color: colors.text),
            onPressed: () => _loadBookings(refresh: true),
          ),
        ],
      ),
      body: _buildBody(colors, activeService),
    );
  }

  Widget _buildBody(AppColors colors, Service? activeService) {
    if (activeService == null) {
      return _buildNoServiceView(colors);
    }

    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (error != null) {
      return _buildErrorView(colors);
    }

    if (bookings.isEmpty) {
      return _buildEmptyView(colors);
    }

    return _buildBookingsList(colors);
  }

  Widget _buildNoServiceView(AppColors colors) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.business_center_outlined,
              size: 64,
              color: colors.secondaryText.withOpacity(0.5),
            ),
            const SizedBox(height: 16),
            Text(
              'No Active Service',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: colors.text,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'You need to create a service profile first to see booking history',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, color: colors.secondaryText),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => context.push(Routes.onboardingService),
              icon: const Icon(Icons.add),
              label: const Text('Create Service Profile'),
              style: ElevatedButton.styleFrom(
                backgroundColor: colors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
              ),
            ),
          ],
        ),
      ),
    );
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
              'Failed to Load Bookings',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: colors.text,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              error!,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, color: colors.secondaryText),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _loadBookings,
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

  Widget _buildEmptyView(AppColors colors) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.history,
              size: 64,
              color: colors.secondaryText.withOpacity(0.5),
            ),
            const SizedBox(height: 16),
            Text(
              'No Bookings Yet',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: colors.text,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Customer requests will appear here once you start receiving bookings',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, color: colors.secondaryText),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBookingsList(AppColors colors) {
    return RefreshIndicator(
      onRefresh: () => _loadBookings(refresh: true),
      child: ListView.separated(
        padding: const EdgeInsets.all(0),
        itemCount: bookings.length,
        separatorBuilder: (_, __) =>
            Divider(height: 1, color: colors.border.withOpacity(0.2)),
        itemBuilder: (context, index) {
          final booking = bookings[index];
          return _buildActivityItem(booking, colors);
        },
      ),
    );
  }

  Widget _buildActivityItem(Booking booking, AppColors colors) {
    final statusColor = _getBookingColor(booking.status, colors);
    final customer = booking.user;
    final vehicle = booking.vehicle;

    return Column(
      children: [
        InkWell(
          onTap: () {
            context.push('/booking/${booking.id}');
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            child: Row(
              children: [
                // Avatar with status icon overlay
                Stack(
                  children: [
                    CircleAvatar(
                      radius: 24,
                      backgroundColor: colors.primary.withOpacity(0.1),
                      child: Text(
                        customer.name.isNotEmpty
                            ? customer.name[0].toUpperCase()
                            : 'C',
                        style: TextStyle(
                          color: colors.primary,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        width: 18,
                        height: 18,
                        decoration: BoxDecoration(
                          color: statusColor,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2),
                        ),
                        child: Icon(
                          _getBookingIcon(booking.status),
                          size: 10,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 12),

                // Activity content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Main activity description
                      RichText(
                        text: TextSpan(
                          style: TextStyle(
                            fontSize: 14,
                            color: colors.text,
                            height: 1.4,
                          ),
                          children: [
                            TextSpan(
                              text: customer.name,
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const TextSpan(text: ' • '),
                            TextSpan(
                              text: '${vehicle.make} ${vehicle.model}',
                              style: TextStyle(
                                color: colors.primary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            if (vehicle.numberPlate.isNotEmpty) ...[
                              const TextSpan(text: ' • '),
                              TextSpan(
                                text: vehicle.numberPlate,
                                style: TextStyle(
                                  color: colors.secondaryText,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ],
                        ),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),

                      // Description in one line
                      if (booking.description.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(
                          booking.description,
                          style: TextStyle(
                            fontSize: 12,
                            color: colors.secondaryText,
                          ),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                      ],

                      // Metadata row
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Text(
                            _getTimeAgo(booking.createdAt ?? DateTime.now()),
                            style: TextStyle(
                              fontSize: 12,
                              color: colors.secondaryText,
                            ),
                          ),
                          Container(
                            margin: const EdgeInsets.symmetric(horizontal: 6),
                            width: 2,
                            height: 2,
                            decoration: BoxDecoration(
                              color: colors.secondaryText.withOpacity(0.5),
                              shape: BoxShape.circle,
                            ),
                          ),
                          Icon(
                            Icons.directions_car,
                            size: 12,
                            color: colors.secondaryText,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            booking.status.toUpperCase(),
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: statusColor,
                            ),
                          ),
                        ],
                      ),

                      // Issues as individual chips
                      if (booking.issues.isNotEmpty) ...[
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            ...booking.issues
                                .take(2)
                                .map(
                                  (issue) => Container(
                                    margin: const EdgeInsets.only(right: 6),
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: colors.primary.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color: colors.primary.withOpacity(0.3),
                                        width: 1,
                                      ),
                                    ),
                                    child: Text(
                                      issue,
                                      style: TextStyle(
                                        fontSize: 10,
                                        color: colors.primary,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                ),
                            if (booking.issues.length > 2)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: colors.secondaryText.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  '${booking.issues.length - 2} more',
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: colors.secondaryText,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),

        // Action buttons for pending bookings
        if (!booking.isPaired && booking.status == 'pending')
          Padding(
            padding: const EdgeInsets.only(left: 60, right: 16, bottom: 12),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => _navigateToPairing(),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      side: BorderSide(color: colors.border),
                      minimumSize: const Size(0, 32),
                    ),
                    child: const Text(
                      'Decline',
                      style: TextStyle(fontSize: 12),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => _navigateToPairing(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: colors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      minimumSize: const Size(0, 32),
                    ),
                    child: const Text(
                      'Approve',
                      style: TextStyle(fontSize: 12),
                    ),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  void _navigateToPairing() {
    context.push('/pairing');
  }
}
