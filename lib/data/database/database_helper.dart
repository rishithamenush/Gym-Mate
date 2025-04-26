import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  static Database? _database;

  factory DatabaseHelper() => _instance;

  DatabaseHelper._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final String path = join(await getDatabasesPath(), 'gymmate.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: _createTables,
    );
  }

  Future<void> _createTables(Database db, int version) async {
    // Create workout_days table
    await db.execute('''
      CREATE TABLE workout_days(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        day_number INTEGER NOT NULL,
        title TEXT NOT NULL,
        is_completed INTEGER DEFAULT 0,
        completion_date TEXT,
        duration INTEGER DEFAULT 0
      )
    ''');

    // Create exercises table
    await db.execute('''
      CREATE TABLE exercises(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        day_number INTEGER NOT NULL,
        name TEXT NOT NULL,
        sets TEXT NOT NULL,
        tips TEXT,
        FOREIGN KEY (day_number) REFERENCES workout_days (day_number)
      )
    ''');
  }

  Future<void> deleteDatabase() async {
    final String path = join(await getDatabasesPath(), 'gymmate.db');
    await databaseFactory.deleteDatabase(path);
    _database = null;
  }

  // Workout completion methods
  Future<bool> isWorkoutCompletedToday(int dayNumber) async {
    final db = await database;
    final today = DateTime.now().toIso8601String().split('T')[0];
    
    final result = await db.query(
      'workout_completions',
      where: 'day_number = ? AND completion_date = ?',
      whereArgs: [dayNumber, today],
    );
    
    return result.isNotEmpty;
  }

  Future<void> recordWorkoutCompletion(int dayNumber, {required int durationInSeconds}) async {
    final db = await database;
    final today = DateTime.now().toIso8601String().split('T')[0];
    
    await db.insert('workout_completions', {
      'day_number': dayNumber,
      'completion_date': today,
      'duration': durationInSeconds,
    });
  }

  Future<Map<String, dynamic>?> getLastWorkoutForDay(int dayNumber) async {
    final db = await database;
    final results = await db.query(
      'workout_completions',
      where: 'day_number = ?',
      whereArgs: [dayNumber],
      orderBy: 'completion_date DESC',
      limit: 1,
    );
    
    if (results.isNotEmpty) {
      return results.first;
    }
    return null;
  }

  // Progress tracking methods
  Future<bool> isProgressRecordedForCurrentWeek() async {
    final db = await database;
    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    final startDate = startOfWeek.toIso8601String().split('T')[0];
    
    final result = await db.query(
      'progress',
      where: 'date >= ?',
      whereArgs: [startDate],
    );
    
    return result.isNotEmpty;
  }

  Future<void> recordWeeklyProgress(double weight) async {
    final db = await database;
    final today = DateTime.now().toIso8601String().split('T')[0];
    
    await db.insert('progress', {
      'weight': weight,
      'date': today,
    });
  }

  Future<List<Map<String, dynamic>>> getAllProgress() async {
    final db = await database;
    return await db.query('progress', orderBy: 'date DESC');
  }

  Future<double?> getLatestWeight() async {
    final db = await database;
    final result = await db.query(
      'progress',
      orderBy: 'date DESC',
      limit: 1,
    );
    
    if (result.isEmpty) return null;
    return result.first['weight'] as double;
  }

  Future<List<Map<String, dynamic>>> getCompletedWorkoutsForCurrentWeek() async {
    final db = await database;
    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    final startDate = startOfWeek.toIso8601String().split('T')[0];
    
    return await db.query(
      'workout_completions',
      where: 'completion_date >= ?',
      whereArgs: [startDate],
    );
  }

  // Workout days and exercises methods
  Future<void> saveWorkoutDay(Map<String, dynamic> workoutDay, List<Map<String, dynamic>> exercises) async {
    final db = await database;
    await db.transaction((txn) async {
      final workoutDayId = await txn.insert('workout_days', workoutDay);
      
      for (var exercise in exercises) {
        exercise['day_number'] = workoutDayId;
        await txn.insert('exercises', exercise);
      }
    });
  }

  Future<List<Map<String, dynamic>>> getWorkoutDays() async {
    final db = await database;
    return await db.query('workout_days', orderBy: 'day_number');
  }

  Future<List<Map<String, dynamic>>> getExercisesForWorkoutDay(int workoutDayId) async {
    final db = await database;
    return await db.query(
      'exercises',
      where: 'day_number = ?',
      whereArgs: [workoutDayId],
    );
  }
} 