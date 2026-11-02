extends Control

const ARENA := Rect2(70.0, 118.0, 1140.0, 530.0)
const CELL_SIZE := 28.0
const GRID_COLS := 40
const GRID_ROWS := 18

var map_option: OptionButton
var status_label: Label
var portal_list: ItemList
var label_input: LineEdit
var pending_link_id := ""
var map_index := 0
var teleports: Array[Dictionary] = []
var wheat_mask: Array[bool] = []
var wall_mask: Array[bool] = []
var water_mask: Array[bool] = []
var preview_rect := Rect2()
var preview_host: Control


func _ready() -> void:
	_build_ui()
	_load_map(0)


func _build_ui() -> void:
	var backdrop := ColorRect.new()
	backdrop.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	backdrop.color = Color("#1f2d28")
	add_child(backdrop)

	var top := HBoxContainer.new()
	top.set_anchors_and_offsets_preset(Control.PRESET_TOP_WIDE)
	top.offset_left = 16
	top.offset_top = 12
	top.offset_right = -16
	top.offset_bottom = 56
	add_child(top)

	var back_button := Button.new()
	back_button.text = "返回大厅"
	back_button.pressed.connect(_return_to_lobby)
	top.add_child(back_button)

	var title := Label.new()
	title.text = "地图编辑器"
	title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	top.add_child(title)

	map_option = OptionButton.new()
	for index in range(MapConfig.MAP_COUNT):
		map_option.add_item(MapConfig.MAP_NAMES[index], index)
	map_option.item_selected.connect(_on_map_selected)
	top.add_child(map_option)

	var save_button := Button.new()
	save_button.text = "保存地图"
	save_button.pressed.connect(_save_map)
	top.add_child(save_button)

	var body := HBoxContainer.new()
	body.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	body.offset_left = 16
	body.offset_top = 64
	body.offset_right = -16
	body.offset_bottom = -16
	body.add_theme_constant_override("separation", 12)
	add_child(body)

	preview_host = Control.new()
	preview_host.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	preview_host.size_flags_vertical = Control.SIZE_EXPAND_FILL
	preview_host.mouse_filter = Control.MOUSE_FILTER_STOP
	preview_host.gui_input.connect(_on_preview_input)
	preview_host.draw.connect(_draw_preview)
	body.add_child(preview_host)

	var side := PanelContainer.new()
	side.custom_minimum_size = Vector2(300, 0)
	body.add_child(side)

	var side_root := VBoxContainer.new()
	side_root.add_theme_constant_override("separation", 8)
	side.add_child(side_root)

	status_label = Label.new()
	status_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	side_root.add_child(status_label)

	var add_row := HBoxContainer.new()
	side_root.add_child(add_row)
	label_input = LineEdit.new()
	label_input.placeholder_text = "传送点名称"
	label_input.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	add_row.add_child(label_input)
	var add_button := Button.new()
	add_button.text = "放置A点"
	add_button.pressed.connect(_begin_place_portal)
	add_row.add_child(add_button)

	var link_button := Button.new()
	link_button.text = "为选中项设目标B点"
	link_button.pressed.connect(_begin_link_selected)
	side_root.add_child(link_button)

	var remove_button := Button.new()
	remove_button.text = "删除选中传送点"
	remove_button.pressed.connect(_remove_selected_portal)
	side_root.add_child(remove_button)

	portal_list = ItemList.new()
	portal_list.custom_minimum_size = Vector2(280, 360)
	side_root.add_child(portal_list)

	var hint := Label.new()
	hint.text = "先放 A 点，再点地图放 B 点并自动互联。不同地图可配置不同传送点。"
	hint.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	hint.modulate = Color("#c7d5cf")
	side_root.add_child(hint)


func _notification(what: int) -> void:
	if what == NOTIFICATION_RESIZED:
		_update_preview_rect()


