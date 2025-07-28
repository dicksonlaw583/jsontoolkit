#define JsonStruct
/// @description JsonStruct(source)
/// @param source
// JsonStruct("filename"): Load JSON data from file
if (is_string(argument0)) {
    var f = file_text_open_read(argument0),
        jsonstr = "";
    while (!file_text_eof(f)) {
        jsonstr += file_text_read_string(f);
        file_text_readln(f);
    }
    file_text_close(f);
    return json_decode(jsonstr);
}
// JsonStruct(constructor): Return the data part of the given constructor helper
else if (is_array(argument0)) {
    switch (argument0[1]) {
        case ds_type_map: return argument0[0];
        case ds_type_list:
            var m = ds_map_create();
            ds_map_add_list(m, "default", argument0[0]);
            return m;
        default:
            show_error("Invalid source constructor.", true);
    }
}
// Unrecognized
else {
    show_error("Invalid source type.", true);
}

#define JsonList
/// @description JsonList(...)
/// @param ...
var tuple, list, value;
list = ds_list_create();
tuple[1] = ds_type_list;
tuple[0] = list;
for (var i = 0; i < argument_count; i++) {
    value = argument[i];
    if (is_array(value)) {
        switch (value[1]) {
            case ds_type_map:
                ds_list_add(list, value[0]);
                ds_list_mark_as_map(list, i);
                break;
            case ds_type_list:
                ds_list_add(list, value[0]);
                ds_list_mark_as_list(list, i);
                break;
            default:
                show_error("Invalid value " + string(i) + " for JSON list constructor.", true);
        }
    } else {
        ds_list_add(list, value);
    }
}
return tuple;

#define JsonMap
/// @description JsonMap(...)
/// @param ...
if (argument_count mod 2 != 0) {
    show_error("Expected an even number of arguments, got " + string(argument_count) + ".", true);
}
var tuple, map, key, value;
map = ds_map_create();
tuple[1] = ds_type_map;
tuple[0] = map;
for (var i = 0; i < argument_count; i += 2) {
    key = argument[i];
    value = argument[i+1];
    if (is_array(value)) {
        switch (value[1]) {
            case ds_type_map:
                ds_map_add_map(map, key, value[0]);
                break;
            case ds_type_list:
                ds_map_add_list(map, key, value[0]);
                break;
            default:
                show_error("Invalid value pair " + string(i >> 1) + " for JSON map constructor.", true);
        }
    } else {
        ds_map_add(map, key, value);
    }
}
return tuple;

#define json_exists
/// @description json_exists(jsonstruct, ...)
/// @param jsonstruct
/// @param  ...
if (argument_count == 0) {
    show_error("Expected at least 1 argument, got " + string(argument_count) + ".", true);
}
// Build the seek path
var path = array_create(argument_count),
    pc = 1;
for (var i = 1; i < argument_count; i++) {
    var argi = argument[i];
    if (is_array(argi)) {
        var jsize = array_length_1d(argi);
        for (var j = 0; j < jsize; j++) {
            path[pc++] = argi[j];
        }
    } else {
        path[pc++] = argi;
    }
}
// Return the path validity marker from _json_dig
_json_dig(argument[0], path, 0);
return path[0];

#define json_encode_as_list
/// @description json_encode_as_list(jsonstruct)
/// @param jsonstruct
// Encode first
var jsonstr = json_encode(argument0);
// Find opening [
var opening_pos = string_pos("[", jsonstr);
// Find closing ]
for (var closing_pos = string_length(jsonstr); closing_pos > opening_pos; closing_pos--) {
    if (string_char_at(jsonstr, closing_pos) == "]") break;
}
// Return trimmed encode if valid
if (opening_pos >= 12 && opening_pos < closing_pos) {
    return string_copy(jsonstr, opening_pos, closing_pos-opening_pos+1);
}
return "";

#define json_get
/// @description json_get(jsonconstruct, ...)
/// @param jsonconstruct
/// @param  ...
if (argument_count == 0) {
    show_error("Expected at least 1 argument, got " + string(argument_count) + ".", true);
}
// Build the seek path
var path = array_create(argument_count),
    pc = 1;
