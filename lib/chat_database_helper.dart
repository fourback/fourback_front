import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class ChatDatabaseHelper {
  static final ChatDatabaseHelper _instance = ChatDatabaseHelper._internal();
  static Database? _database;

  factory ChatDatabaseHelper() {
    return _instance;
  }

  ChatDatabaseHelper._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;

    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'chat_database.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute(
      '''
      CREATE TABLE ChatMessage (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        groupId INTEGER,
        userId  INTEGER,
        sender TEXT,
        message TEXT,
        timestamp TEXT
      )
      ''',
    );
  }

  Future<int> insertMessage(Map<String, dynamic> message) async {
    final db = await database;
    return await db.insert('ChatMessage', message);
  }

  Future<List<Map<String, dynamic>>> getMessages() async {
    final db = await database;
    return await db.query('ChatMessage', orderBy: 'timestamp ASC');
  }

  Future<void> deleteDatabaseFile() async {
    String path = join(await getDatabasesPath(), 'chat_database.db');
    await deleteDatabase(path);
  }
}