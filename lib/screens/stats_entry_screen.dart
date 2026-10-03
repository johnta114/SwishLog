import 'package:flutter/material.dart';
import 'dart:math';
import '../database/database_helper.dart';
import '../utils/stat_actions.dart';


class StatsEntryScreen extends StatefulWidget {
  final String gameId;
  final String opponentName;
  final List<Map<String, dynamic>> starters;
  final List<Map<String, dynamic>> bench;

  const StatsEntryScreen({
    super.key,
    required this.gameId,
    required this.opponentName,
    required this.starters,
    required this.bench,
  });

  @override
  State<StatsEntryScreen> createState() => _StatsEntryScreenState();
}

class _StatsEntryScreenState extends State<StatsEntryScreen> {
  late List<Map<String, dynamic>> _activePlayers;
  late List<Map<String, dynamic>> _benchPlayers;
  late Map<String, dynamic> _selectedPlayer;

  final List<StatRecord> _logs = [];
  
  int _myScore = 0;
  int _oppScore = 0;
  int _currentQuarter = 1;
  bool _isU12 = false;

  @override
  void initState() {
    super.initState();
    _activePlayers = List.from(widget.starters);
    _benchPlayers = List.from(widget.bench);
    _selectedPlayer = _activePlayers.isNotEmpty ? _activePlayers.first : {};
    _loadScores();
  }

  Future<void> _loadScores() async {
    try {
      await DatabaseHelper.instance.updateGameScoreTotals(widget.gameId);
      final games = await DatabaseHelper.instance.getAllGames();
      final thisGame = games.firstWhere((g) => g['id'].toString() == widget.gameId);
      
      // DBから既存のログを取得
      final rawStats = await DatabaseHelper.instance.getRawStats(gameId: widget.gameId);
      final oppScores = await DatabaseHelper.instance.getOpponentScoresByGame(widget.gameId);

      final List<StatRecord> loadedLogs = [];

      for (var s in rawStats) {
        final type = s['stat_type'];
        final isMade = s['is_made'] == 1;
        String label = type;
        if (type == '2P' || type == '3P' || type == 'FG') label = "$type ${isMade ? '成功' : '失敗'}";
        else if (type == 'FT') label = "フリースロー ${isMade ? '成功' : '失敗'}";
        else if (type == 'REB') label = "リバウンド";
        else if (type == 'AST') label = "アシスト";
        else if (type == 'STL') label = "スティール";
        else if (type == 'TO') label = "ターンオーバー";
        else if (type == 'PF') label = "ファウル";
        else if (type == 'SUB') label = "交代でIN";

        loadedLogs.add(StatRecord(
          dbId: s['id'].toString(),
          isOpponent: false,
          playerName: s['court_name'] ?? s['last_name'],
          actionId: type,
          actionLabel: label,
          isMade: s['is_made'] != null ? isMade : null,
          x: s['pos_x'] != null ? (s['pos_x'] as num).toDouble() : null,
          y: s['pos_y'] != null ? (s['pos_y'] as num).toDouble() : null,
          time: s['created_at'] != null ? DateTime.parse(s['created_at']) : DateTime.now(),
        ));
      }

      for (var os in oppScores) {
        int? ms;
        try { ms = int.parse(os['id'].toString()); } catch (_) {}
        loadedLogs.add(StatRecord(
          dbId: os['id'].toString(),
          isOpponent: true,
          playerName: widget.opponentName,
          actionId: 'OPP',
          actionLabel: '相手得点 (+${os['points']})',
          time: ms != null ? DateTime.fromMillisecondsSinceEpoch(ms) : DateTime.now(),
        ));
      }

      // 時間順にソート
      loadedLogs.sort((a, b) => a.time.compareTo(b.time));

      if (mounted) {
        setState(() {
          _myScore = (thisGame['my_score'] as int?) ?? 0;
          _oppScore = (thisGame['opp_score'] as int?) ?? 0;
          _isU12 = (thisGame['is_u12'] == 1);
          _logs.clear();
          _logs.addAll(loadedLogs);
        });
      }
    } catch (e) {
      debugPrint("Error loading scores/logs: $e");
    }
  }

