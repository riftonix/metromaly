extends SceneTree


const MapData = preload("res://core/metro_map/metro_map_data.gd")
const MapValidator = preload("res://core/metro_map/metro_map_validator.gd")


func _initialize() -> void:
	var errors: Array[String] = MapValidator.validate(
		MapData.LINES,
		MapData.STATIONS,
		MapData.CONNECTIONS,
	)

	if errors.is_empty():
		print("Metro map validation passed")
		quit(0)
		return

	for error: String in errors:
		printerr(error)
	quit(1)
