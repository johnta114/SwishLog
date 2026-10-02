import re

with open('lib/screens/analytics_screen.dart', 'r') as f:
    content = f.read()

missing_methods = """
  void _confirmDeleteStat(Map<String, dynamic> stat) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        title: const Text('削除の確認'),
        content: const Text('このアクションを削除しますか？\\n（得点の場合は総得点にも反映されます）'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('キャンセル', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
            onPressed: () async {
              await DatabaseHelper.instance.deleteStat(stat['id'].toString());
              if (widget.gameId != null) {
                await DatabaseHelper.instance.updateGameScoreTotals(widget.gameId!);
              }
              Navigator.pop(context);
              _loadData(showLoading: false);
            },
            child: const Text('削除する', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      )
    );
  }

  void _showEditStatDialog(Map<String, dynamic> stat) {
    if (_roster.isEmpty) return; // ロスターがない場合は編集不可とする
    
    showDialog(
      context: context,
      builder: (context) => _EditStatDialog(
        stat: stat,
        roster: _roster,
        onSave: (String statId, Map<String, dynamic> updatedData) async {
          await DatabaseHelper.instance.updateStat(statId, updatedData);
          if (widget.gameId != null) {
            await DatabaseHelper.instance.updateGameScoreTotals(widget.gameId!);
          }
          _loadData(showLoading: false);
        },
      ),
    );
  }

  Widget _buildPlayLogsTab() {"""

content = content.replace("  Widget _buildPlayLogsTab() {", missing_methods)

with open('lib/screens/analytics_screen.dart', 'w') as f:
    f.write(content)
