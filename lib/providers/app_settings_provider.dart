import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../database/database_helper.dart';

class AppSettingsProvider extends ChangeNotifier {
  static const List<String> configurableActions = ['REB', 'AST', 'STL', 'TO'];

  String? _activeSeasonId;
  List<String> _enabledActions = List.from(configurableActions);
  bool _isLoaded = false;

  String? get activeSeasonId => _activeSeasonId;
  List<String> get enabledActions => List.unmodifiable(_enabledActions);
  bool get isLoaded => _isLoaded;

  // フリースロー (FT) とファール (PF) は常に有効
  bool isActionEnabled(String actionId) {
    if (actionId == 'FT' || actionId == 'PF') return true;
    return _enabledActions.contains(actionId);
  }

  AppSettingsProvider() {
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    _activeSeasonId = prefs.getString('activeSeasonId');
    
    final savedActions = prefs.getStringList('enabledActions');
    if (savedActions != null) {
      _enabledActions = List.from(savedActions);
    } else {
      _enabledActions = List.from(configurableActions);
    }

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

  Future<void> toggleAction(String actionId, bool enabled) async {
    if (enabled) {
      if (!_enabledActions.contains(actionId)) {
        _enabledActions.add(actionId);
      }
    } else {
      _enabledActions.remove(actionId);
    }
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('enabledActions', _enabledActions);
    notifyListeners();
  }
}
