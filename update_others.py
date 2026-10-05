import re

for filename in ['lib/screens/games_screen.dart', 'lib/screens/opponent_teams_screen.dart']:
    with open(filename, 'r') as f:
        content = f.read()

    if "import 'settings_screen.dart';" not in content:
        content = "import 'settings_screen.dart';\n" + content

    appbar_search = r"(actions: \[\s*IconButton\([\s\S]*?onPressed: \(\) \{\s*setState\(\(\) => _isSearching = !_isSearching\);\s*\},\s*\),)"
    new_action = r"\1\n          IconButton(\n            icon: const Icon(Icons.settings),\n            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SettingsScreen())),\n          ),"
    
    content = re.sub(appbar_search, new_action, content)

    with open(filename, 'w') as f:
        f.write(content)
