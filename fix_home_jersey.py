import re

with open('lib/screens/home_screen.dart', 'r') as f:
    content = f.read()

# Locate the left DataTable
old_left_table = """                              // 左側の固定カラム (選手名)
                              DataTable(
                                headingRowColor: WidgetStateProperty.all(Colors.grey.shade100),
                                dataRowMinHeight: 64,
                                dataRowMaxHeight: 64,
                                headingRowHeight: 48,
                                columnSpacing: 16,
                                horizontalMargin: 16,
                                border: TableBorder(
                                  right: BorderSide(color: Colors.grey.shade300),
                                  horizontalInside: BorderSide(color: Colors.grey.shade300),
                                ),
                                columns: [
                                  DataColumn(label: _buildCellContent('選手', isHeader: true)),
                                ],
                                rows: _playerStats.map((stat) {
                                  final name = stat['court_name']?.isNotEmpty == true 
                                      ? stat['court_name'] 
                                      : '${stat['last_name'] ?? ''} ${stat['first_name'] ?? ''}';
                                  return DataRow(
                                    cells: [
                                      DataCell(_buildCellContent(name, isHeader: true)),
                                    ]
                                  );
                                }).toList(),
                              ),"""

new_left_table = """                              // 左側の固定カラム (背番号 + 選手名)
                              DataTable(
                                headingRowColor: WidgetStateProperty.all(Colors.grey.shade100),
                                dataRowMinHeight: 64,
                                dataRowMaxHeight: 64,
                                headingRowHeight: 48,
                                columnSpacing: 16,
                                horizontalMargin: 16,
                                border: TableBorder(
                                  right: BorderSide(color: Colors.grey.shade300),
                                  horizontalInside: BorderSide(color: Colors.grey.shade300),
                                ),
                                columns: [
                                  DataColumn(label: _buildCellContent('No.', isHeader: true)),
                                  DataColumn(label: _buildCellContent('選手', isHeader: true)),
                                ],
                                rows: _playerStats.map((stat) {
                                  final name = stat['court_name']?.isNotEmpty == true 
                                      ? stat['court_name'] 
                                      : '${stat['last_name'] ?? ''} ${stat['first_name'] ?? ''}';
                                  final number = stat['jersey_number']?.toString() ?? '-';
                                  return DataRow(
                                    cells: [
                                      DataCell(_buildCellContent(number)),
                                      DataCell(_buildCellContent(name, isHeader: true)),
                                    ]
                                  );
                                }).toList(),
                              ),"""

content = content.replace(old_left_table, new_left_table)

with open('lib/screens/home_screen.dart', 'w') as f:
    f.write(content)
