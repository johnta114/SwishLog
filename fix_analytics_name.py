import re

with open('lib/screens/game_analytics_screen.dart', 'r') as f:
    content = f.read()

content = content.replace('class AnalyticsScreen extends', 'class GameAnalyticsScreen extends')
content = content.replace('State<AnalyticsScreen>', 'State<GameAnalyticsScreen>')
content = content.replace('AnalyticsScreen({', 'GameAnalyticsScreen({')
content = content.replace('_AnalyticsScreenState', '_GameAnalyticsScreenState')

with open('lib/screens/game_analytics_screen.dart', 'w') as f:
    f.write(content)
