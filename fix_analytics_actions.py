import re

with open('lib/screens/game_analytics_screen.dart', 'r') as f:
    content = f.read()

if "import '../utils/stat_actions.dart';" not in content:
    content = content.replace("import '../database/database_helper.dart';", "import '../database/database_helper.dart';\nimport '../utils/stat_actions.dart';")

# Fix _buildPlayLogsTab
old_logs_logic = """            String label = action;
            Color iconColor = Colors.grey;
            IconData icon = Icons.sports_basketball;

            if (action == '2P' || action == '3P' || action == 'FT') {
              label = "$action ${isMade ? '成功' : '失敗'}";
              iconColor = isMade ? Colors.deepOrange : Colors.grey;
            } else if (action == 'REB') {
              label = "リバウンド"; iconColor = Colors.blue; icon = Icons.back_hand;
            } else if (action == 'AST') {
              label = "アシスト"; iconColor = Colors.green; icon = Icons.handshake;
            } else if (action == 'STL') {
              label = "スティール"; iconColor = Colors.amber; icon = Icons.security;
            } else if (action == 'TO') {
              label = "ターンオーバー"; iconColor = Colors.red; icon = Icons.warning;
            } else if (action == 'PF') {
              label = "ファウル"; iconColor = Colors.purple; icon = Icons.sports;
            } else if (action == 'SUB') {
              label = "交代でIN"; iconColor = Colors.blueGrey; icon = Icons.change_circle;
            }"""

new_logs_logic = """            String label = StatActions.getLabel(action as String);
            Color iconColor = Colors.grey;
            IconData icon = Icons.sports_basketball;

            if (action == '2P' || action == '3P' || action == 'FT') {
              label = "$label ${isMade ? '成功' : '失敗'}";
              iconColor = isMade ? Colors.deepOrange : Colors.grey;
            } else if (action == 'REB') {
              iconColor = Colors.blue; icon = Icons.back_hand;
            } else if (action == 'AST') {
              iconColor = Colors.green; icon = Icons.handshake;
            } else if (action == 'STL') {
              iconColor = Colors.amber; icon = Icons.security;
            } else if (action == 'TO') {
              iconColor = Colors.red; icon = Icons.warning;
            } else if (action == 'PF') {
              iconColor = Colors.purple; icon = Icons.sports;
            } else if (action == 'SUB') {
              label = "交代でIN"; iconColor = Colors.blueGrey; icon = Icons.change_circle;
            }"""

content = content.replace(old_logs_logic, new_logs_logic)

# Fix dropdown in _EditStatDialog
old_dropdown = """            DropdownButton<String>(
              isExpanded: true,
              value: _action,
              items: _actions.map((a) => DropdownMenuItem(value: a, child: Text(a))).toList(),
              onChanged: (val) {"""
new_dropdown = """            DropdownButton<String>(
              isExpanded: true,
              value: _action,
              items: _actions.map((a) => DropdownMenuItem(value: a, child: Text(StatActions.getLabel(a)))).toList(),
              onChanged: (val) {"""

content = content.replace(old_dropdown, new_dropdown)

with open('lib/screens/game_analytics_screen.dart', 'w') as f:
    f.write(content)
