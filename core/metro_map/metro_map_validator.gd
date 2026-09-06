class_name MetroMapValidator
extends RefCounted


const MapData = preload("res://core/metro_map/metro_map_data.gd")


static func validate(
	lines: Dictionary,
	stations: Dictionary,
	connections: Array,
) -> Array[String]:
	var errors: Array[String] = []
	_validate_lines(lines, errors)
	_validate_stations(lines, stations, errors)
	_validate_connections(lines, stations, connections, errors)
	_validate_circle_line(stations, connections, errors)
	return errors


static func _validate_lines(lines: Dictionary, errors: Array[String]) -> void:
	for line_id: Variant in lines:
		var line: Variant = lines[line_id]
		if line is not Dictionary:
			errors.append("Line '%s' must be a dictionary" % line_id)
			continue

		var expected_keys := ["color", "name", "playable"]
		var actual_keys: Array = line.keys()
		actual_keys.sort()
		if actual_keys != expected_keys:
			errors.append("Line '%s' must contain name, color, and playable" % line_id)

		if line.get("name") is not String or line.get("name").is_empty():
			errors.append("Line '%s' has an invalid name" % line_id)
		if line.get("color") is not Color:
			errors.append("Line '%s' has an invalid color" % line_id)
		if line.get("playable") is not bool:
			errors.append("Line '%s' has an invalid playable flag" % line_id)


static func _validate_stations(
	lines: Dictionary,
	stations: Dictionary,
	errors: Array[String],
) -> void:
	for station_id: Variant in stations:
		var station: Variant = stations[station_id]
		if station is not Dictionary:
			errors.append("Station '%s' must be a dictionary" % station_id)
			continue

		var expected_keys := ["line_id", "name", "position"]
		var actual_keys: Array = station.keys()
		actual_keys.sort()
		if actual_keys != expected_keys:
			errors.append("Station '%s' must contain name, line_id, and position" % station_id)

		if station.get("name") is not String or station.get("name").is_empty():
			errors.append("Station '%s' has an invalid name" % station_id)
		if station.get("position") is not Vector2:
			errors.append("Station '%s' has an invalid position" % station_id)

		var line_id: Variant = station.get("line_id")
		if line_id is not String or not lines.has(line_id):
			errors.append("Station '%s' references unknown line '%s'" % [station_id, line_id])


static func _validate_connections(
	lines: Dictionary,
	stations: Dictionary,
	connections: Array,
	errors: Array[String],
) -> void:
	var seen_pairs := {}

	for index: int in connections.size():
		var connection: Variant = connections[index]
		if connection is not Dictionary:
			errors.append("Connection %d must be a dictionary" % index)
			continue

		var expected_keys := ["cost", "stations"]
		var actual_keys: Array = connection.keys()
		actual_keys.sort()
		if actual_keys != expected_keys:
			errors.append("Connection %d must contain only stations and cost" % index)

		var station_ids: Variant = connection.get("stations")
		if station_ids is not Array or station_ids.size() != 2:
			errors.append("Connection %d must reference exactly two stations" % index)
			continue

		var first_id: Variant = station_ids[0]
		var second_id: Variant = station_ids[1]
		if first_id is not String or second_id is not String:
			errors.append("Connection %d station IDs must be strings" % index)
			continue

		if first_id == second_id:
			errors.append("Connection %d cannot connect station '%s' to itself" % [index, first_id])

		for station_id: String in [first_id, second_id]:
			if not stations.has(station_id):
				errors.append("Connection %d references unknown station '%s'" % [index, station_id])

		var pair_ids := [first_id, second_id]
		pair_ids.sort()
		var pair_key := "%s|%s" % pair_ids
		if seen_pairs.has(pair_key):
			errors.append("Connection %d duplicates station pair '%s'" % [index, pair_key])
		else:
			seen_pairs[pair_key] = true

		var cost: Variant = connection.get("cost")
		if cost is not int or cost not in [0, 1]:
			errors.append("Connection %d has invalid cost '%s'" % [index, cost])
			continue

		if not stations.has(first_id) or not stations.has(second_id):
			continue

		var first_line_id: Variant = stations[first_id].get("line_id")
		var second_line_id: Variant = stations[second_id].get("line_id")
		if cost == 0 and first_line_id == second_line_id:
			errors.append("Transfer '%s' must connect stations on different lines" % pair_key)
		elif cost == 1:
			if first_line_id != MapData.CIRCLE_LINE_ID or second_line_id != MapData.CIRCLE_LINE_ID:
				errors.append("Paid connection '%s' must stay on the Circle Line" % pair_key)
			elif (
				not lines.has(first_line_id)
				or lines[first_line_id] is not Dictionary
				or lines[first_line_id].get("playable") != true
			):
				errors.append("Paid connection '%s' references a non-playable line" % pair_key)


static func _validate_circle_line(
	stations: Dictionary,
	connections: Array,
	errors: Array[String],
) -> void:
	var circle_station_ids: Array[String] = []
	for station_id: Variant in stations:
		var station: Variant = stations[station_id]
		if station is Dictionary and station.get("line_id") == MapData.CIRCLE_LINE_ID:
			circle_station_ids.append(station_id)

	if circle_station_ids.size() != 12:
		errors.append("Circle Line must contain exactly 12 stations, found %d" % circle_station_ids.size())

	var paid_neighbors := {}
	for station_id: String in circle_station_ids:
		paid_neighbors[station_id] = []

	for connection: Variant in connections:
		if connection is not Dictionary or connection.get("cost") != 1:
			continue
		var station_ids: Variant = connection.get("stations")
		if station_ids is not Array or station_ids.size() != 2:
			continue
		var first_id: Variant = station_ids[0]
		var second_id: Variant = station_ids[1]
		if paid_neighbors.has(first_id) and paid_neighbors.has(second_id):
			paid_neighbors[first_id].append(second_id)
			paid_neighbors[second_id].append(first_id)

	for station_id: String in circle_station_ids:
		var degree: int = paid_neighbors[station_id].size()
		if degree != 2:
			errors.append("Circle station '%s' must have two paid neighbors, found %d" % [station_id, degree])

	if circle_station_ids.is_empty():
		return

	var visited := {}
	var pending: Array[String] = [circle_station_ids[0]]
	while not pending.is_empty():
		var station_id: String = pending.pop_back()
		if visited.has(station_id):
			continue
		visited[station_id] = true
		for neighbor_id: String in paid_neighbors[station_id]:
			if not visited.has(neighbor_id):
				pending.append(neighbor_id)

	if visited.size() != circle_station_ids.size():
		errors.append(
			"Circle Line paid graph must be connected, reached %d of %d stations"
			% [visited.size(), circle_station_ids.size()]
		)
