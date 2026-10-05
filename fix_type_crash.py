import re

with open('lib/widgets/player_stats_table.dart', 'r') as f:
    content = f.read()

# Replace the formatting logic in PlayerStatsTable to safely parse integers
old_rows_mapping = """                    cells: [
                      DataCell(_buildCellContent('${p['PTS'] ?? 0}')),
                      DataCell(_buildCellContent(_formatPercentage((p['FGM2'] ?? 0) as int, (p['FGA2'] ?? 0) as int))),
                      DataCell(_buildCellContent(_formatPercentage((p['FGM3'] ?? 0) as int, (p['FGA3'] ?? 0) as int))),
                      DataCell(_buildCellContent(_formatPercentage((p['FTM'] ?? 0) as int, (p['FTA'] ?? 0) as int))),
                      DataCell(_buildCellContent('${p['REB'] ?? 0}')),
                      DataCell(_buildCellContent('${p['AST'] ?? 0}')),
                      DataCell(_buildCellContent('${p['STL'] ?? 0}')),
                      DataCell(_buildCellContent('${p['TOV'] ?? 0}')),
                      DataCell(_buildCellContent('${p['FOUL'] ?? 0}')),
                    ]"""

new_rows_mapping = """                    cells: [
                      DataCell(_buildCellContent('${p['PTS'] ?? 0}')),
                      DataCell(_buildCellContent(_formatPercentage(num.tryParse(p['FGM2']?.toString() ?? '0')?.toInt() ?? 0, num.tryParse(p['FGA2']?.toString() ?? '0')?.toInt() ?? 0))),
                      DataCell(_buildCellContent(_formatPercentage(num.tryParse(p['FGM3']?.toString() ?? '0')?.toInt() ?? 0, num.tryParse(p['FGA3']?.toString() ?? '0')?.toInt() ?? 0))),
                      DataCell(_buildCellContent(_formatPercentage(num.tryParse(p['FTM']?.toString() ?? '0')?.toInt() ?? 0, num.tryParse(p['FTA']?.toString() ?? '0')?.toInt() ?? 0))),
                      DataCell(_buildCellContent('${p['REB'] ?? 0}')),
                      DataCell(_buildCellContent('${p['AST'] ?? 0}')),
                      DataCell(_buildCellContent('${p['STL'] ?? 0}')),
                      DataCell(_buildCellContent('${p['TOV'] ?? 0}')),
                      DataCell(_buildCellContent('${p['FOUL'] ?? 0}')),
                    ]"""

content = content.replace(old_rows_mapping, new_rows_mapping)

with open('lib/widgets/player_stats_table.dart', 'w') as f:
    f.write(content)

