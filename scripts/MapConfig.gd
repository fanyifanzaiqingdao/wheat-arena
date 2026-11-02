extends Node

const MAP_NAMES := [
	"麦野双圃",
	"丛林伏击",
	"烘焙厨房",
	"庙宇天井",
	"断桥急流",
	"擀面长廊",
]
const MAP_COUNT := 6


func map_path(index: int) -> String:
	return "res://assets/maps/map_%d.json" % index


func load_map(index: int) -> Dictionary:
	var path := map_path(index)
	if FileAccess.file_exists(path):
		var parsed = JSON.parse_string(FileAccess.get_file_as_string(path))
		if typeof(parsed) == TYPE_DICTIONARY:
			return _normalize_map(index, parsed)
	return default_map(index)


func default_map(index: int) -> Dictionary:
	var teleports: Array = []
	match index:
		1:
			teleports = [
				{"id": "jungle_west", "x": 210.0, "y": 250.0, "link": "jungle_east", "label": "西林"},
				{"id": "jungle_east", "x": 1070.0, "y": 250.0, "link": "jungle_west", "label": "东林"},
			]
		3:
			teleports = [
				{"id": "temple_left", "x": 250.0, "y": 370.0, "link": "temple_right", "label": "左廊"},
				{"id": "temple_right", "x": 1030.0, "y": 370.0, "link": "temple_left", "label": "右廊"},
			]
		4:
			teleports = [
				{"id": "bridge_left", "x": 200.0, "y": 250.0, "link": "bridge_right", "label": "左岸"},
				{"id": "bridge_right", "x": 1080.0, "y": 450.0, "link": "bridge_left", "label": "右岸"},
			]
	return {
		"index": index,
		"name": MAP_NAMES[index % MAP_COUNT],
		"teleports": teleports,
	}


func save_map(index: int, data: Dictionary) -> Error:
	var payload := _normalize_map(index, data)
	var json := JSON.stringify(payload, "\t")
	var path := map_path(index)
	var file := FileAccess.open(path, FileAccess.WRITE)
	if file == null:
		return FileAccess.get_open_error()
	file.store_string(json + "\n")
	return OK


func _normalize_map(index: int, data: Dictionary) -> Dictionary:
	var teleports: Array = []
	for entry in data.get("teleports", []):
		if typeof(entry) != TYPE_DICTIONARY:
			continue
		var portal_id: String = str(entry.get("id", "")).strip_edges()
		var link_id: String = str(entry.get("link", "")).strip_edges()
		if portal_id == "" or link_id == "":
			continue
		teleports.append({
			"id": portal_id,
			"x": float(entry.get("x", 0.0)),
			"y": float(entry.get("y", 0.0)),
			"link": link_id,
			"label": str(entry.get("label", portal_id)),
		})
	return {
		"index": index,
		"name": str(data.get("name", MAP_NAMES[index % MAP_COUNT])),
		"teleports": teleports,
	}
