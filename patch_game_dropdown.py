with open('lib/screens/games_screen.dart', 'r') as f:
    content = f.read()

dd_old = """                    DropdownMenu<String>(
                      width: MediaQuery.of(context).size.width - 48,
                      enableFilter: true,
                      requestFocusOnTap: true,
                      label: const Text('チーム名や都道府県を入力して検索'),
                      dropdownMenuEntries: _knownOpponents.map((opp) {"""

dd_new = """                    DropdownMenu<String>(
                      width: MediaQuery.of(context).size.width - 48,
                      enableFilter: true,
                      requestFocusOnTap: true,
                      label: const Text('チーム名や都道府県を入力して検索'),
                      initialSelection: selectedOpponentId,
                      dropdownMenuEntries: _knownOpponents.map((opp) {"""
content = content.replace(dd_old, dd_new)
with open('lib/screens/games_screen.dart', 'w') as f:
    f.write(content)
