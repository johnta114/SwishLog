import re

with open('lib/screens/game_analytics_screen.dart', 'r') as f:
    content = f.read()

old_agg = """      if (!agg.containsKey(pid)) {
        agg[pid] = {'name': name, 'PTS': 0, 'REB': 0, 'AST': 0, 'STL': 0, 'TO': 0, 'PF': 0, 'FGM': 0, 'FGA': 0, '2PM': 0, '2PA': 0, '3PM': 0, '3PA': 0, 'FTM': 0, 'FTA': 0};
      }"""

new_agg = """      if (!agg.containsKey(pid)) {
        String jNum = '-';
        try {
          final rosterEntry = _roster.firstWhere((r) => r['player_id'].toString() == pid);
          jNum = rosterEntry['jersey_number']?.toString() ?? '-';
        } catch (_) {}
        agg[pid] = {'name': name, 'jersey_number': jNum, 'PTS': 0, 'REB': 0, 'AST': 0, 'STL': 0, 'TO': 0, 'PF': 0, 'FGM': 0, 'FGA': 0, '2PM': 0, '2PA': 0, '3PM': 0, '3PA': 0, 'FTM': 0, 'FTA': 0};
      }"""

content = content.replace(old_agg, new_agg)

with open('lib/screens/game_analytics_screen.dart', 'w') as f:
    f.write(content)

