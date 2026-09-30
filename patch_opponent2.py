with open('lib/screens/opponent_teams_screen.dart', 'r') as f:
    lines = f.readlines()

for i, line in enumerate(lines):
    if "                      );" in line and "}" in lines[i+1] and "                  )," in lines[i+2]:
        lines[i] = "                        ),\n                      );\n"
        break

# Let's remove the TextButton Row
start_idx = -1
end_idx = -1
for i, line in enumerate(lines):
    if "Row(" in line and "mainAxisAlignment: MainAxisAlignment.end" in lines[i+1] and "children: [" in lines[i+2] and "TextButton" in lines[i+3]:
        start_idx = i
        break

if start_idx != -1:
    # find the end of this Row which should be around start_idx + 15
    for j in range(start_idx, len(lines)):
        if "                                  )" in lines[j] and "]" in lines[j-1]:
            end_idx = j
            break
            
if start_idx != -1 and end_idx != -1:
    del lines[start_idx:end_idx+1]
    
with open('lib/screens/opponent_teams_screen.dart', 'w') as f:
    f.writelines(lines)
