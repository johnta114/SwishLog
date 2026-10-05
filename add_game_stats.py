import re

with open('lib/database/database_helper.dart', 'r') as f:
    content = f.read()

new_method = """  Future<List<Map<String, dynamic>>> getGamePlayerStats(String gameId) async {
    final db = await instance.database;
    return await db.rawQuery('''
      SELECT p.id as player_id, r.jersey_number, p.court_name, p.last_name, p.first_name, 
             COALESCE(SUM(CASE WHEN s.stat_type = '2P' AND s.is_made = 1 THEN 2 ELSE 0 END), 0) +
             COALESCE(SUM(CASE WHEN s.stat_type = '3P' AND s.is_made = 1 THEN 3 ELSE 0 END), 0) +
             COALESCE(SUM(CASE WHEN s.stat_type = 'FT' AND s.is_made = 1 THEN 1 ELSE 0 END), 0) as PTS,
             COALESCE(SUM(CASE WHEN s.stat_type = '2P' THEN 1 ELSE 0 END), 0) as FGA2,
             COALESCE(SUM(CASE WHEN s.stat_type = '2P' AND s.is_made = 1 THEN 1 ELSE 0 END), 0) as FGM2,
             COALESCE(SUM(CASE WHEN s.stat_type = '3P' THEN 1 ELSE 0 END), 0) as FGA3,
             COALESCE(SUM(CASE WHEN s.stat_type = '3P' AND s.is_made = 1 THEN 1 ELSE 0 END), 0) as FGM3,
             COALESCE(SUM(CASE WHEN s.stat_type = 'FT' THEN 1 ELSE 0 END), 0) as FTA,
             COALESCE(SUM(CASE WHEN s.stat_type = 'FT' AND s.is_made = 1 THEN 1 ELSE 0 END), 0) as FTM,
             COALESCE(SUM(CASE WHEN s.stat_type = 'REB' THEN 1 ELSE 0 END), 0) as REB,
             COALESCE(SUM(CASE WHEN s.stat_type = 'AST' THEN 1 ELSE 0 END), 0) as AST,
             COALESCE(SUM(CASE WHEN s.stat_type = 'STL' THEN 1 ELSE 0 END), 0) as STL,
             COALESCE(SUM(CASE WHEN s.stat_type = 'TO' THEN 1 ELSE 0 END), 0) as TOV,
             COALESCE(SUM(CASE WHEN s.stat_type = 'BLK' THEN 1 ELSE 0 END), 0) as BLK,
             COALESCE(SUM(CASE WHEN s.stat_type = 'PF' THEN 1 ELSE 0 END), 0) as FOUL
      FROM stats s
      JOIN players p ON s.player_id = p.id
      JOIN games g ON s.game_id = g.id
      LEFT JOIN rosters r ON r.player_id = p.id AND r.season_id = g.season_id
      WHERE s.game_id = ?
      GROUP BY p.id, r.jersey_number, p.court_name, p.last_name, p.first_name
      ORDER BY PTS DESC
    ''', [gameId]);
  }
"""

content = content.replace("  Future<List<Map<String, dynamic>>> getOpponentTeams() async {", new_method + "\n  Future<List<Map<String, dynamic>>> getOpponentTeams() async {")

with open('lib/database/database_helper.dart', 'w') as f:
    f.write(content)

