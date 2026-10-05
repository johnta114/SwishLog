import 'package:provider/provider.dart';
import '../providers/app_settings_provider.dart';
import 'settings_screen.dart';
import 'package:flutter/material.dart';
import '../database/database_helper.dart';
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

  String _formatPercentage(int made, int attempted) {
    if (attempted == 0) return '0.0%\n(0/0)';
    final percent = (made / attempted * 100).toStringAsFixed(1);
    return '$percent%\n($made/$attempted)';
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
                      
                      const Text('シーズン戦績', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87)),
                      const SizedBox(height: 12),
                      Card(
                        elevation: 0,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: Colors.grey.shade200)),
                        color: Colors.white,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
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
                        Container(
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey.shade300),
                            color: Colors.white,
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // 左側の固定カラム (選手名)
                              DataTable(
                                headingRowColor: WidgetStateProperty.all(Colors.grey.shade100),
                                dataRowMinHeight: 64,
                                dataRowMaxHeight: 64,
                                headingRowHeight: 48,
                                columnSpacing: 16,
                                horizontalMargin: 16,
                                border: TableBorder(
                                  right: BorderSide(color: Colors.grey.shade300),
                                  horizontalInside: BorderSide(color: Colors.grey.shade300),
                                ),
                                columns: [
                                  DataColumn(label: _buildCellContent('選手', isHeader: true)),
                                ],
                                rows: _playerStats.map((stat) {
                                  final name = stat['court_name']?.isNotEmpty == true 
                                      ? stat['court_name'] 
                                      : '${stat['last_name'] ?? ''} ${stat['first_name'] ?? ''}';
                                  return DataRow(
                                    cells: [
                                      DataCell(_buildCellContent(name, isHeader: true)),
                                    ]
                                  );
                                }).toList(),
                              ),
                              // 右側のスクロール可能なカラム (スタッツ)
                              Expanded(
                                child: SingleChildScrollView(
                                  scrollDirection: Axis.horizontal,
                                  child: DataTable(
                                    headingRowColor: WidgetStateProperty.all(Colors.grey.shade100),
                                    dataRowMinHeight: 64,
                                    dataRowMaxHeight: 64,
                                    headingRowHeight: 48,
                                    columnSpacing: 24,
                                    horizontalMargin: 16,
                                    border: TableBorder(
                                      horizontalInside: BorderSide(color: Colors.grey.shade300),
                                      verticalInside: BorderSide(color: Colors.grey.shade300),
                                    ),
                                    columns: [
                                      DataColumn(label: _buildCellContent('得点', isHeader: true)),
                                      DataColumn(label: _buildCellContent('2P', isHeader: true)),
                                      DataColumn(label: _buildCellContent('3P', isHeader: true)),
                                      DataColumn(label: _buildCellContent('フリースロー', isHeader: true)),
                                      DataColumn(label: _buildCellContent('リバウンド', isHeader: true)),
                                      DataColumn(label: _buildCellContent('アシスト', isHeader: true)),
                                      DataColumn(label: _buildCellContent('スティール', isHeader: true)),
                                      DataColumn(label: _buildCellContent('ターンオーバー', isHeader: true)),
                                      DataColumn(label: _buildCellContent('ファール', isHeader: true)),
                                    ],
                                    rows: _playerStats.map((stat) {
                                      return DataRow(
                                        cells: [
                                          DataCell(_buildCellContent('${stat['PTS'] ?? 0}')),
                                          DataCell(_buildCellContent(_formatPercentage(stat['FGM2'] ?? 0, stat['FGA2'] ?? 0))),
                                          DataCell(_buildCellContent(_formatPercentage(stat['FGM3'] ?? 0, stat['FGA3'] ?? 0))),
                                          DataCell(_buildCellContent(_formatPercentage(stat['FTM'] ?? 0, stat['FTA'] ?? 0))),
                                          DataCell(_buildCellContent('${stat['REB'] ?? 0}')),
                                          DataCell(_buildCellContent('${stat['AST'] ?? 0}')),
                                          DataCell(_buildCellContent('${stat['STL'] ?? 0}')),
                                          DataCell(_buildCellContent('${stat['TOV'] ?? 0}')),
                                          DataCell(_buildCellContent('${stat['FOUL'] ?? 0}')),
                                        ]
                                      );
                                    }).toList(),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 80),
                    ],
                  ),
                ),
              ),
    );
  }
}
