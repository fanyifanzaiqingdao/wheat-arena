extends Node2D

const MATCH_SECONDS := 120.0
const RESPAWN_SECONDS := 3.0
const SPAWN_SHIELD_RADIUS := 78.0
const TELEPORT_RADIUS := 24.0
const TELEPORT_COOLDOWN := 0.55
const ARENA := Rect2(70.0, 118.0, 1140.0, 530.0)
const CELL_SIZE := 28.0
const GRID_COLS := 40
const GRID_ROWS := 18
const UNIT_RADIUS := 18.0
const FIGHTER_SEPARATION_RADIUS := UNIT_RADIUS * 2.05
const MOVE_SPEED := 205.0
const CUT_RADIUS := 42.0
const ATTACK_RANGE := 64.0
const AI_CHASE_STANDOFF := ATTACK_RANGE * 0.58
const ATTACK_COOLDOWN := 0.62
const CLASH_WINDOW := 0.24
const BLADE_SPIRIT_MAX := 3
const CLASH_KNOCKBACK := 42.0
const BULLET_TIME_DURATION := 0.62
const BULLET_TIME_SCALE := 0.18
const THROW_SPEED := 380.0
const THROW_RETURN_SPEED := 460.0
const THROW_MAX_RANGE := 200.0
const THROW_COOLDOWN := 0.42
const THROW_HIT_RADIUS := 22.0
const THROW_CATCH_RADIUS := 30.0
const THROW_CHARGE_MAX := 1.15
const THROW_CHARGE_MIN := 0.08
const SICKLE_CLASH_RADIUS := 26.0
const SICKLE_FRAME_SIZE := 56
const SICKLE_FRAME_COUNT := 8
const SICKLE_SHEET_PATH := "res://assets/weapons/sickle/sheet.png"
const MAX_SICKLES_PER_FIGHTER := 12
const SICKLE_FORK_ANGLES := [-0.38, 0.0, 0.38]
const FIRE_BURN_RADIUS := 34.0
const FIRE_EMBER_LIFE := 0.55
const SPRINT_SPEED := 520.0
const SPRINT_DURATION := 0.3
const SPRINT_COOLDOWN := 0.75
const POWERUP_RADIUS := 18.0
const POWERUP_PICKUP_RADIUS := 30.0
const POWERUP_SPAWN_INTERVAL := 7.5
const MAX_POWERUPS := 5
const POWERUP_SHIELD := 0
const POWERUP_FIRE := 1
const POWERUP_BARRIER := 2
const POWERUP_SPLIT := 3
const POWERUP_PHASE_SPRINT := 4
const POWERUP_ORBIT_RING := 5
const POWERUP_STEALTH := 6
const INVISIBILITY_DURATION := 20.0
const ORBIT_RING_COUNT := 2
const ORBIT_RING_RADIUS := 42.0
const ORBIT_RING_SPEED := 3.4
const ORBIT_RING_HIT_RADIUS := 20.0
const ORBIT_RING_HIT_COOLDOWN := 0.38
const BARRIER_RADIUS := 88.0
const BARRIER_DURATION := 10.0
const BARRIER_SEAL_TIME := 1.4
const MAX_BARRIER_ZONES := 4
const WHEAT_BLADES_PER_CELL := 7
const WHEAT_BEND_RADIUS := 72.0
const WHEAT_REGROW_SECONDS := 20.0
const SPECIAL_WHEAT_NONE := 0
const SPECIAL_WHEAT_GOLD := 1
const SPECIAL_WHEAT_CURSED := 2
const SPECIAL_WHEAT_GOLD_SCORE := 2
const SPECIAL_WHEAT_GOLD_COUNT := 10
const SPECIAL_WHEAT_CURSED_COUNT := 8
const SPECIAL_WHEAT_SPAWN_CLEARANCE := 95.0
const CURSED_BLADE_SPIRIT_PENALTY := 1
const CURSED_SLOW_DURATION := 1.25
const CURSED_SLOW_SCALE := 0.52
const CHARACTER_MANIFEST_PATH := "res://assets/characters/manifest.json"
const CHARACTER_FRAME_SIZE := 64
const CHARACTER_FRAME_COUNT := 6
const CHARACTER_SPRITE_ANCHOR_Y := 24.0
const CHARACTER_SHADOW_OFFSET := Vector2(0, 4)
const MAP_COUNT := 6
const MAP_NAMES := [
	"麦野双圃",
	"丛林伏击",
	"烘焙厨房",
	"庙宇天井",
	"断桥急流",
	"擀面长廊",
]
const MAP_GRASS := [
	Color("#68c779"),
	Color("#5ea866"),
	Color("#8ecf7a"),
	Color("#79b888"),
	Color("#62b5a0"),
	Color("#d8c89a"),
]
const MAP_ACCENT := [
	Color("#7bd486"),
	Color("#3f7d4d"),
	Color("#c98545"),
	Color("#9aa7b8"),
	Color("#3d8fbe"),
	Color("#b58e62"),
]

const TEAM_COLORS := [
	Color("#31b7e9"),
	Color("#ef5b76"),
]
const TEAM_DARK := [
	Color("#0e6385"),
	Color("#982d48"),
]
const PLAYER_COLORS := [
	Color("#31b7e9"),
	Color("#ef5b76"),
	Color("#f5c542"),
	Color("#9b59b6"),
	Color("#2ecc71"),
	Color("#e67e22"),
	Color("#1abc9c"),
	Color("#e84393"),
]
const MAX_PLAYERS := 8
const STATE_SYNC_INTERVAL := 0.05
const FULL_WHEAT_SYNC_INTERVAL := 1.0
const INTERP_DURATION := 0.11
const LOCAL_CORRECTION_STRENGTH := 0.22
const NETWORK_PORT := 7777
const GRASS := Color("#68c779")
const GRASS_DARK := Color("#48a968")
const GRASS_LIGHT := Color("#7bd486")
const WHEAT := Color("#e5e74e")
const WHEAT_LIGHT := Color("#f2ef69")
const WHEAT_DARK := Color("#b6ce49")
const STRAW := Color("#c9bd55")

const Fighter = FighterModel.Fighter
const HarvestSpark = FighterModel.HarvestSpark
const ThrownSickle = FighterModel.ThrownSickle
const PowerUp = FighterModel.PowerUp
const TeleportPortal = FighterModel.TeleportPortal
const FireEmber = FighterModel.FireEmber
const BarrierZone = FighterModel.BarrierZone
const ClashEffect = FighterModel.ClashEffect
const FighterInterp = FighterModel.FighterInterp
const WheatBlade = FighterModel.WheatBlade

var fighters: Array[Fighter] = []
var territory: Array[int] = []
var regrow_timers: Array[float] = []
var wheat_mask: Array[bool] = []
var wall_mask: Array[bool] = []
var water_mask: Array[bool] = []
var special_wheat: Array[int] = []
var current_map_index := 0
var map_tab_down := false
var wheat_blades: Array[WheatBlade] = []
var sickle_texture: Texture2D
var harvest_sparks: Array[HarvestSpark] = []
var thrown_sickles: Array[ThrownSickle] = []
var powerups: Array[PowerUp] = []
var fire_embers: Array[FireEmber] = []
var barrier_zones: Array[BarrierZone] = []
var clash_effects: Array[ClashEffect] = []
var map_teleports: Array[TeleportPortal] = []
var powerup_spawn_timer := 4.0
var bullet_time_timer := 0.0
var team_scores: Array[int] = [0, 0]
var player_scores: Array[int] = []
var match_mode := GameSession.MatchMode.TEAM
var network_inputs: Dictionary = {}
var state_sync_timer := 0.0
var full_wheat_sync_timer := 0.0
var force_full_wheat_sync := true
var dirty_wheat_cells: Dictionary = {}
var pending_visual_events: Array[Dictionary] = []
var local_throw_down := false
var local_barrier_down := false
var fighter_interps: Dictionary = {}
var match_time := MATCH_SECONDS
var match_over := false
var countdown := 3.0
var announcement := ""
var announcement_timer := 0.0
var screen_shake := 0.0
var rng := RandomNumberGenerator.new()
var match_end_layer: CanvasLayer
var match_end_winner_label: Label
var match_end_subtitle_label: Label
var match_end_cards_host: HBoxContainer
var match_end_action_button: Button
var match_stats: Array = []


func _ready() -> void:
	rng.randomize()
	_load_sickle_texture()
	_build_match_end_ui()
	territory.resize(GRID_COLS * GRID_ROWS)
	regrow_timers.resize(GRID_COLS * GRID_ROWS)
	wheat_mask.resize(GRID_COLS * GRID_ROWS)
	wall_mask.resize(GRID_COLS * GRID_ROWS)
	water_mask.resize(GRID_COLS * GRID_ROWS)
	special_wheat.resize(GRID_COLS * GRID_ROWS)
	special_wheat.fill(SPECIAL_WHEAT_NONE)
	player_scores.resize(MAX_PLAYERS)
	_init_match_stats()
	if GameSession.online:
		current_map_index = GameSession.map_index
		match_mode = GameSession.mode
	else:
		current_map_index = rng.randi_range(0, MAP_COUNT - 1)
	_apply_map(current_map_index)
	if GameSession.online:
		announcement = "联机对战 · %s" % MAP_NAMES[current_map_index]
	else:
		announcement = "地图：%s · 金麦+2分 毒麦降意" % MAP_NAMES[current_map_index]
	announcement_timer = 2.0
	queue_redraw()


func _init_match_stats() -> void:
	match_stats = CombatState.create_stats(MAX_PLAYERS)


func _stats_for(fighter: Fighter) -> CombatState.MatchStats:
	if fighter == null or fighter.player_id < 0 or fighter.player_id >= match_stats.size():
		return null
	return match_stats[fighter.player_id]


func _build_match_end_ui() -> void:
	match_end_layer = CanvasLayer.new()
	match_end_layer.layer = 20
	match_end_layer.visible = false
	add_child(match_end_layer)

	var backdrop := ColorRect.new()
	backdrop.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	backdrop.color = Color("#070a10d9")
	backdrop.mouse_filter = Control.MOUSE_FILTER_STOP
	match_end_layer.add_child(backdrop)

	var root := MarginContainer.new()
	root.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	root.add_theme_constant_override("margin_left", 28)
	root.add_theme_constant_override("margin_top", 24)
	root.add_theme_constant_override("margin_right", 28)
	root.add_theme_constant_override("margin_bottom", 24)
	match_end_layer.add_child(root)

	var layout := VBoxContainer.new()
	layout.add_theme_constant_override("separation", 18)
	root.add_child(layout)

	match_end_winner_label = Label.new()
	match_end_winner_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	match_end_winner_label.add_theme_font_size_override("font_size", 42)
	match_end_winner_label.add_theme_color_override("font_color", Color("#8fe38a"))
	layout.add_child(match_end_winner_label)

	match_end_subtitle_label = Label.new()
	match_end_subtitle_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	match_end_subtitle_label.modulate = Color("#d5eccf")
	layout.add_child(match_end_subtitle_label)

	var scroll := ScrollContainer.new()
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_AUTO
	scroll.vertical_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	layout.add_child(scroll)

	match_end_cards_host = HBoxContainer.new()
	match_end_cards_host.alignment = BoxContainer.ALIGNMENT_CENTER
	match_end_cards_host.add_theme_constant_override("separation", 14)
	scroll.add_child(match_end_cards_host)

	var buttons := HBoxContainer.new()
	buttons.alignment = BoxContainer.ALIGNMENT_CENTER
	buttons.add_theme_constant_override("separation", 16)
	layout.add_child(buttons)

	var retry_button := Button.new()
	retry_button.text = "再来一局"
	retry_button.custom_minimum_size = Vector2(160, 42)
	retry_button.pressed.connect(_restart_match)
	buttons.add_child(retry_button)
	match_end_action_button = retry_button

	var lobby_button := Button.new()
	lobby_button.text = "返回大厅"
	lobby_button.custom_minimum_size = Vector2(160, 42)
	lobby_button.pressed.connect(_return_to_lobby)
	buttons.add_child(lobby_button)

	var hint := Label.new()
	hint.text = "快捷键：R 再来一局 · Esc 返回大厅 · F11 全屏"
	hint.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	hint.add_theme_font_size_override("font_size", 14)
	hint.modulate = Color("#aeb9c8")
	layout.add_child(hint)


func _clear_showcase_cards() -> void:
	if match_end_cards_host == null:
		return
	for child in match_end_cards_host.get_children():
		child.queue_free()


func _make_showcase_card(row: Dictionary) -> PanelContainer:
	var card := PanelContainer.new()
	card.custom_minimum_size = Vector2(132, 300)

	var style := StyleBoxFlat.new()
	style.set_corner_radius_all(10)
	if row.get("is_winner", false):
		style.bg_color = Color("#3f7d4d")
		style.border_color = Color("#fff3b0")
		style.set_border_width_all(3)
	else:
		style.bg_color = Color("#31483f")
		style.border_color = row.get("theme", Color("#58e6a0"))
		style.set_border_width_all(2)
	card.add_theme_stylebox_override("panel", style)

	var content := VBoxContainer.new()
	content.add_theme_constant_override("separation", 8)
	content.alignment = BoxContainer.ALIGNMENT_CENTER
	card.add_child(content)

	var header := Control.new()
	header.custom_minimum_size = Vector2(0, 24)
	content.add_child(header)

	var rank_label := Label.new()
	rank_label.text = str(row.get("rank", 0))
	rank_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	rank_label.set_anchors_and_offsets_preset(Control.PRESET_TOP_RIGHT)
	rank_label.offset_left = -36
	rank_label.offset_top = 0
	rank_label.offset_right = -8
	rank_label.add_theme_font_size_override("font_size", 18)
	header.add_child(rank_label)

	if row.get("is_winner", false):
		var crown := Label.new()
		crown.text = "👑"
		crown.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
		crown.set_anchors_and_offsets_preset(Control.PRESET_TOP_LEFT)
		crown.offset_left = 8
		header.add_child(crown)

	var portrait_wrap := CenterContainer.new()
	content.add_child(portrait_wrap)

	var portrait := TextureRect.new()
	portrait.custom_minimum_size = Vector2(88, 88)
	portrait.expand_mode = TextureRect.EXPAND_FIT_WIDTH_PROPORTIONAL
	portrait.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	portrait.texture = CharacterCatalog.load_texture(str(row.get("portrait", "")))
	portrait_wrap.add_child(portrait)

	var name_label := Label.new()
	name_label.text = str(row.get("name", ""))
	name_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	name_label.add_theme_font_size_override("font_size", 18)
	content.add_child(name_label)

	var score_label := Label.new()
	score_label.text = "本轮 %d 分" % int(row.get("score", 0))
	score_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	score_label.modulate = Color("#d5eccf")
	content.add_child(score_label)

	var tags: Array = row.get("tags", [])
	var tag_colors := [
		Color("#7ce8ff"),
		Color("#ff8a8a"),
		Color("#ffd166"),
	]
	for tag_index in range(mini(tags.size(), 3)):
		var tag_panel := PanelContainer.new()
		var tag_style := StyleBoxFlat.new()
		tag_style.bg_color = tag_colors[tag_index % tag_colors.size()]
		tag_style.set_corner_radius_all(6)
		tag_panel.add_theme_stylebox_override("panel", tag_style)
		var tag_label := Label.new()
		tag_label.text = str(tags[tag_index])
		tag_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		tag_label.add_theme_font_size_override("font_size", 12)
		tag_label.add_theme_color_override("font_color", Color("#173a31"))
		tag_panel.add_child(tag_label)
		content.add_child(tag_panel)

	return card


func _show_match_end_ui() -> void:
	var showcase_rows := CombatState.build_showcase_rows(
		fighters,
		player_scores,
		team_scores,
		match_mode,
		match_stats,
		PLAYER_COLORS
	)
	if match_end_winner_label != null:
		match_end_winner_label.text = CombatState.winner_headline(match_mode, team_scores, player_scores, fighters)
	if match_end_subtitle_label != null:
		match_end_subtitle_label.text = "第 %d / %d 轮 · %s" % [
			GameSession.current_round,
			GameSession.total_rounds,
			MAP_NAMES[current_map_index],
		]
	if match_end_action_button != null:
		match_end_action_button.text = "下一轮" if GameSession.has_next_round() else "重新开始系列赛"
	_clear_showcase_cards()
	for row in showcase_rows:
		if match_end_cards_host != null:
			match_end_cards_host.add_child(_make_showcase_card(row))
	if match_end_layer != null:
		match_end_layer.visible = true


