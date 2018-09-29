import 'dart:async';

import 'package:dd_app/utils/db/basedb.dart';

class Search extends BaseDb {
  static Search _instance = new Search();
  static Future<Search> get instance async => await _instance.open(); 
  Search() : super(tableName: "search");
  
}
