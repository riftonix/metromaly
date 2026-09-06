class_name MetroGraph
extends RefCounted


const MapData = preload("res://core/metro_map/metro_map_data.gd")


static func get_connection_cost(
	first_station_id: String,
	second_station_id: String,
	connections: Array = MapData.CONNECTIONS,
) -> Variant:
	for connection: Variant in connections:
		if connection is not Dictionary:
			continue

		var station_ids: Variant = connection.get("stations")
		if station_ids is not Array or station_ids.size() != 2:
			continue

		if (
			station_ids[0] == first_station_id
			and station_ids[1] == second_station_id
		) or (
			station_ids[0] == second_station_id
			and station_ids[1] == first_station_id
		):
			return connection.get("cost")

	return null
