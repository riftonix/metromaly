class_name EndTurnButton
extends Control


signal pressed

const DARK_COLOR := Color("#1c1712")
const HOVER_COLOR := Color("#34281d")
const PRESSED_COLOR := Color("#100d0a")
const BRONZE_COLOR := Color("#9b6838")
const LIGHT_COLOR := Color("#f3eee1")

var hovered := false
var held := false


func _ready() -> void:
	mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)
	gui_input.connect(_on_gui_input)
	queue_redraw()


func _draw() -> void:
	var center := size * 0.5
	var radius := minf(size.x, size.y) * 0.5 - 3.0
	var background := PRESSED_COLOR if held else HOVER_COLOR if hovered else DARK_COLOR
	draw_circle(center, radius, BRONZE_COLOR)
	draw_circle(center, radius - 3.0, background)
	draw_arc(center, radius - 10.0, deg_to_rad(-55.0), deg_to_rad(235.0), 40, LIGHT_COLOR, 4.0, true)

	var arrow_tip := center + Vector2(-radius + 7.0, -2.0)
	var arrow_points := PackedVector2Array([
		arrow_tip,
		arrow_tip + Vector2(9.0, -7.0),
		arrow_tip + Vector2(8.0, 6.0),
	])
	draw_colored_polygon(arrow_points, LIGHT_COLOR)

	var play_radius := radius * 0.32
	var play_points := PackedVector2Array([
		center + Vector2(-play_radius * 0.55, -play_radius),
		center + Vector2(play_radius, 0.0),
		center + Vector2(-play_radius * 0.55, play_radius),
	])
	draw_colored_polygon(play_points, LIGHT_COLOR)


func _on_gui_input(event: InputEvent) -> void:
	if event is not InputEventMouseButton or event.button_index != MOUSE_BUTTON_LEFT:
		return
	held = event.pressed
	queue_redraw()
	if not event.pressed and hovered:
		pressed.emit()
	accept_event()


func _on_mouse_entered() -> void:
	hovered = true
	queue_redraw()


func _on_mouse_exited() -> void:
	hovered = false
	held = false
	queue_redraw()
