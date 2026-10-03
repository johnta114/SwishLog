import re

# FIX ANALYTICS SCREEN
with open('lib/screens/analytics_screen.dart', 'r') as f:
    content = f.read()

# Make sure import is there and valid
if "import '../utils/stat_actions.dart';" not in content:
    content = content.replace("import '../database/database_helper.dart';", "import '../database/database_helper.dart';\nimport '../utils/stat_actions.dart';")

content = re.sub(r"  final List<String> _actions = \['2P', '3P', 'FT', 'REB', 'AST', 'STL', 'BLK', 'TO', 'PF', 'SUB'\];[\\n]*", "", content)

with open('lib/screens/analytics_screen.dart', 'w') as f:
    f.write(content)

# FIX STATS ENTRY SCREEN
with open('lib/screens/stats_entry_screen.dart', 'r') as f:
    content = f.read()

# Clean up broken python-like lines at the top
content = re.sub(r'if "stat_actions.dart" not in content:.*?\\n', '', content)
content = re.sub(r"content = content\.replace.*?\\n", "", content)

# ensure valid import
if "import '../utils/stat_actions.dart';" not in content:
    content = content.replace("import '../database/database_helper.dart';", "import '../database/database_helper.dart';\nimport '../utils/stat_actions.dart';")

with open('lib/screens/stats_entry_screen.dart', 'w') as f:
    f.write(content)
