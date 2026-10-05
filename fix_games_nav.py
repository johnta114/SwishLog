import re

with open('lib/screens/games_screen.dart', 'r') as f:
    content = f.read()

content = content.replace("import 'game_result_screen.dart';", "import 'game_analytics_screen.dart';")

old_nav = "Navigator.push(context, MaterialPageRoute(builder: (context) => GameResultScreen(game: game)));"
new_nav = "Navigator.push(context, MaterialPageRoute(builder: (context) => GameAnalyticsScreen(gameId: game['id'].toString(), gameTitle: 'vs ${game['opponent']}')));"

content = content.replace(old_nav, new_nav)

with open('lib/screens/games_screen.dart', 'w') as f:
    f.write(content)
