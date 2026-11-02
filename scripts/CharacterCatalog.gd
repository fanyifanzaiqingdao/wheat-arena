extends Node

const MANIFEST_PATH := "res://assets/characters/manifest.json"

var characters: Array[Dictionary] = []
var texture_cache: Dictionary = {}
var sheet_textures: Dictionary = {}
var hit_sheet_textures: Dictionary = {}


func _ready() -> void:
	reload()


func reload() -> void:
	characters.clear()
	texture_cache.clear()
	sheet_textures.clear()
	hit_sheet_textures.clear()
	if not FileAccess.file_exists(MANIFEST_PATH):
		return
	var parsed = JSON.parse_string(FileAccess.get_file_as_string(MANIFEST_PATH))
	if typeof(parsed) != TYPE_DICTIONARY:
		return
	for entry in parsed.get("characters", []):
		if typeof(entry) == TYPE_DICTIONARY:
			var character: Dictionary = entry
			var character_id: String = character.get("id", "")
			var sheet := load_texture(str(character.get("sheet", "")))
			if character_id == "" or sheet == null:
				continue
			characters.append(character)
			sheet_textures[character_id] = sheet
			var hit_sheet := load_texture(str(character.get("hit_sheet", "")))
			if hit_sheet != null:
				hit_sheet_textures[character_id] = hit_sheet


func get_character(character_id: String) -> Dictionary:
	for entry in characters:
		if entry.get("id", "") == character_id:
			return entry
	return {}


func get_character_name(character_id: String) -> String:
	return str(get_character(character_id).get("name", character_id))


func get_by_index(index: int) -> Dictionary:
	if characters.is_empty():
		return {}
	return characters[index % characters.size()]


func has_character(character_id: String) -> bool:
	return not get_character(character_id).is_empty()


func get_sheet_texture(character_id: String) -> Texture2D:
	return sheet_textures.get(character_id, null)


func get_hit_sheet_texture(character_id: String) -> Texture2D:
	return hit_sheet_textures.get(character_id, null)


func get_pose_fps(character_id: String, action: String, fallback: float) -> float:
	var poses = get_character(character_id).get("poses", {})
	if typeof(poses) != TYPE_DICTIONARY:
		return fallback
	var pose = poses.get(action, {})
	if typeof(pose) != TYPE_DICTIONARY:
		return fallback
	return float(pose.get("fps", fallback))


func get_pose_frame_count(character_id: String, action: String, fallback: int) -> int:
	var poses = get_character(character_id).get("poses", {})
	if typeof(poses) != TYPE_DICTIONARY:
		return fallback
	var pose = poses.get(action, {})
	if typeof(pose) != TYPE_DICTIONARY:
		return fallback
	return int(pose.get("frames", fallback))


func load_texture(path: String) -> Texture2D:
	if path == "":
		return null
	if texture_cache.has(path):
		return texture_cache[path]
	var texture := load(path) as Texture2D
	if texture != null:
		texture_cache[path] = texture
		return texture
	var image := Image.new()
	if image.load(path) != OK:
		return null
	texture = ImageTexture.create_from_image(image)
	texture_cache[path] = texture
	return texture
