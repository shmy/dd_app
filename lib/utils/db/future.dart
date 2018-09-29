import 'package:dd_app/utils/db/record.dart';

class FutureUpdateDB {
  static future() async {
    await future20180815();
  }

  // 给记录表添加 part_name part_time 字段
  static future20180815() async {
    final List<Map<String, dynamic>> fields = [
      {"name": "tag_name", "type": "text", "default": "未知", "meta": "NOT NULL", },
      {"name": "tag_time", "type": "integer", "default": 0, "meta": "NOT NULL", },
    ];
    Record r = await Record.instance;

    for (int i = 0, j = fields.length; i < j; i++) {
      final String name = fields[i]["name"];
      final String type = fields[i]["type"];
      final dynamic defaultValue = fields[i]["default"];
      final String meta = fields[i]["meta"];
      if (!await r.isExistsColumn(name)) {
        await r.addColumn(name, type, defaultValue, meta);
      }
    }
  }
}
