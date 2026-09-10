extends Area2D


signal activated(squad_id: String)

const RADIUS := 12.0
const MARKER_COLOR := Color("#f5cf48")
const SELECTED_COLOR := Color("#fff5b5")
const OUTLINE_COLOR := Color("#241d15")

var squad_id := ""
var selected := false:
	set(value):
		selected = value
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


func _draw() -> void:
	draw_circle(Vector2.ZERO, RADIUS, SELECTED_COLOR if selected else MARKER_COLOR)
	draw_arc(Vector2.ZERO, RADIUS, 0.0, TAU, 32, OUTLINE_COLOR, 2.0)
	draw_circle(Vector2.ZERO, 3.0, OUTLINE_COLOR)


func _input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		activated.emit(squad_id)
		get_viewport().set_input_as_handled()
