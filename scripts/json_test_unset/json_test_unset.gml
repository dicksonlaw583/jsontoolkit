/// @description json_test_unset()

// 9.1: Non-existent top layer
assert_equal(json_unset(-1, "a", "A"), 0, "9.1a: Failed to handle nonsense!");
assert_equal(json_unset("nonsense", 2, "A"), 0, "9.1b: Failed to handle nonsense!");

// 9.2.1: Top level is map
var fixture = JsonStruct(JsonMap(
    "foo", "FOO",
    "goo", "GOO",
    "bar", JsonList("a", "b", "c"),
    "baz", JsonMap("d", "e")
));

// 9.2.1: Should unset simple values
assert_equal(json_get(fixture, "foo"), "FOO", "9.2.1.1: Sanity test failed!");
assert_equal(json_unset(fixture, "foo"), 1, "9.2.1.2a: Simple unset failed!");
assert_equal(json_exists(fixture, "foo"), -1, "9.2.1.2b: Simple unset didn't happen!");
assert_equal(json_unset(fixture, "doo"), -1, "9.2.1.3: Simple bad unset went through!");

// 9.2.2: Should unset sublists
assert_equal(json_get(fixture, "bar", 0), "a", "9.2.2.1a: Sanity test failed!");
assert_equal(json_get(fixture, "bar", 1), "b", "9.2.2.1b: Sanity test failed!");
assert_equal(json_get(fixture, "bar", 2), "c", "9.2.2.1c: Sanity test failed!");
assert_equal(json_unset(fixture, "bar", 1), 1, "9.2.2.2a: Sublist unset failed!");
assert_equal(json_get(fixture, "bar", 0), "a", "9.2.2.2b: Sublist unset wrong!");
assert_equal(json_get(fixture, "bar", 1), "c", "9.2.2.2c: Sublist unset wrong!");
assert_equal(json_unset(fixture, "bar", 3), -2, "9.2.2.3: Sublist bad unset went through!");

// 9.2.3: Should unset submaps
assert_equal(json_get(fixture, "baz", "d"), "e", "9.2.3.1a: Sanity test failed!");
assert_equal(json_unset(fixture, "baz", "d"), 1, "9.2.3.2a: Submap unset failed!");
assert_equal(json_exists(fixture, "baz", "d"), -2, "9.2.3.2b: Submap unset didn't happen!");
assert_equal(json_unset(fixture, "baz", "k"), -2, "9.2.3.3: Submap bad unset went through!");

// 9.2.4: Shouldn't choke on overshot paths
assert_equal(json_unset(fixture, "goo", 0), -2, "9.2.4a: Failed to handle overshot path!");
assert_equal(json_unset(fixture, "goo", "over"), -2, "9.2.4b: Failed to handle overshot path!");


// 9.3: Top level is "list"
json_destroy(fixture);
fixture = JsonStruct(JsonList(
    "foo",
    JsonList("a", "b", "c"),
    JsonMap("d", "e", "f", "g"),
    "goo",
    "hoo"
));

// 9.3.1: Should unset simple values
assert_equal(json_get(fixture, 3), "goo", "9.3.1.1a: Sanity test failed!");
assert_equal(json_unset(fixture, 3), 1, "9.3.1.2a: Simple unset failed!");
assert_equal(json_get(fixture, 3), "hoo", "9.2.1.2b: Simple unset didn't shift back!");
assert_equal(json_unset(fixture, 5), -1, "9.3.1.3: Simple bad unset went through!");

// 9.3.2: Should unset sublists
assert_equal(json_get(fixture, 1, 0), "a", "9.3.2.1a: Sanity test failed!");
assert_equal(json_get(fixture, 1, 1), "b", "9.3.2.1b: Sanity test failed!");
assert_equal(json_get(fixture, 1, 2), "c", "9.3.2.1c: Sanity test failed!");
assert_equal(json_unset(fixture, 1, 1), 1, "9.3.2.2a: Sublist unset failed!");
assert_equal(json_get(fixture, 1, 0), "a", "9.3.2.2b: Sublist unset wrong!");
assert_equal(json_get(fixture, 1, 1), "c", "9.3.2.2c: Sublist unset wrong!");
assert_equal(json_exists(fixture, 1, 2), -2, "9.3.2.3a: Sublist didn't shrink!");
assert_equal(json_unset(fixture, 1, 3), -2, "9.3.2.3b: Sublist bad unset went through!");

// 9.3.3: Should unset submaps
assert_equal(json_get(fixture, 2, "d"), "e", "9.3.3.1a: Sanity test failed!");
assert_equal(json_get(fixture, 2, "f"), "g", "9.3.3.1b: Sanity test failed!");
assert_equal(json_unset(fixture, 2, "d"), 1, "9.3.3.2a: Submap unset failed!");
assert_equal(json_exists(fixture, 2, "d"), -2, "9.3.3.2b: Submap unset didn't happen!");
assert_equal(json_get(fixture, 2, "f"), "g", "9.3.3.2c: Submap unset wrong!");
assert_equal(json_unset(fixture, 2, "q"), -2, "9.3.3.3: Submap bad unset went through!");

// 9.3.4: Shouldn't choke on overshot paths
assert_equal(json_unset(fixture, 0, 0), -2, "9.3.4a: Failed to handle overshot path!");
assert_equal(json_unset(fixture, 0, "overshoot"), -2, "9.3.4a: Failed to handle overshot path!");

// Cleanup
json_destroy(fixture);

