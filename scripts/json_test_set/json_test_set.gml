/// @description json_test_set()

// 5.1: Non-existent top layer
assert_equal(json_set(-1, "a", "A"), 0, "5.1.1: Failed nonsense test!");
assert_equal(json_set("nonsense", 2, "A"), 0, "5.1.2: Failed nonsense test!");
assert_equal(json_set(-1, ["a"], "A"), 0, "5.1.1 (alt): Failed nonsense test!");
assert_equal(json_set("nonsense", [2], "A"), 0, "5.1.2 (alt): Failed nonsense test!");

// 5.2: Top level is map
var fixture = JsonStruct(JsonMap(
    "foo", "FOO",
    "bar", JsonList("a", "b", "c"),
    "baz", JsonMap("d", "e")
));

// 5.2.1: Should set simple values
assert_not_equal(json_get(fixture, "foo"), "BOO", "5.2.1.1: Failed opening sanity test!");
assert_equal(json_set(fixture, "foo", "BOO"), 1, "5.2.1.2a: Simple set failed!");
assert_equal(json_get(fixture, "foo"), "BOO", "5.2.1.2b: Simple set didn't happen!");
assert_not_equal(json_get(fixture, "doo"), "DOO", "5.2.1.3a: Failed opening sanity test!");
assert_equal(json_set(fixture, "doo", "DOO"), 1, "5.2.1.3b: Simple set failed!");
assert_equal(json_get(fixture, "doo"), "DOO", "5.2.1.3c: Simple set didn't happen!");

// 5.2.2: Should set sublists
assert_equal(json_get(fixture, "bar", 0), "a", "5.2.2.1a: Failed opening sanity test!");
assert_equal(json_get(fixture, "bar", 1), "b", "5.2.2.1b: Failed opening sanity test!");
assert_equal(json_get(fixture, "bar", 2), "c", "5.2.2.1c: Failed opening sanity test!");
assert_equal(json_get(fixture, "bar", 3), undefined, "5.2.2.1d: Failed opening sanity test!");
assert_equal(json_set(fixture, "bar", 1, "B"), 1, "5.2.2.2a: Sublist set failed!");
assert_equal(json_get(fixture, "bar", 0), "a", "5.2.2.2b: Sublist set wrong!");
assert_equal(json_get(fixture, "bar", 1), "B", "5.2.2.2c: Sublist set didn't happen!");
assert_equal(json_get(fixture, "bar", 2), "c", "5.2.2.2d: Sublist set wrong!");
assert_equal(json_get(fixture, "bar", 3), undefined, "5.2.2.2e: Sublist set wrong!");
assert_equal(json_set(fixture, "bar", 3, "delta"), 1, "5.2.2.3a: Failed opening sanity test");
assert_equal(json_get(fixture, "bar", 0), "a", "5.2.2.3b: Sublist set wrong!");
assert_equal(json_get(fixture, "bar", 1), "B", "5.2.2.3c: Sublist set wrong!");
assert_equal(json_get(fixture, "bar", 2), "c", "5.2.2.3d: Sublist set wrong!");
assert_equal(json_get(fixture, "bar", 3), "delta", "5.2.2.3e: Sublist set didn't happen!");
assert_equal(json_set(fixture, ["bar", -1], "epsilon"), 1, "5.2.2.4a: Sublist set failed!");
assert_equal(json_get(fixture, "bar", 0), "a", "5.2.2.4b: Sublist set wrong!");
assert_equal(json_get(fixture, "bar", 1), "B", "5.2.2.4c: Sublist set wrong!");
assert_equal(json_get(fixture, "bar", 2), "c", "5.2.2.4d: Sublist set wrong!");
assert_equal(json_get(fixture, "bar", 3), "epsilon", "5.2.2.4e: Sublist set didn't happen!");


// 5.2.3: Should set submaps
assert_equal(json_get(fixture, "baz", "d"), "e", "5.2.3.1a: Failed opening sanity test!");
assert_equal(json_set(fixture, "baz", "d", "f"), 1, "5.2.3.2a: Submap set failed!");
assert_equal(json_get(fixture, "baz", "d"), "f", "5.2.3.2b: Submap set didn't happen!");
assert_equal(json_get(fixture, "baz", "k"), undefined, "5.2.3.3a: Failed opening sanity test!");
assert_equal(json_set(fixture, "baz", "k", "kappa"), 1, "5.2.3.3b: Submap set failed!");
assert_equal(json_get(fixture, "baz", "k"), "kappa", "5.2.3.3c: Submap set didn't happen!");
assert_equal(json_set(fixture, ["baz", "L"], "lambda"), 1, "5.2.3.4a: Submap set failed!");
assert_equal(json_get(fixture, "baz", "L"), "lambda", "5.2.3.4b: Submap set didn't happen!");

