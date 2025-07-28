# JSON Toolkit for GMS 2.x

## NOTICE: This library is no longer maintained.

This library is now sunsetted, as `json_encode` and `json_decode` are no longer best-practice in modern GML, and chained accessors have been available since 2.3.0. Consider using the following alternatives:

- `json_stringify` and `json_parse` (built-in GML functions in 2.3.2 and later)
- [GMC Toolbox](https://forum.gamemaker.io/index.php?threads/gamemaker-community-toolbox.103966/) (contains `json_load` and `json_save` for working with JSON files)
- [JSON Struct](https://github.com/dicksonlaw583/jsonstruct) (for general use, with formatting options)
- [Classful JSON](https://github.com/dicksonlaw583/classfuljson) (for working with constructor-built structs)


## Overview

JSON Toolkit is a set of companion scripts facilitating the use of GML's built in `json_encode` and `json_decode` functions. It contains utilities for visually building JSON structure, accessing and manipulating deeply nested values, iterating through a JSON structure, and saving/loading JSON data in files.

## Requirements

- GameMaker 2022.0.3 or higher

If you use GameMaker Studio 2.2.x or 2.3.x, please use [v1.1.2](https://github.com/dicksonlaw583/jsontoolkit/releases/tag/v1.1.2).

## Installation Instructions

Download the asset package from [the Releases page](https://github.com/dicksonlaw583/jsontoolkit/releases), and extract everything to your project.

## License

JSON Toolkit is licensed under the MIT License. You may freely use it in personal and commercial projects.

(C) Dickson Law 2018

## Examples

### Creating Nested JSON Structures

```gml
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

```json
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
        "DEF": 2
    }
]
```

```gml
// Access Bob's HP
var json_data = json_decode(json_str);
var bob_hp = json_get(json_data, 1, "HP");
```

### Loading From a File

```gml
// Load from save.json (Form 1)
var json_data = json_load(working_directory + "save.json");
```

```gml
// Load from save.json (Form 2)
var json_data = JsonStruct(working_directory + "save.json");
```

### Iterating Through a JSON Structure

```json
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
        "DEF": 2
    }
]
```

```gml
// Show a message for each name
var json_data = json_decode(json_str);
for (var i = json_iterate(json_data, ds_type_list); json_has_next(json_data); json_next(json_data)) {
	show_message("Hello from " + json_get(i[JSONITER.VALUE], "name") + "!");
}
```