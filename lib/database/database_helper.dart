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
      version: 1,
      onCreate: _createDB,
    );
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

    // 4. 対戦相手チーム管理（都道府県・監督連絡先を追加）
    await db.execute('''
    CREATE TABLE opponent_teams (
      id $idType,
      name $textType,
      prefecture TEXT,
      coach_contact TEXT
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

  Future close() async {
    final db = await instance.database;
    db.close();
  }
}
