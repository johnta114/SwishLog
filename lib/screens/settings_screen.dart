import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_settings_provider.dart';
import '../database/database_helper.dart';

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
                    'アプリ設定',
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
              ],
            ),
    );
  }
}
