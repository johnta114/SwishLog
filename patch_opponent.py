import re

with open('lib/screens/opponent_teams_screen.dart', 'r') as f:
    content = f.read()

# Add slidable import if not there
if "package:flutter_slidable/flutter_slidable.dart" not in content:
    content = content.replace("import '../database/database_helper.dart';", "import '../database/database_helper.dart';\nimport 'package:flutter_slidable/flutter_slidable.dart';")

# Replace _showAddOpponentModal with _showOpponentModal
modal_old = """  void _showAddOpponentModal() {
    final nameCtrl = TextEditingController();
    final prefCtrl = TextEditingController();
    final contactCtrl = TextEditingController();
    final notesCtrl = TextEditingController();"""

modal_new = """  void _showOpponentModal([Map<String, dynamic>? opponent]) {
    final isEdit = opponent != null;
    final nameCtrl = TextEditingController(text: isEdit ? opponent['name'] : '');
    final prefCtrl = TextEditingController(text: isEdit ? opponent['prefecture'] : '');
    final contactCtrl = TextEditingController(text: isEdit ? opponent['coach_contact'] : '');
    final notesCtrl = TextEditingController(text: isEdit ? opponent['notes'] : '');"""

content = content.replace(modal_old, modal_new)

# Replace '対戦相手の新規登録' with dynamic text
content = content.replace(
    "const Text('対戦相手の新規登録', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),",
    "Text(isEdit ? '対戦相手の編集' : '対戦相手の新規登録', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),"
)

# Replace save logic
save_old = """                  // ★ モックデータではなく、SQLiteデータベースに保存する
                  await DatabaseHelper.instance.insertOpponentTeam({
                    'name': nameCtrl.text,
                    'prefecture': prefCtrl.text,
                    'coach_contact': contactCtrl.text,
                    'notes': notesCtrl.text,
                  });"""

save_new = """                  final data = {
                    'name': nameCtrl.text,
                    'prefecture': prefCtrl.text,
                    'coach_contact': contactCtrl.text,
                    'notes': notesCtrl.text,
                  };
                  if (isEdit) {
                    await DatabaseHelper.instance.updateOpponentTeam(opponent['id'].toString(), data);
                  } else {
                    await DatabaseHelper.instance.insertOpponentTeam(data);
                  }"""

content = content.replace(save_old, save_new)

# Add Slidable to Card and remove TextButtons inside ExpansionTile
# First, remove the Row with TextButtons
buttons_pattern = r"Row\(\s*mainAxisAlignment:\s*MainAxisAlignment\.end,\s*children:\s*\[\s*TextButton\.icon\(\s*onPressed:\s*\(\)\s*=>\s*_confirmDelete[^\)]+\),\s*icon:\s*const\s*Icon\(Icons\.delete[^\]]+\]\s*\)"
content = re.sub(buttons_pattern, "const SizedBox()", content, flags=re.DOTALL)

# Now wrap Card with Slidable
card_start = r"                      return Card\("
card_repl = r"""                      return Slidable(
                        key: ValueKey(opp['id'].toString()),
                        endActionPane: ActionPane(
                          motion: const DrawerMotion(),
                          extentRatio: 0.5,
                          children: [
                            CustomSlidableAction(
                              onPressed: (context) => _showOpponentModal(opp),
                              backgroundColor: Colors.transparent,
                              foregroundColor: Colors.blue,
                              padding: const EdgeInsets.only(left: 8),
                              child: Container(
                                decoration: BoxDecoration(color: Colors.blue.shade50, borderRadius: BorderRadius.circular(12)),
                                child: const Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.edit), SizedBox(height: 4), Text('編集', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold))])),
                              ),
                            ),
                            CustomSlidableAction(
                              onPressed: (context) => _confirmDelete(opp['id'].toString(), name),
                              backgroundColor: Colors.transparent,
                              foregroundColor: Colors.red,
                              padding: const EdgeInsets.only(left: 8, right: 8),
                              child: Container(
                                decoration: BoxDecoration(color: Colors.red.shade50, borderRadius: BorderRadius.circular(12)),
                                child: const Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.delete), SizedBox(height: 4), Text('削除', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold))])),
                              ),
                            ),
                          ],
                        ),
                        child: Card("""

content = re.sub(card_start, card_repl, content)

# Change floating action button from _showAddOpponentModal to () => _showOpponentModal()
content = content.replace("onPressed: _showAddOpponentModal,", "onPressed: () => _showOpponentModal(),")

with open('lib/screens/opponent_teams_screen.dart', 'w') as f:
    f.write(content)

print("opponent_teams_screen updated")
