import 'package:flutter/material.dart';
import 'stats_entry_screen.dart';

class GamesScreen extends StatefulWidget {
  const GamesScreen({super.key});

  @override
  State<GamesScreen> createState() => _GamesScreenState();
}

class _GamesScreenState extends State<GamesScreen> {
  // モックデータ：試合一覧
  final List<Map<String, dynamic>> _games = [
    {'opponent': '〇〇高校', 'date': '2026-10-01', 'is_u12': false, 'my_score': 24, 'opp_score': 20},
    {'opponent': '△△クラブ (練習試合)', 'date': '2026-10-05', 'is_u12': true, 'my_score': 45, 'opp_score': 40},
  ];

  // モックデータ：今シーズンの登録選手（ロスター）
  final List<String> _seasonRoster = [
    'タロウ', 'ジロウ', 'ケン', 'リョウ', 'ショウ',
    'シロー', 'ゴロウ', 'ハチロー', 'キュウ', 'ジュウ'
  ];

  // スタメン選択モーダルを表示する
  void _showStarterSelectionModal(Map<String, dynamic> game) {
    List<String> selectedStarters = [];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('スタメン選択 (5名)', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Text(
                      '現在 \${selectedStarters.length} 名選択中', 
                      style: TextStyle(
                        color: selectedStarters.length == 5 ? Colors.deepOrange : Colors.grey,
                        fontWeight: FontWeight.bold
                      )
                    ),
                    const SizedBox(height: 16),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _seasonRoster.map((player) {
                        final isSelected = selectedStarters.contains(player);
                        return FilterChip(
                          label: Text(player),
                          selected: isSelected,
                          selectedColor: Colors.deepOrange.shade100,
                          checkmarkColor: Colors.deepOrange,
                          onSelected: (bool selected) {
                            setModalState(() {
                              if (selected) {
                                // 5人までしか選べないようにする
                                if (selectedStarters.length < 5) {
                                  selectedStarters.add(player);
                                }
                              } else {
                                selectedStarters.remove(player);
                              }
                            });
                          },
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 32),
                    ElevatedButton(
                      // 5人選ばれていないとボタンを押せない
                      onPressed: selectedStarters.length == 5 ? () {
                        Navigator.pop(context); // モーダルを閉じる
                        
                        // ベンチメンバーを算出
                        final bench = _seasonRoster.where((p) => !selectedStarters.contains(p)).toList();
                        
                        // 選んだ5人をスタメンとして入力画面へ遷移
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => StatsEntryScreen(
                              opponentName: game['opponent'],
                              starters: selectedStarters,
                              bench: bench,
                            ),
                          ),
                        );
                      } : null,
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size.fromHeight(50),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        backgroundColor: Colors.deepOrange,
                      ),
                      child: const Text('試合開始（記録へ）', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                    )
                  ],
                ),
              ),
            );
          }
        );
      }
    );
  }

  // 試合追加の入力モーダル
  void _showAddGameModal() {
    final opponentCtrl = TextEditingController();
    final dateCtrl = TextEditingController(text: DateTime.now().toString().split(' ')[0]);
    bool isU12 = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
                left: 24, right: 24, top: 24
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('新規試合の作成', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  
                  TextField(
                    controller: opponentCtrl,
                    decoration: const InputDecoration(labelText: '対戦相手チーム名 *', border: OutlineInputBorder()),
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                  const SizedBox(height: 16),
                  
                  TextField(
                    controller: dateCtrl,
                    readOnly: true,
                    decoration: const InputDecoration(
                      labelText: '試合日', 
                      border: OutlineInputBorder(),
                      suffixIcon: Icon(Icons.calendar_today),
                    ),
                    onTap: () async {
                      final DateTime? picked = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime(2000),
                        lastDate: DateTime(2100),
                      );
                      if (picked != null) {
                        dateCtrl.text = "\${picked.year}-\${picked.month.toString().padLeft(2, '0')}-\${picked.day.toString().padLeft(2, '0')}";
                      }
                    },
                  ),
                  const SizedBox(height: 16),

                  // U12対象フラグのチェックボックス
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.deepOrange.shade50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.deepOrange.shade200),
                    ),
                    child: CheckboxListTile(
                      title: const Text('U12ルールを適用する', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                      value: isU12,
                      activeColor: Colors.deepOrange,
                      onChanged: (bool? value) {
                        setModalState(() {
                          isU12 = value ?? false;
                        });
                      },
                    ),
                  ),
                  const SizedBox(height: 24),
                  
                  ElevatedButton(
                    onPressed: () {
                      if (opponentCtrl.text.isEmpty) return;
                      setState(() {
                        _games.insert(0, {
                          'opponent': opponentCtrl.text,
                          'date': dateCtrl.text,
                          'is_u12': isU12,
                          'my_score': 0,
                          'opp_score': 0,
                        });
                      });
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepOrange,
                      minimumSize: const Size.fromHeight(50),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text('作成する', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            );
          }
        );
      }
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('SwishLog - 試合一覧', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        centerTitle: false,
      ),
      body: _games.isEmpty
        ? const Center(child: Text('まだ試合が登録されていません。\n右下の ＋ ボタンから作成してください。', textAlign: TextAlign.center))
        : ListView.builder(
            padding: const EdgeInsets.only(bottom: 80, top: 12),
            itemCount: _games.length,
            itemBuilder: (context, index) {
              final game = _games[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                elevation: 2,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: InkWell(
                  borderRadius: BorderRadius.circular(12),
                  // ★ここでスタメン選択モーダルを呼び出す
                  onTap: () => _showStarterSelectionModal(game),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              game['date'], 
                              style: const TextStyle(color: Colors.grey, fontSize: 12, fontWeight: FontWeight.bold)
                            ),
                            if (game['is_u12']) 
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(color: Colors.orange, borderRadius: BorderRadius.circular(4)),
                                child: const Text('U12', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                              )
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'vs ${game['opponent']}', 
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: Colors.black87)
                        ),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text('MY TEAM', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                            const SizedBox(width: 16),
                            Text('${game['my_score']}', style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.deepOrange)),
                            const Padding(padding: EdgeInsets.symmetric(horizontal: 12.0), child: Text('-', style: TextStyle(fontSize: 24, color: Colors.grey))),
                            Text('${game['opp_score']}', style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.black87)),
                            const SizedBox(width: 16),
                            const Text('OPPONENT', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                          ],
                        )
                      ],
                    ),
                  ),
                ),
              );
            }
          ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddGameModal,
        backgroundColor: Colors.deepOrange,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('新規試合', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
    );
  }
}
