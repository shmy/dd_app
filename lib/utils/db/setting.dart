import 'dart:async';
import 'package:dd_app/utils/db/basedb.dart';

class Setting extends BaseDb {
  static Setting _instance = new Setting();
  static Future<Setting> get instance async => await _instance.open(); 
  Setting() : super(tableName: "setting");
  // 按id查
  Future<Map<String, dynamic>> findById(int id) async {
    List<Map<String, dynamic>> r = await db.query(tableName,
        where: "id = ?", whereArgs: [ id ]);
    if (r.length != 0) {
      return r[0];
    }
    return null;
  }
}