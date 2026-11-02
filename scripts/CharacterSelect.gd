extends Control

const THUMB_SIZE := Vector2(88, 104)

var characters: Array[Dictionary] = []
var selected_index := 0
var status_label: Label
var preview_name: Label
var preview_portrait: TextureRect
var confirm_button: Button
var character_strip: HBoxContainer
var character_scroll: ScrollContainer
var confirmed := false
var stick_nav_lock := false


func _ready() -> void:
	characters = CharacterCatalog.characters.duplicate()
	if characters.is_empty():
		CharacterCatalog.reload()
		characters = CharacterCatalog.characters.duplicate()
	_restore_selection()
	_build_ui()
	_select_index(selected_index)


func _restore_selection() -> void:
	if GameSession.my_character_id == "":
		return
	for index in range(characters.size()):
		if characters[index].get("id", "") == GameSession.my_character_id:
			selected_index = index
			return


func _build_ui() -> void:
	var backdrop := ColorRect.new()
	backdrop.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	backdrop.color = Color("#24362f")
	add_child(backdrop)

	var root := MarginContainer.new()
	root.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	root.add_theme_constant_override("margin_left", 28)
	root.add_theme_constant_override("margin_top", 20)
	root.add_theme_constant_override("margin_right", 28)
	root.add_theme_constant_override("margin_bottom", 20)
	add_child(root)

	var layout := VBoxContainer.new()
	layout.add_theme_constant_override("separation", 14)
	root.add_child(layout)

	var title := Label.new()
	title.text = "选择角色"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 34)
	layout.add_child(title)

	status_label = Label.new()
	status_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	layout.add_child(status_label)

	var preview_panel := PanelContainer.new()
	preview_panel.size_flags_vertical = Control.SIZE_EXPAND_FILL
	layout.add_child(preview_panel)

	var preview_center := CenterContainer.new()
	preview_center.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	preview_panel.add_child(preview_center)

	var preview_root := VBoxContainer.new()
	preview_root.add_theme_constant_override("separation", 16)
	preview_center.add_child(preview_root)

	preview_portrait = TextureRect.new()
	preview_portrait.custom_minimum_size = Vector2(280, 280)
	preview_portrait.expand_mode = TextureRect.EXPAND_FIT_WIDTH_PROPORTIONAL
	preview_portrait.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	preview_root.add_child(preview_portrait)

	preview_name = Label.new()
	preview_name.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	preview_name.add_theme_font_size_override("font_size", 36)
	preview_root.add_child(preview_name)

	var hint := Label.new()
	hint.text = "← → 或 A / D 切换角色，方向键左右 / 手柄十字键亦可"
	hint.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	hint.modulate = Color("#c7d5cf")
	preview_root.add_child(hint)

	var selector_row := HBoxContainer.new()
	selector_row.alignment = BoxContainer.ALIGNMENT_CENTER
	selector_row.add_theme_constant_override("separation", 12)
	layout.add_child(selector_row)

	var left_button := Button.new()
	left_button.text = "◀"
	left_button.custom_minimum_size = Vector2(52, THUMB_SIZE.y)
	left_button.pressed.connect(_shift_selection.bind(-1))
	selector_row.add_child(left_button)

	character_scroll = ScrollContainer.new()
	character_scroll.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	character_scroll.custom_minimum_size = Vector2(0, THUMB_SIZE.y + 8)
	character_scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_AUTO
	character_scroll.vertical_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	selector_row.add_child(character_scroll)

	character_strip = HBoxContainer.new()
	character_strip.add_theme_constant_override("separation", 10)
	character_scroll.add_child(character_strip)

	for index in range(characters.size()):
		character_strip.add_child(_make_thumb_card(index))

	var right_button := Button.new()
	right_button.text = "▶"
	right_button.custom_minimum_size = Vector2(52, THUMB_SIZE.y)
	right_button.pressed.connect(_shift_selection.bind(1))
	selector_row.add_child(right_button)

	var button_row := HBoxContainer.new()
	button_row.alignment = BoxContainer.ALIGNMENT_CENTER
	button_row.add_theme_constant_override("separation", 12)
	layout.add_child(button_row)

	var back_button := Button.new()
	back_button.text = "返回大厅"
	back_button.pressed.connect(_return_to_lobby)
	button_row.add_child(back_button)

	confirm_button = Button.new()
	confirm_button.text = "确认出战"
	confirm_button.custom_minimum_size = Vector2(160, 42)
	confirm_button.pressed.connect(_confirm_selection)
	button_row.add_child(confirm_button)

	_refresh_status()


func _make_thumb_card(index: int) -> PanelContainer:
	var character: Dictionary = characters[index]
	var card := PanelContainer.new()
	card.custom_minimum_size = THUMB_SIZE
	card.set_meta("character_index", index)
	card.gui_input.connect(_on_thumb_input.bind(index))

	var content := VBoxContainer.new()
	content.add_theme_constant_override("separation", 4)
	card.add_child(content)

	var portrait := TextureRect.new()
	portrait.custom_minimum_size = Vector2(72, 72)
	portrait.expand_mode = TextureRect.EXPAND_FIT_WIDTH_PROPORTIONAL
	portrait.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	portrait.texture = CharacterCatalog.load_texture(str(character.get("portrait", "")))
	content.add_child(portrait)

	var name_label := Label.new()
	name_label.text = str(character.get("name", ""))
	name_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	name_label.add_theme_font_size_override("font_size", 13)
	content.add_child(name_label)

	return card


