import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('swishlog.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getApplicationDocumentsDirectory();
    final path = join(dbPath.path, filePath);

    return await openDatabase(
      path,
      version: 3,
      onCreate: _createDB,
      onUpgrade: _upgradeDB,
    );
  }

  Future _upgradeDB(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      try { await db.execute("ALTER TABLE games ADD COLUMN status TEXT DEFAULT 'not_started'"); } catch (_) {}
      try { await db.execute("ALTER TABLE games ADD COLUMN my_score INTEGER DEFAULT 0"); } catch (_) {}
      try { await db.execute("ALTER TABLE games ADD COLUMN opp_score INTEGER DEFAULT 0"); } catch (_) {}
    }
    if (oldVersion < 3) {
      // バージョン2で新規作成された環境（iPhone等）にはこれらのカラムが存在しないため、安全に追加を試みる
      try { await db.execute("ALTER TABLE games ADD COLUMN status TEXT DEFAULT 'not_started'"); } catch (_) {}
      try { await db.execute("ALTER TABLE games ADD COLUMN my_score INTEGER DEFAULT 0"); } catch (_) {}
      try { await db.execute("ALTER TABLE games ADD COLUMN opp_score INTEGER DEFAULT 0"); } catch (_) {}
    }
  }

  Future _createDB(Database db, int version) async {
    const idType = 'TEXT PRIMARY KEY';
    const textType = 'TEXT NOT NULL';
    const intType = 'INTEGER NOT NULL';
    const realType = 'REAL';

    // 1. シーズン管理
    await db.execute('''
    CREATE TABLE seasons (
      id $idType,
      name $textType,
      start_date $textType
    )
    ''');

    // 2. 自チーム選手管理
    await db.execute('''
    CREATE TABLE players (
      id $idType,
      last_name $textType,
      first_name $textType,
      court_name $textType,
      birth_date $textType,
      is_active INTEGER NOT NULL DEFAULT 1
    )
    ''');

    // 3. 自チームロスター
    await db.execute('''
    CREATE TABLE rosters (
      season_id TEXT NOT NULL,
      player_id TEXT NOT NULL,
      jersey_number INTEGER,
      position TEXT,
      PRIMARY KEY (season_id, player_id),
      FOREIGN KEY (season_id) REFERENCES seasons (id) ON DELETE CASCADE,
      FOREIGN KEY (player_id) REFERENCES players (id) ON DELETE CASCADE
    )
    ''');

    // 4. 対戦相手チーム管理（都道府県・監督連絡先・メモを追加）
    await db.execute('''
    CREATE TABLE opponent_teams (
      id $idType,
      name $textType,
      prefecture TEXT,
      coach_contact TEXT,
      notes TEXT
    )
    ''');

    // 5. 対戦相手選手管理
    await db.execute('''
    CREATE TABLE opponent_players (
      id $idType,
      team_id TEXT NOT NULL,
      jersey_number INTEGER,
      name TEXT,
      FOREIGN KEY (team_id) REFERENCES opponent_teams (id) ON DELETE CASCADE
    )
    ''');

    // 6. 試合管理（U12フラグを追加）
    await db.execute('''
    CREATE TABLE games (
      id $idType,
      season_id TEXT NOT NULL,
      date $textType,
      opponent_team_id TEXT NOT NULL,
      is_u12 INTEGER NOT NULL DEFAULT 0,
      status TEXT DEFAULT 'not_started',
      my_score INTEGER DEFAULT 0,
      opp_score INTEGER DEFAULT 0,
      opp_score_q1 INTEGER DEFAULT 0,
      opp_score_q2 INTEGER DEFAULT 0,
      opp_score_q3 INTEGER DEFAULT 0,
      opp_score_q4 INTEGER DEFAULT 0,
      opp_score_ot INTEGER DEFAULT 0,
      video_url TEXT,
      FOREIGN KEY (season_id) REFERENCES seasons (id) ON DELETE CASCADE,
      FOREIGN KEY (opponent_team_id) REFERENCES opponent_teams (id) ON DELETE CASCADE
    )
    ''');

    // 7. 自チームスタッツ記録
    await db.execute('''
    CREATE TABLE stats (
      id $idType,
      game_id TEXT NOT NULL,
      player_id TEXT NOT NULL,
      quarter $intType,
      stat_type $textType,
      is_made INTEGER,
      pos_x $realType,
      pos_y $realType,
      created_at $textType,
      FOREIGN KEY (game_id) REFERENCES games (id) ON DELETE CASCADE,
      FOREIGN KEY (player_id) REFERENCES players (id) ON DELETE CASCADE
    )
    ''');

    // 8. 対戦相手の個人得点記録
    await db.execute('''
    CREATE TABLE opponent_scores (
      id $idType,
      game_id TEXT NOT NULL,
      opponent_player_id TEXT NOT NULL,
      points $intType,
      FOREIGN KEY (game_id) REFERENCES games (id) ON DELETE CASCADE,
      FOREIGN KEY (opponent_player_id) REFERENCES opponent_players (id) ON DELETE CASCADE
    )
    ''');
  }

  // ==========================================
  // 対戦相手チーム (Opponent Teams) の CRUD 処理
  // ==========================================
  
  Future<String> insertOpponentTeam(Map<String, dynamic> teamData) async {
    final db = await instance.database;
    // 簡単な一意のIDとしてタイムスタンプを使用
    final id = DateTime.now().millisecondsSinceEpoch.toString();
    
    // SQLiteに保存するためにMapをコピーしてIDを追加
    final dataToInsert = Map<String, dynamic>.from(teamData);
    dataToInsert['id'] = id;
    
    await db.insert('opponent_teams', dataToInsert);
    return id;
  }

  Future<List<Map<String, dynamic>>> getOpponentTeams() async {
    final db = await instance.database;
    // チーム名順で取得
    return await db.query('opponent_teams', orderBy: 'name ASC');
  }

  Future<int> deleteOpponentTeam(String id) async {
    final db = await instance.database;
    return await db.delete('opponent_teams', where: 'id = ?', whereArgs: [id]);
  }

  // ==========================================
  // シーズン (Seasons) の CRUD 処理
  // ==========================================
  
  Future<String> insertSeason(Map<String, dynamic> seasonData) async {
    final db = await instance.database;
    final id = DateTime.now().millisecondsSinceEpoch.toString();
    final dataToInsert = Map<String, dynamic>.from(seasonData);
    dataToInsert['id'] = id;
    await db.insert('seasons', dataToInsert);
    return id;
  }

  Future<List<Map<String, dynamic>>> getSeasons() async {
    final db = await instance.database;
    return await db.query('seasons', orderBy: 'start_date DESC');
  }

  Future<int> deleteSeason(String id) async {
    final db = await instance.database;
    return await db.delete('seasons', where: 'id = ?', whereArgs: [id]);
  }

  // ==========================================
  // 選手マスター (Players) の CRUD 処理
  // ==========================================

  Future<String> insertPlayer(Map<String, dynamic> playerData) async {
    final db = await instance.database;
    final id = DateTime.now().millisecondsSinceEpoch.toString();
    final dataToInsert = Map<String, dynamic>.from(playerData);
    dataToInsert['id'] = id;
    await db.insert('players', dataToInsert);
    return id;
  }

  Future<List<Map<String, dynamic>>> getAllPlayers() async {
    final db = await instance.database;
    return await db.query('players', orderBy: 'last_name ASC');
  }

  // プレイヤー情報の更新
  Future<void> updatePlayer(String id, Map<String, dynamic> playerData) async {
    final db = await instance.database;
    await db.update('players', playerData, where: 'id = ?', whereArgs: [id]);
  }

  // ロスター（背番号・ポジションなど）の更新
  Future<void> updateRoster(String seasonId, String playerId, Map<String, dynamic> rosterData) async {
    final db = await instance.database;
    await db.update('rosters', rosterData, where: 'season_id = ? AND player_id = ?', whereArgs: [seasonId, playerId]);
  }

  Future<int> deletePlayerCompletely(String id) async {
    final db = await instance.database;
    // playersテーブルから削除（外部キー制約ON DELETE CASCADEにより関連ロスターも消える想定）
    return await db.delete('players', where: 'id = ?', whereArgs: [id]);
  }

  // ==========================================
  // ロスター (Rosters - シーズンごとの選手名簿) の CRUD 処理
  // ==========================================

  Future<void> insertRoster(Map<String, dynamic> rosterData) async {
    final db = await instance.database;
    await db.insert('rosters', rosterData, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  // 特定シーズンの所属選手を取得する（JOINを使用）
  Future<List<Map<String, dynamic>>> getRosterForSeason(String seasonId) async {
    final db = await instance.database;
    return await db.rawQuery('''
      SELECT r.season_id, r.player_id, r.jersey_number, r.position,
             p.last_name, p.first_name, p.court_name, p.birth_date
      FROM rosters r
      JOIN players p ON r.player_id = p.id
      WHERE r.season_id = ?
      ORDER BY r.jersey_number ASC
    ''', [seasonId]);
  }

  Future<int> deletePlayerFromRoster(String seasonId, String playerId) async {
    final db = await instance.database;
    return await db.delete('rosters', where: 'season_id = ? AND player_id = ?', whereArgs: [seasonId, playerId]);
  }

  // ==========================================
  // 試合 (Games) の CRUD 処理
  // ==========================================

  Future<String> insertGame(Map<String, dynamic> gameData) async {
    final db = await instance.database;
    final id = DateTime.now().millisecondsSinceEpoch.toString();
    final dataToInsert = Map<String, dynamic>.from(gameData);
    dataToInsert['id'] = id;
    await db.insert('games', dataToInsert);
    return id;
  }

  Future<List<Map<String, dynamic>>> getAllGames() async {
    final db = await instance.database;
    return await db.rawQuery('''
      SELECT g.*, o.name as opponent, o.prefecture 
      FROM games g
      JOIN opponent_teams o ON g.opponent_team_id = o.id
      ORDER BY g.date DESC, g.id DESC
    ''');
  }

  Future<int> updateGameStatus(String gameId, String status) async {
    final db = await instance.database;
    return await db.update('games', {'status': status}, where: 'id = ?', whereArgs: [gameId]);
  }

  // ==========================================
  // スタッツ記録 (Stats & Scores) の CRUD 処理
  // ==========================================

  Future<String> insertStat(Map<String, dynamic> statData) async {
    final db = await instance.database;
    final id = DateTime.now().millisecondsSinceEpoch.toString();
    final dataToInsert = Map<String, dynamic>.from(statData);
    dataToInsert['id'] = id;
    dataToInsert['created_at'] = DateTime.now().toIso8601String();
    await db.insert('stats', dataToInsert);
    return id;
  }

  Future<String> insertOpponentScore(Map<String, dynamic> scoreData) async {
    final db = await instance.database;
    final id = DateTime.now().millisecondsSinceEpoch.toString();
    final dataToInsert = Map<String, dynamic>.from(scoreData);
    dataToInsert['id'] = id;
    await db.insert('opponent_scores', dataToInsert);
    return id;
  }

  Future<List<Map<String, dynamic>>> getOpponentScoresByGame(String gameId) async {
    final db = await instance.database;
    return await db.query('opponent_scores', where: 'game_id = ?', whereArgs: [gameId], orderBy: 'id ASC');
  }

  // 試合の合計得点を再計算して、gamesテーブルを更新する
  Future<void> updateGameScoreTotals(String gameId) async {
    final db = await instance.database;
    
    // 自チームの得点計算 (2P=2点, 3P=3点, FT=1点)
    final myStats = await db.rawQuery("SELECT stat_type FROM stats WHERE game_id = ? AND is_made = 1", [gameId]);
    int myScore = 0;
    for (var s in myStats) {
      if (s['stat_type'] == '2P') myScore += 2;
      if (s['stat_type'] == '3P') myScore += 3;
      if (s['stat_type'] == 'FT') myScore += 1;
    }

    // 相手チームの得点計算
    final oppStats = await db.rawQuery("SELECT SUM(points) as total FROM opponent_scores WHERE game_id = ?", [gameId]);
    int oppScore = 0;
    if (oppStats.isNotEmpty && oppStats.first['total'] != null) {
      oppScore = (oppStats.first['total'] as num).toInt();
    }

    // 合計得点をgamesテーブルに反映
    await db.update(
      'games', 
      {'my_score': myScore, 'opp_score': oppScore}, 
      where: 'id = ?', 
      whereArgs: [gameId]
    );
  }

  // ==========================================
  // 分析機能 (Analytics) 用のデータ取得・更新処理
  // ==========================================

  // 条件（試合ごと・クォーターごとなど）に応じて生スタッツデータを取得
  Future<List<Map<String, dynamic>>> getRawStats({String? gameId, int? quarter}) async {
    final db = await instance.database;
    String query = '''
      SELECT s.*, p.court_name, p.last_name, p.first_name 
      FROM stats s
      JOIN players p ON s.player_id = p.id
      WHERE 1=1
    ''';
    List<dynamic> args = [];

    if (gameId != null) {
      query += ' AND s.game_id = ?';
      args.add(gameId);
    }
    if (quarter != null && quarter > 0) {
      query += ' AND s.quarter = ?';
      args.add(quarter);
    }

    query += ' ORDER BY s.created_at ASC';
    return await db.rawQuery(query, args);
  }

  // 試合のYouTubeリンクを更新
  Future<int> updateGameVideoUrl(String gameId, String url) async {
    final db = await instance.database;
    return await db.update('games', {'video_url': url}, where: 'id = ?', whereArgs: [gameId]);
  }

  // 特定の試合情報を取得
  Future<Map<String, dynamic>?> getGameById(String gameId) async {
    final db = await instance.database;
    final results = await db.query('games', where: 'id = ?', whereArgs: [gameId], limit: 1);
    if (results.isNotEmpty) return results.first;
    return null;
  }

  // 特定のスタッツを削除（Undo用）
  Future<void> deleteStat(String id) async {
    final db = await instance.database;
    await db.delete('stats', where: 'id = ?', whereArgs: [id]);
  }

  // 特定の相手得点を削除（Undo用）
  Future<void> deleteOpponentScore(String id) async {
    final db = await instance.database;
    await db.delete('opponent_scores', where: 'id = ?', whereArgs: [id]);
  }

  Future close() async {
    final db = await instance.database;
    db.close();
  }
}
