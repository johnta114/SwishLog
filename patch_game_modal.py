with open('lib/screens/games_screen.dart', 'r') as f:
    content = f.read()

import re

# Fix initialization
init_old = """    bool isNewOpponent = false;
    String? selectedOpponentId;
    final newOpponentCtrl = TextEditingController();
    final prefCtrl = TextEditingController();
    final dateCtrl = TextEditingController(text: DateTime.now().toString().split(' ')[0]);
    bool isU12 = false;"""

init_new = """    bool isNewOpponent = false;
    String? selectedOpponentId = isEdit ? game['opponent_team_id']?.toString() : null;
    final newOpponentCtrl = TextEditingController();
    final prefCtrl = TextEditingController();
    final dateCtrl = TextEditingController(text: isEdit ? game['date'] : DateTime.now().toString().split(' ')[0]);
    bool isU12 = isEdit ? (game['is_u12'] == 1) : false;"""
content = content.replace(init_old, init_new)

# Fix Title
content = content.replace("const Text('新規試合の作成', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold))", "Text(isEdit ? '試合の編集' : '新規試合の作成', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold))")

with open('lib/screens/games_screen.dart', 'w') as f:
    f.write(content)
