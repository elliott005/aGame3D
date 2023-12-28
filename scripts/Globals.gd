extends Node

var save_path = "user://levels.save"
var save_settings_path = "user://settings.save"
var levels = {"1": {"unlocked": true, "pb": 0.0},
	"2": {"unlocked": false, "pb": 0.0},
	"3": {"unlocked": false, "pb": 0.0},
	"4": {"unlocked": false, "pb": 0.0},
	"5": {"unlocked": false, "pb": 0.0},
	"6": {"unlocked": false, "pb": 0.0},
	"7": {"unlocked": false, "pb": 0.0},
}

var meshes = ["Wall", "NoWallRunWall", "NoWallRunWall", "Lava"]

var default_settings = {
	"mouse_sensitivity": 0.008,
	"joystick_sensitivity": 0.045,
	"volume": -10
}

var settings = default_settings.duplicate()

func save_levels():
	var file = FileAccess.open(save_path, FileAccess.WRITE)
	file.store_string(var_to_str(levels))

func load_levels():
	if FileAccess.file_exists(save_path):
		var file = FileAccess.open(save_path, FileAccess.READ)
		var levels_file = str_to_var(file.get_as_text())
		if levels_file.size() == levels.size():
			levels = levels_file

func save_settings():
	var file = FileAccess.open(save_settings_path, FileAccess.WRITE)
	file.store_string(var_to_str(settings))

func load_settings():
	if FileAccess.file_exists(save_settings_path):
		var file = FileAccess.open(save_settings_path, FileAccess.READ)
		var settings_file = str_to_var(file.get_as_text())
		settings = settings_file

func restore_default_settings():
	settings = default_settings.duplicate()
