import 'package:sqflite/sqflite.dart';

class SQLHelper {
  static Future<void> createTables(Database database) async {
    await database.execute(""" CREATE TABLE books(
      id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
      title TEXT,
      desc TEXT,
      createdAt TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
    )
""");
  }

  static Future<Database> db() async {
    return openDatabase(
      "mp_library.db",
      version: 1,
      onCreate: (db, version) async {
        await createTables(db);
      },
    );
  }

  // bütün dataları çekme
  static Future<List<Map<String, dynamic>>> getAllData() async {
    final db = await SQLHelper.db();
    return db.query('books', orderBy: 'id');
  }

  // id'ye göre data çekme
  static Future<List<Map<String, dynamic>>> getSingleData(int id) async {
    // select * from books where id = 1;
    final db = await SQLHelper.db();
    return db.query('books', where: 'id = ?', whereArgs: [id], limit: 1);
  }

  // data ekleme
  static Future<int> createBook(String title, String? desc) async {
    final db = await SQLHelper.db();
    final data = {'title': title, 'desc': desc};
    final id = await db.insert('books', data,
        conflictAlgorithm: ConflictAlgorithm.replace);
    return id;
  }

  // data güncelleme
  static Future<int> updatedBook(int id, String title, String? desc) async {
    final db = await SQLHelper.db();
    final data = {'title': title, 'desc': desc};
    final count =
        await db.update('books', data, where: 'id = ?', whereArgs: [id]);
    return count;
  }

  // data silme
  static Future<void> deleteBook(int id) async {
    final db = await SQLHelper.db();
    try {
      await db.delete('books', where: 'id = ?', whereArgs: [id]);
    } catch (e) {}
  }
}
