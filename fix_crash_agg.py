import re

with open('lib/screens/game_analytics_screen.dart', 'r') as f:
    content = f.read()

bad_init = "agg[pid] = {'name': name, 'jersey_number': jNum, 'PTS': 0, 'REB': 0, 'AST': 0, 'STL': 0, 'TOV': 0, 'FOUL': 0, 'FGM2': 0, 'FGA2': 0, 'FGM3': 0, 'FGA3': 0, 'FTM': 0, 'FTA': 0};"
good_init = "agg[pid] = {'name': name, 'jersey_number': jNum, 'PTS': 0, 'REB': 0, 'AST': 0, 'STL': 0, 'TOV': 0, 'FOUL': 0, 'FGM': 0, 'FGA': 0, 'FGM2': 0, 'FGA2': 0, 'FGM3': 0, 'FGA3': 0, 'FTM': 0, 'FTA': 0};"

content = content.replace(bad_init, good_init)

with open('lib/screens/game_analytics_screen.dart', 'w') as f:
    f.write(content)

