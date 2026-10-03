import re

with open('lib/screens/games_screen.dart', 'r') as f:
    content = f.read()

layout_old = """                  ],
                  
                  DropdownButtonFormField<String>("""

layout_new = """                  ],
                  
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>("""

content = content.replace(layout_old, layout_new)

with open('lib/screens/games_screen.dart', 'w') as f:
    f.write(content)
