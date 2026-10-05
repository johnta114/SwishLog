import re

with open('lib/screens/game_analytics_screen.dart', 'r') as f:
    content = f.read()

# Replace _buildStatsTab
old_stats_tab = """  Widget _buildStatsTab() {
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
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 固定カラム（選手名）
                    Container(
                      decoration: BoxDecoration(
                        border: Border(right: BorderSide(color: Colors.grey.shade300, width: 2)),
                      ),
                      child: DataTable(
                        columnSpacing: 16,
                        horizontalMargin: 12,
                        headingRowColor: WidgetStateProperty.all(Colors.blueGrey.shade50),
                        columns: const [
                          DataColumn(label: Text("選手", style: TextStyle(fontWeight: FontWeight.bold))),
                        ],
                        rows: _aggregatedPlayerStats.map((p) {
                          return DataRow(
                            cells: [
                              DataCell(Text(p['name'] as String, style: const TextStyle(fontWeight: FontWeight.bold))),
                            ],
                          );
                        }).toList(),
                      ),
                    ),
                    // スクロール可能カラム（スタッツ）
                    Expanded(
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: DataTable(
                          columnSpacing: 16,
                          horizontalMargin: 12,
                          headingRowColor: WidgetStateProperty.all(Colors.blueGrey.shade50),
                          columns: const [
                            DataColumn(label: Text("PTS", style: TextStyle(fontWeight: FontWeight.bold)), numeric: true),
                            DataColumn(label: Text("REB", style: TextStyle(fontWeight: FontWeight.bold)), numeric: true),
                            DataColumn(label: Text("AST", style: TextStyle(fontWeight: FontWeight.bold)), numeric: true),
                            DataColumn(label: Text("STL", style: TextStyle(fontWeight: FontWeight.bold)), numeric: true),
                            DataColumn(label: Text("TO", style: TextStyle(fontWeight: FontWeight.bold)), numeric: true),
                            DataColumn(label: Text("2P%", style: TextStyle(fontWeight: FontWeight.bold)), numeric: true),
                            DataColumn(label: Text("3P%", style: TextStyle(fontWeight: FontWeight.bold)), numeric: true),
                            DataColumn(label: Text("FT%", style: TextStyle(fontWeight: FontWeight.bold)), numeric: true),
                          ],
                          rows: _aggregatedPlayerStats.map((p) {
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
                          }).toList(),
                        ),
                      ),
                    ),
                  ],
                )
              ],
            ),
          )
        ];""" # Need a robust regex

# Wait, simple replace might fail if there are slight differences. Let's use regex matching from _buildStatsTab to the end of the method.
