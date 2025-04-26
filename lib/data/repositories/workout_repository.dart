import 'package:gymmate/data/database/database_helper.dart';
import 'package:sqflite/sqflite.dart';

class WorkoutRepository {
  final DatabaseHelper _databaseHelper;

  WorkoutRepository({DatabaseHelper? databaseHelper})
      : _databaseHelper = databaseHelper ?? DatabaseHelper();

  // Workout completion methods
  Future<bool> completeWorkout(int dayNumber, {required int durationInSeconds}) async {
    try {
      // First check if workout was already completed today
      bool alreadyCompleted = await _databaseHelper.isWorkoutCompletedToday(dayNumber);
      if (alreadyCompleted) {
        return false;
      }

      // Record the workout completion with duration
      await _databaseHelper.recordWorkoutCompletion(
        dayNumber,
        durationInSeconds: durationInSeconds,
      );
      return true;
    } catch (e) {
      print('Error completing workout: $e');
      return false;
    }
  }

  Future<Map<String, dynamic>?> getLastWorkoutForDay(int dayNumber) async {
    try {
      return await _databaseHelper.getLastWorkoutForDay(dayNumber);
    } catch (e) {
      print('Error getting last workout: $e');
      return null;
    }
  }

  // Progress tracking methods
  Future<bool> canRecordProgress() async {
    try {
      // Check if any workouts were completed this week
      final completedWorkouts = await _databaseHelper.getCompletedWorkoutsForCurrentWeek();
      if (completedWorkouts.isEmpty) {
        return false;
      }

      // Check if progress was already recorded this week
      bool alreadyRecorded = await _databaseHelper.isProgressRecordedForCurrentWeek();
      return !alreadyRecorded;
    } catch (e) {
      print('Error checking progress eligibility: $e');
      return false;
    }
  }

  Future<bool> recordWeeklyProgress(double weight) async {
    try {
      await _databaseHelper.recordWeeklyProgress(weight);
      return true;
    } catch (e) {
      print('Error recording progress: $e');
      return false;
    }
  }

  Future<List<Map<String, dynamic>>> getAllProgress() async {
    try {
      return await _databaseHelper.getAllProgress();
    } catch (e) {
      print('Error getting progress: $e');
      return [];
    }
  }

  Future<double?> getLatestWeight() async {
    try {
      return await _databaseHelper.getLatestWeight();
    } catch (e) {
      print('Error getting latest weight: $e');
      return null;
    }
  }

  Future<List<Map<String, dynamic>>> getCompletedWorkoutsForCurrentWeek() async {
    try {
      return await _databaseHelper.getCompletedWorkoutsForCurrentWeek();
    } catch (e) {
      print('Error getting completed workouts: $e');
      return [];
    }
  }

  // Workout days and exercises methods
  Future<void> saveWorkoutDay(Map<String, dynamic> workoutDay, List<Map<String, dynamic>> exercises) async {
    try {
      await _databaseHelper.saveWorkoutDay(workoutDay, exercises);
    } catch (e) {
      print('Error saving workout day: $e');
      rethrow;
    }
  }

  Future<List<Map<String, dynamic>>> getWorkoutDays() async {
    try {
      return await _databaseHelper.getWorkoutDays();
    } catch (e) {
      print('Error getting workout days: $e');
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> getExercisesForDay(int workoutDayId) async {
    try {
      return await _databaseHelper.getExercisesForWorkoutDay(workoutDayId);
    } catch (e) {
      print('Error getting exercises for day: $e');
      return [];
    }
  }

  Future<void> clearWorkoutHistory() async {
    try {
      final db = await _databaseHelper.database;
      await db.transaction((txn) async {
        await txn.delete('workout_completions');
        await txn.delete('progress');
        await txn.update('workout_days', {'is_completed': 0});
      });
    } catch (e) {
      print('Error clearing workout history: $e');
      rethrow;
    }
  }

  Future<void> insertWorkoutDay(Map<String, dynamic> workoutDay) async {
    final db = await _databaseHelper.database;
    await db.insert(
      'workout_days',
      {
        'day_number': workoutDay['day'],
        'title': workoutDay['title'],
        'is_completed': 0,
        'completion_date': null,
        'duration': 0,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> insertExercise(Map<String, dynamic> exercise) async {
    final db = await _databaseHelper.database;
    await db.insert(
      'exercises',
      {
        'day_number': exercise['day_number'],
        'name': exercise['name'],
        'sets': exercise['sets'],
        'tips': exercise['tips'],
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> markWorkoutComplete(int dayNumber, int duration) async {
    final db = await _databaseHelper.database;
    await db.update(
      'workout_days',
      {
        'is_completed': 1,
        'completion_date': DateTime.now().toIso8601String(),
        'duration': duration,
      },
      where: 'day_number = ?',
      whereArgs: [dayNumber],
    );
  }

  Future<void> deleteWorkoutDay(int dayNumber) async {
    final db = await _databaseHelper.database;
    
    await db.transaction((txn) async {
      // Delete exercises first (foreign key constraint)
      await txn.delete(
        'exercises',
        where: 'day_number = ?',
        whereArgs: [dayNumber],
      );
      
      // Delete workout day
      await txn.delete(
        'workout_days',
        where: 'day_number = ?',
        whereArgs: [dayNumber],
      );
    });
  }

  Future<void> updateWorkoutDay(
    int dayNumber,
    Map<String, dynamic> workoutDayData,
    List<Map<String, dynamic>> exercisesData,
  ) async {
    final db = await _databaseHelper.database;
    
    await db.transaction((txn) async {
      // Update workout day
      await txn.update(
        'workout_days',
        workoutDayData,
        where: 'day_number = ?',
        whereArgs: [dayNumber],
      );
      
      // Delete existing exercises
      await txn.delete(
        'exercises',
        where: 'day_number = ?',
        whereArgs: [dayNumber],
      );
      
      // Insert new exercises
      for (var exercise in exercisesData) {
        exercise['day_number'] = dayNumber;
        await txn.insert('exercises', exercise);
      }
    });
  }
} 