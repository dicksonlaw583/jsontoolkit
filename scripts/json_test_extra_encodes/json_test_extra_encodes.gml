/// @description json_test_extra_encodes()
function json_test_extra_encodes() {

	var fixture = JsonStruct(JsonList(
	    "a", "b", JsonList("c"), JsonMap("d", "e")
	));

	// 1.1: Test simple encode list
	assert_equal(string_replace_all(json_encode_as_list(fixture), " ", ""), "[\"a\",\"b\",[\"c\"],{\"d\":\"e\"}]", "1.1.1: Simple list encode failed!");

	// Cleanup
	json_destroy(fixture);




}
