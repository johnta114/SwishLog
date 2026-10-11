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
                const SizedBox(height: 24),
              ],
            ),
    );
  }
}
