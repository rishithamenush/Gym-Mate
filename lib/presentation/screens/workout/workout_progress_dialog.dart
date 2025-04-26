import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:gymmate/core/theme/app_colors.dart';
import '../../../data/models/workout_model.dart';
import 'package:provider/provider.dart';
import 'package:gymmate/presentation/providers/workout_timer_provider.dart';

class WorkoutProgressDialog extends StatefulWidget {
  final WorkoutDay workoutDay;

  const WorkoutProgressDialog({
    Key? key,
    required this.workoutDay,
  }) : super(key: key);

  @override
  State<WorkoutProgressDialog> createState() => _WorkoutProgressDialogState();
}

class _WorkoutProgressDialogState extends State<WorkoutProgressDialog> with SingleTickerProviderStateMixin {
  int _currentExerciseIndex = 0;
  bool _isCompleted = false;
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;
  late WorkoutTimerProvider _timerProvider;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutBack),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeIn),
    );
    _controller.forward();
    _timerProvider = Provider.of<WorkoutTimerProvider>(context, listen: false);
    _timerProvider.startTimer(widget.workoutDay.dayNumber);
  }

  @override
  void dispose() {
    _controller.dispose();
    if (_timerProvider.isRunning) {
      _timerProvider.stopTimer(widget.workoutDay.dayNumber);
    }
    super.dispose();
  }

  void _nextExercise() {
    _controller.reverse().then((_) {
      setState(() {
        _currentExerciseIndex++;
        _isCompleted = false;
      });
      _controller.forward();
    });
  }

  void _previousExercise() {
    _controller.reverse().then((_) {
      setState(() {
        _currentExerciseIndex--;
        _isCompleted = false;
      });
      _controller.forward();
    });
  }

  @override
  Widget build(BuildContext context) {
    final exercise = widget.workoutDay.exercises[_currentExerciseIndex];
    final totalExercises = widget.workoutDay.exercises.length;
    final progress = (_currentExerciseIndex + 1) / totalExercises;
    final screenSize = MediaQuery.of(context).size;
    final isLandscape = screenSize.width > screenSize.height;
    final isSmallScreen = screenSize.width < 360;

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Container(
        constraints: BoxConstraints(
          maxWidth: isLandscape ? screenSize.width * 0.7 : screenSize.width * 0.9,
          maxHeight: screenSize.height * 0.8,
        ),
        padding: EdgeInsets.all(isSmallScreen ? 12 : 20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: ScaleTransition(
            scale: _scaleAnimation,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Progress indicator with animation
                  Stack(
                    children: [
                      Container(
                        height: 8,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade200,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        height: 8,
                        width: (isLandscape ? screenSize.width * 0.4 : screenSize.width * 0.6) * progress,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              AppColors.primary,
                              AppColors.primary.withOpacity(0.8),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: isSmallScreen ? 12 : 20),
                  
                  // Exercise number and total with animation
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    child: Text(
                      'Exercise ${_currentExerciseIndex + 1} of $totalExercises',
                      key: ValueKey<int>(_currentExerciseIndex),
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontWeight: FontWeight.bold,
                        fontSize: isSmallScreen ? 14 : 16,
                      ),
                    ),
                  ),
                  SizedBox(height: isSmallScreen ? 12 : 20),

                  // Exercise details with animation
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    child: Container(
                      key: ValueKey<int>(_currentExerciseIndex),
                      padding: EdgeInsets.all(isSmallScreen ? 12 : 20),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            AppColors.primary.withOpacity(0.1),
                            AppColors.primary.withOpacity(0.05),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: AppColors.primary.withOpacity(0.2),
                          width: 1,
                        ),
                      ),
                      child: Column(
                        children: [
                          Container(
                            padding: EdgeInsets.all(isSmallScreen ? 10 : 16),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withOpacity(0.1),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              FontAwesomeIcons.dumbbell,
                              color: AppColors.primary,
                              size: isSmallScreen ? 30 : 40,
                            ),
                          ),
                          SizedBox(height: isSmallScreen ? 12 : 20),
                          Text(
                            exercise.name,
                            style: TextStyle(
                              fontSize: isSmallScreen ? 20 : 24,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          SizedBox(height: isSmallScreen ? 8 : 12),
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: isSmallScreen ? 12 : 16,
                              vertical: isSmallScreen ? 6 : 8,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              exercise.sets,
                              style: TextStyle(
                                color: AppColors.primary,
                                fontSize: isSmallScreen ? 16 : 18,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          SizedBox(height: isSmallScreen ? 12 : 16),
                          Container(
                            padding: EdgeInsets.all(isSmallScreen ? 12 : 16),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade100,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  FontAwesomeIcons.lightbulb,
                                  color: Colors.amber,
                                  size: isSmallScreen ? 16 : 20,
                                ),
                                SizedBox(width: isSmallScreen ? 8 : 12),
                                Expanded(
                                  child: Text(
                                    exercise.tips,
                                    style: TextStyle(
                                      color: Colors.grey.shade700,
                                      fontStyle: FontStyle.italic,
                                      fontSize: isSmallScreen ? 12 : 14,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: isSmallScreen ? 16 : 24),

                  // Navigation buttons with animation
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      if (_currentExerciseIndex > 0)
                        AnimatedSwitcher(
                          duration: const Duration(milliseconds: 300),
                          child: Container(
                            width: 50,
                            height: 50,
                            decoration: BoxDecoration(
                              color: Colors.grey.shade300,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 10,
                                  offset: const Offset(0, 5),
                                ),
                              ],
                            ),
                            child: Material(
                              color: Colors.transparent,
                              child: InkWell(
                                onTap: _previousExercise,
                                borderRadius: BorderRadius.circular(25),
                                child: const Icon(
                                  FontAwesomeIcons.arrowLeft,
                                  color: Colors.black,
                                ),
                              ),
                            ),
                          ),
                        ),
                      Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              AppColors.primary,
                              AppColors.primary.withOpacity(0.8),
                            ],
                          ),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primary.withOpacity(0.3),
                              blurRadius: 10,
                              offset: const Offset(0, 5),
                            ),
                          ],
                        ),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: () async {
                              if (_currentExerciseIndex < totalExercises - 1) {
                                _nextExercise();
                              } else {
                                // Get current duration before stopping
                                final currentDuration = _timerProvider.duration;
                                _timerProvider.stopTimer(widget.workoutDay.dayNumber);
                                if (mounted) {
                                  // Return the actual duration
                                  Navigator.of(context).pop(currentDuration);
                                }
                              }
                            },
                            borderRadius: BorderRadius.circular(25),
                            child: Icon(
                              _currentExerciseIndex < totalExercises - 1
                                  ? FontAwesomeIcons.arrowRight
                                  : FontAwesomeIcons.check,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
} 