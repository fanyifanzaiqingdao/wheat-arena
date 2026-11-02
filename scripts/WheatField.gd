extends RefCounted
class_name WheatField

const ARENA := Rect2(70.0, 118.0, 1140.0, 530.0)
const CELL_SIZE := 28.0
const GRID_COLS := 40
const GRID_ROWS := 18

static func cell_index(cell: Vector2i) -> int:
	return cell.y * GRID_COLS + cell.x


static func cell_center(cell: Vector2i) -> Vector2:
	return ARENA.position + Vector2((cell.x + 0.5) * CELL_SIZE, (cell.y + 0.5) * CELL_SIZE)


static func position_to_cell(position: Vector2) -> Vector2i:
	var local := position - ARENA.position
	return Vector2i(
		clampi(floori(local.x / CELL_SIZE), 0, GRID_COLS - 1),
		clampi(floori(local.y / CELL_SIZE), 0, GRID_ROWS - 1)
	)


static func update_regrowth(regrow_timers: Array[float], territory: Array[int], delta: float) -> Array[int]:
	var regrown: Array[int] = []
	for index in range(regrow_timers.size()):
		if regrow_timers[index] <= 0.0:
			continue
		regrow_timers[index] = maxf(0.0, regrow_timers[index] - delta)
		if regrow_timers[index] <= 0.0:
			territory[index] = -1
			regrown.append(index)
	return regrown
