with open('lib/screens/games_screen.dart', 'r') as f:
    content = f.read()

save_old = """                      // SQLiteに試合を登録
                      await DatabaseHelper.instance.insertGame({
                        'season_id': _activeSeasonId,
                        'date': dateCtrl.text,
                        'opponent_team_id': targetOpponentId,
                        'is_u12': isU12 ? 1 : 0,
                        'status': 'not_started',
                        'my_score': 0,
                        'opp_score': 0,
                      });"""

save_new = """                      final data = {
                        'season_id': _activeSeasonId,
                        'date': dateCtrl.text,
                        'opponent_team_id': targetOpponentId,
                        'is_u12': isU12 ? 1 : 0,
                      };
                      if (isEdit) {
                        await DatabaseHelper.instance.updateGame(game['id'].toString(), data);
                      } else {
                        data['status'] = 'not_started';
                        data['my_score'] = 0;
                        data['opp_score'] = 0;
                        await DatabaseHelper.instance.insertGame(data);
                      }"""

content = content.replace(save_old, save_new)

# Button text
btn_old = "child: const Text('作成する', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),"
btn_new = "child: Text(isEdit ? '更新する' : '作成する', style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),"
content = content.replace(btn_old, btn_new)

with open('lib/screens/games_screen.dart', 'w') as f:
    f.write(content)
