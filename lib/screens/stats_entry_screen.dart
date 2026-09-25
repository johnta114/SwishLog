import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

class StatsEntryScreen extends StatefulWidget {
  final String opponentName;
  final List<String> starters;
  final List<String> bench;

  const StatsEntryScreen({
    super.key,
    required this.opponentName,
    required this.starters,
    required this.bench,
  });

  @override
  State<StatsEntryScreen> createState() => _StatsEntryScreenState();
}

class _StatsEntryScreenState extends State<StatsEntryScreen> {
  // 選手データ（前画面から受け取ったスタメンとベンチをセット）
  late List<String> _activePlayers;
  late List<String> _benchPlayers;
  late String _selectedPlayer;

  // 試合の全スタッツログ
  final List<StatRecord> _logs = [];
  final _uuid = const Uuid();

  @override
  void initState() {
    super.initState();
    // 受け取ったリストを元に状態を初期化
    _activePlayers = List.from(widget.starters);
    _benchPlayers = List.from(widget.bench);
    _selectedPlayer = _activePlayers.isNotEmpty ? _activePlayers.first : '';
  }

  // 直前のアクションを取り消す（Undo）
  void _undoLastAction() {
    if (_logs.isEmpty) return;
    setState(() {
      final removed = _logs.removeLast();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${removed.player}の ${removed.actionLabel} を取り消しました'), duration: const Duration(seconds: 1)),
      );
    });
  }

  // 試合ログを表示し、個別に削除（修正）する
  void _showLogs() {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return SafeArea(
              child: Column(
                children: [
                  const Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Text('試合ログ（修正・削除）', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
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
                                leading: const Icon(Icons.history),
                                title: Text('${log.player} - ${log.actionLabel}$isMadeText'),
                                subtitle: Text(log.time.toString().substring(11, 19)),
                                trailing: IconButton(
                                  icon: const Icon(Icons.delete, color: Colors.red),
                                  onPressed: () {
                                    setState(() => _logs.removeWhere((e) => e.id == log.id));
                                    setModalState(() {});
                                  },
                                ),
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

  // 選手交代のUI
  void _showSubstitutionDialog() {
    showModalBottomSheet(
      context: context,
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
                    label: Text(p),
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

  void _showBenchPlayers(String playerOut) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('「$playerOut」と交代で入る選手を選択：', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 8,
                  children: _benchPlayers.map((p) => ActionChip(
                    label: Text(p),
                    backgroundColor: Colors.deepOrange.shade100,
                    onPressed: () {
                      setState(() {
                        _activePlayers.remove(playerOut);
                        _benchPlayers.remove(p);
                        _activePlayers.add(p);
                        _benchPlayers.add(playerOut);
                        if (_selectedPlayer == playerOut) _selectedPlayer = p;
                        _addLog(player: '交代', actionId: 'SUB', actionLabel: '$playerOut OUT, $p IN');
                      });
                      Navigator.pop(context);
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

  // 汎用のログ追加メソッド
  void _addLog({required String player, required String actionId, required String actionLabel, bool? isMade, double? x, double? y}) {
    setState(() {
      _logs.add(StatRecord(
        id: _uuid.v4(),
        player: player,
        actionId: actionId,
        actionLabel: actionLabel,
        isMade: isMade,
        x: x,
        y: y,
        time: DateTime.now(),
      ));
    });
  }

  // フリースロー入力
  void _recordFreeThrow() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('$_selectedPlayer のフリースロー', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    OutlinedButton(
                      onPressed: () { _addLog(player: _selectedPlayer, actionId: 'FT', actionLabel: 'フリースロー', isMade: false); Navigator.pop(context); },
                      style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16)),
                      child: const Text('失敗 (Miss)', style: TextStyle(color: Colors.grey, fontSize: 16)),
                    ),
                    ElevatedButton(
                      onPressed: () { _addLog(player: _selectedPlayer, actionId: 'FT', actionLabel: 'フリースロー', isMade: true); Navigator.pop(context); },
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

  // コートタップ時（フィールドゴール）の処理
  void _handleCourtTap(TapDownDetails details, Size courtSize) {
    final double dx = details.localPosition.dx / courtSize.width;
    final double dy = details.localPosition.dy / courtSize.height;

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('$_selectedPlayer のシュート結果', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    OutlinedButton(
                      onPressed: () { _addLog(player: _selectedPlayer, actionId: 'FG', actionLabel: 'シュート', isMade: false, x: dx, y: dy); Navigator.pop(context); },
                      style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16)),
                      child: const Text('失敗 (Miss)', style: TextStyle(color: Colors.grey, fontSize: 16)),
                    ),
                    ElevatedButton(
                      onPressed: () { _addLog(player: _selectedPlayer, actionId: 'FG', actionLabel: 'シュート', isMade: true, x: dx, y: dy); Navigator.pop(context); },
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('SwishLog', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        centerTitle: false,
        toolbarHeight: 48,
      ),
      body: Column(
        children: [
          // 1. スコア表示（前画面で選んだ対戦相手の名前を動的に表示）
          Container(
            padding: const EdgeInsets.symmetric(vertical: 4),
            color: Colors.white,
            child: Column(
              children: [
                Text('vs ${widget.opponentName}', style: const TextStyle(fontSize: 12, color: Colors.black54)),
                const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Text('MY TEAM', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                    Text('0 - 0', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24, color: Colors.deepOrange)),
                    Text('OPPONENT', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                  ],
                ),
              ],
            ),
          ),
          
          // 2. 直前のアクションログ ＋ Undo ＆ ログボタン
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
            color: Colors.blueGrey.shade50,
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    _logs.isEmpty 
                      ? '▶ まだ記録はありません' 
                      : '▶ 最新: ${_logs.last.player} - ${_logs.last.actionLabel} ${_logs.last.isMade == null ? "" : (_logs.last.isMade! ? "(成功)" : "(失敗)")}',
                    style: const TextStyle(color: Colors.black54, fontWeight: FontWeight.bold, fontSize: 13),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
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

          // 3. コート図
          Expanded(
            child: Center(
              child: AspectRatio(
                aspectRatio: 15.0 / 14.0,
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final courtSize = Size(constraints.maxWidth, constraints.maxHeight);
                    return GestureDetector(
                      onTapDown: (details) => _handleCourtTap(details, courtSize),
                      child: Container(
                        decoration: BoxDecoration(
                          color: const Color(0xFFF6E8D7),
                          border: const Border(bottom: BorderSide(color: Colors.black54, width: 2)),
                        ),
                        child: CustomPaint(
                          size: courtSize,
                          painter: CourtPainter(_logs),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ),

          // 4. アクションボタン群
          Container(
            padding: const EdgeInsets.all(4.0),
            color: Colors.white,
            child: Column(
              children: [
                Row(
                  children: [
                    _buildStatBtn('フリースロー', 'FT', isPrimary: true),
                    _buildStatBtn('リバウンド', 'REB'),
                    _buildStatBtn('アシスト', 'AST'),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    _buildStatBtn('スティール', 'STL'),
                    _buildStatBtn('ターンオーバー', 'TO'),
                    _buildStatBtn('ファウル', 'PF'),
                  ],
                ),
              ],
            ),
          ),

          // 5. 選手選択＆交代（スクロールなしで5名等分配置）
          Container(
            height: 60,
            color: Colors.grey.shade100,
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
            child: Row(
              children: [
                ..._activePlayers.map((player) {
                  final isSelected = player == _selectedPlayer;
                  return Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _selectedPlayer = player),
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 2),
                        decoration: BoxDecoration(
                          color: isSelected ? Colors.deepOrange : Colors.white,
                          border: Border.all(color: isSelected ? Colors.deepOrange : Colors.grey.shade400),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Center(
                          child: Text(
                            player,
                            style: TextStyle(
                              fontSize: 12, // 名前が長い場合も入りやすくする
                              color: isSelected ? Colors.white : Colors.black87,
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                    ),
                  );
                }),
                // 交代ボタン
                Container(
                  width: 44,
                  margin: const EdgeInsets.only(left: 4),
                  child: IconButton(
                    onPressed: _showSubstitutionDialog,
                    icon: const Icon(Icons.change_circle, size: 28, color: Colors.blueGrey),
                    padding: EdgeInsets.zero,
                    tooltip: '選手交代',
                  ),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }

  // 同じサイズに揃えたアクションボタンの生成メソッド
  Widget _buildStatBtn(String label, String actionId, {bool isPrimary = false}) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 2.0),
        child: ElevatedButton(
          onPressed: () {
            if (actionId == 'FT') {
              _recordFreeThrow();
            } else {
              _addLog(player: _selectedPlayer, actionId: actionId, actionLabel: label);
            }
          },
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 12),
            backgroundColor: isPrimary ? Colors.deepOrange.shade100 : Colors.grey.shade200,
            foregroundColor: Colors.black87,
            elevation: 0,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
          ),
          child: Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ),
    );
  }
}

// 汎用スタッツ記録クラス
class StatRecord {
  final String id;
  final String player;
  final String actionId;
  final String actionLabel;
  final bool? isMade;
  final double? x;
  final double? y;
  final DateTime time;

  StatRecord({required this.id, required this.player, required this.actionId, required this.actionLabel, this.isMade, this.x, this.y, required this.time});
}

// コート描画クラス（ゴールが上のレイアウト）
class CourtPainter extends CustomPainter {
  final List<StatRecord> logs;

  CourtPainter(this.logs);

  @override
  void paint(Canvas canvas, Size size) {
    final paintLine = Paint()
      ..color = Colors.black54
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    const double courtWidthM = 15.0; 
    const double halfCourtLengthM = 14.0; 
    final double scale = size.width / courtWidthM;

    Offset mToPx(double x, double y) {
      return Offset(x * scale, y * scale);
    }

    final keyRect = Rect.fromLTRB(
      mToPx((15.0 - 4.9) / 2, 0).dx,
      mToPx((15.0 - 4.9) / 2, 0).dy,
      mToPx(15.0 - (15.0 - 4.9) / 2, 5.8).dx,
      mToPx(15.0 - (15.0 - 4.9) / 2, 5.8).dy,
    );
    canvas.drawRect(keyRect, paintLine);

    final ftCenter = mToPx(7.5, 5.8);
    canvas.drawArc(Rect.fromCircle(center: ftCenter, radius: 1.8 * scale), 0, 3.1415 * 2, false, paintLine);

    final hoopCenter = mToPx(7.5, 1.575);
    canvas.drawLine(
      mToPx(7.5 - 0.9, 1.2), 
      mToPx(7.5 + 0.9, 1.2), 
      paintLine..strokeWidth = 3.0
    );
    canvas.drawCircle(hoopCenter, 0.225 * scale, paintLine..color = Colors.deepOrange..strokeWidth = 3.0);
    paintLine.color = Colors.black54;
    paintLine.strokeWidth = 2.0;

    final ncRect = Rect.fromCircle(center: hoopCenter, radius: 1.25 * scale);
    canvas.drawArc(ncRect, 0, 3.1415, false, paintLine);

    final path3p = Path();
    path3p.moveTo(mToPx(0.9, 0).dx, mToPx(0.9, 0).dy);
    path3p.lineTo(mToPx(0.9, 2.99).dx, mToPx(0.9, 2.99).dy);
    path3p.arcToPoint(
      mToPx(14.1, 2.99), 
      radius: Radius.circular(6.75 * scale), 
      clockwise: false
    );
    path3p.lineTo(mToPx(14.1, 0).dx, mToPx(14.1, 0).dy);
    canvas.drawPath(path3p, paintLine);

    for (var log in logs.where((e) => e.actionId == 'FG' && e.x != null && e.y != null)) {
      final dotPaint = Paint()
        ..color = log.isMade == true ? Colors.deepOrange : Colors.grey
        ..style = PaintingStyle.fill;
      canvas.drawCircle(Offset(log.x! * size.width, log.y! * size.height), 6.0, dotPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
