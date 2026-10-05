import re

with open('lib/screens/game_analytics_screen.dart', 'r') as f:
    content = f.read()

# Replace the keys in _aggregatedPlayerStats
old_agg_init = """      if (!agg.containsKey(pid)) {
        String jNum = '-';
        try {
          final rosterEntry = _roster.firstWhere((r) => r['player_id'].toString() == pid);
          jNum = rosterEntry['jersey_number']?.toString() ?? '-';
        } catch (_) {}
        agg[pid] = {'name': name, 'jersey_number': jNum, 'PTS': 0, 'REB': 0, 'AST': 0, 'STL': 0, 'TO': 0, 'PF': 0, 'FGM': 0, 'FGA': 0, '2PM': 0, '2PA': 0, '3PM': 0, '3PA': 0, 'FTM': 0, 'FTA': 0};
      }"""

new_agg_init = """      if (!agg.containsKey(pid)) {
        String jNum = '-';
        try {
          final rosterEntry = _roster.firstWhere((r) => r['player_id'].toString() == pid);
          jNum = rosterEntry['jersey_number']?.toString() ?? '-';
        } catch (_) {}
        agg[pid] = {'name': name, 'jersey_number': jNum, 'PTS': 0, 'REB': 0, 'AST': 0, 'STL': 0, 'TOV': 0, 'FOUL': 0, 'FGM2': 0, 'FGA2': 0, 'FGM3': 0, 'FGA3': 0, 'FTM': 0, 'FTA': 0};
      }"""
content = content.replace(old_agg_init, new_agg_init)

content = content.replace("agg[pid]!['2PA'] =", "agg[pid]!['FGA2'] =")
content = content.replace("agg[pid]!['2PM'] =", "agg[pid]!['FGM2'] =")
content = content.replace("agg[pid]!['2PA'] as int", "agg[pid]!['FGA2'] as int")
content = content.replace("agg[pid]!['2PM'] as int", "agg[pid]!['FGM2'] as int")

content = content.replace("agg[pid]!['3PA'] =", "agg[pid]!['FGA3'] =")
content = content.replace("agg[pid]!['3PM'] =", "agg[pid]!['FGM3'] =")
content = content.replace("agg[pid]!['3PA'] as int", "agg[pid]!['FGA3'] as int")
content = content.replace("agg[pid]!['3PM'] as int", "agg[pid]!['FGM3'] as int")

content = content.replace("agg[pid]!['TO'] =", "agg[pid]!['TOV'] =")
content = content.replace("agg[pid]!['TO'] as int", "agg[pid]!['TOV'] as int")

content = content.replace("agg[pid]!['PF'] =", "agg[pid]!['FOUL'] =")
content = content.replace("agg[pid]!['PF'] as int", "agg[pid]!['FOUL'] as int")

with open('lib/screens/game_analytics_screen.dart', 'w') as f:
    f.write(content)