func _update_preview_rect() -> void:
	if preview_host == null:
		return
	var available := preview_host.get_rect().size
	var scale := minf(available.x / ARENA.size.x, available.y / ARENA.size.y) * 0.96
	var size := ARENA.size * scale
	preview_rect = Rect2(
		(preview_host.size.x - size.x) * 0.5,
		(preview_host.size.y - size.y) * 0.5,
		size.x,
		size.y
	)
	preview_host.queue_redraw()


func _on_map_selected(index: int) -> void:
	_load_map(index)


func _load_map(index: int) -> void:
	map_index = index
	var config := MapConfig.load_map(index)
	teleports.clear()
	for entry in config.get("teleports", []):
		if typeof(entry) == TYPE_DICTIONARY:
			teleports.append(entry.duplicate(true))
	var masks := MapLayoutData.build_masks(index)
	wheat_mask = masks["wheat"]
	wall_mask = masks["wall"]
	water_mask = masks["water"]
	pending_link_id = ""
	_refresh_portal_list()
	_update_preview_rect()
	status_label.text = "正在编辑：%s（%d 个传送点）" % [config.get("name", ""), teleports.size()]


func _refresh_portal_list() -> void:
	portal_list.clear()
	for portal in teleports:
		portal_list.add_item("%s -> %s" % [portal.get("label", portal.get("id", "")), portal.get("link", "")])


func _begin_place_portal() -> void:
	var label := label_input.text.strip_edges()
	if label == "":
		label = "传送点%d" % (teleports.size() + 1)
	var portal_id := "tp_%d_%d" % [map_index, teleports.size() + 1]
	pending_link_id = portal_id
	teleports.append({
		"id": portal_id,
		"x": ARENA.position.x + ARENA.size.x * 0.5,
		"y": ARENA.position.y + ARENA.size.y * 0.5,
		"link": portal_id,
		"label": label,
	})
	_refresh_portal_list()
	status_label.text = "已创建 A 点「%s」，请在地图上点击放置 B 点。" % label


func _begin_link_selected() -> void:
	var selected := portal_list.get_selected_items()
	if selected.is_empty():
		status_label.text = "请先在列表中选中一个传送点。"
		return
	var portal := teleports[selected[0]]
	pending_link_id = str(portal.get("id", ""))
	status_label.text = "为「%s」选择链接位置：点击地图放置对应传送点。" % portal.get("label", "")


func _remove_selected_portal() -> void:
	var selected := portal_list.get_selected_items()
	if selected.is_empty():
		return
	var portal := teleports[selected[0]]
	var portal_id: String = portal.get("id", "")
	var filtered: Array[Dictionary] = []
	for entry in teleports:
		if entry.get("id", "") == portal_id:
			continue
		if entry.get("link", "") == portal_id:
			continue
		filtered.append(entry)
	teleports = filtered
	pending_link_id = ""
	_refresh_portal_list()
	status_label.text = "已删除传送点。"


func _on_preview_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		var arena_pos := _arena_from_local(event.position)
		if pending_link_id == "":
			status_label.text = "请先点击「放置A点」或选中列表项设置链接。"
			return
		if _place_or_move_pending(arena_pos):
			_refresh_portal_list()
			preview_host.queue_redraw()


func _place_or_move_pending(arena_pos: Vector2) -> bool:
	for portal in teleports:
		if portal.get("id", "") == pending_link_id:
			portal["x"] = arena_pos.x
			portal["y"] = arena_pos.y
			status_label.text = "已更新 A 点位置。现在点击另一处创建互联 B 点。"
			pending_link_id = ""
			return true
	for portal in teleports:
		if portal.get("link", "") == pending_link_id and portal.get("id", "") != pending_link_id:
			portal["x"] = arena_pos.x
			portal["y"] = arena_pos.y
			status_label.text = "已更新互联传送点位置。"
			pending_link_id = ""
			return true
	var source := _find_portal(pending_link_id)
	if source.is_empty():
		return false
	var target_id := "%s_b" % pending_link_id
	teleports.append({
		"id": target_id,
		"x": arena_pos.x,
		"y": arena_pos.y,
		"link": pending_link_id,
		"label": "%s出口" % source.get("label", "传送"),
	})
	source["link"] = target_id
	status_label.text = "已创建互联传送点：%s <-> %s" % [source.get("label", ""), teleports.back().get("label", "")]
	pending_link_id = ""
	return true


