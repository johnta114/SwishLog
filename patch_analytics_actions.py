import re

with open('lib/screens/analytics_screen.dart', 'r') as f:
    content = f.read()

# Add import
import_stmt = "import '../utils/stat_actions.dart';\\n"
if "stat_actions.dart" not in content:
    content = content.replace("import '../database/database_helper.dart';", f"import '../database/database_helper.dart';\\n{import_stmt}")

# Remove local _actions list
old_actions = "  final List<String> _actions = ['2P', '3P', 'FT', 'REB', 'AST', 'STL', 'BLK', 'TO', 'PF', 'SUB'];\\n"
content = content.replace(old_actions, "")

# Update Dropdown items
old_dropdown = "items: _actions.map((a) => DropdownMenuItem(value: a, child: Text(a))).toList(),"
new_dropdown = "items: StatActions.labels.keys.map((a) => DropdownMenuItem(value: a, child: Text(StatActions.getLabel(a)))).toList(),"
content = content.replace(old_dropdown, new_dropdown)

# Also update the Play Log tab which might display the raw actionId
# Let's check how play log is displayed in analytics_screen.dart
with open('lib/screens/analytics_screen.dart', 'w') as f:
    f.write(content)
