import '../models/gameplay.dart';
import '../database/db_helper.dart';

class GameplayRepository {
  final DbHelper _dbHelper = DbHelper();

  Future<int> create(Gameplay gameplay) async {
    final db = await _dbHelper.database;
    return await db.insert('gameplay', gameplay.toMap());
  }

  Future<Gameplay?> getById(int id) async {
    final db = await _dbHelper.database;
    final maps = await db.query(
      'gameplay',
      where: 'id = ?',
      whereArgs: [id.toString()],
    );
    if (maps.isNotEmpty) {
      return Gameplay.fromMap(maps.first);
    }
    return null;
  }

  Future<List<Gameplay>> getAll() async {
    final db = await _dbHelper.database;
    final maps = await db.query('gameplay');
    return maps.map((map) => Gameplay.fromMap(map)).toList();
  }

  Future<List<Gameplay>> getByUserId(int usersId) async {
    final db = await _dbHelper.database;
    final maps = await db.query(
      'gameplay',
      where: 'usersId = ?',
      whereArgs: [usersId.toString()],
    );
    return maps.map((map) => Gameplay.fromMap(map)).toList();
  }

  Future<List<Gameplay>> getByJogoId(int jogosId) async {
    final db = await _dbHelper.database;
    final maps = await db.query(
      'gameplay',
      where: 'jogosId = ?',
      whereArgs: [jogosId.toString()],
    );
    return maps.map((map) => Gameplay.fromMap(map)).toList();
  }

  Future<int> update(Gameplay gameplay) async {
    final db = await _dbHelper.database;
    return await db.update(
      'gameplay',
      gameplay.toMap(),
      where: 'id = ?',
      whereArgs: [gameplay.id?.toString()],
    );
  }

  Future<int> delete(int id) async {
    final db = await _dbHelper.database;
    return await db.delete(
      'gameplay',
      where: 'id = ?',
      whereArgs: [id.toString()],
    );
  }
}
