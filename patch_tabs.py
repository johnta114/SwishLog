import re

with open('lib/screens/analytics_screen.dart', 'r') as f:
    content = f.read()

# 1. Update build method
build_old = """  @override
  Widget build(BuildContext context) {
    final isGameSpecific = widget.gameId != null;

    final Widget body = _isLoading 
      ? const Center(child: CircularProgressIndicator(color: Colors.deepOrange))
      : Column(
          children: [
            _buildHeaderFilters(isGameSpecific),
            Expanded(
              child: isGameSpecific
                ? TabBarView(
                    children: [
                      _buildStatsTab(),
                      _buildPlayLogsTab(),
                    ],
                  )
                : _buildStatsTab(),
            ),
          ],
        );

    final appBar = AppBar(
      title: const Text('SwishLog', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
      centerTitle: false,
      bottom: isGameSpecific
        ? const TabBar(
            indicatorColor: Colors.white,
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white70,
            tabs: [
              Tab(icon: Icon(Icons.bar_chart), text: "スタッツ"),
              Tab(icon: Icon(Icons.history), text: "試合ログ"),
            ],
          )
        : null,
    );

    if (isGameSpecific) {
      return DefaultTabController(
        length: 2,
        child: Scaffold(
          appBar: appBar,
          body: body,
        ),
      );
    } else {
      return Scaffold(
        appBar: appBar,
        body: body,
      );
    }
  }"""

build_new = """  @override
  Widget build(BuildContext context) {
    final isGameSpecific = widget.gameId != null;

    final Widget body = _isLoading 
      ? const Center(child: CircularProgressIndicator(color: Colors.deepOrange))
      : Column(
          children: [
            _buildHeaderFilters(isGameSpecific),
            Expanded(
              child: TabBarView(
                children: [
                  _buildShotChartTab(),
                  _buildPlayerStatsTab(),
                  if (isGameSpecific) _buildPlayLogsTab(),
                ],
              )
            ),
          ],
        );

    final appBar = AppBar(
      title: const Text('SwishLog', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
      centerTitle: false,
      bottom: TabBar(
        indicatorColor: Colors.white,
        labelColor: Colors.white,
        unselectedLabelColor: Colors.white70,
        tabs: [
          const Tab(icon: Icon(Icons.pie_chart), text: "シュート分布"),
          const Tab(icon: Icon(Icons.person), text: "個人スタッツ"),
          if (isGameSpecific) const Tab(icon: Icon(Icons.history), text: "試合ログ"),
        ],
      ),
    );

    return DefaultTabController(
      length: isGameSpecific ? 3 : 2,
      child: Scaffold(
        appBar: appBar,
        body: body,
      ),
    );
  }"""

content = content.replace(build_old, build_new)

# 2. Split _buildStatsTab into two methods
stats_tab_old_start = """  Widget _buildStatsTab() {"""
stats_tab_old = content[content.find(stats_tab_old_start):]
stats_tab_old = stats_tab_old[:stats_tab_old.find("  Widget _buildPlayLogsTab() {")]