func _round_result_text() -> String:
	if match_mode == GameSession.MatchMode.FFA:
		var lines: Array[String] = ["本轮排名："]
		for row in _player_ranking_rows(player_scores):
			lines.append("%d. %s  本轮 %d  累计 %d" % [
				lines.size(),
				row["name"],
				row["round"],
				row["total"],
			])
		return "\n".join(lines)
	var blue_round := team_scores[0]
	var red_round := team_scores[1]
	var blue_total := GameSession.cumulative_team_scores[0]
	var red_total := GameSession.cumulative_team_scores[1]
	var leader := "暂时平局"
	if blue_total > red_total:
		leader = "累计领先：青禾队"
	elif red_total > blue_total:
		leader = "累计领先：赤镰队"
	return "本轮：青禾队 %d : %d 赤镰队\n累计：青禾队 %d : %d 赤镰队\n%s" % [
		blue_round,
		red_round,
		blue_total,
		red_total,
		leader,
	]


func _player_ranking_rows(round_scores: Array[int]) -> Array[Dictionary]:
	var rows: Array[Dictionary] = []
	for fighter in fighters:
		if fighter.player_id < 0:
			continue
		rows.append({
			"name": fighter.label,
			"round": round_scores[fighter.player_id] if fighter.player_id < round_scores.size() else 0,
			"total": GameSession.cumulative_player_scores[fighter.player_id] if fighter.player_id < GameSession.cumulative_player_scores.size() else 0,
		})
	rows.sort_custom(func(a: Dictionary, b: Dictionary) -> bool:
		if int(a["total"]) == int(b["total"]):
			return int(a["round"]) > int(b["round"])
		return int(a["total"]) > int(b["total"])
	)
	return rows


func _input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo:
		if event.keycode == KEY_F11:
			GameSession.toggle_fullscreen()
			get_viewport().set_input_as_handled()
			return
	if not match_over:
		return
	if event is InputEventKey and event.pressed and not event.echo:
		if event.keycode == KEY_R:
			_restart_match()
			get_viewport().set_input_as_handled()
		elif event.keycode == KEY_ESCAPE:
			_return_to_lobby()
			get_viewport().set_input_as_handled()


func _restart_match() -> void:
	if _is_online():
		if _is_network_server():
			if GameSession.has_next_round():
				GameSession.advance_round()
			else:
				GameSession.reset_series()
			GameSession._start_match.rpc()
		else:
			announcement = "请由主机发起新对局，或返回大厅"
			announcement_timer = 2.0
		return
	if GameSession.has_next_round():
		GameSession.advance_round()
	else:
		GameSession.reset_series()
	GameSession.launch_match()


func _return_to_lobby() -> void:
	if _is_online():
		GameSession.disconnect_game()
	get_tree().change_scene_to_file("res://scenes/Lobby.tscn")


func _is_online() -> bool:
	return GameSession.online and multiplayer.multiplayer_peer != null


func _is_network_server() -> bool:
	return _is_online() and multiplayer.is_server()


func _load_texture_resource(path: String) -> Texture2D:
	if path == "":
		return null
	var texture := load(path) as Texture2D
	if texture != null:
		return texture
	var image := Image.new()
	if image.load(path) != OK:
		return null
	return ImageTexture.create_from_image(image)


func _load_sickle_texture() -> void:
	sickle_texture = _load_texture_resource(SICKLE_SHEET_PATH)


func _is_local_fighter(fighter: Fighter) -> bool:
	if GameSession.my_player_id >= 0:
		return fighter.player_id == GameSession.my_player_id
	if not GameSession.online:
		return not fighter.ai
	return false


func _is_stealthed(fighter: Fighter) -> bool:
	return fighter.invisibility_timer > 0.0


func _fighter_draw_modulate(fighter: Fighter) -> Color:
	if not _is_stealthed(fighter):
		return Color.WHITE
	if _is_local_fighter(fighter):
		return Color(1.0, 1.0, 1.0, 0.42)
	return Color(1.0, 1.0, 1.0, 0.1)


func _are_allies(a: Fighter, b: Fighter) -> bool:
	if a == b:
		return true
	if match_mode == GameSession.MatchMode.FFA:
		return a.player_id == b.player_id
	return a.team == b.team


func _fighter_color(fighter: Fighter) -> Color:
	if match_mode == GameSession.MatchMode.FFA and fighter.player_id >= 0:
		return PLAYER_COLORS[fighter.player_id % PLAYER_COLORS.size()]
	return TEAM_COLORS[fighter.team % TEAM_COLORS.size()]


func _fighter_dark_color(fighter: Fighter) -> Color:
	if match_mode == GameSession.MatchMode.FFA and fighter.player_id >= 0:
		return _fighter_color(fighter).darkened(0.35)
	return TEAM_DARK[fighter.team % TEAM_DARK.size()]


func _award_cut_score(fighter: Fighter, amount: int = 1) -> void:
	CombatState.award_cut_score(match_mode, fighter.player_id, fighter.team, team_scores, player_scores, amount)


func _fighter_move_speed(fighter: Fighter) -> float:
	var speed := SPRINT_SPEED if fighter.sprint_timer > 0.0 else MOVE_SPEED
	if fighter.curse_slow_timer > 0.0:
		speed *= CURSED_SLOW_SCALE
	return speed


func _spawn_fighter(team: int, fighter_name: String, at: Vector2, is_ai: bool, player_id: int = -1, peer_id: int = 0) -> void:
	var fighter := Fighter.new()
	fighter.player_id = player_id
	fighter.peer_id = peer_id
	fighter.team = team
	fighter.label = fighter_name
	fighter.position = at
	fighter.spawn_position = at
	fighter.ai = is_ai
	fighter.anim_seed = rng.randf_range(0.0, TAU)
	var character_id := GameSession.resolve_character_id(player_id)
	if character_id != "" and CharacterCatalog.has_character(character_id):
		fighter.character_id = character_id
	elif not CharacterCatalog.characters.is_empty():
		var character_index := player_id if player_id >= 0 else fighters.size()
		var character: Dictionary = CharacterCatalog.get_by_index(character_index)
		fighter.character_id = character.get("id", "")
	fighters.append(fighter)


func _process(delta: float) -> void:
	if match_over:
		queue_redraw()
		return

	if countdown > 0.0:
		var tab_now := Input.is_key_pressed(KEY_TAB)
		if tab_now and not map_tab_down and (not _is_online() or _is_network_server()):
			_cycle_map(1)
			if _is_network_server():
				GameSession.map_index = current_map_index
		map_tab_down = tab_now
		countdown = maxf(0.0, countdown - delta)
		if _is_network_server():
			_broadcast_state()
		queue_redraw()
		return

	if _is_online() and not _is_network_server():
		_send_local_input()
		_update_client_interpolation(delta)
		_update_orbit_ring_visuals(delta)
		_update_clash_effects(delta)
		_update_harvest_sparks(delta)
		_update_fire_embers(delta)
		announcement_timer = maxf(0.0, announcement_timer - delta)
		screen_shake = maxf(0.0, screen_shake - delta)
		queue_redraw()
		return

	match_time = maxf(0.0, match_time - delta)
	if match_time <= 0.0:
		_finish_match()
		return

	var real_delta := delta
	if bullet_time_timer > 0.0:
		bullet_time_timer = maxf(0.0, bullet_time_timer - real_delta)
		delta *= BULLET_TIME_SCALE

	announcement_timer = maxf(0.0, announcement_timer - delta)
	screen_shake = maxf(0.0, screen_shake - delta)
	_update_clash_effects(delta)
	_update_regrowth(delta)
	_update_harvest_sparks(delta)
	_update_fire_embers(delta)
	_update_thrown_sickles(delta)
	_update_barrier_zones(delta)
	_update_powerups(delta)
	_update_orbit_rings(delta)
	for fighter in fighters:
		_update_fighter(fighter, delta)
	_resolve_fighter_overlaps()
	if _is_network_server():
		state_sync_timer += delta
		full_wheat_sync_timer += delta
		if full_wheat_sync_timer >= FULL_WHEAT_SYNC_INTERVAL:
			full_wheat_sync_timer = 0.0
			force_full_wheat_sync = true
		if state_sync_timer >= STATE_SYNC_INTERVAL:
			state_sync_timer = 0.0
			_broadcast_state()
	queue_redraw()


func _update_fighter(fighter: Fighter, delta: float) -> void:
	fighter.attack_cooldown = maxf(0.0, fighter.attack_cooldown - delta)
	fighter.attack_flash = maxf(0.0, fighter.attack_flash - delta)
	fighter.attack_active = maxf(0.0, fighter.attack_active - delta)
	fighter.clash_flash = maxf(0.0, fighter.clash_flash - delta)
	fighter.clash_immunity = maxf(0.0, fighter.clash_immunity - delta)
	fighter.throw_cooldown = maxf(0.0, fighter.throw_cooldown - delta)
	fighter.throw_flash = maxf(0.0, fighter.throw_flash - delta)
	fighter.shield_flash = maxf(0.0, fighter.shield_flash - delta)
	fighter.sprint_timer = maxf(0.0, fighter.sprint_timer - delta)
	if fighter.sprint_timer <= 0.0:
		fighter.phase_sprint_active = false
	fighter.sprint_cooldown = maxf(0.0, fighter.sprint_cooldown - delta)
	fighter.teleport_cooldown = maxf(0.0, fighter.teleport_cooldown - delta)
	fighter.harvest_timer = maxf(0.0, fighter.harvest_timer - delta)
	fighter.curse_slow_timer = maxf(0.0, fighter.curse_slow_timer - delta)
	fighter.invisibility_timer = maxf(0.0, fighter.invisibility_timer - delta)
	if fighter.harvest_timer > 0.0:
		fighter.harvest_phase += delta * 15.0
	if fighter.respawn_timer > 0.0:
		fighter.respawn_timer = maxf(0.0, fighter.respawn_timer - delta)
		if fighter.respawn_timer <= 0.0:
			fighter.position = fighter.spawn_position
			fighter.blade_spirit = BLADE_SPIRIT_MAX
			announcement = "%s 已重返麦田" % fighter.label
			announcement_timer = 1.2
		return

	var wants_attack := false
	var throw_hold := false
	var throw_release := false
	var wants_sprint := false
	var wants_barrier := false
	if fighter.ai:
		var ai_actions := _update_ai(fighter, delta)
		wants_attack = ai_actions[0]
		throw_hold = ai_actions[1]
		wants_sprint = ai_actions[2]
		wants_barrier = ai_actions[3]
		if throw_hold:
			if not fighter.throw_charging and fighter.throw_cooldown <= 0.0 and _can_throw(fighter):
				fighter.throw_charging = true
				fighter.throw_charge = 0.0
			elif fighter.throw_charging and fighter.throw_charge >= rng.randf_range(0.42, 0.95):
				throw_release = true
		elif fighter.throw_charging:
			throw_release = true
	elif _is_online() and _is_network_server():
		var input_data: Dictionary = network_inputs.get(fighter.player_id, {})
		if _is_local_fighter(fighter):
			input_data = _read_local_input_dict()
		wants_attack = input_data.get("attack", false)
		throw_hold = input_data.get("throw_hold", false)
		throw_release = input_data.get("throw_release", false)
		wants_sprint = input_data.get("sprint", false)
		wants_barrier = input_data.get("barrier", false)
		var move_vector: Vector2 = input_data.get("move", Vector2.ZERO)
		var aim_vector: Vector2 = input_data.get("aim", fighter.aim)
		var move_speed := _fighter_move_speed(fighter)
		fighter.velocity = move_vector * move_speed
		if aim_vector.length_squared() > 0.01:
			fighter.aim = aim_vector.normalized()
	elif not _is_online():
		var input_vector := Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
		if Input.is_key_pressed(KEY_A):
			input_vector.x -= 1.0
		if Input.is_key_pressed(KEY_D):
			input_vector.x += 1.0
		if Input.is_key_pressed(KEY_W):
			input_vector.y -= 1.0
		if Input.is_key_pressed(KEY_S):
			input_vector.y += 1.0
		input_vector = input_vector.normalized()
		var move_speed := _fighter_move_speed(fighter)
		fighter.velocity = input_vector * move_speed
		var mouse_direction := get_global_mouse_position() - fighter.position
		if mouse_direction.length_squared() > 1.0:
			fighter.aim = mouse_direction.normalized()
		wants_attack = Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT)
		var throw_now := Input.is_key_pressed(KEY_ENTER) or Input.is_key_pressed(KEY_KP_ENTER)
		throw_release = fighter.throw_input_down and not throw_now
		throw_hold = throw_now
		fighter.throw_input_down = throw_now
		var sprint_now := Input.is_key_pressed(KEY_SPACE)
		wants_sprint = sprint_now and fighter.sprint_cooldown <= 0.0 and fighter.sprint_timer <= 0.0 and input_vector.length_squared() > 0.01
		var barrier_now := Input.is_key_pressed(KEY_Q)
		wants_barrier = barrier_now and not fighter.barrier_input_down
		fighter.barrier_input_down = barrier_now
	else:
		return

	_update_throw_input(fighter, throw_hold, throw_release, delta)

	var previous_position := fighter.position
	fighter.position += fighter.velocity * delta
	_clamp_fighter_to_arena(fighter)
	_apply_barrier_constraints(fighter, previous_position)
	_apply_spawn_shield_constraints(fighter, previous_position)
	_apply_wall_constraints(fighter, previous_position)
	_clamp_fighter_to_arena(fighter)
	_check_teleports(fighter)
	_cut_wheat(fighter)
	_try_pickup_powerup(fighter)
	if wants_sprint:
		_activate_sprint(fighter)
	if wants_barrier:
		_deploy_barrier(fighter)
	if wants_attack:
		_attack(fighter)


func _update_throw_input(fighter: Fighter, throw_hold: bool, throw_release: bool, delta: float) -> void:
	if throw_release and fighter.throw_charging:
		_release_throw(fighter)
		return
	if throw_hold:
		if not fighter.throw_charging and fighter.throw_cooldown <= 0.0 and _can_throw(fighter):
			fighter.throw_charging = true
			fighter.throw_charge = 0.0
		if fighter.throw_charging:
			fighter.throw_charge = minf(fighter.throw_charge + delta, THROW_CHARGE_MAX)


func _can_throw(fighter: Fighter) -> bool:
	var in_flight := _fighter_sickle_count(fighter)
	if fighter.split_sickle_charges > 0:
		return in_flight + SICKLE_FORK_ANGLES.size() <= MAX_SICKLES_PER_FIGHTER
	return in_flight < 1


func _throw_fork_angles(fighter: Fighter) -> Array:
	if fighter.split_sickle_charges > 0:
		fighter.split_sickle_charges -= 1
		return SICKLE_FORK_ANGLES
	return [0.0]


func _release_throw(fighter: Fighter) -> void:
	if fighter.throw_charge < THROW_CHARGE_MIN:
		fighter.throw_charging = false
		fighter.throw_charge = 0.0
		return
	_throw_sickle(fighter, fighter.throw_charge)
	fighter.throw_charging = false
	fighter.throw_charge = 0.0


func _throw_charge_power(charge_seconds: float) -> float:
	return clampf(charge_seconds / THROW_CHARGE_MAX, 0.0, 1.0)


func _activate_sprint(fighter: Fighter) -> void:
	if fighter.sprint_cooldown > 0.0 or fighter.sprint_timer > 0.0:
		return
	fighter.phase_sprint_active = fighter.phase_sprint_charges > 0
	if fighter.phase_sprint_active:
		fighter.phase_sprint_charges -= 1
	fighter.sprint_timer = SPRINT_DURATION
	fighter.sprint_cooldown = SPRINT_COOLDOWN
	var sprint_stats := _stats_for(fighter)
	if sprint_stats != null:
		sprint_stats.sprints += 1
	if fighter.velocity.length_squared() < 1.0:
		fighter.velocity = fighter.aim * SPRINT_SPEED
	else:
		fighter.velocity = fighter.velocity.normalized() * SPRINT_SPEED


