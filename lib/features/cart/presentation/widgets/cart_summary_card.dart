import 'package:flutter/material.dart';
import 'package:flutter_library/core/theme/app_dimensions.dart';

class CartSummaryCard extends StatelessWidget {
  final double total;
  final int itemCount;
  final bool isProcessing;

  const CartSummaryCard({
    super.key,
    required this.total,
    required this.itemCount,
    this.isProcessing = false,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: AppDimensions.elevationMd,
      margin: EdgeInsets.zero,
      shape: const RoundedRectangleBorder(),
      child: Container(
        padding: const EdgeInsets.all(16),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Items ($itemCount)',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  Text(
                    '\$${total.toStringAsFixed(2)}',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).primaryColor,
                        ),
                  ),
                ],
              ),
              SizedBox(height: AppDimensions.spaceMd),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: isProcessing ? null : () {
                    // This would be handled by sending requests for all items
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Send individual requests for each item'),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: isProcessing
                      ? SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Theme.of(context).colorScheme.onPrimary,
                          ),
                        )
                      : const Text('Proceed to Request'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
