/// @description json_test_clone()
function json_test_clone() {

	var fixture = JsonStruct(JsonMap(
	    "foo", "FOO",
	    "bar", JsonList("a", "b", "c"),
	    "baz", JsonMap("d", "e")
	));
	var fixture_clone = json_clone(fixture);

	// 10.1: Test equivalence
	assert_equal(json_get(fixture_clone, "foo"), "FOO", "10.1a: Clone not equivalent!");
	assert_equal(json_get(fixture_clone, "bar", 0), "a", "10.1b: Clone not equivalent!");
	assert_equal(json_get(fixture_clone, "bar", 1), "b", "10.1c: Clone not equivalent!");
	assert_equal(json_get(fixture_clone, "bar", 2), "c", "10.1d: Clone not equivalent!");
	assert_equal(json_get(fixture_clone, "baz", "d"), "e", "10.1e: Clone not equivalent!");

	// 10.2: Test independence
	assert_equal(json_set(fixture, "foo", "goo"), 1, "10.2.1a: Test not sane!");
	assert_equal(json_set(fixture, "bar", 0, "A"), 1, "10.2.1b: Test not sane!");
	assert_equal(json_set(fixture, "baz", "d", "E"), 1, "10.2.1c: Test not sane!");
	assert_equal(json_get(fixture_clone, "foo"), "FOO", "10.2.2a: Clone not independent!");
	assert_equal(json_get(fixture_clone, "bar", 0), "a", "10.2.2b: Clone not independent!");
	assert_equal(json_get(fixture_clone, "bar", 1), "b", "10.2.2c: Clone not independent!");
	assert_equal(json_get(fixture_clone, "bar", 2), "c", "10.2.2d: Clone not independent!");
	assert_equal(json_get(fixture_clone, "baz", "d"), "e", "10.2.2e: Clone not independent!");

	// Cleanup
	json_destroy(fixture);
	json_destroy(fixture_clone);




}
