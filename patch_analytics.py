import re

with open('lib/screens/analytics_screen.dart', 'r') as f:
    content = f.read()

# 1. Fetch roster in _loadData
load_data_old = """    if (widget.gameId != null) {
      final gameData = await DatabaseHelper.instance.getGameById(widget.gameId!);
      _youtubeUrl = gameData?['video_url'];
    }"""
load_data_new = """    if (widget.gameId != null) {
      final gameData = await DatabaseHelper.instance.getGameById(widget.gameId!);
      _youtubeUrl = gameData?['video_url'];
      if (gameData != null && gameData['season_id'] != null) {
        _roster = await DatabaseHelper.instance.getRosterForSeason(gameData['season_id'].toString());
      }
    }"""
if "_roster =" not in content:
    content = content.replace(load_data_old, load_data_new)
    # Also add _roster to class variables
    content = content.replace("  List<Map<String, dynamic>> _rawStats = [];", "  List<Map<String, dynamic>> _rawStats = [];\n  List<Map<String, dynamic>> _roster = [];")

# 2. Modify ListTile to show edit icon or be tappable
list_tile_old = """            return ListTile(
              leading: CircleAvatar(
                backgroundColor: iconColor.withOpacity(0.2),
                child: Icon(icon, color: iconColor),
              ),
              title: Text("$name - $label", style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text(timeStr),
            );"""
list_tile_new = """            return ListTile(
              leading: CircleAvatar(
                backgroundColor: iconColor.withOpacity(0.2),
                child: Icon(icon, color: iconColor),
              ),
              title: Text("$name - $label", style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text(timeStr),
              trailing: IconButton(
                icon: const Icon(Icons.edit, color: Colors.grey),
                onPressed: () => _showEditStatDialog(stat),
              ),
            );"""
content = content.replace(list_tile_old, list_tile_new)

with open('lib/screens/analytics_screen.dart', 'w') as f:
    f.write(content)
