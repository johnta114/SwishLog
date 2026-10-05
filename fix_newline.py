import re

with open('lib/widgets/player_stats_table.dart', 'r') as f:
    content = f.read()

# Replace the literal \n with actual newline character in the Dart string
content = content.replace("'0.0%\\\\n(0/0)'", "'0.0%\\n(0/0)'")
content = content.replace("'$percent%\\\\n($made/$attempted)'", "'$percent%\\n($made/$attempted)'")

with open('lib/widgets/player_stats_table.dart', 'w') as f:
    f.write(content)

