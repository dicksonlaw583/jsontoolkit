/// @description json_test_destroy()
function json_test_destroy() {
    ///Feather disable GM2023
	var fixture = JsonStruct(JsonMap(
	    "foo", "FOO",
	    "bar", JsonList("a", "b", "c"),
	    "baz", JsonMap("d", "e")
	));

	// 11.1: Test non-existence
	var bar = fixture[? "bar"],
	    baz = fixture[? "baz"];
	json_destroy(fixture);
	assert_fail(ds_exists(fixture, ds_type_map), "11.1a: Top layer not cleaned!");
	assert_fail(ds_exists(bar, ds_type_list), "11.1b: Sublist not cleaned!");
	assert_fail(ds_exists(baz, ds_type_map), "11.1c: Submap not cleaned!");




}
