import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:gymmate/presentation/providers/workout_timer_provider.dart';
import 'package:gymmate/core/theme/app_colors.dart';
import 'package:intl/intl.dart';

class WorkoutSummaryScreen extends StatelessWidget {
  const WorkoutSummaryScreen({Key? key}) : super(key: key);

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
                    const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            FontAwesomeIcons.chartLine,
                            size: 60,
                            color: Colors.white,
                          ),
                          SizedBox(height: 16),
                          Text(
                            'Workout Progress',
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
            child: Consumer<WorkoutTimerProvider>(
              builder: (context, timerProvider, child) {
                final workoutDurations = timerProvider.workoutDurations;
                if (workoutDurations.isEmpty) {
                  return _buildEmptyState();
                }
                return Column(
                  children: [
                    _buildOverallStats(workoutDurations),
                    _buildWorkoutChart(context, workoutDurations),
                    _buildProgressDetails(workoutDurations, timerProvider),
                    _buildDayList(workoutDurations, timerProvider),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            FontAwesomeIcons.chartSimple,
            size: 80,
            color: Colors.grey.withOpacity(0.5),
          ),
          const SizedBox(height: 24),
          Text(
            'No Workout Data Yet',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade800,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Complete your first workout to see your progress!',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOverallStats(Map<int, Duration> workoutDurations) {
    final totalWorkouts = workoutDurations.length;
    final totalMinutes = workoutDurations.values
        .fold(0, (sum, duration) => sum + duration.inMinutes);
    final averageMinutes = totalWorkouts > 0 ? totalMinutes ~/ totalWorkouts : 0;

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem(
            'Total Workouts',
            totalWorkouts.toString(),
            FontAwesomeIcons.dumbbell,
            Colors.blue,
          ),
          _buildStatItem(
            'Total Minutes',
            totalMinutes.toString(),
            FontAwesomeIcons.stopwatch,
            Colors.orange,
          ),
          _buildStatItem(
            'Avg Minutes',
            averageMinutes.toString(),
            FontAwesomeIcons.chartBar,
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

  Widget _buildWorkoutChart(BuildContext context, Map<int, Duration> workoutDurations) {
    final timerProvider = Provider.of<WorkoutTimerProvider>(context, listen: false);
    final records = timerProvider.workoutRecords;
    
    // Create spots with dates
    final spots = records.entries.map((e) {
      final date = e.value.date;
      // Convert date to double (days since epoch)
      final x = date.millisecondsSinceEpoch.toDouble();
      return FlSpot(x, e.value.duration.inMinutes.toDouble());
    }).toList()..sort((a, b) => a.x.compareTo(b.x));

    // Find min and max dates for the x-axis
    final dates = records.values.map((r) => r.date).toList()..sort();
    final minDate = dates.isNotEmpty ? dates.first : DateTime.now();
    final maxDate = dates.isNotEmpty ? dates.last : DateTime.now();

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      height: 300,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Workout Duration Trend',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade800,
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: LineChart(
              LineChartData(
                gridData: FlGridData(show: false),
                titlesData: FlTitlesData(
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 40,
                      getTitlesWidget: (value, meta) {
                        return Text(
                          '${value.toInt()}m',
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 12,
                          ),
                        );
                      },
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 35,
                      interval: 24 * 60 * 60 * 1000, // One day in milliseconds
                      getTitlesWidget: (value, meta) {
                        final date = DateTime.fromMillisecondsSinceEpoch(value.toInt());
                        return Transform.rotate(
                          angle: -0.5, // Rotate text for better readability
                          child: Text(
                            DateFormat('MMM d').format(date),
                            style: TextStyle(
                              color: Colors.grey.shade600,
                              fontSize: 12,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  rightTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  topTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                ),
                borderData: FlBorderData(show: false),
                minX: minDate.millisecondsSinceEpoch.toDouble(),
                maxX: maxDate.millisecondsSinceEpoch.toDouble(),
                lineBarsData: [
                  LineChartBarData(
                    spots: spots,
                    isCurved: true,
                    gradient: LinearGradient(
                      colors: [
                        AppColors.primary,
                        AppColors.primary.withOpacity(0.8),
                      ],
                    ),
                    barWidth: 3,
                    isStrokeCapRound: true,
                    dotData: FlDotData(
                      show: true,
                      getDotPainter: (spot, percent, barData, index) {
                        return FlDotCirclePainter(
                          radius: 6,
                          color: AppColors.primary,
                          strokeWidth: 2,
                          strokeColor: Colors.white,
                        );
                      },
                    ),
                    belowBarData: BarAreaData(
                      show: true,
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          AppColors.primary.withOpacity(0.2),
                          AppColors.primary.withOpacity(0.0),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressDetails(Map<int, Duration> workoutDurations, WorkoutTimerProvider timerProvider) {
    final sortedDurations = workoutDurations.values.toList()..sort((a, b) => b.compareTo(a));
    final longestWorkout = sortedDurations.isNotEmpty ? sortedDurations.first : const Duration();
    final shortestWorkout = sortedDurations.isNotEmpty ? sortedDurations.last : const Duration();
    final streak = _calculateCurrentStreak(workoutDurations);
    final completionRate = (workoutDurations.length / 3 * 100).toStringAsFixed(1);

    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Icon(
                  FontAwesomeIcons.chartPie,
                  color: AppColors.primary,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Text(
                  'Progress Details',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey.shade800,
                  ),
                ),
              ],
            ),
          ),
          const Divider(),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _buildProgressDetailRow(
                  'Completion Rate',
                  '$completionRate%',
                  FontAwesomeIcons.percent,
                  Colors.green,
                  'Of total workout plan completed',
                ),
                const SizedBox(height: 16),
                _buildProgressDetailRow(
                  'Current Streak',
                  '$streak days',
                  FontAwesomeIcons.fire,
                  Colors.orange,
                  'Keep the momentum going!',
                ),
                const SizedBox(height: 16),
                _buildProgressDetailRow(
                  'Longest Workout',
                  timerProvider.formatDuration(longestWorkout),
                  FontAwesomeIcons.crown,
                  Colors.amber,
                  'Your best session duration',
                ),
                const SizedBox(height: 16),
                _buildProgressDetailRow(
                  'Shortest Workout',
                  timerProvider.formatDuration(shortestWorkout),
                  FontAwesomeIcons.stopwatch,
                  Colors.blue,
                  'Your quickest session',
                ),
                const SizedBox(height: 16),
                _buildWorkoutIntensityIndicator(workoutDurations),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressDetailRow(
    String title,
    String value,
    IconData icon,
    Color color,
    String subtitle,
  ) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            icon,
            color: color,
            size: 24,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildWorkoutIntensityIndicator(Map<int, Duration> workoutDurations) {
    final averageDuration = workoutDurations.isEmpty
        ? 0
        : workoutDurations.values.fold<int>(
            0, (sum, duration) => sum + duration.inMinutes) ~/ workoutDurations.length;
    
    String intensityLevel;
    Color intensityColor;
    String message;

    if (averageDuration >= 45) {
      intensityLevel = 'High Intensity';
      intensityColor = Colors.red;
      message = 'You\'re crushing it! Keep up the intense workouts!';
    } else if (averageDuration >= 30) {
      intensityLevel = 'Medium Intensity';
      intensityColor = Colors.orange;
      message = 'Great balanced workouts! You\'re doing well!';
    } else {
      intensityLevel = 'Light Intensity';
      intensityColor = Colors.green;
      message = 'Good start! Try to gradually increase your workout duration.';
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: intensityColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: intensityColor.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                FontAwesomeIcons.gauge,
                color: intensityColor,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Workout Intensity',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: intensityColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            intensityLevel,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: intensityColor,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            message,
            style: const TextStyle(
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  int _calculateCurrentStreak(Map<int, Duration> workoutDurations) {
    if (workoutDurations.isEmpty) return 0;
    
    final days = workoutDurations.keys.toList()..sort();
    int streak = 1;
    
    for (int i = 1; i < days.length; i++) {
      if (days[i] - days[i - 1] == 1) {
        streak++;
      } else {
        break;
      }
    }
    
    return streak;
  }

  Widget _buildDayList(Map<int, Duration> workoutDurations, WorkoutTimerProvider timerProvider) {
    final records = timerProvider.workoutRecords;
    final sortedEntries = records.entries.toList()
      ..sort((a, b) => b.value.date.compareTo(a.value.date)); // Sort by date descending

    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: ListView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: sortedEntries.length,
        itemBuilder: (context, index) {
          final entry = sortedEntries[index];
          final record = entry.value;
          return ListTile(
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Text(
                '${entry.key}',
                style: TextStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            title: Text(
              'Day ${entry.key} Workout',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  timerProvider.formatDuration(record.duration),
                  style: TextStyle(
                    color: Colors.grey.shade600,
                  ),
                ),
                Text(
                  DateFormat('MMMM d, y').format(record.date),
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
            trailing: Icon(
              FontAwesomeIcons.check,
              color: Colors.green.shade400,
            ),
          );
        },
      ),
    );
  }
} 