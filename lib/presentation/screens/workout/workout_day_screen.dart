import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:gymmate/presentation/providers/workout_provider.dart';
import 'package:gymmate/core/theme/app_colors.dart';
import '../../../data/models/workout_model.dart';
import 'package:gymmate/presentation/screens/workout/workout_progress_dialog.dart';
import 'package:gymmate/presentation/screens/workout/workout_summary_screen.dart';

class WorkoutDayScreen extends StatefulWidget {
  final WorkoutDay workoutDay;
  final int? initialExerciseIndex;

  const WorkoutDayScreen({
    Key? key,
    required this.workoutDay,
    this.initialExerciseIndex,
  }) : super(key: key);

  @override
  State<WorkoutDayScreen> createState() => _WorkoutDayScreenState();
}

class _WorkoutDayScreenState extends State<WorkoutDayScreen> {
  late int _currentExerciseIndex;
  late DateTime _startTime;

  @override
  void initState() {
    super.initState();
    _currentExerciseIndex = widget.initialExerciseIndex ?? 0;
    _startTime = DateTime.now();
    _saveWorkoutState();
  }

  @override
  void dispose() {
    // Clear the workout state if we're exiting normally
    if (mounted) {
      final workoutProvider = Provider.of<WorkoutProvider>(context, listen: false);
      workoutProvider.clearWorkoutState();
    }
    super.dispose();
  }

  void _saveWorkoutState() {
    final workoutProvider = Provider.of<WorkoutProvider>(context, listen: false);
    workoutProvider.saveWorkoutState(
      dayNumber: widget.workoutDay.dayNumber,
      exerciseIndex: _currentExerciseIndex,
      startTime: _startTime,
    );
  }

  void _onExerciseComplete() {
    if (_currentExerciseIndex < widget.workoutDay.exercises.length - 1) {
      setState(() {
        _currentExerciseIndex++;
        _saveWorkoutState();
      });
    } else {
      // Workout completed
      final workoutProvider = Provider.of<WorkoutProvider>(context, listen: false);
      workoutProvider.clearWorkoutState();
      // ... rest of completion logic ...
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        final shouldExit = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Exit Workout?'),
            content: const Text(
              'Your progress will be saved and you can resume later. Are you sure you want to exit?'
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text('Exit'),
              ),
            ],
          ),
        );
        return shouldExit ?? false;
      },
      child: Consumer<WorkoutProvider>(
        builder: (context, workoutProvider, child) {
          final workoutDay = workoutProvider.currentWorkoutDay;
          final isCompleted = workoutProvider.isDayCompleted(widget.workoutDay.dayNumber);
          final isUnlocked = widget.workoutDay.dayNumber == 1 || workoutProvider.isDayCompleted(widget.workoutDay.dayNumber - 1);
          final canStartWorkout = widget.workoutDay.dayNumber == 1 || workoutProvider.isDayCompleted(widget.workoutDay.dayNumber - 1);

          if (workoutDay == null) {
            return Scaffold(
              body: Container(
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
                child: const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        FontAwesomeIcons.dumbbell,
                        size: 60,
                        color: Colors.white,
                      ),
                      SizedBox(height: 20),
                      Text(
                        'Workout day not found',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }

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
                                const Icon(
                                  FontAwesomeIcons.dumbbell,
                                  size: 60,
                                  color: Colors.white,
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'Day ${widget.workoutDay.dayNumber}',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 28,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  workoutDay.title,
                                  style: TextStyle(
                                    color: Colors.white.withOpacity(0.8),
                                    fontSize: 18,
                                  ),
                                ),
                                if (isCompleted) ...[
                                  const SizedBox(height: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                    decoration: BoxDecoration(
                                      color: Colors.green.withOpacity(0.2),
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        const Icon(
                                          FontAwesomeIcons.check,
                                          color: Colors.green,
                                          size: 16,
                                        ),
                                        const SizedBox(width: 6),
                                        const Text(
                                          'Completed',
                                          style: TextStyle(
                                            color: Colors.green,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
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
                        if (!canStartWorkout) ...[
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.orange.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: Colors.orange),
                            ),
                            child: Row(
                              children: [
                                const Icon(
                                  FontAwesomeIcons.lock,
                                  color: Colors.orange,
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    'Complete Day ${widget.workoutDay.dayNumber - 1} to start this workout',
                                    style: const TextStyle(
                                      color: Colors.orange,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 24),
                        ],
                        _buildWorkoutStats(workoutDay),
                        const SizedBox(height: 24),
                        Text(
                          'Exercises',
                          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: AppColors.primary,
                              ),
                        ),
                        const SizedBox(height: 16),
                        ...workoutDay.exercises.map((exercise) => _buildExerciseCard(context, exercise)).toList(),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            floatingActionButton: canStartWorkout
                ? FloatingActionButton.extended(
                    onPressed: isCompleted
                        ? null
                        : () async {
                            final result = await showDialog<Duration>(
                              context: context,
                              builder: (context) => WorkoutProgressDialog(
                                workoutDay: workoutDay,
                              ),
                            );
                            
                            if (result != null) {
                              // Workout completed with duration
                              await workoutProvider.completeWorkout(widget.workoutDay.dayNumber, result);
                              if (context.mounted) {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (context) => const WorkoutSummaryScreen(),
                                  ),
                                );
                              }
                            }
                          },
                    icon: Icon(
                      isCompleted ? FontAwesomeIcons.check : FontAwesomeIcons.play,
                    ),
                    label: Text(isCompleted ? 'Completed' : 'Start Workout'),
                    backgroundColor: isCompleted ? Colors.green : AppColors.primary,
                  )
                : null,
          );
        },
      ),
    );
  }

  Widget _buildWorkoutStats(WorkoutDay workoutDay) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem(
            'Exercises',
            workoutDay.exercises.length.toString(),
            FontAwesomeIcons.dumbbell,
            Colors.blue,
          ),
          _buildStatItem(
            'Sets',
            workoutDay.exercises.fold(0, (sum, ex) => sum + int.parse(ex.sets.split(' ')[0])).toString(),
            FontAwesomeIcons.layerGroup,
            Colors.orange,
          ),
          _buildStatItem(
            'Duration',
            '45 min',
            FontAwesomeIcons.clock,
            Colors.purple,
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon, Color color) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            color: color,
            size: 24,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            color: color,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            color: Colors.grey.shade600,
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildExerciseCard(BuildContext context, Exercise exercise) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            FontAwesomeIcons.dumbbell,
            color: AppColors.primary,
          ),
        ),
        title: Text(
          exercise.name,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              exercise.sets,
              style: TextStyle(
                color: AppColors.primary,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              exercise.tips,
              style: TextStyle(
                color: Colors.grey.shade600,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
      ),
    );
  }
}