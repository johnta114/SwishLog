import 'package:flutter/material.dart';

class AnalyticsScreen extends StatefulWidget {
  final String? gameTitle;

  const AnalyticsScreen({super.key, this.gameTitle});

  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen> {
  final List<String> _filters = ['チーム全体 (2026年度)', 'タロウ (個人)', 'ジロウ (個人)'];
  late String _selectedFilter;
  
  final List<String> _quarters = ['全体', '1Q', '2Q', '3Q', '4Q'];
  String _selectedQuarter = '全体';

  String? _youtubeUrl;

  @override
  void initState() {
    super.initState();
    if (widget.gameTitle != null) {
      final gameFilter = 'vs ${widget.gameTitle}';
      if (!_filters.contains(gameFilter)) {
        _filters.insert(0, gameFilter);
      }
      _selectedFilter = gameFilter;
    } else {
      _selectedFilter = _filters.first;
    }
  }

  void _showYoutubeDialog() {
    final ctrl = TextEditingController(text: _youtubeUrl);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('YouTubeリンクを登録', style: TextStyle(fontWeight: FontWeight.bold)),
        content: TextField(
          controller: ctrl,
          decoration: const InputDecoration(hintText: 'https://youtube.com/...', border: OutlineInputBorder()),
          keyboardType: TextInputType.url,
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('キャンセル', style: TextStyle(color: Colors.grey))),
          ElevatedButton(
            onPressed: () {
              setState(() => _youtubeUrl = ctrl.text.isEmpty ? null : ctrl.text);
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
            child: const Text('保存', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      )
    );
  }

  // モックデータたち
  final List<Map<String, dynamic>> _mockShots = [
    {'x': 0.5, 'y': 0.12, 'made': true}, {'x': 0.48, 'y': 0.10, 'made': true},
    {'x': 0.52, 'y': 0.15, 'made': false}, {'x': 0.2, 'y': 0.25, 'made': true},
    {'x': 0.8, 'y': 0.25, 'made': false}, {'x': 0.5, 'y': 0.40, 'made': true},
    {'x': 0.7, 'y': 0.12, 'made': true}, {'x': 0.3, 'y': 0.10, 'made': false},
    {'x': 0.6, 'y': 0.35, 'made': false}, {'x': 0.4, 'y': 0.35, 'made': true},
    {'x': 0.5, 'y': 0.55, 'made': true},
  ];

  final List<Map<String, dynamic>> _playerStats = [
    {'name': 'タロウ', 'pts': 15, 'reb': 4, 'ast': 5, 'stl': 2},
    {'name': 'ジロウ', 'pts': 12, 'reb': 2, 'ast': 1, 'stl': 1},
    {'name': 'ショウ', 'pts': 8, 'reb': 10, 'ast': 0, 'stl': 0},
    {'name': 'ケン', 'pts': 6, 'reb': 3, 'ast': 2, 'stl': 3},
    {'name': 'リョウ', 'pts': 4, 'reb': 5, 'ast': 1, 'stl': 0},
  ];

  final List<Map<String, String>> _gameLogs = [
    {'q': '4Q', 'time': '00:15', 'log': 'タロウ - 3Pシュート (成功)'},
    {'q': '4Q', 'time': '01:30', 'log': 'ケン - リバウンド'},
    {'q': '4Q', 'time': '02:45', 'log': '相手 - シュート (成功)'},
    {'q': '3Q', 'time': '05:10', 'log': 'ジロウ - ターンオーバー'},
    {'q': '3Q', 'time': '08:20', 'log': 'ショウ - ファウル'},
    {'q': '2Q', 'time': '03:15', 'log': 'リョウ - フリースロー (成功)'},
    {'q': '1Q', 'time': '09:45', 'log': 'タロウ - シュート (成功)'},
  ];

  bool get isGameSpecific => _selectedFilter.startsWith('vs ');

  @override
  Widget build(BuildContext context) {
    if (!isGameSpecific) {
      // 特定の試合以外（全体や個人の通算成績）を見ている場合
      return Scaffold(
        appBar: AppBar(
          title: const Text('SwishLog - 分析', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          centerTitle: false,
        ),
        body: Column(
          children: [
            _buildFilterHeader(),
            const Divider(height: 1),
            Expanded(child: _buildStatsView()),
          ],
        ),
      );
    }

    // 特定の試合を見ている場合（YouTubeと試合ログを表示）
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('SwishLog - 分析', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          centerTitle: false,
        ),
        body: Column(
          children: [
            _buildFilterHeader(),
            const Divider(height: 1),
            _buildYoutubeTile(),
            const TabBar(
              labelColor: Colors.deepOrange,
              unselectedLabelColor: Colors.grey,
              indicatorColor: Colors.deepOrange,
              labelStyle: TextStyle(fontWeight: FontWeight.bold),
              tabs: [Tab(text: 'スタッツ分析'), Tab(text: '試合ログ')],
            ),
            Expanded(
              child: TabBarView(
                children: [
                  _buildStatsView(),
                  _buildLogsView(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterHeader() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          const Icon(Icons.bar_chart, color: Colors.deepOrange),
          const SizedBox(width: 12),
          Expanded(
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: _selectedFilter,
                isExpanded: true,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87),
                items: _filters.map((f) => DropdownMenuItem(value: f, child: Text(f))).toList(),
                onChanged: (val) {
                  if (val != null) setState(() => _selectedFilter = val);
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildYoutubeTile() {
    return Container(
      color: Colors.white,
      child: ListTile(
        leading: const Icon(Icons.play_circle_fill, color: Colors.redAccent, size: 36),
        title: Text(
          _youtubeUrl ?? 'YouTube動画を登録する',
          style: TextStyle(
            color: _youtubeUrl == null ? Colors.grey : Colors.blue,
            fontWeight: FontWeight.bold,
            decoration: _youtubeUrl != null ? TextDecoration.underline : null,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: const Text('タップして試合動画のリンクを編集'),
        onTap: _showYoutubeDialog,
        trailing: const Icon(Icons.edit, size: 16, color: Colors.grey),
      ),
    );
  }

  Widget _buildStatsView() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            color: Colors.grey.shade50,
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: _quarters.map((q) {
                  final isSelected = _selectedQuarter == q;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: Text(q, style: TextStyle(color: isSelected ? Colors.white : Colors.black87, fontWeight: FontWeight.bold)),
                      selected: isSelected,
                      selectedColor: Colors.deepOrange,
                      backgroundColor: Colors.white,
                      showCheckmark: false,
                      onSelected: (selected) {
                        if (selected) setState(() => _selectedQuarter = q);
                      },
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('$_selectedQuarter の主要スタッツ', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.blueGrey)),
                const SizedBox(height: 8),
                Row(
                  children: [
                    _buildStatCard('得点', '45.0', 'PTS'),
                    const SizedBox(width: 8),
                    _buildStatCard('2P 成功率', '48%', '12/25'),
                    const SizedBox(width: 8),
                    _buildStatCard('3P 成功率', '33%', '4/12'),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    _buildStatCard('リバウンド', '24.0', 'REB'),
                    const SizedBox(width: 8),
                    _buildStatCard('アシスト', '9.0', 'AST'),
                    const SizedBox(width: 8),
                    _buildStatCard('ターンオーバー', '5.5', 'TO'),
                  ],
                ),
              ],
            ),
          ),
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Column(
              children: [
                Text('$_selectedQuarter のショット分布', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.blueGrey)),
                const SizedBox(height: 4),
                const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.circle, color: Colors.deepOrange, size: 12), SizedBox(width: 4), Text('成功', style: TextStyle(fontSize: 12)),
                    SizedBox(width: 16),
                    Icon(Icons.circle, color: Colors.blueGrey, size: 12), SizedBox(width: 4), Text('失敗', style: TextStyle(fontSize: 12)),
                  ],
                ),
                const SizedBox(height: 16),
                Center(
                  child: FractionallySizedBox(
                    widthFactor: 0.85, 
                    child: AspectRatio(
                      aspectRatio: 15.0 / 14.0,
                      child: Container(
                        decoration: BoxDecoration(color: const Color(0xFFF6E8D7), border: Border.all(color: Colors.black54, width: 2)),
                        child: CustomPaint(painter: AnalysisCourtPainter(_mockShots)),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('$_selectedQuarter の個人成績', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.blueGrey)),
                const SizedBox(height: 8),
                Container(
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 4)]),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: DataTable(
                      headingRowColor: MaterialStateProperty.all(Colors.deepOrange.shade50),
                      columnSpacing: 20,
                      columns: const [
                        DataColumn(label: Text('選手', style: TextStyle(fontWeight: FontWeight.bold))),
                        DataColumn(label: Text('PTS', style: TextStyle(fontWeight: FontWeight.bold)), numeric: true),
                        DataColumn(label: Text('REB', style: TextStyle(fontWeight: FontWeight.bold)), numeric: true),
                        DataColumn(label: Text('AST', style: TextStyle(fontWeight: FontWeight.bold)), numeric: true),
                        DataColumn(label: Text('STL', style: TextStyle(fontWeight: FontWeight.bold)), numeric: true),
                      ],
                      rows: _playerStats.map((stat) {
                        return DataRow(cells: [
                          DataCell(Text(stat['name'], style: const TextStyle(fontWeight: FontWeight.bold))),
                          DataCell(Text('${stat['pts']}')),
                          DataCell(Text('${stat['reb']}')),
                          DataCell(Text('${stat['ast']}')),
                          DataCell(Text('${stat['stl']}')),
                        ]);
                      }).toList(),
                    ),
                  ),
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLogsView() {
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: _gameLogs.length,
      separatorBuilder: (context, index) => const Divider(),
      itemBuilder: (context, index) {
        final log = _gameLogs[index];
        final bool isMade = log['log']!.contains('成功');
        return ListTile(
          leading: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: Colors.blueGrey.shade50, borderRadius: BorderRadius.circular(8)),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(log['q']!, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.blueGrey)),
                Text(log['time']!, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 10, color: Colors.blueGrey)),
              ],
            ),
          ),
          title: Text(log['log']!, style: TextStyle(fontWeight: isMade ? FontWeight.bold : FontWeight.normal)),
          trailing: isMade ? const Icon(Icons.star, color: Colors.orange, size: 20) : null,
        );
      },
    );
  }

  Widget _buildStatCard(String title, String mainValue, String subValue) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 4)]),
        child: Column(
          children: [
            Text(title, style: const TextStyle(fontSize: 11, color: Colors.black54, fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text(mainValue, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.deepOrange)),
            const SizedBox(height: 2),
            Text(subValue, style: const TextStyle(fontSize: 11, color: Colors.blueGrey)),
          ],
        ),
      ),
    );
  }
}

