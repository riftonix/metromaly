class_name SquadMovementController
extends RefCounted


const Graph = preload("res://core/metro_map/metro_graph.gd")

const RESULT_MOVED := "moved"
const REJECTION_UNKNOWN_SQUAD := "unknown_squad"
const REJECTION_UNKNOWN_DESTINATION := "unknown_destination"
const REJECTION_CURRENT_STATION := "current_station"
const REJECTION_NO_CONNECTION := "no_connection"
const REJECTION_DESTINATION_CLOSED := "destination_closed"
const REJECTION_INSUFFICIENT_ACTION_POINTS := "insufficient_action_points"


static func try_move(
	squads: Dictionary,
	closed_for_entry_station_ids: Array[String],
	squad_id: String,
	destination_station_id: String,
	stations: Dictionary,
	connections: Array,
) -> Dictionary:
	if not squads.has(squad_id) or squads[squad_id] is not Dictionary:
		return _rejected(REJECTION_UNKNOWN_SQUAD)
	if not stations.has(destination_station_id):
		return _rejected(REJECTION_UNKNOWN_DESTINATION)

	var squad: Dictionary = squads[squad_id]
	var origin_station_id: Variant = squad.get("station_id")
	if origin_station_id == destination_station_id:
		return _rejected(REJECTION_CURRENT_STATION)

	var connection_cost: Variant = Graph.get_connection_cost(
		origin_station_id,
		destination_station_id,
		connections,
	)
	if connection_cost == null:
		return _rejected(REJECTION_NO_CONNECTION)
	if destination_station_id in closed_for_entry_station_ids:
		return _rejected(REJECTION_DESTINATION_CLOSED)

	var action_points: Variant = squad.get("action_points")
	if action_points is not int or action_points < connection_cost:
		return _rejected(REJECTION_INSUFFICIENT_ACTION_POINTS)

	squad["station_id"] = destination_station_id
	squad["action_points"] = action_points - connection_cost
	return {
		"success": true,
		"reason": RESULT_MOVED,
		"cost": connection_cost,
	}


static func _rejected(reason: String) -> Dictionary:
	return {
		"success": false,
		"reason": reason,
	}


static func list_destinations(
	squads: Dictionary,
	closed_for_entry_station_ids: Array[String],
	squad_id: String,
	stations: Dictionary,
	connections: Array,
) -> Array[Dictionary]:
	var destinations: Array[Dictionary] = []
	if not squads.has(squad_id) or squads[squad_id] is not Dictionary:
		return destinations

	var squad: Dictionary = squads[squad_id]
	var origin_station_id: Variant = squad.get("station_id")
	var action_points: Variant = squad.get("action_points")

	for connection: Variant in connections:
		if connection is not Dictionary:
			continue
		var station_ids: Variant = connection.get("stations")
		if station_ids is not Array or station_ids.size() != 2:
			continue

		var destination_station_id: Variant = null
		if station_ids[0] == origin_station_id:
			destination_station_id = station_ids[1]
		elif station_ids[1] == origin_station_id:
			destination_station_id = station_ids[0]
		else:
			continue

		if not stations.has(destination_station_id):
			continue
		if destination_station_id in closed_for_entry_station_ids:
			continue

		var cost: Variant = connection.get("cost")
		if action_points is not int or action_points < cost:
			continue

		destinations.append({
			"station_id": destination_station_id,
			"cost": cost,
		})

	return destinations
