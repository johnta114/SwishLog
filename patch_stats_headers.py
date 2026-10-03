import re

with open('lib/screens/analytics_screen.dart', 'r') as f:
    content = f.read()

# Replace columns
cols_old = """                          columns: const [
                            DataColumn(label: Text("PTS", style: TextStyle(fontWeight: FontWeight.bold)), numeric: true),
                            DataColumn(label: Text("REB", style: TextStyle(fontWeight: FontWeight.bold)), numeric: true),
                            DataColumn(label: Text("AST", style: TextStyle(fontWeight: FontWeight.bold)), numeric: true),
                            DataColumn(label: Text("STL", style: TextStyle(fontWeight: FontWeight.bold)), numeric: true),
                            DataColumn(label: Text("TO", style: TextStyle(fontWeight: FontWeight.bold)), numeric: true),
                            DataColumn(label: Text("2P%", style: TextStyle(fontWeight: FontWeight.bold)), numeric: true),
                            DataColumn(label: Text("3P%", style: TextStyle(fontWeight: FontWeight.bold)), numeric: true),
                            DataColumn(label: Text("FT%", style: TextStyle(fontWeight: FontWeight.bold)), numeric: true),
                          ],"""

cols_new = """                          columns: const [
                            DataColumn(label: Text("得点", style: TextStyle(fontWeight: FontWeight.bold)), numeric: true),
                            DataColumn(label: Text("2P%", style: TextStyle(fontWeight: FontWeight.bold)), numeric: true),
                            DataColumn(label: Text("3P%", style: TextStyle(fontWeight: FontWeight.bold)), numeric: true),
                            DataColumn(label: Text("FT%", style: TextStyle(fontWeight: FontWeight.bold)), numeric: true),
                            DataColumn(label: Text("リバウンド", style: TextStyle(fontWeight: FontWeight.bold)), numeric: true),
                            DataColumn(label: Text("アシスト", style: TextStyle(fontWeight: FontWeight.bold)), numeric: true),
                            DataColumn(label: Text("スティール", style: TextStyle(fontWeight: FontWeight.bold)), numeric: true),
                            DataColumn(label: Text("ターンオーバー", style: TextStyle(fontWeight: FontWeight.bold)), numeric: true),
                          ],"""

content = content.replace(cols_old, cols_new)

# Replace cells
cells_old = """                            return DataRow(
                              cells: [
                                DataCell(Text("${p['PTS']}")),
                                DataCell(Text("${p['REB']}")),
                                DataCell(Text("${p['AST']}")),
                                DataCell(Text("${p['STL']}")),
                                DataCell(Text("${p['TO']}")),
                                DataCell(Text("$pct2% ($pm2/$pa2)")),
                                DataCell(Text("$pct3% ($pm3/$pa3)")),
                                DataCell(Text("$pctFt% ($ftm/$fta)")),
                              ],
                            );"""

cells_new = """                            return DataRow(
                              cells: [
                                DataCell(Text("${p['PTS']}")),
                                DataCell(Text("$pct2% ($pm2/$pa2)")),
                                DataCell(Text("$pct3% ($pm3/$pa3)")),
                                DataCell(Text("$pctFt% ($ftm/$fta)")),
                                DataCell(Text("${p['REB']}")),
                                DataCell(Text("${p['AST']}")),
                                DataCell(Text("${p['STL']}")),
                                DataCell(Text("${p['TO']}")),
                              ],
                            );"""

content = content.replace(cells_old, cells_new)

with open('lib/screens/analytics_screen.dart', 'w') as f:
    f.write(content)

