import 'package:provider/provider.dart';
import '../providers/app_settings_provider.dart';
import 'settings_screen.dart';
import 'package:flutter/material.dart';
import '../database/database_helper.dart';
import '../widgets/player_stats_table.dart';
import '../main.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _isLoading = true;
  Map<String, dynamic>? _activeSeason;
  List<Map<String, dynamic>> _completedGames = [];
  List<Map<String, dynamic>> _winGames = [];
  List<Map<String, dynamic>> _lossGames = [];
  List<Map<String, dynamic>> _drawGames = [];
  List<Map<String, dynamic>> _playerStats = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }


  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final settings = Provider.of<AppSettingsProvider>(context);
    if (settings.isLoaded) {
      if (_activeSeason == null || _activeSeason!['id'] != settings.activeSeasonId) {
        _loadData(settings.activeSeasonId);
      }
    }
  }

  Future<void> _loadData([String? seasonId]) async {

    setState(() => _isLoading = true);
    if (seasonId == null) {
      if (mounted) setState(() { _isLoading = false; _activeSeason = null; });
      return;
    }
    final seasons = await DatabaseHelper.instance.getSeasons();
    final activeSeason = seasons.firstWhere((s) => s['id'] == seasonId, orElse: () => <String, dynamic>{});
    if (activeSeason.isEmpty) {
      if (mounted) setState(() { _isLoading = false; _activeSeason = null; });
      return;
    }
    final games = await DatabaseHelper.instance.getAllGames();
    final seasonGames = games.where((g) => g['season_id'] == activeSeason['id']).toList();

    final completedList = <Map<String, dynamic>>[];
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
    }
  }

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

  Widget _buildCellContent(String text, {bool isHeader = false}) {
    return Center(
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: TextStyle(
          fontWeight: isHeader ? FontWeight.bold : FontWeight.normal,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: GestureDetector(
          onTap: () {
            Navigator.of(context).popUntil((route) => route.isFirst);
            mainScreenKey.currentState?.goToHome();
          },
          child: const Text('SwishLog', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        ),
        centerTitle: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SettingsScreen())),
          ),
        ],
      ),
      body: _isLoading 
        ? const Center(child: CircularProgressIndicator(color: Colors.deepOrange))
        : _activeSeason == null 
            ? const Center(child: Text('シーズンが登録されていません。\n「チーム管理」タブからシーズンを作成してください。', textAlign: TextAlign.center))
            : SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.orange.shade50,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.orange.shade200),
                        ),
                        child: Text(
                          '現在の対象シーズン: ${_activeSeason!['name']}',
                          style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.orange.shade900),
                        ),
                      ),
                      const SizedBox(height: 24),
                      
                      const Text('シーズン概要', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87)),
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
                      
                      const Text('個人スタッツ一覧', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87)),
                      const SizedBox(height: 12),
                      if (_playerStats.isEmpty)
                        const Padding(
                          padding: EdgeInsets.all(16.0),
                          child: Center(child: Text('このシーズンの選手データがありません。', style: TextStyle(color: Colors.black54))),
                        )
                      else
                        PlayerStatsTable(stats: _playerStats),
                        const SizedBox(height: 80),
                    ],
                  ),
                ),
              ),
    );
  }
}