class AnalysisCourtPainter extends CustomPainter {
  final List<Map<String, dynamic>> shots;
  AnalysisCourtPainter(this.shots);
  @override
  void paint(Canvas canvas, Size size) {
    final paintLine = Paint()..color = Colors.black54..style = PaintingStyle.stroke..strokeWidth = 2.0;
    const double courtWidthM = 15.0; 
    final double scale = size.width / courtWidthM;
    Offset mToPx(double x, double y) => Offset(x * scale, y * scale);
    final keyRect = Rect.fromLTRB(mToPx((15.0 - 4.9) / 2, 0).dx, mToPx((15.0 - 4.9) / 2, 0).dy, mToPx(15.0 - (15.0 - 4.9) / 2, 5.8).dx, mToPx(15.0 - (15.0 - 4.9) / 2, 5.8).dy);
    canvas.drawRect(keyRect, paintLine);
    final ftCenter = mToPx(7.5, 5.8);
    canvas.drawArc(Rect.fromCircle(center: ftCenter, radius: 1.8 * scale), 0, 3.1415 * 2, false, paintLine);
    final hoopCenter = mToPx(7.5, 1.575);
    canvas.drawLine(mToPx(7.5 - 0.9, 1.2), mToPx(7.5 + 0.9, 1.2), paintLine..strokeWidth = 3.0);
    canvas.drawCircle(hoopCenter, 0.225 * scale, paintLine..color = Colors.deepOrange..strokeWidth = 3.0);
    paintLine.color = Colors.black54; paintLine.strokeWidth = 2.0;
    final ncRect = Rect.fromCircle(center: hoopCenter, radius: 1.25 * scale);
    canvas.drawArc(ncRect, 0, 3.1415, false, paintLine);
    final path3p = Path();
    path3p.moveTo(mToPx(0.9, 0).dx, mToPx(0.9, 0).dy);
    path3p.lineTo(mToPx(0.9, 2.99).dx, mToPx(0.9, 2.99).dy);
    path3p.arcToPoint(mToPx(14.1, 2.99), radius: Radius.circular(6.75 * scale), clockwise: false);
    path3p.lineTo(mToPx(14.1, 0).dx, mToPx(14.1, 0).dy);
    canvas.drawPath(path3p, paintLine);
    for (var shot in shots) {
      final isMade = shot['made'] as bool;
      final dx = shot['x'] as double;
      final dy = shot['y'] as double;
      final dotPaint = Paint()..color = isMade ? Colors.deepOrange.withOpacity(0.85) : Colors.blueGrey.withOpacity(0.6)..style = PaintingStyle.fill;
      canvas.drawCircle(Offset(dx * size.width, dy * size.height), 7.0, dotPaint);
      if (isMade) {
        final strokePaint = Paint()..color = Colors.white..style = PaintingStyle.stroke..strokeWidth = 1.5;
        canvas.drawCircle(Offset(dx * size.width, dy * size.height), 7.0, strokePaint);
      }
    }
  }
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