  Future<void> _undoLastAction() async {
    if (_logs.isEmpty) return;
    
    final removed = _logs.removeLast();
    
    if (removed.isOpponent) {
      await DatabaseHelper.instance.deleteOpponentScore(removed.dbId);
    } else {
      await DatabaseHelper.instance.deleteStat(removed.dbId);
    }
    
    await _loadScores();

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("${removed.playerName} の ${removed.actionLabel} を取り消しました"), duration: const Duration(seconds: 1)),
      );
    }
  }

  void _showLogs() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return SafeArea(
              child: Column(
                children: [
                  const Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Text('試合ログ（直近のアクション）', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  ),
                  Expanded(
                    child: _logs.isEmpty
                        ? const Center(child: Text('記録がありません'))
                        : ListView.builder(
                            itemCount: _logs.length,
                            itemBuilder: (context, index) {
                              final log = _logs[_logs.length - 1 - index];
                              final isMadeText = log.isMade == null ? '' : (log.isMade! ? ' (成功)' : ' (失敗)');
                              return ListTile(
                                leading: Icon(log.isOpponent ? Icons.warning : Icons.history, color: log.isOpponent ? Colors.red : Colors.grey),
                                title: Text("${log.playerName} - ${log.actionLabel}$isMadeText"),
                                subtitle: Text("${log.time.hour.toString().padLeft(2, '0')}:${log.time.minute.toString().padLeft(2, '0')}"),
                              );
                            },
                          ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _showSubstitutionDialog() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('選手交代', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
                const Text('ベンチに下げる選手を選択してください：'),
                Wrap(
                  spacing: 8,
                  children: _activePlayers.map((p) => ActionChip(
                    label: Text(p['court_name'] ?? p['last_name']),
                    onPressed: () {
                      Navigator.pop(context);
                      _showBenchPlayers(p);
                    },
                  )).toList(),
                )
              ],
            ),
          ),
        );
      },
    );
  }

  void _showBenchPlayers(Map<String, dynamic> playerOut) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("「${playerOut['court_name'] ?? playerOut['last_name']}」と交代で入る選手を選択：", style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 8,
                  children: _benchPlayers.map((p) => ActionChip(
                    label: Text(p['court_name'] ?? p['last_name']),
                    backgroundColor: Colors.deepOrange.shade100,
                    onPressed: () async {
                      final String inName = p['court_name'] ?? p['last_name'];
                      final String outName = playerOut['court_name'] ?? playerOut['last_name'];

                      // 交代のログをDBに記録
                      final dbId = await DatabaseHelper.instance.insertStat({
                        'game_id': widget.gameId,
                        'player_id': p['player_id'],
                        'quarter': _currentQuarter,
                        'stat_type': 'SUB',
                      });

                      setState(() {
                        _logs.add(StatRecord(
                          dbId: dbId,
                          isOpponent: false,
                          playerName: inName,
                          actionId: 'SUB',
                          actionLabel: 'IN (OUT: $outName)',
                          time: DateTime.now(),
                        ));

                        _activePlayers.remove(playerOut);
                        _benchPlayers.remove(p);
                        _activePlayers.add(p);
                        _benchPlayers.add(playerOut);
                        if (_selectedPlayer['player_id'] == playerOut['player_id']) _selectedPlayer = p;
                      });
                      if (mounted) Navigator.pop(context);
                    },
                  )).toList(),
                )
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _saveStatToDB({required String statType, bool? isMade, double? x, double? y}) async {
    final playerName = _selectedPlayer['court_name'] ?? _selectedPlayer['last_name'];
    
    // SQLiteへ保存しIDを取得
    final dbId = await DatabaseHelper.instance.insertStat({
      'game_id': widget.gameId,
      'player_id': _selectedPlayer['player_id'],
      'quarter': _currentQuarter,
      'stat_type': statType,
      'is_made': isMade != null ? (isMade ? 1 : 0) : null,
      'pos_x': x,
      'pos_y': y,
    });

    // UI用ログ追加
    setState(() {
      _logs.add(StatRecord(
        dbId: dbId,
        isOpponent: false,
        playerName: playerName,
        actionId: statType,
        actionLabel: StatActions.getLabel(statType),
        isMade: isMade, x: x, y: y, time: DateTime.now(),
      ));
    });
    
    if (isMade == true && (statType == '2P' || statType == '3P' || statType == 'FT')) {
      await _loadScores();
    }
  }

  void _recordFreeThrow() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text("${_selectedPlayer['court_name'] ?? _selectedPlayer['last_name']} のフリースロー", style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    OutlinedButton(
                      onPressed: () { _saveStatToDB(statType: 'FT', isMade: false); Navigator.pop(context); },
                      style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16)),
                      child: const Text('失敗 (Miss)', style: TextStyle(color: Colors.grey, fontSize: 16)),
                    ),
                    ElevatedButton(
                      onPressed: () { _saveStatToDB(statType: 'FT', isMade: true); Navigator.pop(context); },
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.deepOrange, padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16)),
                      child: const Text('成功 (Made)', style: TextStyle(color: Colors.white, fontSize: 16)),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _handleCourtTap(TapDownDetails details, Size courtSize) {
    final double dx = details.localPosition.dx / courtSize.width;
    final double dy = details.localPosition.dy / courtSize.height;

    final double x_m = dx * 15.0;
    final double y_m = dy * 14.0;
    final double distance = sqrt(pow(x_m - 7.5, 2) + pow(y_m - 1.575, 2));
    final bool is3P = !_isU12 && distance >= 6.75 && y_m >= 2.99;
    final String statType = is3P ? '3P' : '2P';

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text("${_selectedPlayer['court_name'] ?? _selectedPlayer['last_name']} のシュート ($statType)", style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    OutlinedButton(
                      onPressed: () { _saveStatToDB(statType: statType, isMade: false, x: dx, y: dy); Navigator.pop(context); },
                      style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16)),
                      child: const Text('失敗 (Miss)', style: TextStyle(color: Colors.grey, fontSize: 16)),
                    ),
                    ElevatedButton(
                      onPressed: () { _saveStatToDB(statType: statType, isMade: true, x: dx, y: dy); Navigator.pop(context); },
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.deepOrange, padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16)),
                      child: const Text('成功 (Made)', style: TextStyle(color: Colors.white, fontSize: 16)),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showOpponentScoreModal() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text("相手チーム (${widget.opponentName}) の得点", style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildOpponentScoreBtn(1, 'FT'),
                    _buildOpponentScoreBtn(2, 'FG'),
                    if (!_isU12) _buildOpponentScoreBtn(3, '3P'),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildOpponentScoreBtn(int pts, String label) {
    return ElevatedButton(
      onPressed: () async {
        final dbId = await DatabaseHelper.instance.insertOpponentScore({'game_id': widget.gameId, 'opponent_player_id': 'unknown', 'points': pts});
        setState(() {
          _logs.add(StatRecord(
            dbId: dbId, isOpponent: true, playerName: widget.opponentName, actionId: 'OPP', actionLabel: '相手得点 (+$pts)', time: DateTime.now()
          ));
        });
        await _loadScores();
        if (mounted) Navigator.pop(context);
      },
      style: ElevatedButton.styleFrom(backgroundColor: Colors.black87), 
      child: Text("+$pts $label", style: const TextStyle(color: Colors.white)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('SwishLog', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)), 
        centerTitle: false, 
        toolbarHeight: 48,
        actions: [
          TextButton.icon(
            onPressed: () async {
              // 試合終了処理
              await DatabaseHelper.instance.updateGameStatus(widget.gameId, 'completed');
              if (mounted) Navigator.pop(context); // 試合一覧へ戻る
            },
            icon: const Icon(Icons.check_circle, color: Colors.white),
            label: const Text('試合終了', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            style: TextButton.styleFrom(foregroundColor: Colors.white),
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(vertical: 4),
            color: Colors.white,
            child: Column(
              children: [
                Text("vs ${widget.opponentName}", style: const TextStyle(fontSize: 12, color: Colors.black54)),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    const Text('MY TEAM', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                    Text('$_myScore - $_oppScore', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 24, color: Colors.deepOrange)),
                    GestureDetector(
                      onTap: _showOpponentScoreModal,
                      child: Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4), decoration: BoxDecoration(color: Colors.black87, borderRadius: BorderRadius.circular(4)), child: const Text('相手得点＋', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 10, color: Colors.white))),
                    ),
                  ],
                ),
                // クォーター切り替えUI
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [1, 2, 3, 4].map((q) => Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: ChoiceChip(
                        label: Text("$q Q", style: const TextStyle(fontSize: 12)),
                        selected: _currentQuarter == q,
                        onSelected: (selected) {
                          if (selected) setState(() => _currentQuarter = q);
                        },
                        selectedColor: Colors.deepOrange.shade100,
                        showCheckmark: false,
                        visualDensity: VisualDensity.compact,
                      ),
                    )).toList(),
                  ),
                ),
              ],
            ),
          ),
          
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
            color: Colors.blueGrey.shade50,
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    _logs.isEmpty ? '▶ まだ記録はありません' : "▶ 最新: ${_logs.last.playerName} - ${_logs.last.actionLabel} ${_logs.last.isMade == null ? '' : (_logs.last.isMade! ? '(成功)' : '(失敗)')}",
                    style: const TextStyle(color: Colors.black54, fontWeight: FontWeight.bold, fontSize: 13),
                    maxLines: 1, overflow: TextOverflow.ellipsis,
                  ),
                ),
                // 復活させたUndoボタンとログボタン
                IconButton(
                  icon: const Icon(Icons.undo, size: 20, color: Colors.black87),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  onPressed: _logs.isEmpty ? null : _undoLastAction,
                  tooltip: '直前を取り消す'
                ),
                const SizedBox(width: 16),
                IconButton(
                  icon: const Icon(Icons.list_alt, size: 20, color: Colors.black87),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  onPressed: _showLogs,
                  tooltip: '試合ログ'
                ),
                const SizedBox(width: 8),
              ],
            ),
          ),

          Expanded(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: AspectRatio(
                  aspectRatio: 15.0 / 14.0,
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final courtSize = Size(constraints.maxWidth, constraints.maxHeight);
                      return GestureDetector(
                        onTapDown: (details) => _handleCourtTap(details, courtSize),
                        child: Container(
                          decoration: const BoxDecoration(color: Color(0xFFF6E8D7), border: Border(bottom: BorderSide(color: Colors.black54, width: 2))),
                          child: CustomPaint(size: courtSize, painter: CourtPainter(_logs)),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
          ),

          Container(
            padding: const EdgeInsets.all(4.0),
            color: Colors.white,
            child: Column(
              children: [
                Row(
                  children: [
                    _buildStatBtn('FT', isPrimary: true),
                    _buildStatBtn('REB'),
                    _buildStatBtn('AST'),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    _buildStatBtn('STL'),
                    _buildStatBtn('TO'),
                    _buildStatBtn('PF'),
                  ],
                ),
              ],
            ),
          ),

          SafeArea(
            top: false,
            child: Container(
              height: 60,
              color: Colors.grey.shade100,
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
              child: Row(
                children: [
                  ..._activePlayers.map((player) {
                    final isSelected = player['player_id'] == _selectedPlayer['player_id'];
                    final name = player['court_name'] ?? player['last_name'];
                    return Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() => _selectedPlayer = player),
                        child: Container(
                          margin: const EdgeInsets.symmetric(horizontal: 2),
                          decoration: BoxDecoration(color: isSelected ? Colors.deepOrange : Colors.white, border: Border.all(color: isSelected ? Colors.deepOrange : Colors.grey.shade400), borderRadius: BorderRadius.circular(6)),
                          child: Center(
                            child: Text(name, style: TextStyle(fontSize: 12, color: isSelected ? Colors.white : Colors.black87, fontWeight: isSelected ? FontWeight.bold : FontWeight.normal), maxLines: 1, overflow: TextOverflow.ellipsis),
                          ),
                        ),
                      ),
                    );
                  }),
                  Container(
                    width: 44, margin: const EdgeInsets.only(left: 4),
                    child: IconButton(onPressed: _showSubstitutionDialog, icon: const Icon(Icons.change_circle, size: 28, color: Colors.blueGrey), padding: EdgeInsets.zero),
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatBtn(String actionId, {bool isPrimary = false}) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 2.0),
        child: ElevatedButton(
          onPressed: () {
            if (actionId == 'FT') {
              _recordFreeThrow();
            } else {
              _saveStatToDB(statType: actionId);
            }
          },
          style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 12), backgroundColor: isPrimary ? Colors.deepOrange.shade100 : Colors.grey.shade200, foregroundColor: Colors.black87, elevation: 0, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6))),
          child: Text(StatActions.getLabel(actionId), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13), maxLines: 1, overflow: TextOverflow.ellipsis),
        ),
      ),
    );
  }
}

class StatRecord {
  final String dbId;
  final bool isOpponent;
  final String playerName;
  final String actionId;
  final String actionLabel;
  final bool? isMade;
  final double? x;
  final double? y;
  final DateTime time;

  StatRecord({required this.dbId, required this.isOpponent, required this.playerName, required this.actionId, required this.actionLabel, this.isMade, this.x, this.y, required this.time});
}

class CourtPainter extends CustomPainter {
  final List<StatRecord> logs;

  CourtPainter(this.logs);

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

    for (var log in logs.where((e) => (e.actionId == '2P' || e.actionId == '3P') && e.x != null && e.y != null)) {
      final dotPaint = Paint()..color = log.isMade == true ? Colors.deepOrange : Colors.grey..style = PaintingStyle.fill;
      canvas.drawCircle(Offset(log.x! * size.width, log.y! * size.height), 6.0, dotPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
