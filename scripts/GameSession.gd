extends Node

const MAX_PLAYERS := 8
const DEFAULT_PORT := 7777
const MIN_PLAYERS_TO_START := 2
const DEFAULT_TOTAL_ROUNDS := 3

enum MatchMode { TEAM, FFA }
enum MatchEntry { SOLO, ONLINE }

class PlayerSlot:
	var player_id := -1
	var peer_id := 0
	var display_name := ""
	var team := 0
	var ready := false
	var character_id := ""

var online := false
var mode := MatchMode.TEAM
var map_index := 0
var fill_ai := true
var pending_match_entry := MatchEntry.SOLO
var my_character_id := "tudou"
var slots: Array[PlayerSlot] = []
var my_peer_id := 1
var my_player_id := -1
var total_rounds := DEFAULT_TOTAL_ROUNDS
var current_round := 1
var cumulative_team_scores: Array[int] = [0, 0]
var cumulative_player_scores: Array[int] = []
var round_scores_recorded := false


func _ready() -> void:
	multiplayer.peer_connected.connect(_on_peer_connected)
	multiplayer.peer_disconnected.connect(_on_peer_disconnected)
	_reset_slots()
	cumulative_player_scores.resize(MAX_PLAYERS)
	cumulative_player_scores.fill(0)


func _reset_slots() -> void:
	slots.clear()
	for index in range(MAX_PLAYERS):
		var slot := PlayerSlot.new()
		slot.player_id = index
		slots.append(slot)


func host_game(port: int = DEFAULT_PORT) -> Error:
	var peer := ENetMultiplayerPeer.new()
	var error := peer.create_server(port)
	if error != OK:
		return error
	multiplayer.multiplayer_peer = peer
	online = true
	my_peer_id = multiplayer.get_unique_id()
	_reset_slots()
	_assign_peer_to_slot(my_peer_id, "玩家%d" % my_peer_id)
	return OK


func join_game(address: String, port: int = DEFAULT_PORT, player_name: String = "") -> Error:
	var peer := ENetMultiplayerPeer.new()
	var error := peer.create_client(address, port)
	if error != OK:
		return error
	multiplayer.multiplayer_peer = peer
	online = true
	pending_player_name = player_name
	if not multiplayer.connected_to_server.is_connected(_on_client_connected):
		multiplayer.connected_to_server.connect(_on_client_connected)
	return OK


var pending_player_name := ""


func _on_client_connected() -> void:
	my_peer_id = multiplayer.get_unique_id()
	register_player.rpc_id(1, pending_player_name if pending_player_name != "" else "玩家%d" % my_peer_id)


func disconnect_game() -> void:
	if multiplayer.multiplayer_peer != null:
		multiplayer.multiplayer_peer.close()
		multiplayer.multiplayer_peer = null
	online = false
	my_player_id = -1
	_reset_slots()


func reset_series() -> void:
	current_round = 1
	round_scores_recorded = false
	cumulative_team_scores = [0, 0]
	cumulative_player_scores.resize(MAX_PLAYERS)
	cumulative_player_scores.fill(0)


func record_round_scores(round_team_scores: Array[int], round_player_scores: Array[int]) -> void:
	if round_scores_recorded:
		return
	round_scores_recorded = true
	for index in range(mini(cumulative_team_scores.size(), round_team_scores.size())):
		cumulative_team_scores[index] += round_team_scores[index]
	for index in range(mini(cumulative_player_scores.size(), round_player_scores.size())):
		cumulative_player_scores[index] += round_player_scores[index]


func has_next_round() -> bool:
	return current_round < total_rounds


func advance_round() -> void:
	if has_next_round():
		current_round += 1
		round_scores_recorded = false


func series_payload() -> Dictionary:
	return {
		"round": current_round,
		"total_rounds": total_rounds,
		"team_total": cumulative_team_scores,
		"player_total": cumulative_player_scores,
	}


