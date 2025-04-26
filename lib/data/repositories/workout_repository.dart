import 'package:gymmate/data/database/database_helper.dart';
import 'package:sqflite/sqflite.dart';

class WorkoutRepository {
  final DatabaseHelper _databaseHelper;

  WorkoutRepository({DatabaseHelper? databaseHelper})
      : _databaseHelper = databaseHelper ?? DatabaseHelper();

  // Workout completion methods
  Future<bool> completeWorkout(int dayNumber, {required int durationInSeconds}) async {
    try {
      // Record the workout completion with duration
      await _databaseHelper.recordWorkoutCompletion(dayNumber, durationInSeconds);
      
      // Update the workout day's completion status
      await _databaseHelper.updateWorkoutDay(dayNumber, {
        'is_completed': 1,
        'completion_date': DateTime.now().toIso8601String(),
        'duration': durationInSeconds,
      });
      
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
      return completedWorkouts.isNotEmpty;
    } catch (e) {
      print('Error checking progress eligibility: $e');
      return false;
    }
  }

  Future<bool> recordWeeklyProgress(double weight) async {
    try {
      await _databaseHelper.recordProgress(weight);
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
      final db = await _databaseHelper.database;
      await db.transaction((txn) async {
        final workoutDayId = await txn.insert('workout_days', workoutDay);
        
        for (var exercise in exercises) {
          exercise['day_number'] = workoutDayId;
          await txn.insert('exercises', exercise);
        }
      });
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
      return await _databaseHelper.getExercisesForDay(workoutDayId);
    } catch (e) {
      print('Error getting exercises for day: $e');
      return [];
    }
  }

  Future<void> clearWorkoutHistory() async {
    try {
      await _databaseHelper.clearAllData();
    } catch (e) {
      print('Error clearing workout history: $e');
      rethrow;
    }
  }

  Future<void> insertWorkoutDay(Map<String, dynamic> workoutDay) async {
    try {
      await _databaseHelper.insertWorkoutDay(workoutDay);
    } catch (e) {
      print('Error inserting workout day: $e');
      rethrow;
    }
  }

  Future<void> insertExercise(Map<String, dynamic> exercise) async {
    try {
      await _databaseHelper.insertExercise(exercise);
    } catch (e) {
      print('Error inserting exercise: $e');
      rethrow;
    }
  }

  Future<void> updateWorkoutDay(int dayNumber, Map<String, dynamic> workoutDayData, List<Map<String, dynamic>> exercisesData) async {
    try {
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
    } catch (e) {
      print('Error updating workout day: $e');
      rethrow;
    }
  }

  Future<void> deleteWorkoutDay(int dayNumber) async {
    try {
      await _databaseHelper.deleteWorkoutDay(dayNumber);
    } catch (e) {
      print('Error deleting workout day: $e');
      rethrow;
    }
  }
} 