for (var i = 1; i < argument_count; i++) {
    var argi = argument[i];
    if (is_array(argi)) {
        var jsize = array_length_1d(argi);
        for (var j = 0; j < jsize; j++) {
            path[pc++] = argi[j];
        }
    } else {
        path[pc++] = argi;
    }
}
// Return the result of _json_dig
return _json_dig(argument[0], path, 0);

#define json_set
/// @description json_set(@jsonstruct, ..., value)
/// @param @jsonstruct
/// @param  ...
/// @param  value
if (argument_count < 3) {
    show_error("Expected at least 3 arguments, got " + string(argument_count) + ".", true);
}
// Build the seek path
var path = array_create(argument_count-1),
    pc = 0;
for (var i = 1; i < argument_count-1; i++) {
    var argi = argument[i];
    if (is_array(argi)) {
        var jsize = array_length_1d(argi);
        for (var j = 0; j < jsize; j++) {
            path[++pc] = argi[j];
        }
    } else {
        path[++pc] = argi;
    }
}
// Special: Dig at least to default if only path value is real
var single_real_path = pc == 1 && is_real(path[1]);
if (single_real_path) {
    path[2] = path[1];
    path[1] = "default";
    pc = 2;
}
// Stop if _json_dig() errors out
var current = _json_dig(argument[0], path, 1);
if (path[0] <= 0) {
    return path[0];
}
// Attempt to set the target
var k = path[pc];
if (is_string(k) && !_json_not_ds(current, ds_type_map)) {
    current[? k] = argument[argument_count-1];
} else if (is_real(k) && !_json_not_ds(current, ds_type_list)) {
    if (k < 0) {
        k += ds_list_size(current);
        if (k < 0) {
            if (single_real_path) {
                return -1;
            }
            return -pc;
        }
    }
    current[| k] = argument[argument_count-1];
} else {
    if (single_real_path) {
        return -1;
    }
    return -pc;
}
// Success!
return 1;

#define json_set_nested
/// @description json_set_nested(@jsonstruct, ..., jsonsubdata)
/// @param @jsonstruct
/// @param  ...
/// @param  jsonsubdata
if (argument_count < 3) {
    show_error("Expected at least 3 arguments, got " + string(argument_count) + ".", true);
}
// Build the seek path
var path = array_create(argument_count-1),
    pc = 0;
for (var i = 1; i < argument_count-1; i++) {
    var argi = argument[i];
    if (is_array(argi)) {
        var jsize = array_length_1d(argi);
        for (var j = 0; j < jsize; j++) {
            path[++pc] = argi[j];
        }
    } else {
        path[++pc] = argi;
    }
}
// Special: Dig at least to default if only path value is real
var single_real_path = pc == 1 && is_real(path[1]);
if (single_real_path) {
    path[2] = path[1];
    path[1] = "default";
    pc = 2;
}
// Stop if _json_dig() errors out
var current = _json_dig(argument[0], path, 1);
if (path[0] <= 0) {
    return path[0];
}
// Check type of subdata
var to_nest = argument[argument_count-1],
    nested_is_list = ds_map_size(to_nest) == 1 && ds_map_exists(to_nest, "default");
// Set the last layer and go
var k = path[pc];
if (is_string(k) && !_json_not_ds(current, ds_type_map)) {
    if (nested_is_list) {
        ds_map_add_list(current, k, to_nest[? "default"]);
    } else {
        ds_map_add_map(current, k, to_nest);
    }
} else if (is_real(k) && !_json_not_ds(current, ds_type_list)) {
    if (k < 0) {
        k += ds_list_size(current);
        if (k < 0) {
            if (single_real_path) {
                return -1;
            }
            return -pc;
        }
    }
    if (nested_is_list) {
        current[| k] = to_nest[? "default"];
        ds_list_mark_as_list(current, k);
    } else {
        current[| k] = to_nest;
        ds_list_mark_as_map(current, k);
    }
} else {
    if (single_real_path) {
        return -1;
    }
    return -pc;
}
// Success!
return 1;

#define json_insert
/// @description json_insert(@jsonstruct, ..., value)
/// @param @jsonstruct
/// @param  ...
/// @param  value
if (argument_count < 3) {
    show_error("Expected at least 3 arguments, got " + string(argument_count) + ".", true);
}
// Build the seek path
var path = array_create(argument_count-1),
    pc = 0;
