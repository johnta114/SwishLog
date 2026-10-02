import re

with open('lib/screens/analytics_screen.dart', 'r') as f:
    content = f.read()

rows_old = """                    rows: _aggregatedPlayerStats.map((p) {
                      final fga = p['FGA'] as int;
                      final fgm = p['FGM'] as int;
                      final fgPct = fga > 0 ? ((fgm / fga) * 100).toStringAsFixed(1) : "0.0";
                      
                      return DataRow(
                        cells: [
                          DataCell(Text(p['name'] as String, style: const TextStyle(fontWeight: FontWeight.bold))),
                          DataCell(Text("${p['PTS']}")),
                          DataCell(Text("${p['REB']}")),
                          DataCell(Text("${p['AST']}")),
                          DataCell(Text("${p['STL']}")),
                          DataCell(Text("${p['TO']}")),
                          DataCell(Text("$fgPct%")),
                        ],
                      );
                    }).toList(),"""

rows_new = """                    rows: _aggregatedPlayerStats.map((p) {
                      final pa2 = p['2PA'] as int;
                      final pm2 = p['2PM'] as int;
                      final pct2 = pa2 > 0 ? ((pm2 / pa2) * 100).toStringAsFixed(1) : "0.0";
                      
                      final pa3 = p['3PA'] as int;
                      final pm3 = p['3PM'] as int;
                      final pct3 = pa3 > 0 ? ((pm3 / pa3) * 100).toStringAsFixed(1) : "0.0";
                      
                      final fta = p['FTA'] as int;
                      final ftm = p['FTM'] as int;
                      final pctFt = fta > 0 ? ((ftm / fta) * 100).toStringAsFixed(1) : "0.0";
                      
                      return DataRow(
                        cells: [
                          DataCell(Text(p['name'] as String, style: const TextStyle(fontWeight: FontWeight.bold))),
                          DataCell(Text("${p['PTS']}")),
                          DataCell(Text("${p['REB']}")),
                          DataCell(Text("${p['AST']}")),
                          DataCell(Text("${p['STL']}")),
                          DataCell(Text("${p['TO']}")),
                          DataCell(Text("$pct2% ($pm2/$pa2)")),
                          DataCell(Text("$pct3% ($pm3/$pa3)")),
                          DataCell(Text("$pctFt% ($ftm/$fta)")),
                        ],
                      );
                    }).toList(),"""

content = content.replace(rows_old, rows_new)

with open('lib/screens/analytics_screen.dart', 'w') as f:
    f.write(content)

