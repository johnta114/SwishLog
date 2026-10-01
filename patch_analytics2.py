with open('lib/screens/analytics_screen.dart', 'r') as f:
    content = f.read()

dialog_code = """
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
"""

if "_showEditStatDialog" not in content:
    # Insert it before the last closing brace of _AnalyticsScreenState
    parts = content.rsplit('}', 1)
    # Actually wait, _AnalyticsScreenState ends right before `class _EditStatDialog`. 
    # Let's find the end of `_buildPlayLogsTab()`
    content = content.replace("  Widget _buildPlayLogsTab() {", dialog_code + "\n  Widget _buildPlayLogsTab() {")

widgets_code = """
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
                  decoration: BoxDecoration(border: Border.all(color: Colors.grey)),
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
    final paintLine = Paint()..color = Colors.black26..style = PaintingStyle.stroke..strokeWidth = 2.0;
    final double scale = size.width / 15.0;
    Offset mToPx(double x, double y) => Offset(x * scale, y * scale);

    // Court lines
    canvas.drawRect(Rect.fromLTRB(mToPx(5.05, 0).dx, mToPx(5.05, 0).dy, mToPx(9.95, 5.8).dx, mToPx(9.95, 5.8).dy), paintLine);
    canvas.drawArc(Rect.fromCircle(center: mToPx(7.5, 5.8), radius: 1.8 * scale), 0, 3.1415 * 2, false, paintLine);
    final hoopCenter = mToPx(7.5, 1.575);
    canvas.drawLine(mToPx(6.6, 1.2), mToPx(8.4, 1.2), paintLine..strokeWidth = 3.0);
    canvas.drawCircle(hoopCenter, 0.225 * scale, paintLine..color = Colors.deepOrange.withOpacity(0.5)..strokeWidth = 3.0);
    paintLine.color = Colors.black26; paintLine.strokeWidth = 2.0;
    canvas.drawArc(Rect.fromCircle(center: hoopCenter, radius: 1.25 * scale), 0, 3.1415, false, paintLine);
    final path3p = Path();
    path3p.moveTo(mToPx(0.9, 0).dx, mToPx(0.9, 0).dy);
    path3p.lineTo(mToPx(0.9, 2.99).dx, mToPx(0.9, 2.99).dy);
    path3p.arcToPoint(mToPx(14.1, 2.99), radius: Radius.circular(6.75 * scale), clockwise: false);
    path3p.lineTo(mToPx(14.1, 0).dx, mToPx(14.1, 0).dy);
    canvas.drawPath(path3p, paintLine);

    // Draw point
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
"""

if "_EditStatDialog" not in content:
    content += widgets_code

with open('lib/screens/analytics_screen.dart', 'w') as f:
    f.write(content)
