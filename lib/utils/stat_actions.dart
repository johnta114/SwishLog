class StatActions {
  static const Map<String, String> labels = {
    '2P': '2P',
    '3P': '3P',
    'FT': 'フリースロー',
    'REB': 'リバウンド',
    'AST': 'アシスト',
    'STL': 'スティール',
    'BLK': 'ブロック',
    'TO': 'ターンオーバー',
    'PF': 'ファール',
    'SUB': '交代',
  };

  static String getLabel(String actionId) {
    return labels[actionId] ?? actionId;
  }
}
