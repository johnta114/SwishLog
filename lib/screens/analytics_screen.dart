import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../database/database_helper.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

class AnalyticsScreen extends StatefulWidget {
  final String? gameId;
  final String? gameTitle;

  const AnalyticsScreen({super.key, this.gameId, this.gameTitle});

  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen> {
  bool _isLoading = true;
  int _selectedQuarter = 0; // 0 = 全体
  
  List<Map<String, dynamic>> _rawStats = [];
  List<Map<String, dynamic>> _roster = [];
  String? _youtubeUrl;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    
    // SQLiteからスタッツデータと試合情報を取得
    final stats = await DatabaseHelper.instance.getRawStats(
      gameId: widget.gameId, 
      quarter: _selectedQuarter > 0 ? _selectedQuarter : null
    );
    
    if (widget.gameId != null) {
      final gameData = await DatabaseHelper.instance.getGameById(widget.gameId!);
      _youtubeUrl = gameData?['video_url'];
      if (gameData != null && gameData['season_id'] != null) {
        _roster = await DatabaseHelper.instance.getRosterForSeason(gameData['season_id'].toString());
      }
    }

    if (mounted) {
      setState(() {
        _rawStats = stats;
        _isLoading = false;
      });
    }
  }

  void _updateQuarter(int q) {
    setState(() => _selectedQuarter = q);
    _loadData();
  }

  // 生スタッツデータから個人成績を計算
  List<Map<String, dynamic>> get _aggregatedPlayerStats {
    Map<String, Map<String, dynamic>> agg = {};
    
    for (var s in _rawStats) {
      final pid = s['player_id'].toString();
      final name = s['court_name'] ?? s['last_name'];
      
      if (!agg.containsKey(pid)) {
        agg[pid] = {'name': name, 'PTS': 0, 'REB': 0, 'AST': 0, 'STL': 0, 'TO': 0, 'PF': 0, 'FGM': 0, 'FGA': 0, '3PM': 0, '3PA': 0};
      }
      
      final type = s['stat_type'];
      final isMade = s['is_made'] == 1;
      
      if (type == '2P' || type == '3P' || type == 'FG') {
        agg[pid]!['FGA'] = (agg[pid]!['FGA'] as int) + 1;
        if (isMade) {
          agg[pid]!['FGM'] = (agg[pid]!['FGM'] as int) + 1;
          agg[pid]!['PTS'] = (agg[pid]!['PTS'] as int) + (type == '3P' ? 3 : 2);
        }
        if (type == '3P') {
           agg[pid]!['3PA'] = (agg[pid]!['3PA'] as int) + 1;
           if (isMade) agg[pid]!['3PM'] = (agg[pid]!['3PM'] as int) + 1;
        }
      } else if (type == 'FT') {
        if (isMade) agg[pid]!['PTS'] = (agg[pid]!['PTS'] as int) + 1;
      } else if (type == 'REB') {
        agg[pid]!['REB'] = (agg[pid]!['REB'] as int) + 1;
      } else if (type == 'AST') {
        agg[pid]!['AST'] = (agg[pid]!['AST'] as int) + 1;
      } else if (type == 'STL') {
        agg[pid]!['STL'] = (agg[pid]!['STL'] as int) + 1;
      } else if (type == 'TO') {
        agg[pid]!['TO'] = (agg[pid]!['TO'] as int) + 1;
      } else if (type == 'PF') {
        agg[pid]!['PF'] = (agg[pid]!['PF'] as int) + 1;
      }
    }
    
    final list = agg.values.toList();
    list.sort((a, b) => (b['PTS'] as int).compareTo(a['PTS'] as int));
    return list;
  }

