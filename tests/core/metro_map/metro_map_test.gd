extends SceneTree


const MapData = preload("res://core/metro_map/metro_map_data.gd")
const Graph = preload("res://core/metro_map/metro_graph.gd")
const MapValidator = preload("res://core/metro_map/metro_map_validator.gd")


var _failures: Array[String] = []
var _tests_run := 0


func _initialize() -> void:
	_test_committed_data()
	_test_connection_lookup()
	_test_invalid_connection_shape()
	_test_self_connection()
	_test_missing_station()
	_test_duplicate_reversed_connection()
	_test_invalid_cost()
	_test_invalid_transfer()
	_test_missing_circle_edge()
	_test_extra_circle_edge()
	_test_disconnected_paid_topology()

	if _failures.is_empty():
		print("Metro map tests passed (%d tests)" % _tests_run)
		quit(0)
		return

	for failure: String in _failures:
		printerr(failure)
	printerr("Metro map tests failed (%d failures)" % _failures.size())
	quit(1)


func _test_committed_data() -> void:
	var errors := _validate_committed_data()
	_expect(errors.is_empty(), "committed data is valid: %s" % [errors])


func _test_connection_lookup() -> void:
	_expect_equal(
		Graph.get_connection_cost(
			"park_kultury_koltsevaya",
			"oktyabrskaya_koltsevaya",
		),
		1,
		"forward lookup returns paid cost",
	)
	_expect_equal(
		Graph.get_connection_cost(
			"oktyabrskaya_koltsevaya",
			"park_kultury_koltsevaya",
		),
		1,
		"reverse lookup returns the same cost",
	)
	_expect_equal(
		Graph.get_connection_cost(
			"park_kultury_koltsevaya",
			"park_kultury_sokolnicheskaya",
		),
		0,
		"transfer lookup preserves zero cost",
	)
	_expect_equal(
		Graph.get_connection_cost(
			"park_kultury_koltsevaya",
			"kurskaya_koltsevaya",
		),
		null,
		"unrelated stations have no direct connection",
	)


func _test_missing_station() -> void:
	var connections := _connections_copy()
	connections.append({"stations": ["park_kultury_koltsevaya", "missing_station"], "cost": 0})
	var errors := _validate(connections)
	_expect_contains(errors, "unknown station 'missing_station'", "missing station is rejected")


func _test_invalid_connection_shape() -> void:
	var connections := _connections_copy()
	connections.append({"stations": ["park_kultury_koltsevaya"], "cost": 0})
	var errors := _validate(connections)
	_expect_contains(errors, "must reference exactly two stations", "invalid connection shape is rejected")


func _test_self_connection() -> void:
	var connections := _connections_copy()
	connections.append(
		{
			"stations": ["park_kultury_koltsevaya", "park_kultury_koltsevaya"],
			"cost": 1,
		}
	)
	var errors := _validate(connections)
	_expect_contains(errors, "cannot connect station", "self-connection is rejected")


func _test_duplicate_reversed_connection() -> void:
	var connections := _connections_copy()
	connections.append(
		{
			"stations": ["oktyabrskaya_koltsevaya", "park_kultury_koltsevaya"],
			"cost": 1,
		}
	)
	var errors := _validate(connections)
	_expect_contains(errors, "duplicates station pair", "reversed duplicate is rejected")


func _test_invalid_cost() -> void:
	var connections := _connections_copy()
	connections[0]["cost"] = 2
	var errors := _validate(connections)
	_expect_contains(errors, "invalid cost '2'", "cost outside zero and one is rejected")


func _test_invalid_transfer() -> void:
	var connections := _connections_copy()
	connections.append(
		{
			"stations": ["park_kultury_koltsevaya", "oktyabrskaya_koltsevaya"],
			"cost": 0,
		}
	)
	var errors := _validate(connections)
	_expect_contains(errors, "must connect stations on different lines", "same-line transfer is rejected")


func _test_missing_circle_edge() -> void:
	var connections := _connections_copy()
	connections.remove_at(0)
	var errors := _validate(connections)
	_expect_contains(errors, "must have two paid neighbors", "missing Circle edge is rejected")


func _test_extra_circle_edge() -> void:
	var connections := _connections_copy()
	connections.append(
		{
			"stations": ["park_kultury_koltsevaya", "dobryninskaya_koltsevaya"],
			"cost": 1,
		}
	)
	var errors := _validate(connections)
	_expect_contains(errors, "must have two paid neighbors", "extra Circle edge is rejected")


func _test_disconnected_paid_topology() -> void:
	var connections: Array = []
	var first_cycle := [
		"park_kultury_koltsevaya",
		"oktyabrskaya_koltsevaya",
		"dobryninskaya_koltsevaya",
		"paveletskaya_koltsevaya",
		"taganskaya_koltsevaya",
		"kurskaya_koltsevaya",
	]
	var second_cycle := [
		"komsomolskaya_koltsevaya",
		"prospekt_mira_koltsevaya",
		"novoslobodskaya_koltsevaya",
		"belorusskaya_koltsevaya",
		"krasnopresnenskaya_koltsevaya",
		"kievskaya_koltsevaya",
	]
	for cycle: Array in [first_cycle, second_cycle]:
		for index: int in cycle.size():
			connections.append(
				{
					"stations": [cycle[index], cycle[(index + 1) % cycle.size()]],
					"cost": 1,
				}
			)
	for connection: Dictionary in MapData.CONNECTIONS:
		if connection["cost"] == 0:
			connections.append(connection.duplicate(true))

	var errors := _validate(connections)
	_expect_contains(errors, "paid graph must be connected", "disconnected cycles are rejected")


func _validate_committed_data() -> Array[String]:
	return MapValidator.validate(
		MapData.LINES,
		MapData.STATIONS,
		MapData.CONNECTIONS,
	)


func _validate(connections: Array) -> Array[String]:
	return MapValidator.validate(
		MapData.LINES,
		MapData.STATIONS,
		connections,
	)


func _connections_copy() -> Array:
	return MapData.CONNECTIONS.duplicate(true)


func _expect(condition: bool, description: String) -> void:
	_tests_run += 1
	if not condition:
		_failures.append("FAIL: %s" % description)


func _expect_equal(actual: Variant, expected: Variant, description: String) -> void:
	_expect(actual == expected, "%s (expected %s, got %s)" % [description, expected, actual])


func _expect_contains(errors: Array[String], fragment: String, description: String) -> void:
	var found := false
	for error: String in errors:
		if fragment in error:
			found = true
			break
	_expect(found, "%s (missing '%s' in %s)" % [description, fragment, errors])
