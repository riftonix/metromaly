.PHONY: verify validate test
verify: validate test
validate:
	godot --headless --path . --script core/metro_map/validate_metro_map.gd
test:
	godot --headless --path . --script tests/core/metro_map/metro_map_test.gd
