extends Node2D


const BACKGROUND_COLOR := Color("#e1b27b")
const TEXT_COLOR := Color.BLACK
const REFERENCE_SIZE := Vector2(1280.0, 1500.0)
const MAP_TEXTURE: Texture2D = preload("res://apps/client/assets/metro_map/metro_map.svg")
const STATION_LABELS := [
	{"title": "VDNH", "position": Vector2(842.0, 260.0)},
	{"title": "Alexeevskaya", "position": Vector2(842.0, 286.0)},
]

@onready var camera: Camera2D = $"../Camera2D"
@export var camera_move_speed := 500.0


func _ready() -> void:
	RenderingServer.set_default_clear_color(BACKGROUND_COLOR)
	get_viewport().size_changed.connect(_on_viewport_size_changed)
	fill_viewport()



@export var zoom_step := 0.1
@export var minimum_zoom_factor := 0.5
@export var maximum_zoom_factor := 3.0
var initial_zoom := 1.0


func fill_viewport() -> void:
	var viewport_size: Vector2 = get_viewport_rect().size
	var map_size: Vector2 = MAP_TEXTURE.get_size()
	var fill_zoom: float = maxf(
		viewport_size.x / map_size.x,
		viewport_size.y / map_size.y,
	)

	camera.position = map_size * 0.5
	camera.zoom = Vector2.ONE * fill_zoom
	initial_zoom = fill_zoom
	clamp_camera_position()


func _on_viewport_size_changed() -> void:
	fill_viewport()



func _process(delta: float) -> void:
	var direction: Vector2 = Input.get_vector(
		"camera_left",
		"camera_right",
		"camera_up",
		"camera_down",
	)
	camera.position += direction * camera_move_speed * delta / camera.zoom.x
	clamp_camera_position()


func clamp_camera_position() -> void:
	var map_size := MAP_TEXTURE.get_size()
	var visible_size := get_viewport_rect().size / camera.zoom
	var half_visible_size := visible_size * 0.5
	var map_center := map_size * 0.5

	if visible_size.x >= map_size.x:
		camera.position.x = map_center.x
	else:
		camera.position.x = clampf(
			camera.position.x,
			half_visible_size.x,
			map_size.x - half_visible_size.x,
		)

	if visible_size.y >= map_size.y:
		camera.position.y = map_center.y
	else:
		camera.position.y = clampf(
			camera.position.y,
			half_visible_size.y,
			map_size.y - half_visible_size.y,
		)


func _draw() -> void:
	var map_size: Vector2 = MAP_TEXTURE.get_size()
	draw_rect(Rect2(Vector2.ZERO, map_size), BACKGROUND_COLOR)
	draw_texture(MAP_TEXTURE, Vector2.ZERO)

	for station_label: Dictionary in STATION_LABELS:
		draw_string(
			ThemeDB.fallback_font,
			station_label["position"],
			station_label["title"],
			HORIZONTAL_ALIGNMENT_LEFT,
			180.0,
			20,
			TEXT_COLOR,
		)


func _unhandled_input(event: InputEvent) -> void:
	if event is not InputEventMouseButton:
		return

	if not event.pressed:
		return

	if event.button_index == MOUSE_BUTTON_WHEEL_UP:
		change_zoom(1.0)
	elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
		change_zoom(-1.0)


func change_zoom(direction: float) -> void:
	var minimum_zoom := initial_zoom * minimum_zoom_factor
	var maximum_zoom := initial_zoom * maximum_zoom_factor
	var change := initial_zoom * zoom_step * direction

	var new_zoom := clampf(
		camera.zoom.x + change,
		minimum_zoom,
		maximum_zoom,
	)

	camera.zoom = Vector2.ONE * new_zoom
	clamp_camera_position()