func _update_ai(fighter: Fighter, delta: float) -> Array:
	fighter.target_refresh -= delta
	if fighter.target_refresh <= 0.0:
		fighter.target_refresh = rng.randf_range(0.35, 0.75)
		fighter.target_cell = _find_ai_target(fighter)

	var target_position := _cell_center(fighter.target_cell)
	var nearest_enemy := _nearest_enemy(fighter)
	var nearest_powerup := _nearest_powerup(fighter)
	var should_attack := false
	var should_throw := false
	var should_sprint := false
	var should_barrier := false
	if nearest_powerup != null and fighter.position.distance_to(nearest_powerup.position) < 260.0:
		target_position = nearest_powerup.position
		if fighter.position.distance_to(nearest_powerup.position) < POWERUP_PICKUP_RADIUS + 12.0:
			should_sprint = fighter.sprint_cooldown <= 0.0 and fighter.sprint_timer <= 0.0
	elif nearest_enemy != null:
		var enemy_distance := fighter.position.distance_to(nearest_enemy.position)
		var standoff := maxf(AI_CHASE_STANDOFF, FIGHTER_SEPARATION_RADIUS * 0.55)
		if enemy_distance < 190.0:
			var to_enemy := nearest_enemy.position - fighter.position
			if to_enemy.length_squared() < 0.01:
				to_enemy = Vector2.RIGHT.rotated(fighter.anim_seed * 3.0)
			if enemy_distance > standoff + 8.0:
				target_position = nearest_enemy.position
			else:
				target_position = nearest_enemy.position - to_enemy.normalized() * standoff
		if enemy_distance <= ATTACK_RANGE + 8.0:
			should_attack = true
		elif enemy_distance <= THROW_MAX_RANGE - 20.0:
			should_throw = true
		should_sprint = fighter.sprint_cooldown <= 0.0 and fighter.sprint_timer <= 0.0 and enemy_distance > ATTACK_RANGE + 20.0
		should_barrier = fighter.barrier_charges > 0 and enemy_distance < 170.0

	var direction := target_position - fighter.position
	var move_speed := _fighter_move_speed(fighter)
	if direction.length_squared() > 9.0:
		fighter.aim = direction.normalized()
		fighter.velocity = fighter.aim * move_speed * 0.82
	else:
		fighter.velocity = Vector2.ZERO
	return [should_attack, should_throw, should_sprint, should_barrier]


func _find_ai_target(fighter: Fighter) -> Vector2i:
	var best := Vector2i(GRID_COLS / 2, GRID_ROWS / 2)
	var best_score := -INF
	for sample in range(40):
		var cell := Vector2i(rng.randi_range(0, GRID_COLS - 1), rng.randi_range(0, GRID_ROWS - 1))
		if not wheat_mask[_cell_index(cell)]:
			continue
		var owner := territory[_cell_index(cell)]
		if owner != -1:
			continue
		var distance_penalty := fighter.position.distance_to(_cell_center(cell)) * 0.006
		var value := 3.0 - distance_penalty
		var special := special_wheat[_cell_index(cell)]
		if special == SPECIAL_WHEAT_GOLD:
			value += 4.5
		elif special == SPECIAL_WHEAT_CURSED:
			value -= 3.5
		value += rng.randf_range(0.0, 0.8)
		if value > best_score:
			best_score = value
			best = cell
	return best


func _nearest_enemy(fighter: Fighter) -> Fighter:
	var nearest: Fighter = null
	var nearest_distance := INF
	for other in fighters:
		if _are_allies(fighter, other) or other.respawn_timer > 0.0 or _is_stealthed(other):
			continue
		var distance := fighter.position.distance_squared_to(other.position)
		if distance < nearest_distance:
			nearest_distance = distance
			nearest = other
	return nearest


func _nearest_powerup(fighter: Fighter) -> PowerUp:
	var nearest: PowerUp = null
	var nearest_distance := INF
	for powerup in powerups:
		var distance := fighter.position.distance_squared_to(powerup.position)
		if distance < nearest_distance:
			nearest_distance = distance
			nearest = powerup
	return nearest


func _cut_wheat(fighter: Fighter) -> void:
	var center_cell := _position_to_cell(fighter.position)
	var cell_radius := ceili(CUT_RADIUS / CELL_SIZE)
	var newly_cut := 0
	var cut_gold := false
	var cut_cursed := false
	for y in range(center_cell.y - cell_radius, center_cell.y + cell_radius + 1):
		for x in range(center_cell.x - cell_radius, center_cell.x + cell_radius + 1):
			if x < 0 or x >= GRID_COLS or y < 0 or y >= GRID_ROWS:
				continue
			var cell := Vector2i(x, y)
			if not wheat_mask[_cell_index(cell)]:
				continue
			if _cell_center(cell).distance_to(fighter.position) <= CUT_RADIUS:
				if territory[_cell_index(cell)] == -1:
					newly_cut += 1
					var special := _claim_wheat_cell(fighter, cell)
					if special == SPECIAL_WHEAT_GOLD:
						cut_gold = true
					elif special == SPECIAL_WHEAT_CURSED:
						cut_cursed = true
	if newly_cut > 0:
		fighter.harvest_timer = 0.24
		if newly_cut >= 2:
			_spawn_harvest_sparks(fighter, mini(newly_cut, 4))
		if cut_gold:
			_spawn_harvest_sparks(fighter, 3)
			announcement = "%s 割到了金麦穗！" % fighter.label
			announcement_timer = 1.1
		elif cut_cursed:
			_apply_cursed_wheat_effect(fighter)
			announcement = "%s 踩中了毒麦！" % fighter.label
			announcement_timer = 1.1


func _claim_wheat_cell(fighter: Fighter, cell: Vector2i) -> int:
	var index := _cell_index(cell)
	var special := special_wheat[index]
	territory[index] = fighter.team
	regrow_timers[index] = WHEAT_REGROW_SECONDS
	_mark_wheat_cell_dirty(index)
	match special:
		SPECIAL_WHEAT_GOLD:
			_award_cut_score(fighter, SPECIAL_WHEAT_GOLD_SCORE)
		SPECIAL_WHEAT_CURSED:
			_award_cut_score(fighter, 1)
		_:
			_award_cut_score(fighter, 1)
	CombatState.record_cut(_stats_for(fighter), special)
	return special


func _apply_cursed_wheat_effect(fighter: Fighter) -> void:
	fighter.blade_spirit = maxi(0, fighter.blade_spirit - CURSED_BLADE_SPIRIT_PENALTY)
	fighter.curse_slow_timer = CURSED_SLOW_DURATION


func _update_regrowth(delta: float) -> void:
	for index in WheatField.update_regrowth(regrow_timers, territory, delta):
		_mark_wheat_cell_dirty(index)


func _mark_wheat_cell_dirty(index: int) -> void:
	dirty_wheat_cells[index] = true


func _spawn_harvest_sparks(fighter: Fighter, amount: int, record_event: bool = true) -> void:
	_spawn_harvest_sparks_at(fighter.position, fighter.team, amount)
	if record_event and _is_network_server():
		_queue_visual_event({
			"type": "harvest_sparks",
			"x": fighter.position.x,
			"y": fighter.position.y,
			"team": fighter.team,
			"amount": amount,
		})


func _spawn_harvest_sparks_at(position: Vector2, team: int, amount: int) -> void:
	for index in range(amount):
		var spark := HarvestSpark.new()
		spark.position = position + Vector2(rng.randf_range(-14.0, 14.0), rng.randf_range(-9.0, 5.0))
		spark.velocity = Vector2(rng.randf_range(-42.0, 42.0), rng.randf_range(-82.0, -42.0))
		spark.max_life = rng.randf_range(0.35, 0.58)
		spark.life = spark.max_life
		spark.team = team
		harvest_sparks.append(spark)


func _update_harvest_sparks(delta: float) -> void:
	for index in range(harvest_sparks.size() - 1, -1, -1):
		var spark := harvest_sparks[index]
		spark.life -= delta
		spark.velocity.y += 150.0 * delta
		spark.position += spark.velocity * delta
		if spark.life <= 0.0:
			harvest_sparks.remove_at(index)


func _update_fire_embers(delta: float) -> void:
	for index in range(fire_embers.size() - 1, -1, -1):
		var ember := fire_embers[index]
		ember.life -= delta
		ember.velocity *= 1.0 - delta * 2.2
		ember.position += ember.velocity * delta
		if ember.life <= 0.0:
			fire_embers.remove_at(index)


func _update_powerups(delta: float) -> void:
	for powerup in powerups:
		powerup.bob_phase += delta * 4.2
	powerup_spawn_timer -= delta
	if powerup_spawn_timer <= 0.0:
		powerup_spawn_timer = POWERUP_SPAWN_INTERVAL
		_spawn_random_powerup()


func _spawn_random_powerup() -> void:
	if powerups.size() >= MAX_POWERUPS:
		return
	for attempt in range(24):
		var at := Vector2(
			rng.randf_range(ARENA.position.x + 60.0, ARENA.end.x - 60.0),
			rng.randf_range(ARENA.position.y + 60.0, ARENA.end.y - 60.0)
		)
		if not _position_in_wheat(at):
			continue
		var too_close := false
		for fighter in fighters:
			if fighter.respawn_timer <= 0.0 and fighter.position.distance_to(at) < 90.0:
				too_close = true
				break
		if too_close:
			continue
		var powerup := PowerUp.new()
		powerup.kind = rng.randi_range(POWERUP_SHIELD, POWERUP_STEALTH)
		powerup.position = at
		powerup.bob_phase = rng.randf_range(0.0, TAU)
		powerups.append(powerup)
		return


func _position_in_wheat(position: Vector2) -> bool:
	var cell := _position_to_cell(position)
	return wheat_mask[_cell_index(cell)]


func _try_pickup_powerup(fighter: Fighter) -> void:
	for index in range(powerups.size() - 1, -1, -1):
		var powerup := powerups[index]
		if fighter.position.distance_to(powerup.position) > POWERUP_PICKUP_RADIUS:
			continue
		match powerup.kind:
			POWERUP_SHIELD:
				fighter.shield_charges = mini(fighter.shield_charges + 1, 2)
				announcement = "%s 获得了护盾" % fighter.label
			POWERUP_FIRE:
				fighter.fire_sickle_charges = mini(fighter.fire_sickle_charges + 2, 4)
				announcement = "%s 获得了火焰回旋镰" % fighter.label
			POWERUP_BARRIER:
				fighter.barrier_charges = mini(fighter.barrier_charges + 1, 2)
				announcement = "%s 获得了结界道具" % fighter.label
			POWERUP_SPLIT:
				fighter.split_sickle_charges = mini(fighter.split_sickle_charges + 1, 3)
				announcement = "%s 获得了分裂回旋镰" % fighter.label
			POWERUP_PHASE_SPRINT:
				fighter.phase_sprint_charges = mini(fighter.phase_sprint_charges + 2, 4)
				announcement = "%s 获得了穿墙冲刺" % fighter.label
			POWERUP_ORBIT_RING:
				fighter.orbit_ring_active = true
				fighter.orbit_ring_spin = fighter.anim_seed
				fighter.orbit_hit_cooldowns.clear()
				announcement = "%s 获得了环绕镰" % fighter.label
			POWERUP_STEALTH:
				fighter.invisibility_timer = INVISIBILITY_DURATION
				announcement = "%s 获得了隐身（20秒）" % fighter.label
		CombatState.record_powerup(_stats_for(fighter), powerup.kind)
		announcement_timer = 1.2
		powerups.remove_at(index)


func _update_orbit_ring_visuals(delta: float) -> void:
	for fighter in fighters:
		if not fighter.orbit_ring_active or fighter.respawn_timer > 0.0 or _is_stealthed(fighter):
			continue
		fighter.orbit_ring_spin = fmod(fighter.orbit_ring_spin + delta * ORBIT_RING_SPEED, TAU)


func _update_orbit_rings(delta: float) -> void:
	_update_orbit_ring_visuals(delta)
	for fighter in fighters:
		if not fighter.orbit_ring_active or fighter.respawn_timer > 0.0 or _is_stealthed(fighter):
			continue
		var expired_ids: Array = []
		for target_id in fighter.orbit_hit_cooldowns.keys():
			var remaining: float = fighter.orbit_hit_cooldowns[target_id]
			remaining = maxf(0.0, remaining - delta)
			if remaining <= 0.0:
				expired_ids.append(target_id)
			else:
				fighter.orbit_hit_cooldowns[target_id] = remaining
		for target_id in expired_ids:
			fighter.orbit_hit_cooldowns.erase(target_id)
		for blade_index in range(ORBIT_RING_COUNT):
			var angle := fighter.orbit_ring_spin + TAU * float(blade_index) / float(ORBIT_RING_COUNT)
			var blade_pos := fighter.position + Vector2.from_angle(angle) * ORBIT_RING_RADIUS
			var blade_dir := Vector2.from_angle(angle + PI * 0.5)
			_check_orbit_blade_hits(fighter, blade_pos, blade_dir)


func _check_orbit_blade_hits(owner: Fighter, blade_pos: Vector2, blade_dir: Vector2) -> void:
	for target in fighters:
		if target == owner or _are_allies(owner, target) or target.respawn_timer > 0.0:
			continue
		if blade_pos.distance_to(target.position) > ORBIT_RING_HIT_RADIUS:
			continue
		if fighter_orbit_hit_on_cooldown(owner, target):
			continue
		if _fighter_in_clash_stance(target):
			_trigger_clash(owner, target)
			_set_orbit_hit_cooldown(owner, target)
			continue
		_blade_hit_fighter(target, owner, "环镰")
		_set_orbit_hit_cooldown(owner, target)


func fighter_orbit_hit_on_cooldown(owner: Fighter, target: Fighter) -> bool:
	if target.player_id < 0:
		return false
	return owner.orbit_hit_cooldowns.get(target.player_id, 0.0) > 0.0


func _set_orbit_hit_cooldown(owner: Fighter, target: Fighter) -> void:
	if target.player_id < 0:
		return
	owner.orbit_hit_cooldowns[target.player_id] = ORBIT_RING_HIT_COOLDOWN


func _deploy_barrier(fighter: Fighter) -> void:
	if fighter.barrier_charges <= 0 or barrier_zones.size() >= MAX_BARRIER_ZONES:
		return
	fighter.barrier_charges -= 1
	var zone := BarrierZone.new()
	zone.team = fighter.team
	zone.owner_label = fighter.label
	zone.position = fighter.position
	zone.life = BARRIER_DURATION
	zone.seal_timer = BARRIER_SEAL_TIME
	zone.pulse = rng.randf_range(0.0, TAU)
	for ally in fighters:
		if _are_allies(fighter, ally) or ally.respawn_timer > 0.0:
			continue
		if ally.position.distance_to(zone.position) < BARRIER_RADIUS - UNIT_RADIUS * 0.5:
			zone.inside_allies.append(ally)
	barrier_zones.append(zone)
	for other in fighters:
		if _are_allies(fighter, other) or other.respawn_timer > 0.0:
			continue
		if other.position.distance_to(zone.position) < _barrier_inner_radius():
			other.position = _push_to_barrier_edge(other.position, zone)
	announcement = "%s 释放了结界" % fighter.label
	announcement_timer = 1.2
	var barrier_stats := _stats_for(fighter)
	if barrier_stats != null:
		barrier_stats.barriers += 1


func _update_barrier_zones(delta: float) -> void:
	for index in range(barrier_zones.size() - 1, -1, -1):
		var zone := barrier_zones[index]
		zone.life -= delta
		zone.seal_timer = maxf(0.0, zone.seal_timer - delta)
		zone.pulse += delta * 3.2
		if zone.life <= 0.0:
			barrier_zones.remove_at(index)


func _barrier_inner_radius() -> float:
	return BARRIER_RADIUS - UNIT_RADIUS


func _path_enters_circle(from: Vector2, to: Vector2, center: Vector2, radius: float) -> bool:
	if from.distance_to(center) <= radius:
		return false
	if to.distance_to(center) <= radius:
		return true
	var segment := to - from
	var rel := from - center
	var a := segment.dot(segment)
	if a < 0.0001:
		return false
	var b := 2.0 * rel.dot(segment)
	var c := rel.dot(rel) - radius * radius
	var discriminant := b * b - 4.0 * a * c
	if discriminant < 0.0:
		return false
	discriminant = sqrt(discriminant)
	var inv := 1.0 / (2.0 * a)
	var t1 := (-b - discriminant) * inv
	var t2 := (-b + discriminant) * inv
	return (t1 >= 0.0 and t1 <= 1.0) or (t2 >= 0.0 and t2 <= 1.0)


