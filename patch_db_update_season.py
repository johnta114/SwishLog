import re

with open('lib/database/database_helper.dart', 'r') as f:
    content = f.read()

update_season = """  Future<int> updateSeason(String id, Map<String, dynamic> data) async {
    final db = await instance.database;
    return await db.update('seasons', data, where: 'id = ?', whereArgs: [id]);
  }

  Future<int> deleteSeason(String id) async {"""

content = content.replace("  Future<int> deleteSeason(String id) async {", update_season)

with open('lib/database/database_helper.dart', 'w') as f:
    f.write(content)
