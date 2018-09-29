import 'dart:async';

import 'package:dd_app/utils/db/basedb.dart';

class Record extends BaseDb {
  static Record _instance = new Record();
  static Future<Record> get instance async => await _instance.open(); 
  Record() : super(tableName: "record");
  
}
