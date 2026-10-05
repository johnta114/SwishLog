import re

with open('lib/screens/game_analytics_screen.dart', 'r') as f:
    content = f.read()

# Find the start of _buildPlayerStatsTab
start_idx = content.find("  Widget _buildPlayerStatsTab() {")
# Find the start of the next method _confirmDeleteStat
end_idx = content.find("  void _confirmDeleteStat(Map<String, dynamic> stat) {")

if start_idx != -1 and end_idx != -1:
    new_method = """  Widget _buildPlayerStatsTab() {
    return _aggregatedPlayerStats.isEmpty 
      ? const Center(child: Text("この試合・クォーターの記録はありません"))
      : SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('個人スタッツ一覧', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade300),
                    color: Colors.white,
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 左側の固定カラム
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
                        rows: _aggregatedPlayerStats.map((p) {
                          return DataRow(
                            cells: [
                              DataCell(_buildCellContent(p['jersey_number'] as String)),
                              DataCell(_buildCellContent(p['name'] as String, isHeader: true)),
                            ]
                          );
                        }).toList(),
                      ),
                      // 右側のスクロール可能なカラム
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
                            rows: _aggregatedPlayerStats.map((p) {
                              return DataRow(
                                cells: [
                                  DataCell(_buildCellContent('${p['PTS']}')),
                                  DataCell(_buildCellContent(_formatPercentage(p['2PM'] as int, p['2PA'] as int))),
                                  DataCell(_buildCellContent(_formatPercentage(p['3PM'] as int, p['3PA'] as int))),
                                  DataCell(_buildCellContent(_formatPercentage(p['FTM'] as int, p['FTA'] as int))),
                                  DataCell(_buildCellContent('${p['REB']}')),
                                  DataCell(_buildCellContent('${p['AST']}')),
                                  DataCell(_buildCellContent('${p['STL']}')),
                                  DataCell(_buildCellContent('${p['TO']}')),
                                  DataCell(_buildCellContent('${p['PF']}')),
                                ]
                              );
                            }).toList(),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 80),
              ],
            ),
          )
        );
  }

"""
    content = content[:start_idx] + new_method + content[end_idx:]
    with open('lib/screens/game_analytics_screen.dart', 'w') as f:
        f.write(content)
else:
    print("Could not find start or end index!")
    print(f"start_idx: {start_idx}, end_idx: {end_idx}")

