/// @description json_test_load_save()

var fname = working_directory + "test.json";
var fixture = JsonStruct(JsonMap(
    "foo", "FOO",
    "bar", JsonList("a", "b", "c"),
    "baz", JsonMap("d", "e")
));
var f, got, expected;

// 13.1: Should save properly
json_save(fname, fixture);
f = file_text_open_read(fname);
assert_equal(file_text_read_string(f), json_encode(fixture), "13.1a: Didn't save properly!");
file_text_close(f);

// 13.2: Should load properly
got = json_load(fname);
assert_equal(got[? "foo"], "FOO", "13.2a: Didn't load properly!");
assert_equal(json_get(got, "bar", 0), "a", "13.2b: Didn't load properly!");
assert_equal(json_get(got, "bar", 1), "b", "13.2c: Didn't load properly!");
assert_equal(json_get(got, "bar", 2), "c", "13.2d: Didn't load properly!");
assert_equal(json_get(got, "baz", "d"), "e", "13.2e: Didn't load properly!");
json_destroy(got);

// Cleanup
file_delete(fname);
json_destroy(fixture);
