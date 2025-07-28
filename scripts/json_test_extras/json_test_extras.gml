/// @description json_test_extras()
function json_test_extras() {
    ///Feather disable GM2023
	var expected, got, row, subentries;

	// 2.1: JSON map
	got = JsonStruct(JsonMap(
	    "abc", 9,
	    "def", "foobar"
	));
	assert_equal(ds_map_size(got), 2, "2.1.1: JSON map size wrong!");
	assert_equal(got[? "abc"], 9, "2.1.2: JSON map abc value wrong!");
	assert_equal(got[? "def"], "foobar", "2.1.3: JSON map def value wrong!");
	ds_map_destroy(got);

	// 2.2: JSON list
	got = JsonStruct(
	    JsonList("abc", 9, undefined, "waahoo")
	);
	assert_equal(ds_map_size(got), 1, "2.2.1: JSON list has wrong size in wrapper!");
	assert(ds_map_exists(got, "default"), "2.2.2: JSON list has wrong wrapper!");
	row = got[? "default"];
	assert_equal(ds_list_size(row), 4, "2.2.3: JSON list has wrong size!");
	assert_equal(row[| 0], "abc", "2.2.4: JSON list has wrong content 0!");
	assert_equal(row[| 1], 9, "2.2.5: JSON list has wrong content 1!");
	assert_equal(row[| 2], undefined, "2.2.6: JSON list has wrong content 2!");
	assert_equal(row[| 3], "waahoo", "2.2.7: JSON list has wrong content 3!");
	ds_map_destroy(got);

	// 2.3 Nested mashup
	got = JsonStruct(JsonMap(
	    "abc", JsonList(5, "ab", undefined),
	    "bcd", JsonMap("cd", "ef")
	));
	row = got[? "abc"];
	subentries[0] = row;
	assert_equal(ds_list_size(row), 3, "2.3.1: Nested mashup has wrong abc size!");
	assert_equal(row[| 0], 5, "2.3.2: Nested mashup missing abc content!");
	assert_equal(row[| 1], "ab", "2.3.3: Nested mashup missing abc content!");
	assert_equal(row[| 2], undefined, "2.3.4: Nested mashup missing abc content!");
	row = got[? "bcd"];
	subentries[1] = row;
	assert_equal(ds_map_size(row), 1, "2.3.5: Nested mashup has wrong bcd size!");
	assert_equal(row[? "cd"], "ef", "2.3.6: Nested mashup missing bcd content!");
	ds_map_destroy(got);
	if (os_browser == browser_not_a_browser) {
	    assert_fail(ds_exists(got, ds_type_map), "2.3.7: Nested mashup is leaky!");
	    assert_fail(ds_exists(subentries[0], ds_type_list), "2.3.8: Nested mashup has leaky sublist!");
	    assert_fail(ds_exists(subentries[1], ds_type_map), "2.3.9: Nested mashup has leaky submap!");
	}




}
