import re

with open('lib/screens/analytics_screen.dart', 'r') as f:
    content = f.read()

# 1. Update _loadData signature and logic
load_old = """  Future<void> _loadData() async {
    setState(() => _isLoading = true);"""
load_new = """  Future<void> _loadData({bool showLoading = true}) async {
    if (showLoading) setState(() => _isLoading = true);"""
content = content.replace(load_old, load_new)

# 2. Update _updateQuarter logic
update_old = """  void _updateQuarter(int q) {
    setState(() => _selectedQuarter = q);
    _loadData();
  }"""
update_new = """  void _updateQuarter(int q) {
    setState(() => _selectedQuarter = q);
    _loadData(showLoading: false);
  }"""
content = content.replace(update_old, update_new)

# 3. Fix other calls to _loadData if necessary
# In _AnalyticsScreenState:
# initState: _loadData(); -> it has the default showLoading=true, so it's fine.
# onSave in _confirmDeleteStat and _showEditStatDialog: we can use _loadData(showLoading: false) to prevent screen blink on save.
save_old = """          _loadData();
        },
      ),"""
save_new = """          _loadData(showLoading: false);
        },
      ),"""
content = content.replace(save_old, save_new)

delete_old = """              Navigator.pop(context);
              _loadData();
            },"""
delete_new = """              Navigator.pop(context);
              _loadData(showLoading: false);
            },"""
content = content.replace(delete_old, delete_new)

with open('lib/screens/analytics_screen.dart', 'w') as f:
    f.write(content)

