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
  int _wins = 0;
  int _losses = 0;
  int _draws = 0;
  int _totalGames = 0;
  List<Map<String, dynamic>> _playerStats = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    final seasons = await DatabaseHelper.instance.getSeasons();
    if (seasons.isEmpty) {
      if (mounted) {
        setState(() {
          _activeSeason = null;
          _isLoading = false;
        });
      }
      return;
    }

    final activeSeason = seasons.first;
    final games = await DatabaseHelper.instance.getAllGames();
    final seasonGames = games.where((g) => g['season_id'] == activeSeason['id']).toList();

    int w = 0, l = 0, d = 0;
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
    }
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
                          child: SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: DataTable(
                              headingRowColor: WidgetStateProperty.all(Colors.grey.shade100),
                              columnSpacing: 24,
                              border: TableBorder.all(color: Colors.grey.shade300),
                              columns: [
                                DataColumn(label: _buildCellContent('選手', isHeader: true)),
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
                                final name = stat['court_name']?.isNotEmpty == true 
                                    ? stat['court_name'] 
                                    : '${stat['last_name'] ?? ''} ${stat['first_name'] ?? ''}';
                                return DataRow(
                                  cells: [
                                    DataCell(_buildCellContent(name, isHeader: true)),
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
                        const SizedBox(height: 80),
                    ],
                  ),
                ),
              ),
    );
  }
}
