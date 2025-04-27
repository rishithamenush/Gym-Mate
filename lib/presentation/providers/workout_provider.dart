import 'package:flutter/material.dart';
import 'package:gymmate/data/models/workout_model.dart';
import 'package:gymmate/data/repositories/workout_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class WorkoutProvider with ChangeNotifier {
  final WorkoutRepository _repository;
  
  int _selectedDay = 1;
  double _currentWeight = 0.0;
  List<double> _weightHistory = [];
  List<WorkoutDay> _workoutDays = [];
  WorkoutDay? _currentWorkoutDay;
  final Map<int, bool> _completedDays = {};
  final Map<int, Duration> _lastWorkoutDurations = {};

  // New variables for session state
  bool _hasActiveWorkout = false;
  int? _activeWorkoutDay;
  int _currentExerciseIndex = 0;
  DateTime? _workoutStartTime;

  // Getters for new variables
  bool get hasActiveWorkout => _hasActiveWorkout;
  int? get activeWorkoutDay => _activeWorkoutDay;
  int get currentExerciseIndex => _currentExerciseIndex;
  DateTime? get workoutStartTime => _workoutStartTime;

  WorkoutProvider({WorkoutRepository? repository}) 
      : _repository = repository ?? WorkoutRepository() {
    _initializeWorkoutDays();
    _loadWorkoutState();
  }

  int get selectedDay => _selectedDay;
  double get currentWeight => _currentWeight;
  List<double> get weightHistory => _weightHistory;
  List<WorkoutDay> get workoutDays => _workoutDays;
  WorkoutDay? get currentWorkoutDay => _currentWorkoutDay;
  Map<int, Duration> get lastWorkoutDurations => _lastWorkoutDurations;

  // Initialize the provider
  Future<void> initialize() async {
    await _initializeWorkoutDays();
    await _loadWorkoutState();
  }

  Future<void> _initializeWorkoutDays() async {
    try {
      // Clear existing workout days first
      _workoutDays.clear();

      // Load the updated workout days from the repository
      final workoutDaysData = await _repository.getWorkoutDays();

      for (var dayData in workoutDaysData) {
        final exercises = await _repository.getExercisesForDay(dayData['id'] as int);
        final lastWorkout = await _repository.getLastWorkoutForDay(dayData['day_number'] as int);

        if (lastWorkout != null) {
          _lastWorkoutDurations[dayData['day_number'] as int] = Duration(seconds: lastWorkout['duration'] as int);
        }

        _workoutDays.add(WorkoutDay(
          dayNumber: dayData['day_number'] as int,
          title: dayData['title'] as String,
          exercises: exercises.map((e) => Exercise(
            name: e['name'] as String,
            sets: e['sets'] as String,
            reps: e['reps'] as int,
            tips: e['tips'] as String,
            notes: e['notes'] as String?,
          )).toList(),
          isCompleted: dayData['is_completed'] == 1,
        ));
      }

      // Set current workout day
      _setCurrentWorkoutDay();
      notifyListeners();
    } catch (e) {
      print('Error initializing workout days: $e');
    }
  }

  void _setCurrentWorkoutDay() {
    if (_workoutDays.isEmpty) {
      _currentWorkoutDay = null;
      return;
    }

    // Get today's day number (1-3)
    final now = DateTime.now();
    final dayOfWeek = now.weekday;
    
    // Map weekday to workout day (1-3)
    // Monday, Wednesday, Friday = Day 1, 2, 3
    if (dayOfWeek == DateTime.monday) {
      _currentWorkoutDay = _workoutDays.firstWhere((day) => day.dayNumber == 1, orElse: () => _workoutDays[0]);
    } else if (dayOfWeek == DateTime.wednesday) {
      _currentWorkoutDay = _workoutDays.firstWhere((day) => day.dayNumber == 2, orElse: () => _workoutDays[1]);
    } else if (dayOfWeek == DateTime.friday) {
      _currentWorkoutDay = _workoutDays.firstWhere((day) => day.dayNumber == 3, orElse: () => _workoutDays[2]);
    } else {
      // No workout scheduled for other days, set to first available day
      _currentWorkoutDay = _workoutDays.isNotEmpty ? _workoutDays[0] : null;
    }
    notifyListeners();
  }

  void selectDay(int day) {
    if (day >= 1 && day <= _workoutDays.length) {
      _selectedDay = day;
      _currentWorkoutDay = _workoutDays.firstWhere(
        (workoutDay) => workoutDay.dayNumber == day,
        orElse: () => _workoutDays[0],
      );
      notifyListeners();
    }
  }

  Future<void> _loadInitialData() async {
    try {
      // Load latest weight
      final latestWeight = await _repository.getLatestWeight();
      if (latestWeight != null) {
        _currentWeight = latestWeight;
      }

      // Load completed workouts for the current week
      final completedWorkouts = await _repository.getCompletedWorkoutsForCurrentWeek();
      for (var workout in completedWorkouts) {
        _completedDays[workout['day_number'] as int] = true;
      }

      // Load workout days from database
      final workoutDaysData = await _repository.getWorkoutDays();
      if (workoutDaysData.isNotEmpty) {
        _workoutDays = [];
        for (var dayData in workoutDaysData) {
          final exercises = await _repository.getExercisesForDay(dayData['id'] as int);
          
          // Load last workout duration for this day
          final lastWorkout = await _repository.getLastWorkoutForDay(dayData['day_number'] as int);
          if (lastWorkout != null) {
            _lastWorkoutDurations[dayData['day_number'] as int] = 
                Duration(seconds: lastWorkout['duration'] as int);
          }

          _workoutDays.add(
            WorkoutDay(
              dayNumber: dayData['day_number'] as int,
              title: dayData['title'] as String,
              exercises: exercises.map((e) => Exercise(
                name: e['name'] as String,
                sets: e['sets'] as String,
                tips: e['tips'] as String,
                reps: e['reps'] as int,
                notes: e['notes'] as String?,
              )).toList(),
              isCompleted: dayData['is_completed'] == 1,
            ),
          );
        }
      }

      notifyListeners();
    } catch (e) {
      print('Error loading initial data: $e');
    }
  }

  bool isDayCompleted(int dayNumber) {
    return _completedDays[dayNumber] ?? false;
  }

  Duration? getLastWorkoutDuration(int dayNumber) {
    return _lastWorkoutDurations[dayNumber];
  }

  Future<void> updateWeight(double weight) async {
    if (weight >= 0) {
      _currentWeight = weight;
      await _repository.recordWeeklyProgress(weight);
      notifyListeners();
    }
  }

  Future<void> addWorkoutDay(WorkoutDay workoutDay) async {
    try {
      // Check if a workout day with the same day number already exists
      final existingWorkoutDayIndex = _workoutDays.indexWhere(
        (day) => day.dayNumber == workoutDay.dayNumber,
      );

      if (existingWorkoutDayIndex != -1) {
        // If it exists, update it instead of adding a new one
        await updateWorkoutDay(workoutDay);
        return;
      }

      // Prepare data for database
      final workoutDayData = {
        'day_number': workoutDay.dayNumber,
        'title': workoutDay.title,
        'is_completed': workoutDay.isCompleted ? 1 : 0,
      };

      final exercisesData = workoutDay.exercises.map((e) => {
        'name': e.name,
        'sets': e.sets,
        'reps': e.reps,
        'tips': e.tips,
        'notes': e.notes,
      }).toList();

      // Save to database
      await _repository.saveWorkoutDay(workoutDayData, exercisesData);
      
      // Update local state
      _workoutDays.add(workoutDay);
      notifyListeners();
    } catch (e) {
      print('Error adding workout day: $e');
      rethrow;
    }
  }

  Future<void> completeWorkout(int dayNumber, Duration duration) async {
    try {
      final success = await _repository.completeWorkout(
        dayNumber,
        durationInSeconds: duration.inSeconds,
      );
      
      if (success) {
        _completedDays[dayNumber] = true;
        _lastWorkoutDurations[dayNumber] = duration;
        
        // Update the workout day's completion status
        final index = _workoutDays.indexWhere((day) => day.dayNumber == dayNumber);
        if (index != -1) {
          _workoutDays[index] = _workoutDays[index].copyWith(isCompleted: true);
        }
        
        notifyListeners();
      }
    } catch (e) {
      print('Error completing workout: $e');
      rethrow;
    }
  }

  Future<void> clearWorkoutHistory() async {
    try {
      // Clear all workout history from database
      await _repository.clearWorkoutHistory();
      
      // Reset local state
      _completedDays.clear();
      _weightHistory.clear();
      _lastWorkoutDurations.clear();
      _currentWeight = 70.0; // Reset to default weight
      
      // Reset completion status of workout days
      _workoutDays = _workoutDays.map((day) => 
        day.copyWith(isCompleted: false)
      ).toList();
      
      notifyListeners();
    } catch (e) {
      print('Error clearing workout history: $e');
      rethrow;
    }
  }

  Future<void> insertWorkoutDay(Map<String, dynamic> workoutDay) async {
    try {
      // Insert the workout day into the repository
      await _repository.insertWorkoutDay(workoutDay);
      
      // Add exercises
      if (workoutDay['exercises'] != null) {
        for (var exercise in workoutDay['exercises']) {
          exercise['day_number'] = workoutDay['day'];
          await _repository.insertExercise(exercise);
        }
      }
      
      // Reload workout days to update the list
      await _loadInitialData();
      
      // Set as current workout day if it's the first one
      if (_workoutDays.isEmpty) {
        _currentWorkoutDay = _workoutDays.first;
      }
    } catch (e) {
      throw Exception('Failed to insert workout day: $e');
    }
  }

  void setCurrentWorkoutDay(WorkoutDay workoutDay) {
    _currentWorkoutDay = workoutDay;
    notifyListeners();
  }

  // Save current workout state
  Future<void> saveWorkoutState({
    required int dayNumber,
    required int exerciseIndex,
    required DateTime startTime,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final workoutState = {
      'dayNumber': dayNumber,
      'exerciseIndex': exerciseIndex,
      'startTime': startTime.toIso8601String(),
      'hasActiveWorkout': true,
    };
    
    await prefs.setString('workout_state', json.encode(workoutState));
    
    _hasActiveWorkout = true;
    _activeWorkoutDay = dayNumber;
    _currentExerciseIndex = exerciseIndex;
    _workoutStartTime = startTime;
    
    notifyListeners();
  }

  // Load saved workout state
  Future<void> _loadWorkoutState() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final stateString = prefs.getString('workout_state');
      
      if (stateString != null) {
        final state = json.decode(stateString) as Map<String, dynamic>;
        
        _hasActiveWorkout = state['hasActiveWorkout'] ?? false;
        if (_hasActiveWorkout) {
          _activeWorkoutDay = state['dayNumber'] as int;
          _currentExerciseIndex = state['exerciseIndex'] as int;
          _workoutStartTime = DateTime.parse(state['startTime'] as String);
          
          // Check if the workout was started more than 24 hours ago
          if (DateTime.now().difference(_workoutStartTime!).inHours > 24) {
            await clearWorkoutState();
          }
        }
        
        notifyListeners();
      }
    } catch (e) {
      print('Error loading workout state: $e');
      await clearWorkoutState();
    }
  }

  // Clear workout state
  Future<void> clearWorkoutState() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('workout_state');
    
    _hasActiveWorkout = false;
    _activeWorkoutDay = null;
    _currentExerciseIndex = 0;
    _workoutStartTime = null;
    
    notifyListeners();
  }

  // Get the workout that was in progress
  WorkoutDay? getActiveWorkout() {
    if (!_hasActiveWorkout || _activeWorkoutDay == null) return null;
    
    return _workoutDays.firstWhere(
      (day) => day.dayNumber == _activeWorkoutDay,
      orElse: () => _workoutDays[0],
    );
  }

  Future<void> deleteWorkoutDay(int dayNumber) async {
    try {
      // Delete from database
      await _repository.deleteWorkoutDay(dayNumber);
      
      // Remove from local state
      _workoutDays.removeWhere((day) => day.dayNumber == dayNumber);
      _completedDays.remove(dayNumber);
      _lastWorkoutDurations.remove(dayNumber);
      
      // If the deleted day was the current day, reset it
      if (_currentWorkoutDay?.dayNumber == dayNumber) {
        _currentWorkoutDay = null;
      }
      
      notifyListeners();
    } catch (e) {
      print('Error deleting workout day: $e');
      rethrow;
    }
  }

  Future<void> updateWorkoutDay(WorkoutDay updatedWorkout) async {
    try {
      // Prepare data for database
      final workoutDayData = {
        'day_number': updatedWorkout.dayNumber,
        'title': updatedWorkout.title,
        'is_completed': updatedWorkout.isCompleted ? 1 : 0,
      };

      final exercisesData = updatedWorkout.exercises.map((e) => {
        'name': e.name,
        'sets': e.sets,
        'reps': e.reps,
        'tips': e.tips,
        'notes': e.notes,
      }).toList();

      // Update in database
      await _repository.updateWorkoutDay(updatedWorkout.dayNumber, workoutDayData, exercisesData);
      
      // Update in local state
      final index = _workoutDays.indexWhere((day) => day.dayNumber == updatedWorkout.dayNumber);
      if (index != -1) {
        _workoutDays[index] = updatedWorkout;
        
        // Update current workout day if it was the one that was updated
        if (_currentWorkoutDay?.dayNumber == updatedWorkout.dayNumber) {
          _currentWorkoutDay = updatedWorkout;
        }
      }
      
      notifyListeners();
    } catch (e) {
      print('Error updating workout day: $e');
      rethrow;
    }
  }
} 
