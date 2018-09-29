import './define.dart';
import 'package:sqflite/sqflite.dart';
import 'dart:async';

final String tableName = "record";

class Record {
  static Record _instance;
  static Database db;
  static Future<Record> get instance async {
    if (_instance == null || db == null) {
      _instance = new Record();
      await _instance.open();
    }
    return _instance;
  }

  // 打开数据库
  Future open() async {
    db = await DefineDataBase.open();
  }

  // 增
  Future<Map<String, dynamic>> insert(Map<String, dynamic> item) async {
    item["id"] = await db.insert(tableName, item);
    return item;
  }

  // 增加或更新
  Future<Map<String, dynamic>> upsert(
      dynamic whereColVale, Map<String, dynamic> item,
      [String whereColKey = "_id"]) async {
    List<Map<String, dynamic>> r = await db.rawQuery(
        "SELECT id FROM $tableName WHERE $whereColKey=? LIMIT 1;",
        [whereColVale]);
    if (r.length != 0) {
      await update(r[0]["id"], item);
      return item;
    }
    return insert(item);
  }

  // 删
  Future<int> delete(int id) async {
    return await db.delete(tableName, where: "id = ?", whereArgs: [id]);
  }

  // 改
  Future<int> update(int id, Map<String, dynamic> item) async {
    return await db.update(tableName, item, where: "id = ?", whereArgs: [id]);
  }

  // 分页查询
  Future<List<Map<String, dynamic>>> paging(
      [int page = 1, int perPage = 21]) async {
    return await db.query(tableName,
        // columns: [columnId, columnDone, columnTitle],
        // where: "$columnId = ?",
        // whereArgs: [id],
        orderBy: "time DESC",
        offset: (page - 1) * perPage,
        limit: perPage);
  }

  Future dropTable() async {
    await db.rawQuery("DROP TABLE IF EXISTS $tableName;");
  }

  Future truncateTable() async {
    await db.rawQuery("DELETE FROM $tableName;");
    await db
        .rawQuery("UPDATE sqlite_sequence SET seq=0 WHERE name='$tableName';");
  }

  Future close() async => db.close();
}
