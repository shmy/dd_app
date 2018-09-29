import 'package:dd_app/utils/db/basedb.dart';
import 'dart:async';

class User extends BaseDb {
  static User _instance = new User();
  static Future<User> get instance async => await _instance.open();
  User() : super(tableName: "user");
  
  Future<Map> findID1() async {
    List<Map> r = await db.query(tableName, where: "id = 1");
    return r.length != 0 ? r[0] : null;
  }
  
}