# JSON Toolkit for GMS 2.x

## Overview
JSON Toolkit is a set of companion scripts facilitating the use of GML's built in `json_encode()` and `json_decode()` functions. It contains utilities for visually building JSON structure, accessing and manipulating deeply nested values, iterating through a JSON structure, and saving/loading JSON data in files. With JSON Toolkit, many common JSON operations that would otherwise take several lines, intermediate values and repetitions in conventional GML can be shortened into concise, easy-to-read one-liners.

## Installation Instructions
Install for free at [YoYo Marketplace](http://marketplace.yoyogames.com/assets/8066/json-toolkit).

## License
JSON Toolkit is licensed under the MIT License. You may freely use it in personal and commercial projects.

(C) Dickson Law 2018

## Examples
### Creating Nested JSON Structures
**Conventional GML**
```
global.stats = ds_map_create();
ds_map_add_map(global.stats, "Alice", ds_map_create());
ds_map_add(global.stats[? "Alice"], "HP", 5);
ds_map_add(global.stats[? "Alice"], "ATK", 5);
ds_map_add(global.stats[? "Alice"], "DEF", 4);
ds_map_add_map(global.stats, "Bob", ds_map_create());
ds_map_add(global.stats[? "Bob"], "HP", 7);
ds_map_add(global.stats[? "Bob"], "ATK", 6);
ds_map_add(global.stats[? "Bob"], "DEF", 2);
```
**With JSON Toolkit**
```
global.stats = JsonStruct(JsonMap(
	"Alice", JsonMap(
    	"HP", 5,
        "ATK", 5,
        "DEF", 4
    ),
    "Bob", JsonMap(
    	"HP", 7,
        "ATK", 6,
        "DEF", 2
    )
));
```
### Accessing Deeply Nested Structures
**JSON String to Decode**
```
[
	{
    	"name": "Alice",
        "HP": 5,
        "ATK": 5,
        "DEF": 4
    },
    {
    	"name": "Bob",
        "HP": 7,
        "ATK": 6,
        "DEF", 2
    }
]
```
**Conventional GML**
```
// Access Bob's HP
var json_data = json_decode(json_str);
var bob_hp = json_data[? "default"];
bob_hp = bob_hp[| 1];
bob_hp = bob_hp[? "HP"];
```
**With JSON Toolkit**
```
// Access Bob's HP
var json_data = json_decode(json_str);
var bob_hp = json_get(json_data, 1, "HP");
```
### Loading From a File
**Conventional GML**
```
// Load from save.json
var f = file_text_open_read(working_directory + "save.json"),
	json_str = "";
while (!file_text_eof(f)) {
	json_str += file_text_read_string(f);
    file_text_readln(f);
}
file_text_close();
var json_data = json_decode(json_str);
```
**With JSON Toolkit**
```
// Load from save.json (Form 1)
var json_data = json_load(working_directory + "save.json");
```
```
// Load from save.json (Form 2)
var json_data = JsonStruct(working_directory + "save.json");
```
### Iterating Through a JSON Structure
**JSON String**
```
[
	{
    	"name": "Alice",
        "HP": 5,
        "ATK": 5,
        "DEF": 4
    },
    {
    	"name": "Bob",
        "HP": 7,
        "ATK": 6,
        "DEF", 2
    }
]
```
**Conventional GML**
```
// Show a message for each name
var json_data = json_decode(json_str),
	json_list = json_data[? "default"];
for (var i = 0; i < ds_list_size(json_list); i++) {
	show_message("Hello from " + ds_map_find_value(json_list[| i], "name") + "!");
}
```
**With JSON Toolkit**
```
// Show a message for each name
var json_data = json_decode(json_str);
for (var i = json_iterate(json_data); json_has_next(json_data); json_next(json_data)) {
	show_message("Hello from " + json_get(i[JSONITER.VALUE], "name") + "!");
}
```