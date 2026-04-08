import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riderescue_services/plugins/utils/background_service.dart';

class RetryStatusWidget extends ConsumerStatefulWidget {
  const RetryStatusWidget({super.key});

  @override
  ConsumerState<RetryStatusWidget> createState() => _RetryStatusWidgetState();
}

class _RetryStatusWidgetState extends ConsumerState<RetryStatusWidget> {
  Map<String, dynamic> _retryStatus = {};
  Timer? _updateTimer;

  @override
  void initState() {
    super.initState();
    _loadRetryStatus();
    _startUpdateTimer();
  }

  @override
  void dispose() {
    _updateTimer?.cancel();
    super.dispose();
  }

  void _startUpdateTimer() {
    _updateTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
      _loadRetryStatus();
    });
  }

  Future<void> _loadRetryStatus() async {
    final status = await backgroundService.getRetryStatus();
    if (mounted) {
      setState(() {
        _retryStatus = status;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final wasLive = _retryStatus['wasLive'] ?? false;
    final retryCount = _retryStatus['retryCount'] ?? 0;
    final maxRetries = _retryStatus['maxRetries'] ?? 6;
    final timeExceeded = _retryStatus['timeExceeded'] ?? false;
    final isRetrying = _retryStatus['isRetrying'] ?? false;
    final isConnected = _retryStatus['isConnected'] ?? false;

    // Don't show widget if not retrying and not in a retry state
    if (!wasLive && !isRetrying && retryCount == 0) {
      return const SizedBox.shrink();
    }

    return Card(
      margin: const EdgeInsets.all(16.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.sync,
                  color: isRetrying ? Colors.orange : Colors.grey,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Connection Status',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      Text(
                        _getStatusText(
                          wasLive,
                          isRetrying,
                          timeExceeded,
                          isConnected,
                        ),
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                if (isRetrying)
                  const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
              ],
            ),
            if (isRetrying && !timeExceeded) ...[
              const SizedBox(height: 12),
              LinearProgressIndicator(
                value: retryCount / maxRetries,
                backgroundColor: Colors.grey[300],
                valueColor: AlwaysStoppedAnimation<Color>(
                  retryCount >= maxRetries ? Colors.red : Colors.orange,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Retry attempt $retryCount of $maxRetries',
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
              ),
            ],
            if (timeExceeded) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(Icons.error_outline, color: Colors.red, size: 16),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Retry time limit exceeded. Please manually reconnect.',
                        style: Theme.of(
                          context,
                        ).textTheme.bodySmall?.copyWith(color: Colors.red[700]),
                      ),
                    ),
                  ],
                ),
              ),
            ],
            if (wasLive && !isRetrying && !timeExceeded && retryCount > 0) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info_outline, color: Colors.blue, size: 16),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Connection restored successfully',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.blue[700],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _getStatusText(
    bool wasLive,
    bool isRetrying,
    bool timeExceeded,
    bool isConnected,
  ) {
    if (timeExceeded) {
      return 'Retry time limit exceeded';
    } else if (isRetrying) {
      return 'Attempting to reconnect...';
    } else if (wasLive && !isConnected) {
      return 'Disconnected while live - will retry automatically';
    } else if (isConnected) {
      return 'Connected successfully';
    } else {
      return 'Connection status unknown';
    }
  }
}
