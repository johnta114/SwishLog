import re

with open('lib/screens/home_screen.dart', 'r') as f:
    content = f.read()

# 1. Update State Variables
old_state = """  bool _isLoading = true;
  Map<String, dynamic>? _activeSeason;
  int _wins = 0;
  int _losses = 0;
  int _draws = 0;
  int _totalGames = 0;
  List<Map<String, dynamic>> _playerStats = [];"""

new_state = """  bool _isLoading = true;
  Map<String, dynamic>? _activeSeason;
  List<Map<String, dynamic>> _completedGames = [];
  List<Map<String, dynamic>> _winGames = [];
  List<Map<String, dynamic>> _lossGames = [];
  List<Map<String, dynamic>> _drawGames = [];
  List<Map<String, dynamic>> _playerStats = [];"""
content = content.replace(old_state, new_state)

# 2. Update _loadData
old_load_data = """    int w = 0, l = 0, d = 0;
    for (var g in seasonGames) {
      if (g['status'] == 'completed') {
        int myScore = g['my_score'] ?? 0;
        int oppScore = g['opp_score'] ?? 0;
        if (myScore > oppScore) w++;
        else if (myScore < oppScore) l++;
        else d++;
      }
    }

    final stats = await DatabaseHelper.instance.getSeasonPlayerStats(activeSeason['id'].toString());

    if (mounted) {
      setState(() {
        _activeSeason = activeSeason;
        _wins = w;
        _losses = l;
        _draws = d;
        _totalGames = w + l + d;
        _playerStats = stats;
        _isLoading = false;
      });
    }"""

new_load_data = """    final completedList = <Map<String, dynamic>>[];
    final winList = <Map<String, dynamic>>[];
    final lossList = <Map<String, dynamic>>[];
    final drawList = <Map<String, dynamic>>[];

    for (var g in seasonGames) {
      if (g['status'] == 'completed') {
        completedList.add(g);
        int myScore = g['my_score'] ?? 0;
        int oppScore = g['opp_score'] ?? 0;
        if (myScore > oppScore) winList.add(g);
        else if (myScore < oppScore) lossList.add(g);
        else drawList.add(g);
      }
    }

    final stats = await DatabaseHelper.instance.getSeasonPlayerStats(activeSeason['id'].toString());

    if (mounted) {
      setState(() {
        _activeSeason = activeSeason;
        _completedGames = completedList;
        _winGames = winList;
        _lossGames = lossList;
        _drawGames = drawList;
        _playerStats = stats;
        _isLoading = false;
      });
    }"""
content = content.replace(old_load_data, new_load_data)

# 3. Add helper methods
methods_to_add = """
  void _showGamesList(String title, List<Map<String, dynamic>> games) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.only(top: 16),
          height: MediaQuery.of(context).size.height * 0.6,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(context)),
                  ],
                ),
              ),
              const Divider(),
              Expanded(
                child: games.isEmpty
                  ? const Center(child: Text('該当する試合がありません', style: TextStyle(color: Colors.black54)))
                  : ListView.separated(
                      itemCount: games.length,
                      separatorBuilder: (context, index) => const Divider(height: 1),
                      itemBuilder: (context, index) {
                        final g = games[index];
                        final date = g['date'] ?? '';
                        final opp = g['opponent'] ?? '不明';
                        final myScore = g['my_score'] ?? 0;
                        final oppScore = g['opp_score'] ?? 0;
                        return ListTile(
                          title: Text('vs $opp', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                          subtitle: Text(date, style: const TextStyle(fontSize: 12, color: Colors.black54)),
                          trailing: Text('$myScore - $oppScore', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black87)),
                        );
                      },
                    ),
              ),
            ],
          ),
        );
      }
    );
  }

  Widget _buildStatColumn(String label, int count, Color color, VoidCallback onTap) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Column(
            children: [
              Text(label, style: const TextStyle(fontSize: 12, color: Colors.black54, fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              Text('$count', style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: color)),
            ],
          ),
        ),
      ),
    );
  }
"""

content = content.replace("  String _formatPercentage", methods_to_add + "\n  String _formatPercentage")

# 4. Replace Card children
old_card = """                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                children: [
                                  Column(
                                    children: [
                                      const Text('試合数', style: TextStyle(fontSize: 12, color: Colors.black54, fontWeight: FontWeight.bold)),
                                      const SizedBox(height: 4),
                                      Text('$_totalGames', style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold)),
                                    ],
                                  ),
                                  Container(height: 40, width: 1, color: Colors.grey.shade200),
                                  Column(
                                    children: [
                                      const Text('勝', style: TextStyle(fontSize: 12, color: Colors.black54, fontWeight: FontWeight.bold)),
                                      const SizedBox(height: 4),
                                      Text('$_wins', style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.deepOrange)),
                                    ],
                                  ),
                                  Container(height: 40, width: 1, color: Colors.grey.shade200),
                                  Column(
                                    children: [
                                      const Text('負', style: TextStyle(fontSize: 12, color: Colors.black54, fontWeight: FontWeight.bold)),
                                      const SizedBox(height: 4),
                                      Text('$_losses', style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.blueAccent)),
                                    ],
                                  ),
                                  if (_draws > 0) ...[
                                    Container(height: 40, width: 1, color: Colors.grey.shade200),
                                    Column(
                                      children: [
                                        const Text('分', style: TextStyle(fontSize: 12, color: Colors.black54, fontWeight: FontWeight.bold)),
                                        const SizedBox(height: 4),
                                        Text('$_draws', style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.blueGrey)),
                                      ],
                                    ),
                                  ],
                                ],
                              )"""

new_card = """                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                children: [
                                  _buildStatColumn('試合数', _completedGames.length, Colors.black87, () => _showGamesList('全試合', _completedGames)),
                                  Container(height: 40, width: 1, color: Colors.grey.shade200),
                                  _buildStatColumn('勝', _winGames.length, Colors.deepOrange, () => _showGamesList('勝利した試合', _winGames)),
                                  Container(height: 40, width: 1, color: Colors.grey.shade200),
                                  _buildStatColumn('負', _lossGames.length, Colors.blueAccent, () => _showGamesList('敗北した試合', _lossGames)),
                                  if (_drawGames.isNotEmpty) ...[
                                    Container(height: 40, width: 1, color: Colors.grey.shade200),
                                    _buildStatColumn('分', _drawGames.length, Colors.blueGrey, () => _showGamesList('引き分けた試合', _drawGames)),
                                  ],
                                ],
                              )"""
content = content.replace(old_card, new_card)

with open('lib/screens/home_screen.dart', 'w') as f:
    f.write(content)

