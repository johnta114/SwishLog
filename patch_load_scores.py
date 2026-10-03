import re

with open('lib/screens/stats_entry_screen.dart', 'r') as f:
    content = f.read()

# Fix the Game Fetch logic
inefficient_fetch = """      final games = await DatabaseHelper.instance.getAllGames();
      final thisGame = games.firstWhere((g) => g['id'].toString() == widget.gameId);"""

efficient_fetch = """      final thisGame = await DatabaseHelper.instance.getGameById(widget.gameId);
      if (thisGame == null) return;"""
content = content.replace(inefficient_fetch, efficient_fetch)

# Fix the label logic
inefficient_labels = """        String label = type;
        if (type == '2P' || type == '3P' || type == 'FG') label = "$type ${isMade ? '成功' : '失敗'}";
        else if (type == 'FT') label = "フリースロー ${isMade ? '成功' : '失敗'}";
        else if (type == 'REB') label = "リバウンド";
        else if (type == 'AST') label = "アシスト";
        else if (type == 'STL') label = "スティール";
        else if (type == 'TO') label = "ターンオーバー";
        else if (type == 'PF') label = "ファウル";"""

efficient_labels = """        String label = StatActions.getLabel(type as String);
        if (type == '2P' || type == '3P' || type == 'FG' || type == 'FT') {
          label = "$label ${isMade ? '成功' : '失敗'}";
        }"""
content = content.replace(inefficient_labels, efficient_labels)

with open('lib/screens/stats_entry_screen.dart', 'w') as f:
    f.write(content)
