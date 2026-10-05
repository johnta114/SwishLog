import re

# Fix games_screen
with open('lib/screens/games_screen.dart', 'r') as f:
    content = f.read()

# Add json import if missing
if 'import \'dart:convert\';' not in content:
    content = "import 'dart:convert';\n" + content

old_call = "Navigator.push(context, MaterialPageRoute(builder: (context) => StatsEntryScreen(gameId: game['id'].toString())));"
new_call = """final String startersJson = game['starters'] ?? '[]';
                                    final String benchJson = game['bench'] ?? '[]';
                                    final List<String> starters = List<String>.from(jsonDecode(startersJson));
                                    final List<String> bench = List<String>.from(jsonDecode(benchJson));
                                    await Navigator.push(context, MaterialPageRoute(builder: (context) => StatsEntryScreen(gameId: game['id'].toString(), opponentName: game['opponent'], starters: starters, bench: bench)));"""
content = content.replace(old_call, new_call)

# also fix the literal newline in games_screen if any
content = content.replace("該当する試合が見つからないか、\nまだ作成されていません。", "該当する試合が見つからないか、\\nまだ作成されていません。")

with open('lib/screens/games_screen.dart', 'w') as f:
    f.write(content)

# Fix opponent_teams_screen
with open('lib/screens/opponent_teams_screen.dart', 'r') as f:
    opp_content = f.read()

# The text has a literal newline in the file:
# Text('対戦相手が登録されていません。
# 右下のボタンから追加してください。'
# We replace it with a single line string.
opp_content = re.sub(r"Text\('対戦相手が登録されていません。[\s\S]*?右下のボタンから追加してください。'", r"Text('対戦相手が登録されていません。\\n右下のボタンから追加してください。'", opp_content)

with open('lib/screens/opponent_teams_screen.dart', 'w') as f:
    f.write(opp_content)
