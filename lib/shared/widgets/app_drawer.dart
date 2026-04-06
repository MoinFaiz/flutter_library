import 'package:flutter/material.dart';
import 'package:flutter_library/core/constants/app_constants.dart';
import 'package:flutter_library/core/theme/app_dimensions.dart';
import 'package:flutter_library/core/navigation/app_routes.dart';
import 'package:flutter_library/core/navigation/navigation_service.dart';
import 'package:flutter_library/injection/injection_container.dart';

/// App drawer with navigation menu items
class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final NavigationService navigationService = sl<NavigationService>();

    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          // Drawer Header
          DrawerHeader(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Theme.of(context).colorScheme.primary,
                  Theme.of(context).colorScheme.primaryContainer,
                ],
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                CircleAvatar(
                  radius: AppDimensions.iconSm,
                  backgroundColor: Theme.of(context).colorScheme.surface,
                  child: Icon(
                    Icons.library_books,
                    size: AppDimensions.iconSm,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                const SizedBox(height: AppDimensions.spaceXs / 2),
                Text(
                  'Flutter Library',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onPrimary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Your digital book companion',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onPrimary.withValues(alpha: 0.8),
                  ),
                ),
              ],
            ),
          ),

          // Orders
          _buildDrawerItem(
            context,
            icon: Icons.shopping_bag_outlined,
            title: 'Orders',
            subtitle: 'Track your orders and history',
            onTap: () {
              Navigator.pop(context);
              navigationService.navigateTo(AppRoutes.orders);
            },
          ),

          // Profile
          _buildDrawerItem(
            context,
            icon: Icons.person_outline,
            title: 'Profile',
            subtitle: 'Manage your profile information',
            onTap: () {
              Navigator.pop(context);
              navigationService.navigateTo(AppRoutes.profile);
            },
          ),

          // Settings
          _buildDrawerItem(
            context,
            icon: Icons.settings_outlined,
            title: 'Settings',
            subtitle: 'App preferences and account',
            onTap: () {
              Navigator.pop(context);
              navigationService.navigateTo(AppRoutes.settings);
            },
          ),

          // Feedback
          _buildDrawerItem(
            context,
            icon: Icons.feedback_outlined,
            title: 'Feedback',
            subtitle: 'Share your thoughts with us',
            onTap: () {
              Navigator.pop(context);
              navigationService.navigateTo(AppRoutes.feedback);
            },
          ),

          const Divider(),

          // Policy Section Header
          Padding(
            padding: const EdgeInsets.all(AppConstants.defaultPadding),
            child: Text(
              'Policies & Legal',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                color: Theme.of(context).colorScheme.outline,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),

          // Terms and Conditions
          _buildDrawerItem(
            context,
            icon: Icons.description_outlined,
            title: 'Terms & Conditions',
            subtitle: 'Service terms and agreements',
            onTap: () {
              Navigator.pop(context);
              navigationService.navigateTo(AppRoutes.termsConditions);
            },
          ),

          // Shipping & Delivery Policy
          _buildDrawerItem(
            context,
            icon: Icons.local_shipping_outlined,
            title: 'Shipping & Delivery Policy',
            subtitle: 'Delivery information and policies',
            onTap: () {
              Navigator.pop(context);
              navigationService.navigateTo(AppRoutes.shippingDeliveryPolicy);
            },
          ),

          // Cancellation & Refund Policy
          _buildDrawerItem(
            context,
            icon: Icons.assignment_return_outlined,
            title: 'Cancellation & Refund Policy',
            subtitle: 'Return and refund procedures',
            onTap: () {
              Navigator.pop(context);
              navigationService.navigateTo(AppRoutes.cancellationRefundPolicy);
            },
          ),

          // Privacy Policy
          _buildDrawerItem(
            context,
            icon: Icons.privacy_tip_outlined,
            title: 'Privacy Policy',
            subtitle: 'How we protect your data',
            onTap: () {
              Navigator.pop(context);
              navigationService.navigateTo(AppRoutes.privacyPolicy);
            },
          ),

          const SizedBox(height: AppConstants.defaultPadding),

          // App Version
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppConstants.defaultPadding),
            child: Text(
              'Version 1.0.0',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.outline,
              ),
              textAlign: TextAlign.center,
            ),
          ),

          const SizedBox(height: AppConstants.defaultPadding),
        ],
      ),
    );
  }

  Widget _buildDrawerItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(
        icon,
        color: Theme.of(context).colorScheme.onSurfaceVariant,
      ),
      title: Text(
        title,
        style: Theme.of(context).textTheme.titleMedium,
      ),
      subtitle: Text(
        subtitle,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
          color: Theme.of(context).colorScheme.outline,
        ),
      ),
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: AppConstants.defaultPadding,
        vertical: 4,
      ),
    );
  }
}
