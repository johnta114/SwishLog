import re

with open('lib/screens/analytics_screen.dart', 'r') as f:
    content = f.read()

# 1. Add column
col_old = """                            DataColumn(label: Expanded(child: Text("スティール", textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold)))),
                            DataColumn(label: Expanded(child: Text("ターンオーバー", textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold)))),
                          ],"""

col_new = """                            DataColumn(label: Expanded(child: Text("スティール", textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold)))),
                            DataColumn(label: Expanded(child: Text("ターンオーバー", textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold)))),
                            DataColumn(label: Expanded(child: Text("ファール", textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold)))),
                          ],"""
content = content.replace(col_old, col_new)

# 2. Add cell
cell_old = """                                DataCell(Center(child: Text("${p['STL']}", textAlign: TextAlign.center))),
                                DataCell(Center(child: Text("${p['TO']}", textAlign: TextAlign.center))),
                              ],
                            );"""
cell_new = """                                DataCell(Center(child: Text("${p['STL']}", textAlign: TextAlign.center))),
                                DataCell(Center(child: Text("${p['TO']}", textAlign: TextAlign.center))),
                                DataCell(Center(child: Text("${p['PF']}", textAlign: TextAlign.center))),
                              ],
                            );"""
content = content.replace(cell_old, cell_new)

with open('lib/screens/analytics_screen.dart', 'w') as f:
    f.write(content)
