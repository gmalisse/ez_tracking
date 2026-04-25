import 'package:sqflite/sqflite.dart';
import '../database/db_helper.dart';
import '../models/userdata.dart';

class UserDataRepository {
  final DbHelper _dbHelper = DbHelper();

  Future<int> create(UserData userData) async {
    final db = await _dbHelper.database;
    return await db.insert('userdata', userData.toMap());
  }

  Future<UserData?> getById(int id) async {
    final db = await _dbHelper.database;
    final maps = await db.query('userdata', where: 'id = ?', whereArgs: [id]);
    if (maps.isNotEmpty) {
      return UserData.fromMap(maps.first);
    }
    return null;
  }

  Future<UserData?> getByUserId(int userId) async {
    final db = await _dbHelper.database;
    final maps = await db.query(
      'userdata',
      where: 'userId = ?',
      whereArgs: [userId],
    );
    if (maps.isNotEmpty) {
      return UserData.fromMap(maps.first);
    }
    return null;
  }

  Future<List<UserData>> getAll() async {
    final db = await _dbHelper.database;
    final maps = await db.query('userdata');
    return maps.map((map) => UserData.fromMap(map)).toList();
  }

  Future<int> update(UserData userData) async {
    final db = await _dbHelper.database;
    return await db.update(
      'userdata',
      userData.toMap(),
      where: 'id = ?',
      whereArgs: [userData.id],
    );
  }

  Future<int> delete(int id) async {
    final db = await _dbHelper.database;
    return await db.delete('userdata', where: 'id = ?', whereArgs: [id]);
  }
}
