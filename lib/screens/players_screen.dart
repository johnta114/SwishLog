import 'package:flutter/material.dart';

class PlayersScreen extends StatefulWidget {
  const PlayersScreen({super.key});

  @override
  State<PlayersScreen> createState() => _PlayersScreenState();
}

class _PlayersScreenState extends State<PlayersScreen> {
  // ブラウザ(Chrome)での動作確認用に、一時的にメモリ上で管理するリスト
  // 実際のスマホアプリ化の際は、ここで DatabaseHelper を呼び出して保存します。
  final List<Map<String, String>> _players = [
    {'last_name': '山田', 'first_name': '太郎', 'court_name': 'タロウ', 'birth_date': '2010-04-01'},
    {'last_name': '佐藤', 'first_name': '次郎', 'court_name': 'ジロウ', 'birth_date': '2011-08-15'},
  ];

  // 選手追加の入力モーダルを表示
  void _showAddPlayerModal() {
    final lastCtrl = TextEditingController();
    final firstCtrl = TextEditingController();
    final courtCtrl = TextEditingController();
    final birthCtrl = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          // キーボードが表示された際に隠れないように余白を確保
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            left: 24, right: 24, top: 24
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('新規選手登録', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              
              Row(
                children: [
                  Expanded(child: TextField(controller: lastCtrl, decoration: const InputDecoration(labelText: '氏（苗字）', border: OutlineInputBorder()))),
                  const SizedBox(width: 16),
                  Expanded(child: TextField(controller: firstCtrl, decoration: const InputDecoration(labelText: '名', border: OutlineInputBorder()))),
                ],
              ),
              const SizedBox(height: 16),
              
              TextField(
                controller: courtCtrl, 
                decoration: const InputDecoration(labelText: 'コートネーム *', border: OutlineInputBorder()),
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18), // コートネームを強調
              ),
              const SizedBox(height: 16),
              
              TextField(
                controller: birthCtrl,
                readOnly: true, // キーボードを出さない
                decoration: const InputDecoration(
                  labelText: '誕生日', 
                  border: OutlineInputBorder(), 
                  hintText: 'カレンダーから選択',
                  suffixIcon: Icon(Icons.calendar_today),
                ),
                onTap: () async {
                  // カレンダーピッカーを表示
                  final DateTime? picked = await showDatePicker(
                    context: context,
                    initialDate: DateTime(2012, 1, 1), // U12を想定して初期値を2012年付近に
                    firstDate: DateTime(1950),
                    lastDate: DateTime.now(),
                  );
                  if (picked != null) {
                    // YYYY-MM-DD 形式でテキストフィールドにセット
                    birthCtrl.text = "\${picked.year}-\${picked.month.toString().padLeft(2, '0')}-\${picked.day.toString().padLeft(2, '0')}";
                  }
                },
              ),
              const SizedBox(height: 24),
              
              ElevatedButton(
                onPressed: () {
                  if (courtCtrl.text.isEmpty) return; // コートネーム必須
                  setState(() {
                    _players.add({
                      'last_name': lastCtrl.text,
                      'first_name': firstCtrl.text,
                      'court_name': courtCtrl.text,
                      'birth_date': birthCtrl.text,
                    });
                  });
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepOrange,
                  minimumSize: const Size.fromHeight(50),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('登録する', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
              ),
              const SizedBox(height: 24),
            ],
          ),
        );
      }
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('SwishLog - 選手一覧', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        centerTitle: false,
      ),
      body: _players.isEmpty
        ? const Center(
            child: Text('まだ選手が登録されていません。\n右下の ＋ ボタンから登録してください。', textAlign: TextAlign.center)
          )
        : ListView.builder(
            padding: const EdgeInsets.only(bottom: 80, top: 12),
            itemCount: _players.length,
            itemBuilder: (context, index) {
              final p = _players[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                elevation: 1,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  leading: CircleAvatar(
                    backgroundColor: Colors.deepOrange.shade50,
                    radius: 28,
                    child: Text(
                      p['court_name']!.substring(0, 1), // コートネームの1文字目
                      style: const TextStyle(color: Colors.deepOrange, fontWeight: FontWeight.bold, fontSize: 20),
                    ),
                  ),
                  // 方針通り、コートネームをメインで一番大きく表示する
                  title: Text(
                    p['court_name']!, 
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 22, color: Colors.black87)
                  ),
                  subtitle: Padding(
                    padding: const EdgeInsets.only(top: 4.0),
                    child: Text(
                      '${p['last_name']} ${p['first_name']}  |  誕生日: ${p['birth_date']}',
                      style: const TextStyle(fontSize: 13),
                    ),
                  ),
                  trailing: const Icon(Icons.edit, color: Colors.grey),
                  onTap: () {
                    // タップで編集画面（今後の実装）
                  },
                ),
              );
            }
          ),
      // 右下の追加ボタン
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddPlayerModal,
        backgroundColor: Colors.deepOrange,
        icon: const Icon(Icons.person_add, color: Colors.white),
        label: const Text('追加', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
    );
  }
}
