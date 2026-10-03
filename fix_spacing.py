import re

with open('lib/screens/games_screen.dart', 'r') as f:
    content = f.read()

spacing_old = """                  ),
                  const SizedBox(height: 16),

                  const SizedBox(height: 16),
                  TextField("""

spacing_new = """                  ),
                  const SizedBox(height: 16),
                  TextField("""

content = content.replace(spacing_old, spacing_new)

with open('lib/screens/games_screen.dart', 'w') as f:
    f.write(content)
