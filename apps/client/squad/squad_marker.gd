extends Area2D


signal activated(squad_id: String)

const DragState = preload("res://apps/client/metro_map/drag_state.gd")

const RADIUS := 12.0
const MARKER_COLOR := Color("#f5cf48")
const SELECTED_COLOR := Color("#fff5b5")
const OUTLINE_COLOR := Color("#241d15")
const AP_COLOR := Color("#2f6f3e")

var squad_id := ""
var selected := false:
	set(value):
		selected = value
		queue_redraw()
var action_points := 1:
	set(value):
		action_points = clampi(value, 0, 1)
		queue_redraw()


func setup(new_squad_id: String, station_position: Vector2) -> void:
	squad_id = new_squad_id
	name = "SquadMarker_%s" % squad_id
	position = station_position
	z_index = 10
	input_pickable = true
	monitoring = false
	monitorable = false

	var collision_shape := CollisionShape2D.new()
	var circle := CircleShape2D.new()
	circle.radius = RADIUS
	collision_shape.shape = circle
	add_child(collision_shape)
	queue_redraw()


func _badge_points(radius: float) -> PackedVector2Array:
	# Shield-like badge silhouette inside the circular hit target, distinct
	# from the station target dots.
	return PackedVector2Array([
		Vector2(0.0, -radius),
		Vector2(radius * 0.75, -radius * 0.5),
		Vector2(radius * 0.5, radius * 0.6),
		Vector2(-radius * 0.5, radius * 0.6),
		Vector2(-radius * 0.75, -radius * 0.5),
	])


func _draw() -> void:
	var fill := SELECTED_COLOR if selected else MARKER_COLOR
	var badge := _badge_points(RADIUS)
	draw_colored_polygon(badge, fill)
	badge.append(badge[0])
	draw_polyline(badge, OUTLINE_COLOR, 2.0)
	if selected:
		var inner_badge := _badge_points(RADIUS * 0.7)
		inner_badge.append(inner_badge[0])
		draw_polyline(inner_badge, OUTLINE_COLOR, 1.5)

	# Chevron glyph marking a squad, distinct from station target dots.
	draw_polyline(
		PackedVector2Array([
			Vector2(-4.0, 0.5),
			Vector2(0.0, -3.5),
			Vector2(4.0, 0.5),
		]),
		OUTLINE_COLOR,
		2.0,
	)

	# Action-point indicator: filled pip with AP, hollow ring without.
	var pip_position := Vector2(0.0, RADIUS * 0.55)
	if action_points > 0:
		draw_circle(pip_position, 3.0, AP_COLOR)
		draw_arc(pip_position, 3.0, 0.0, TAU, 16, OUTLINE_COLOR, 1.0)
	else:
		draw_arc(pip_position, 3.0, 0.0, TAU, 16, OUTLINE_COLOR, 1.5)


func presentation_state() -> String:
	if action_points > 0:
		return "selected-mobile" if selected else "unselected-mobile"
	return "selected-spent" if selected else "unselected-spent"


func _input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		# Activate on release, not press, so a camera drag that started
		# on the marker does not trigger selection.
		if not event.pressed and not DragState.was_dragging():
			activated.emit(squad_id)
			get_viewport().set_input_as_handled()
