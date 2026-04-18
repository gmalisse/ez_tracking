import 'package:sqflite/sqflite.dart';
import '../models/gameplay.dart';
import '../database/db_helper.dart';

class GameplayRepository {
  final DbHelper _dbHelper = DbHelper();

  Future<int> create(Gameplay gameplay) async {
    final db = await _dbHelper.database;
    return await db.insert('gameplays', gameplay.toMap());
  }

  Future<Gameplay?> getById(int id) async {
    final db = await _dbHelper.database;
    final maps = await db.query('gameplays', where: 'id = ?', whereArgs: [id]);
    if (maps.isNotEmpty) {
      return Gameplay.fromMap(maps.first);
    }
    return null;
  }

  Future<List<Gameplay>> getAll() async {
    final db = await _dbHelper.database;
    final maps = await db.query('gameplays');
    return maps.map((map) => Gameplay.fromMap(map)).toList();
  }

  Future<List<Gameplay>> getByUserId(int usersId) async {
    final db = await _dbHelper.database;
    final maps = await db.query(
      'gameplays',
      where: 'usersId = ?',
      whereArgs: [usersId],
    );
    return maps.map((map) => Gameplay.fromMap(map)).toList();
  }

  Future<List<Gameplay>> getByJogoId(int jogosId) async {
    final db = await _dbHelper.database;
    final maps = await db.query(
      'gameplays',
      where: 'jogosId = ?',
      whereArgs: [jogosId],
    );
    return maps.map((map) => Gameplay.fromMap(map)).toList();
  }

  Future<int> update(Gameplay gameplay) async {
    final db = await _dbHelper.database;
    return await db.update(
      'gameplays',
      gameplay.toMap(),
      where: 'id = ?',
      whereArgs: [gameplay.id],
    );
  }

  Future<int> delete(int id) async {
    final db = await _dbHelper.database;
    return await db.delete('gameplays', where: 'id = ?', whereArgs: [id]);
  }
}
