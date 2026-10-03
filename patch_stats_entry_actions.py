import re

with open('lib/screens/stats_entry_screen.dart', 'r') as f:
    content = f.read()

# Add import
import_stmt = "import '../utils/stat_actions.dart';\\n"
if "stat_actions.dart" not in content:
    content = content.replace("import '../database/database_helper.dart';", f"import '../database/database_helper.dart';\\n{import_stmt}")

# Update actionLabel in _saveStatToDB
save_old = "actionLabel: statType == '2P' || statType == '3P' ? 'シュート' : statType,"
save_new = "actionLabel: StatActions.getLabel(statType),"
content = content.replace(save_old, save_new)

# Update _buildStatBtn signature and implementation
btn_sig_old = "  Widget _buildStatBtn(String label, String actionId, {bool isPrimary = false}) {"
btn_sig_new = "  Widget _buildStatBtn(String actionId, {bool isPrimary = false}) {"
content = content.replace(btn_sig_old, btn_sig_new)

btn_child_old = "child: Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13), maxLines: 1, overflow: TextOverflow.ellipsis),"
btn_child_new = "child: Text(StatActions.getLabel(actionId), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13), maxLines: 1, overflow: TextOverflow.ellipsis),"
content = content.replace(btn_child_old, btn_child_new)

# Update _buildStatBtn calls
calls_old = """                    _buildStatBtn('フリースロー', 'FT', isPrimary: true),
                    _buildStatBtn('リバウンド', 'REB'),
                    _buildStatBtn('アシスト', 'AST'),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    _buildStatBtn('スティール', 'STL'),
                    _buildStatBtn('ターンオーバー', 'TO'),
                    _buildStatBtn('ファウル', 'PF'),
                  ],"""

calls_new = """                    _buildStatBtn('FT', isPrimary: true),
                    _buildStatBtn('REB'),
                    _buildStatBtn('AST'),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    _buildStatBtn('STL'),
                    _buildStatBtn('TO'),
                    _buildStatBtn('PF'),
                  ],"""
content = content.replace(calls_old, calls_new)

with open('lib/screens/stats_entry_screen.dart', 'w') as f:
    f.write(content)