func _push_to_barrier_edge(fighter_position: Vector2, zone: BarrierZone) -> Vector2:
	var inner_radius := _barrier_inner_radius()
	var offset := fighter_position - zone.position
	if offset.length_squared() < 0.01:
		return zone.position + Vector2.RIGHT * inner_radius
	return zone.position + offset.normalized() * inner_radius


func _apply_barrier_constraints(fighter: Fighter, previous_position: Vector2) -> void:
	if fighter.respawn_timer > 0.0:
		return
	var inner_radius := _barrier_inner_radius()
	for zone in barrier_zones:
		if zone.life <= 0.0:
			continue
		var to_pos := fighter.position - zone.position
		var distance := to_pos.length()
		var was_inside := previous_position.distance_to(zone.position) <= inner_radius
		if fighter.team != zone.team:
			if distance < inner_radius:
				fighter.position = _push_to_barrier_edge(fighter.position, zone)
			elif not was_inside and _path_enters_circle(previous_position, fighter.position, zone.position, inner_radius):
				fighter.position = previous_position
			continue
		var ally_allowed := zone.seal_timer <= 0.0 or fighter in zone.inside_allies
		if ally_allowed:
			continue
		if distance < inner_radius:
			fighter.position = _push_to_barrier_edge(fighter.position, zone)
		elif not was_inside and _path_enters_circle(previous_position, fighter.position, zone.position, inner_radius):
			fighter.position = previous_position


func _spawn_shield_outer_radius() -> float:
	return SPAWN_SHIELD_RADIUS


func _push_to_spawn_shield_edge(fighter_position: Vector2, center: Vector2) -> Vector2:
	var radius := _spawn_shield_outer_radius()
	var offset := fighter_position - center
	if offset.length_squared() < 0.01:
		return center + Vector2.RIGHT * radius
	return center + offset.normalized() * radius


func _apply_spawn_shield_constraints(fighter: Fighter, previous_position: Vector2) -> void:
	if fighter.respawn_timer > 0.0:
		return
	var radius := _spawn_shield_outer_radius()
	for respawning in fighters:
		if respawning.respawn_timer <= 0.0:
			continue
		if _are_allies(fighter, respawning):
			continue
		var center := respawning.spawn_position
		var to_pos := fighter.position - center
		var distance := to_pos.length()
		var was_outside := previous_position.distance_to(center) >= radius
		if distance < radius:
			fighter.position = _push_to_spawn_shield_edge(fighter.position, center)
		elif was_outside and _path_enters_circle(previous_position, fighter.position, center, radius):
			fighter.position = previous_position


func _eject_enemies_from_spawn_shield(respawning: Fighter) -> void:
	var center := respawning.spawn_position
	var radius := _spawn_shield_outer_radius() + UNIT_RADIUS * 0.35
	for fighter in fighters:
		if fighter == respawning or fighter.respawn_timer > 0.0:
			continue
		if _are_allies(fighter, respawning):
			continue
		var offset := fighter.position - center
		if offset.length() >= radius:
			continue
		if offset.length_squared() < 0.01:
			offset = Vector2.RIGHT
		fighter.position = center + offset.normalized() * radius
		fighter.velocity = Vector2.ZERO


func _fighter_sickle_count(fighter: Fighter) -> int:
	var count := 0
	for sickle in thrown_sickles:
		if sickle.owner == fighter:
			count += 1
	return count


func _fighter_in_clash_stance(fighter: Fighter) -> bool:
	return fighter.attack_active > 0.0 or fighter.attack_flash > 0.0 or fighter.throw_flash > 0.0


func _player_in_fight(a: Fighter, b: Fighter) -> bool:
	return not a.ai or not b.ai


func _update_clash_effects(delta: float) -> void:
	for index in range(clash_effects.size() - 1, -1, -1):
		var effect := clash_effects[index]
		effect.life -= delta
		if effect.life <= 0.0:
			clash_effects.remove_at(index)


func _spawn_clash_effect(at: Vector2, record_event: bool = true) -> void:
	var effect := ClashEffect.new()
	effect.position = at
	effect.life = effect.max_life
	clash_effects.append(effect)
	if record_event and _is_network_server():
		_queue_visual_event({
			"type": "clash",
			"x": at.x,
			"y": at.y,
		})


func _trigger_clash(a: Fighter, b: Fighter) -> void:
	if a.clash_immunity > 0.0 or b.clash_immunity > 0.0:
		return
	a.clash_flash = 0.32
	b.clash_flash = 0.32
	a.clash_immunity = 0.38
	b.clash_immunity = 0.38
	screen_shake = 0.18
	var midpoint := (a.position + b.position) * 0.5
	_spawn_clash_effect(midpoint)
	var push_dir := (b.position - a.position)
	if push_dir.length_squared() < 1.0:
		push_dir = Vector2.RIGHT
	push_dir = push_dir.normalized()
	a.position -= push_dir * CLASH_KNOCKBACK
	b.position += push_dir * CLASH_KNOCKBACK
	_clamp_fighter_to_arena(a)
	_clamp_fighter_to_arena(b)
	_nudge_fighter_out_of_walls(a)
	_nudge_fighter_out_of_walls(b)
	if _player_in_fight(a, b):
		bullet_time_timer = BULLET_TIME_DURATION
	CombatState.record_clash(_stats_for(a), _stats_for(b))
	announcement = "拼刀！"
	announcement_timer = 0.9


func _blade_hit_fighter(target: Fighter, attacker: Fighter, attack_name: String) -> void:
	if target.shield_charges > 0:
		target.shield_charges -= 1
		target.shield_flash = 0.35
		var block_stats := _stats_for(target)
		if block_stats != null:
			block_stats.shields_blocked += 1
		announcement = "%s 的护盾挡住了 %s" % [target.label, attack_name]
		announcement_timer = 1.0
		return
	target.blade_spirit = maxi(0, target.blade_spirit - 1)
	screen_shake = 0.1
	var knocked := target.blade_spirit <= 0
	CombatState.record_hit(_stats_for(attacker), attack_name, knocked)
	if knocked:
		CombatState.record_knockdown(_stats_for(attacker), _stats_for(target))
		target.respawn_timer = RESPAWN_SECONDS
		target.velocity = Vector2.ZERO
		target.orbit_ring_active = false
		target.orbit_hit_cooldowns.clear()
		target.invisibility_timer = 0.0
		_eject_enemies_from_spawn_shield(target)
		announcement = "%s 的%s破势击倒了 %s" % [attacker.label, attack_name, target.label]
		announcement_timer = 1.8


func _attack(attacker: Fighter) -> void:
	if attacker.attack_cooldown > 0.0:
		return
	attacker.attack_cooldown = ATTACK_COOLDOWN
	attacker.attack_flash = 0.16
	attacker.attack_active = CLASH_WINDOW
	for target in fighters:
		if _are_allies(attacker, target) or target.respawn_timer > 0.0:
			continue
		var offset := target.position - attacker.position
		if offset.length() > ATTACK_RANGE:
			continue
		if attacker.aim.dot(offset.normalized()) < 0.20:
			continue
		if _fighter_in_clash_stance(target):
			_trigger_clash(attacker, target)
			continue
		_blade_hit_fighter(target, attacker, "挥镰")


func _throw_sickle(thrower: Fighter, charge_seconds: float) -> void:
	if thrower.throw_cooldown > 0.0:
		return
	var fork_angles := _throw_fork_angles(thrower)
	if _fighter_sickle_count(thrower) + fork_angles.size() > MAX_SICKLES_PER_FIGHTER:
		return
	var on_fire := thrower.fire_sickle_charges > 0
	if on_fire:
		thrower.fire_sickle_charges -= 1
	var charge_power := _throw_charge_power(charge_seconds)
	var throw_speed := THROW_SPEED * lerpf(0.82, 1.38, charge_power)
	var throw_range := THROW_MAX_RANGE * lerpf(0.78, 1.28, charge_power)
	var base_angle := thrower.aim.angle()
	for fork_angle in fork_angles:
		var sickle := ThrownSickle.new()
		sickle.owner = thrower
		sickle.position = thrower.position + thrower.aim * 18.0
		sickle.direction = Vector2.from_angle(base_angle + fork_angle)
		sickle.on_fire = on_fire
		sickle.charge_power = charge_power
		sickle.speed = throw_speed
		sickle.max_range = throw_range
		thrown_sickles.append(sickle)
	thrower.throw_cooldown = THROW_COOLDOWN
	thrower.throw_flash = 0.18 + charge_power * 0.12
	thrower.attack_active = CLASH_WINDOW


func _update_thrown_sickles(delta: float) -> void:
	for index in range(thrown_sickles.size() - 1, -1, -1):
		var sickle := thrown_sickles[index]
		var owner := sickle.owner
		if owner.respawn_timer > 0.0:
			thrown_sickles.remove_at(index)
			continue
		sickle.spin += delta * 16.0
		var previous_position := sickle.position
		if not sickle.returning:
			var step := sickle.speed * delta
			var next_position := _clamp_sickle_position(sickle.position + sickle.direction * step)
			if _sickle_path_blocked(previous_position, next_position):
				sickle.returning = true
			else:
				sickle.position = next_position
				sickle.distance += step
				if sickle.distance >= sickle.max_range:
					sickle.returning = true
		else:
			var to_owner := owner.position - sickle.position
			var catch_distance := to_owner.length()
			if catch_distance <= THROW_CATCH_RADIUS:
				thrown_sickles.remove_at(index)
				continue
			sickle.direction = to_owner / catch_distance
			var next_position := _clamp_sickle_position(
				sickle.position + sickle.direction * THROW_RETURN_SPEED * delta
			)
			if not _sickle_path_blocked(previous_position, next_position):
				sickle.position = next_position
		_check_sickle_hits(sickle)
		if sickle.on_fire:
			_update_fire_sickle(sickle, delta)
	_check_sickle_clashes()


func _check_sickle_clashes() -> void:
	var to_remove: Array[int] = []
	for first in range(thrown_sickles.size()):
		if first in to_remove:
			continue
		var sickle_a := thrown_sickles[first]
		if sickle_a.returning or sickle_a.owner == null:
			continue
		for second in range(first + 1, thrown_sickles.size()):
			if second in to_remove:
				continue
			var sickle_b := thrown_sickles[second]
			if sickle_b.returning or sickle_b.owner == null:
				continue
			if _are_allies(sickle_a.owner, sickle_b.owner):
				continue
			if sickle_a.position.distance_to(sickle_b.position) > SICKLE_CLASH_RADIUS:
				continue
			var outcome := _sickle_clash_outcome(sickle_a, sickle_b)
			_spawn_clash_effect((sickle_a.position + sickle_b.position) * 0.5)
			match outcome:
				0:
					if first not in to_remove:
						to_remove.append(first)
					if second not in to_remove:
						to_remove.append(second)
				-1:
					if second not in to_remove:
						to_remove.append(second)
				1:
					if first not in to_remove:
						to_remove.append(first)
	to_remove.sort()
	to_remove.reverse()
	for index in to_remove:
		thrown_sickles.remove_at(index)


func _sickle_clash_outcome(a: ThrownSickle, b: ThrownSickle) -> int:
	if absf(a.charge_power - b.charge_power) < 0.06:
		return 0
	if a.charge_power > b.charge_power:
		return -1
	return 1


func _update_fire_sickle(sickle: ThrownSickle, delta: float) -> void:
	sickle.fire_tick += delta
	sickle.ember_timer += delta
	while sickle.ember_timer >= 0.05:
		sickle.ember_timer -= 0.05
		_spawn_fire_ember(sickle.position, sickle.direction)
	var burned := _burn_wheat_for_sickle(sickle)
	if burned > 0 and sickle.owner.harvest_timer <= 0.0:
		sickle.owner.harvest_timer = 0.16
	if sickle.fire_tick >= 0.22:
		sickle.fire_tick = 0.0
		for target in fighters:
			if target == sickle.owner or _are_allies(sickle.owner, target) or target.respawn_timer > 0.0:
				continue
			if sickle.position.distance_to(target.position) > THROW_HIT_RADIUS + 8.0:
				continue
			if _fighter_in_clash_stance(target):
				_trigger_clash(sickle.owner, target)
				continue
			_blade_hit_fighter(target, sickle.owner, "火焰镰")


func _spawn_fire_ember(at: Vector2, direction: Vector2, record_event: bool = true) -> void:
	var ember := FireEmber.new()
	ember.position = at + Vector2(rng.randf_range(-6.0, 6.0), rng.randf_range(-6.0, 6.0))
	ember.velocity = direction * rng.randf_range(12.0, 42.0) + Vector2(rng.randf_range(-18.0, 18.0), rng.randf_range(-28.0, -8.0))
	ember.max_life = FIRE_EMBER_LIFE * rng.randf_range(0.7, 1.1)
	ember.life = ember.max_life
	fire_embers.append(ember)
	if record_event and _is_network_server():
		_queue_visual_event({
			"type": "fire_ember",
			"x": at.x,
			"y": at.y,
			"dx": direction.x,
			"dy": direction.y,
		})


func _burn_wheat_for_sickle(sickle: ThrownSickle) -> int:
	var center_cell := _position_to_cell(sickle.position)
	var cell_radius := ceili(FIRE_BURN_RADIUS / CELL_SIZE)
	var burned := 0
	for y in range(center_cell.y - cell_radius, center_cell.y + cell_radius + 1):
		for x in range(center_cell.x - cell_radius, center_cell.x + cell_radius + 1):
			if x < 0 or x >= GRID_COLS or y < 0 or y >= GRID_ROWS:
				continue
			var cell := Vector2i(x, y)
			var cell_index := _cell_index(cell)
			if cell_index in sickle.burned_cells:
				continue
			if not wheat_mask[cell_index]:
				continue
			if _cell_center(cell).distance_to(sickle.position) > FIRE_BURN_RADIUS:
				continue
			sickle.burned_cells.append(cell_index)
			if territory[cell_index] == -1:
				burned += 1
				_claim_wheat_cell(sickle.owner, cell)
	return burned


func _check_sickle_hits(sickle: ThrownSickle) -> void:
	for target in fighters:
		if target == sickle.owner or _are_allies(sickle.owner, target) or target.respawn_timer > 0.0:
			continue
		if target in sickle.hit_targets:
			continue
		if sickle.position.distance_to(target.position) > THROW_HIT_RADIUS:
			continue
		sickle.hit_targets.append(target)
		if _fighter_in_clash_stance(target):
			_trigger_clash(sickle.owner, target)
			continue
		_blade_hit_fighter(target, sickle.owner, "回旋镰" if not sickle.on_fire else "火焰镰")


func _read_local_input_dict() -> Dictionary:
	var input_vector := Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	if Input.is_key_pressed(KEY_A):
		input_vector.x -= 1.0
	if Input.is_key_pressed(KEY_D):
		input_vector.x += 1.0
	if Input.is_key_pressed(KEY_W):
		input_vector.y -= 1.0
	if Input.is_key_pressed(KEY_S):
		input_vector.y += 1.0
	input_vector = input_vector.normalized()
	var aim_vector := Vector2.RIGHT
	if GameSession.my_player_id >= 0:
		for fighter in fighters:
			if fighter.player_id == GameSession.my_player_id:
				var mouse_direction := get_global_mouse_position() - fighter.position
				if mouse_direction.length_squared() > 1.0:
					aim_vector = mouse_direction.normalized()
				else:
					aim_vector = fighter.aim
				break
	var throw_now := Input.is_key_pressed(KEY_ENTER) or Input.is_key_pressed(KEY_KP_ENTER)
	var throw_release := local_throw_down and not throw_now
	local_throw_down = throw_now
	var barrier_now := Input.is_key_pressed(KEY_Q)
	var barrier_edge := barrier_now and not local_barrier_down
	local_barrier_down = barrier_now
	return {
		"move": input_vector,
		"aim": aim_vector,
		"attack": Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT),
		"throw_hold": throw_now,
		"throw_release": throw_release,
		"sprint": Input.is_key_pressed(KEY_SPACE) and input_vector.length_squared() > 0.01,
		"barrier": barrier_edge,
	}


