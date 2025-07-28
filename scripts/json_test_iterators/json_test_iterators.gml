/// @description json_test_iterators()
function json_test_iterators() {
    ///Feather disable GM2023

	// 12.1: Non-existent top layer
	var fixture = JsonStruct(JsonMap());
	assert_isnt_defined(json_iterate(-1, ds_type_map), "12.1a: Didn't catch nonsense!");
	assert_isnt_defined(json_iterate(-1, ds_type_list), "12.1b: Didn't catch nonsense!");
	assert_isnt_defined(json_iterate(fixture, ds_type_list), "12.1c: Didn't catch nonsense!");
	json_destroy(fixture);

	// 12.2: Top level is map
	fixture = JsonStruct(JsonMap(
	    "foo", "FOO",
	    "bar", JsonList("a", "b", "c"),
	    "baz", JsonMap("d", "e")
	));

	var expected, got, iterator, found_keys;

	// 12.2.1 Iterate top layer
	found_keys = "";
	iterator = json_iterate(fixture, ds_type_map);
	repeat (3) {
	    found_keys += iterator[JSONITER.KEY];
	    assert(json_has_next(iterator), "12.2.1a: Top layer should have more");
	    json_next(iterator);
	}
	assert_fail(json_has_next(iterator), "12.2.1b: Top layer should have no more");
	assert(found_keys == "foobarbaz" || found_keys == "foobazbar" || found_keys == "barfoobaz" || found_keys == "barbazfoo" || found_keys == "bazfoobar" || found_keys == "bazbarfoo", "12.2.1c: Top layer content wrong!");

	// 12.2.2 Iterate submap
	iterator = json_iterate(fixture, "baz", ds_type_map);
	assert_equal(iterator[JSONITER.KEY], "d");
	assert_equal(iterator[JSONITER.VALUE], "e");
	assert(json_has_next(iterator), "12.2.2a: Submap should have more");
	json_next(iterator);
	assert_equal(iterator[JSONITER.KEY], undefined);
	assert_equal(iterator[JSONITER.VALUE], undefined);
	assert_fail(json_has_next(iterator), "12.2.2b: Submap should have no more");

	// 12.2.3 Iterate sublist
	iterator = json_iterate(fixture, "bar", ds_type_list);
	assert_equal(iterator[JSONITER.KEY], 0);
	assert_equal(iterator[JSONITER.VALUE], "a");
	assert(json_has_next(iterator), "12.2.3a: Sublist should have more");
	json_next(iterator);
	assert_equal(iterator[JSONITER.KEY], 1);
	assert_equal(iterator[JSONITER.VALUE], "b");
	assert(json_has_next(iterator), "12.2.3b: Sublist should have more");
	json_next(iterator);
	assert_equal(iterator[JSONITER.KEY], 2);
	assert_equal(iterator[JSONITER.VALUE], "c");
	assert(json_has_next(iterator), "12.2.3c: Sublist should have more");
	json_next(iterator);
	assert_equal(iterator[JSONITER.KEY], 3);
	assert_equal(iterator[JSONITER.VALUE], undefined);
	assert_fail(json_has_next(iterator), "12.2.3d: Sublist should have no more");

	// 12.2.4 Live scenario tests
	got = "";
	for (var i = json_iterate(fixture, "bar", ds_type_list); json_has_next(i); json_next(i)) {
	    got += i[JSONITER.VALUE];
	}
	assert_equal(got, "abc", "12.2.4.1: Live list scenario failed!");
	got = "";
	for (var i = json_iterate(fixture, "baz", ds_type_map); json_has_next(i); json_next(i)) {
	    got += i[JSONITER.KEY]+":"+i[JSONITER.VALUE];
	}
	assert_equal(got, "d:e", "12.2.4.2: Live map scenario failed!");
	got = "";
	for (var i = json_iterate(fixture, ["bar"], ds_type_list); json_has_next(i); json_next(i)) {
	    got += i[JSONITER.VALUE];
	}
	assert_equal(got, "abc", "12.2.4.1 (alt): Live list scenario failed!");
	got = "";
	for (var i = json_iterate(fixture, ["baz"], ds_type_map); json_has_next(i); json_next(i)) {
	    got += i[JSONITER.KEY]+":"+i[JSONITER.VALUE];
	}
	assert_equal(got, "d:e", "12.2.4.2 (alt): Live map scenario failed!");

	// 12.3: Top level is list
	json_destroy(fixture);
	fixture = JsonStruct(JsonList(
	    "one", "two", "three", JsonMap("alpha", "beta"), JsonList("gamma", "delta")
	));

	// 12.3.1: Iterate top layer
	iterator = json_iterate(fixture, ds_type_list);
	assert_equal(iterator[JSONITER.KEY], 0, "12.3.1a: Top layer iteration key wrong!");
	assert_equal(iterator[JSONITER.VALUE], "one", "12.3.1b: Top layer iteration wrong!");
	assert(json_has_next(iterator), "12.3.1c: Top layer iteration should have more!");
	json_next(iterator);
	assert_equal(iterator[JSONITER.KEY], 1, "12.3.1d: Top layer iteration key wrong!");
	assert_equal(iterator[JSONITER.VALUE], "two", "12.3.1e: Top layer iteration wrong!");
	assert(json_has_next(iterator), "12.3.1f: Top layer iteration should have more!");
	json_next(iterator);
	assert_equal(iterator[JSONITER.KEY], 2, "12.3.1g: Top layer iteration key wrong!");
	assert_equal(iterator[JSONITER.VALUE], "three", "12.3.1h: Top layer iteration wrong!");
	assert(json_has_next(iterator), "12.3.1i: Top layer iteration should have more!");
	json_next(iterator);
	assert_equal(iterator[JSONITER.KEY], 3, "12.3.1j: Top layer iteration key wrong!");
	assert(ds_exists(iterator[JSONITER.VALUE], ds_type_map), "12.3.1k: Top layer iteration wrong!");
	assert(json_has_next(iterator), "12.3.1l: Top layer iteration should have more!");
	json_next(iterator);
	assert_equal(iterator[JSONITER.KEY], 4, "12.3.1m: Top layer iteration key wrong!");
	assert(ds_exists(iterator[JSONITER.VALUE], ds_type_list), "12.3.1n: Top layer iteration wrong!");
	assert(json_has_next(iterator), "12.3.1o: Top layer iteration should have more!");
	json_next(iterator);
	assert_equal(iterator[JSONITER.KEY], 5, "12.3.1p: Top layer iteration key wrong!");
	assert_equal(iterator[JSONITER.VALUE], undefined, "12.3.1q: Top layer iteration wrong!");
	assert_fail(json_has_next(iterator), "12.3.1r: Top layer iteration should be done!");

	// 12.3.2: Iterate submap
	iterator = json_iterate(fixture, 3, ds_type_map);
	assert_equal(iterator[JSONITER.KEY], "alpha", "12.3.2a: Submap iteration key wrong!");
	assert_equal(iterator[JSONITER.VALUE], "beta", "12.3.2b: Submap iteration wrong!");
	assert(json_has_next(iterator), "12.3.2c: Submap iteration should have more!");
	json_next(iterator);
	assert_equal(iterator[JSONITER.KEY], undefined, "12.3.2d: Submap iteration key wrong!");
	assert_equal(iterator[JSONITER.VALUE], undefined, "12.3.2e: Submap iteration wrong!");
	assert_fail(json_has_next(iterator), "12.3.2f: Submap iteration should be done!");

	// 12.3.3: Iterate sublist
	iterator = json_iterate(fixture, 4, ds_type_list);
	assert_equal(iterator[JSONITER.KEY], 0, "12.3.3a: Sublist iteration key wrong!");
	assert_equal(iterator[JSONITER.VALUE], "gamma", "12.3.3b: Sublist iteration wrong!");
	assert(json_has_next(iterator), "12.3.3c: Sublist iteration should have more!");
	json_next(iterator);
	assert_equal(iterator[JSONITER.KEY], 1, "12.3.3d: Sublist iteration key wrong!");
	assert_equal(iterator[JSONITER.VALUE], "delta", "12.3.3e: Sublist iteration wrong!");
	assert(json_has_next(iterator), "12.3.3f: Sublist iteration should have more!");
	json_next(iterator);
	assert_equal(iterator[JSONITER.KEY], 2, "12.3.3g: Sublist iteration key wrong!");
	assert_equal(iterator[JSONITER.VALUE], undefined, "12.3.3h: Sublist iteration wrong!");
	assert_fail(json_has_next(iterator), "12.3.3i: Sublist iteration should be done!");

	// 12.3.4: Live scenario tests
	got = "";
	for (var i = json_iterate(fixture, 3, ds_type_map); json_has_next(i); json_next(i)) {
	    got += i[JSONITER.KEY]+":"+i[JSONITER.VALUE];
	}
	assert_equal(got, "alpha:beta", "12.3.4.1: Live scenario failed!");
	got = "";
	for (var i = json_iterate(fixture, 4, ds_type_list); json_has_next(i); json_next(i)) {
	    got += i[JSONITER.VALUE];
	}
	assert_equal(got, "gammadelta", "12.3.4.2: Live scenario failed!");
	got = "";
	for (var i = json_iterate(fixture, [-2], ds_type_map); json_has_next(i); json_next(i)) {
	    got += i[JSONITER.KEY]+":"+i[JSONITER.VALUE];
	}
	assert_equal(got, "alpha:beta", "12.3.4.1 (alt): Live scenario failed!");
	got = "";
	for (var i = json_iterate(fixture, -1, ds_type_list); json_has_next(i); json_next(i)) {
	    got += i[JSONITER.VALUE];
	}
	assert_equal(got, "gammadelta", "12.3.4.2 (alt): Live scenario failed!");

	// Cleanup
	json_destroy(fixture);




}