func _on_thumb_input(event: InputEvent, index: int) -> void:
	if confirmed:
		return
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		_select_index(index)


func _shift_selection(delta: int) -> void:
	if confirmed or characters.is_empty():
		return
	_select_index((selected_index + delta + characters.size()) % characters.size())


func _select_index(index: int) -> void:
	if index < 0 or index >= characters.size():
		return
	selected_index = index
	var character: Dictionary = characters[index]
	preview_name.text = str(character.get("name", ""))
	preview_portrait.texture = CharacterCatalog.load_texture(str(character.get("portrait", "")))
	_refresh_thumb_styles()
	_scroll_to_selected()
	_refresh_status()


func _refresh_thumb_styles() -> void:
	if character_strip == null:
		return
	for child in character_strip.get_children():
		if not child is PanelContainer:
			continue
		var index: int = child.get_meta("character_index")
		var style := StyleBoxFlat.new()
		style.set_corner_radius_all(6)
		if index == selected_index:
			style.bg_color = Color("#4d6b57")
			style.border_color = Color("#fff3b0")
			style.set_border_width_all(2)
		else:
			style.bg_color = Color("#31483f")
		child.add_theme_stylebox_override("panel", style)


func _scroll_to_selected() -> void:
	if character_scroll == null or character_strip == null:
		return
	if selected_index < 0 or selected_index >= character_strip.get_child_count():
		return
	var card := character_strip.get_child(selected_index) as Control
	if card != null:
		character_scroll.ensure_control_visible(card)


func _refresh_status() -> void:
	if GameSession.pending_match_entry == GameSession.MatchEntry.ONLINE:
		var ready_count := GameSession.connected_character_count()
		var total := GameSession.connected_player_count()
		status_label.text = "联机选角：%d / %d 人已确认" % [ready_count, total]
	else:
		status_label.text = "单机练习：选择你的出战角色"
	if confirmed:
		confirm_button.disabled = true
		confirm_button.text = "已确认"


func _confirm_selection() -> void:
	if characters.is_empty() or confirmed:
		return
	var character: Dictionary = characters[selected_index]
	var character_id: String = character.get("id", "")
	if character_id == "":
		return
	GameSession.set_local_character(character_id)
	confirmed = true
	if GameSession.pending_match_entry == GameSession.MatchEntry.ONLINE:
		if GameSession.is_host():
			GameSession._broadcast_lobby()
		else:
			GameSession.submit_character_choice.rpc_id(1, character_id)
		_refresh_status()
		return
	GameSession.launch_match()


func _process(_delta: float) -> void:
	if not confirmed:
		_poll_stick_navigation()
	if not confirmed or GameSession.pending_match_entry != GameSession.MatchEntry.ONLINE:
		return
	_refresh_status()
	if GameSession.is_host() and GameSession.all_characters_selected():
		GameSession.launch_match.rpc()


func _poll_stick_navigation() -> void:
	var direction := 0
	for device in Input.get_connected_joypads():
		var left_x := Input.get_joy_axis(device, JOY_AXIS_LEFT_X)
		var right_x := Input.get_joy_axis(device, JOY_AXIS_RIGHT_X)
		if left_x > 0.6 or right_x > 0.6:
			direction = 1
			break
		if left_x < -0.6 or right_x < -0.6:
			direction = -1
			break
	if direction == 0:
		stick_nav_lock = false
		return
	if stick_nav_lock:
		return
	stick_nav_lock = true
	_shift_selection(direction)


func _return_to_lobby() -> void:
	if GameSession.online:
		GameSession.disconnect_game()
	get_tree().change_scene_to_file("res://scenes/Lobby.tscn")


func _is_nav_left(event: InputEvent) -> bool:
	if event is InputEventKey and event.pressed and not event.echo:
		return event.keycode in [KEY_LEFT, KEY_A]
	if event is InputEventJoypadButton and event.pressed:
		return event.button_index in [JOY_BUTTON_DPAD_LEFT, JOY_BUTTON_LEFT_SHOULDER]
	return false


func _is_nav_right(event: InputEvent) -> bool:
	if event is InputEventKey and event.pressed and not event.echo:
		return event.keycode in [KEY_RIGHT, KEY_D]
	if event is InputEventJoypadButton and event.pressed:
		return event.button_index in [JOY_BUTTON_DPAD_RIGHT, JOY_BUTTON_RIGHT_SHOULDER]
	return false


func _input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo and event.keycode == KEY_F11:
		GameSession.toggle_fullscreen()
		get_viewport().set_input_as_handled()
		return
	if confirmed:
		return
	if _is_nav_left(event):
		_shift_selection(-1)
		get_viewport().set_input_as_handled()
	elif _is_nav_right(event):
		_shift_selection(1)
		get_viewport().set_input_as_handled()
	elif event is InputEventKey and event.pressed and not event.echo and event.keycode == KEY_ENTER:
		_confirm_selection()
		get_viewport().set_input_as_handled()
