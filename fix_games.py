with open('lib/screens/games_screen.dart', 'r') as f:
    lines = f.readlines()

for i in range(len(lines)):
    if "                          )," in lines[i] and "                        );" in lines[i+1] and "                      }" in lines[i+2]:
        # it was already patched? wait let's just print it.
        pass

