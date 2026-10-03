with open('lib/screens/stats_entry_screen.dart', 'r') as f:
    c = f.read()
c = c.replace(r"\nimport '../utils/stat_actions.dart';\n", "\nimport '../utils/stat_actions.dart';\n")
with open('lib/screens/stats_entry_screen.dart', 'w') as f:
    f.write(c)

with open('lib/screens/analytics_screen.dart', 'r') as f:
    c = f.read()
c = c.replace(r"\nimport '../utils/stat_actions.dart';\n", "\nimport '../utils/stat_actions.dart';\n")
with open('lib/screens/analytics_screen.dart', 'w') as f:
    f.write(c)
