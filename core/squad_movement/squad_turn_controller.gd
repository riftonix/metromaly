class_name SquadTurnController
extends RefCounted


const ACTION_POINTS_PER_TURN := 1


static func end_turn(squads: Dictionary) -> void:
	for squad_id: Variant in squads:
		var squad: Variant = squads[squad_id]
		if squad is Dictionary:
			squad["action_points"] = ACTION_POINTS_PER_TURN