for (var i = 1; i < argument_count-1; i++) {
    var argi = argument[i];
    if (is_array(argi)) {
        var jsize = array_length_1d(argi);
        for (var j = 0; j < jsize; j++) {
            path[++pc] = argi[j];
        }
    } else {
        path[++pc] = argi;
    }
}
// Special: Dig at least to default if only path value is real
var single_real_path = pc == 1 && (is_real(path[1]) || is_undefined(path[1]));
if (single_real_path) {
    path[2] = path[1];
    path[1] = "default";
    pc = 2;
}
// Stop if _json_dig() errors out
var current = _json_dig(argument[0], path, 1);
if (path[0] <= 0) {
    return path[0];
}
// Insert at the last layer and go
var k = path[pc];
if (is_string(k) && !_json_not_ds(current, ds_type_map)) {
    current[? k] = argument[argument_count-1];
    return 1;
} else if (!_json_not_ds(current, ds_type_list)) {
    if (is_real(k)) {
        if (k < 0) {
            k += ds_list_size(current);
            if (k < 0) {
                if (single_real_path) {
                    return -1;
                }
                return -pc;
            }
        }
        ds_list_insert(current, k, argument[argument_count-1]);
        return 1;
    } else if (is_undefined(k)) {
        ds_list_add(current, argument[argument_count-1]);
        return 1;
    }
}
// None of the inserts work
if (single_real_path) {
    return -1;
}
return -pc;

#define json_insert_nested
/// @description json_insert_nested(@jsonstruct, ..., jsonsubdata)
/// @param @jsonstruct
/// @param  ...
/// @param  jsonsubdata
if (argument_count < 3) {
    show_error("Expected at least 3 arguments, got " + string(argument_count) + ".", true);
}
var current = argument[0];
// Build the seek path
var path = array_create(argument_count-1),
    pc = 0;
for (var i = 1; i < argument_count-1; i++) {
    var argi = argument[i];
    if (is_array(argi)) {
        var jsize = array_length_1d(argi);
        for (var j = 0; j < jsize; j++) {
            path[++pc] = argi[j];
        }
    } else {
        path[++pc] = argi;
    }
}
// Special: Dig at least to default if only path value is real or undefined
var single_real_path = pc == 1 && (is_real(path[1]) || is_undefined(path[1]));
if (single_real_path) {
    path[2] = path[1];
    path[1] = "default";
    pc = 2;
}
// Stop if _json_dig() errors out
var current = _json_dig(argument[0], path, 1);
if (path[0] <= 0) {
    return path[0];
}
// Check type of subdata
var to_nest = argument[argument_count-1],
    nested_is_list = ds_map_size(to_nest) == 1 && ds_map_exists(to_nest, "default");
// Set the last layer and go
var k = path[pc];
if (is_string(k) && !_json_not_ds(current, ds_type_map)) {
    if (nested_is_list) {
        ds_map_add_list(current, k, to_nest[? "default"]);
    } else {
        ds_map_add_map(current, k, to_nest);
    }
    return 1;
} else if (!_json_not_ds(current, ds_type_list)) {
    if (is_real(k)) {
        if (k < 0) {
            k += ds_list_size(current);
            if (k < 0) {
                if (single_real_path) {
                    return -1;
                }
                return -pc;
            }
        }
        if (nested_is_list) {
            ds_list_insert(current, k, ds_map_find_value(to_nest, "default"));
        } else {
            ds_list_insert(current, k, to_nest);
        }
    } else if (is_undefined(k)) {
        k = ds_list_size(current);
        if (nested_is_list) {
            ds_list_add(current, ds_map_find_value(argument[argument_count-1], "default"));
        } else {
            ds_list_add(current, argument[argument_count-1]);
        }
    } else {
        if (single_real_path) {
            return -1;
        }
        return -pc;
    }
    if (nested_is_list) {
        ds_list_mark_as_list(current, k);
    } else {
        ds_list_mark_as_map(current, k);
    }
    return 1;
}
// None of the inserts work
if (single_real_path) {
    return -1;
}
return -pc;

