import 'package:flutter/material.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class BottomNavBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const BottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: theme.cardColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
          child: GNav(
            backgroundColor: theme.cardColor,
            color: theme.textTheme.bodyMedium?.color ?? Colors.grey,
            activeColor: theme.colorScheme.primary,
            tabBackgroundColor: theme.colorScheme.primary.withOpacity(0.1),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            gap: 8,
            onTabChange: onTap,
            selectedIndex: currentIndex,
            tabs: [
              GButton(
                icon: FontAwesomeIcons.house,
                text: 'Home',
                iconColor: isDarkMode ? Colors.white70 : Colors.grey,
                textColor: theme.colorScheme.primary,
              ),
              GButton(
                icon: FontAwesomeIcons.dumbbell,
                text: 'Workout',
                iconColor: isDarkMode ? Colors.white70 : Colors.grey,
                textColor: theme.colorScheme.primary,
              ),
              GButton(
                icon: FontAwesomeIcons.chartLine,
                text: 'Progress',
                iconColor: isDarkMode ? Colors.white70 : Colors.grey,
                textColor: theme.colorScheme.primary,
              ),
              GButton(
                icon: FontAwesomeIcons.user,
                text: 'Profile',
                iconColor: isDarkMode ? Colors.white70 : Colors.grey,
                textColor: theme.colorScheme.primary,
              ),
            ],
          ),
        ),
      ),
    );
  }
} 