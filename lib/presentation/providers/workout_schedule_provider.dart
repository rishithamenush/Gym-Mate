import 'package:flutter/material.dart';

class WorkoutScheduleProvider extends ChangeNotifier {
  DateTime? _startDate;
  final int _daysInCycle = 4; // 3 workout days + 1 rest day

  // Initialize with a start date
  void initializeSchedule(DateTime startDate) {
    _startDate = startDate;
    notifyListeners();
  }

  // Get the current cycle day (1-4, where 4 is rest day)
  int getCurrentCycleDay() {
    if (_startDate == null) return 1;
    
    final today = DateTime.now();
    final daysSinceStart = today.difference(_startDate!).inDays;
    
    // Calculate which day in the cycle (1-4)
    return ((daysSinceStart % _daysInCycle) + 1);
  }

  // Check if a specific workout day is unlocked
  bool isDayUnlocked(int workoutDay) {
    if (_startDate == null) return workoutDay == 1;
    
    final today = DateTime.now();
    final daysSinceStart = today.difference(_startDate!).inDays;
    final currentCycleDay = getCurrentCycleDay();
    
    // If we're on a rest day, no workout days are unlocked
    if (currentCycleDay == 4) return false;
    
    // A day is unlocked if it's less than or equal to the current cycle day
    return workoutDay <= currentCycleDay;
  }

  // Get the date when a specific day will be unlocked
  DateTime? getUnlockDate(int workoutDay) {
    if (_startDate == null) return null;
    return _startDate!.add(Duration(days: workoutDay - 1));
  }

  // Check if today is a rest day
  bool isRestDay() {
    return getCurrentCycleDay() == 4;
  }

  // Get the next workout date after a rest day
  DateTime? getNextWorkoutDate() {
    if (_startDate == null) return null;
    
    final today = DateTime.now();
    final daysSinceStart = today.difference(_startDate!).inDays;
    final daysUntilNextCycle = _daysInCycle - (daysSinceStart % _daysInCycle);
    
    return today.add(Duration(days: daysUntilNextCycle));
  }

  // Reset the schedule with a new start date
  void resetSchedule(DateTime newStartDate) {
    _startDate = newStartDate;
    notifyListeners();
  }
} 