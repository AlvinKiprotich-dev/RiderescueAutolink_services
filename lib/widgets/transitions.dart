import 'package:flutter/material.dart';

/// Improved slide transition animation that only goes forward
/// This prevents funny transitions by using a simple slide from right to left
Widget slideTransition(
  BuildContext context,
  Animation<double> animation,
  Animation<double> secondaryAnimation,
  Widget child,
) {
  // Only animate the incoming page, not the outgoing page
  final slideAnimation = Tween<Offset>(
    begin: const Offset(1.0, 0.0), // Start from right
    end: Offset.zero, // End at center
  ).animate(CurvedAnimation(parent: animation, curve: Curves.easeInOut));

  return SlideTransition(position: slideAnimation, child: child);
}

/// Fade transition for subtle page changes
Widget fadeTransition(
  BuildContext context,
  Animation<double> animation,
  Animation<double> secondaryAnimation,
  Widget child,
) {
  return FadeTransition(
    opacity: CurvedAnimation(parent: animation, curve: Curves.easeInOut),
    child: child,
  );
}

/// Scale transition for modal-like pages
Widget scaleTransition(
  BuildContext context,
  Animation<double> animation,
  Animation<double> secondaryAnimation,
  Widget child,
) {
  return ScaleTransition(
    scale: CurvedAnimation(parent: animation, curve: Curves.easeInOut),
    child: child,
  );
}
