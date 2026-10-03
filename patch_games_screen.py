import re

with open('lib/screens/games_screen.dart', 'r') as f:
    content = f.read()

# 1. Add _seasons to state
state_old = """  String? _activeSeasonId;
  List<Map<String, dynamic>> _activeRoster = [];"""

state_new = """  String? _activeSeasonId;
  List<Map<String, dynamic>> _seasons = [];
  List<Map<String, dynamic>> _activeRoster = [];"""
content = content.replace(state_old, state_new)

# 2. Populate _seasons in _loadData
load_old = """    setState(() {
      _games = games;
      _knownOpponents = opponents;
      _activeSeasonId = activeSeason;
      _activeRoster = roster;
      _isLoading = false;
    });"""

load_new = """    setState(() {
      _games = games;
      _knownOpponents = opponents;
      _seasons = seasons;
      _activeSeasonId = activeSeason;
      _activeRoster = roster;
      _isLoading = false;
    });"""
content = content.replace(load_old, load_new)

# 3. Add selectedSeasonId state inside _showGameModal
modal_old = """    bool isNewOpponent = false;
    String? selectedOpponentId = isEdit ? game['opponent_team_id']?.toString() : null;"""

modal_new = """    bool isNewOpponent = false;
    String? selectedOpponentId = isEdit ? game['opponent_team_id']?.toString() : null;
    String? selectedSeasonId = isEdit ? game['season_id']?.toString() : _activeSeasonId;"""
content = content.replace(modal_old, modal_new)

# 4. Add dropdown for season in UI
ui_old = """                  Text(isEdit ? '試合の編集' : '新規試合の作成', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  
                  Container("""

ui_new = """                  Text(isEdit ? '試合の編集' : '新規試合の作成', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  
                  DropdownButtonFormField<String>(
                    decoration: const InputDecoration(labelText: '対象シーズン', border: OutlineInputBorder()),
                    value: selectedSeasonId,
                    items: _seasons.map((s) => DropdownMenuItem(value: s['id'].toString(), child: Text(s['name'].toString()))).toList(),
                    onChanged: (val) {
                      if (val != null) setModalState(() => selectedSeasonId = val);
                    },
                  ),
                  const SizedBox(height: 16),

                  Container("""
content = content.replace(ui_old, ui_new)

# 5. Use selectedSeasonId in save data
save_old = """                      final data = {
                        'season_id': _activeSeasonId,
                        'date': dateCtrl.text,"""
save_new = """                      final data = {
                        'season_id': selectedSeasonId,
                        'date': dateCtrl.text,"""
content = content.replace(save_old, save_new)

with open('lib/screens/games_screen.dart', 'w') as f:
    f.write(content)
