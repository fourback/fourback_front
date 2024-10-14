import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class FriendChatDatabaseHelper {
  static final FriendChatDatabaseHelper _instance = FriendChatDatabaseHelper._internal();
  static Database? _database;

  factory FriendChatDatabaseHelper() {
    return _instance;
  }

  FriendChatDatabaseHelper._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;

    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'friend_chat_database.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute(
      '''
      CREATE TABLE FriendChatMessage (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        chatRoomId TEXT,    -- 1대1 채팅방 ID
        userId  INTEGER,    -- 메시지 보낸 사람의 ID
        sender TEXT,        -- 메시지 보낸 사람의 이름
        message TEXT,       -- 메시지 내용
        timestamp TEXT      -- 메시지 보낸 시간
      )
      ''',
    );
  }


  /// 메시지 삽입 (1대1 채팅)
  Future<int> insertMessage(Map<String, dynamic> message) async {
    final db = await database;
    return await db.insert('FriendChatMessage', message);
  }

  /// 1대1 채팅 메시지 조회
  Future<List<Map<String, dynamic>>> getMessages(String chatRoomId) async {
    final db = await database;
    return await db.query(
      'FriendChatMessage',
      where: 'chatRoomId = ?',
      whereArgs: [chatRoomId],
      orderBy: 'timestamp ASC',
    );
  }

  /// DB 삭제
  Future<void> deleteDatabaseFile() async {
    String path = join(await getDatabasesPath(), 'friend_chat_database.db');
    await deleteDatabase(path);
  }
}