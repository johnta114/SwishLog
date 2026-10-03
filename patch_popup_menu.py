import re

with open('lib/screens/season_roster_screen.dart', 'r') as f:
    content = f.read()

popup_old = """                      PopupMenuButton<String>(
                        icon: const Icon(Icons.more_vert, color: Colors.grey),
                        onSelected: (val) {"""
popup_new = """                      PopupMenuButton<String>(
                        color: Colors.white,
                        surfaceTintColor: Colors.transparent,
                        icon: const Icon(Icons.more_vert, color: Colors.grey),
                        onSelected: (val) {"""

content = content.replace(popup_old, popup_new)

with open('lib/screens/season_roster_screen.dart', 'w') as f:
    f.write(content)