func apply_series_payload(payload: Dictionary) -> void:
	current_round = int(payload.get("round", current_round))
	total_rounds = int(payload.get("total_rounds", total_rounds))
	cumulative_team_scores = payload.get("team_total", cumulative_team_scores)
	cumulative_player_scores = payload.get("player_total", cumulative_player_scores)


func toggle_fullscreen() -> void:
	var mode := DisplayServer.window_get_mode()
	if mode == DisplayServer.WINDOW_MODE_FULLSCREEN or mode == DisplayServer.WINDOW_MODE_EXCLUSIVE_FULLSCREEN:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_MAXIMIZED)
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)


func is_host() -> bool:
	return online and multiplayer.is_server()


func get_slot_for_peer(peer_id: int) -> PlayerSlot:
	for slot in slots:
		if slot.peer_id == peer_id:
			return slot
	return null


func get_slot_for_player(player_id: int) -> PlayerSlot:
	if player_id < 0 or player_id >= slots.size():
		return null
	return slots[player_id]


func connected_player_count() -> int:
	var count := 0
	for slot in slots:
		if slot.peer_id > 0:
			count += 1
	return count


func set_local_name(player_name: String) -> void:
	var slot := get_slot_for_peer(my_peer_id)
	if slot != null:
		slot.display_name = player_name


func set_local_ready(is_ready: bool) -> void:
	var slot := get_slot_for_peer(my_peer_id)
	if slot != null:
		slot.ready = is_ready
	if is_host():
		_broadcast_lobby()


func set_local_character(character_id: String) -> void:
	my_character_id = character_id
	var slot := get_slot_for_peer(my_peer_id)
	if slot != null:
		slot.character_id = character_id


func resolve_character_id(player_id: int) -> String:
	if player_id >= 0:
		if online:
			var slot := get_slot_for_player(player_id)
			if slot != null and slot.character_id != "":
				return slot.character_id
		elif player_id == 0:
			return my_character_id
	if CharacterCatalog.characters.is_empty():
		return ""
	return CharacterCatalog.get_by_index(player_id).get("id", "")


func connected_character_count() -> int:
	var count := 0
	for slot in slots:
		if slot.peer_id > 0 and slot.character_id != "":
			count += 1
	return count


func all_characters_selected() -> bool:
	for slot in slots:
		if slot.peer_id > 0 and slot.character_id == "":
			return false
	return connected_player_count() > 0


func open_character_select(entry: MatchEntry) -> void:
	pending_match_entry = entry
	for slot in slots:
		if slot.peer_id > 0:
			slot.character_id = ""
	get_tree().change_scene_to_file("res://scenes/CharacterSelect.tscn")


func begin_solo_match(selected_map: int = -1, selected_mode: MatchMode = MatchMode.TEAM) -> void:
	disconnect_game()
	online = false
	mode = selected_mode
	reset_series()
	if selected_map >= 0:
		map_index = selected_map
	open_character_select(MatchEntry.SOLO)


func begin_online_match() -> void:
	if not can_start_match():
		return
	_assign_teams_for_mode()
	reset_series()
	_go_character_select.rpc()


func can_start_match() -> bool:
	if not is_host():
		return false
	var ready_count := 0
	for slot in slots:
		if slot.peer_id > 0 and slot.ready:
			ready_count += 1
	return ready_count >= MIN_PLAYERS_TO_START and ready_count == connected_player_count()


func _assign_peer_to_slot(peer_id: int, player_name: String) -> void:
	for slot in slots:
		if slot.peer_id == 0:
			slot.peer_id = peer_id
			slot.display_name = player_name
			slot.ready = false
			if peer_id == my_peer_id:
				my_player_id = slot.player_id
			return


func _remove_peer(peer_id: int) -> void:
	for slot in slots:
		if slot.peer_id == peer_id:
			slot.peer_id = 0
			slot.display_name = ""
			slot.ready = false
			slot.team = 0
			slot.character_id = ""
	if my_player_id >= 0 and slots[my_player_id].peer_id != my_peer_id:
		my_player_id = -1
		for slot in slots:
			if slot.peer_id == my_peer_id:
				my_player_id = slot.player_id
				break


