import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:go_router/go_router.dart';
// import 'package:riderescue_services/constants/route_names.dart';
import '../plugins/theme/colors.dart';
import '../plugins/providers/app_provider.dart';
// import '../models/service.dart';
import '../widgets/notification_list.dart';
// import 'dart:developer' as dev;

class TopActions extends ConsumerStatefulWidget {
  final AppColors colors;

  const TopActions({super.key, required this.colors});

  @override
  ConsumerState<TopActions> createState() => _TopActionsState();
}

class _TopActionsState extends ConsumerState<TopActions> {
  @override
  Widget build(BuildContext context) {
    // final activeService = ref.watch(activeServiceProvider);
    // final serviceProfiles = ref.watch(serviceProfilesProvider);
    // final isLive = ref.watch(isLiveProvider);
    final unreadCount = ref.watch(unreadNotificationCountProvider);

    // Check if user has any service profiles
    // final hasServiceProfiles = serviceProfiles.isNotEmpty;
    // final hasActiveService = activeService != null;

    // Check if service is approved (can go live)
    // final canGoLive = hasActiveService && activeService.status == 'approved';

    return Row(
      children: [
        // Notification icon with badge
        Stack(
          children: [
            IconButton(
              onPressed: () => _showNotificationList(context),
              icon: Icon(
                Icons.notifications_outlined,
                color: widget.colors.text,
                size: 24,
              ),
              tooltip: 'Notifications',
            ),
            if (unreadCount > 0)
              Positioned(
                right: 8,
                top: 8,
                child: Container(
                  padding: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  constraints: const BoxConstraints(
                    minWidth: 16,
                    minHeight: 16,
                  ),
                  child: Text(
                    unreadCount > 99 ? '99+' : unreadCount.toString(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(width: 8),

        // // Only show live status if user has an approved active service
        // if (canGoLive) ...[
        //   InkWell(
        //     onTap: () => _showGoLiveSheet(context),
        //     borderRadius: BorderRadius.circular(14),
        //     child: Container(
        //       padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        //       decoration: BoxDecoration(
        //         color: widget.colors.card,
        //         borderRadius: BorderRadius.circular(14),
        //         border: Border.all(
        //           color: widget.colors.primary.withOpacity(0.5),
        //           width: 1,
        //         ),
        //       ),
        //       child: Row(
        //         mainAxisSize: MainAxisSize.min,
        //         children: [
        //           Icon(
        //             Icons.keyboard_arrow_down,
        //             size: 14,
        //             color: widget.colors.text,
        //           ),
        //           const SizedBox(width: 2),
        //           Text(
        //             'Active',
        //             style: TextStyle(
        //               color: widget.colors.text,
        //               fontWeight: FontWeight.w600,
        //               fontSize: 11,
        //             ),
        //           ),
        //           const SizedBox(width: 4),
        //           Container(
        //             width: 7,
        //             height: 7,
        //             decoration: BoxDecoration(
        //               color: isLive ? Colors.greenAccent : Colors.grey,
        //               shape: BoxShape.circle,
        //             ),
        //           ),
        //         ],
        //       ),
        //     ),
        //   ),
        //   const SizedBox(width: 12),
        // ],

        // // Show enroll button if no service profiles, otherwise show profile button
        // if (!hasServiceProfiles)
        //   // Enroll button
        //   InkWell(
        //     onTap: () => _navigateToServiceOnboarding(context),
        //     borderRadius: BorderRadius.circular(14),
        //     child: Container(
        //       padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        //       decoration: BoxDecoration(
        //         color: widget.colors.primary,
        //         borderRadius: BorderRadius.circular(14),
        //       ),
        //       child: Row(
        //         mainAxisSize: MainAxisSize.min,
        //         children: [
        //           Icon(Icons.add, size: 16, color: Colors.white),
        //           const SizedBox(width: 6),
        //           Text(
        //             'Enroll',
        //             style: TextStyle(
        //               color: Colors.white,
        //               fontWeight: FontWeight.w600,
        //               fontSize: 12,
        //             ),
        //           ),
        //         ],
        //       ),
        //     ),
        //   )
        // else
        //   // Profile button
        //   InkWell(
        //     onTap: () => _showProfileSheet(context),
        //     borderRadius: BorderRadius.circular(14),
        //     child: Container(
        //       padding: const EdgeInsets.symmetric(vertical: 4.5),
        //       decoration: BoxDecoration(
        //         color: widget.colors.primary.withOpacity(0.2),
        //         borderRadius: BorderRadius.circular(14),
        //       ),
        //       child: Row(
        //         children: [
        //           const SizedBox(width: 8),
        //           CircleAvatar(
        //             radius: 12,
        //             backgroundImage: NetworkImage(
        //               _getServicePhoto(activeService),
        //             ),
        //             backgroundColor: widget.colors.primary.withOpacity(0.1),
        //             onBackgroundImageError: (exception, stackTrace) {
        //               // Handle image loading errors
        //               dev.log('Failed to load service photo: $exception');
        //             },
        //           ),
        //           const SizedBox(width: 8),
        //           const Icon(Icons.keyboard_arrow_down_rounded, size: 22),
        //           const SizedBox(width: 4),
        //         ],
        //       ),
        //     ),
        //   ),
        const SizedBox(width: 12),
      ],
    );
  }

  // Helper method to safely get service photo with fallback
  // String _getServicePhoto(Service? service) {
  //   if (service?.photo.isNotEmpty == true) {
  //     return service!.photo;
  //   }
  //   return 'https://via.placeholder.com/40';
  // }

  // Navigate to service onboarding page
  // void _navigateToServiceOnboarding(BuildContext context) {
  //   // Navigate to service onboarding page
  //   context.push(Routes.onboardingService);
  // }

  // void _showGoLiveSheet(BuildContext context) {
  //   final isLive = ref.read(isLiveProvider);

  //   showModalBottomSheet(
  //     context: context,
  //     shape: const RoundedRectangleBorder(
  //       borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
  //     ),
  //     builder: (context) {
  //       return Padding(
  //         padding: const EdgeInsets.all(24.0),
  //         child: Column(
  //           mainAxisSize: MainAxisSize.min,
  //           children: [
  //             Icon(
  //               isLive ? Icons.stop_circle : Icons.live_tv,
  //               size: 40,
  //               color: isLive
  //                   ? Theme.of(context).colorScheme.error
  //                   : Theme.of(context).colorScheme.primary,
  //             ),
  //             const SizedBox(height: 16),
  //             Text(
  //               isLive ? 'Stop Live' : 'Go Live',
  //               style: const TextStyle(
  //                 fontWeight: FontWeight.bold,
  //                 fontSize: 18,
  //               ),
  //             ),
  //             const SizedBox(height: 8),
  //             Text(
  //               isLive
  //                   ? 'Do you want to stop accepting service requests?'
  //                   : 'Do you want to go live and start accepting service requests now?',
  //               textAlign: TextAlign.center,
  //             ),
  //             const SizedBox(height: 24),
  //             Row(
  //               mainAxisAlignment: MainAxisAlignment.spaceEvenly,
  //               children: [
  //                 TextButton(
  //                   onPressed: () => Navigator.of(context).pop(),
  //                   child: const Text('Cancel'),
  //                 ),
  //                 ElevatedButton(
  //                   onPressed: () {
  //                     try {
  //                       ref
  //                           .read(appNotifierProvider.notifier)
  //                           .setLiveStatus(!isLive);
  //                       Navigator.of(context).pop();
  //                     } catch (e) {
  //                       dev.log('Error setting live status: $e');
  //                       // Show error snackbar or handle error gracefully
  //                       ScaffoldMessenger.of(context).showSnackBar(
  //                         SnackBar(
  //                           content: Text('Failed to update live status: $e'),
  //                           backgroundColor: Theme.of(
  //                             context,
  //                           ).colorScheme.error,
  //                         ),
  //                       );
  //                     }
  //                   },
  //                   style: ElevatedButton.styleFrom(
  //                     backgroundColor: isLive
  //                         ? Theme.of(context).colorScheme.error
  //                         : Theme.of(context).colorScheme.primary,
  //                     foregroundColor: Theme.of(context).colorScheme.onPrimary,
  //                   ),
  //                   child: Text(isLive ? 'Stop' : 'Go Live'),
  //                 ),
  //               ],
  //             ),
  //           ],
  //         ),
  //       );
  //     },
  //   );
  // }

  // void _showProfileSheet(BuildContext context) {
  //   final activeService = ref.read(activeServiceProvider);
  //   final serviceProfiles = ref.read(serviceProfilesProvider);

  //   showModalBottomSheet(
  //     context: context,
  //     isScrollControlled: true,
  //     shape: const RoundedRectangleBorder(
  //       borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
  //     ),
  //     builder: (context) {
  //       return Consumer(
  //         builder: (context, ref, _) {
  //           return Padding(
  //             padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
  //             child: Column(
  //               mainAxisSize: MainAxisSize.min,
  //               crossAxisAlignment: CrossAxisAlignment.start,
  //               children: [
  //                 Text(
  //                   'Switch service profile',
  //                   style: TextStyle(
  //                     color: Theme.of(
  //                       context,
  //                     ).colorScheme.onSurface.withOpacity(0.7),
  //                     fontSize: 16,
  //                     fontWeight: FontWeight.w600,
  //                   ),
  //                 ),
  //                 const SizedBox(height: 16),
  //                 if (serviceProfiles.isNotEmpty)
  //                   ...serviceProfiles.map(
  //                     (service) => _ServiceProfileTile(
  //                       service: service,
  //                       isActive: activeService?.id == service.id,
  //                       onTap: () => _confirmProfileSwitch(context, service),
  //                     ),
  //                   )
  //                 else
  //                   Column(
  //                     children: [
  //                       Text(
  //                         'No service profiles available',
  //                         style: TextStyle(
  //                           color: Theme.of(
  //                             context,
  //                           ).colorScheme.onSurface.withOpacity(0.7),
  //                         ),
  //                       ),
  //                       const SizedBox(height: 12),
  //                       ElevatedButton.icon(
  //                         onPressed: () {
  //                           Navigator.of(context).pop();
  //                           _navigateToServiceOnboarding(context);
  //                         },
  //                         icon: const Icon(Icons.add, size: 16),
  //                         label: const Text('Enroll as Service Provider'),
  //                         style: ElevatedButton.styleFrom(
  //                           backgroundColor: widget.colors.primary,
  //                           foregroundColor: Colors.white,
  //                           shape: RoundedRectangleBorder(
  //                             borderRadius: BorderRadius.circular(8),
  //                           ),
  //                         ),
  //                       ),
  //                     ],
  //                   ),
  //                 const SizedBox(height: 18),
  //               ],
  //             ),
  //           );
  //         },
  //       );
  //     },
  //   );
  // }

  // void _confirmProfileSwitch(BuildContext context, Service newService) {
  //   final currentService = ref.read(activeServiceProvider);

  //   // Don't show confirmation if switching to the same service
  //   if (currentService?.id == newService.id) {
  //     Navigator.of(context).pop();
  //     return;
  //   }

  //   showDialog(
  //     context: context,
  //     builder: (BuildContext context) {
  //       return AlertDialog(
  //         title: const Text('Switch Service Profile'),
  //         content: Column(
  //           mainAxisSize: MainAxisSize.min,
  //           crossAxisAlignment: CrossAxisAlignment.start,
  //           children: [
  //             Text(
  //               'Are you sure you want to switch to "${newService.name.isNotEmpty ? newService.name : 'Unnamed Service'}"?',
  //               style: TextStyle(
  //                 color: Theme.of(context).colorScheme.onSurface,
  //               ),
  //             ),
  //             const SizedBox(height: 16),
  //             Container(
  //               padding: const EdgeInsets.all(12),
  //               decoration: BoxDecoration(
  //                 color: Theme.of(
  //                   context,
  //                 ).colorScheme.surfaceVariant.withOpacity(0.5),
  //                 borderRadius: BorderRadius.circular(8),
  //               ),
  //               child: Column(
  //                 crossAxisAlignment: CrossAxisAlignment.start,
  //                 children: [
  //                   Text(
  //                     'This will:',
  //                     style: TextStyle(
  //                       fontWeight: FontWeight.w600,
  //                       color: Theme.of(context).colorScheme.onSurfaceVariant,
  //                     ),
  //                   ),
  //                   const SizedBox(height: 8),
  //                   _buildWarningItem(
  //                     icon: Icons.stop_circle,
  //                     text: 'Stop your current live status',
  //                     context: context,
  //                   ),
  //                   _buildWarningItem(
  //                     icon: Icons.swap_horiz,
  //                     text: 'Switch to the new service profile',
  //                     context: context,
  //                   ),
  //                   _buildWarningItem(
  //                     icon: Icons.info_outline,
  //                     text: 'Update your active service settings',
  //                     context: context,
  //                   ),
  //                 ],
  //               ),
  //             ),
  //           ],
  //         ),
  //         actions: [
  //           TextButton(
  //             onPressed: () => Navigator.of(context).pop(),
  //             child: const Text('Cancel'),
  //           ),
  //           ElevatedButton(
  //             onPressed: () {
  //               try {
  //                 ref
  //                     .read(appNotifierProvider.notifier)
  //                     .setActiveService(newService);
  //                 Navigator.of(context).pop(); // Close dialog
  //                 Navigator.of(context).pop(); // Close bottom sheet
  //               } catch (e) {
  //                 dev.log('Error setting active service: $e');
  //                 Navigator.of(context).pop(); // Close dialog
  //                 ScaffoldMessenger.of(context).showSnackBar(
  //                   SnackBar(
  //                     content: Text('Failed to switch service profile: $e'),
  //                     backgroundColor: Theme.of(context).colorScheme.error,
  //                   ),
  //                 );
  //               }
  //             },
  //             style: ElevatedButton.styleFrom(
  //               backgroundColor: Theme.of(context).colorScheme.primary,
  //               foregroundColor: Theme.of(context).colorScheme.onPrimary,
  //             ),
  //             child: const Text('Switch'),
  //           ),
  //         ],
  //       );
  //     },
  //   );
  // }

  // Widget _buildWarningItem({
  //   required IconData icon,
  //   required String text,
  //   required BuildContext context,
  // }) {
  //   return Padding(
  //     padding: const EdgeInsets.only(bottom: 4),
  //     child: Row(
  //       children: [
  //         Icon(
  //           icon,
  //           size: 16,
  //           color: Theme.of(context).colorScheme.onSurfaceVariant,
  //         ),
  //         const SizedBox(width: 8),
  //         Expanded(
  //           child: Text(
  //             text,
  //             style: TextStyle(
  //               fontSize: 14,
  //               color: Theme.of(context).colorScheme.onSurfaceVariant,
  //             ),
  //           ),
  //         ),
  //       ],
  //     ),
  //   );
  // }

  void _showNotificationList(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
      ),
      builder: (context) => const NotificationList(),
    );
  }
}

// class _ServiceProfileTile extends StatelessWidget {
//   final Service service;
//   final bool isActive;
//   final VoidCallback onTap;

//   const _ServiceProfileTile({
//     required this.service,
//     required this.isActive,
//     required this.onTap,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return InkWell(
//       onTap: onTap,
//       child: Container(
//         margin: const EdgeInsets.only(bottom: 8),
//         padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
//         decoration: BoxDecoration(
//           color: isActive
//               ? Theme.of(context).colorScheme.primary.withOpacity(0.1)
//               : Colors.transparent,
//           borderRadius: BorderRadius.circular(8),
//           border: Border.all(
//             color: isActive
//                 ? Theme.of(context).colorScheme.primary
//                 : Theme.of(context).colorScheme.outline.withOpacity(0.3),
//             width: 1,
//           ),
//         ),
//         child: Row(
//           children: [
//             CircleAvatar(
//               radius: 16,
//               backgroundImage: NetworkImage(
//                 service.photo.isNotEmpty
//                     ? service.photo
//                     : 'https://via.placeholder.com/32',
//               ),
//               backgroundColor: Theme.of(
//                 context,
//               ).colorScheme.surfaceVariant.withOpacity(0.3),
//               onBackgroundImageError: (exception, stackTrace) {
//                 dev.log('Failed to load service profile photo: $exception');
//               },
//             ),
//             const SizedBox(width: 10),
//             Expanded(
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text(
//                     service.name.isNotEmpty ? service.name : 'Unnamed Service',
//                     style: TextStyle(
//                       fontWeight: FontWeight.bold,
//                       color: isActive
//                           ? Theme.of(context).colorScheme.primary
//                           : Theme.of(context).colorScheme.onSurface,
//                     ),
//                   ),
//                   Text(
//                     service.type.isNotEmpty ? service.type : 'Unknown Type',
//                     style: TextStyle(
//                       fontSize: 12,
//                       color: Theme.of(
//                         context,
//                       ).colorScheme.onSurface.withOpacity(0.7),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//             if (isActive)
//               Icon(
//                 Icons.check_circle,
//                 color: Theme.of(context).colorScheme.primary,
//                 size: 20,
//               ),
//           ],
//         ),
//       ),
//     );
//   }
// }
