import re

with open('lib/screens/home_screen.dart', 'r') as f:
    content = f.read()

# 1. Add _buildOverviewColumn helper method before _buildStatColumn
helper = """
  Widget _buildOverviewColumn(String label, String value1, String value2) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Text(value1, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87)),
        const SizedBox(height: 4),
        Text(value2, style: const TextStyle(fontSize: 12, color: Colors.black54)),
      ],
    );
  }

  Widget _buildStatColumn(String label, int count, Color color, VoidCallback onTap) {"""

content = content.replace("  Widget _buildStatColumn(String label, int count, Color color, VoidCallback onTap) {", helper)

# 2. Add calculation and UI block before "個人スタッツ一覧"
calc_and_ui = """                      ),
                      
                      const SizedBox(height: 32),
                      
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

                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('シーズン概要', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87)),
                              const SizedBox(height: 12),
                              Card(
                                elevation: 0,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: Colors.grey.shade200)),
                                color: Colors.white,
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 8),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                    children: [
                                      _buildOverviewColumn('平均得点', avgPts, '点 / 試合'),
                                      Container(height: 40, width: 1, color: Colors.grey.shade200),
                                      _buildOverviewColumn('2P', getPct(total2PM, total2PA), '($total2PM / $total2PA)'),
                                      Container(height: 40, width: 1, color: Colors.grey.shade200),
                                      _buildOverviewColumn('3P', getPct(total3PM, total3PA), '($total3PM / $total3PA)'),
                                      Container(height: 40, width: 1, color: Colors.grey.shade200),
                                      _buildOverviewColumn('フリースロー', getPct(totalFTM, totalFTA), '($totalFTM / $totalFTA)'),
                                    ],
                                  ),
                                ),
                              ),
                            ]
                          );
                        }
                      ),

                      const SizedBox(height: 32),
                      
                      const Text('個人スタッツ一覧', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87)),"""

old_divider = """                      ),
                      
                      const SizedBox(height: 32),
                      
                      const Text('個人スタッツ一覧', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87)),"""

content = content.replace(old_divider, calc_and_ui)

with open('lib/screens/home_screen.dart', 'w') as f:
    f.write(content)

