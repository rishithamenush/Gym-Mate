import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:gymmate/presentation/screens/workout/workout_summary_screen.dart';
import 'package:provider/provider.dart';
import 'package:gymmate/presentation/providers/theme_provider.dart';
import 'package:gymmate/presentation/screens/home/home_screen.dart';
import 'package:gymmate/presentation/screens/workout/workout_screen.dart';
import 'package:gymmate/presentation/screens/progress/progress_screen.dart';
import 'package:gymmate/presentation/screens/profile/profile_screen.dart';
import 'package:gymmate/presentation/widgets/bottom_nav_bar.dart';
import 'package:gymmate/presentation/widgets/app_drawer.dart';
import '../providers/workout_provider.dart';
import 'workout/workout_day_screen.dart';

class MainLayout extends StatefulWidget {
  const MainLayout({super.key});

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  int _currentIndex = 0;
  final List<Widget> _screens = [
    const HomeScreen(),
    const WorkoutScreen(),
    const WorkoutSummaryScreen(),
    const ProfileScreen(),
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkActiveWorkout();
    });
  }

  Future<void> _checkActiveWorkout() async {
    final workoutProvider = Provider.of<WorkoutProvider>(context, listen: false);
    if (workoutProvider.hasActiveWorkout) {
      final workout = workoutProvider.getActiveWorkout();
      if (workout != null) {
        // Show resume workout dialog
        final shouldResume = await showDialog<bool>(
          context: context,
          barrierDismissible: false,
          builder: (context) => AlertDialog(
            title: const Text('Resume Workout'),
            content: Text(
              'You have an unfinished workout for Day ${workout.dayNumber}. Would you like to resume where you left off?'
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(false);
                  workoutProvider.clearWorkoutState();
                },
                child: const Text('Start New'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop(true);
                },
                child: const Text('Resume'),
              ),
            ],
          ),
        );

        if (shouldResume == true) {
          // Navigate to the workout screen
          if (!mounted) return;
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => WorkoutDayScreen(
                workoutDay: workout,
                initialExerciseIndex: workoutProvider.currentExerciseIndex,
              ),
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDarkMode = themeProvider.isDarkMode;

    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: isDarkMode
                    ? [
                        const Color(0xFF2C3E50),
                        const Color(0xFF34495E),
                        const Color(0xFF1A1A1A),
                      ]
                    : [
                        const Color(0xFF3498DB),
                        const Color(0xFF2980B9),
                        const Color(0xFF2C3E50),
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
                      color: Colors.white.withOpacity(isDarkMode ? 0.03 : 0.08),
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
                      color: Colors.white.withOpacity(isDarkMode ? 0.03 : 0.08),
                    ),
                  ),
                ),
                Positioned(
                  right: 30,
                  bottom: 30,
                  child: Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withOpacity(isDarkMode ? 0.03 : 0.08),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Scaffold(
            backgroundColor: Colors.transparent,
            drawer: const AppDrawer(),
            body: Stack(
              children: [
                _screens[_currentIndex],
                Positioned(
                  top: MediaQuery.of(context).padding.top,
                  left: 16,
                  child: Builder(
                    builder: (context) => IconButton(
                      icon: const Icon(
                        FontAwesomeIcons.bars,
                        color: Colors.white,
                        size: 24,
                      ),
                      onPressed: () => Scaffold.of(context).openDrawer(),
                    ),
                  ),
                ),
              ],
            ),
            bottomNavigationBar: BottomNavBar(
              currentIndex: _currentIndex,
              onTap: (index) {
                setState(() {
                  _currentIndex = index;
                });
              },
            ),
          ),
        ],
      ),
    );
  }
} 