import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_settings_provider.dart';
import '../database/database_helper.dart';
import '../utils/stat_actions.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  List<Map<String, dynamic>> _seasons = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSeasons();
  }

  Future<void> _loadSeasons() async {
    final seasons = await DatabaseHelper.instance.getSeasons();
    if (mounted) {
      setState(() {
        _seasons = seasons;
        _isLoading = false;
      });
    }
  }

  Widget _getActionIcon(String actionId) {
    IconData icon;
    Color color = Colors.blueGrey;
    switch (actionId) {
      case 'FT':
        icon = Icons.adjust;
        color = Colors.deepOrange;
        break;
      case 'REB':
        icon = Icons.back_hand;
        color = Colors.blue;
        break;
      case 'AST':
        icon = Icons.handshake;
        color = Colors.green;
        break;
      case 'STL':
        icon = Icons.pan_tool;
        color = Colors.teal;
        break;
      case 'TO':
        icon = Icons.swap_horiz;
        color = Colors.deepPurple;
        break;
      case 'PF':
        icon = Icons.error_outline;
        color = Colors.redAccent;
        break;
      default:
        icon = Icons.sports_basketball;
    }
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
      child: Icon(icon, color: color, size: 20),
    );
  }

  void _confirmDeleteGames() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        title: const Row(
          children: [
            Icon(Icons.delete_sweep, color: Colors.orange),
            SizedBox(width: 8),
            Text('試合記録の全削除', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
          ],
        ),
        content: const Text(
          'これまでに記録されたすべての試合データとスタッツを削除しますか？\n\n※この操作は取り消せません。\n※チーム、選手、対戦相手情報は保持されます。',
          style: TextStyle(fontSize: 14, height: 1.5),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('キャンセル', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
            onPressed: () async {
              final nav = Navigator.of(context);
              final messenger = ScaffoldMessenger.of(context);
              await DatabaseHelper.instance.deleteAllGames();
              nav.pop();
              messenger.showSnackBar(
                const SnackBar(content: Text('すべての試合記録を削除しました')),
              );
            },
            child: const Text('削除する', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  void _confirmResetAllData() {
    final settingsProvider = Provider.of<AppSettingsProvider>(context, listen: false);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        title: const Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: Colors.red),
            SizedBox(width: 8),
            Text('全データの初期化', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.red)),
          ],
        ),
        content: const Text(
          'アプリ内のすべてのデータ（シーズン、選手、対戦相手、試合記録、スタッツ）を完全に消去し、初期状態にリセットしますか？\n\n※この操作を実行するとすべてのデータが失われ、元に戻すことはできません。',
          style: TextStyle(fontSize: 14, height: 1.5),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('キャンセル', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              final nav = Navigator.of(context);
              final messenger = ScaffoldMessenger.of(context);
              await DatabaseHelper.instance.resetAllData();
              await settingsProvider.resetAllSettings();
              await _loadSeasons();
              nav.pop();
              messenger.showSnackBar(
                const SnackBar(content: Text('すべてのデータを初期化しました')),
              );
            },
            child: const Text('初期化する', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final settingsProvider = Provider.of<AppSettingsProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('設定', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              children: [
                const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Text(
                    'シーズン設定',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.deepOrange),
                  ),
                ),
                ListTile(
                  leading: const Icon(Icons.calendar_today),
                  title: const Text('アクティブなシーズン'),
                  subtitle: const Text('ホーム画面などで表示されるデフォルトのシーズン'),
                  trailing: DropdownButton<String>(
                    value: _seasons.any((s) => s['id'] == settingsProvider.activeSeasonId) 
                        ? settingsProvider.activeSeasonId 
                        : null,
                    hint: const Text('未設定'),
                    underline: const SizedBox(),
                    items: _seasons.map((s) {
                      return DropdownMenuItem<String>(
                        value: s['id'].toString(),
                        child: Text(s['name'] ?? ''),
                      );
                    }).toList(),
                    onChanged: (newSeasonId) {
                      if (newSeasonId != null) {
                        settingsProvider.setActiveSeason(newSeasonId);
                      }
                    },
                  ),
                ),
                const Divider(),
                const Padding(
                  padding: EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 4.0),
                  child: Text(
                    '記録するアクション',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.deepOrange),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
                  child: Text(
                    '試合記録画面で記録したいアクションを選択してください。オフにしたアクションのボタンは無効になります。',
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                  ),
                ),
                const SizedBox(height: 8),
                ...AppSettingsProvider.configurableActions.map((actionId) {
                  final isEnabled = settingsProvider.isActionEnabled(actionId);
                  return SwitchListTile(
                    title: Text(StatActions.getLabel(actionId), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                    subtitle: Text('「${StatActions.getLabel(actionId)}」の記録ボタンを${isEnabled ? '有効' : '無効'}', style: const TextStyle(fontSize: 12, color: Colors.grey)),
                    secondary: _getActionIcon(actionId),
                    value: isEnabled,
                    activeThumbColor: Colors.deepOrange,
                    onChanged: (val) {
                      settingsProvider.toggleAction(actionId, val);
                    },
                  );
                }),
                const Divider(),
                const Padding(
                  padding: EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 4.0),
                  child: Text(
                    'データ管理',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.redAccent),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
                  child: Text(
                    'データの削除や初期化を行います。削除したデータは復元できません。',
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                  ),
                ),
                const SizedBox(height: 8),
                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(color: Colors.orange.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
                    child: const Icon(Icons.delete_sweep, color: Colors.orange, size: 20),
                  ),
                  title: const Text('試合記録のみ全削除', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                  subtitle: const Text('全試合データとスタッツを削除（選手やチームは保持）', style: TextStyle(fontSize: 12, color: Colors.grey)),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey),
                  onTap: _confirmDeleteGames,
                ),
                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(color: Colors.red.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
                    child: const Icon(Icons.warning_amber_rounded, color: Colors.red, size: 20),
                  ),
                  title: const Text('全データを初期化', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Colors.red)),
                  subtitle: const Text('シーズン・選手・対戦相手・試合記録を含む全データを初期化', style: TextStyle(fontSize: 12, color: Colors.grey)),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.red),
                  onTap: _confirmResetAllData,
                ),
                const SizedBox(height: 32),
              ],
            ),
    );
  }
}
