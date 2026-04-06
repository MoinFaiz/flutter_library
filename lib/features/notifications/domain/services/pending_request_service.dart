import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_library/core/theme/app_colors.dart';
import 'package:flutter_library/features/cart/domain/entities/cart_request.dart';
import 'package:flutter_library/features/cart/domain/repositories/cart_repository.dart';
import 'package:flutter_library/features/cart/domain/usecases/accept_cart_request_usecase.dart';
import 'package:flutter_library/features/cart/domain/usecases/reject_cart_request_usecase.dart';
import 'package:flutter_library/features/notifications/presentation/widgets/pending_request_dialog.dart';

/// Service to check for pending requests and show popup dialog
class PendingRequestService {
  final CartRepository cartRepository;
  final AcceptCartRequestUseCase acceptCartRequestUseCase;
  final RejectCartRequestUseCase rejectCartRequestUseCase;

  // Track processed requests to prevent infinite loops
  final Set<String> _processedRequestIds = {};
  bool _isCheckingRequests = false;
  int _consecutiveChecks = 0;
  static const int _maxConsecutiveChecks = 5;

  PendingRequestService({
    required this.cartRepository,
    required this.acceptCartRequestUseCase,
    required this.rejectCartRequestUseCase,
  });

  /// Check for pending requests and show dialog if any exist
  Future<void> checkAndShowPendingRequests(BuildContext context, {bool isAutoCheck = false}) async {
    // Prevent multiple simultaneous checks
    if (_isCheckingRequests) {
      debugPrint('Request check already in progress, skipping...');
      return;
    }

    // Prevent infinite auto-check loops
    if (isAutoCheck) {
      _consecutiveChecks++;
      if (_consecutiveChecks > _maxConsecutiveChecks) {
        debugPrint('Max consecutive checks reached, stopping auto-check');
        _consecutiveChecks = 0; // Reset for next session
        return;
      }
    } else {
      _consecutiveChecks = 0; // Reset on manual check
    }

    _isCheckingRequests = true;

    try {
      final requestFuture = cartRepository.getReceivedRequests();
      final result = await requestFuture.timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          debugPrint('Request fetch timed out');
          throw TimeoutException('Failed to fetch requests', const Duration(seconds: 10));
        },
      );

      if (!context.mounted) {
        _isCheckingRequests = false;
        return;
      }