#define json_unset
/// @description json_unset(@jsonstruct, ...)
/// @param @jsonstruct
/// @param  ...
if (argument_count < 2) {
    show_error("Expected at least 2 arguments, got " + string(argument_count) + ".", true);
}
// Build the seek path
var path = array_create(argument_count),
    pc = 0;
for (var i = 1; i < argument_count; i++) {
    var argi = argument[i];
    if (is_array(argi)) {
        var jsize = array_length_1d(argi);
        for (var j = 0; j < jsize; j++) {
            path[++pc] = argi[j];
        }
    } else {
        path[++pc] = argi;
    }
}
// Special: Dig at least to default if only path value is real
var single_real_path = pc == 1 && is_real(path[1]);
if (single_real_path) {
    path[2] = path[1];
    path[1] = "default";
    pc = 2;
}
// Stop if _json_dig() errors out
var current = _json_dig(argument[0], path, 1);
if (path[0] <= 0) {
    return path[0];
}
// Set the last layer and go
var k = path[pc];
if (is_string(k) && !_json_not_ds(current, ds_type_map)) {
    if (ds_map_exists(current, k)) {
        ds_map_delete(current, k);
        return 1;
    }
} else if (is_real(k) && !_json_not_ds(current, ds_type_list)) {
    var current_list_size = ds_list_size(current);
    if (k >= 0 && k < current_list_size) {
        ds_list_delete(current, k);
        return 1;
    }
    if (k < 0 && k >= -current_list_size) {
        ds_list_delete(current, k+current_list_size);
        return 1;
    }
}
// Unset attempt failed
if (single_real_path) {
    return -1;
}
return -pc;

#define json_clone
/// @description json_clone(jsonstruct)
/// @param jsonstruct
return json_decode(json_encode(argument0));

#define json_destroy
/// @description json_destroy(@jsonstruct)
/// @param @jsonstruct
ds_map_destroy(argument0);

#define json_load
/// @description json_load(fname)
/// @param fname
if (file_exists(argument0)) {
    var f = file_text_open_read(argument0),
        jsonstr = "";
    while (!file_text_eof(f)) {
        jsonstr += file_text_read_string(f);
        file_text_readln(f);
    }
    file_text_close(f);
    return json_decode(jsonstr);
}
return undefined;

#define json_save
/// @description json_save(fname, jsonstruct)
/// @param fname
/// @param  jsonstruct
var f = file_text_open_write(argument0);
if (ds_map_exists(argument1, "default") && !_json_not_ds(argument1[? "default"], ds_type_list)) {
    file_text_write_string(f, json_encode_as_list(argument1));
} else {
    file_text_write_string(f, json_encode(argument1));
}
file_text_close(f);

#define json_iterate
/// @description json_iterate(jsonstruct, ..., type)
/// @param jsonstruct
/// @param  ...
/// @param  type
if (argument_count < 2) {
    show_error("Expected at least 2 arguments, got " + string(argument_count) + ".", true);
}
enum JSONITER {
    VALUE,
    KEY,
    DS
}
// Build the seek path
var path = array_create(argument_count-1),
    pc = 0;
