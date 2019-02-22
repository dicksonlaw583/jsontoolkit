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
var current = argument[0];
// Check existence of root
if (_json_not_ds(current, ds_type_map)) return 0;
// No need to check further if no path
if (argument_count == 1) return 1;
// Check existence of first layer
var k = argument[1];
if (is_string(k)) {
    if (!ds_map_exists(current, k)) return -1;
    current = current[? k];
} else if (is_real(k)) {
    if (!ds_map_exists(current, "default")) return -1;
    current = current[? "default"];
    if (_json_not_ds(current, ds_type_list) || k >= ds_list_size(current)) return -1;
    current = current[| k];
} else {
    return -1;
}
// Check existence of subsequent layers
for (var i = 2; i < argument_count; i++) {
    k = argument[i];
    if (is_string(k)) {
        if (_json_not_ds(current, ds_type_map) || !ds_map_exists(current, k)) return -i;
        current = current[? k];
    } else if (is_real(k)) {
        if (_json_not_ds(current, ds_type_list) || k >= ds_list_size(current)) return -i;
        current = current[| k];
    } else {
        return -1;
    }
}
// All layers exist, must be valid
return 1;

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
var current = argument[0];
// Check existence of root
if (_json_not_ds(current, ds_type_map)) return undefined;
// No need to check further if no path
if (argument_count == 1) return current;
// Check existence of first layer
var k = argument[1];
if (is_string(k)) {
    if (!ds_map_exists(current, k)) return undefined;
    current = current[? k];
} else if (is_real(k)) {
    if (!ds_map_exists(current, "default")) return undefined;
    current = current[? "default"];
    if (_json_not_ds(current, ds_type_list) || k >= ds_list_size(current)) return undefined;
    current = current[| k];
} else {
    return undefined;
}
// Check existence of subsequent layers
for (var i = 2; i < argument_count; i++) {
    k = argument[i];
    if (is_string(k)) {
        if (_json_not_ds(current, ds_type_map) || !ds_map_exists(current, k)) return undefined;
        current = current[? k];
    } else if (is_real(k)) {
        if (_json_not_ds(current, ds_type_list) || k >= ds_list_size(current)) return undefined;
        current = current[| k];
    } else {
        return undefined;
    }
}
// All layers exist, must be valid
return current;

#define json_set
/// @description json_set(@jsonstruct, ..., value)
/// @param @jsonstruct
/// @param  ...
/// @param  value
if (argument_count < 3) {
    show_error("Expected at least 3 arguments, got " + string(argument_count) + ".", true);
}
var current = argument[0];
// Check existence of root
if (_json_not_ds(current, ds_type_map)) return 0;
// Check existence of first layer
var k = argument[1];
if (is_string(k)) {
    if (argument_count == 3) {
        current[? k] = argument[2];
        return 1;
    }
    if (!ds_map_exists(current, k)) {
        return -1;
    }
    current = current[? k];
} else if (is_real(k)) {
    if (!ds_map_exists(current, "default")) return -1;
    current = current[? "default"];
    if (_json_not_ds(current, ds_type_list)) return -1;
    if (argument_count == 3) {
        current[| k] = argument[2];
        return 1;
    }
    if (k >= ds_list_size(current)) {
        return -1;
    }
    current = current[| k];
} else {
    return -1;
}
// Check existence of subsequent layers
for (var i = 2; i < argument_count-1; i++) {
    k = argument[i];
    if (is_string(k)) {
        if (_json_not_ds(current, ds_type_map) || (!ds_map_exists(current, k) && i < argument_count-2)) return -i;
        if (i < argument_count-2) {
            current = current[? k];
        }
    } else if (is_real(k)) {
        if (_json_not_ds(current, ds_type_list) || (k >= ds_list_size(current) && i < argument_count-2)) return -i;
        if (i < argument_count-2) {
            current = current[| k];
        }
    } else {
        return -1;
    }
}
// Set the last layer and go
if (is_string(k)) {
    current[? k] = argument[argument_count-1];
} else {
    current[| k] = argument[argument_count-1];
}
return 1;

#define json_set_nested
/// @description json_set_nested(@jsonstruct, ..., jsonsubdata)
/// @param @jsonstruct
/// @param  ...
/// @param  jsonsubdata
if (argument_count < 3) {
    show_error("Expected at least 3 arguments, got " + string(argument_count) + ".", true);
}
var current = argument[0];
// Check existence of root
if (_json_not_ds(current, ds_type_map)) return 0;
// Check type of subdata
var to_nest = argument[argument_count-1],
    nested_is_list = ds_map_size(to_nest) == 1 && ds_map_exists(to_nest, "default");
