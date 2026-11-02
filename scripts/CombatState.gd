extends RefCounted
class_name CombatState

class MatchStats:
	var cuts := 0
	var gold_cuts := 0
	var cursed_cuts := 0
	var knockdowns := 0
	var times_knocked := 0
	var clashes := 0
	var melee_hits := 0
	var throw_hits := 0
	var orbit_hits := 0
	var fire_hits := 0
	var powerups := 0
	var barriers := 0
	var teleports := 0
	var sprints := 0
	var stealth_pickups := 0
	var shields_blocked := 0


const TAG_DEFS := [
	{"label": "割麦达人", "metric": "cuts", "weight": 1.0},
	{"label": "淘金能手", "metric": "gold_cuts", "weight": 3.0},
	{"label": "毒麦专家", "metric": "cursed_cuts", "weight": 2.5},
	{"label": "破势专家", "metric": "knockdowns", "weight": 5.0},
	{"label": "倒地常客", "metric": "times_knocked", "weight": 4.0},
	{"label": "拼刀高手", "metric": "clashes", "weight": 3.0},
	{"label": "近战狂人", "metric": "melee_hits", "weight": 2.5},
	{"label": "远程狙击", "metric": "throw_hits", "weight": 4.0},
	{"label": "环刃大师", "metric": "orbit_hits", "weight": 4.0},
	{"label": "引火神手", "metric": "fire_hits", "weight": 4.0},
	{"label": "道具收藏家", "metric": "powerups", "weight": 3.0},
	{"label": "结界法师", "metric": "barriers", "weight": 4.0},
	{"label": "空间旅者", "metric": "teleports", "weight": 3.0},
	{"label": "冲刺狂人", "metric": "sprints", "weight": 2.0},
	{"label": "隐身刺客", "metric": "stealth_pickups", "weight": 5.0},
	{"label": "铁壁防御", "metric": "shields_blocked", "weight": 4.0},
]

const FALLBACK_TAG_SETS = [
	["稳扎稳打", "麦田观察员", "节奏大师"],
	["佛系割麦", "和平主义者", "随缘作战"],
	["初出茅庐", "潜力新星", "继续加油"],
]


static func create_stats(max_players: int) -> Array:
	var stats: Array = []
	for _index in range(max_players):
		stats.append(MatchStats.new())
	return stats


static func serialize_stats(stats: MatchStats) -> Dictionary:
	if stats == null:
		return {}
	return {
		"cuts": stats.cuts,
		"gold_cuts": stats.gold_cuts,
		"cursed_cuts": stats.cursed_cuts,
		"knockdowns": stats.knockdowns,
		"times_knocked": stats.times_knocked,
		"clashes": stats.clashes,
		"melee_hits": stats.melee_hits,
		"throw_hits": stats.throw_hits,
		"orbit_hits": stats.orbit_hits,
		"fire_hits": stats.fire_hits,
		"powerups": stats.powerups,
		"barriers": stats.barriers,
		"teleports": stats.teleports,
		"sprints": stats.sprints,
		"stealth_pickups": stats.stealth_pickups,
		"shields_blocked": stats.shields_blocked,
	}


static func apply_stats(stats: MatchStats, data: Dictionary) -> void:
	if stats == null or data.is_empty():
		return
	stats.cuts = int(data.get("cuts", stats.cuts))
	stats.gold_cuts = int(data.get("gold_cuts", stats.gold_cuts))
	stats.cursed_cuts = int(data.get("cursed_cuts", stats.cursed_cuts))
	stats.knockdowns = int(data.get("knockdowns", stats.knockdowns))
	stats.times_knocked = int(data.get("times_knocked", stats.times_knocked))
	stats.clashes = int(data.get("clashes", stats.clashes))
	stats.melee_hits = int(data.get("melee_hits", stats.melee_hits))
	stats.throw_hits = int(data.get("throw_hits", stats.throw_hits))
	stats.orbit_hits = int(data.get("orbit_hits", stats.orbit_hits))
	stats.fire_hits = int(data.get("fire_hits", stats.fire_hits))
	stats.powerups = int(data.get("powerups", stats.powerups))
	stats.barriers = int(data.get("barriers", stats.barriers))
	stats.teleports = int(data.get("teleports", stats.teleports))
	stats.sprints = int(data.get("sprints", stats.sprints))
	stats.stealth_pickups = int(data.get("stealth_pickups", stats.stealth_pickups))
	stats.shields_blocked = int(data.get("shields_blocked", stats.shields_blocked))


