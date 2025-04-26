import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:gymmate/core/theme/app_colors.dart';
import 'package:gymmate/presentation/providers/theme_provider.dart';
import 'package:gymmate/presentation/providers/workout_provider.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 200.0,
            floating: false,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      AppColors.primary,
                      AppColors.primary.withOpacity(0.8),
                      Colors.purple,
                    ],
                  ),
                ),
                child: Stack(
                  children: [
                    Positioned(
                      right: -50,
                      top: -50,
                      child: Container(
                        width: 150,
                        height: 150,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withOpacity(0.1),
                        ),
                      ),
                    ),
                    Positioned(
                      left: -30,
                      bottom: -30,
                      child: Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withOpacity(0.1),
                        ),
                      ),
                    ),
                    Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            FontAwesomeIcons.gear,
                            size: 60,
                            color: Colors.white,
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            'Settings',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionTitle('Appearance'),
                  _buildSettingCard(
                    context,
                    icon: FontAwesomeIcons.moon,
                    title: 'Dark Mode',
                    trailing: Consumer<ThemeProvider>(
                      builder: (context, themeProvider, child) {
                        return Switch(
                          value: themeProvider.isDarkMode,
                          onChanged: (value) {
                            themeProvider.toggleTheme();
                          },
                          activeColor: AppColors.primary,
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildSectionTitle('Workout Settings'),
                  _buildSettingCard(
                    context,
                    icon: FontAwesomeIcons.bell,
                    title: 'Workout Reminders',
                    subtitle: 'Get notified about your workout schedule',
                    trailing: Switch(
                      value: true,
                      onChanged: (value) {},
                      activeColor: AppColors.primary,
                    ),
                  ),
                  _buildSettingCard(
                    context,
                    icon: FontAwesomeIcons.clock,
                    title: 'Rest Timer',
                    subtitle: 'Set rest time between exercises',
                    onTap: () {
                      // TODO: Show rest timer settings
                    },
                  ),
                  const SizedBox(height: 16),
                  _buildSectionTitle('Data & Storage'),
                  _buildSettingCard(
                    context,
                    icon: FontAwesomeIcons.database,
                    title: 'Clear Workout History',
                    subtitle: 'Remove all your workout records',
                    onTap: () {
                      _showClearHistoryDialog(context);
                    },
                  ),
                  _buildSettingCard(
                    context,
                    icon: FontAwesomeIcons.download,
                    title: 'Export Data',
                    subtitle: 'Save your workout data',
                    onTap: () {
                      // TODO: Implement data export
                    },
                  ),
                  const SizedBox(height: 16),
                  _buildSectionTitle('About'),
                  _buildSettingCard(
                    context,
                    icon: FontAwesomeIcons.info,
                    title: 'App Version',
                    subtitle: '1.0.0',
                    showTrailing: false,
                  ),
                  _buildSettingCard(
                    context,
                    icon: FontAwesomeIcons.star,
                    title: 'Rate App',
                    onTap: () {
                      // TODO: Open app store rating
                    },
                  ),
                  _buildSettingCard(
                    context,
                    icon: FontAwesomeIcons.share,
                    title: 'Share App',
                    onTap: () {
                      // TODO: Implement share functionality
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: AppColors.primary,
        ),
      ),
    );
  }

  Widget _buildSettingCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    String? subtitle,
    Widget? trailing,
    VoidCallback? onTap,
    bool showTrailing = true,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            color: AppColors.primary,
          ),
        ),
        title: Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: subtitle != null
            ? Text(
                subtitle,
                style: TextStyle(
                  color: Colors.grey.shade600,
                ),
              )
            : null,
        trailing: showTrailing
            ? trailing ??
                const Icon(
                  FontAwesomeIcons.chevronRight,
                  size: 16,
                  color: Colors.grey,
                )
            : null,
        onTap: onTap,
      ),
    );
  }

  void _showClearHistoryDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear Workout History'),
        content: const Text(
          'Are you sure you want to clear all your workout history? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              context.read<WorkoutProvider>().clearWorkoutHistory();
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Workout history cleared successfully'),
                ),
              );
            },
            child: const Text(
              'Clear',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }
} 