      result.fold(
        (failure) {
          // Silently fail - don't interrupt user experience
          debugPrint('Failed to fetch pending requests: ${failure.message}');
        },
        (requests) {
          // Filter only pending requests that haven't been processed
          final pendingRequests = requests
              .where((request) => request.isPending && !_processedRequestIds.contains(request.id))
              .toList();

          if (pendingRequests.isNotEmpty && context.mounted) {
            _showPendingRequestDialog(context, pendingRequests, isAutoCheck: isAutoCheck);
          } else if (isAutoCheck) {
            // No more pending requests, reset consecutive checks
            _consecutiveChecks = 0;
          }
        },
      );
    } catch (e) {
      // Silently fail
      debugPrint('Error checking pending requests: $e');
    } finally {
      _isCheckingRequests = false;
    }
  }

  void _showPendingRequestDialog(
    BuildContext context,
    List<CartRequest> pendingRequests,
    {bool isAutoCheck = false}
  ) {
    // Don't show multiple dialogs automatically - only show on manual trigger or first auto-check
    if (isAutoCheck && pendingRequests.length > 1) {
      // For auto-checks after processing a request, only show one at a time
      final latestRequest = pendingRequests.first;
      _showSingleRequestDialog(context, [latestRequest]);
    } else {
      _showSingleRequestDialog(context, pendingRequests);
    }
  }

  void _showSingleRequestDialog(
    BuildContext context,
    List<CartRequest> pendingRequests,
  ) {
    if (!context.mounted) return;

    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => PendingRequestDialog(
        pendingRequests: pendingRequests,
        onAccept: (requestId) => _handleAccept(context, requestId),
        onReject: (requestId, reason) => _handleReject(context, requestId, reason),
      ),
    );
  }

  Future<void> _handleAccept(BuildContext context, String requestId) async {
    // Mark as processed to prevent re-showing
    _processedRequestIds.add(requestId);

    if (!context.mounted) return;

    // Show loading indicator
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(Theme.of(context).colorScheme.onPrimary),
              ),
            ),
            const SizedBox(width: 12),
            const Text('Accepting request...'),
          ],
        ),
        duration: Duration(seconds: 2),
      ),
    );

    try {
      final result = await acceptCartRequestUseCase(requestId).timeout(
        const Duration(seconds: 15),
        onTimeout: () async {
          debugPrint('Accept request timed out');
          throw Exception('Request timed out');
        },
      );

      if (!context.mounted) return;

      result.fold(
        (failure) {
          // Remove from processed on failure so user can retry
          _processedRequestIds.remove(requestId);
          
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to accept request: ${failure.message}'),
              backgroundColor: Theme.of(context).colorScheme.error,
              action: SnackBarAction(
                label: 'Retry',
                textColor: Theme.of(context).colorScheme.onError,
                onPressed: () => _handleAccept(context, requestId),
              ),
            ),
          );
        },
        (_) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  Icon(Icons.check_circle, color: Theme.of(context).colorScheme.onPrimary),
                  const SizedBox(width: 12),
                  const Text('Request accepted successfully!'),
                ],
              ),
              backgroundColor: AppColors.success,
            ),
          );
          
          // Check if there are more pending requests
          _checkForMoreRequests(context);
        },
      );
    } catch (e) {
      _processedRequestIds.remove(requestId);
      
      if (!context.mounted) return;
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    }
  }

  Future<void> _handleReject(
    BuildContext context,
    String requestId,
    String? reason,
  ) async {
    // Mark as processed to prevent re-showing
    _processedRequestIds.add(requestId);

    if (!context.mounted) return;

    // Show loading indicator
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(Theme.of(context).colorScheme.onPrimary),
              ),
            ),
            const SizedBox(width: 12),
            const Text('Rejecting request...'),
          ],
        ),
        duration: const Duration(seconds: 2),
      ),
    );

    try {
      final result = await rejectCartRequestUseCase(requestId, reason: reason).timeout(
        const Duration(seconds: 15),
        onTimeout: () async {
          debugPrint('Reject request timed out');
          throw Exception('Request timed out');
        },
      );

      if (!context.mounted) return;

      result.fold(
        (failure) {
          // Remove from processed on failure so user can retry
          _processedRequestIds.remove(requestId);
          
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to reject request: ${failure.message}'),
              backgroundColor: Theme.of(context).colorScheme.error,
              action: SnackBarAction(
                label: 'Retry',
                textColor: Theme.of(context).colorScheme.onError,
                onPressed: () => _handleReject(context, requestId, reason),
              ),
            ),
          );
        },
        (_) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  Icon(Icons.check_circle, color: Theme.of(context).colorScheme.onPrimary),
                  const SizedBox(width: 12),
                  const Text('Request rejected'),
                ],
              ),
              backgroundColor: AppColors.warning,
            ),
          );
          
          // Check if there are more pending requests
          _checkForMoreRequests(context);
        },
      );
    } catch (e) {
      _processedRequestIds.remove(requestId);
      
      if (!context.mounted) return;
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    }
  }

  Future<void> _checkForMoreRequests(BuildContext context) async {
    // Wait a bit for the UI to settle
    await Future.delayed(const Duration(milliseconds: 500));
    
    if (context.mounted) {
      // Pass isAutoCheck to prevent showing all requests again
      await checkAndShowPendingRequests(context, isAutoCheck: true);
    }
  }

  /// Reset processed request tracking (call when user manually navigates to notifications)
  void resetProcessedRequests() {
    _processedRequestIds.clear();
    _consecutiveChecks = 0;
  }
}
