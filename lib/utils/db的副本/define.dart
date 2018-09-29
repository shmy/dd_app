import 'package:sqflite/sqflite.dart';
import 'dart:async';

final DBName = "main.db";

class DefineDataBase {
  static Database db;
  static Future<Database> open() async {
    if (DefineDataBase.db == null) {
      String databasesPath = await getDatabasesPath();
      String path = databasesPath + "/" + DBName;
      // await deleteDatabase(path);
      DefineDataBase.db =
          await openDatabase(path, version: 1, onOpen: (Database db) async {
        // execute 每次只能一条语句
        // 用户表
        await db.execute('''
          CREATE TABLE IF NOT EXISTS user ( 
            id integer primary key autoincrement, 
            _id text not null,
            username text not null,
            nickname text not null,
            avatar text not null,
            email text not null,
            level integer not null,
            integral integer not null,
            token text not null,
            overdue integer not null
          );
          ''');
        // 播放历史表
        await db.execute('''
          CREATE TABLE IF NOT EXISTS record ( 
            id integer primary key autoincrement, 
            _id text not null,
            name text not null,
            pic text not null,
            time integer not null
          );
          ''');
        // 搜索记录表
        await db.execute('''
          CREATE TABLE IF NOT EXISTS search ( 
            id integer primary key autoincrement, 
            keyword text not null,
            time integer not null
          );
          ''');
        // 系统设置表
        await db.execute('''
          CREATE TABLE IF NOT EXISTS setting ( 
            id integer primary key autoincrement, 
            theme_index integer not null
          );
          ''');
      });
    }
    return DefineDataBase.db;
  }
}
