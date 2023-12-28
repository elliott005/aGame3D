extends CanvasLayer

@onready var level_buttons = {
	"1": %LevelButton,
	"2": %LevelButton2,
	"3": %LevelButton3,
	"4": %LevelButton4,
	"5": %LevelButton5,
	"6": %LevelButton6,
	"7": %LevelButton7,
}
@onready var pb_label = %PbLabel

func _ready():
	if not MenuMusic.playing:
		MenuMusic.play()
	Globals.load_levels()
	for k in Globals.levels:
		if Globals.levels[k]["unlocked"]:
			level_buttons[k].get_child(0).hide()
			level_buttons[k].disabled = false
#			level_buttons[k].text += "\npb: " + str(Globals.levels[k]["pb"])
	get_tree().paused = false
	LevelTransition.fade_from_black()
	level_buttons["1"].grab_focus()

func _process(delta):
	if Input.is_action_just_pressed("quit_game") or Input.is_action_just_pressed("back"):
		get_tree().paused = true
		await LevelTransition.fade_to_black()
		get_tree().change_scene_to_file("res://scenes/main_menu.tscn")
	for k in Globals.levels:
		if 	level_buttons[k].has_focus():
			pb_label.text = "Personal best: " + str(Globals.levels[k]["pb"])

func load_level(which):
	get_tree().paused = true
	MenuMusic.fade_out_music()
	await LevelTransition.fade_to_black()
	get_tree().change_scene_to_file("res://scenes/levels/level_" + str(which) + ".tscn")

func _on_level_button_pressed():
	load_level(1)

func _on_level_button_2_pressed():
	load_level(2)

func _on_level_button_3_pressed():
	load_level(3)

func _on_level_button_4_pressed():
	load_level(4)

func _on_level_button_5_pressed():
	load_level(5)

func _on_level_button_6_pressed():
	load_level(6)

func _on_level_button_7_pressed():
	load_level(7)
