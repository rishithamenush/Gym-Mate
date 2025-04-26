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
    String path = join(await getDatabasesPath(), 'gymmate.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
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
        reps INTEGER DEFAULT 12,
        tips TEXT,
        notes TEXT,
        FOREIGN KEY (day_number) REFERENCES workout_days (day_number) ON DELETE CASCADE
      )
    ''');

    // Create workout_completions table
    await db.execute('''
      CREATE TABLE workout_completions(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        day_number INTEGER NOT NULL,
        completion_date TEXT NOT NULL,
        duration INTEGER NOT NULL,
        FOREIGN KEY (day_number) REFERENCES workout_days (day_number) ON DELETE CASCADE
      )
    ''');

    // Create progress table
    await db.execute('''
      CREATE TABLE progress(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        weight REAL NOT NULL,
        date TEXT NOT NULL
      )
    ''');
  }

  // Workout Days Methods
  Future<int> insertWorkoutDay(Map<String, dynamic> workoutDay) async {
    final db = await database;
    return await db.insert('workout_days', workoutDay);
  }

  Future<List<Map<String, dynamic>>> getWorkoutDays() async {
    final db = await database;
    return await db.query('workout_days', orderBy: 'day_number');
  }

  Future<void> updateWorkoutDay(int dayNumber, Map<String, dynamic> workoutDay) async {
    final db = await database;
    await db.update(
      'workout_days',
      workoutDay,
      where: 'day_number = ?',
      whereArgs: [dayNumber],
    );
  }

  Future<void> deleteWorkoutDay(int dayNumber) async {
    final db = await database;
    await db.delete(
      'workout_days',
      where: 'day_number = ?',
      whereArgs: [dayNumber],
    );
  }

  // Exercises Methods
  Future<int> insertExercise(Map<String, dynamic> exercise) async {
    final db = await database;
    return await db.insert('exercises', exercise);
  }

  Future<List<Map<String, dynamic>>> getExercisesForDay(int dayNumber) async {
    final db = await database;
    return await db.query(
      'exercises',
      where: 'day_number = ?',
      whereArgs: [dayNumber],
    );
  }

  Future<void> updateExercise(int id, Map<String, dynamic> exercise) async {
    final db = await database;
    await db.update(
      'exercises',
      exercise,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> deleteExercise(int id) async {
    final db = await database;
    await db.delete(
      'exercises',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Workout Completions Methods
  Future<void> recordWorkoutCompletion(int dayNumber, int duration) async {
    final db = await database;
    await db.insert('workout_completions', {
      'day_number': dayNumber,
      'completion_date': DateTime.now().toIso8601String(),
      'duration': duration,
    });
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

  Future<Map<String, dynamic>?> getLastWorkoutForDay(int dayNumber) async {
    final db = await database;
    final results = await db.query(
      'workout_completions',
      where: 'day_number = ?',
      whereArgs: [dayNumber],
      orderBy: 'completion_date DESC',
      limit: 1,
    );
    return results.isNotEmpty ? results.first : null;
  }

  // Progress Methods
  Future<void> recordProgress(double weight) async {
    final db = await database;
    await db.insert('progress', {
      'weight': weight,
      'date': DateTime.now().toIso8601String(),
    });
  }

  Future<double?> getLatestWeight() async {
    final db = await database;
    final results = await db.query(
      'progress',
      orderBy: 'date DESC',
      limit: 1,
    );
    return results.isNotEmpty ? results.first['weight'] as double : null;
  }

  Future<List<Map<String, dynamic>>> getAllProgress() async {
    final db = await database;
    return await db.query('progress', orderBy: 'date DESC');
  }

  // Utility Methods
  Future<void> clearAllData() async {
    final db = await database;
    await db.transaction((txn) async {
      await txn.delete('workout_completions');
      await txn.delete('progress');
      await txn.delete('exercises');
      await txn.delete('workout_days');
    });
  }
} 