func _find_portal(portal_id: String) -> Dictionary:
	for portal in teleports:
		if portal.get("id", "") == portal_id:
			return portal
	return {}


func _arena_from_local(local_pos: Vector2) -> Vector2:
	var normalized := Vector2(
		(local_pos.x - preview_rect.position.x) / preview_rect.size.x,
		(local_pos.y - preview_rect.position.y) / preview_rect.size.y
	)
	return ARENA.position + Vector2(normalized.x * ARENA.size.x, normalized.y * ARENA.size.y)


func _arena_to_local(arena_pos: Vector2) -> Vector2:
	var normalized := Vector2(
		(arena_pos.x - ARENA.position.x) / ARENA.size.x,
		(arena_pos.y - ARENA.position.y) / ARENA.size.y
	)
	return preview_rect.position + Vector2(normalized.x * preview_rect.size.x, normalized.y * preview_rect.size.y)


func _draw_preview() -> void:
	if preview_host == null:
		return
	preview_host.draw_rect(preview_host.get_rect(), Color("#142019"), true)
	preview_host.draw_rect(preview_rect, Color("#68c779"), true)
	for y in range(GRID_ROWS):
		for x in range(GRID_COLS):
			var index := MapLayoutData.cell_index(Vector2i(x, y))
			var center := ARENA.position + Vector2(float(x) + 0.5, float(y) + 0.5) * CELL_SIZE
			var local_center := _arena_to_local(center)
			var tile_size := Vector2(CELL_SIZE, CELL_SIZE) * (preview_rect.size / ARENA.size)
			if water_mask[index]:
				preview_host.draw_rect(Rect2(local_center - tile_size * 0.5, tile_size), Color("#3d8fbe"), true)
			elif wall_mask[index]:
				preview_host.draw_rect(Rect2(local_center - tile_size * 0.5, tile_size), Color("#4a674f"), true)
			elif wheat_mask[index]:
				preview_host.draw_rect(Rect2(local_center - tile_size * 0.5, tile_size), Color("#7bd486"), true)
	preview_host.draw_rect(preview_rect, Color("#173a31"), false, 2.0)
	for portal in teleports:
		var at := _arena_to_local(Vector2(portal.get("x", 0.0), portal.get("y", 0.0)))
		preview_host.draw_circle(at, 12.0, Color("#b57aff55"))
		preview_host.draw_arc(at, 14.0, 0.0, TAU, 24, Color("#d9b6ff"), 2.0)
		preview_host.draw_string(ThemeDB.fallback_font, at + Vector2(-18, -16), str(portal.get("label", "")), HORIZONTAL_ALIGNMENT_CENTER, 80, 12, Color.WHITE)
		var linked := _find_portal(str(portal.get("link", "")))
		if not linked.is_empty():
			var target := _arena_to_local(Vector2(linked.get("x", 0.0), linked.get("y", 0.0)))
			preview_host.draw_line(at, target, Color("#d9b6ff66"), 2.0)


func _save_map() -> void:
	var payload := {
		"index": map_index,
		"name": MapConfig.MAP_NAMES[map_index],
		"teleports": teleports,
	}
	var error := MapConfig.save_map(map_index, payload)
	if error != OK:
		status_label.text = "保存失败：%s" % error_string(error)
	else:
		status_label.text = "已保存 %s" % MapConfig.map_path(map_index)


func _return_to_lobby() -> void:
	get_tree().change_scene_to_file("res://scenes/Lobby.tscn")
