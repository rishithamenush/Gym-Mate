import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../../models/weight_model.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('gymmate.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE weights(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        weight REAL NOT NULL,
        date TEXT NOT NULL,
        workoutDay INTEGER NOT NULL
      )
    ''');
  }

  Future<int> insertWeight(WeightModel weight) async {
    final db = await instance.database;
    return await db.insert('weights', weight.toMap());
  }

  Future<List<WeightModel>> getAllWeights() async {
    final db = await instance.database;
    final List<Map<String, dynamic>> maps = await db.query('weights');
    return List.generate(maps.length, (i) => WeightModel.fromMap(maps[i]));
  }

  Future<List<WeightModel>> getWeightsByDay(int workoutDay) async {
    final db = await instance.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'weights',
      where: 'workoutDay = ?',
      whereArgs: [workoutDay],
    );
    return List.generate(maps.length, (i) => WeightModel.fromMap(maps[i]));
  }

  Future<void> close() async {
    final db = await instance.database;
    db.close();
  }
} 