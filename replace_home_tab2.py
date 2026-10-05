import re

with open('lib/screens/home_screen.dart', 'r') as f:
    content = f.read()

# We need to replace the Container holding the DataTables.
start_str = "                      Container("
end_str = "                      ),"

# Let's find it after "_playerStats.isEmpty"
idx1 = content.find("                  _playerStats.isEmpty ")
start_idx = content.find("                      Container(", idx1)

if start_idx != -1:
    # We want to match up to the end of the Container.
    # The container ends with "                      ),"
    # It's better to just search for the end of the Expanded block.
    # We can match `DataCell(_buildCellContent('${stat['FOUL'] ?? 0}')),`
    # and then skip the closing brackets.
    
    end_marker = "DataCell(_buildCellContent('${stat['FOUL'] ?? 0}')),"
    marker_idx = content.find(end_marker, start_idx)
    
    if marker_idx != -1:
        # Find the end of the container
        end_idx = content.find("                      ),", marker_idx)
        if end_idx != -1:
            end_idx += len("                      ),")
            
            new_method = "                      PlayerStatsTable(stats: _playerStats),"
            content = content[:start_idx] + new_method + content[end_idx:]

with open('lib/screens/home_screen.dart', 'w') as f:
    f.write(content)