  void _showYouTubeDialog() {
    final ctrl = TextEditingController(text: _youtubeUrl);
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        title: const Text("YouTubeリンクの登録"),
          content: TextField(
            controller: ctrl,
            decoration: const InputDecoration(hintText: "https://youtu.be/...", border: OutlineInputBorder()),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text("キャンセル")),
            ElevatedButton(
              onPressed: () async {
                if (widget.gameId != null) {
                  await DatabaseHelper.instance.updateGameVideoUrl(widget.gameId!, ctrl.text);
                  setState(() => _youtubeUrl = ctrl.text);
                }
                if (mounted) Navigator.pop(context);
              },
              child: const Text("保存"),
            )
          ],
        );
      }
    );
  }

  Future<void> _launchYouTube() async {
    if (_youtubeUrl != null && _youtubeUrl!.isNotEmpty) {
      final uri = Uri.parse(_youtubeUrl!);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri);
      } else {
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("URLを開けませんでした")));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isGameSpecific = widget.gameId != null;

    final Widget body = _isLoading 
      ? const Center(child: CircularProgressIndicator(color: Colors.deepOrange))
      : Column(
          children: [
            _buildHeaderFilters(isGameSpecific),
            Expanded(
              child: isGameSpecific
                ? TabBarView(
                    children: [
                      _buildStatsTab(),
                      _buildPlayLogsTab(),
                    ],
                  )
                : _buildStatsTab(),
            ),
          ],
        );

    final appBar = AppBar(
      title: const Text('SwishLog', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
      centerTitle: false,
      bottom: isGameSpecific
        ? const TabBar(
            indicatorColor: Colors.white,
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white70,
            tabs: [
              Tab(icon: Icon(Icons.bar_chart), text: "スタッツ"),
              Tab(icon: Icon(Icons.history), text: "試合ログ"),
            ],
          )
        : null,
    );

    if (isGameSpecific) {
      return DefaultTabController(
        length: 2,
        child: Scaffold(
          appBar: appBar,
          body: body,
        ),
      );
    } else {
      return Scaffold(
        appBar: appBar,
        body: body,
      );
    }
  }

  Widget _buildHeaderFilters(bool isGameSpecific) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        children: [
          if (isGameSpecific)
            Row(
              children: [
                const Icon(Icons.play_circle_fill, color: Colors.red),
                const SizedBox(width: 8),
                Expanded(
                  child: InkWell(
                    onTap: _youtubeUrl != null && _youtubeUrl!.isNotEmpty ? _launchYouTube : _showYouTubeDialog,
                    child: Text(
                      _youtubeUrl != null && _youtubeUrl!.isNotEmpty ? "試合映像を見る" : "試合映像(YouTube)のリンクを登録",
                      style: TextStyle(color: Colors.blue.shade700, decoration: TextDecoration.underline, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.edit, size: 20),
                  onPressed: _showYouTubeDialog,
                  tooltip: "リンクを編集",
                )
              ],
            ),
          if (isGameSpecific) const Divider(),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildFilterChip("全体", 0),
                const SizedBox(width: 8),
                _buildFilterChip("1Q", 1),
                const SizedBox(width: 8),
                _buildFilterChip("2Q", 2),
                const SizedBox(width: 8),
                _buildFilterChip("3Q", 3),
                const SizedBox(width: 8),
                _buildFilterChip("4Q", 4),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, int value) {
    return ChoiceChip(
      label: Text(label),
      selected: _selectedQuarter == value,
      onSelected: (selected) {
        if (selected) _updateQuarter(value);
      },
      selectedColor: Colors.deepOrange.shade100,
      labelStyle: TextStyle(
        color: _selectedQuarter == value ? Colors.deepOrange.shade900 : Colors.black87,
        fontWeight: _selectedQuarter == value ? FontWeight.bold : FontWeight.normal,
      ),
    );
  }

  Widget _buildStatsTab() {
    final shots = _rawStats.where((s) => (s['stat_type'] == '2P' || s['stat_type'] == '3P' || s['stat_type'] == 'FG') && s['pos_x'] != null).toList();

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. シュート分布図（ヒートマップ風）
          Container(
            width: double.infinity,
            color: Colors.grey.shade100,
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Text("シュート分布 (FG/3P)", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(width: 12, height: 12, decoration: const BoxDecoration(shape: BoxShape.circle, color: Colors.deepOrange)),
                    const SizedBox(width: 4), const Text("Made", style: TextStyle(fontSize: 12)),
                    const SizedBox(width: 16),
                    Container(width: 12, height: 12, decoration: const BoxDecoration(shape: BoxShape.circle, color: Colors.grey)),
                    const SizedBox(width: 4), const Text("Miss", style: TextStyle(fontSize: 12)),
                  ],
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: MediaQuery.of(context).size.width * 0.8,
                  child: AspectRatio(
                    aspectRatio: 15.0 / 14.0,
                    child: Container(
                      decoration: const BoxDecoration(color: Color(0xFFF6E8D7), border: Border(bottom: BorderSide(color: Colors.black54, width: 2))),
                      child: CustomPaint(
                        painter: AnalysisCourtPainter(shots),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          // 2. 個人成績ランキング・スタッツ
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("個人スタッツ一覧", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                const SizedBox(height: 12),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: DataTable(
                    columnSpacing: 16,
                    headingRowColor: WidgetStateProperty.all(Colors.blueGrey.shade50),
                    columns: const [
                      DataColumn(label: Text("選手", style: TextStyle(fontWeight: FontWeight.bold))),
                      DataColumn(label: Text("PTS", style: TextStyle(fontWeight: FontWeight.bold)), numeric: true),
                      DataColumn(label: Text("REB", style: TextStyle(fontWeight: FontWeight.bold)), numeric: true),
                      DataColumn(label: Text("AST", style: TextStyle(fontWeight: FontWeight.bold)), numeric: true),
                      DataColumn(label: Text("STL", style: TextStyle(fontWeight: FontWeight.bold)), numeric: true),
                      DataColumn(label: Text("TO", style: TextStyle(fontWeight: FontWeight.bold)), numeric: true),
                      DataColumn(label: Text("FG%", style: TextStyle(fontWeight: FontWeight.bold)), numeric: true),
                    ],
                    rows: _aggregatedPlayerStats.map((p) {
                      final fga = p['FGA'] as int;
                      final fgm = p['FGM'] as int;
                      final fgPct = fga > 0 ? ((fgm / fga) * 100).toStringAsFixed(1) : "0.0";
                      
                      return DataRow(
                        cells: [
                          DataCell(Text(p['name'] as String, style: const TextStyle(fontWeight: FontWeight.bold))),
                          DataCell(Text("${p['PTS']}")),
                          DataCell(Text("${p['REB']}")),
                          DataCell(Text("${p['AST']}")),
                          DataCell(Text("${p['STL']}")),
                          DataCell(Text("${p['TO']}")),
                          DataCell(Text("$fgPct%")),
                        ],
                      );
                    }).toList(),
                  ),
                )
              ],
            ),
          )
        ],
      ),
    );
  }


  void _confirmDeleteStat(Map<String, dynamic> stat) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        title: const Text('削除の確認'),
        content: const Text('このアクションを削除しますか？\n（得点の場合は総得点にも反映されます）'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('キャンセル', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
            onPressed: () async {
              await DatabaseHelper.instance.deleteStat(stat['id'].toString());
              if (widget.gameId != null) {
                await DatabaseHelper.instance.updateGameScoreTotals(widget.gameId!);
              }
              Navigator.pop(context);
              _loadData();
            },
            child: const Text('削除する', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      )
    );
  }

  void _showEditStatDialog(Map<String, dynamic> stat) {
    if (_roster.isEmpty) return; // ロスターがない場合は編集不可とする
    
    showDialog(
      context: context,
      builder: (context) => _EditStatDialog(
        stat: stat,
        roster: _roster,
        onSave: (String statId, Map<String, dynamic> updatedData) async {
          await DatabaseHelper.instance.updateStat(statId, updatedData);
          if (widget.gameId != null) {
            await DatabaseHelper.instance.updateGameScoreTotals(widget.gameId!);
          }
          _loadData();
        },
      ),
    );
  }

  Widget _buildPlayLogsTab() {
    return _rawStats.isEmpty 
      ? const Center(child: Text("この試合・クォーターの記録はありません"))
      : ListView.builder(
          padding: const EdgeInsets.symmetric(vertical: 8),
          itemCount: _rawStats.length,
          itemBuilder: (context, index) {
            final stat = _rawStats[index];
            final name = stat['court_name'] ?? stat['last_name'];
            final action = stat['stat_type'];
            final isMade = stat['is_made'] == 1;
            
            String label = action;
            Color iconColor = Colors.grey;
            IconData icon = Icons.sports_basketball;

            if (action == '2P' || action == '3P' || action == 'FT') {
              label = "$action ${isMade ? '成功' : '失敗'}";
              iconColor = isMade ? Colors.deepOrange : Colors.grey;
            } else if (action == 'REB') {
              label = "リバウンド"; iconColor = Colors.blue; icon = Icons.back_hand;
            } else if (action == 'AST') {
              label = "アシスト"; iconColor = Colors.green; icon = Icons.handshake;
            } else if (action == 'STL') {
              label = "スティール"; iconColor = Colors.amber; icon = Icons.security;
            } else if (action == 'TO') {
              label = "ターンオーバー"; iconColor = Colors.red; icon = Icons.warning;
            } else if (action == 'PF') {
              label = "ファウル"; iconColor = Colors.purple; icon = Icons.sports;
            } else if (action == 'SUB') {
              label = "交代でIN"; iconColor = Colors.blueGrey; icon = Icons.change_circle;
            }

            // 時刻のパース
            String timeStr = "";
            try {
              if (stat['created_at'] != null) {
                final dt = DateTime.parse(stat['created_at']);
                timeStr = "${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}";
              }
            } catch (_) {}

            return Slidable(
              key: ValueKey(stat['id'].toString()),
              endActionPane: ActionPane(
                motion: const DrawerMotion(),
                extentRatio: 0.5,
                children: [
                  CustomSlidableAction(
                    onPressed: (context) => _showEditStatDialog(stat),
                    backgroundColor: Colors.transparent,
                    foregroundColor: Colors.blue,
                    padding: const EdgeInsets.only(left: 8),
                    child: Container(
                      decoration: BoxDecoration(color: Colors.blue.shade50, borderRadius: BorderRadius.circular(12)),
                      child: const Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.edit), SizedBox(height: 4), Text('編集', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold))])),
                    ),
                  ),
                  CustomSlidableAction(
                    onPressed: (context) => _confirmDeleteStat(stat),
                    backgroundColor: Colors.transparent,
                    foregroundColor: Colors.red,
                    padding: const EdgeInsets.only(left: 8, right: 8),
                    child: Container(
                      decoration: BoxDecoration(color: Colors.red.shade50, borderRadius: BorderRadius.circular(12)),
                      child: const Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.delete), SizedBox(height: 4), Text('削除', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold))])),
                    ),
                  ),
                ],
              ),
              child: ListTile(
                leading: CircleAvatar(backgroundColor: iconColor.withValues(alpha: 0.2), child: Icon(icon, color: iconColor, size: 20)),
                title: Text("$name - $label", style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text(timeStr),
              ),
            );
          },
        );
  }
}

