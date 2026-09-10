class_name EndTurnButton
extends Control


signal pressed

const LIGHT_COLOR := Color("#f3eee1")
const LIGHT_DISABLED_COLOR := Color("#8a8a8a")
const FOCUS_COLOR := Color("#f0d060")
const DARK_COLOR := Color("#1c1712")
const HOVER_COLOR := Color("#34281d")
const PRESSED_COLOR := Color("#100d0a")
const DISABLED_COLOR := Color("#2a2a2a")
const BRONZE_COLOR := Color("#9b6838")
const BRONZE_DISABLED_COLOR := Color("#5a5a5a")

var hovered := false
var held := false
var enabled := true:
	set(value):
		enabled = value
		if not enabled:
			held = false
			hovered = false
		queue_redraw()


func _ready() -> void:
	mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)
	gui_input.connect(_on_gui_input)
	focus_entered.connect(queue_redraw)
	focus_exited.connect(queue_redraw)
	queue_redraw()


func _draw() -> void:
	var center := size * 0.5
	var radius := minf(size.x, size.y) * 0.5 - 3.0
	var focused := has_focus()

	var background: Color
	if not enabled:
		background = DISABLED_COLOR
	elif held:
		background = PRESSED_COLOR
	elif hovered:
		background = HOVER_COLOR
	else:
		background = DARK_COLOR

	var rim := BRONZE_COLOR if enabled else BRONZE_DISABLED_COLOR
	var icon_tint := LIGHT_COLOR if enabled else LIGHT_DISABLED_COLOR

	draw_circle(center, radius, rim)
	draw_circle(center, radius - 3.0, background)

	# Focus indicator: distinct concentric ring, separate from hover styling.
	if focused and enabled:
		draw_arc(center, radius + 1.0, 0.0, TAU, 48, FOCUS_COLOR, 2.0)

	_draw_circular_arrow(center, radius, icon_tint)


func _draw_circular_arrow(center: Vector2, radius: float, color: Color) -> void:
	var arrow_radius := radius * 0.55
	var start_angle := deg_to_rad(-55.0)
	var end_angle := deg_to_rad(245.0)
	draw_arc(center, arrow_radius, start_angle, end_angle, 36, color, 3.5, true)

	var tip := center + Vector2.from_angle(start_angle) * arrow_radius
	var tangent := Vector2.from_angle(start_angle + PI * 0.5)
	var radial := Vector2.from_angle(start_angle)
	var arrow_head := PackedVector2Array([
		tip - tangent * 5.0,
		tip + tangent * 5.0 + radial * 6.0,
		tip + tangent * 5.0 - radial * 2.0,
	])
	draw_colored_polygon(arrow_head, color)


func _on_gui_input(event: InputEvent) -> void:
	if not enabled:
		accept_event()
		return

	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		held = event.pressed
		queue_redraw()
		if not event.pressed and hovered:
			pressed.emit()
		accept_event()
		return

	# Keyboard/controller activation when focused.
	if has_focus() and (event.is_action_pressed("ui_accept") or event.is_action_pressed("ui_select")):
		pressed.emit()
		accept_event()


func _on_mouse_entered() -> void:
	if enabled:
		hovered = true
		queue_redraw()


func _on_mouse_exited() -> void:
	hovered = false
	held = false
	queue_redraw()