func _send_local_input() -> void:
	if GameSession.my_player_id < 0:
		return
	submit_player_input.rpc_id(1, GameSession.my_player_id, _read_local_input_dict())


func _smooth_interp_t(t: float) -> float:
	var clamped := clampf(t, 0.0, 1.0)
	return clamped * clamped * (3.0 - 2.0 * clamped)


func _get_or_create_interp(player_id: int) -> FighterInterp:
	if fighter_interps.has(player_id):
		return fighter_interps[player_id]
	var interp := FighterInterp.new()
	fighter_interps[player_id] = interp
	return interp


func _update_client_interpolation(delta: float) -> void:
	for fighter in fighters:
		var interp: FighterInterp = fighter_interps.get(fighter.player_id)
		if interp == null:
			continue
		if _is_local_fighter(fighter):
			var input_data := _read_local_input_dict()
			var move_vector: Vector2 = input_data.get("move", Vector2.ZERO)
			var move_speed := _fighter_move_speed(fighter)
			fighter.position += move_vector * move_speed * delta
			fighter.position += interp.correction * LOCAL_CORRECTION_STRENGTH
			interp.correction = interp.correction.lerp(Vector2.ZERO, minf(1.0, delta * 10.0))
			var aim_vector: Vector2 = input_data.get("aim", fighter.aim)
			if aim_vector.length_squared() > 0.01:
				fighter.aim = aim_vector.normalized()
		else:
			interp.elapsed += delta
			var blend := _smooth_interp_t(interp.elapsed / INTERP_DURATION)
			fighter.position = interp.from_pos.lerp(interp.to_pos, blend)
			var blended_aim := interp.from_aim.lerp(interp.to_aim, blend)
			if blended_aim.length_squared() > 0.01:
				fighter.aim = blended_aim.normalized()
	_extrapolate_client_sickles(delta)


func _extrapolate_client_sickles(delta: float) -> void:
	for sickle in thrown_sickles:
		if sickle.owner == null:
			continue
		sickle.spin += delta * 16.0
		if sickle.returning:
			var to_owner := sickle.owner.position - sickle.position
			var catch_distance := to_owner.length()
			if catch_distance <= THROW_CATCH_RADIUS:
				continue
			if catch_distance > 0.01:
				sickle.direction = to_owner / catch_distance
			sickle.position += sickle.direction * THROW_RETURN_SPEED * delta
		else:
			sickle.position += sickle.direction * sickle.speed * delta
			sickle.distance += sickle.speed * delta


func _queue_fighter_interp(row: Dictionary) -> void:
	var player_id: int = row.get("pid", -1)
	var fighter := _fighter_by_player_id(player_id)
	if fighter == null:
		return
	var applied := NetworkSync.apply_fighter_row(fighter, row)
	var server_pos: Vector2 = applied["position"]
	var server_aim: Vector2 = applied["aim"]
	var interp := _get_or_create_interp(player_id)
	if not interp.initialized or server_pos.distance_to(fighter.position) > 120.0 or fighter.respawn_timer > 0.0:
		fighter.position = server_pos
		fighter.aim = server_aim
		interp.initialized = true
	interp.from_pos = fighter.position
	interp.to_pos = server_pos
	interp.from_aim = fighter.aim
	interp.to_aim = server_aim
	interp.elapsed = 0.0
	if _is_local_fighter(fighter):
		interp.correction = server_pos - fighter.position


func _fighter_by_player_id(player_id: int) -> Fighter:
	for fighter in fighters:
		if fighter.player_id == player_id:
			return fighter
	return null


func _serialize_thrown_sickles() -> Array:
	var rows: Array = []
	for sickle in thrown_sickles:
		var owner_pid := -1
		if sickle.owner != null:
			owner_pid = sickle.owner.player_id
		rows.append({
			"opid": owner_pid,
			"x": sickle.position.x,
			"y": sickle.position.y,
			"dx": sickle.direction.x,
			"dy": sickle.direction.y,
			"ret": sickle.returning,
			"fire": sickle.on_fire,
			"spin": sickle.spin,
			"dist": sickle.distance,
			"charge": sickle.charge_power,
			"speed": sickle.speed,
			"range": sickle.max_range,
		})
	return rows


func _apply_thrown_sickles(rows: Array) -> void:
	thrown_sickles.clear()
	for row in rows:
		var owner := _fighter_by_player_id(row.get("opid", -1))
		if owner == null:
			continue
		var sickle := ThrownSickle.new()
		sickle.owner = owner
		sickle.position = Vector2(row.get("x", 0.0), row.get("y", 0.0))
		sickle.direction = Vector2(row.get("dx", 1.0), row.get("dy", 0.0)).normalized()
		sickle.returning = row.get("ret", false)
		sickle.on_fire = row.get("fire", false)
		sickle.spin = row.get("spin", 0.0)
		sickle.distance = row.get("dist", 0.0)
		sickle.charge_power = row.get("charge", 0.5)
		sickle.speed = row.get("speed", THROW_SPEED)
		sickle.max_range = row.get("range", THROW_MAX_RANGE)
		thrown_sickles.append(sickle)


func _serialize_powerups() -> Array:
	var rows: Array = []
	for powerup in powerups:
		rows.append({
			"kind": powerup.kind,
			"x": powerup.position.x,
			"y": powerup.position.y,
			"bob": powerup.bob_phase,
		})
	return rows


func _apply_powerups(rows: Array) -> void:
	powerups.clear()
	for row in rows:
		var powerup := PowerUp.new()
		powerup.kind = row.get("kind", 0)
		powerup.position = Vector2(row.get("x", 0.0), row.get("y", 0.0))
		powerup.bob_phase = row.get("bob", 0.0)
		powerups.append(powerup)


func _serialize_barrier_zones() -> Array:
	var rows: Array = []
	for zone in barrier_zones:
		var ally_ids: Array = []
		for ally in zone.inside_allies:
			if ally != null:
				ally_ids.append(ally.player_id)
		rows.append({
			"team": zone.team,
			"label": zone.owner_label,
			"x": zone.position.x,
			"y": zone.position.y,
			"life": zone.life,
			"seal": zone.seal_timer,
			"pulse": zone.pulse,
			"allies": ally_ids,
		})
	return rows


func _apply_barrier_zones(rows: Array) -> void:
	barrier_zones.clear()
	for row in rows:
		var zone := BarrierZone.new()
		zone.team = row.get("team", 0)
		zone.owner_label = row.get("label", "")
		zone.position = Vector2(row.get("x", 0.0), row.get("y", 0.0))
		zone.life = row.get("life", 0.0)
		zone.seal_timer = row.get("seal", 0.0)
		zone.pulse = row.get("pulse", 0.0)
		for ally_id in row.get("allies", []):
			var ally := _fighter_by_player_id(int(ally_id))
			if ally != null:
				zone.inside_allies.append(ally)
		barrier_zones.append(zone)


func _queue_visual_event(event: Dictionary) -> void:
	pending_visual_events.append(event)


func _apply_visual_events(events: Array) -> void:
	for event in events:
		if typeof(event) != TYPE_DICTIONARY:
			continue
		var event_type := str(event.get("type", ""))
		match event_type:
			"harvest_sparks":
				_spawn_harvest_sparks_at(
					Vector2(event.get("x", 0.0), event.get("y", 0.0)),
					int(event.get("team", 0)),
					int(event.get("amount", 1))
				)
			"clash":
				_spawn_clash_effect(Vector2(event.get("x", 0.0), event.get("y", 0.0)), false)
			"fire_ember":
				var direction := Vector2(event.get("dx", 0.0), event.get("dy", 0.0))
				if direction.length_squared() > 0.01:
					direction = direction.normalized()
				_spawn_fire_ember(Vector2(event.get("x", 0.0), event.get("y", 0.0)), direction, false)


func _collect_wheat_delta() -> Array:
	var rows: Array = []
	for key in dirty_wheat_cells.keys():
		var index := int(key)
		if index < 0 or index >= territory.size():
			continue
		rows.append({
			"i": index,
			"owner": territory[index],
			"regrow": regrow_timers[index],
			"special": special_wheat[index],
		})
	return rows


func _apply_wheat_delta(rows: Array) -> void:
	for row in rows:
		if typeof(row) != TYPE_DICTIONARY:
			continue
		var index := int(row.get("i", -1))
		if index < 0 or index >= territory.size():
			continue
		territory[index] = int(row.get("owner", territory[index]))
		regrow_timers[index] = float(row.get("regrow", regrow_timers[index]))
		special_wheat[index] = int(row.get("special", special_wheat[index]))


func _serialize_match_stats() -> Array:
	var rows: Array = []
	for stats in match_stats:
		rows.append(CombatState.serialize_stats(stats))
	return rows


func _apply_match_stats(rows: Array) -> void:
	for index in range(mini(rows.size(), match_stats.size())):
		if typeof(rows[index]) != TYPE_DICTIONARY:
			continue
		CombatState.apply_stats(match_stats[index], rows[index])


func _collect_state() -> Dictionary:
	var fighter_rows: Array = []
	for fighter in fighters:
		fighter_rows.append(NetworkSync.serialize_fighter(fighter))
	var state := {
		"match_time": match_time,
		"countdown": countdown,
		"match_over": match_over,
		"announcement": announcement,
		"announcement_timer": announcement_timer,
		"team_scores": team_scores,
		"player_scores": player_scores,
		"fighters": fighter_rows,
		"sickles": _serialize_thrown_sickles(),
		"powerups": _serialize_powerups(),
		"barriers": _serialize_barrier_zones(),
		"events": pending_visual_events.duplicate(true),
		"map_index": current_map_index,
		"match_mode": match_mode,
		"bullet_time": bullet_time_timer,
		"screen_shake": screen_shake,
		"series": GameSession.series_payload(),
		"match_stats": _serialize_match_stats(),
	}
	if force_full_wheat_sync:
		state["territory"] = territory.duplicate()
		state["regrow_timers"] = regrow_timers.duplicate()
		state["special_wheat"] = special_wheat.duplicate()
	else:
		state["wheat_delta"] = _collect_wheat_delta()
	pending_visual_events.clear()
	dirty_wheat_cells.clear()
	force_full_wheat_sync = false
	return state


func _broadcast_state() -> void:
	if not _is_network_server():
		return
	receive_game_state.rpc(_collect_state())


func _apply_game_state(state: Dictionary) -> void:
	match_time = state.get("match_time", match_time)
	countdown = state.get("countdown", countdown)
	match_over = state.get("match_over", match_over)
	match_mode = state.get("match_mode", match_mode)
	announcement = state.get("announcement", announcement)
	announcement_timer = state.get("announcement_timer", announcement_timer)
	bullet_time_timer = state.get("bullet_time", bullet_time_timer)
	screen_shake = state.get("screen_shake", screen_shake)
	if state.has("series"):
		GameSession.apply_series_payload(state.get("series", {}))
	team_scores = state.get("team_scores", team_scores)
	player_scores = state.get("player_scores", player_scores)
	if state.has("match_stats"):
		_apply_match_stats(state.get("match_stats", []))
	if match_over:
		_show_match_end_ui()
	if state.has("territory"):
		var synced_territory: Array = state.get("territory", territory)
		if synced_territory.size() == territory.size():
			territory = synced_territory
		var synced_regrow: Array = state.get("regrow_timers", regrow_timers)
		if synced_regrow.size() == regrow_timers.size():
			regrow_timers = synced_regrow
		var synced_special: Array = state.get("special_wheat", special_wheat)
		if synced_special.size() == special_wheat.size():
			special_wheat = synced_special
	else:
		_apply_wheat_delta(state.get("wheat_delta", []))
	for row in state.get("fighters", []):
		_queue_fighter_interp(row)
	_apply_thrown_sickles(state.get("sickles", []))
	_apply_powerups(state.get("powerups", []))
	_apply_barrier_zones(state.get("barriers", []))
	_apply_visual_events(state.get("events", []))


@rpc("any_peer", "call_remote", "unreliable")
func submit_player_input(player_id: int, input: Dictionary) -> void:
	if not _is_network_server():
		return
	network_inputs[player_id] = input


@rpc("authority", "call_remote", "unreliable")
func receive_game_state(state: Dictionary) -> void:
	if _is_network_server():
		return
	_apply_game_state(state)


func _finish_match() -> void:
	match_over = true
	if not _is_online() or _is_network_server():
		GameSession.record_round_scores(team_scores, player_scores)
	announcement = CombatState.finish_announcement(match_mode, team_scores, player_scores, fighters)
	if _is_network_server():
		_broadcast_state()
	_show_match_end_ui()
	queue_redraw()


func _scores() -> Array[int]:
	return team_scores.duplicate()


func _cycle_map(step: int) -> void:
	_apply_map((current_map_index + step) % MAP_COUNT)
	if _is_network_server():
		GameSession.map_index = current_map_index
	announcement = "地图：%s · 金麦+2分 毒麦降意" % MAP_NAMES[current_map_index]
	announcement_timer = 1.4


func _apply_map(index: int) -> void:
	current_map_index = index
	territory.fill(-1)
	regrow_timers.fill(0.0)
	team_scores = [0, 0]
	player_scores.resize(MAX_PLAYERS)
	player_scores.fill(0)
	_init_match_stats()
	thrown_sickles.clear()
	powerups.clear()
	fire_embers.clear()
	barrier_zones.clear()
	clash_effects.clear()
	fighter_interps.clear()
	dirty_wheat_cells.clear()
	pending_visual_events.clear()
	force_full_wheat_sync = true
	full_wheat_sync_timer = 0.0
	_build_map_layout(index)
	_load_map_teleports(index)
	_spawn_special_wheat(_map_spawn_points_8(index))
	_build_wheat_blades()
	_spawn_match_roster()


func _spawn_match_roster() -> void:
	fighters.clear()
	var spawn_points := _map_spawn_points_8(current_map_index)
	if _is_online():
		for slot in GameSession.slots:
			if slot.peer_id > 0:
				_spawn_from_slot(slot, spawn_points[slot.player_id])
		if GameSession.fill_ai:
			for slot in GameSession.slots:
				if slot.peer_id == 0:
					_spawn_from_slot(slot, spawn_points[slot.player_id], true)
	else:
		_spawn_fighter(0, CharacterCatalog.get_character_name(GameSession.my_character_id), spawn_points[0], false, 0, 0)
		for ai_id in range(1, 4):
			var ai_name := CharacterCatalog.get_character_name(GameSession.resolve_character_id(ai_id))
			_spawn_fighter(ai_id % 2, ai_name, spawn_points[ai_id], true, ai_id, 0)


func _spawn_from_slot(slot: GameSession.PlayerSlot, at: Vector2, force_ai: bool = false) -> void:
	var is_ai := force_ai or slot.peer_id <= 0
	_spawn_fighter(slot.team, slot.display_name, at, is_ai, slot.player_id, slot.peer_id)


func _map_spawn_points_8(index: int) -> Array[Vector2]:
	var defaults: Array[Vector2] = [
		Vector2(116, 220), Vector2(180, 420), Vector2(1164, 220), Vector2(1100, 420),
		Vector2(116, 370), Vector2(640, 180), Vector2(640, 520), Vector2(1164, 420),
	]
	var points: Array[Vector2] = []
	points.append_array(defaults)
	var map_points := _map_spawns(index)
	for i in range(mini(map_points.size(), 4)):
		var entry = map_points[i]
		points[i] = entry[2]
	if index == 0:
		points[4] = Vector2(116, 370)
		points[5] = Vector2(640, 200)
		points[6] = Vector2(640, 500)
		points[7] = Vector2(1164, 370)
	return points


func _build_map_layout(index: int) -> void:
	var masks := MapLayoutData.build_masks(index)
	wheat_mask = masks["wheat"]
	wall_mask = masks["wall"]
	water_mask = masks["water"]