static func award_cut_score(match_mode: int, player_id: int, team: int, team_scores: Array[int], player_scores: Array[int], amount: int) -> void:
	if amount <= 0:
		return
	if match_mode == GameSession.MatchMode.FFA and player_id >= 0:
		player_scores[player_id] += amount
	elif team >= 0 and team < team_scores.size():
		team_scores[team] += amount


static func record_cut(stats: MatchStats, special_type: int) -> void:
	if stats == null:
		return
	stats.cuts += 1
	if special_type == 1:
		stats.gold_cuts += 1
	elif special_type == 2:
		stats.cursed_cuts += 1


static func record_hit(attacker: MatchStats, attack_name: String, caused_knockdown: bool) -> void:
	if attacker == null:
		return
	match attack_name:
		"挥镰":
			attacker.melee_hits += 1
		"回旋镰":
			attacker.throw_hits += 1
		"火焰镰":
			attacker.fire_hits += 1
			attacker.throw_hits += 1
		"环镰":
			attacker.orbit_hits += 1
	if caused_knockdown:
		attacker.knockdowns += 1


static func record_knockdown(attacker: MatchStats, victim: MatchStats) -> void:
	if victim != null:
		victim.times_knocked += 1


static func record_clash(a: MatchStats, b: MatchStats) -> void:
	if a != null:
		a.clashes += 1
	if b != null:
		b.clashes += 1


static func record_powerup(stats: MatchStats, kind: int) -> void:
	if stats == null:
		return
	stats.powerups += 1
	if kind == 6:
		stats.stealth_pickups += 1


static func finish_announcement(match_mode: int, team_scores: Array[int], player_scores: Array[int], fighters: Array) -> String:
	if match_mode == GameSession.MatchMode.FFA:
		var best_id := 0
		var best_score := -1
		for index in range(player_scores.size()):
			if player_scores[index] > best_score:
				best_score = player_scores[index]
				best_id = index
		if best_score <= 0:
			return "自由赛平局"
		for fighter in fighters:
			if fighter.player_id == best_id:
				return "%s 在自由赛中获胜！" % fighter.label
		return "自由赛结束"
	if team_scores[0] == team_scores[1]:
		return "平局！双方平分秋色"
	if team_scores[0] > team_scores[1]:
		return "青禾队获胜！"
	return "赤镰队获胜！"


static func winner_headline(match_mode: int, team_scores: Array[int], player_scores: Array[int], fighters: Array) -> String:
	if match_mode == GameSession.MatchMode.FFA:
		var best_id := -1
		var best_score := -1
		for index in range(player_scores.size()):
			if player_scores[index] > best_score:
				best_score = player_scores[index]
				best_id = index
		if best_score <= 0:
			return "本轮平局"
		for fighter in fighters:
			if fighter.player_id == best_id:
				return "%s 获胜！" % fighter.label
		return "本轮结束"
	if team_scores[0] == team_scores[1]:
		return "本轮平局"
	if team_scores[0] > team_scores[1]:
		return "青禾队 获胜！"
	return "赤镰队 获胜！"


