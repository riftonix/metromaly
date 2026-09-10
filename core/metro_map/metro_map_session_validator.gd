class_name MetroMapSessionValidator
extends RefCounted


static func validate(
	closed_for_entry_station_ids: Variant,
	stations: Dictionary,
) -> Array[String]:
	var errors: Array[String] = []
	if closed_for_entry_station_ids is not Array:
		errors.append("Closed-for-entry station IDs must be an array")
		return errors

	var seen_station_ids := {}
	for index: int in closed_for_entry_station_ids.size():
		var station_id: Variant = closed_for_entry_station_ids[index]
		if station_id is not String or not stations.has(station_id):
			errors.append("Closure entry %d references unknown station '%s'" % [index, station_id])
			continue
		if seen_station_ids.has(station_id):
			errors.append("Closure entry %d duplicates station '%s'" % [index, station_id])
		else:
			seen_station_ids[station_id] = true

	return errors
