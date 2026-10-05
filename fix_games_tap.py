import re

with open('lib/screens/games_screen.dart', 'r') as f:
    content = f.read()

# Add import for GameResultScreen
if "import 'game_result_screen.dart';" not in content:
    content = "import 'game_result_screen.dart';\n" + content

old_tap = """                                  onTap: () async {
                                    final status = game['status'] ?? 'completed';
                                    if (status == 'completed') {
                                      Navigator.push(context, MaterialPageRoute(builder: (context) => StatsEntryScreen(gameId: game['id'].toString(), opponentName: game['opponent'], starters: const [], bench: const [])));
                                    } else if (status == 'in_progress') {"""

new_tap = """                                  onTap: () async {
                                    final status = game['status'] ?? 'completed';
                                    if (status == 'completed') {
                                      Navigator.push(context, MaterialPageRoute(builder: (context) => GameResultScreen(game: game)));
                                    } else if (status == 'in_progress') {"""

content = content.replace(old_tap, new_tap)

with open('lib/screens/games_screen.dart', 'w') as f:
    f.write(content)

