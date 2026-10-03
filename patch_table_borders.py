import re

with open('lib/screens/analytics_screen.dart', 'r') as f:
    content = f.read()

left_table_old = """                      child: DataTable(
                        dataRowMinHeight: 56.0,
                        dataRowMaxHeight: 56.0,
                        columnSpacing: 16,
                        horizontalMargin: 12,"""
left_table_new = """                      child: DataTable(
                        border: TableBorder(
                          horizontalInside: BorderSide(color: Colors.grey.shade300, width: 1),
                          verticalInside: BorderSide(color: Colors.grey.shade300, width: 1),
                        ),
                        dataRowMinHeight: 56.0,
                        dataRowMaxHeight: 56.0,
                        columnSpacing: 16,
                        horizontalMargin: 12,"""
content = content.replace(left_table_old, left_table_new)


right_table_old = """                        child: DataTable(
                          dataRowMinHeight: 56.0,
                          dataRowMaxHeight: 56.0,
                          columnSpacing: 16,
                          horizontalMargin: 12,"""
right_table_new = """                        child: DataTable(
                          border: TableBorder(
                            horizontalInside: BorderSide(color: Colors.grey.shade300, width: 1),
                            verticalInside: BorderSide(color: Colors.grey.shade300, width: 1),
                          ),
                          dataRowMinHeight: 56.0,
                          dataRowMaxHeight: 56.0,
                          columnSpacing: 16,
                          horizontalMargin: 12,"""
content = content.replace(right_table_old, right_table_new)

with open('lib/screens/analytics_screen.dart', 'w') as f:
    f.write(content)
