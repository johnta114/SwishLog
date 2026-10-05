import re

with open('lib/screens/season_roster_screen.dart', 'r') as f:
    content = f.read()

# Replace didChangeDependencies and _loadData
old_block = """  String? _lastLoadedSeasonId;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final settings = Provider.of<AppSettingsProvider>(context);
    if (settings.isLoaded && _lastLoadedSeasonId != settings.activeSeasonId) {
      _lastLoadedSeasonId = settings.activeSeasonId;
      _loadData();
    }
  }

  Future<void> _loadData() async {

    setState(() => _isLoading = true);
    final seasons = await DatabaseHelper.instance.getSeasons();
    
    setState(() {
      _seasons = seasons;
    });

    if (seasons.isNotEmpty) {
      if (_selectedSeasonId == null || !seasons.any((s) => s['id'] == _selectedSeasonId)) {
        _selectedSeasonId = seasons.first['id'];
      }
      await _loadRoster(_selectedSeasonId!);
    } else {
      setState(() {
        _roster = [];
        _isLoading = false;
      });
    }
  }"""

new_block = """  String? _lastLoadedSeasonId;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final settings = Provider.of<AppSettingsProvider>(context);
    if (settings.isLoaded && _lastLoadedSeasonId != settings.activeSeasonId) {
      _lastLoadedSeasonId = settings.activeSeasonId;
      // グローバル設定が変更されたら、画面内のドロップダウンもそれに合わせる
      _selectedSeasonId = settings.activeSeasonId;
      _loadData();
    }
  }

  Future<void> _loadData() async {
    if (!mounted) return;
    setState(() => _isLoading = true);
    final seasons = await DatabaseHelper.instance.getSeasons();
    
    setState(() {
      _seasons = seasons;
    });

    if (seasons.isNotEmpty) {
      if (_selectedSeasonId == null || !seasons.any((s) => s['id'] == _selectedSeasonId)) {
        final settings = Provider.of<AppSettingsProvider>(context, listen: false);
        _selectedSeasonId = settings.activeSeasonId ?? seasons.first['id'];
      }
      await _loadRoster(_selectedSeasonId!);
    } else {
      setState(() {
        _roster = [];
        _isLoading = false;
      });
    }
  }"""

content = content.replace(old_block, new_block)

with open('lib/screens/season_roster_screen.dart', 'w') as f:
    f.write(content)

