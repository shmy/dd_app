import './define.dart';
import 'package:sqflite/sqflite.dart';
import 'dart:async';

class BaseDb {
  final String tableName;
  Database db;
  BaseDb({this.tableName}) {
    open();
  }
  // 打开数据库
  Future<BaseDb> open() async {
    if (db == null) {
      db = await DefineDataBase.open();
    }
    return this;
  }

  // 增加一条
  Future<Map<String, dynamic>> findObjectId(String id) async {
    List<Map<String, dynamic>> m = await db.query(
      tableName,
      limit: 1,
      where: "_id = ?",
      whereArgs: [id],
    );
    if (m.length > 0) {
      return m[0];
    }
    return null;
  }

  // 增加一条
  Future<Map<String, dynamic>> insert(Map<String, dynamic> item) async {
    item["id"] = await db.insert(tableName, item);
    return item;
  }

  // 增加一条或更新一条
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

  // 按id删除一条
  Future<int> delete(int id) async {
    return await db.delete(tableName, where: "id = ?", whereArgs: [id]);
  }

  // 按id修改一条
  Future<int> update(int id, Map<String, dynamic> item) async {
    return await db.update(tableName, item, where: "id = ?", whereArgs: [id]);
  }

  Future<int> updateObjectId(String _id, Map<String, dynamic> item) async {
    return await db.update(tableName, item, where: "_id = ?", whereArgs: [_id]);
  }

  // 分页查询
  Future<List<Map<String, dynamic>>> paging(
      [int page = 1, int perPage = 21, String orderBy]) async {
    return await db.query(tableName,
        orderBy: orderBy, offset: (page - 1) * perPage, limit: perPage);
  }

  // 删除表
  Future dropTable() async {
    await db.rawQuery("DROP TABLE IF EXISTS $tableName;");
  }

  // 清空表
  Future truncateTable() async {
    await db.rawQuery("DELETE FROM $tableName;");
    await db
        .rawQuery("UPDATE sqlite_sequence SET seq=0 WHERE name='$tableName';");
  }

  Future<bool> isExistsColumn(String columnName) async {
    var r = await db.rawQuery(
        "SELECT * FROM sqlite_master WHERE name='$tableName' and sql like '%$columnName%';");
    return r.length != 0;
  }

  Future<bool> addColumn(String columnName, String type,
      [dynamic defaultValue, String meta = ""]) async {
    try {
      defaultValue =
          defaultValue == null ? "" : "DEFAULT " + defaultValue.toString();
      await db.rawQuery(
          "ALTER TABLE $tableName add $columnName $type $defaultValue $meta;");
      return true;
    } catch (e) {
      return false;
    }
  }

  // 关闭数据库
  Future close() async => db.close();
}
