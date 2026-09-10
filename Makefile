.PHONY: verify validate test
verify: validate test
validate:
	godot --headless --path . --script core/metro_map/validate_metro_map.gd
test:
	godot --headless --path . --script tests/core/metro_map/metro_map_test.gd
	godot --headless --path . --script tests/core/metro_map/metro_map_session_test.gd
	godot --headless --path . --script tests/core/squad/squad_test.gd
	godot --headless --path . --script tests/core/squad_movement/squad_movement_test.gd
	godot --headless --path . --script tests/apps/client/metro_map/metro_map_interaction_test.gd
