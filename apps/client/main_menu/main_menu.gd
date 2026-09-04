extends Control

@onready var start_button: Button = %StartButton
@onready var exit_button: Button = %ExitButton


func _ready() -> void:
	start_button.pressed.connect(_on_start_pressed)
	exit_button.pressed.connect(_on_exit_pressed)
	start_button.grab_focus()


func _on_start_pressed() -> void:
	const METRO_MAP_SCENE := "res://apps/client/metro_map/metro_map.tscn"
	var error := get_tree().change_scene_to_file(METRO_MAP_SCENE)
	if error != OK:
		push_error("Failed to open metro map: %s" % error_string(error))


func _on_exit_pressed() -> void:
	get_tree().quit()
