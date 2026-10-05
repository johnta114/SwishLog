with open('lib/screens/games_screen.dart', 'r') as f:
    content = f.read()

old_action = """          IconButton(
            icon: Icon(_isSearching ? Icons.close : Icons.search),
            onPressed: () {
              setState(() {
                _isSearching = !_isSearching;

              });
            },
          ),"""

new_action = old_action + """
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SettingsScreen())),
          ),"""

content = content.replace(old_action, new_action)

with open('lib/screens/games_screen.dart', 'w') as f:
    f.write(content)