func _assign_teams_for_mode() -> void:
	var team_toggle := 0
	for slot in slots:
		if slot.peer_id <= 0:
			continue
		if mode == MatchMode.FFA:
			slot.team = slot.player_id
		else:
			slot.team = team_toggle % 2
			team_toggle += 1


func _lobby_payload() -> Dictionary:
	var players: Array = []
	for slot in slots:
		if slot.peer_id <= 0:
			continue
		players.append({
			"player_id": slot.player_id,
			"peer_id": slot.peer_id,
			"name": slot.display_name,
			"team": slot.team,
			"ready": slot.ready,
			"character_id": slot.character_id,
		})
	return {
		"mode": mode,
		"map_index": map_index,
		"fill_ai": fill_ai,
		"players": players,
	}


func _apply_lobby_payload(payload: Dictionary) -> void:
	_reset_slots()
	mode = payload.get("mode", MatchMode.TEAM)
	map_index = payload.get("map_index", 0)
	fill_ai = payload.get("fill_ai", true)
	my_player_id = -1
	for entry in payload.get("players", []):
		var player_id: int = entry.get("player_id", -1)
		if player_id < 0 or player_id >= slots.size():
			continue
		var slot := slots[player_id]
		slot.peer_id = entry.get("peer_id", 0)
		slot.display_name = entry.get("name", "")
		slot.team = entry.get("team", 0)
		slot.ready = entry.get("ready", false)
		slot.character_id = entry.get("character_id", "")
		if slot.peer_id == my_peer_id:
			my_player_id = player_id
			if slot.character_id != "":
				my_character_id = slot.character_id


func _broadcast_lobby() -> void:
	if not is_host():
		return
	_sync_lobby.rpc(_lobby_payload())


func _on_peer_connected(peer_id: int) -> void:
	if not is_host():
		return
	_assign_peer_to_slot(peer_id, "玩家%d" % peer_id)
	_broadcast_lobby()


func _on_peer_disconnected(peer_id: int) -> void:
	_remove_peer(peer_id)
	if is_host():
		_broadcast_lobby()


@rpc("authority", "call_local", "reliable")
func _go_character_select() -> void:
	open_character_select(MatchEntry.ONLINE)


@rpc("authority", "call_local", "reliable")
func launch_match() -> void:
	get_tree().change_scene_to_file("res://scenes/WheatArena.tscn")


@rpc("any_peer", "call_remote", "reliable")
func submit_character_choice(character_id: String) -> void:
	if not is_host():
		return
	var peer_id := multiplayer.get_remote_sender_id()
	var slot := get_slot_for_peer(peer_id)
	if slot != null:
		slot.character_id = character_id
	_broadcast_lobby()


@rpc("authority", "call_local", "reliable")
func _start_match() -> void:
	launch_match()


@rpc("authority", "call_remote", "reliable")
func _sync_lobby(payload: Dictionary) -> void:
	_apply_lobby_payload(payload)


@rpc("any_peer", "call_remote", "reliable")
func register_player(player_name: String) -> void:
	if not is_host():
		return
	var peer_id := multiplayer.get_remote_sender_id()
	var slot := get_slot_for_peer(peer_id)
	if slot == null:
		_assign_peer_to_slot(peer_id, player_name)
	else:
		slot.display_name = player_name
	_broadcast_lobby()


@rpc("any_peer", "call_remote", "reliable")
func request_set_ready(is_ready: bool) -> void:
	if not is_host():
		return
	var peer_id := multiplayer.get_remote_sender_id()
	var slot := get_slot_for_peer(peer_id)
	if slot != null:
		slot.ready = is_ready
	_broadcast_lobby()


@rpc("any_peer", "call_remote", "reliable")
func request_lobby_settings(new_mode: int, new_map_index: int, new_fill_ai: bool) -> void:
	if not is_host():
		return
	if multiplayer.get_remote_sender_id() != 1:
		return
	mode = new_mode
	map_index = new_map_index
	fill_ai = new_fill_ai
	_broadcast_lobby()