static func build_showcase_rows(
	fighters: Array,
	round_scores: Array[int],
	team_scores: Array[int],
	match_mode: int,
	match_stats: Array,
	player_colors: Array
) -> Array[Dictionary]:
	var rows: Array[Dictionary] = []
	for fighter in fighters:
		if fighter.player_id < 0:
			continue
		var round_score := 0
		if fighter.player_id < round_scores.size():
			round_score = round_scores[fighter.player_id]
		var stats: MatchStats = null
		if fighter.player_id < match_stats.size():
			stats = match_stats[fighter.player_id]
		var character: Dictionary = CharacterCatalog.get_character(fighter.character_id)
		rows.append({
			"player_id": fighter.player_id,
			"name": fighter.label,
			"character_id": fighter.character_id,
			"portrait": str(character.get("portrait", "")),
			"score": round_score,
			"team": fighter.team,
			"stats": stats,
			"theme": player_colors[fighter.player_id % player_colors.size()],
		})
	rows.sort_custom(func(a: Dictionary, b: Dictionary) -> bool:
		if int(a["score"]) == int(b["score"]):
			return int(a["player_id"]) < int(b["player_id"])
		return int(a["score"]) > int(b["score"])
	)
	var winner_score: int = 0
	if not rows.is_empty():
		winner_score = int(rows[0]["score"])
	var winning_team := -1
	if match_mode != GameSession.MatchMode.FFA and team_scores.size() >= 2:
		if team_scores[0] > team_scores[1]:
			winning_team = 0
		elif team_scores[1] > team_scores[0]:
			winning_team = 1
	for index in range(rows.size()):
		var row: Dictionary = rows[index]
		row["rank"] = index + 1
		row["is_winner"] = int(row["score"]) == winner_score and winner_score > 0
		if match_mode != GameSession.MatchMode.FFA and winning_team >= 0:
			row["is_winner"] = int(row["team"]) == winning_team
		row["tags"] = assign_tags(row["stats"], int(row["rank"]), rows.size(), bool(row["is_winner"]))
	return _order_showcase_rows(rows)


static func assign_tags(stats: MatchStats, rank: int, total_players: int, is_winner: bool) -> Array[String]:
	var scored: Array[Dictionary] = []
	for tag_def in TAG_DEFS:
		var metric: String = tag_def["metric"]
		var value: float = _metric_value(stats, metric)
		var weighted: float = value * float(tag_def["weight"])
		if weighted <= 0.0:
			continue
		scored.append({
			"label": str(tag_def["label"]),
			"score": weighted,
		})
	scored.sort_custom(func(a: Dictionary, b: Dictionary) -> bool:
		return float(a["score"]) > float(b["score"])
	)
	var tags: Array[String] = []
	for entry in scored:
		if tags.size() >= 3:
			break
		tags.append(str(entry["label"]))
	if is_winner:
		if "麦野之王" not in tags:
			tags.insert(0, "麦野之王")
	elif rank == 1 and tags.size() < 3:
		tags.insert(0, "本轮 MVP")
	if tags.size() < 3:
		var fallback: Array = FALLBACK_TAG_SETS[(rank + total_players) % FALLBACK_TAG_SETS.size()]
		for label in fallback:
			if tags.size() >= 3:
				break
			var tag_label := str(label)
			if tag_label not in tags:
				tags.append(tag_label)
	while tags.size() < 3:
		tags.append("麦田旅人")
	return tags.slice(0, 3)


static func _metric_value(stats: MatchStats, metric: String) -> float:
	if stats == null:
		return 0.0
	match metric:
		"cuts":
			return float(stats.cuts)
		"gold_cuts":
			return float(stats.gold_cuts)
		"cursed_cuts":
			return float(stats.cursed_cuts)
		"knockdowns":
			return float(stats.knockdowns)
		"times_knocked":
			return float(stats.times_knocked)
		"clashes":
			return float(stats.clashes)
		"melee_hits":
			return float(stats.melee_hits)
		"throw_hits":
			return float(stats.throw_hits)
		"orbit_hits":
			return float(stats.orbit_hits)
		"fire_hits":
			return float(stats.fire_hits)
		"powerups":
			return float(stats.powerups)
		"barriers":
			return float(stats.barriers)
		"teleports":
			return float(stats.teleports)
		"sprints":
			return float(stats.sprints)
		"stealth_pickups":
			return float(stats.stealth_pickups)
		"shields_blocked":
			return float(stats.shields_blocked)
	return 0.0


static func _order_showcase_rows(rows: Array[Dictionary]) -> Array[Dictionary]:
	if rows.size() <= 2:
		return rows
	var winner_index := 0
	for index in range(rows.size()):
		if rows[index].get("is_winner", false):
			winner_index = index
			break
	var ordered: Array[Dictionary] = rows.duplicate()
	var winner_row: Dictionary = ordered[winner_index]
	ordered.remove_at(winner_index)
	var center := ordered.size() / 2
	ordered.insert(center, winner_row)
	return ordered
