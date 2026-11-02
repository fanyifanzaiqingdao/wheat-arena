extends RefCounted
class_name MapLayoutData

const GRID_COLS := 40
const GRID_ROWS := 18


static func cell_index(cell: Vector2i) -> int:
	return cell.y * GRID_COLS + cell.x


static func build_masks(index: int) -> Dictionary:
	var wheat_mask: Array[bool] = []
	var wall_mask: Array[bool] = []
	var water_mask: Array[bool] = []
	wheat_mask.resize(GRID_COLS * GRID_ROWS)
	wall_mask.resize(GRID_COLS * GRID_ROWS)
	water_mask.resize(GRID_COLS * GRID_ROWS)
	wheat_mask.fill(false)
	wall_mask.fill(false)
	water_mask.fill(false)
	_build_layout(index, wheat_mask, wall_mask, water_mask)
	_apply_edge_noise(wheat_mask)
	return {
		"wheat": wheat_mask,
		"wall": wall_mask,
		"water": water_mask,
	}


static func _build_layout(index: int, wheat_mask: Array[bool], wall_mask: Array[bool], water_mask: Array[bool]) -> void:
	match index:
		0:
			_build_twin_fields(wheat_mask)
		1:
			_build_jungle(wheat_mask)
		2:
			_build_kitchen(wheat_mask, wall_mask)
		3:
			_build_temple(wheat_mask, wall_mask)
		4:
			_build_bridge(wheat_mask, water_mask)
		5:
			_build_rolling_lanes(wheat_mask, wall_mask)


static func _fill_wheat_rect(rect: Rect2i, wheat_mask: Array[bool]) -> void:
	for y in range(rect.position.y, rect.position.y + rect.size.y):
		for x in range(rect.position.x, rect.position.x + rect.size.x):
			if x < 0 or x >= GRID_COLS or y < 0 or y >= GRID_ROWS:
				continue
			wheat_mask[cell_index(Vector2i(x, y))] = true


static func _fill_wall_rect(rect: Rect2i, wheat_mask: Array[bool], wall_mask: Array[bool]) -> void:
	for y in range(rect.position.y, rect.position.y + rect.size.y):
		for x in range(rect.position.x, rect.position.x + rect.size.x):
			if x < 0 or x >= GRID_COLS or y < 0 or y >= GRID_ROWS:
				continue
			wall_mask[cell_index(Vector2i(x, y))] = true
			wheat_mask[cell_index(Vector2i(x, y))] = false


static func _fill_water_rect(rect: Rect2i, wheat_mask: Array[bool], water_mask: Array[bool]) -> void:
	for y in range(rect.position.y, rect.position.y + rect.size.y):
		for x in range(rect.position.x, rect.position.x + rect.size.x):
			if x < 0 or x >= GRID_COLS or y < 0 or y >= GRID_ROWS:
				continue
			water_mask[cell_index(Vector2i(x, y))] = true
			wheat_mask[cell_index(Vector2i(x, y))] = false


static func _build_twin_fields(wheat_mask: Array[bool]) -> void:
	for y in range(GRID_ROWS):
		for x in range(GRID_COLS):
			var in_left_top := x >= 2 and x <= 15 and y >= 1 and y <= 8
			var in_left_bottom := x >= 2 and x <= 15 and y >= 11 and y <= 16
			var in_center := x >= 18 and x <= 25 and y >= 1 and y <= 16
			var in_right_top := x >= 28 and x <= 37 and y >= 2 and y <= 8
			var in_right_bottom := x >= 28 and x <= 37 and y >= 11 and y <= 15
			wheat_mask[cell_index(Vector2i(x, y))] = (
				in_left_top or in_left_bottom or in_center or in_right_top or in_right_bottom
			)


