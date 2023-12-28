extends CanvasLayer

@onready var label = $CenterContainer/VBoxContainer/Label
@onready var next_level_button = %NextLevelButton
@onready var retry_button = %RetryButton
@onready var main_menu_button = %MainMenuButton

@export var next_level: PackedScene
@export var time: float = 0.0

func _on_visibility_changed():
	retry_button.grab_focus()
	label.text += str(time) + " seconds!"
	
	var which_level = get_parent().which_level
	Globals.levels[str(min(which_level + 1, Globals.levels.size()))]["unlocked"] = true
	if Globals.levels[str(min(which_level, Globals.levels.size()))]["pb"] == 0.0 or Globals.levels[str(min(which_level, Globals.levels.size()))]["pb"] > time:
		Globals.levels[str(min(which_level, Globals.levels.size()))]["pb"] = time
		label.text += " New Personal Best!"
	Globals.save_levels()
	
	if not next_level is PackedScene:
		main_menu_button.hide()
		next_level_button.text = "Main Menu!"
		label.text += "\nGame Completed!"

func _on_next_level_button_pressed():
	get_tree().paused = true
	await LevelTransition.fade_to_black()
	if not next_level is PackedScene:
		get_tree().change_scene_to_file("res://scenes/main_menu.tscn")
	else:
		get_tree().change_scene_to_packed(next_level)

func _on_retry_button_pressed():
	get_tree().paused = true
	await LevelTransition.fade_to_black()
	get_tree().reload_current_scene()

func _on_main_menu_button_pressed():
	get_tree().paused = true
	await LevelTransition.fade_to_black()
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")
