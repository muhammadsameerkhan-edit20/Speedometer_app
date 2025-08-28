import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

import '../Model/tracking_history.dart'; // import your model

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  DatabaseHelper._internal();

  static Database? _db;

  Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await _initDB();
    return _db!;
  }

  Future<Database> _initDB() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'tracking_history.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
  CREATE TABLE records (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    distance REAL,
    averageSpeed REAL,
    topSpeed REAL,
    duration INTEGER,
    timestamp TEXT
  )
''');

        // Create a settings table to store the speed limit
        await db.execute('''
  CREATE TABLE settings (
    key TEXT PRIMARY KEY,
    value TEXT
  )
''');

        // Insert default speed limit
        await db.insert('settings', {'key': 'speed_limit', 'value': '200'});
      },
    );
  }

  Future<void> insertRecord(TrackingRecord record) async {
    final db = await database;
    await db.insert(
      'records',
      record.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<TrackingRecord>> getRecords() async {
    final db = await database;
    final maps = await db.query('records', orderBy: 'timestamp DESC');
    return maps.map((e) => TrackingRecord.fromMap(e)).toList();
  }

  Future<void> clearHistory() async {
    final db = await database;
    await db.delete('records');
  }
  Future<double> getSpeedLimit() async {
    final db = await database;
    final result = await db.query(
      'settings',
      where: 'key = ?',
      whereArgs: ['speed_limit'],
    );

    if (result.isNotEmpty) {
      return double.tryParse(result.first['value'] as String) ?? 200.0;
    } else {
      return 200.0; // default if not found
    }
  }

  Future<void> updateSpeedLimit(double newLimit) async {
    final db = await database;
    await db.update(
      'settings',
      {'value': newLimit.toString()},
      where: 'key = ?',
      whereArgs: ['speed_limit'],
    );
  }

}