func _spawn_special_wheat(spawn_points: Array[Vector2]) -> void:
	special_wheat.resize(GRID_COLS * GRID_ROWS)
	special_wheat.fill(SPECIAL_WHEAT_NONE)
	var candidates: Array[int] = []
	for y in range(GRID_ROWS):
		for x in range(GRID_COLS):
			var cell := Vector2i(x, y)
			var index := _cell_index(cell)
			if not wheat_mask[index]:
				continue
			var center := _cell_center(cell)
			var too_close := false
			for spawn in spawn_points:
				if center.distance_to(spawn) < SPECIAL_WHEAT_SPAWN_CLEARANCE:
					too_close = true
					break
			if too_close:
				continue
			candidates.append(index)
	for i in range(candidates.size() - 1, 0, -1):
		var swap_index := rng.randi_range(0, i)
		var temp := candidates[i]
		candidates[i] = candidates[swap_index]
		candidates[swap_index] = temp
	var placed_gold := 0
	var placed_cursed := 0
	for index in candidates:
		if placed_gold >= SPECIAL_WHEAT_GOLD_COUNT and placed_cursed >= SPECIAL_WHEAT_CURSED_COUNT:
			break
		if placed_gold < SPECIAL_WHEAT_GOLD_COUNT and (
			placed_cursed >= SPECIAL_WHEAT_CURSED_COUNT or rng.randf() < 0.58
		):
			special_wheat[index] = SPECIAL_WHEAT_GOLD
			placed_gold += 1
		elif placed_cursed < SPECIAL_WHEAT_CURSED_COUNT:
			special_wheat[index] = SPECIAL_WHEAT_CURSED
			placed_cursed += 1


func _load_map_teleports(index: int) -> void:
	map_teleports.clear()
	var config := MapConfig.load_map(index)
	for entry in config.get("teleports", []):
		if typeof(entry) != TYPE_DICTIONARY:
			continue
		var portal := TeleportPortal.new()
		portal.id = str(entry.get("id", ""))
		portal.position = Vector2(float(entry.get("x", 0.0)), float(entry.get("y", 0.0)))
		portal.link_id = str(entry.get("link", ""))
		portal.label = str(entry.get("label", portal.id))
		if portal.id != "" and portal.link_id != "":
			map_teleports.append(portal)


func _find_teleport(portal_id: String) -> TeleportPortal:
	for portal in map_teleports:
		if portal.id == portal_id:
			return portal
	return null


func _check_teleports(fighter: Fighter) -> void:
	if fighter.respawn_timer > 0.0 or fighter.teleport_cooldown > 0.0:
		return
	for portal in map_teleports:
		if fighter.position.distance_to(portal.position) > TELEPORT_RADIUS:
			continue
		var destination := _find_teleport(portal.link_id)
		if destination == null or destination.id == portal.id:
			continue
		fighter.position = destination.position
		fighter.teleport_cooldown = TELEPORT_COOLDOWN
		var tp_stats := _stats_for(fighter)
		if tp_stats != null:
			tp_stats.teleports += 1
		announcement = "%s 通过传送门" % fighter.label
		announcement_timer = 0.6
		return


func _map_spawns(index: int) -> Array:
	match index:
		1:
			return [
				[0, "你", Vector2(150, 200), false],
				[0, "青禾", Vector2(210, 200), true],
				[1, "赤镰", Vector2(1130, 200), true],
				[1, "晚霞", Vector2(1070, 200), true],
			]
		2:
			return [
				[0, "你", Vector2(130, 370), false],
				[0, "青禾", Vector2(200, 300), true],
				[1, "赤镰", Vector2(1150, 370), true],
				[1, "晚霞", Vector2(1080, 300), true],
			]
		3:
			return [
				[0, "你", Vector2(130, 370), false],
				[0, "青禾", Vector2(220, 370), true],
				[1, "赤镰", Vector2(1150, 370), true],
				[1, "晚霞", Vector2(1060, 370), true],
			]
		4:
			return [
				[0, "你", Vector2(130, 250), false],
				[0, "青禾", Vector2(130, 450), true],
				[1, "赤镰", Vector2(1150, 250), true],
				[1, "晚霞", Vector2(1150, 450), true],
			]
		5:
			return [
				[0, "你", Vector2(116, 220), false],
				[0, "青禾", Vector2(180, 420), true],
				[1, "赤镰", Vector2(1164, 220), true],
				[1, "晚霞", Vector2(1100, 420), true],
			]
		_:
			return [
				[0, "你", Vector2(116, 370), false],
				[0, "青禾", Vector2(180, 370), true],
				[1, "赤镰", Vector2(1164, 370), true],
				[1, "晚霞", Vector2(1100, 370), true],
			]


func _cell_is_wall(cell: Vector2i) -> bool:
	if cell.x < 0 or cell.x >= GRID_COLS or cell.y < 0 or cell.y >= GRID_ROWS:
		return true
	return wall_mask[_cell_index(cell)]


func _clamp_fighter_to_arena(fighter: Fighter) -> void:
	fighter.position.x = clampf(fighter.position.x, ARENA.position.x + UNIT_RADIUS, ARENA.end.x - UNIT_RADIUS)
	fighter.position.y = clampf(fighter.position.y, ARENA.position.y + UNIT_RADIUS, ARENA.end.y - UNIT_RADIUS)


func _resolve_fighter_overlaps() -> void:
	var min_dist := FIGHTER_SEPARATION_RADIUS
	var min_dist_sq := min_dist * min_dist
	for i in range(fighters.size()):
		var fighter_a := fighters[i]
		if fighter_a.respawn_timer > 0.0:
			continue
		for j in range(i + 1, fighters.size()):
			var fighter_b := fighters[j]
			if fighter_b.respawn_timer > 0.0:
				continue
			var offset := fighter_b.position - fighter_a.position
			var dist_sq := offset.length_squared()
			if dist_sq >= min_dist_sq:
				continue
			var push_dir := Vector2.RIGHT
			if dist_sq > 0.01:
				push_dir = offset.normalized()
			else:
				push_dir = Vector2.from_angle(fighter_a.anim_seed * 2.7 - fighter_b.anim_seed)
			var overlap := min_dist - sqrt(dist_sq)
			var half_push := overlap * 0.5 + 0.5
			fighter_a.position -= push_dir * half_push
			fighter_b.position += push_dir * half_push
	for fighter in fighters:
		if fighter.respawn_timer > 0.0:
			continue
		_clamp_fighter_to_arena(fighter)
		_nudge_fighter_out_of_walls(fighter)


func _nudge_fighter_out_of_walls(fighter: Fighter) -> void:
	if fighter.sprint_timer > 0.0 and fighter.phase_sprint_active:
		return
	for _attempt in range(6):
		if not _cell_is_wall(_position_to_cell(fighter.position)):
			return
		for offset in [
			Vector2(18, 0), Vector2(-18, 0), Vector2(0, 18), Vector2(0, -18),
			Vector2(14, 14), Vector2(-14, 14), Vector2(14, -14), Vector2(-14, -14),
		]:
			var candidate: Vector2 = fighter.position + offset
			if not _cell_is_wall(_position_to_cell(candidate)):
				fighter.position = candidate
				return


func _apply_wall_constraints(fighter: Fighter, previous_position: Vector2) -> void:
	if fighter.respawn_timer > 0.0:
		return
	if fighter.sprint_timer > 0.0 and fighter.phase_sprint_active:
		return
	var cell := _position_to_cell(fighter.position)
	if not _cell_is_wall(cell):
		return
	fighter.position = previous_position
	if _cell_is_wall(_position_to_cell(fighter.position)):
		for offset in [Vector2(18, 0), Vector2(-18, 0), Vector2(0, 18), Vector2(0, -18)]:
			var candidate: Vector2 = previous_position + offset
			if not _cell_is_wall(_position_to_cell(candidate)):
				fighter.position = candidate
				return


func _sickle_path_blocked(from: Vector2, to: Vector2) -> bool:
	if _cell_is_wall(_position_to_cell(to)):
		return true
	var travel := to - from
	var distance := travel.length()
	if distance <= 0.001:
		return false
	var steps := maxi(1, ceili(distance / (CELL_SIZE * 0.45)))
	for step in range(1, steps):
		var t := float(step) / float(steps)
		if _cell_is_wall(_position_to_cell(from.lerp(to, t))):
			return true
	return false


func _clamp_sickle_position(position: Vector2) -> Vector2:
	position.x = clampf(position.x, ARENA.position.x + 8.0, ARENA.end.x - 8.0)
	position.y = clampf(position.y, ARENA.position.y + 8.0, ARENA.end.y - 8.0)
	return position


func _current_grass_color() -> Color:
	return MAP_GRASS[current_map_index]


func _current_accent_color() -> Color:
	return MAP_ACCENT[current_map_index]


func _build_wheat_blades() -> void:
	wheat_blades.clear()
	for y in range(GRID_ROWS):
		for x in range(GRID_COLS):
			var cell := Vector2i(x, y)
			if not wheat_mask[_cell_index(cell)]:
				continue
			for index in range(WHEAT_BLADES_PER_CELL):
				var seed := float(x * 97 + y * 131 + index * 47)
				var blade := WheatBlade.new()
				blade.cell = cell
				blade.offset = Vector2(
					sin(seed * 1.73) * 11.0 + sin(seed * 0.37) * 3.0,
					cos(seed * 1.19) * 8.0 + cos(seed * 0.23) * 2.5
				)
				blade.height = 14.0 + fposmod(sin(seed * 0.61) * 999.0, 1.0) * 12.0
				blade.width = 1.6 + fposmod(cos(seed * 0.49) * 999.0, 1.0) * 1.5
				blade.phase = fposmod(seed * 0.43, TAU)
				blade.tint = fposmod(sin(seed * 0.29) * 999.0, 1.0)
				blade.tuft = fposmod(cos(seed * 0.31) * 999.0, 1.0)
				wheat_blades.append(blade)


func _position_to_cell(position: Vector2) -> Vector2i:
	return WheatField.position_to_cell(position)


func _cell_center(cell: Vector2i) -> Vector2:
	return WheatField.cell_center(cell)


func _cell_index(cell: Vector2i) -> int:
	return WheatField.cell_index(cell)


func _draw() -> void:
	var shake_offset := Vector2.ZERO
	if screen_shake > 0.0:
		shake_offset = Vector2(rng.randf_range(-4.0, 4.0), rng.randf_range(-4.0, 4.0))
	draw_set_transform(shake_offset)
	var field_grass := _current_grass_color()
	draw_rect(Rect2(Vector2.ZERO, Vector2(1280, 720)), field_grass)
	_draw_header()
	_draw_field()
	_draw_barrier_zones()
	_draw_spawn_shields()
	_draw_teleports()
	_draw_powerups()
	_draw_harvest_sparks()
	_draw_fire_embers()
	_draw_thrown_sickles()
	_draw_clash_effects()
	_draw_fighters()
	_draw_orbit_rings()
	_draw_overlays()
	draw_set_transform(Vector2.ZERO)


func _draw_header() -> void:
	var scores := _scores()
	var claimed := maxi(1, scores[0] + scores[1])
	var left_ratio := float(scores[0]) / claimed
	draw_style_box(_pixel_panel(Color("#244b3bd9")), Rect2(26, 22, 222, 62))
	draw_string(ThemeDB.fallback_font, Vector2(46, 49), "麦浪争锋", HORIZONTAL_ALIGNMENT_LEFT, -1, 24, Color("#fff6c9"))
	draw_string(ThemeDB.fallback_font, Vector2(46, 72), "第%d/%d轮 · %s" % [GameSession.current_round, GameSession.total_rounds, MAP_NAMES[current_map_index]], HORIZONTAL_ALIGNMENT_LEFT, -1, 14, Color("#d5eccf"))
	draw_style_box(_pixel_panel(Color("#244b3be8")), Rect2(386, 18, 508, 68))
	draw_rect(Rect2(402, 33, 476, 30), Color("#173a31"), true)
	draw_rect(Rect2(406, 37, 468 * left_ratio, 22), TEAM_COLORS[0], true)
	draw_rect(Rect2(406 + 468 * left_ratio, 37, 468 * (1.0 - left_ratio), 22), TEAM_COLORS[1], true)
	draw_string(ThemeDB.fallback_font, Vector2(412, 59), "%d" % scores[0], HORIZONTAL_ALIGNMENT_LEFT, -1, 18, Color.WHITE)
	draw_string(ThemeDB.fallback_font, Vector2(838, 59), "%d" % scores[1], HORIZONTAL_ALIGNMENT_LEFT, -1, 18, Color.WHITE)
	draw_string(ThemeDB.fallback_font, Vector2(402, 78), "累计 %d" % GameSession.cumulative_team_scores[0], HORIZONTAL_ALIGNMENT_LEFT, -1, 12, Color("#d5eccf"))
	draw_string(ThemeDB.fallback_font, Vector2(832, 78), "累计 %d" % GameSession.cumulative_team_scores[1], HORIZONTAL_ALIGNMENT_LEFT, -1, 12, Color("#d5eccf"))
	var minutes := floori(match_time / 60.0)
	var seconds := floori(match_time) % 60
	draw_style_box(_pixel_panel(Color("#244b3be8")), Rect2(1024, 22, 224, 62))
	draw_string(ThemeDB.fallback_font, Vector2(1040, 61), "%d:%02d" % [minutes, seconds], HORIZONTAL_ALIGNMENT_LEFT, 82, 29, Color("#fff6c9"))
	draw_string(ThemeDB.fallback_font, Vector2(1125, 48), "空格冲刺 Q结界 F11全屏", HORIZONTAL_ALIGNMENT_LEFT, -1, 13, Color("#d5eccf"))
	draw_string(ThemeDB.fallback_font, Vector2(1125, 68), "左键挥镰 回车投镰", HORIZONTAL_ALIGNMENT_LEFT, -1, 13, Color("#d5eccf"))


func _draw_field() -> void:
	var field_grass := _current_grass_color()
	var field_accent := _current_accent_color()
	var now := Time.get_ticks_msec() * 0.001
	draw_rect(ARENA, field_grass, true)
	_draw_grass_texture()
	for y in range(GRID_ROWS):
		for x in range(GRID_COLS):
			var cell := Vector2i(x, y)
			var center := _cell_center(cell)
			if water_mask[_cell_index(cell)]:
				draw_rect(Rect2(center - Vector2.ONE * 13.0, Vector2.ONE * 26.0), field_accent.darkened(0.1), true)
				draw_line(center + Vector2(-8, 2), center + Vector2(8, -2), Color("#ffffff33"), 2.0)
				continue
			if wall_mask[_cell_index(cell)]:
				draw_rect(Rect2(center - Vector2.ONE * 13.0, Vector2.ONE * 26.0), field_accent.darkened(0.35), true)
				draw_rect(Rect2(center - Vector2.ONE * 9.0, Vector2.ONE * 18.0), field_accent.lightened(0.08), true)
				continue
			if not wheat_mask[_cell_index(cell)]:
				continue
			var owner := territory[_cell_index(cell)]
			var special := special_wheat[_cell_index(cell)]
			if owner == -1 and special != SPECIAL_WHEAT_NONE:
				var pulse := 0.5 + 0.5 * sin(now * 3.0 + x * 0.7 + y * 0.5)
				if special == SPECIAL_WHEAT_GOLD:
					draw_arc(center, 11.0, 0.0, TAU, 16, Color("#ffe066", 0.22 + pulse * 0.18), 2.0)
					draw_string(ThemeDB.fallback_font, center + Vector2(-8, 4), "金", HORIZONTAL_ALIGNMENT_CENTER, 16, 11, Color("#fff3b0"))
				else:
					draw_arc(center, 11.0, 0.0, TAU, 16, Color("#9b6bd4", 0.2 + pulse * 0.16), 2.0)
					draw_string(ThemeDB.fallback_font, center + Vector2(-8, 4), "毒", HORIZONTAL_ALIGNMENT_CENTER, 16, 11, Color("#e8d0ff"))
			if owner != -1:
				var cut_color := GRASS_LIGHT.lerp(TEAM_COLORS[owner], 0.13)
				draw_rect(Rect2(center - Vector2.ONE * 13.0, Vector2.ONE * 26.0), cut_color, true)
				var regrow_progress := 1.0 - regrow_timers[_cell_index(cell)] / WHEAT_REGROW_SECONDS
				if regrow_progress > 0.48:
					var sprout_color := GRASS_DARK.lerp(WHEAT_DARK, regrow_progress)
					var sprout_height := 4.0 + regrow_progress * 8.0
					for sprout in range(3):
						var seed := float(x * 23 + y * 41 + sprout * 17)
						var base := center + Vector2(sin(seed) * 8.0, cos(seed * 1.7) * 7.0)
						draw_line(base, base + Vector2(sin(seed * 0.5) * 2.0, -sprout_height), sprout_color, 2.0)
				if (x * 7 + y * 11) % 5 == 0:
					draw_rect(Rect2(center + Vector2(-3, -3), Vector2(6, 6)), TEAM_COLORS[owner], true)
					draw_rect(Rect2(center + Vector2(-1, -7), Vector2(2, 12)), TEAM_COLORS[owner].lightened(0.18), true)
	var blade_now := Time.get_ticks_msec() * 0.001
	for blade in wheat_blades:
		var owner := territory[_cell_index(blade.cell)]
		if owner == -1:
			_draw_wheat_blade(blade, blade_now)
		elif blade.tuft > 0.42:
			_draw_cut_stubble(blade, owner)
	draw_rect(ARENA, Color("#173a3155"), false, 4.0)


