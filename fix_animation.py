import re

def update_games_screen():
    with open('lib/screens/games_screen.dart', 'r') as f:
        content = f.read()

    # Find AnimatedSize block
    animated_size_regex = r"AnimatedSize\(\s*duration: const Duration\(milliseconds: 200\),\s*curve: Curves\.easeInOut,\s*alignment: Alignment\.topCenter,\s*child: !_isSearching\s*\?\s*const SizedBox\(width: double\.infinity, height: 0\)\s*:\s*Container\(\s*decoration: const BoxDecoration\(\s*color: Colors\.deepOrange,\s*boxShadow: \[BoxShadow\(color: Colors\.black26, blurRadius: 6, offset: Offset\(0, 3\)\)\],\s*\),\s*padding: const EdgeInsets\.fromLTRB\(16, 0, 16, 12\),"

    new_animated_cross_fade = """AnimatedCrossFade(
                  duration: const Duration(milliseconds: 200),
                  crossFadeState: _isSearching ? CrossFadeState.showFirst : CrossFadeState.showSecond,
                  alignment: Alignment.topCenter,
                  sizeCurve: Curves.easeInOut,
                  secondChild: const SizedBox(width: double.infinity, height: 0),
                  firstChild: Container(
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.vertical(bottom: Radius.circular(16)),
                        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2))],
                      ),
                      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),"""
                      
    content = re.sub(animated_size_regex, new_animated_cross_fade, content)

    # Change text field fillColors inside the firstChild
    # Wait, we can just replace `fillColor: Colors.white` with `fillColor: Colors.grey.shade100` everywhere below the AnimatedCrossFade in this block.
    # Actually, let's just do a blanket replace for the `fillColor: Colors.white` in the specific `Positioned` block.
    
    # We can split the string at `// Overlay Layer` to only replace inside the search bar.
    parts = content.split("// Overlay Layer")
    if len(parts) == 2:
        parts[1] = parts[1].replace("fillColor: Colors.white", "fillColor: Colors.grey.shade100")
        parts[1] = parts[1].replace("color: Colors.deepOrange),", "color: Colors.black54),") # Fix the calendar icon color
        content = "// Overlay Layer".join(parts)

    with open('lib/screens/games_screen.dart', 'w') as f:
        f.write(content)

def update_opponent_teams_screen():
    with open('lib/screens/opponent_teams_screen.dart', 'r') as f:
        content = f.read()

    animated_size_regex = r"AnimatedSize\(\s*duration: const Duration\(milliseconds: 200\),\s*curve: Curves\.easeInOut,\s*alignment: Alignment\.topCenter,\s*child: !_isSearching\s*\?\s*const SizedBox\(width: double\.infinity, height: 0\)\s*:\s*Container\(\s*decoration: const BoxDecoration\(\s*color: Colors\.deepOrange,\s*boxShadow: \[BoxShadow\(color: Colors\.black26, blurRadius: 6, offset: Offset\(0, 3\)\)\],\s*\),\s*padding: const EdgeInsets\.fromLTRB\(16, 0, 16, 12\),"

    new_animated_cross_fade = """AnimatedCrossFade(
              duration: const Duration(milliseconds: 200),
              crossFadeState: _isSearching ? CrossFadeState.showFirst : CrossFadeState.showSecond,
              alignment: Alignment.topCenter,
              sizeCurve: Curves.easeInOut,
              secondChild: const SizedBox(width: double.infinity, height: 0),
              firstChild: Container(
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.vertical(bottom: Radius.circular(16)),
                    boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2))],
                  ),
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),"""
                  
    content = re.sub(animated_size_regex, new_animated_cross_fade, content)

    # Change text field fillColors inside the search container
    parts = content.split("Positioned(")
    if len(parts) == 2:
        parts[1] = parts[1].replace("fillColor: Colors.white", "fillColor: Colors.grey.shade100")
        content = "Positioned(".join(parts)

    with open('lib/screens/opponent_teams_screen.dart', 'w') as f:
        f.write(content)

update_games_screen()
update_opponent_teams_screen()
