import re

with open('lib/screens/analytics_screen.dart', 'r') as f:
    content = f.read()

logs_old = """            String label = action;
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
              label = "ターンオーバー"; iconColor = Colors.redAccent; icon = Icons.error_outline;
            } else if (action == 'PF') {
              label = "ファール"; iconColor = Colors.orange; icon = Icons.warning_amber_rounded;
            }"""

logs_new = """            String label = StatActions.getLabel(action as String);
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
              iconColor = Colors.redAccent; icon = Icons.error_outline;
            } else if (action == 'PF') {
              iconColor = Colors.orange; icon = Icons.warning_amber_rounded;
            }"""

content = content.replace(logs_old, logs_new)

with open('lib/screens/analytics_screen.dart', 'w') as f:
    f.write(content)
