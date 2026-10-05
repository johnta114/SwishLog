import 'package:flutter/material.dart';

class PlayerStatsTable extends StatelessWidget {
  final List<Map<String, dynamic>> stats;

  const PlayerStatsTable({super.key, required this.stats});

  String _formatPercentage(int made, int attempted) {
    if (attempted == 0) return '0.0%\n(0/0)';
    final percent = (made / attempted * 100).toStringAsFixed(1);
    return '$percent%\n($made/$attempted)';
  }

  Widget _buildCellContent(String text, {bool isHeader = false, double minWidth = 72.0}) {
    if (text == 'No.' || text == '-' || (text.length <= 2 && RegExp(r'^[0-9]+$').hasMatch(text))) {
      minWidth = 28.0;
    }
    if (text == '選手') minWidth = 80.0;

    return Container(
      constraints: BoxConstraints(minWidth: minWidth),
      alignment: Alignment.center,
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: TextStyle(
          fontWeight: isHeader ? FontWeight.bold : FontWeight.normal,
          fontSize: isHeader ? 13 : 14,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (stats.isEmpty) {
      return const Center(child: Text("記録はありません", style: TextStyle(color: Colors.grey)));
    }

    return Container(
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
            columnSpacing: 8,
            horizontalMargin: 8,
            border: TableBorder(
              right: BorderSide(color: Colors.grey.shade300),
              horizontalInside: BorderSide(color: Colors.grey.shade300),
            ),
            columns: [
              DataColumn(label: _buildCellContent('No.', isHeader: true)),
              DataColumn(label: _buildCellContent('選手', isHeader: true)),
            ],
            rows: stats.map((p) {
              final name = p['court_name']?.isNotEmpty == true 
                  ? p['court_name'] 
                  : (p['name'] ?? '${p['last_name'] ?? ''} ${p['first_name'] ?? ''}').toString().trim();
              final number = p['jersey_number']?.toString() ?? '-';
              
              return DataRow(
                cells: [
                  DataCell(_buildCellContent(number)),
                  DataCell(_buildCellContent(name, isHeader: true)),
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
                  DataColumn(label: _buildCellContent('得点', isHeader: true), numeric: true),
                  DataColumn(label: _buildCellContent('2P', isHeader: true), numeric: true),
                  DataColumn(label: _buildCellContent('3P', isHeader: true), numeric: true),
                  DataColumn(label: _buildCellContent('フリースロー', isHeader: true), numeric: true),
                  DataColumn(label: _buildCellContent('リバウンド', isHeader: true), numeric: true),
                  DataColumn(label: _buildCellContent('アシスト', isHeader: true), numeric: true),
                  DataColumn(label: _buildCellContent('スティール', isHeader: true), numeric: true),
                  DataColumn(label: _buildCellContent('ターンオーバー', isHeader: true), numeric: true),
                  DataColumn(label: _buildCellContent('ファール', isHeader: true), numeric: true),
                ],
                rows: stats.map((p) {
                  return DataRow(
                    cells: [
                      DataCell(_buildCellContent('${p['PTS'] ?? 0}')),
                      DataCell(_buildCellContent(_formatPercentage(num.tryParse(p['FGM2']?.toString() ?? '0')?.toInt() ?? 0, num.tryParse(p['FGA2']?.toString() ?? '0')?.toInt() ?? 0))),
                      DataCell(_buildCellContent(_formatPercentage(num.tryParse(p['FGM3']?.toString() ?? '0')?.toInt() ?? 0, num.tryParse(p['FGA3']?.toString() ?? '0')?.toInt() ?? 0))),
                      DataCell(_buildCellContent(_formatPercentage(num.tryParse(p['FTM']?.toString() ?? '0')?.toInt() ?? 0, num.tryParse(p['FTA']?.toString() ?? '0')?.toInt() ?? 0))),
                      DataCell(_buildCellContent('${p['REB'] ?? 0}')),
                      DataCell(_buildCellContent('${p['AST'] ?? 0}')),
                      DataCell(_buildCellContent('${p['STL'] ?? 0}')),
                      DataCell(_buildCellContent('${p['TOV'] ?? 0}')),
                      DataCell(_buildCellContent('${p['FOUL'] ?? 0}')),
                    ]
                  );
                }).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
