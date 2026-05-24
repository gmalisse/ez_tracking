import '../models/user.dart';
import '../database/db_helper.dart';

class UserRepository {
  final DbHelper _dbHelper = DbHelper();

  Future<int> create(User user) async {
    final db = await _dbHelper.database;
    return await db.insert('user', user.toMap());
  }

  Future<User?> getById(int id) async {
    final db = await _dbHelper.database;
    final maps = await db.query(
      'user',
      where: 'id = ?',
      whereArgs: [id.toString()],
    );
    if (maps.isNotEmpty) {
      return User.fromMap(maps.first);
    }
    return null;
  }

  Future<User?> getByEmail(String email) async {
    final db = await _dbHelper.database;
    final maps = await db.query('user', where: 'email = ?', whereArgs: [email]);
    if (maps.isNotEmpty) {
      return User.fromMap(maps.first);
    }
    return null;
  }

  Future<List<User>> getAll() async {
    final db = await _dbHelper.database;
    final maps = await db.query('user');
    return maps.map((map) => User.fromMap(map)).toList();
  }

  Future<int> update(User user) async {
    final db = await _dbHelper.database;
    return await db.update(
      'user',
      user.toMap(),
      where: 'id = ?',
      whereArgs: [user.id?.toString()],
    );
  }

  Future<int> delete(int id) async {
    final db = await _dbHelper.database;
    return await db.delete('user', where: 'id = ?', whereArgs: [id.toString()]);
  }
}
