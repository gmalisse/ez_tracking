import 'package:sqflite/sqflite.dart';
import '../models/jogo.dart';
import '../database/db_helper.dart';

class JogoRepository {
  final DbHelper _dbHelper = DbHelper();

  Future<int> create(Jogo jogo) async {
    final db = await _dbHelper.database;
    return await db.insert('jogo', jogo.toMap());
  }

  Future<Jogo?> getById(int id) async {
    final db = await _dbHelper.database;
    final maps = await db.query('jogo', where: 'id = ?', whereArgs: [id]);
    if (maps.isNotEmpty) {
      return Jogo.fromMap(maps.first);
    }
    return null;
  }

  Future<Jogo?> getByName(String nome) async {
    final db = await _dbHelper.database;
    final maps = await db.query('jogo', where: 'nome = ?', whereArgs: [nome]);
    if (maps.isNotEmpty) {
      return Jogo.fromMap(maps.first);
    }
    return null;
  }

  Future<List<Jogo>> getAll() async {
    final db = await _dbHelper.database;
    final maps = await db.query('jogo');
    return maps.map((map) => Jogo.fromMap(map)).toList();
  }

  Future<int> update(Jogo jogo) async {
    final db = await _dbHelper.database;
    return await db.update(
      'jogo',
      jogo.toMap(),
      where: 'id = ?',
      whereArgs: [jogo.id],
    );
  }

  Future<int> delete(int id) async {
    final db = await _dbHelper.database;
    return await db.delete('jogo', where: 'id = ?', whereArgs: [id]);
  }
}
