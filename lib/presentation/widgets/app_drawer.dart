import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:gymmate/presentation/providers/theme_provider.dart';

import '../screens/settings/settings_screen.dart';


class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDarkMode = themeProvider.isDarkMode;
    final theme = Theme.of(context);

    return Drawer(
      backgroundColor: theme.cardColor,
      child: Column(
        children: [
          _buildHeader(context, theme),
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                _buildMenuItem(
                  context,
                  'Home',
                  FontAwesomeIcons.house,
                  Colors.blue,
                  0,
                ),
                _buildMenuItem(
                  context,
                  'Workout Plans',
                  FontAwesomeIcons.dumbbell,
                  Colors.orange,
                  1,
                ),
                _buildMenuItem(
                  context,
                  'Progress',
                  FontAwesomeIcons.chartLine,
                  Colors.green,
                  2,
                ),
                _buildMenuItem(
                  context,
                  'Profile',
                  FontAwesomeIcons.user,
                  Colors.purple,
                  3,
                ),
                const Divider(height: 32),
                _buildThemeSwitcher(context, themeProvider, isDarkMode),
                _buildMenuItem(
                  context,
                  'Settings',
                  FontAwesomeIcons.gear,
                  Colors.grey,
                  4,
                  onTap: () {
                    Navigator.pop(context); // Close the drawer
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const SettingsScreen(),
                      ),
                    );
                  },
                ),
                _buildMenuItem(
                  context,
                  'Help & Support',
                  FontAwesomeIcons.circleQuestion,
                  Colors.blue,
                  5,
                ),
                _buildMenuItem(
                  context,
                  'About',
                  FontAwesomeIcons.info,
                  Colors.green,
                  6,
                ),
              ],
            ),
          ),
          _buildFooter(context, theme),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context, ThemeData theme) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 48, 16, 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            theme.colorScheme.primary,
            theme.colorScheme.primary.withOpacity(0.8),
            Colors.purple,
          ],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  FontAwesomeIcons.dumbbell,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'GymMate',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.w100,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Text(
            'Track your fitness journey',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _buildStatBadge(
                FontAwesomeIcons.fire,
                '7 Day Streak',
                Colors.white,
              ),
              const SizedBox(width: 8),
              _buildStatBadge(
                FontAwesomeIcons.trophy,
                'Level 3',
                Colors.white,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatBadge(IconData icon, String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            color: color,
            size: 12,
          ),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(
              color: color,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem(
      BuildContext context,
      String title,
      IconData icon,
      Color color,
      int index, {
        VoidCallback? onTap,
      }) {
    final theme = Theme.of(context);
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          icon,
          color: color,
        ),
      ),
      title: Text(
        title,
        style: TextStyle(
          fontWeight: FontWeight.normal,
          color: theme.textTheme.bodyLarge?.color,
        ),
      ),
      onTap: onTap ?? () => Navigator.pop(context),
    );
  }

  Widget _buildThemeSwitcher(
      BuildContext context,
      ThemeProvider themeProvider,
      bool isDarkMode,
      ) {
    final theme = Theme.of(context);
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.amber.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          isDarkMode ? FontAwesomeIcons.solidSun : FontAwesomeIcons.moon,
          color: Colors.amber,
        ),
      ),
      title: Text(
        isDarkMode ? 'Light Mode' : 'Dark Mode',
        style: TextStyle(
          fontWeight: FontWeight.normal,
          color: theme.textTheme.bodyLarge?.color,
        ),
      ),
      trailing: Switch(
        value: isDarkMode,
        onChanged: (value) {
          themeProvider.setThemeMode(
            value ? ThemeMode.dark : ThemeMode.light,
          );
        },
        activeColor: Colors.amber,
        activeTrackColor: Colors.amber.withOpacity(0.5),
        inactiveTrackColor: Colors.grey.withOpacity(0.5),
      ),
    );
  }

  Widget _buildFooter(BuildContext context, ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Text(
            'Version 1.0.0',
            style: TextStyle(
              color: theme.textTheme.bodySmall?.color,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}
