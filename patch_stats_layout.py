import re

with open('lib/screens/analytics_screen.dart', 'r') as f:
    content = f.read()

# 1. Update Columns
cols_old = """                            DataColumn(label: Text("2P%", style: TextStyle(fontWeight: FontWeight.bold)), numeric: true),
                            DataColumn(label: Text("3P%", style: TextStyle(fontWeight: FontWeight.bold)), numeric: true),
                            DataColumn(label: Text("FT%", style: TextStyle(fontWeight: FontWeight.bold)), numeric: true),"""

cols_new = """                            DataColumn(label: Text("2P", style: TextStyle(fontWeight: FontWeight.bold)), numeric: true),
                            DataColumn(label: Text("3P", style: TextStyle(fontWeight: FontWeight.bold)), numeric: true),
                            DataColumn(label: Text("フリースロー", style: TextStyle(fontWeight: FontWeight.bold)), numeric: true),"""

content = content.replace(cols_old, cols_new)

# 2. Update Cells with Newline and Right Align
cells_old = """                                DataCell(Text("$pct2% ($pm2/$pa2)")),
                                DataCell(Text("$pct3% ($pm3/$pa3)")),
                                DataCell(Text("$pctFt% ($ftm/$fta)")),"""

cells_new = """                                DataCell(Text("$pct2%\\n($pm2/$pa2)", textAlign: TextAlign.right)),
                                DataCell(Text("$pct3%\\n($pm3/$pa3)", textAlign: TextAlign.right)),
                                DataCell(Text("$pctFt%\\n($ftm/$fta)", textAlign: TextAlign.right)),"""

content = content.replace(cells_old, cells_new)

# 3. Add dataRowMaxHeight/MinHeight to BOTH DataTables to ensure enough height for 2 lines
left_table_old = """                      child: DataTable(
                        columnSpacing: 16,
                        horizontalMargin: 12,
                        headingRowColor: WidgetStateProperty.all(Colors.blueGrey.shade50),"""

left_table_new = """                      child: DataTable(
                        dataRowMinHeight: 56.0,
                        dataRowMaxHeight: 56.0,
                        columnSpacing: 16,
                        horizontalMargin: 12,
                        headingRowColor: WidgetStateProperty.all(Colors.blueGrey.shade50),"""

content = content.replace(left_table_old, left_table_new)

right_table_old = """                        child: DataTable(
                          columnSpacing: 16,
                          horizontalMargin: 12,
                          headingRowColor: WidgetStateProperty.all(Colors.blueGrey.shade50),"""

right_table_new = """                        child: DataTable(
                          dataRowMinHeight: 56.0,
                          dataRowMaxHeight: 56.0,
                          columnSpacing: 16,
                          horizontalMargin: 12,
                          headingRowColor: WidgetStateProperty.all(Colors.blueGrey.shade50),"""

content = content.replace(right_table_old, right_table_new)

with open('lib/screens/analytics_screen.dart', 'w') as f:
    f.write(content)
