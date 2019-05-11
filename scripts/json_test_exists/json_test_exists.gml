/// @description json_test_exists()

// 4.1: Non-existent top layer
assert_equal(json_exists(-1), 0, "4.1.1a: Didn't detect missing top layer!");
assert_equal(json_exists(-1, 5), 0, "4.1.1b: Didn't detect missing top layer!");
assert_equal(json_exists(-1, ["3", -2]), 0, "4.1.1c: Didn't detect missing top layer!");

// 4.2: Top level is map
var fixture = JsonStruct(JsonMap(
    "foo", "FOO",
    "bar", JsonList("a", "b", "c"),
    "baz", JsonMap("d", "e")
));

// 4.2.1: Top level exists
assert_equal(json_exists(fixture), 1, "4.2.1.1: Didn't detect top level!");

// 4.2.2: Should fetch simple values
assert_equal(json_exists(fixture, "foo"), 1, "4.2.2.1: Didn't detect simple value!");
assert_equal(json_exists(fixture, "doo"), -1, "4.2.2.2: Didn't detect missing simple value!");
assert_equal(json_exists(fixture, ["foo"]), 1, "4.2.2.1 (alt): Didn't detect simple value!");
assert_equal(json_exists(fixture, ["doo"]), -1, "4.2.2.2 (alt): Didn't detect missing simple value!");


// 4.2.3: Should fetch sublists
assert_equal(json_exists(fixture, "bar", 0), 1, "4.2.3.1: Didn't detect sublist value!");
assert_equal(json_exists(fixture, "bar", 1), 1, "4.2.3.2: Didn't detect sublist value!");
assert_equal(json_exists(fixture, "bar", 2), 1, "4.2.3.3: Didn't detect sublist value!");
assert_equal(json_exists(fixture, "bar", 3), -2, "4.2.3.4: Didn't detect missing sublist value!");
assert_equal(json_exists(fixture, "bar", -1), 1, "4.2.3.5: Didn't detect sublist value!");
assert_equal(json_exists(fixture, "bar", -2), 1, "4.2.3.6: Didn't detect sublist value!");
assert_equal(json_exists(fixture, "bar", -3), 1, "4.2.3.7: Didn't detect sublist value!");
assert_equal(json_exists(fixture, "bar", -4), -2, "4.2.3.8: Didn't detect missing sublist value!");
assert_equal(json_exists(fixture, ["bar", -3]), 1, "4.2.3.7 (alt): Didn't detect sublist value!");
assert_equal(json_exists(fixture, ["bar", 3]), -2, "4.2.3.8 (alt): Didn't detect missing sublist value!");

// 4.2.4: Should fetch submaps
assert_equal(json_exists(fixture, "baz", "d"), 1, "4.2.4.1: Didn't detect submap value!");
assert_equal(json_exists(fixture, "baz", "k"), -2, "4.2.4.2: Didn't detect missing submap value!");
assert_equal(json_exists(fixture, ["baz", "d"]), 1, "4.2.4.1 (alt): Didn't detect submap value!");
assert_equal(json_exists(fixture, ["baz", "k"]), -2, "4.2.4.2 (alt): Didn't detect missing submap value!");

// 4.2.5: Shouldn't choke on overshot paths
assert_equal(json_exists(fixture, "foo", 0), -2, "4.2.5.1: Didn't handle overshot path!");
assert_equal(json_exists(fixture, ["foo", 0]), -2, "4.2.5.2: Didn't handle overshot path!");


// 4.3: Top level is "list"
json_destroy(fixture);
fixture = JsonStruct(JsonList(
    "foo",
    JsonList("a", "b", "c"),
    JsonMap("d", "e")
));

// 4.3.1: Top-level exists
assert_equal(json_exists(fixture), 1, "4.3.1.1: Didn't detect top level!");

// 4.3.2: Should fetch simple values
assert_equal(json_exists(fixture, 0), 1, "4.3.2.1: Didn't detect simple value!");
assert_equal(json_exists(fixture, 5), -1, "4.3.2.2: Didn't detect missing simple value!");
assert_equal(json_exists(fixture, [0]), 1, "4.3.2.1 (alt): Didn't detect simple value!");
assert_equal(json_exists(fixture, [5]), -1, "4.3.2.2 (alt): Didn't detect missing simple value!");

// 4.3.3: Should fetch sublists
assert_equal(json_exists(fixture, 1, 0), 1, "4.3.3.1: Didn't detect sublist value!");
assert_equal(json_exists(fixture, 1, 1), 1, "4.3.3.2: Didn't detect sublist value!");
assert_equal(json_exists(fixture, 1, 2), 1, "4.3.3.3: Didn't detect sublist value!");
assert_equal(json_exists(fixture, 1, 3), -2, "4.3.3.4: Didn't detect missing sublist value!");
assert_equal(json_exists(fixture, -2, -1), 1, "4.3.3.5: Didn't detect sublist value!");
assert_equal(json_exists(fixture, -2, -2), 1, "4.3.3.6: Didn't detect sublist value!");
assert_equal(json_exists(fixture, -2, -3), 1, "4.3.3.7: Didn't detect sublist value!");
assert_equal(json_exists(fixture, -2, -4), -2, "4.3.3.8: Didn't detect missing sublist value!");
assert_equal(json_exists(fixture, [1, 3]), -2, "4.3.3.4 (alt): Didn't detect missing sublist value!");
assert_equal(json_exists(fixture, -2, [-1]), 1, "4.3.3.5 (alt): Didn't detect sublist value!");

// 4.3.4: Should fetch submaps
assert_equal(json_exists(fixture, 2, "d"), 1, "4.3.4.1: Didn't detect submap value!");
assert_equal(json_exists(fixture, 2, "k"), -2, "4.3.4.2: Didn't detect missing submap value!");
assert_equal(json_exists(fixture, [2, "d"]), 1, "4.3.4.1 (alt): Didn't detect submap value!");
assert_equal(json_exists(fixture, [2, "k"]), -2, "4.3.4.2 (alt): Didn't detect missing submap value!");

// 4.3.5: Shouldn't choke on overshot paths
assert_equal(json_exists(fixture, 0, 0), -2, "4.3.5.1: Didn't handle overshot path!");
assert_equal(json_exists(fixture, [-3, 0]), -2, "4.3.5.2: Didn't handle overshot path!");

// Cleanup
json_destroy(fixture);

