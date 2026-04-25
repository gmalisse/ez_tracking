import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DbHelper {
  static final DbHelper _instance = DbHelper._internal();
  factory DbHelper() => _instance;
  DbHelper._internal();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDb();
    return _database!;
  }

  Future<Database> _initDb() async {
    String path = join(await getDatabasesPath(), 'ez_tracking.db');
    return await openDatabase(
      path,
      version: 3,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE jogo (
        id TEXT PRIMARY KEY,
        nome TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE user (
        id TEXT PRIMARY KEY,
        nome TEXT NOT NULL,
        email TEXT NOT NULL,
        senha TEXT NOT NULL,
        dataNascimento TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE gameplay (
        id TEXT PRIMARY KEY,
        usersId TEXT NOT NULL,
        jogosId TEXT NOT NULL,
        horasJogadas REAL NOT NULL,
        dataInicio TEXT NOT NULL,
        dataFim TEXT,
        zerado INTEGER NOT NULL,
        console TEXT NOT NULL,
        FOREIGN KEY (usersId) REFERENCES user (id),
        FOREIGN KEY (jogosId) REFERENCES jogo (id)
      )
    ''');

    await db.execute('''
      CREATE TABLE userdata (
        id TEXT PRIMARY KEY,
        userId TEXT UNIQUE NOT NULL,
        jogosJogados INTEGER NOT NULL,
        totalHoras REAL NOT NULL,
        generoFavorito TEXT NOT NULL,
        jogoMaisHoras TEXT NOT NULL,
        FOREIGN KEY (userId) REFERENCES user (id)
      )
    ''');
  }

  Future<bool> _tableExists(Database db, String tableName) async {
    final result = await db.rawQuery(
      "SELECT name FROM sqlite_master WHERE type='table' AND name=?",
      [tableName],
    );
    return result.isNotEmpty;
  }

  Future<bool> _columnExists(
    Database db,
    String tableName,
    String columnName,
  ) async {
    final result = await db.rawQuery('PRAGMA table_info($tableName)');
    return result.any((row) => row['name'] == columnName);
  }

  Future _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      final hasUserDataTable = await _tableExists(db, 'userdata');
      if (!hasUserDataTable) {
        await db.execute('''
          CREATE TABLE userdata (
            id TEXT PRIMARY KEY,
            userId TEXT UNIQUE NOT NULL,
            jogosJogados INTEGER NOT NULL,
            totalHoras REAL NOT NULL,
            generoFavorito TEXT NOT NULL,
            jogoMaisHoras TEXT NOT NULL,
            FOREIGN KEY (userId) REFERENCES user (id)
          )
        ''');
      }
    }

    if (oldVersion < 3) {
      final hasUserDataTable = await _tableExists(db, 'userdata');
      if (hasUserDataTable) {
        final hasUserIdColumn = await _columnExists(db, 'userdata', 'userId');
        if (!hasUserIdColumn) {
          await db.execute('ALTER TABLE userdata ADD COLUMN userId TEXT');
        }
        await db.execute(
          'CREATE UNIQUE INDEX IF NOT EXISTS idx_userdata_userId ON userdata (userId)',
        );
      }
    }
  }
}
