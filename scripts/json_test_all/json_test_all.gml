/// @description json_test_all()
// Getting started
var time_start = current_time;

// Tests
json_test_extra_encodes();
json_test_extras();
json_test_get();
json_test_exists();
json_test_set();
json_test_set_nested();
json_test_insert();
json_test_insert_nested();
json_test_unset();
json_test_clone();
json_test_destroy();
json_test_iterators();
json_test_load_save();

// Done
var time_message = "JSON Toolkit tests completed in " + string(current_time-time_start) + "ms.";
if (os_browser == browser_not_a_browser) {
    show_debug_message(time_message);
} else {
    show_message(time_message);
}