func _draw_grass_texture() -> void:
	for y in range(0, GRID_ROWS, 2):
		var row_offset := (y / 2) % 2
		for x in range(row_offset, GRID_COLS, 3):
			var grass_point := _cell_center(Vector2i(x, y)) + Vector2(-8, 7)
			var lift := 3.5 + fposmod(float(x * 13 + y * 17), 4.0)
			draw_line(grass_point, grass_point + Vector2(-2, -lift), GRASS_DARK, 2.0)
			draw_line(grass_point + Vector2(2, 0), grass_point + Vector2(4, -lift * 0.75), GRASS_LIGHT, 2.0)


func _draw_wheat_blade(blade: WheatBlade, now: float) -> void:
	var base := _cell_center(blade.cell) + blade.offset
	var special := special_wheat[_cell_index(blade.cell)]
	var wind := sin(now * 2.2 + blade.phase + base.x * 0.018 + base.y * 0.006) * 4.4
	wind += sin(now * 1.1 + blade.phase * 0.7) * 1.8
	var bend := Vector2(wind, 0.0)
	var pressure := 0.0
	for fighter in fighters:
		if fighter.respawn_timer > 0.0:
			continue
		var away := base - fighter.position
		var distance := away.length()
		if distance >= WHEAT_BEND_RADIUS:
			continue
		var strength := pow(1.0 - distance / WHEAT_BEND_RADIUS, 2.0)
		if away.length_squared() > 0.1:
			bend += away.normalized() * strength * 22.0
		pressure = maxf(pressure, strength)
	var height := blade.height * lerpf(1.0, 0.62, pressure)
	if special == SPECIAL_WHEAT_GOLD:
		height *= 1.12
	var tip := base + Vector2(bend.x, -height + absf(bend.x) * 0.12 + pressure * 5.0)
	var stalk_color := WHEAT_DARK.lerp(WHEAT, blade.tint * 0.55)
	var head_color := WHEAT_LIGHT.lerp(Color("#f7d85d"), blade.tint * 0.35)
	match special:
		SPECIAL_WHEAT_GOLD:
			stalk_color = WHEAT_DARK.lerp(Color("#f7d85d"), 0.72)
			head_color = Color("#ffe066")
		SPECIAL_WHEAT_CURSED:
			stalk_color = Color("#4a3558").lerp(Color("#7a5290"), blade.tint * 0.45)
			head_color = Color("#b48cff").lerp(Color("#5c3d72"), 0.35)
	draw_line(base, tip, stalk_color, blade.width)
	if blade.tuft > 0.16:
		var head_size := Vector2(5.0 + blade.tuft * 3.0, 4.0 + blade.tint * 2.0)
		draw_rect(Rect2(tip + Vector2(-head_size.x * 0.5, -head_size.y * 0.5), head_size), head_color, true)
	if pressure > 0.04:
		var shimmer := Color("#fff4a8")
		shimmer.a = minf(0.42, pressure * 0.75)
		draw_line(tip + Vector2(-5, 1), tip + Vector2(5, -1), shimmer, 1.0)


func _draw_cut_stubble(blade: WheatBlade, owner: int) -> void:
	var base := _cell_center(blade.cell) + blade.offset
	var stub_height := 3.5 + blade.tuft * 6.0
	var lean := sin(blade.phase) * 2.0
	var straw := STRAW.lerp(TEAM_COLORS[owner], 0.12)
	draw_line(base, base + Vector2(lean, -stub_height), straw, maxf(1.0, blade.width))


func _draw_fighters() -> void:
	for fighter in fighters:
		if fighter.respawn_timer > 0.0:
			if not _draw_fighter_pose_sprite(fighter, "down", fighter.spawn_position):
				_draw_pixel_farmer(fighter)
			var text := "%s  %.1f" % [fighter.label, fighter.respawn_timer]
			draw_string(ThemeDB.fallback_font, fighter.spawn_position + Vector2(-32, -28), text, HORIZONTAL_ALIGNMENT_CENTER, 64, 14, Color.WHITE)
			draw_arc(fighter.spawn_position, 23.0, -PI * 0.5, -PI * 0.5 + TAU * (1.0 - fighter.respawn_timer / RESPAWN_SECONDS), 32, _fighter_color(fighter), 4.0)
			continue
		var draw_modulate := _fighter_draw_modulate(fighter)
		if not _draw_fighter_sprite(fighter, draw_modulate):
			_draw_pixel_farmer(fighter, draw_modulate)
		if _is_stealthed(fighter):
			var pulse := sin(Time.get_ticks_msec() * 0.008 + fighter.anim_seed) * 0.5 + 0.5
			var stealth_ring := Color("#d8ecff", 0.16 + pulse * 0.14)
			draw_arc(fighter.position, 22.0, 0.0, TAU, 18, stealth_ring, 2.0)
		if fighter.attack_flash > 0.0 and not _is_stealthed(fighter):
			draw_arc(fighter.position, ATTACK_RANGE, fighter.aim.angle() - 0.8, fighter.aim.angle() + 0.8, 12, Color("#fff3b0"), 5.0)
		if fighter.clash_flash > 0.0:
			var clash_alpha := clampf(fighter.clash_flash / 0.32, 0.0, 1.0)
			var clash_color := Color("#fff0d8", clash_alpha)
			draw_arc(fighter.position, 28.0, 0.0, TAU, 20, clash_color, 4.0)
		if fighter.throw_flash > 0.0 and not _is_stealthed(fighter):
			draw_arc(fighter.position, THROW_MAX_RANGE, fighter.aim.angle() - 0.35, fighter.aim.angle() + 0.35, 10, Color("#c8f0ff"), 4.0)
		if fighter.throw_charging and not _is_stealthed(fighter):
			var charge_ratio := clampf(fighter.throw_charge / THROW_CHARGE_MAX, 0.0, 1.0)
			var ring_color := Color("#fff7b0", 0.55 + charge_ratio * 0.35)
			draw_arc(fighter.position, 18.0 + charge_ratio * 10.0, -PI * 0.5, -PI * 0.5 + TAU * charge_ratio, 24, ring_color, 3.0)
		if fighter.shield_flash > 0.0 or fighter.shield_charges > 0:
			var shield_alpha := 0.55 if fighter.shield_flash > 0.0 else 0.28
			var shield_color := Color("#9be7ff", shield_alpha)
			draw_arc(fighter.position, 24.0, 0.0, TAU, 18, shield_color, 3.0)
		if fighter.curse_slow_timer > 0.0:
			var curse_alpha := clampf(fighter.curse_slow_timer / CURSED_SLOW_DURATION, 0.0, 1.0)
			draw_arc(fighter.position, 20.0, 0.0, TAU, 16, Color("#9b6bd4", 0.18 + curse_alpha * 0.35), 2.0)
		if fighter.sprint_timer > 0.0:
			if fighter.phase_sprint_active:
				var ghost := Color("#9efcff", 0.42)
				draw_arc(fighter.position, 20.0, 0.0, TAU, 16, ghost, 3.0)
				var dash_dir := fighter.aim if fighter.velocity.length_squared() < 1.0 else fighter.velocity.normalized()
				draw_line(fighter.position - dash_dir * 14.0, fighter.position, Color("#d8fbff", 0.75), 4.0)
			else:
				draw_line(fighter.position + Vector2(-10, 8), fighter.position + Vector2(10, 8), Color("#fff4a8"), 3.0)
		_draw_fighter_buffs(fighter)
		_draw_blade_spirit(fighter)
		if _is_stealthed(fighter) and _is_local_fighter(fighter):
			draw_string(
				ThemeDB.fallback_font,
				fighter.position + Vector2(-34, 38),
				"隐身 %.0fs" % fighter.invisibility_timer,
				HORIZONTAL_ALIGNMENT_CENTER,
				68,
				12,
				Color("#d8ecff", 0.85)
			)
		elif not _is_stealthed(fighter):
			draw_string(ThemeDB.fallback_font, fighter.position + Vector2(-30, 38), fighter.label, HORIZONTAL_ALIGNMENT_CENTER, 60, 13, Color("#173a31"))


func _draw_fighter_pose_sprite(fighter: Fighter, pose: String, at_position: Vector2 = Vector2.INF, draw_modulate: Color = Color.WHITE) -> bool:
	if fighter.character_id == "":
		return false
	var texture := CharacterCatalog.get_hit_sheet_texture(fighter.character_id)
	if texture == null:
		return false
	var row := 0 if pose == "hit" else 1
	var frame_count := CharacterCatalog.get_pose_frame_count(fighter.character_id, pose, CHARACTER_FRAME_COUNT)
	var frame_speed := CharacterCatalog.get_pose_fps(fighter.character_id, pose, 10.0)
	var frame := int(Time.get_ticks_msec() * 0.001 * frame_speed + fighter.anim_seed) % frame_count
	var source := Rect2(
		frame * CHARACTER_FRAME_SIZE,
		row * CHARACTER_FRAME_SIZE,
		CHARACTER_FRAME_SIZE,
		CHARACTER_FRAME_SIZE
	)
	var draw_position := fighter.position if at_position == Vector2.INF else at_position
	var top_left := _fighter_sprite_top_left(draw_position)
	var shadow := Color("#286d4a66")
	shadow.a *= draw_modulate.a
	_draw_pixel_ellipse(_fighter_shadow_center(draw_position), Vector2(16, 5), shadow)
	draw_texture_rect_region(
		texture,
		Rect2(top_left, Vector2(CHARACTER_FRAME_SIZE, CHARACTER_FRAME_SIZE)),
		source,
		draw_modulate,
		false,
	)
	return true


func _draw_fighter_sprite(fighter: Fighter, draw_modulate: Color = Color.WHITE) -> bool:
	if fighter.character_id == "":
		return false
	if fighter.clash_flash > 0.0:
		return _draw_fighter_pose_sprite(fighter, "hit", Vector2.INF, draw_modulate)
	var texture := CharacterCatalog.get_sheet_texture(fighter.character_id)
	if texture == null:
		return false
	var action := ArenaRenderer.fighter_action(
		fighter.attack_active > 0.0 or fighter.attack_flash > 0.0 or fighter.harvest_timer > 0.0,
		fighter.velocity
	)
	var frame_count := CharacterCatalog.get_pose_frame_count(fighter.character_id, action, CHARACTER_FRAME_COUNT)
	var default_fps := 11.0 if action == "run" else 14.0 if action == "slash" else 5.0
	var frame_speed := CharacterCatalog.get_pose_fps(fighter.character_id, action, default_fps)
	var frame := int(Time.get_ticks_msec() * 0.001 * frame_speed + fighter.anim_seed) % frame_count
	var source := ArenaRenderer.fighter_sheet_source(action, fighter.aim, frame, CHARACTER_FRAME_SIZE)
	var top_left := _fighter_sprite_top_left(fighter.position)
	var shadow := Color("#286d4a66")
	shadow.a *= draw_modulate.a
	_draw_pixel_ellipse(_fighter_shadow_center(fighter.position), Vector2(16, 5), shadow)
	draw_texture_rect_region(
		texture,
		Rect2(top_left, Vector2(CHARACTER_FRAME_SIZE, CHARACTER_FRAME_SIZE)),
		source,
		draw_modulate,
		false,
	)
	return true


func _fighter_sprite_top_left(position: Vector2) -> Vector2:
	return (position - Vector2(CHARACTER_FRAME_SIZE * 0.5, CHARACTER_FRAME_SIZE - CHARACTER_SPRITE_ANCHOR_Y)).round()


func _fighter_shadow_center(position: Vector2) -> Vector2:
	return position + CHARACTER_SHADOW_OFFSET


func _tint_color(color: Color, modulate: Color) -> Color:
	var tinted := color * modulate
	tinted.a = color.a * modulate.a
	return tinted


func _draw_pixel_farmer(fighter: Fighter, draw_modulate: Color = Color.WHITE) -> void:
	var walking := fighter.velocity.length_squared() > 25.0
	var harvest_strength := clampf(fighter.harvest_timer / 0.24, 0.0, 1.0)
	var wiggle := sin(fighter.harvest_phase + fighter.anim_seed)
	var hop := 0.0
	var body_squash := 0.0
	var body_lean := 0.0
	if harvest_strength > 0.0:
		hop = -abs(sin(fighter.harvest_phase * 1.5)) * 5.0
		body_squash = abs(wiggle) * 3.0
		body_lean = wiggle * 5.0
	elif walking:
		hop = -abs(sin(Time.get_ticks_msec() * 0.012 + fighter.anim_seed)) * 2.0
	var p := (fighter.position + Vector2(body_lean, hop)).round()
	var facing := 1.0 if fighter.aim.x >= 0.0 else -1.0
	var shadow := _tint_color(Color("#286d4a66"), draw_modulate)
	_draw_pixel_ellipse(_fighter_shadow_center(fighter.position), Vector2(16, 5), shadow)
	draw_rect(Rect2(p + Vector2(-9, -7 + body_squash), Vector2(18, 19 - body_squash)), _tint_color(_fighter_dark_color(fighter), draw_modulate), true)
	var foot_kick := 5.0 if harvest_strength > 0.0 else 0.0
	draw_rect(Rect2(p + Vector2(-11 - foot_kick * wiggle, 7), Vector2(8, 10)), _tint_color(Color("#6c4934"), draw_modulate), true)
	draw_rect(Rect2(p + Vector2(3 + foot_kick * wiggle, 7), Vector2(8, 10)), _tint_color(Color("#6c4934"), draw_modulate), true)
	draw_rect(Rect2(p + Vector2(-8, -19 + body_squash), Vector2(16, 14)), _tint_color(Color("#b97147"), draw_modulate), true)
	var cheek_color := _tint_color(Color("#e69a6c"), draw_modulate)
	draw_rect(Rect2(p + Vector2(-8, -11 + body_squash), Vector2(4, 3)), cheek_color, true)
	draw_rect(Rect2(p + Vector2(4, -11 + body_squash), Vector2(4, 3)), cheek_color, true)
	var hat_bounce: float = -absf(wiggle) * 4.0 * harvest_strength
	draw_rect(Rect2(p + Vector2(-12, -22 + hat_bounce), Vector2(24, 6)), _tint_color(_fighter_color(fighter), draw_modulate), true)
	draw_rect(Rect2(p + Vector2(-7, -27 + hat_bounce), Vector2(14, 6)), _tint_color(_fighter_color(fighter).lightened(0.12), draw_modulate), true)
	draw_rect(Rect2(p + Vector2(facing * 7 - 2, -15 + body_squash), Vector2(4, 3)), _tint_color(Color("#3c2925"), draw_modulate), true)
	var hand := p + Vector2(facing * 10, -1)
	var sickle_direction := fighter.aim
	if harvest_strength > 0.0:
		var sweep_angle := fighter.aim.angle() + wiggle * 1.7
		sickle_direction = Vector2.from_angle(sweep_angle)
	var sickle_on_fire := fighter.fire_sickle_charges > 0
	_draw_sickle_blade(hand, sickle_direction, 0.0, 30.0 + harvest_strength * 7.0, sickle_on_fire)
	if harvest_strength > 0.0:
		draw_arc(p, 38.0, sickle_direction.angle() - 0.9, sickle_direction.angle() + 0.45, 10, Color("#fff7b099"), 3.0)
	if fighter.throw_flash > 0.0:
		draw_arc(hand, 18.0, fighter.aim.angle() - 0.55, fighter.aim.angle() + 0.55, 8, Color("#c8f0ff88"), 2.0)


