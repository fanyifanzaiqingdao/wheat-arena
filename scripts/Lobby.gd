extends Control

const PORT := GameSession.DEFAULT_PORT

var name_input: LineEdit
var address_input: LineEdit
var status_label: Label
var player_list: ItemList
var mode_option: OptionButton
var map_option: OptionButton
var ai_check: CheckBox
var host_button: Button
var join_button: Button
var ready_button: Button
var start_button: Button
var solo_button: Button
var leave_button: Button


func _ready() -> void:
	_build_ui()
	_refresh_ui()


func _build_ui() -> void:
	var backdrop := ColorRect.new()
	backdrop.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	backdrop.color = Color("#2a3d34")
	add_child(backdrop)

	var center := CenterContainer.new()
	center.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(center)

	var panel := PanelContainer.new()
	panel.custom_minimum_size = Vector2(800, 540)
	center.add_child(panel)
	var root := VBoxContainer.new()
	root.add_theme_constant_override("separation", 10)
	panel.add_child(root)
	var title := Label.new()
	title.text = "麦浪争锋 · 联机大厅"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	root.add_child(title)
	status_label = Label.new()
	status_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	root.add_child(status_label)
	var form := GridContainer.new()
	form.columns = 2
	root.add_child(form)
	_add_label(form, "昵称")
	name_input = LineEdit.new()
	name_input.text = "农夫%d" % (randi() % 900 + 100)
	form.add_child(name_input)
	_add_label(form, "主机地址")
	address_input = LineEdit.new()
	address_input.text = "127.0.0.1"
	form.add_child(address_input)
	_add_label(form, "模式")
	mode_option = OptionButton.new()
	mode_option.add_item("组队赛", GameSession.MatchMode.TEAM)
	mode_option.add_item("自由赛", GameSession.MatchMode.FFA)
	form.add_child(mode_option)
	_add_label(form, "地图")
	map_option = OptionButton.new()
	for index in range(6):
		map_option.add_item(["麦野双圃", "丛林伏击", "烘焙厨房", "庙宇天井", "断桥急流", "擀面长廊"][index], index)
	form.add_child(map_option)
	ai_check = CheckBox.new()
	ai_check.text = "空位用 AI 补齐"
	ai_check.button_pressed = true
	root.add_child(ai_check)
	var buttons := HBoxContainer.new()
	root.add_child(buttons)
	host_button = Button.new()
	host_button.text = "创建房间"
	host_button.pressed.connect(_on_host_pressed)
	buttons.add_child(host_button)
	join_button = Button.new()
	join_button.text = "加入房间"
	join_button.pressed.connect(_on_join_pressed)
	buttons.add_child(join_button)
	solo_button = Button.new()
	solo_button.text = "单机练习"
	solo_button.pressed.connect(_on_solo_pressed)
	buttons.add_child(solo_button)
	leave_button = Button.new()
	leave_button.text = "离开房间"
	leave_button.pressed.connect(_on_leave_pressed)
	buttons.add_child(leave_button)
	player_list = ItemList.new()
	player_list.custom_minimum_size = Vector2(760, 180)
	root.add_child(player_list)
	var action_row := HBoxContainer.new()
	root.add_child(action_row)
	ready_button = Button.new()
	ready_button.text = "准备"
	ready_button.pressed.connect(_on_ready_pressed)
	action_row.add_child(ready_button)
	start_button = Button.new()
	start_button.text = "开始比赛"
	start_button.pressed.connect(_on_start_pressed)
	action_row.add_child(start_button)

	var editor_button := Button.new()
	editor_button.text = "地图编辑器"
	editor_button.pressed.connect(_on_editor_pressed)
	action_row.add_child(editor_button)

	var hint := Label.new()
	hint.text = "F11 切换全屏"
	hint.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	hint.add_theme_font_size_override("font_size", 13)
	hint.modulate = Color("#aeb9c8")
	root.add_child(hint)


func _add_label(parent: GridContainer, text: String) -> void:
	var label := Label.new()
	label.text = text
	parent.add_child(label)


func _process(_delta: float) -> void:
	_refresh_ui()


func _input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo and event.keycode == KEY_F11:
		GameSession.toggle_fullscreen()
		get_viewport().set_input_as_handled()


func _refresh_ui() -> void:
	var online := GameSession.online
	host_button.disabled = online
	join_button.disabled = online
	leave_button.disabled = not online
	ready_button.disabled = not online
	start_button.disabled = not GameSession.can_start_match()
	start_button.visible = GameSession.is_host()
	mode_option.disabled = online and not GameSession.is_host()
	map_option.disabled = online and not GameSession.is_host()
	ai_check.disabled = online and not GameSession.is_host()
	if online:
		status_label.text = "已连接 · 本机 ID %d · 玩家槽 %d" % [
			GameSession.my_peer_id,
			GameSession.my_player_id,
		]
	else:
		status_label.text = "未连接 · 可创建/加入房间，或直接单机练习"
	player_list.clear()
	for slot in GameSession.slots:
		if slot.peer_id <= 0:
			continue
		var ready_text := "已准备" if slot.ready else "未准备"
		var host_mark := " [主机]" if slot.peer_id == 1 else ""
		player_list.add_item("%s%s · 队伍%d · %s" % [slot.display_name, host_mark, slot.team, ready_text])


func _on_host_pressed() -> void:
	var error := GameSession.host_game(PORT)
	if error != OK:
		status_label.text = "创建房间失败：%s" % error_string(error)
		return
	GameSession.set_local_name(name_input.text.strip_edges())
	GameSession.mode = mode_option.selected
	GameSession.map_index = map_option.selected
	GameSession.fill_ai = ai_check.button_pressed
	_refresh_ui()


func _on_join_pressed() -> void:
	var error := GameSession.join_game(address_input.text.strip_edges(), PORT, name_input.text.strip_edges())
	if error != OK:
		status_label.text = "加入失败：%s" % error_string(error)
		return
	_refresh_ui()


func _on_ready_pressed() -> void:
	if GameSession.is_host():
		GameSession.set_local_ready(not _local_ready())
		GameSession._broadcast_lobby()
	else:
		GameSession.request_set_ready.rpc_id(1, not _local_ready())


func _local_ready() -> bool:
	var slot := GameSession.get_slot_for_peer(GameSession.my_peer_id)
	return slot != null and slot.ready


func _on_start_pressed() -> void:
	if not GameSession.is_host():
		return
	GameSession.mode = mode_option.selected
	GameSession.map_index = map_option.selected
	GameSession.fill_ai = ai_check.button_pressed
	GameSession.begin_online_match()


func _on_solo_pressed() -> void:
	GameSession.begin_solo_match(map_option.selected, mode_option.selected)


func _on_editor_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/MapEditor.tscn")


func _on_leave_pressed() -> void:
	GameSession.disconnect_game()
	_refresh_ui()
