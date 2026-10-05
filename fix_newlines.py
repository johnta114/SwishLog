import re

for filename in ['lib/screens/games_screen.dart', 'lib/screens/opponent_teams_screen.dart']:
    with open(filename, 'r') as f:
        content = f.read()
    
    # Fix games_screen
    content = content.replace("該当する試合が見つからないか、\nまだ作成されていません。", "該当する試合が見つからないか、\\nまだ作成されていません。")
    # Fix opponent_teams_screen
    content = content.replace("対戦相手が登録されていません。\n右下のボタンから追加してください。", "対戦相手が登録されていません。\\n右下のボタンから追加してください。")
    
    with open(filename, 'w') as f:
        f.write(content)
