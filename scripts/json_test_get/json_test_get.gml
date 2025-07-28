/// @description json_test_get()
function json_test_get() {

	// 3.1: Non-existent top layer
	assert_isnt_defined(json_get(-1), "3.1.1: Didn't detect missing top layer!");

	// 3.2: Top level is map
	var fixture = JsonStruct(JsonMap(
	    "foo", "FOO",
	    "bar", JsonList("a", "b", "c"),
	    "baz", JsonMap("d", "e")
	));

	// 3.2.1: Top level exists
	assert_equal(json_get(fixture), fixture, "3.2.1.1: Top level should exist!");

	// 3.2.2: Should fetch simple values
	assert_equal(json_get(fixture, "foo"), "FOO", "3.2.2.1: Should fetch simple value!");
	assert_isnt_defined(json_get(fixture, "doo"), "3.2.2.2: Should handle simple value that doesn't exist!");
	assert_equal(json_get(fixture, ["foo"]), "FOO", "3.2.2.1 (alt): Should fetch simple value from array path!");
	assert_isnt_defined(json_get(fixture, ["doo"]), "3.2.2.2 (alt): Should handle simple value that doesn't exist from array path!");

	// 3.2.3: Should fetch sublists
	assert_equal(json_get(fixture, "bar", 0), "a", "3.2.3.1: Should fetch simple value from sublist!");
	assert_equal(json_get(fixture, "bar", 1), "b", "3.2.3.2: Should fetch simple value from sublist!");
	assert_equal(json_get(fixture, "bar", 2), "c", "3.2.3.3: Should fetch simple value from sublist!");
	assert_isnt_defined(json_get(fixture, "bar", 3), "3.2.3.4: Should handle simple value from sublist that doesn't exist!");
	assert_equal(json_get(fixture, "bar", -3), "a", "3.2.3.5: Should fetch simple value from sublist with negative indexing!");
	assert_equal(json_get(fixture, "bar", -2), "b", "3.2.3.6: Should fetch simple value from sublist with negative indexing!");
	assert_equal(json_get(fixture, "bar", -1), "c", "3.2.3.7: Should fetch simple value from sublist with negative indexing!");
	assert_equal(json_get(fixture, ["bar", 0]), "a", "3.2.3.1 (alt): Should fetch simple value from array path from sublist!");
	assert_equal(json_get(fixture, ["bar", 1]), "b", "3.2.3.2 (alt): Should fetch simple value from array path from sublist!");
	assert_equal(json_get(fixture, ["bar", 2]), "c", "3.2.3.3 (alt): Should fetch simple value from array path from sublist!");
	assert_isnt_defined(json_get(fixture, ["bar", 3]), "3.2.3.4 (alt): Should handle simple value from array path from sublist that doesn't exist!");
	assert_equal(json_get(fixture, ["bar", -3]), "a", "3.2.3.5 (alt): Should fetch simple value from array path from sublist with negative indexing!");
	assert_equal(json_get(fixture, ["bar", -2]), "b", "3.2.3.6 (alt): Should fetch simple value from array path from sublist with negative indexing!");
	assert_equal(json_get(fixture, ["bar", -1]), "c", "3.2.3.7 (alt): Should fetch simple value from array path from sublist with negative indexing!");

	// 3.2.4: Should fetch submaps
	assert_equal(json_get(fixture, "baz", "d"), "e", "3.2.4.1: Should fetch simple value from submap!");
	assert_isnt_defined(json_get(fixture, "baz", "k"), "3.2.4.2: Should handle simple value from submap that doesn't exist!");
	assert_equal(json_get(fixture, ["baz", "d"]), "e", "3.2.4.1 (alt): Should fetch simple value from submap!");
	assert_isnt_defined(json_get(fixture, ["baz", "k"]), "3.2.4.2 (alt): Should handle simple value from submap that doesn't exist!");

	// 3.2.5: Shouldn't choke on overshot paths
	assert_isnt_defined(json_get(fixture, "foo", 0), "3.2.5.1: Should handle overshot path!");
	assert_isnt_defined(json_get(fixture, ["foo", 0]), "3.2.5.1 (alt 1): Should handle overshot path!");
	assert_isnt_defined(json_get(fixture, "foo", [0]), "3.2.5.1 (alt 2): Should handle overshot path!");


	// 3.3: Top level is "list"
	json_destroy(fixture);
	fixture = JsonStruct(JsonList(
	    "foo",
	    JsonList("a", "b", "c"),
	    JsonMap("d", "e")
	));

	// 3.3.1: Top-level exists
	assert_equal(json_get(fixture), fixture, "3.3.1.1: Top level should exist!");

	// 3.3.2: Should fetch simple values
	assert_equal(json_get(fixture, 0), "foo", "3.3.2.1: Should fetch simple value!");
	assert_isnt_defined(json_get(fixture, 5), "3.3.2.2: Should handle simple value that doesn't exist!");
	assert_equal(json_get(fixture, -3), "foo", "3.3.2.3: Should fetch simple value with negative index!");
	assert_equal(json_get(fixture, [0]), "foo", "3.3.2.1 (alt): Should fetch simple value!");
	assert_isnt_defined(json_get(fixture, [5]), "3.3.2.2 (alt): Should handle simple value that doesn't exist!");
	assert_equal(json_get(fixture, [-3]), "foo", "3.3.2.3 (alt): Should fetch simple value with negative index!");

	// 3.3.3: Should fetch sublists
	assert_equal(json_get(fixture, 1, 0), "a", "3.3.3.1: Should fetch simple value from sublist!");
	assert_equal(json_get(fixture, 1, 1), "b", "3.3.3.2: Should fetch simple value from sublist!");
	assert_equal(json_get(fixture, 1, 2), "c", "3.3.3.3: Should fetch simple value from sublist!");
	assert_isnt_defined(json_get(fixture, 1, 3), "3.3.3.4: Should handle simple value from sublist that doesn't exist!");
	assert_equal(json_get(fixture, -2, 0), "a", "3.3.3.5: Should fetch simple value from sublist!");
	assert_equal(json_get(fixture, -2, 1), "b", "3.3.3.6: Should fetch simple value from sublist!");
	assert_equal(json_get(fixture, -2, 2), "c", "3.3.3.7: Should fetch simple value from sublist!");
	assert_isnt_defined(json_get(fixture, -2, 3), "3.3.3.8: Should handle simple value from sublist that doesn't exist!");
	assert_equal(json_get(fixture, -2, -3), "a", "3.3.3.9: Should fetch simple value from sublist!");
	assert_equal(json_get(fixture, -2, -2), "b", "3.3.3.10: Should fetch simple value from sublist!");
	assert_equal(json_get(fixture, -2, -1), "c", "3.3.3.11: Should fetch simple value from sublist!");
	assert_isnt_defined(json_get(fixture, -2, -4), "3.3.3.12: Should handle simple value from sublist that doesn't exist!");
	assert_equal(json_get(fixture, [-2], -3), "a", "3.3.3.9 (alt): Should fetch simple value from sublist!");
	assert_equal(json_get(fixture, -2, [-2]), "b", "3.3.3.10 (alt): Should fetch simple value from sublist!");
	assert_equal(json_get(fixture, [-2, -1]), "c", "3.3.3.11 (alt): Should fetch simple value from sublist!");
	assert_isnt_defined(json_get(fixture, [-2, -4]), "3.3.3.12 (alt): Should handle simple value from sublist that doesn't exist!");

	// 3.3.4: Should fetch submaps
	assert_equal(json_get(fixture, 2, "d"), "e", "3.3.4.1: Should fetch simple value from submap!");
	assert_isnt_defined(json_get(fixture, 2, "k"), "3.3.4.2: Should handle simple value from submap that doesn't exist!");
	assert_equal(json_get(fixture, -1, "d"), "e", "3.3.4.3: Should fetch simple value from submap!");
	assert_isnt_defined(json_get(fixture, -1, "k"), "3.3.4.4: Should handle simple value from submap that doesn't exist!");
	assert_equal(json_get(fixture, [-1, "d"]), "e", "3.3.4.3 (alt): Should fetch simple value from submap!");
	assert_isnt_defined(json_get(fixture, [2], "k"), "3.3.4.1 (alt): Should handle simple value from submap that doesn't exist!");

	// 3.3.5: Shouldn't choke on overshot paths
	assert_isnt_defined(json_get(fixture, 0, 0), "3.3.5.1: Should handle overshot path!");
	assert_isnt_defined(json_get(fixture, [0, -5]), "3.3.5.2: Should handle overshot path!");

	// Cleanup
	json_destroy(fixture);




}