func _draw_pixel_ellipse(center: Vector2, radius: Vector2, color: Color) -> void:
	var points := PackedVector2Array()
	for index in range(16):
		var angle := TAU * float(index) / 16.0
		points.append(center + Vector2(cos(angle) * radius.x, sin(angle) * radius.y))
	draw_colored_polygon(points, color)


func _draw_blade_spirit(fighter: Fighter) -> void:
	for index in range(BLADE_SPIRIT_MAX):
		var filled := index < fighter.blade_spirit
		var pip_x := fighter.position.x - 16.0 + index * 11.0
		var pip_y := fighter.position.y - 35.0
		var base_color := Color("#49332d") if filled else Color("#49332d88")
		var spirit_color: Color = _fighter_color(fighter).lightened(0.25) if filled else Color("#6a5a4a66")
		draw_rect(Rect2(pip_x, pip_y, 8, 8), base_color, true)
		if filled:
			draw_rect(Rect2(pip_x + 1, pip_y + 1, 6, 6), spirit_color, true)


func _draw_clash_effects() -> void:
	for effect in clash_effects:
		var alpha := clampf(effect.life / effect.max_life, 0.0, 1.0)
		var burst := Color("#fff8e8", alpha)
		draw_arc(effect.position, 10.0 + (1.0 - alpha) * 18.0, 0.0, TAU, 16, burst, 4.0)
		draw_line(effect.position + Vector2(-14, 0), effect.position + Vector2(14, 0), Color("#fff0b0", alpha), 3.0)
		draw_line(effect.position + Vector2(0, -14), effect.position + Vector2(0, 14), Color("#fff0b0", alpha), 3.0)
		draw_line(effect.position + Vector2(-10, -10), effect.position + Vector2(10, 10), Color("#ffd27a", alpha * 0.85), 2.0)
		draw_line(effect.position + Vector2(10, -10), effect.position + Vector2(-10, 10), Color("#ffd27a", alpha * 0.85), 2.0)


func _draw_sickle_blade(at: Vector2, direction: Vector2, spin: float, length: float = 30.0, on_fire: bool = false) -> void:
	if sickle_texture != null:
		_draw_sickle_sprite(at, direction, spin, on_fire)
		return
	_draw_sickle_blade_procedural(at, direction, spin, length, on_fire)


func _draw_sickle_sprite(at: Vector2, direction: Vector2, spin: float, on_fire: bool) -> void:
	var frame := int(absf(spin) / TAU * float(SICKLE_FRAME_COUNT)) % SICKLE_FRAME_COUNT
	var col := frame % 4
	var row := int(frame / 4)
	var source := Rect2(
		col * SICKLE_FRAME_SIZE,
		row * SICKLE_FRAME_SIZE,
		SICKLE_FRAME_SIZE,
		SICKLE_FRAME_SIZE
	)
	var scale := 1.0
	var tint := Color.WHITE if not on_fire else Color("#ffd8a8")
	draw_set_transform(at, direction.angle() + spin * 0.35, Vector2(scale, scale))
	draw_texture_rect_region(
		sickle_texture,
		Rect2(-SICKLE_FRAME_SIZE * 0.5, -SICKLE_FRAME_SIZE * 0.5, SICKLE_FRAME_SIZE, SICKLE_FRAME_SIZE),
		source,
		tint,
		false,
	)
	draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)


func _draw_sickle_blade_procedural(at: Vector2, direction: Vector2, spin: float, length: float = 30.0, on_fire: bool = false) -> void:
	var dir := direction.rotated(spin)
	var blade_tip := at + dir * length
	var handle_color := Color("#71472f")
	var blade_color := Color("#edf2d4")
	if on_fire:
		handle_color = Color("#8f3d1d")
		blade_color = Color("#ffd27a")
	draw_line(at, blade_tip, handle_color, 4.0)
	draw_arc(blade_tip, 11.0, dir.angle() - 1.3, dir.angle() + 0.2, 8, blade_color, 3.0)
	if on_fire:
		draw_arc(blade_tip, 8.0, 0.0, TAU, 10, Color("#ff8a3c99"), 2.0)


func _draw_fighter_buffs(fighter: Fighter) -> void:
	var buff_y := fighter.position.y - 44.0
	var buff_x := fighter.position.x - 20.0
	if fighter.shield_charges > 0:
		draw_rect(Rect2(buff_x + 26.0, buff_y, 6, 6), Color("#9be7ff"), true)
	if fighter.fire_sickle_charges > 0:
		draw_rect(Rect2(buff_x + 34.0, buff_y, 6, 6), Color("#ff8a3c"), true)
	if fighter.split_sickle_charges > 0:
		draw_rect(Rect2(buff_x + 42.0, buff_y, 6, 6), Color("#ffd166"), true)
	if fighter.barrier_charges > 0:
		draw_rect(Rect2(buff_x + 50.0, buff_y, 6, 6), Color("#b48cff"), true)
	if fighter.phase_sprint_charges > 0:
		draw_rect(Rect2(buff_x + 58.0, buff_y, 6, 6), Color("#7ce8ff"), true)
	if fighter.orbit_ring_active:
		draw_rect(Rect2(buff_x + 66.0, buff_y, 6, 6), Color("#58e6a0"), true)
	if fighter.invisibility_timer > 0.0:
		draw_rect(Rect2(buff_x + 74.0, buff_y, 6, 6), Color("#c8d8e8"), true)


func _draw_orbit_rings() -> void:
	for fighter in fighters:
		if not fighter.orbit_ring_active or fighter.respawn_timer > 0.0 or _is_stealthed(fighter):
			continue
		var ring_color := _fighter_color(fighter)
		ring_color.a = 0.2
		draw_arc(fighter.position, ORBIT_RING_RADIUS, 0.0, TAU, 40, ring_color, 1.5)
		for blade_index in range(ORBIT_RING_COUNT):
			var angle := fighter.orbit_ring_spin + TAU * float(blade_index) / float(ORBIT_RING_COUNT)
			var blade_pos := fighter.position + Vector2.from_angle(angle) * ORBIT_RING_RADIUS
			var blade_dir := Vector2.from_angle(angle + PI * 0.5)
			_draw_sickle_blade(blade_pos, blade_dir, fighter.orbit_ring_spin * 2.4 + float(blade_index) * 0.8)


func _draw_spawn_shields() -> void:
	for fighter in fighters:
		if fighter.respawn_timer <= 0.0:
			continue
		var center := fighter.spawn_position
		var team_color := _fighter_color(fighter)
		var progress := 1.0 - fighter.respawn_timer / RESPAWN_SECONDS
		var pulse := sin(Time.get_ticks_msec() * 0.006 + fighter.anim_seed) * 0.5 + 0.5
		var fill := Color("#dff6ff")
		fill.a = 0.1 + progress * 0.06
		draw_circle(center, SPAWN_SHIELD_RADIUS, fill)
		var inner_fill := team_color
		inner_fill.a = 0.07 + pulse * 0.05
		draw_circle(center, SPAWN_SHIELD_RADIUS - 10.0, inner_fill)
		var ring := Color("#f4fdff")
		ring.a = 0.42 + pulse * 0.18
		draw_arc(center, SPAWN_SHIELD_RADIUS, 0.0, TAU, 56, ring, 3.0)
		var inner_ring := team_color.lightened(0.35)
		inner_ring.a = 0.34
		draw_arc(center, SPAWN_SHIELD_RADIUS - 8.0, 0.0, TAU, 48, inner_ring, 2.0)
		var sweep := Time.get_ticks_msec() * 0.004 + fighter.anim_seed
		for segment in range(3):
			var start := sweep + segment * TAU / 3.0
			draw_arc(center, SPAWN_SHIELD_RADIUS - 4.0, start, start + 0.9, 18, Color("#ffffff55"), 2.0)
		draw_string(ThemeDB.fallback_font, center + Vector2(-10, 5), "护", HORIZONTAL_ALIGNMENT_CENTER, 20, 14, Color("#f4fdffaa"))


func _draw_teleports() -> void:
	var pulse := sin(Time.get_ticks_msec() * 0.005) * 0.5 + 0.5
	for portal in map_teleports:
		var fill := Color("#c89cff", 0.14 + pulse * 0.08)
		draw_circle(portal.position, 20.0, fill)
		var ring := Color("#ead0ff", 0.55 + pulse * 0.25)
		draw_arc(portal.position, 20.0, 0.0, TAU, 28, ring, 2.5)
		draw_arc(portal.position, 12.0, pulse * TAU, pulse * TAU + 1.4, 12, Color("#ffffff88"), 2.0)
		draw_string(ThemeDB.fallback_font, portal.position + Vector2(-24, -22), portal.label, HORIZONTAL_ALIGNMENT_CENTER, 48, 12, Color("#f8ecff"))
		var linked := _find_teleport(portal.link_id)
		if linked != null and portal.id < linked.id:
			draw_line(portal.position, linked.position, Color("#d9b6ff44"), 2.0)


func _draw_barrier_zones() -> void:
	for zone in barrier_zones:
		var team_color: Color = TEAM_COLORS[zone.team]
		var sealing := zone.seal_timer > 0.0
		var fill := team_color
		fill.a = 0.16 if sealing else 0.1
		draw_circle(zone.position, BARRIER_RADIUS, fill)
		var ring := team_color.lightened(0.18)
		ring.a = 0.72
		draw_arc(zone.position, BARRIER_RADIUS, 0.0, TAU, 48, ring, 4.0)
		if sealing:
			var lock_color := Color("#fff7b0", 0.55)
			draw_arc(zone.position, BARRIER_RADIUS - 10.0, zone.pulse, zone.pulse + TAU * 0.72, 28, lock_color, 3.0)
			draw_string(ThemeDB.fallback_font, zone.position + Vector2(-8, 5), "封", HORIZONTAL_ALIGNMENT_CENTER, 16, 14, Color("#fff7b0"))
		else:
			var open_color := team_color.lightened(0.35)
			open_color.a = 0.65
			draw_arc(zone.position, BARRIER_RADIUS - 14.0, -PI * 0.5, PI * 0.5, 20, open_color, 3.0)
			draw_string(ThemeDB.fallback_font, zone.position + Vector2(-8, 5), "友", HORIZONTAL_ALIGNMENT_CENTER, 16, 14, open_color)


func _draw_powerups() -> void:
	for powerup in powerups:
		var bob := sin(powerup.bob_phase) * 4.0
		var at := powerup.position + Vector2(0.0, bob)
		var glow := Color.WHITE
		var icon := "?"
		match powerup.kind:
			POWERUP_SHIELD:
				glow = Color("#9be7ff")
				icon = "盾"
			POWERUP_FIRE:
				glow = Color("#ff8a3c")
				icon = "火"
			POWERUP_BARRIER:
				glow = Color("#b48cff")
				icon = "界"
			POWERUP_SPLIT:
				glow = Color("#ffd166")
				icon = "裂"
			POWERUP_PHASE_SPRINT:
				glow = Color("#7ce8ff")
				icon = "穿"
			POWERUP_ORBIT_RING:
				glow = Color("#58e6a0")
				icon = "环"
			POWERUP_STEALTH:
				glow = Color("#c8d8e8")
				icon = "隐"
		var ring := glow
		ring.a = 0.35
		draw_arc(at, POWERUP_RADIUS + 4.0, 0.0, TAU, 16, ring, 3.0)
		draw_circle(at, POWERUP_RADIUS, glow.darkened(0.25))
		draw_circle(at, POWERUP_RADIUS - 4.0, glow)
		draw_string(ThemeDB.fallback_font, at + Vector2(-8, 5), icon, HORIZONTAL_ALIGNMENT_CENTER, 16, 14, Color("#173a31"))


func _draw_thrown_sickles() -> void:
	for sickle in thrown_sickles:
		if sickle.on_fire:
			draw_line(sickle.position - sickle.direction * 20.0, sickle.position, Color("#ff8a3caa"), 5.0)
			draw_arc(sickle.position, 16.0, 0.0, TAU, 10, Color("#ff5a1a55"), 2.0)
		else:
			var trail_color: Color = TEAM_COLORS[sickle.owner.team]
			trail_color.a = 0.45 + sickle.charge_power * 0.35
			draw_line(sickle.position - sickle.direction * (10.0 + sickle.charge_power * 8.0), sickle.position, trail_color, 2.0 + sickle.charge_power * 2.0)
		_draw_sickle_blade(sickle.position, sickle.direction, sickle.spin, 30.0, sickle.on_fire)
		if sickle.charge_power > 0.55:
			draw_arc(sickle.position, 10.0 + sickle.charge_power * 6.0, 0.0, TAU, 10, Color("#fff7b088"), 1.5)
		if sickle.returning:
			var glow := Color("#fff7b0") if not sickle.on_fire else Color("#ffc56b")
			glow.a = 0.55
			draw_arc(sickle.position, 14.0, 0.0, TAU, 12, glow, 2.0)


func _draw_fire_embers() -> void:
	for ember in fire_embers:
		var alpha := clampf(ember.life / ember.max_life, 0.0, 1.0)
		var core := Color("#fff0b0", alpha)
		var flame := Color("#ff6a1f", alpha * 0.85)
		var size := 2.0 + alpha * 4.0
		draw_rect(Rect2(ember.position - Vector2.ONE * size * 0.5, Vector2.ONE * size), flame, true)
		draw_rect(Rect2(ember.position - Vector2.ONE * (size * 0.35), Vector2.ONE * size * 0.7), core, true)


func _draw_harvest_sparks() -> void:
	for spark in harvest_sparks:
		var alpha := clampf(spark.life / spark.max_life, 0.0, 1.0)
		var color := WHEAT_LIGHT
		color.a = alpha
		var size := 3.0 + alpha * 2.0
		draw_rect(Rect2(spark.position - Vector2.ONE * size * 0.5, Vector2.ONE * size), color, true)
		if spark.life > spark.max_life * 0.55:
			var accent: Color = TEAM_COLORS[spark.team]
			accent.a = alpha
			draw_line(spark.position + Vector2(-5, 0), spark.position + Vector2(5, 0), accent, 2.0)
			draw_line(spark.position + Vector2(0, -5), spark.position + Vector2(0, 5), accent, 2.0)


func _pixel_panel(color: Color) -> StyleBoxFlat:
	var panel := StyleBoxFlat.new()
	panel.bg_color = color
	panel.border_color = Color("#173a31")
	panel.set_border_width_all(4)
	panel.corner_radius_top_left = 6
	panel.corner_radius_top_right = 6
	panel.corner_radius_bottom_left = 6
	panel.corner_radius_bottom_right = 6
	return panel


func _draw_overlays() -> void:
	if countdown > 0.0:
		draw_rect(Rect2(Vector2.ZERO, Vector2(1280, 720)), Color("#081018aa"), true)
		var count_text := str(ceili(countdown))
		draw_string(ThemeDB.fallback_font, Vector2(0, 360), count_text, HORIZONTAL_ALIGNMENT_CENTER, 1280, 96, Color("#fff0a8"))
		draw_string(ThemeDB.fallback_font, Vector2(0, 450), MAP_NAMES[current_map_index], HORIZONTAL_ALIGNMENT_CENTER, 1280, 28, Color("#d5eccf"))
		draw_string(ThemeDB.fallback_font, Vector2(0, 486), "Tab 切换地图", HORIZONTAL_ALIGNMENT_CENTER, 1280, 18, Color("#aeb9c8"))
	elif announcement_timer > 0.0:
		draw_rect(Rect2(390, 92, 500, 48), Color("#05080dcc"), true)
		draw_string(ThemeDB.fallback_font, Vector2(390, 124), announcement, HORIZONTAL_ALIGNMENT_CENTER, 500, 22, Color.WHITE)

	if bullet_time_timer > 0.0:
		var tint_strength := clampf(bullet_time_timer / BULLET_TIME_DURATION, 0.0, 1.0) * 0.42
		draw_rect(Rect2(Vector2.ZERO, Vector2(1280, 720)), Color("#6a8fd122"), true)
		draw_rect(Rect2(Vector2.ZERO, Vector2(1280, 720)), Color("#0a1028", tint_strength * 0.35), true)
		draw_string(ThemeDB.fallback_font, Vector2(0, 120), "拼刀", HORIZONTAL_ALIGNMENT_CENTER, 1280, 42, Color("#fff8e8", tint_strength))