// ----------------------------------------------------
// コート描画用の共通カスタムペインター（分析画面用）
// ----------------------------------------------------
class AnalysisCourtPainter extends CustomPainter {
  final List<Map<String, dynamic>> shots;

  AnalysisCourtPainter(this.shots);

  @override
  void paint(Canvas canvas, Size size) {
    final paintLine = Paint()..color = Colors.black54..style = PaintingStyle.stroke..strokeWidth = 2.0;
    final double scale = size.width / 15.0;
    Offset mToPx(double x, double y) => Offset(x * scale, y * scale);

    canvas.drawRect(Rect.fromLTRB(mToPx(5.05, 0).dx, mToPx(5.05, 0).dy, mToPx(9.95, 5.8).dx, mToPx(9.95, 5.8).dy), paintLine);
    canvas.drawArc(Rect.fromCircle(center: mToPx(7.5, 5.8), radius: 1.8 * scale), 0, 3.1415 * 2, false, paintLine);
    final hoopCenter = mToPx(7.5, 1.575);
    canvas.drawLine(mToPx(6.6, 1.2), mToPx(8.4, 1.2), paintLine..strokeWidth = 3.0);
    canvas.drawCircle(hoopCenter, 0.225 * scale, paintLine..color = Colors.deepOrange..strokeWidth = 3.0);
    paintLine.color = Colors.black54; paintLine.strokeWidth = 2.0;
    canvas.drawArc(Rect.fromCircle(center: hoopCenter, radius: 1.25 * scale), 0, 3.1415, false, paintLine);

    final path3p = Path();
    path3p.moveTo(mToPx(0.9, 0).dx, mToPx(0.9, 0).dy);
    path3p.lineTo(mToPx(0.9, 2.99).dx, mToPx(0.9, 2.99).dy);
    path3p.arcToPoint(mToPx(14.1, 2.99), radius: Radius.circular(6.75 * scale), clockwise: false);
    path3p.lineTo(mToPx(14.1, 0).dx, mToPx(14.1, 0).dy);
    canvas.drawPath(path3p, paintLine);

    for (var shot in shots) {
      if (shot['pos_x'] != null && shot['pos_y'] != null) {
        final dotPaint = Paint()..color = (shot['is_made'] == 1) ? Colors.deepOrange.withValues(alpha: 0.8) : Colors.grey.withValues(alpha: 0.6)..style = PaintingStyle.fill;
        canvas.drawCircle(Offset((shot['pos_x'] as double) * size.width, (shot['pos_y'] as double) * size.height), 5.0, dotPaint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class _EditStatDialog extends StatefulWidget {
  final Map<String, dynamic> stat;
  final List<Map<String, dynamic>> roster;
  final Function(String, Map<String, dynamic>) onSave;

  const _EditStatDialog({required this.stat, required this.roster, required this.onSave});

  @override
  State<_EditStatDialog> createState() => _EditStatDialogState();
}

class _EditStatDialogState extends State<_EditStatDialog> {
  late String _playerId;
  late String _action;
  late bool _isMade;
  double? _posX;
  double? _posY;

  final List<String> _actions = ['2P', '3P', 'FT', 'REB', 'AST', 'STL', 'BLK', 'TO', 'PF', 'SUB'];

  @override
  void initState() {
    super.initState();
    _playerId = widget.stat['player_id'].toString();
    _action = widget.stat['stat_type'];
    _isMade = widget.stat['is_made'] == 1;
    if (widget.stat['pos_x'] != null) _posX = (widget.stat['pos_x'] as num).toDouble();
    if (widget.stat['pos_y'] != null) _posY = (widget.stat['pos_y'] as num).toDouble();
  }

  @override
  Widget build(BuildContext context) {
    final bool isShot = _action == '2P' || _action == '3P' || _action == 'FT';
    final bool isFieldGoal = _action == '2P' || _action == '3P';

    return AlertDialog(
         backgroundColor: Colors.white,
      surfaceTintColor: Colors.transparent,
      title: const Text('アクションの修正', style: TextStyle(fontWeight: FontWeight.bold)),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('選手', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.grey)),
            DropdownButton<String>(
              isExpanded: true,
              value: widget.roster.any((p) => p['player_id'].toString() == _playerId) ? _playerId : null,
              items: widget.roster.map((p) {
                final name = p['court_name'] ?? p['last_name'];
                return DropdownMenuItem<String>(value: p['player_id'].toString(), child: Text(name));
              }).toList(),
              onChanged: (val) {
                if (val != null) setState(() => _playerId = val);
              },
            ),
            const SizedBox(height: 16),
            const Text('アクション', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.grey)),
            DropdownButton<String>(
              isExpanded: true,
              value: _action,
              items: _actions.map((a) => DropdownMenuItem(value: a, child: Text(a))).toList(),
              onChanged: (val) {
                if (val != null) setState(() => _action = val);
              },
            ),
            if (isShot) ...[
              const SizedBox(height: 16),
              const Text('結果', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.grey)),
              Row(
                children: [
                  Expanded(
                    child: RadioListTile<bool>(
                      title: const Text('成功'),
                      value: true,
                      groupValue: _isMade,
                      onChanged: (val) => setState(() => _isMade = val!),
                    ),
                  ),
                  Expanded(
                    child: RadioListTile<bool>(
                      title: const Text('失敗'),
                      value: false,
                      groupValue: _isMade,
                      onChanged: (val) => setState(() => _isMade = val!),
                    ),
                  ),
                ],
              ),
            ],
            if (isFieldGoal) ...[
              const SizedBox(height: 16),
              const Text('シュート位置 (タップして変更)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.grey)),
              const SizedBox(height: 8),
              Center(
                child: Container(
                  width: 250,
                  height: 250 * (14.0 / 15.0),
                  decoration: const BoxDecoration(color: Color(0xFFF6E8D7), border: Border(bottom: BorderSide(color: Colors.black54, width: 2))),
                  child: GestureDetector(
                    onTapDown: (details) {
                      setState(() {
                        _posX = (details.localPosition.dx / 250) * 15.0;
                        _posY = (details.localPosition.dy / (250 * (14.0 / 15.0))) * 14.0;
                      });
                    },
                    child: CustomPaint(
                      painter: _MiniCourtPainter(_posX, _posY, _isMade),
                      size: Size(250, 250 * (14.0 / 15.0)),
                    ),
                  ),
                ),
              ),
            ]
          ],
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('キャンセル', style: TextStyle(color: Colors.grey))),
        ElevatedButton(
          style: ElevatedButton.styleFrom(backgroundColor: Colors.deepOrange),
          onPressed: () {
            final data = {
              'player_id': _playerId,
              'stat_type': _action,
              'is_made': isShot ? (_isMade ? 1 : 0) : 0,
              'pos_x': isFieldGoal ? _posX : null,
              'pos_y': isFieldGoal ? _posY : null,
            };
            widget.onSave(widget.stat['id'].toString(), data);
            Navigator.pop(context);
          },
          child: const Text('保存', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        ),
      ],
    );
  }
}

class _MiniCourtPainter extends CustomPainter {
  final double? x;
  final double? y;
  final bool isMade;

