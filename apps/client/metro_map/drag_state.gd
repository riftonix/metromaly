class_name DragState
extends RefCounted


# Shared pointer-drag state so that clickable Area2D entities (squad marker,
# station target) can suppress release-activation after a camera drag.
#
# `map_world` is assigned by metro_map.gd in _ready(). It must implement
# `is_left_button_dragging() -> bool`.
static var map_world: Node = null


static func was_dragging() -> bool:
	if map_world == null:
		return false
	return map_world.is_left_button_dragging()
