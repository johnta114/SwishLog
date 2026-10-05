import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../database/database_helper.dart';

class AppSettingsProvider extends ChangeNotifier {
  String? _activeSeasonId;
  bool _isLoaded = false;

  String? get activeSeasonId => _activeSeasonId;
  bool get isLoaded => _isLoaded;

  AppSettingsProvider() {
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    _activeSeasonId = prefs.getString('activeSeasonId');
    
    // DBにシーズンが存在するか確認し、IDが無効または未設定なら自動設定する
    final seasons = await DatabaseHelper.instance.getSeasons();
    if (seasons.isNotEmpty) {
      bool isValid = seasons.any((s) => s['id'] == _activeSeasonId);
      if (!isValid) {
        _activeSeasonId = seasons.first['id'];
        await prefs.setString('activeSeasonId', _activeSeasonId!);
      }
    } else {
      _activeSeasonId = null;
      await prefs.remove('activeSeasonId');
    }
    
    _isLoaded = true;
    notifyListeners();
  }

  Future<void> setActiveSeason(String seasonId) async {
    _activeSeasonId = seasonId;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('activeSeasonId', seasonId);
    notifyListeners();
  }
}