static func _build_jungle(wheat_mask: Array[bool]) -> void:
	_fill_wheat_rect(Rect2i(1, 1, 14, 7), wheat_mask)
	_fill_wheat_rect(Rect2i(25, 1, 14, 7), wheat_mask)
	_fill_wheat_rect(Rect2i(1, 10, 14, 7), wheat_mask)
	_fill_wheat_rect(Rect2i(25, 10, 14, 7), wheat_mask)
	_fill_wheat_rect(Rect2i(17, 2, 6, 4), wheat_mask)
	_fill_wheat_rect(Rect2i(17, 12, 6, 4), wheat_mask)


static func _build_kitchen(wheat_mask: Array[bool], wall_mask: Array[bool]) -> void:
	_fill_wheat_rect(Rect2i(1, 1, 38, 3), wheat_mask)
	_fill_wheat_rect(Rect2i(1, 14, 38, 3), wheat_mask)
	_fill_wheat_rect(Rect2i(1, 4, 8, 10), wheat_mask)
	_fill_wheat_rect(Rect2i(31, 4, 8, 10), wheat_mask)
	_fill_wheat_rect(Rect2i(11, 4, 6, 4), wheat_mask)
	_fill_wheat_rect(Rect2i(23, 4, 6, 4), wheat_mask)
	_fill_wheat_rect(Rect2i(11, 10, 6, 4), wheat_mask)
	_fill_wheat_rect(Rect2i(23, 10, 6, 4), wheat_mask)
	_fill_wall_rect(Rect2i(16, 6, 8, 6), wheat_mask, wall_mask)


static func _build_temple(wheat_mask: Array[bool], wall_mask: Array[bool]) -> void:
	for y in range(GRID_ROWS):
		for x in range(GRID_COLS):
			var edge_dist := mini(mini(x, GRID_COLS - 1 - x), mini(y, GRID_ROWS - 1 - y))
			var in_ring := edge_dist <= 2 or (x >= 2 and x <= 6) or (x >= 33 and x <= 37) or (y >= 1 and y <= 3) or (y >= 14 and y <= 16)
			var in_courtyard := x >= 14 and x <= 25 and y >= 5 and y <= 12
			wheat_mask[cell_index(Vector2i(x, y))] = in_ring and not in_courtyard
	for pillar in [Vector2i(14, 5), Vector2i(25, 5), Vector2i(14, 12), Vector2i(25, 12)]:
		wall_mask[cell_index(pillar)] = true
		wheat_mask[cell_index(pillar)] = false


static func _build_bridge(wheat_mask: Array[bool], water_mask: Array[bool]) -> void:
	_fill_wheat_rect(Rect2i(1, 1, 12, 16), wheat_mask)
	_fill_wheat_rect(Rect2i(27, 1, 12, 16), wheat_mask)
	_fill_wheat_rect(Rect2i(13, 7, 14, 4), wheat_mask)
	_fill_water_rect(Rect2i(13, 1, 14, 6), wheat_mask, water_mask)
	_fill_water_rect(Rect2i(13, 11, 14, 6), wheat_mask, water_mask)


static func _build_rolling_lanes(wheat_mask: Array[bool], wall_mask: Array[bool]) -> void:
	for y in range(GRID_ROWS):
		for x in range(GRID_COLS):
			var lane := y >= 1 and y <= 16 and (y % 3 != 1)
			wheat_mask[cell_index(Vector2i(x, y))] = lane
	for y in range(2, 16):
		if y % 4 != 0:
			wall_mask[cell_index(Vector2i(13, y))] = true
			wall_mask[cell_index(Vector2i(26, y))] = true
			wheat_mask[cell_index(Vector2i(13, y))] = false
			wheat_mask[cell_index(Vector2i(26, y))] = false


static func _apply_edge_noise(wheat_mask: Array[bool]) -> void:
	for y in range(GRID_ROWS):
		for x in range(GRID_COLS):
			if not wheat_mask[cell_index(Vector2i(x, y))]:
				continue
			var edge_noise: float = absf(sin(float(x * 19 + y * 31)))
			if edge_noise > 0.93 and (x % 13 == 0 or y % 7 == 0):
				wheat_mask[cell_index(Vector2i(x, y))] = false
