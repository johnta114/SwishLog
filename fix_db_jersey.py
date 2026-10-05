with open('lib/database/database_helper.dart', 'r') as f:
    content = f.read()

old_query = """      SELECT r.player_id, p.court_name, p.last_name, p.first_name, """
new_query = """      SELECT r.player_id, r.jersey_number, p.court_name, p.last_name, p.first_name, """
content = content.replace(old_query, new_query)

old_group = """      GROUP BY r.player_id, p.court_name, p.last_name, p.first_name"""
new_group = """      GROUP BY r.player_id, r.jersey_number, p.court_name, p.last_name, p.first_name"""
content = content.replace(old_group, new_group)

with open('lib/database/database_helper.dart', 'w') as f:
    f.write(content)
