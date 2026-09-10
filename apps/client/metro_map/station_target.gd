class_name StationTarget
extends Area2D


signal activated(station_id: String)

const DragState = preload("res://apps/client/metro_map/drag_state.gd")

const RADIUS := 12.0
const ROTATION_SPEED := 0.5
const GEAR_TEETH := 8

const STATE_NEUTRAL := "neutral"
const STATE_FREE_DESTINATION := "free_destination"
const STATE_PAID_DESTINATION := "paid_destination"

const BASE_COLOR := Color("#6b5233")
const FREE_COLOR := Color("#2f8f4e")
const PAID_COLOR := Color("#8a5a1e")

var station_id := ""
var presentation_state := STATE_NEUTRAL:
	set(value):
		if presentation_state == value:
			return
		presentation_state = value
		set_process(_is_highlighted())
		queue_redraw()
var _rotation_angle := 0.0


func setup(new_station_id: String, station_position: Vector2) -> void:
	station_id = new_station_id
	name = "StationTarget_%s" % station_id
	position = station_position
	input_pickable = true
	monitoring = false
	monitorable = false

	var collision_shape := CollisionShape2D.new()
	var circle := CircleShape2D.new()
	circle.radius = RADIUS
	collision_shape.shape = circle
	add_child(collision_shape)
	set_process(false)
	queue_redraw()


func _is_highlighted() -> bool:
	return presentation_state == STATE_FREE_DESTINATION or presentation_state == STATE_PAID_DESTINATION


func _process(delta: float) -> void:
	_rotation_angle += delta * ROTATION_SPEED
	queue_redraw()


func _draw() -> void:
	match presentation_state:
		STATE_FREE_DESTINATION:
			_draw_free_destination()
		STATE_PAID_DESTINATION:
			_draw_paid_destination()
		_:
			_draw_neutral()


func _draw_neutral() -> void:
	# Neutral station: thin static ring, no center dot (factions render there).
	draw_arc(Vector2.ZERO, RADIUS * 0.5, 0.0, TAU, 24, BASE_COLOR, 1.5)


func _draw_free_destination() -> void:
	# Free destination: green gear that rotates with the same speed as paid.
	_draw_gear(Vector2.ZERO, RADIUS * 0.9, RADIUS * 0.7, GEAR_TEETH, _rotation_angle, FREE_COLOR)


func _draw_paid_destination() -> void:
	# Paid destination: dashed ring rotating slowly, matching free gear speed.
	_draw_dashed_arc(Vector2.ZERO, RADIUS * 0.8, 12, PAID_COLOR, 2.5, _rotation_angle)


func _draw_gear(center: Vector2, outer_radius: float, inner_radius: float, teeth: int, phase: float, color: Color) -> void:
	# Radial gear outline: alternating outer/inner radius, rotated by phase.
	var points := PackedVector2Array()
	var steps := teeth * 2
	for i: int in range(steps):
		var radius := outer_radius if i % 2 == 0 else inner_radius
		var angle := phase + TAU * float(i) / float(steps)
		points.append(center + Vector2(cos(angle), sin(angle)) * radius)
	points.append(points[0])
	draw_polyline(points, color, 2.0)


func _draw_dashed_arc(center: Vector2, radius: float, dash_count: int, color: Color, width: float, phase: float = 0.0) -> void:
	for i: int in range(dash_count):
		if i % 2 != 0:
			continue
		var start_angle := phase + TAU * float(i) / float(dash_count)
		var end_angle := phase + TAU * float(i + 1) / float(dash_count)
		draw_arc(center, radius, start_angle, end_angle, 4, color, width)


func set_destination_cost(cost: Variant) -> void:
	if cost == null:
		presentation_state = STATE_NEUTRAL
	elif cost == 0:
		presentation_state = STATE_FREE_DESTINATION
	else:
		presentation_state = STATE_PAID_DESTINATION


func _input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		# Activate on release, not press, so a camera drag that started
		# on the target does not trigger a squad move.
		if not event.pressed and not DragState.was_dragging():
			activated.emit(station_id)
			get_viewport().set_input_as_handled()
