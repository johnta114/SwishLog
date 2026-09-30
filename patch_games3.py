with open('lib/screens/games_screen.dart', 'r') as f:
    lines = f.readlines()

for i, line in enumerate(lines):
    if "                          )," in line and "                        );" not in line:
        if i+1 < len(lines) and "                      }," in lines[i+1]:
            lines[i] = "                          ),\n                        );\n"

with open('lib/screens/games_screen.dart', 'w') as f:
    f.writelines(lines)
