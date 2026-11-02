extends RefCounted
class_name ArenaRenderer

static func facing_name(direction: Vector2) -> String:
	if absf(direction.x) > absf(direction.y):
		return "right" if direction.x >= 0.0 else "left"
	return "down" if direction.y >= 0.0 else "up"


static func fighter_sheet_source(
	action: String,
	aim: Vector2,
	frame: int,
	frame_size: int
) -> Rect2:
	var action_index: int = {"idle": 0, "run": 1, "slash": 2}.get(action, 0)
	var direction_index: int = {"down": 0, "up": 1, "right": 2, "left": 3}.get(facing_name(aim), 0)
	return Rect2(
		frame * frame_size,
		(action_index * 4 + direction_index) * frame_size,
		frame_size,
		frame_size
	)


static func fighter_action(is_slashing: bool, velocity: Vector2) -> String:
	if is_slashing:
		return "slash"
	if velocity.length_squared() > 25.0:
		return "run"
	return "idle"
