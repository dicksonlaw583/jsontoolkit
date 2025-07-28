///@func json_test_load_save_encrypted()
function json_test_load_save_encrypted() {

	var fname = working_directory + "test.xjson";
	var fixture = JsonStruct(JsonMap(
	    "foo", "FOO",
	    "bar", JsonList("a", "b", "c"),
	    "baz", JsonMap("d", "e")
	));
	var key = "defghi";
	var f, got, expected;


	// 14.1: RC4 should be sane
	expected = "foogoohoojoo";
	got = _json_rc4_encrypt_string(expected, key);
	assert_not_equal(got, expected, "14.1a: Ciphertext = Plaintext");
	assert_equal(_json_rc4_decrypt_string(got, key), expected, "14.1b: Round trip RC4 failed!");

	// 14.2: RC4 string encryption should be sane
	var encrypted = json_encrypt(fixture, key);
	got = json_decrypt(encrypted, key);
	assert_equal(got[? "foo"], "FOO", "14.2a: Didn't decrypt properly!");
	assert_equal(json_get(got, "bar", 0), "a", "14.2b: Didn't decrypt properly!");
	assert_equal(json_get(got, "bar", 1), "b", "14.2c: Didn't decrypt properly!");
	assert_equal(json_get(got, "bar", 2), "c", "14.2d: Didn't decrypt properly!");
	assert_equal(json_get(got, "baz", "d"), "e", "14.2e: Didn't decrypt properly!");
	json_destroy(got);

	// 14.3: Should save properly
	json_save_encrypted(fname, fixture, key);
	f = file_text_open_read(fname);
	assert_equal(file_text_read_string(f), json_encrypt(fixture, key), "14.3a: Didn't save properly!");
	file_text_close(f);


	// 14.4: Should load properly
	got = json_load_encrypted(fname, key);
	assert_equal(got[? "foo"], "FOO", "14.4a: Didn't load properly!");
	assert_equal(json_get(got, "bar", 0), "a", "14.4b: Didn't load properly!");
	assert_equal(json_get(got, "bar", 1), "b", "14.4c: Didn't load properly!");
	assert_equal(json_get(got, "bar", 2), "c", "14.4d: Didn't load properly!");
	assert_equal(json_get(got, "baz", "d"), "e", "14.4e: Didn't load properly!");
	json_destroy(got);

	// Cleanup
	file_delete(fname);
	json_destroy(fixture);


}
