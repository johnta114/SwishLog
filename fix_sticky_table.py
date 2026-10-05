import re

with open('lib/screens/home_screen.dart', 'r') as f:
    content = f.read()

# Locate the container containing the table
old_table_pattern = r"""                        Container\(\s*decoration: BoxDecoration\(\s*border: Border\.all\(color: Colors\.grey\.shade300\),\s*color: Colors\.white,\s*\),\s*child: SingleChildScrollView\([\s\S]*?\}\)\.toList\(\),\s*\),\s*\),\s*\),"""

new_table = """                        Container(
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey.shade300),
                            color: Colors.white,
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // 左側の固定カラム (選手名)
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
                              ),
                              // 右側のスクロール可能なカラム (スタッツ)
                              Expanded(
                                child: SingleChildScrollView(
                                  scrollDirection: Axis.horizontal,
                                  child: DataTable(
                                    headingRowColor: WidgetStateProperty.all(Colors.grey.shade100),
                                    dataRowMinHeight: 64,
                                    dataRowMaxHeight: 64,
                                    headingRowHeight: 48,
                                    columnSpacing: 24,
                                    horizontalMargin: 16,
                                    border: TableBorder(
                                      horizontalInside: BorderSide(color: Colors.grey.shade300),
                                      verticalInside: BorderSide(color: Colors.grey.shade300),
                                    ),
                                    columns: [
                                      DataColumn(label: _buildCellContent('得点', isHeader: true)),
                                      DataColumn(label: _buildCellContent('2P', isHeader: true)),
                                      DataColumn(label: _buildCellContent('3P', isHeader: true)),
                                      DataColumn(label: _buildCellContent('フリースロー', isHeader: true)),
                                      DataColumn(label: _buildCellContent('リバウンド', isHeader: true)),
                                      DataColumn(label: _buildCellContent('アシスト', isHeader: true)),
                                      DataColumn(label: _buildCellContent('スティール', isHeader: true)),
                                      DataColumn(label: _buildCellContent('ターンオーバー', isHeader: true)),
                                      DataColumn(label: _buildCellContent('ファール', isHeader: true)),
                                    ],
                                    rows: _playerStats.map((stat) {
                                      return DataRow(
                                        cells: [
                                          DataCell(_buildCellContent('${stat['PTS'] ?? 0}')),
                                          DataCell(_buildCellContent(_formatPercentage(stat['FGM2'] ?? 0, stat['FGA2'] ?? 0))),
                                          DataCell(_buildCellContent(_formatPercentage(stat['FGM3'] ?? 0, stat['FGA3'] ?? 0))),
                                          DataCell(_buildCellContent(_formatPercentage(stat['FTM'] ?? 0, stat['FTA'] ?? 0))),
                                          DataCell(_buildCellContent('${stat['REB'] ?? 0}')),
                                          DataCell(_buildCellContent('${stat['AST'] ?? 0}')),
                                          DataCell(_buildCellContent('${stat['STL'] ?? 0}')),
                                          DataCell(_buildCellContent('${stat['TOV'] ?? 0}')),
                                          DataCell(_buildCellContent('${stat['FOUL'] ?? 0}')),
                                        ]
                                      );
                                    }).toList(),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),"""

content = re.sub(old_table_pattern, new_table, content)

with open('lib/screens/home_screen.dart', 'w') as f:
    f.write(content)