stats_tab_new = """  Widget _buildShotChartTab() {
    var shots = _rawStats.where((s) => (s['stat_type'] == '2P' || s['stat_type'] == '3P' || s['stat_type'] == 'FG') && s['pos_x'] != null).toList();
    if (_selectedPlayerForChart != null) {
      shots = shots.where((s) => s['player_id'].toString() == _selectedPlayerForChart).toList();
    }

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            color: Colors.grey.shade100,
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Text("シュート分布 (FG/3P)", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(width: 12, height: 12, decoration: const BoxDecoration(shape: BoxShape.circle, color: Colors.deepOrange)),
                    const SizedBox(width: 4), const Text("Made", style: TextStyle(fontSize: 12)),
                    const SizedBox(width: 16),
                    Container(width: 12, height: 12, decoration: const BoxDecoration(shape: BoxShape.circle, color: Colors.grey)),
                    const SizedBox(width: 4), const Text("Miss", style: TextStyle(fontSize: 12)),
                  ],
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: MediaQuery.of(context).size.width * 0.8,
                  child: AspectRatio(
                    aspectRatio: 15.0 / 14.0,
                    child: Container(
                      decoration: const BoxDecoration(color: Color(0xFFF6E8D7), border: Border(bottom: BorderSide(color: Colors.black54, width: 2))),
                      child: CustomPaint(
                        painter: AnalysisCourtPainter(shots),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlayerStatsTab() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("個人スタッツ一覧", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                const SizedBox(height: 12),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 固定カラム（選手名）
                    Container(
                      decoration: BoxDecoration(
                        border: Border(right: BorderSide(color: Colors.grey.shade300, width: 2)),
                      ),
                      child: DataTable(
                        columnSpacing: 16,
                        horizontalMargin: 12,
                        headingRowColor: WidgetStateProperty.all(Colors.blueGrey.shade50),
                        columns: const [
                          DataColumn(label: Text("選手", style: TextStyle(fontWeight: FontWeight.bold))),
                        ],
                        rows: _aggregatedPlayerStats.map((p) {
                          return DataRow(
                            cells: [
                              DataCell(Text(p['name'] as String, style: const TextStyle(fontWeight: FontWeight.bold))),
                            ],
                          );
                        }).toList(),
                      ),
                    ),
                    // スクロール可能カラム（スタッツ）
                    Expanded(
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: DataTable(
                          columnSpacing: 16,
                          horizontalMargin: 12,
                          headingRowColor: WidgetStateProperty.all(Colors.blueGrey.shade50),
                          columns: const [
                            DataColumn(label: Text("PTS", style: TextStyle(fontWeight: FontWeight.bold)), numeric: true),
                            DataColumn(label: Text("REB", style: TextStyle(fontWeight: FontWeight.bold)), numeric: true),
                            DataColumn(label: Text("AST", style: TextStyle(fontWeight: FontWeight.bold)), numeric: true),
                            DataColumn(label: Text("STL", style: TextStyle(fontWeight: FontWeight.bold)), numeric: true),
                            DataColumn(label: Text("TO", style: TextStyle(fontWeight: FontWeight.bold)), numeric: true),
                            DataColumn(label: Text("2P%", style: TextStyle(fontWeight: FontWeight.bold)), numeric: true),
                            DataColumn(label: Text("3P%", style: TextStyle(fontWeight: FontWeight.bold)), numeric: true),
                            DataColumn(label: Text("FT%", style: TextStyle(fontWeight: FontWeight.bold)), numeric: true),
                          ],
                          rows: _aggregatedPlayerStats.map((p) {
                            final pa2 = p['2PA'] as int;
                            final pm2 = p['2PM'] as int;
                            final pct2 = pa2 > 0 ? ((pm2 / pa2) * 100).toStringAsFixed(1) : "0.0";
                            
                            final pa3 = p['3PA'] as int;
                            final pm3 = p['3PM'] as int;
                            final pct3 = pa3 > 0 ? ((pm3 / pa3) * 100).toStringAsFixed(1) : "0.0";
                            
                            final fta = p['FTA'] as int;
                            final ftm = p['FTM'] as int;
                            final pctFt = fta > 0 ? ((ftm / fta) * 100).toStringAsFixed(1) : "0.0";
                            
                            return DataRow(
                              cells: [
                                DataCell(Text("${p['PTS']}")),
                                DataCell(Text("${p['REB']}")),
                                DataCell(Text("${p['AST']}")),
                                DataCell(Text("${p['STL']}")),
                                DataCell(Text("${p['TO']}")),
                                DataCell(Text("$pct2% ($pm2/$pa2)")),
                                DataCell(Text("$pct3% ($pm3/$pa3)")),
                                DataCell(Text("$pctFt% ($ftm/$fta)")),
                              ],
                            );
                          }).toList(),
                        ),
                      ),
                    ),
                  ],
                )
              ],
            ),
          )
        ],
      ),
    );
  }

"""

content = content.replace(stats_tab_old, stats_tab_new)

with open('lib/screens/analytics_screen.dart', 'w') as f:
    f.write(content)

