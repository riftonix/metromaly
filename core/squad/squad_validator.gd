class_name SquadValidator
extends RefCounted


static func validate(squads: Variant, stations: Dictionary) -> Array[String]:
	var errors: Array[String] = []
	if squads is not Dictionary:
		errors.append("Squads must be a dictionary keyed by squad ID")
		return errors

	for squad_id: Variant in squads:
		if squad_id is not String or squad_id.is_empty():
			errors.append("Squad ID '%s' must be a non-empty string" % squad_id)
			continue

		var squad: Variant = squads[squad_id]
		if squad is not Dictionary:
			errors.append("Squad '%s' must be a dictionary" % squad_id)
			continue

		var expected_keys := ["action_points", "station_id"]
		var actual_keys: Array = squad.keys()
		actual_keys.sort()
		if actual_keys != expected_keys:
			errors.append("Squad '%s' must contain only station_id and action_points" % squad_id)

		var station_id: Variant = squad.get("station_id")
		if station_id is not String or not stations.has(station_id):
			errors.append("Squad '%s' references unknown station '%s'" % [squad_id, station_id])

		var action_points: Variant = squad.get("action_points")
		if action_points is not int or action_points not in [0, 1]:
			errors.append("Squad '%s' has invalid action points '%s'" % [squad_id, action_points])

	return errors
