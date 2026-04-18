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
    return await openDatabase(path, version: 1, onCreate: _onCreate);
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
  }
}