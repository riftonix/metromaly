class_name StationTarget
extends Area2D


signal activated(station_id: String)

const RADIUS := 12.0

var station_id := ""


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


func _input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		activated.emit(station_id)
		get_viewport().set_input_as_handled()