for (var i = 1; i < argument_count-1; i++) {
    var argi = argument[i];
    if (is_array(argi)) {
        var jsize = array_length_1d(argi);
        for (var j = 0; j < jsize; j++) {
            path[++pc] = argi[j];
        }
    } else {
        path[++pc] = argi;
    }
}
// Special: Dig at least to default if only path value is real
var single_real_path = pc == 1 && is_real(path[1]);
if (single_real_path) {
    path[2] = path[1];
    path[1] = "default";
    pc = 2;
}
// Stop if _json_dig() errors out
var ds = _json_dig(argument[0], path, 0);
if (path[0] <= 0) {
    return undefined;
}
// Create the iterator
var iterator = array_create(3);
iterator[JSONITER.DS] = ds;
if (_json_not_ds(ds, ds_type_map)) return undefined;
if (pc >= 1) {
    switch (argument[argument_count-1]) {
        case ds_type_map:
            if (ds_map_empty(ds)) {
                iterator[JSONITER.VALUE] = undefined;
                iterator[JSONITER.KEY] = undefined;
            } else {
                var k = ds_map_find_first(ds);
                iterator[JSONITER.KEY] = k;
                iterator[JSONITER.VALUE] = ds[? k];
            }
            break;
        case ds_type_list:
            iterator[JSONITER.KEY] = 0;
            if (ds_list_empty(ds)) {
                iterator[JSONITER.VALUE] = undefined;
            } else {
                iterator[JSONITER.VALUE] = ds[| 0];
            }
            break;
        default:
            show_error("Invalid iteration type.", true);
    }
} else {
    switch (argument[argument_count-1]) {
        case ds_type_map:
            iterator[JSONITER.DS] = ds;
            if (ds_map_empty(ds)) {
                iterator[JSONITER.VALUE] = undefined;
                iterator[JSONITER.KEY] = undefined;
            } else {
                var k = ds_map_find_first(ds);
                iterator[JSONITER.KEY] = k;
                iterator[JSONITER.VALUE] = ds[? k];
            }
            break;
        case ds_type_list:
            if (!ds_map_exists(ds, "default")) return undefined;
            ds = ds[? "default"];
            if (_json_not_ds(ds, ds_type_list)) return undefined;
            iterator[JSONITER.DS] = ds;
            iterator[JSONITER.KEY] = 0;
            if (ds_list_empty(ds)) {
                iterator[JSONITER.VALUE] = undefined;
            } else {
                iterator[JSONITER.VALUE] = ds[| 0];
            }
            break;
        default:
            show_error("Invalid iteration type.", true);
    }
}
return iterator;

#define json_has_next
/// @description json_has_next(jsoniterator)
/// @param jsoniterator
if (!is_array(argument0) || is_undefined(argument0[JSONITER.KEY])) return false;
var k = argument0[JSONITER.KEY];
if (is_real(k)) return k < ds_list_size(argument0[JSONITER.DS]);
if (is_string(k)) return ds_map_exists(argument0[JSONITER.DS], k);
show_error("Unexpected error when iterating: " + string(argument0), true);

#define json_next
/// @description json_next(@jsoniterator)
/// @param @jsoniterator
if (!is_array(argument0) || is_undefined(argument0[JSONITER.KEY])) return false;
var k = argument0[JSONITER.KEY];
if (is_real(k)) {
    if (++argument0[@JSONITER.KEY] < ds_list_size(argument0[JSONITER.DS])) {
        argument0[@JSONITER.VALUE] = ds_list_find_value(argument0[JSONITER.DS], argument0[JSONITER.KEY]);
    } else {
        argument0[@JSONITER.VALUE] = undefined;
    }
} else if (is_string(k)) {
    argument0[@JSONITER.KEY] = ds_map_find_next(argument0[JSONITER.DS], k);
    if (is_undefined(argument0[JSONITER.KEY])) {
        argument0[@JSONITER.VALUE] = undefined;
    } else {
        argument0[@JSONITER.VALUE] = ds_map_find_value(argument0[JSONITER.DS], argument0[JSONITER.KEY]);
    }
} else {
    show_error("Unexpected error when iterating: " + string(argument0), true);
}

#define _json_not_ds
gml_pragma("forceinline");
try {
    return !ds_exists(argument0, argument1);
} catch (_) {
    return true;
}

#define _json_dig
/// @description _json_dig(jsonstruct, @seekpath, ignore_last_n)
/// @param jsonstruct
/// @param  @seekpath
/// @param  ignore_last_n
//seekpath is always [blank, ...<path>...]; first slot will receive a status from this function
var current = argument0,
    path = argument1,
    ignore_last = argument2,
    spsiz = array_length_1d(path)-ignore_last;
