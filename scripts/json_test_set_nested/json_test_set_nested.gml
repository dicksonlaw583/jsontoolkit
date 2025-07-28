/// @description json_test_set_nested()
function json_test_set_nested() {

	// 6.1: Non-existent top layer
	var filling_map = JsonStruct(JsonMap(
	    "d", "e"
	));
	var filling_list = JsonStruct(JsonList(
	    "a", "b", "c"
	));
	var filling_map2 = JsonStruct(JsonMap(
	    "D", "E"
	));
	var filling_list2 = JsonStruct(JsonList(
	    "A", "B", "C"
	));
	assert_equal(json_set_nested(-1, "a", filling_map), 0, "6.1.1: Failed nonsense test!");
	assert_equal(json_set_nested("nonsense", 2, filling_list), 0, "6.1.2: Failed nonsense test!");
	assert_equal(json_set_nested(-1, ["a"], filling_map), 0, "6.1.1 (alt): Failed nonsense test!");
	assert_equal(json_set_nested("nonsense", [2], filling_list), 0, "6.1.2 (alt): Failed nonsense test!");

	// 6.2: Top level is map
	var fixture = JsonStruct(JsonMap(
	    "foo", "boo"
	));

	// 6.2.1: Shouldn't choke on overshot paths
	assert_equal(json_set_nested(fixture, "foo", "waahoo", filling_map), -2, "6.2.1a: Failed to handle overshot path!");
	assert_equal(json_set_nested(fixture, "foo", "waahoo", filling_list), -2, "6.2.1b: Failed to handle overshot path!");
	assert_equal(json_set_nested(fixture, "foo", 0, filling_map), -2, "6.2.1c: Failed to handle overshot path!");
	assert_equal(json_set_nested(fixture, "foo", 0, filling_list), -2, "6.2.1d: Failed to handle overshot path!");
	assert_equal(json_set_nested(fixture, ["foo", 0], filling_map), -2, "6.2.1c (alt): Failed to handle overshot path!");
	assert_equal(json_set_nested(fixture, ["foo", 0], filling_list), -2, "6.2.1d (alt): Failed to handle overshot path!");

	// 6.2.2: Should set sublists
	assert_equal(json_set_nested(fixture, "bar", filling_list), 1, "6.2.2.1a: Sublist nest failed!");
	assert_equal(json_get(fixture, "bar", 0), "a", "6.2.2.1b: Sublist nest didn't happen!");
	assert_equal(json_get(fixture, "bar", 1), "b", "6.2.2.1c: Sublist nest didn't happen!");
	assert_equal(json_get(fixture, "bar", 2), "c", "6.2.2.1d: Sublist nest didn't happen!");
	assert_equal(json_get(fixture, "bar", 3), undefined, "6.2.2.1e: Sublist nest didn't happen!");
	assert_equal(json_set_nested(fixture, ["BAR"], filling_list2), 1, "6.2.2.2a: Sublist nest failed!");
	assert_equal(json_get(fixture, "BAR", 0), "A", "6.2.2.2b: Sublist nest didn't happen!");
	assert_equal(json_get(fixture, "BAR", 1), "B", "6.2.2.2c: Sublist nest didn't happen!");
	assert_equal(json_get(fixture, "BAR", 2), "C", "6.2.2.2d: Sublist nest didn't happen!");
	assert_equal(json_get(fixture, "BAR", 3), undefined, "6.2.2.2e: Sublist nest didn't happen!");

	// 6.2.3: Should set submaps
	assert_equal(json_set_nested(fixture, "baz", filling_map), 1, "6.2.3.1a: Submap nest failed!");
	assert_equal(json_get(fixture, "baz", "d"), "e", "6.2.3.1b: Submap nest didn't happen!");
	assert_equal(json_get(fixture, "baz", "k"), undefined, "6.2.3.1c: Submap nest didn't happen!");
	assert_equal(json_set_nested(fixture, "BAZ", filling_map2), 1, "6.2.3.2a: Submap nest failed!");
	assert_equal(json_get(fixture, "BAZ", "D"), "E", "6.2.3.2b: Submap nest didn't happen!");
	assert_equal(json_get(fixture, "BAZ", "K"), undefined, "6.2.3.2c: Submap nest didn't happen!");


	// 6.3: Top level is "list"
	json_destroy(fixture);
	fixture = JsonStruct(JsonList(
	    "foo",
	    "bar",
	    "baz",
	    "barbar",
	    "bazbaz"
	));
	filling_map = JsonStruct(JsonMap(
	    "D", "E"
	));
	filling_list = JsonStruct(JsonList(
	    "A", "B", "C"
	));
	filling_map2 = JsonStruct(JsonMap(
	    "d", "e"
	));
	filling_list2 = JsonStruct(JsonList(
	    "a", "b", "c"
	));

	// 6.3.1: Shouldn't choke on overshot paths
	assert_equal(json_set_nested(fixture, 0, "waahoo", filling_map), -2, "6.3.1a: Failed to handle overshot path!");
	assert_equal(json_set_nested(fixture, 0, "waahoo", filling_list), -2, "6.3.1b: Failed to handle overshot path!");
	assert_equal(json_set_nested(fixture, 0, 0, filling_map), -2, "6.3.1c: Failed to handle overshot path!");
	assert_equal(json_set_nested(fixture, 0, 0, filling_list), -2, "6.3.1d: Failed to handle overshot path!");
	assert_equal(json_set_nested(fixture, [0, "waahoo"], filling_list), -2, "6.3.1b (alt): Failed to handle overshot path!");
	assert_equal(json_set_nested(fixture, [0, 0], filling_map), -2, "6.3.1c (alt): Failed to handle overshot path!");

	// 6.3.2: Should set sublists
	assert_equal(json_set_nested(fixture, 1, filling_list), 1, "6.3.2.1a: Sublist nest failed!");
	assert_equal(json_get(fixture, 1, 0), "A", "6.3.2.1b: Sublist nest didn't happen!");
	assert_equal(json_get(fixture, 1, 1), "B", "6.3.2.1c: Sublist nest didn't happen!");
	assert_equal(json_get(fixture, 1, 2), "C", "6.3.2.1d: Sublist nest didn't happen!");
	assert_isnt_defined(json_get(fixture, 1, 3), "6.3.2.1e: Sublist nest didn't happen!");
	assert_equal(json_set_nested(fixture, [-2], filling_list2), 1, "6.3.2.2a: Sublist nest failed!");
	assert_equal(json_get(fixture, 3, 0), "a", "6.3.2.2b: Sublist nest didn't happen!");
	assert_equal(json_get(fixture, 3, 1), "b", "6.3.2.2c: Sublist nest didn't happen!");
	assert_equal(json_get(fixture, 3, 2), "c", "6.3.2.2d: Sublist nest didn't happen!");
	assert_isnt_defined(json_get(fixture, 3, 3), "6.3.2.2e: Sublist nest didn't happen!");

	// 6.3.3: Should set submaps
	assert_equal(json_set_nested(fixture, 2, filling_map), 1, "6.3.3.1a: Submap nest failed!");
	assert_equal(json_get(fixture, 2, "D"), "E", "6.3.3.1b: Submap nest didn't happen!");
	assert_isnt_defined(json_get(fixture, 2, "k"), "6.3.3.1c: Submap nest didn't happen!");
	assert_equal(json_set_nested(fixture, [-1], filling_map2), 1, "6.3.3.2a: Submap nest failed!");
	assert_equal(json_get(fixture, 4, "d"), "e", "6.3.3.2b: Submap nest didn't happen!");
	assert_isnt_defined(json_get(fixture, 4, "k"), "6.3.3.2c: Submap nest didn't happen!");

	// Cleanup
	json_destroy(fixture);




}