  _MiniCourtPainter(this.x, this.y, this.isMade);

  @override
  void paint(Canvas canvas, Size size) {
    final paintLine = Paint()..color = Colors.black54..style = PaintingStyle.stroke..strokeWidth = 2.0;
    final double scale = size.width / 15.0;
    Offset mToPx(double x, double y) => Offset(x * scale, y * scale);

    canvas.drawRect(Rect.fromLTRB(mToPx(5.05, 0).dx, mToPx(5.05, 0).dy, mToPx(9.95, 5.8).dx, mToPx(9.95, 5.8).dy), paintLine);
    canvas.drawArc(Rect.fromCircle(center: mToPx(7.5, 5.8), radius: 1.8 * scale), 0, 3.1415 * 2, false, paintLine);
    final hoopCenter = mToPx(7.5, 1.575);
    canvas.drawLine(mToPx(6.6, 1.2), mToPx(8.4, 1.2), paintLine..strokeWidth = 3.0);
    canvas.drawCircle(hoopCenter, 0.225 * scale, paintLine..color = Colors.deepOrange..strokeWidth = 3.0);
    paintLine.color = Colors.black54; paintLine.strokeWidth = 2.0;
    canvas.drawArc(Rect.fromCircle(center: hoopCenter, radius: 1.25 * scale), 0, 3.1415, false, paintLine);
    final path3p = Path();
    path3p.moveTo(mToPx(0.9, 0).dx, mToPx(0.9, 0).dy);
    path3p.lineTo(mToPx(0.9, 2.99).dx, mToPx(0.9, 2.99).dy);
    path3p.arcToPoint(mToPx(14.1, 2.99), radius: Radius.circular(6.75 * scale), clockwise: false);
    path3p.lineTo(mToPx(14.1, 0).dx, mToPx(14.1, 0).dy);
    canvas.drawPath(path3p, paintLine);

    if (x != null && y != null) {
      final dotPaint = Paint()..color = isMade ? Colors.deepOrange : Colors.grey..style = PaintingStyle.fill;
      canvas.drawCircle(mToPx(x!, y!), 6.0, dotPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _MiniCourtPainter oldDelegate) {
    return oldDelegate.x != x || oldDelegate.y != y || oldDelegate.isMade != isMade;
  }
}
