import re

with open('lib/screens/analytics_screen.dart', 'r') as f:
    content = f.read()

# 1. Update _aggregatedPlayerStats initialization
agg_init_old = "'FGA': 0, '3PM': 0, '3PA': 0};"
agg_init_new = "'FGA': 0, '2PM': 0, '2PA': 0, '3PM': 0, '3PA': 0, 'FTM': 0, 'FTA': 0};"
content = content.replace(agg_init_old, agg_init_new)

# 2. Update _aggregatedPlayerStats logic
logic_old = """      if (type == '2P' || type == '3P' || type == 'FG') {
        agg[pid]!['FGA'] = (agg[pid]!['FGA'] as int) + 1;
        if (isMade) {
          agg[pid]!['FGM'] = (agg[pid]!['FGM'] as int) + 1;
          agg[pid]!['PTS'] = (agg[pid]!['PTS'] as int) + (type == '3P' ? 3 : 2);
        }
        if (type == '3P') {
           agg[pid]!['3PA'] = (agg[pid]!['3PA'] as int) + 1;
           if (isMade) agg[pid]!['3PM'] = (agg[pid]!['3PM'] as int) + 1;
        }
      } else if (type == 'FT') {
        if (isMade) agg[pid]!['PTS'] = (agg[pid]!['PTS'] as int) + 1;
      }"""
logic_new = """      if (type == '2P' || type == '3P' || type == 'FG') {
        agg[pid]!['FGA'] = (agg[pid]!['FGA'] as int) + 1;
        if (isMade) {
          agg[pid]!['FGM'] = (agg[pid]!['FGM'] as int) + 1;
          agg[pid]!['PTS'] = (agg[pid]!['PTS'] as int) + (type == '3P' ? 3 : 2);
        }
        if (type == '2P' || type == 'FG') {
           agg[pid]!['2PA'] = (agg[pid]!['2PA'] as int) + 1;
           if (isMade) agg[pid]!['2PM'] = (agg[pid]!['2PM'] as int) + 1;
        }
        if (type == '3P') {
           agg[pid]!['3PA'] = (agg[pid]!['3PA'] as int) + 1;
           if (isMade) agg[pid]!['3PM'] = (agg[pid]!['3PM'] as int) + 1;
        }
      } else if (type == 'FT') {
        agg[pid]!['FTA'] = (agg[pid]!['FTA'] as int) + 1;
        if (isMade) {
          agg[pid]!['FTM'] = (agg[pid]!['FTM'] as int) + 1;
          agg[pid]!['PTS'] = (agg[pid]!['PTS'] as int) + 1;
        }
      }"""
content = content.replace(logic_old, logic_new)

# 3. Update DataTable columns
cols_old = """                      DataColumn(label: Text("TO", style: TextStyle(fontWeight: FontWeight.bold)), numeric: true),
                      DataColumn(label: Text("FG%", style: TextStyle(fontWeight: FontWeight.bold)), numeric: true),
                    ],"""
cols_new = """                      DataColumn(label: Text("TO", style: TextStyle(fontWeight: FontWeight.bold)), numeric: true),
                      DataColumn(label: Text("2P%", style: TextStyle(fontWeight: FontWeight.bold)), numeric: true),
                      DataColumn(label: Text("3P%", style: TextStyle(fontWeight: FontWeight.bold)), numeric: true),
                      DataColumn(label: Text("FT%", style: TextStyle(fontWeight: FontWeight.bold)), numeric: true),
                    ],"""
content = content.replace(cols_old, cols_new)

# 4. Update DataTable rows mapping
rows_old = """                    rows: _aggregatedPlayerStats.map((p) {
                      final fga = p['FGA'] as int;
                      final fgm = p['FGM'] as int;
                      final fgPct = fga > 0 ? ((fgm / fga) * 100).toStringAsFixed(1) : "0.0";
                      
                      return DataRow(
                        cells: [
                          DataCell(Text(p['name'])),
                          DataCell(Text("${p['PTS']}", style: const TextStyle(fontWeight: FontWeight.bold))),
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
                          DataCell(Text(p['name'])),
                          DataCell(Text("${p['PTS']}", style: const TextStyle(fontWeight: FontWeight.bold))),
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
