import re

with open('lib/screens/home_screen.dart', 'r') as f:
    content = f.read()

# We need to replace everything from "const Text('シーズン戦績'" down to just before "const Text('個人スタッツ一覧'"
start_str = "const Text('シーズン戦績', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87)),"
end_str = "const Text('個人スタッツ一覧', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87)),"

start_idx = content.find(start_str)
end_idx = content.find(end_str)

if start_idx != -1 and end_idx != -1:
    unified_code = """const Text('シーズン概要', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87)),
                      const SizedBox(height: 12),
                      Builder(
                        builder: (context) {
                          int totalPts = 0;
                          int total2PM = 0, total2PA = 0;
                          int total3PM = 0, total3PA = 0;
                          int totalFTM = 0, totalFTA = 0;

                          for (var p in _playerStats) {
                            totalPts += (num.tryParse(p['PTS']?.toString() ?? '0')?.toInt() ?? 0);
                            total2PM += (num.tryParse(p['FGM2']?.toString() ?? '0')?.toInt() ?? 0);
                            total2PA += (num.tryParse(p['FGA2']?.toString() ?? '0')?.toInt() ?? 0);
                            total3PM += (num.tryParse(p['FGM3']?.toString() ?? '0')?.toInt() ?? 0);
                            total3PA += (num.tryParse(p['FGA3']?.toString() ?? '0')?.toInt() ?? 0);
                            totalFTM += (num.tryParse(p['FTM']?.toString() ?? '0')?.toInt() ?? 0);
                            totalFTA += (num.tryParse(p['FTA']?.toString() ?? '0')?.toInt() ?? 0);
                          }

                          final int gamesCount = _completedGames.length;
                          final String avgPts = gamesCount > 0 ? (totalPts / gamesCount).toStringAsFixed(1) : '0.0';
                          
                          String getPct(int m, int a) => a > 0 ? '${(m / a * 100).toStringAsFixed(1)}%' : '0.0%';

                          return Card(
                            elevation: 0,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: Colors.grey.shade200)),
                            color: Colors.white,
                            child: Column(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
                                  child: Row(
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
                                  ),
                                ),
                                Divider(height: 1, color: Colors.grey.shade200, indent: 16, endIndent: 16),
                                Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 8),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                    children: [
                                      _buildOverviewColumn('平均得点', avgPts, '点 / 試合'),
                                      Container(height: 40, width: 1, color: Colors.grey.shade200),
                                      _buildOverviewColumn('2P', getPct(total2PM, total2PA), '($total2PM / $total2PA)'),
                                      Container(height: 40, width: 1, color: Colors.grey.shade200),
                                      _buildOverviewColumn('3P', getPct(total3PM, total3PA), '($total3PM / $total3PA)'),
                                      Container(height: 40, width: 1, color: Colors.grey.shade200),
                                      _buildOverviewColumn('FT', getPct(totalFTM, totalFTA), '($totalFTM / $totalFTA)'),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          );
                        }
                      ),
                      
                      const SizedBox(height: 32),
                      
                      """
    content = content[:start_idx] + unified_code + content[end_idx:]

with open('lib/screens/home_screen.dart', 'w') as f:
    f.write(content)