// 5.2.4: Shouldn't choke on overshot paths
assert_equal(json_set(fixture, "foo", 0, "overshoot"), -2, "5.2.4.1: Failed to handle overshot path!");
assert_equal(json_set(fixture, ["foo", 0], "overshoot"), -2, "5.2.4.1 (alt): Failed to handle overshot path!");


// 5.3: Top level is "list"
json_destroy(fixture);
fixture = JsonStruct(JsonList(
    "foo",
    JsonList("a", "b", "c"),
    JsonMap("d", "e")
));

// 5.3.1: Should set simple values
assert_equal(json_get(fixture, 0), "foo", "5.3.1.1: Failed opening sanity test!");
assert_equal(json_set(fixture, 0, "doo"), 1, "5.3.1.2a: Simple set failed!");
assert_equal(json_get(fixture, 0), "doo", "5.3.1.2b: Simple set didn't happen!");
assert_equal(json_set(fixture, 3, "bar"), 1, "5.3.1.3a: Simple set failed!");
assert_equal(json_get(fixture, 3), "bar", "5.3.1.3b: Simple set didn't happen!");
assert_equal(json_set(fixture, -1, "baz"), 1, "5.3.1.4a: Simple set failed!");
assert_equal(json_get(fixture, -1), "baz", "5.3.1.4b: Simple set didn't happen!");

// 5.3.2: Should set sublists
assert_equal(json_get(fixture, 1, 0), "a", "5.3.2.1a: Failed opening sanity test!");
assert_equal(json_get(fixture, 1, 1), "b", "5.3.2.1b: Failed opening sanity test!");
assert_equal(json_get(fixture, 1, 2), "c", "5.3.2.1c: Failed opening sanity test!");
assert_isnt_defined(json_get(fixture, 1, 3), "5.3.2.1d: Failed opening sanity test!");
assert_equal(json_set(fixture, 1, 1, "B"), 1, "5.3.2.2a: Sublist set failed!");
assert_equal(json_set(fixture, 1, 3, "D"), 1, "5.3.2.2b: Sublist set failed!");
assert_equal(json_get(fixture, 1, 0), "a", "5.3.2.2c: Sublist set wrong!");
assert_equal(json_get(fixture, 1, 1), "B", "5.3.2.2d: Sublist set didn't happen!");
assert_equal(json_get(fixture, 1, 2), "c", "5.3.2.2e: Sublist set wrong!");
assert_equal(json_get(fixture, 1, 3), "D", "5.3.2.2f: Sublist set didn't happen!");
assert_equal(json_set(fixture, [-3, -2], "C"), 1, "5.3.2.2g: Sublist set failed!");
assert_equal(json_get(fixture, 1, 0), "a", "5.3.2.2h: Sublist set wrong!");
assert_equal(json_get(fixture, 1, 1), "B", "5.3.2.2i: Sublist set wrong!");
assert_equal(json_get(fixture, 1, 2), "C", "5.3.2.2j: Sublist set didn't happen!");
assert_equal(json_get(fixture, 1, 3), "D", "5.3.2.2k: Sublist set wrong!");

// 5.3.3: Should set submaps
assert_equal(json_get(fixture, 2, "d"), "e", "5.3.3.1a: Failed opening sanity test!");
assert_isnt_defined(json_get(fixture, 2, "k"), "5.3.3.1b: Failed opening sanity test!");
assert_equal(json_set(fixture, 2, "d", "eee"), 1, "5.3.3.2a: Submap set failed!");
assert_equal(json_set(fixture, 2, "k", "kay"), 1, "5.3.3.2b: Submap set failed!");
assert_equal(json_get(fixture, 2, "d"), "eee", "5.3.3.2c: Submap set didn't happen!");
assert_equal(json_get(fixture, 2, "k"), "kay", "5.3.3.2d: Submap set didn't happen!");
assert_equal(json_set(fixture, [-2, "L"], "ELL"), 1, "5.3.3.3a: Submap set failed!");
assert_equal(json_get(fixture, 2, "L"), "ELL", "5.3.3.3b: Submap set didn't happen!");

// 5.3.4: Shouldn't choke on overshot paths
assert_equal(json_set(fixture, 0, 0, "overshoot"), -2, "5.3.4.1: Failed to handle overshot path!");
assert_equal(json_set(fixture, [0, 0], "overshoot"), -2, "5.3.4.1 (alt): Failed to handle overshot path!");

// Cleanup
json_destroy(fixture);