// Check existence of top
if (_json_not_ds(current, ds_type_map)) {
    path[@ 0] = 0;
    return undefined;
}
// If path is "empty", return the top
if (spsiz <= 1) {
  path[@ 0] = 1;
  return current;
}
// Check existence of first layer
var k = path[1];
if (is_string(k)) {
    if (!ds_map_exists(current, k)) {
        path[@ 0] = -1;
        return undefined;
    }
    current = current[? k];
} else if (is_real(k)) {
    if (!ds_map_exists(current, "default")) {
        path[@ 0] = -1;
        return undefined;
    }
    current = current[? "default"];
    if (_json_not_ds(current, ds_type_list)) {
        path[@ 0] = -1;
        return undefined;
    }
    var current_list_size = ds_list_size(current);
    if (k >= current_list_size || k < -current_list_size) {
        path[@ 0] = -1;
        return undefined;
    }
    if (k < 0) {
      k += current_list_size;
    }
    current = current[| k];
} else {
    path[@ 0] = -1;
    return undefined;
}
// Check existence of subsequent layers
for (var i = 2; i < spsiz; i++) {
    k = path[i];
    if (is_string(k)) {
        if (_json_not_ds(current, ds_type_map) || !ds_map_exists(current, k)) {
           path[@ 0] = -i;
           return undefined;
        }
        current = current[? k];
    } else if (is_real(k)) {
        if (_json_not_ds(current, ds_type_list)) {
           path[@ 0] = -i;
           return undefined;
        }
        var current_list_size = ds_list_size(current);
        if (k >= current_list_size || k < -current_list_size) {
           path[@ 0] = -i;
           return undefined;
        }
        if (k < 0) {
            k += current_list_size;
        }
        current = current[| k];
    } else {
        path[@ 0] = -i;
        return undefined;
    }
}
// Mark the path as OK
path[@ 0] = 1;
// Return dig result
return current;

#define _json_rc4
///@func _json_rc4(@buffer, key, offset, length)
///@param buffer
///@param key
///@param offset
///@param length

var i, j, s, temp, keyLength, pos;
s = array_create(256);
keyLength = string_byte_length(argument1);
for (var i = 255; i >= 0; --i) {
	s[i] = i;
}
j = 0;
for (var i = 0; i <= 255; ++i) {
	j = (j + s[i] + string_byte_at(argument1, i mod keyLength)) mod 256;
	temp = s[i];
	s[i] = s[j];
	s[j] = temp;
}
i = 0;
j = 0;
pos = 0;
buffer_seek(argument0, buffer_seek_start, argument2);
repeat (argument3) {
	i = (i+1) mod 256;
	j = (j+s[i]) mod 256;
	temp = s[i];
	s[i] = s[j];
	s[j] = temp;
	var currentByte = buffer_peek(argument0, pos++, buffer_u8);
	buffer_write(argument0, buffer_u8, s[(s[i]+s[j]) mod 256] ^ currentByte);
}
return argument0;

#define _json_rc4_decrypt_string
///@func _json_rc4_decrypt_string(str, key)
///@param str
///@param key
var buffer = buffer_base64_decode(argument0);
_json_rc4(buffer, argument1, 0, buffer_get_size(buffer));
buffer_seek(buffer, buffer_seek_start, 0);
var decoded = buffer_read(buffer, buffer_string);
buffer_delete(buffer);
return decoded;

#define _json_rc4_encrypt_string
///@func _json_rc4_encrypt_string(str, key)
///@param str
///@param key
var length = string_byte_length(argument0);
var buffer = buffer_create(length+1, buffer_fixed, 1);
buffer_write(buffer, buffer_string, argument0);
_json_rc4(buffer, argument1, 0, buffer_tell(buffer));
var encoded = buffer_base64_encode(buffer, 0, length);
buffer_delete(buffer);
return encoded;

#define json_encrypt
///@func json_encrypt(jsonstruct, key)
///@param jsonstruct
///@param key
return _json_rc4_encrypt_string(json_encode(argument0), argument1);

#define json_decrypt
///@func json_decrypt(jsonencstr, key)
///@param jsonencstr
///@param key
return json_decode(_json_rc4_decrypt_string(argument0, argument1));

#define json_save_encrypted
///@func json_save_encrypted(fname, jsonstruct, key)
///@param fname
///@param jsonstruct
///@param key
var f = file_text_open_write(argument0);
file_text_write_string(f, json_encrypt(argument1, argument2));
file_text_close(f);

#define json_load_encrypted
///@func json_load_encrypted(fname, key)
///@param fname
///@param key
var f = file_text_open_read(argument0);
var ciphertext = file_text_read_string(f);
file_text_close(f);
return json_decrypt(ciphertext, argument1);
