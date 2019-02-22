/// @description json_test_insert()

// 7.1: Non-existent top layer
assert_equal(json_insert(-1, "a", "A"), 0, "7.1.1: Failed nonsense test!");
assert_equal(json_insert("nonsense", 2, "A"), 0, "7.1.2: Failed nonsense test!");

// 7.2: Top level is map
var fixture = JsonStruct(JsonMap(
    "foo", "FOO",
    "bar", JsonList("a", "b", "c"),
    "baz", JsonMap("d", "e")
));

// 7.2.1: Should insert simple values
assert_not_equal(json_get(fixture, "foo"), "BOO", "7.2.1.1: Failed opening sanity test!");
assert_equal(json_insert(fixture, "foo", "BOO"), 1, "7.2.1.2a: Simple insert failed!");
assert_equal(json_get(fixture, "foo"), "BOO", "7.2.1.2b: Simple insert didn't happen!");
assert_not_equal(json_get(fixture, "doo"), "DOO", "7.2.1.3a: Failed opening sanity test!");
assert_equal(json_insert(fixture, "doo", "DOO"), 1, "7.2.1.3b: Simple insert failed!");
assert_equal(json_get(fixture, "doo"), "DOO", "7.2.1.3c: Simple insert didn't happen!");

// 7.2.2: Should insert sublists
assert_equal(json_get(fixture, "bar", 0), "a", "7.2.2.1a: Failed opening sanity test!");
assert_equal(json_get(fixture, "bar", 1), "b", "7.2.2.1b: Failed opening sanity test!");
assert_equal(json_get(fixture, "bar", 2), "c", "7.2.2.1c: Failed opening sanity test!");
assert_equal(json_get(fixture, "bar", 3), undefined, "7.2.2.1d: Failed opening sanity test!");
assert_equal(json_insert(fixture, "bar", 1, "B"), 1, "7.2.2.2a: Sublist insert failed!");
assert_equal(json_get(fixture, "bar", 0), "a", "7.2.2.2b: Sublist insert wrong!");
assert_equal(json_get(fixture, "bar", 1), "B", "7.2.2.2c: Sublist insert didn't happen!");
assert_equal(json_get(fixture, "bar", 2), "b", "7.2.2.2d: Sublist insert wrong!");
assert_equal(json_get(fixture, "bar", 3), "c", "7.2.2.2e: Sublist insert wrong!");
assert_equal(json_get(fixture, "bar", 4), undefined, "7.2.2.2f: Sublist insert wrong!");

// 7.2.3: Should insert submaps
assert_equal(json_get(fixture, "baz", "d"), "e", "7.2.3.1a: Failed opening sanity test!");
assert_equal(json_insert(fixture, "baz", "d", "f"), 1, "7.2.3.2a: Submap insert failed!");
assert_equal(json_get(fixture, "baz", "d"), "f", "7.2.3.2b: Submap insert didn't happen!");
assert_equal(json_get(fixture, "baz", "k"), undefined, "7.2.3.3a: Failed openign sanity test!");
assert_equal(json_insert(fixture, "baz", "k", "kappa"), 1, "7.2.3.3b: Submap insert failed!");
assert_equal(json_get(fixture, "baz", "k"), "kappa", "7.2.3.3c: Submap insert didn't happen!");

// 7.2.4: Shouldn't choke on overshot paths
assert_equal(json_insert(fixture, "foo", 0, "overshoot"), -2, "7.2.4.1: Failed to handle overshot path!");


// 7.3: Top level is "list"
json_destroy(fixture);
fixture = JsonStruct(JsonList(
    "foo",
    JsonList("a", "b", "c"),
    JsonMap("d", "e"),
    "goo"
));

// 7.3.1: Should insert simple values
assert_equal(json_get(fixture, 3), "goo", "7.3.1.1: Failed opening sanity test!");
assert_equal(json_insert(fixture, 3, "doo"), 1, "7.3.1.2a: Simple insert failed!");
assert_equal(json_get(fixture, 3), "doo", "7.3.1.2b: Simple insert didn't happen!");
assert_equal(json_get(fixture, 4), "goo", "7.3.1.2c: Simple insert didn't push back!");

// 7.3.2: Should insert sublists
assert_equal(json_get(fixture, 1, 0), "a", "7.3.2.1a: Failed opening sanity test!");
assert_equal(json_get(fixture, 1, 1), "b", "7.3.2.1b: Failed opening sanity test!");
assert_equal(json_get(fixture, 1, 2), "c", "7.3.2.1c: Failed opening sanity test!");
assert_isnt_defined(json_get(fixture, 1, 3), "7.3.2.1d: Failed opening sanity test!");
assert_equal(json_insert(fixture, 1, 1, "B"), 1, "7.3.2.2a: Sublist insert failed!");
assert_equal(json_get(fixture, 1, 0), "a", "7.3.2.2b: Sublist insert wrong!");
assert_equal(json_get(fixture, 1, 1), "B", "7.3.2.2c: Sublist insert wrong!");
assert_equal(json_get(fixture, 1, 2), "b", "7.3.2.2c: Sublist insert wrong!");
assert_equal(json_get(fixture, 1, 3), "c", "7.3.2.2d: Sublist insert wrong!");
assert_isnt_defined(json_get(fixture, 1, 4), "7.3.2.2e: Sublist insert wrong!");

// 7.3.3: Should insert submaps
assert_equal(json_get(fixture, 2, "d"), "e", "7.3.3.1a: Failed opening sanity test!");
assert_isnt_defined(json_get(fixture, 2, "k"), "7.3.3.1b: Failed opening sanity test!");
assert_equal(json_insert(fixture, 2, "d", "eee"), 1, "7.3.3.2a: Submap insert failed!");
assert_equal(json_insert(fixture, 2, "k", "kay"), 1, "7.3.3.2b: Submap insert failed!");
assert_equal(json_get(fixture, 2, "d"), "eee", "7.3.3.2c: Submap insert didn't happen!");
assert_equal(json_get(fixture, 2, "k"), "kay", "7.3.3.2d: Submap insert didn't happen!");

// 7.3.4: Shouldn't choke on overshot paths
assert_equal(json_insert(fixture, 0, 0, "overshoot"), -2, "7.3.4.1: Failed to handle overshot path!");

// Cleanup
json_destroy(fixture);

