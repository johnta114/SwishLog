import re

# ================================
# 1. games_screen.dart
# ================================
with open('lib/screens/games_screen.dart', 'r') as f:
    games_content = f.read()

# Capture AnimatedSize block
animated_size_regex = r"(AnimatedSize\([\s\S]*?child: !_isSearching\s*\?\s*const SizedBox\(width: double.infinity, height: 0\)\s*:\s*)Container\(\s*color: Colors\.deepOrange,([\s\S]*?)\n\s*\),\s*\),"
match = re.search(animated_size_regex, games_content)

if match:
    animated_size_prefix = match.group(1)
    container_inner = match.group(2)
    
    new_animated_size = animated_size_prefix + """Container(
                      decoration: const BoxDecoration(
                        color: Colors.deepOrange,
                        boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 6, offset: Offset(0, 3))],
                      ),""" + container_inner + """
                    ),
              ),"""
    
    # Replace the body
    body_start_regex = r"body: _isLoading\s*\?\s*const Center\(child: CircularProgressIndicator\(color: Colors\.deepOrange\)\)\s*:\s*Column\(\s*children: \[\s*AnimatedSize[\s\S]*?\n\s*\),\s*\),\s*(Expanded\([\s\S]*?)\s*\]\s*\)"
    
    body_match = re.search(body_start_regex, games_content)
    if body_match:
        list_content = body_match.group(1)
        
        new_body = f"""body: _isLoading
        ? const Center(child: CircularProgressIndicator(color: Colors.deepOrange))
        : Stack(
            children: [
              Column(
                children: [
                  {list_content}
                ]
              ),
              Positioned(
                top: 0, left: 0, right: 0,
                child: {new_animated_size}
              ),
            ],
          )"""
        games_content = games_content[:body_match.start()] + new_body + games_content[body_match.end():]
        with open('lib/screens/games_screen.dart', 'w') as f:
            f.write(games_content)


# ================================
# 2. opponent_teams_screen.dart
# ================================
with open('lib/screens/opponent_teams_screen.dart', 'r') as f:
    opp_content = f.read()

opp_animated_size_regex = r"(AnimatedSize\([\s\S]*?child: !_isSearching\s*\?\s*const SizedBox\(width: double.infinity, height: 0\)\s*:\s*)Container\(\s*color: Colors\.deepOrange,([\s\S]*?)\n\s*\),\s*\),"
opp_match = re.search(opp_animated_size_regex, opp_content)

if opp_match:
    opp_animated_size_prefix = opp_match.group(1)
    opp_container_inner = opp_match.group(2)
    
    opp_new_animated_size = opp_animated_size_prefix + """Container(
                  decoration: const BoxDecoration(
                    color: Colors.deepOrange,
                    boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 6, offset: Offset(0, 3))],
                  ),""" + opp_container_inner + """
                ),
          ),"""
          
    opp_body_start_regex = r"body: Column\(\s*children: \[\s*AnimatedSize[\s\S]*?\n\s*\),\s*\),\s*// リスト表示\s*(Expanded\([\s\S]*?)\s*\]\s*\)"
    
    opp_body_match = re.search(opp_body_start_regex, opp_content)
    if opp_body_match:
        opp_list_content = opp_body_match.group(1)
        
        opp_new_body = f"""body: Stack(
        children: [
          Column(
            children: [
              // リスト表示
              {opp_list_content}
            ]
          ),
          Positioned(
            top: 0, left: 0, right: 0,
            child: {opp_new_animated_size}
          ),
        ],
      )"""
        opp_content = opp_content[:opp_body_match.start()] + opp_new_body + opp_content[opp_body_match.end():]
        with open('lib/screens/opponent_teams_screen.dart', 'w') as f:
            f.write(opp_content)

