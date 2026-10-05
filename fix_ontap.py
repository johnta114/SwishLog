import re

with open('lib/screens/games_screen.dart', 'r') as f:
    content = f.read()

bad_ontap = """                                  onTap: () {
                                    final String startersJson = game['starters'] ?? '[]';
                                    final String benchJson = game['bench'] ?? '[]';
                                    final List<String> starters = List<String>.from(jsonDecode(startersJson));
                                    final List<String> bench = List<String>.from(jsonDecode(benchJson));
                                    await Navigator.push(context, MaterialPageRoute(builder: (context) => StatsEntryScreen(gameId: game['id'].toString(), opponentName: game['opponent'], starters: starters, bench: bench)));
                                  },"""

good_ontap = """                                  onTap: () async {
                                    final status = game['status'] ?? 'completed';
                                    if (status == 'completed') {
                                      Navigator.push(context, MaterialPageRoute(builder: (context) => StatsEntryScreen(gameId: game['id'].toString(), opponentName: game['opponent'], starters: const [], bench: const [])));
                                    } else if (status == 'in_progress') {
                                      final starters = _activeRoster.take(5).toList();
                                      final bench = _activeRoster.skip(5).toList();
                                      await Navigator.push(context, MaterialPageRoute(builder: (context) => StatsEntryScreen(gameId: game['id'].toString(), opponentName: game['opponent'], starters: starters, bench: bench)));
                                      _loadData();
                                    } else {
                                      _showStarterSelectionModal(game);
                                    }
                                  },"""

content = content.replace(bad_ontap, good_ontap)

with open('lib/screens/games_screen.dart', 'w') as f:
    f.write(content)