// Check existence of first layer
var k = argument[1];
if (is_string(k)) {
    if (argument_count == 3) {
        if (nested_is_list) {
            ds_map_add_list(current, k, to_nest[? "default"]);
        } else {
            ds_map_add_map(current, k, to_nest);
        }
        return 1;
    }
    if (!ds_map_exists(current, k)) {
        return -1;
    }
    current = current[? k];
} else if (is_real(k)) {
    if (!ds_map_exists(current, "default")) return -1;
    current = current[? "default"];
    if (_json_not_ds(current, ds_type_list)) return -1;
    if (argument_count == 3) {
        if (nested_is_list) {
            current[| k] = to_nest[? "default"];
            ds_list_mark_as_list(current, k);
        } else {
            current[| k] = to_nest;
            ds_list_mark_as_map(current, k);
        }
        return 1;
    }
    if (k >= ds_list_size(current)) {
        return -1;
    }
    current = current[| k];
} else {
    return -1;
}
// Check existence of subsequent layers
for (var i = 2; i < argument_count-1; i++) {
    k = argument[i];
    if (is_string(k)) {
        if (_json_not_ds(current, ds_type_map) || (!ds_map_exists(current, k) && i < argument_count-2)) return -i;
        if (i < argument_count-2) {
            current = current[? k];
        }
    } else if (is_real(k)) {
        if (_json_not_ds(current, ds_type_list) || (k >= ds_list_size(current) && i < argument_count-2)) return -i;
        if (i < argument_count-2) {
            current = current[| k];
        }
    } else {
        return -1;
    }
}
// Set the last layer and go
if (is_string(k)) {
    if (nested_is_list) {
        ds_map_add_list(current, k, to_nest[? "default"]);
    } else {
        ds_map_add_map(current, k, to_nest);
    }
} else {
    if (nested_is_list) {
        current[| k] = to_nest[? "default"];
        ds_list_mark_as_list(current, k);
    } else {
        current[| k] = to_nest;
        ds_list_mark_as_map(current, k);
    }
}
return 1;

#define json_insert
/// @description json_insert(@jsonstruct, ..., value)
/// @param @jsonstruct
/// @param  ...
/// @param  value
if (argument_count < 3) {
    show_error("Expected at least 3 arguments, got " + string(argument_count) + ".", true);
}
var current = argument[0];
// Check existence of root
if (_json_not_ds(current, ds_type_map)) return 0;
// Check existence of first layer
var k = argument[1];
if (is_string(k)) {
    if (argument_count == 3) {
        current[? k] = argument[2];
        return 1;
    }
    if (!ds_map_exists(current, k)) {
        return -1;
    }
    current = current[? k];
} else if (is_real(k)) {
    if (!ds_map_exists(current, "default")) return -1;
    current = current[? "default"];
    if (_json_not_ds(current, ds_type_list)) return -1;
    if (argument_count == 3) {
        ds_list_insert(current, k, argument[2]);
        return 1;
    }
    if (k >= ds_list_size(current)) {
        return -1;
    }
    current = current[| k];
} else {
    return -1;
}
// Check existence of subsequent layers
for (var i = 2; i < argument_count-1; i++) {
    k = argument[i];
    if (is_string(k)) {
        if (_json_not_ds(current, ds_type_map) || (!ds_map_exists(current, k) && i < argument_count-2)) return -i;
        if (i < argument_count-2) {
            current = current[? k];
        }
    } else if (is_real(k)) {
        if (_json_not_ds(current, ds_type_list) || (k >= ds_list_size(current) && i < argument_count-2)) return -i;
        if (i < argument_count-2) {
            current = current[| k];
        }
    } else {
        return -1;
    }
}
// Set the last layer and go
if (is_string(k)) {
    if (_json_not_ds(current, ds_type_map)) return -argument_count+2;
    current[? k] = argument[argument_count-1];
} else {
    if (_json_not_ds(current, ds_type_list)) return -argument_count+2;
    if (is_real(k)) {
        ds_list_insert(current, k, argument[argument_count-1]);
    } else if (is_undefined(k)) {
        ds_list_add(current, argument[argument_count-1]);
    } else {
        return -argument_count+2;
    }
}
return 1;

#define json_insert_nested
/// @description json_insert_nested(@jsonstruct, ..., jsonsubdata)
/// @param @jsonstruct
/// @param  ...
/// @param  jsonsubdata
if (argument_count < 3) {
    show_error("Expected at least 3 arguments, got " + string(argument_count) + ".", true);
}
var current = argument[0];
// Check existence of root
if (_json_not_ds(current, ds_type_map)) return 0;
// Check type of subdata
var to_nest = argument[argument_count-1],
    nested_is_list = ds_map_size(to_nest) == 1 && ds_map_exists(to_nest, "default");
