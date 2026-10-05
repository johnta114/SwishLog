import re

def update_file(filename):
    with open(filename, 'r') as f:
        content = f.read()

    # Update _buildCellContent
    old_min_width = "if (text == 'No.' || text == '-' || text.length <= 2 && RegExp(r'^[0-9]+$').hasMatch(text)) minWidth = 40.0;"
    new_min_width = "if (text == 'No.' || text == '-' || text.length <= 2 && RegExp(r'^[0-9]+$').hasMatch(text)) minWidth = 28.0;"
    content = content.replace(old_min_width, new_min_width)

    # We need to target the left DataTable. 
    # Let's find:
    #                         headingRowHeight: 48,
    #                         columnSpacing: 16,
    #                         horizontalMargin: 16,
    #                         border: TableBorder(
    #                           right: BorderSide(color: Colors.grey.shade300),
    
    old_spacing = """                        headingRowHeight: 48,
                        columnSpacing: 16,
                        horizontalMargin: 16,
                        border: TableBorder(
                          right: BorderSide(color: Colors.grey.shade300),"""
    new_spacing = """                        headingRowHeight: 48,
                        columnSpacing: 8,
                        horizontalMargin: 8,
                        border: TableBorder(
                          right: BorderSide(color: Colors.grey.shade300),"""
    content = content.replace(old_spacing, new_spacing)

    # Note: the above string match is specific enough and should only hit the left DataTable 
    # because the right DataTable has a different border:
    # border: TableBorder(
    #   horizontalInside: BorderSide(color: Colors.grey.shade300),
    #   verticalInside: BorderSide(color: Colors.grey.shade300),
    # ),

    # But just in case, let's also check if there are 24 spacing.
    # The right DataTable has:
    # columnSpacing: 24,
    # horizontalMargin: 16,
    # Maybe we should shrink the right table's margin too?
    # Leave right table as is for now, maybe just left margin? No, horizontalMargin applies to both sides.
    # We will leave the right table's horizontalMargin at 16, which is good for the edge of the scroll area.
    
    with open(filename, 'w') as f:
        f.write(content)

update_file('lib/screens/home_screen.dart')
update_file('lib/screens/game_analytics_screen.dart')

