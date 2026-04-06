import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_library/core/constants/app_constants.dart';
import 'package:flutter_library/core/theme/app_dimensions.dart';
import 'package:flutter_library/features/settings/presentation/bloc/settings_bloc.dart';
import 'package:flutter_library/features/settings/presentation/bloc/settings_event.dart';
import 'package:flutter_library/features/settings/presentation/bloc/settings_state.dart';

/// Settings page for managing app preferences
class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SettingsBloc, SettingsState>(
      builder: (context, state) {
        final themeLabel = switch (state.themeMode) {
          ThemeMode.light => 'Light',
          ThemeMode.dark => 'Dark',
          ThemeMode.system => 'System',
        };
        return Scaffold(
          appBar: AppBar(
            title: const Text('Settings'),
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(AppConstants.defaultPadding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Theme Settings
                _buildSectionHeader(context, 'Appearance'),
                _buildSettingsTile(
                  context,
                  icon: Icons.palette_outlined,
                  title: 'Theme',
                  subtitle: themeLabel,
                  onTap: () => _showThemeDialog(context),
                ),
                
                const SizedBox(height: AppConstants.defaultPadding),
                
                // Notification Settings
                _buildSectionHeader(context, 'Notifications'),
                _buildSettingsTile(
                  context,
                  icon: Icons.notifications_outlined,
                  title: 'Push Notifications',
                  subtitle: 'Receive notifications about rentals and updates',
                  onTap: () {
                // TODO: Implement notification settings
              },
            ),
            _buildSettingsTile(
              context,
              icon: Icons.email_outlined,
              title: 'Email Notifications',
              subtitle: 'Get email updates about your library',
              onTap: () {
                // TODO: Implement email settings
              },
            ),
            
            const SizedBox(height: AppConstants.defaultPadding),
            
            // Account Settings
            _buildSectionHeader(context, 'Account'),
            _buildSettingsTile(
              context,
              icon: Icons.person_outline,
              title: 'Profile',
              subtitle: 'Manage your profile information',
              onTap: () {
                // TODO: Navigate to profile page
              },
            ),
            _buildSettingsTile(
              context,
              icon: Icons.security_outlined,
              title: 'Privacy & Security',
              subtitle: 'Control your privacy settings',
              onTap: () {
                // TODO: Navigate to privacy settings
              },
            ),
            
            const SizedBox(height: AppConstants.defaultPadding),
            
            // App Settings
            _buildSectionHeader(context, 'App'),
            _buildSettingsTile(
              context,
              icon: Icons.storage_outlined,
              title: 'Storage',
              subtitle: 'Manage app data and cache',
              onTap: () {
                // TODO: Implement storage management
              },
            ),
            _buildSettingsTile(
              context,
              icon: Icons.info_outline,
              title: 'About',
              subtitle: 'App version and information',
              onTap: () {
                // TODO: Show about dialog
                _showAboutDialog(context);
              },
            ),
            
            const SizedBox(height: AppConstants.largePadding),
            
            // Sign Out
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () {
                  // TODO: Implement sign out
                  _showSignOutDialog(context);
                },
                icon: Icon(Icons.logout, color: Theme.of(context).colorScheme.error),
                label: Text(
                  'Sign Out',
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: Theme.of(context).colorScheme.error),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
      },
    );
  }
  
  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppDimensions.spaceSm),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.bold,
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
    );
  }
  
  Widget _buildSettingsTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: AppDimensions.spaceSm),
      child: ListTile(
        leading: Icon(
          icon,
          color: Theme.of(context).colorScheme.primary,
        ),
        title: Text(title),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
  
  void _showThemeDialog(BuildContext context) {
    final currentMode = context.read<SettingsBloc>().state.themeMode;
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Choose Theme'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.light_mode),
              title: const Text('Light'),
              trailing: currentMode == ThemeMode.light
                  ? const Icon(Icons.check)
                  : null,
              onTap: () {
                Navigator.pop(dialogContext);
                context.read<SettingsBloc>().add(const ChangeThemeMode(ThemeMode.light));
              },
            ),
            ListTile(
              leading: const Icon(Icons.dark_mode),
              title: const Text('Dark'),
              trailing: currentMode == ThemeMode.dark
                  ? const Icon(Icons.check)
                  : null,
              onTap: () {
                Navigator.pop(dialogContext);
                context.read<SettingsBloc>().add(const ChangeThemeMode(ThemeMode.dark));
              },
            ),
            ListTile(
              leading: const Icon(Icons.settings_system_daydream),
              title: const Text('System'),
              trailing: currentMode == ThemeMode.system
                  ? const Icon(Icons.check)
                  : null,
              onTap: () {
                Navigator.pop(dialogContext);
                context.read<SettingsBloc>().add(const ChangeThemeMode(ThemeMode.system));
              },
            ),
          ],
        ),
      ),
    );
  }
  
  void _showAboutDialog(BuildContext context) {
    showAboutDialog(
      context: context,
      applicationName: 'Flutter Library',
      applicationVersion: '1.0.0',
      applicationIcon: const Icon(Icons.library_books, size: AppDimensions.icon3Xl),
      children: [
        const Text('A modern library management app built with Flutter.'),
        SizedBox(height: AppDimensions.spaceMd),
        const Text('Features:'),
        const Text('• Book rental and purchase'),
        const Text('• Personal library management'),
        const Text('• Favorites and reviews'),
        const Text('• Search and discovery'),
      ],
    );
  }
  
  void _showSignOutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sign Out'),
        content: const Text('Are you sure you want to sign out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              // TODO: Implement sign out logic
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Signed out successfully')),
              );
            },
            child: const Text('Sign Out'),
          ),
        ],
      ),
    );
  }
}