// Check existence of first layer
var k = argument[1];
if (is_string(k)) {
    if (argument_count == 3) {
        if (nested_is_list) {
            ds_map_add_list(current, k, to_nest[? "default"]);
        } else {
            ds_map_add_map(current, k, to_nest);
        }
        return 1;
    }
    if (!ds_map_exists(current, k)) {
        return -1;
    }
    current = current[? k];
} else if (is_real(k) || is_undefined(k)) {
    if (!ds_map_exists(current, "default")) return -1;
    current = current[? "default"];
    if (_json_not_ds(current, ds_type_list)) return -1;
    if (argument_count == 3) {
        if (is_undefined(k)) {
            k = ds_list_size(current);
            if (nested_is_list) {
                ds_list_add(current, ds_map_find_value(argument[2], "default"));
            } else {
                ds_list_add(current, argument[2]);
            }
        } else {
            if (nested_is_list) {
                ds_list_insert(current, k, ds_map_find_value(argument[2], "default"));
            } else {
                ds_list_insert(current, k, argument[2]);
            }
        }
        if (nested_is_list) {
            ds_list_mark_as_list(current, k);
        } else {
            ds_list_mark_as_map(current, k);
        }
        return 1;
    }
    if (k >= ds_list_size(current)) {
        return -1;
    }
    current = current[| k];
} else {
    return -1;
}
// Check existence of subsequent layers
for (var i = 2; i < argument_count-1; i++) {
    k = argument[i];
    if (is_string(k)) {
        if (_json_not_ds(current, ds_type_map) || (!ds_map_exists(current, k) && i < argument_count-2)) return -i;
        if (i < argument_count-2) {
            current = current[? k];
        }
    } else if (is_real(k)) {
        if (_json_not_ds(current, ds_type_list) || (k >= ds_list_size(current) && i < argument_count-2)) return -i;
        if (i < argument_count-2) {
            current = current[| k];
        }
    } else {
        return -1;
    }
}
// Set the last layer and go
if (is_string(k)) {
    if (_json_not_ds(current, ds_type_map)) return -argument_count+2;
    if (nested_is_list) {
        ds_map_add_list(current, k, to_nest[? "default"]);
    } else {
        ds_map_add_map(current, k, to_nest);
    }
} else {
    if (_json_not_ds(current, ds_type_list)) return -argument_count+2;
    if (is_real(k)) {
        if (nested_is_list) {
            ds_list_insert(current, k, ds_map_find_value(argument[argument_count-1], "default"));
        } else {
            ds_list_insert(current, k, argument[argument_count-1]);
        }
    } else if (is_undefined(k)) {
        k = ds_list_size(current);
        if (nested_is_list) {
            ds_list_add(current, ds_map_find_value(argument[argument_count-1], "default"));
        } else {
            ds_list_add(current, argument[argument_count-1]);
        }
    } else {
        return -argument_count+2;
    }
    if (nested_is_list) {
        ds_list_mark_as_list(current, k);
    } else {
        ds_list_mark_as_map(current, k);
    }
}
return 1;

#define json_unset
/// @description json_unset(@jsonstruct, ...)
/// @param @jsonstruct
/// @param  ...
if (argument_count < 2) {
    show_error("Expected at least 2 arguments, got " + string(argument_count) + ".", true);
}
var current = argument[0];
// Check existence of root
if (_json_not_ds(current, ds_type_map)) return 0;
// Check existence of first layer
var k = argument[1];
if (is_string(k)) {
    if (!ds_map_exists(current, k)) {
        return -1;
    }
    if (argument_count == 2) {
        ds_map_delete(current, k);
        return 1;
    }
    current = current[? k];
} else if (is_real(k)) {
    if (!ds_map_exists(current, "default")) return -1;
    current = current[? "default"];
    if (_json_not_ds(current, ds_type_list)) return -1;
    if (k >= ds_list_size(current)) {
        return -1;
    }
    if (argument_count == 2) {
        ds_list_delete(current, k);
        return 1;
    }
    current = current[| k];
} else {
    return -1;
}
// Check existence of subsequent layers
for (var i = 2; i < argument_count; i++) {
    k = argument[i];
    if (is_string(k)) {
        if (_json_not_ds(current, ds_type_map) || !ds_map_exists(current, k)) return -i;
        if (i < argument_count-1) {
            current = current[? k];
        }
    } else if (is_real(k)) {
        if (_json_not_ds(current, ds_type_list) || k >= ds_list_size(current)) return -i;
        if (i < argument_count-1) {
            current = current[| k];
        }
    } else {
        return -1;
    }
}
// Set the last layer and go
if (is_string(k)) {
    ds_map_delete(current, k);
} else {
    ds_list_delete(current, k);
}
return 1;

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
var ds = argument[0],
    iterator = array_create(3);
if (_json_not_ds(ds, ds_type_map)) return undefined;
if (argument_count > 2) {
    var k = argument[1];
    if (is_string(k)) {
        if (!ds_map_exists(ds, k)) return undefined;
        ds = ds[? k];
    } else if (is_real(k)) {
        if (!ds_map_exists(ds, "default")) return undefined;
        ds = ds[? "default"];
        if (_json_not_ds(ds, ds_type_list)) return undefined;
        ds = ds[| k];
    } else {
        return undefined;
    }
    for (var i = 2; i < argument_count-1; i++) {
        var k = argument[i]
        if (is_string(k)) {
            if (!ds_map_exists(ds, k)) return undefined;
            ds = ds[? k];
        } else if (is_real(k)) {
            if (_json_not_ds(ds, ds_type_list)) return undefined;
            ds = ds[| k];
        } else {
            return undefined;
        }
    }
    iterator[JSONITER.DS] = ds;
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
    switch (argument[1]) {
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
return !(is_real(argument0) && ds_exists(argument0, argument1));

