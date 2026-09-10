class_name SquadState
extends RefCounted


const INITIAL_SQUAD_ID := "player_squad_1"
const INITIAL_STATION_ID := "park_kultury_koltsevaya"

var squads: Dictionary = {}


func _init(initial_squads: Dictionary = {}) -> void:
	squads = initial_squads.duplicate(true)


static func create_initial() -> RefCounted:
	return new(
		{
			INITIAL_SQUAD_ID: {
				"station_id": INITIAL_STATION_ID,
				"action_points": 1,
			},
		},
	)
