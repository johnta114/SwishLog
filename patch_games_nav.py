with open('lib/screens/games_screen.dart', 'r') as f:
    content = f.read()

target = "Navigator.push(context, MaterialPageRoute(builder: (context) => AnalyticsScreen(gameId: game['id'].toString(), gameTitle: game['opponent'])));"
replacement = "await Navigator.push(context, MaterialPageRoute(builder: (context) => AnalyticsScreen(gameId: game['id'].toString(), gameTitle: game['opponent'])));\n                                _loadData();"

if target in content:
    content = content.replace(target, replacement)
    with open('lib/screens/games_screen.dart', 'w') as f:
        f.write(content)
    print("Fixed Analytics Navigator")
else:
    print("Target not found")
