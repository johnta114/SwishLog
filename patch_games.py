with open('lib/screens/games_screen.dart', 'r') as f:
    content = f.read()

# Add slidable import
if "package:flutter_slidable/flutter_slidable.dart" not in content:
    content = content.replace("import '../database/database_helper.dart';", "import '../database/database_helper.dart';\nimport 'package:flutter_slidable/flutter_slidable.dart';")

# Replace _showAddGameModal to handle Edit
modal_old = """  void _showAddGameModal() {"""
modal_new = """  void _showGameModal([Map<String, dynamic>? game]) {
    final isEdit = game != null;"""

content = content.replace(modal_old, modal_new)

# Add _confirmDeleteGame
delete_method = """  void _confirmDeleteGame(String id, String opponentName) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('削除の確認'),
        content: Text('vs $opponentName の試合を削除しますか？\\n関連するすべてのスタッツとアクションログも削除されます。'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('キャンセル', style: TextStyle(color: Colors.grey))),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
            onPressed: () async {
              await DatabaseHelper.instance.deleteGame(id);
              Navigator.pop(context);
              _loadData();
            },
            child: const Text('削除する', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      )
    );
  }

"""
if "_confirmDeleteGame" not in content:
    content = content.replace("  void _showGameModal", delete_method + "  void _showGameModal")

# Now handle the form variables in _showGameModal
content = content.replace("    bool isU12 = false;\n    String? selectedOpponentId;", "    bool isU12 = isEdit ? (game['is_u12'] == 1) : false;\n    String? selectedOpponentId = isEdit ? game['opponent_id']?.toString() : null;")
content = content.replace("    final dateCtrl = TextEditingController();", "    final dateCtrl = TextEditingController(text: isEdit ? game['date'] : '');")
content = content.replace("    bool isNewOpponent = false;\n    final oppCtrl = TextEditingController();", "    bool isNewOpponent = false;\n    final oppCtrl = TextEditingController();")

# Change save logic
save_old = """                          await DatabaseHelper.instance.insertGame({
                            'opponent_id': oppId,
                            'date': dateCtrl.text,
                            'status': 'scheduled',
                            'my_score': 0,
                            'opp_score': 0,
                            'is_u12': isU12 ? 1 : 0,
                          });"""
save_new = """                          final data = {
                            'opponent_id': oppId,
                            'date': dateCtrl.text,
                            'is_u12': isU12 ? 1 : 0,
                          };
                          if (isEdit) {
                            await DatabaseHelper.instance.updateGame(game['id'].toString(), data);
                          } else {
                            data['status'] = 'scheduled';
                            data['my_score'] = 0;
                            data['opp_score'] = 0;
                            await DatabaseHelper.instance.insertGame(data);
                          }"""
content = content.replace(save_old, save_new)

content = content.replace("const Text('試合作成', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold))", "Text(isEdit ? '試合編集' : '試合作成', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold))")

content = content.replace("onPressed: _showAddGameModal", "onPressed: () => _showGameModal()")

with open('lib/screens/games_screen.dart', 'w') as f:
    f.write(content)
