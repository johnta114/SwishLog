import re

# Fix season_roster_screen.dart
with open('lib/screens/season_roster_screen.dart', 'r') as f:
    content = f.read()

old_appbar = "centerTitle: false,\n      ),"
new_appbar = """centerTitle: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SettingsScreen())),
          ),
        ],
      ),"""
content = content.replace(old_appbar, new_appbar)

with open('lib/screens/season_roster_screen.dart', 'w') as f:
    f.write(content)


# Fix opponent_teams_screen.dart
with open('lib/screens/opponent_teams_screen.dart', 'r') as f:
    content = f.read()

old_appbar_action = """          IconButton(
            icon: Icon(_isSearching ? Icons.close : Icons.search),
            onPressed: () {
              setState(() {
                _isSearching = !_isSearching;

              });
            },
          ),"""
new_appbar_action = old_appbar_action + """
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SettingsScreen())),
          ),"""

content = content.replace(old_appbar_action, new_appbar_action)

with open('lib/screens/opponent_teams_screen.dart', 'w') as f:
    f.write(content)

