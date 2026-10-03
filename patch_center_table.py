import re

with open('lib/screens/analytics_screen.dart', 'r') as f:
    content = f.read()

# 1. Update left table (選手)
left_col_old = """                        columns: const [
                          DataColumn(label: Text("選手", style: TextStyle(fontWeight: FontWeight.bold))),
                        ],"""
left_col_new = """                        columns: const [
                          DataColumn(label: Expanded(child: Text("選手", textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold)))),
                        ],"""
content = content.replace(left_col_old, left_col_new)

left_cell_old = """                            cells: [
                              DataCell(Text(p['name'] as String, style: const TextStyle(fontWeight: FontWeight.bold))),
                            ],"""
left_cell_new = """                            cells: [
                              DataCell(Center(child: Text(p['name'] as String, textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.bold)))),
                            ],"""
content = content.replace(left_cell_old, left_cell_new)


# 2. Update right table columns
right_col_old = """                          columns: const [
                            DataColumn(label: Text("得点", style: TextStyle(fontWeight: FontWeight.bold)), numeric: true),
                            DataColumn(label: Text("2P", style: TextStyle(fontWeight: FontWeight.bold)), numeric: true),
                            DataColumn(label: Text("3P", style: TextStyle(fontWeight: FontWeight.bold)), numeric: true),
                            DataColumn(label: Text("フリースロー", style: TextStyle(fontWeight: FontWeight.bold)), numeric: true),
                            DataColumn(label: Text("リバウンド", style: TextStyle(fontWeight: FontWeight.bold)), numeric: true),
                            DataColumn(label: Text("アシスト", style: TextStyle(fontWeight: FontWeight.bold)), numeric: true),
                            DataColumn(label: Text("スティール", style: TextStyle(fontWeight: FontWeight.bold)), numeric: true),
                            DataColumn(label: Text("ターンオーバー", style: TextStyle(fontWeight: FontWeight.bold)), numeric: true),
                          ],"""
right_col_new = """                          columns: const [
                            DataColumn(label: Expanded(child: Text("得点", textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold)))),
                            DataColumn(label: Expanded(child: Text("2P", textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold)))),
                            DataColumn(label: Expanded(child: Text("3P", textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold)))),
                            DataColumn(label: Expanded(child: Text("フリースロー", textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold)))),
                            DataColumn(label: Expanded(child: Text("リバウンド", textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold)))),
                            DataColumn(label: Expanded(child: Text("アシスト", textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold)))),
                            DataColumn(label: Expanded(child: Text("スティール", textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold)))),
                            DataColumn(label: Expanded(child: Text("ターンオーバー", textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold)))),
                          ],"""
content = content.replace(right_col_old, right_col_new)

# 3. Update right table cells
right_cell_old = """                            return DataRow(
                              cells: [
                                DataCell(Text("${p['PTS']}")),
                                DataCell(Text("$pct2%\\n($pm2/$pa2)", textAlign: TextAlign.right)),
                                DataCell(Text("$pct3%\\n($pm3/$pa3)", textAlign: TextAlign.right)),
                                DataCell(Text("$pctFt%\\n($ftm/$fta)", textAlign: TextAlign.right)),
                                DataCell(Text("${p['REB']}")),
                                DataCell(Text("${p['AST']}")),
                                DataCell(Text("${p['STL']}")),
                                DataCell(Text("${p['TO']}")),
                              ],
                            );"""
right_cell_new = """                            return DataRow(
                              cells: [
                                DataCell(Center(child: Text("${p['PTS']}", textAlign: TextAlign.center))),
                                DataCell(Center(child: Text("$pct2%\\n($pm2/$pa2)", textAlign: TextAlign.center))),
                                DataCell(Center(child: Text("$pct3%\\n($pm3/$pa3)", textAlign: TextAlign.center))),
                                DataCell(Center(child: Text("$pctFt%\\n($ftm/$fta)", textAlign: TextAlign.center))),
                                DataCell(Center(child: Text("${p['REB']}", textAlign: TextAlign.center))),
                                DataCell(Center(child: Text("${p['AST']}", textAlign: TextAlign.center))),
                                DataCell(Center(child: Text("${p['STL']}", textAlign: TextAlign.center))),
                                DataCell(Center(child: Text("${p['TO']}", textAlign: TextAlign.center))),
                              ],
                            );"""
content = content.replace(right_cell_old, right_cell_new)

with open('lib/screens/analytics_screen.dart', 'w') as f:
    f.write(content)

