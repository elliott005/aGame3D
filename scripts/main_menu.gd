extends CanvasLayer

@onready var start_button = %StartButton
@onready var tab_container = %TabContainer
@onready var mouse_h_slider = %MouseHSlider
@onready var joystick_h_slider = %JoystickHSlider
@onready var audio_h_slider = %AudioHSlider

# Called when the node enters the scene tree for the first time.
func _ready():
	Globals.load_settings()
	get_tree().paused = false
	LevelTransition.fade_from_black()
	start_button.grab_focus()
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	if not MenuMusic.playing:
		MenuMusic.play()
		MenuMusic.volume_db = Globals.settings["volume"] - 20

func _physics_process(delta):
	MenuMusic.volume_db = move_toward(MenuMusic.volume_db, Globals.settings["volume"], 20 * delta)
	if Input.is_action_just_pressed("quit_game"):
		Globals.save_settings()
		get_tree().quit()
	if tab_container.visible:
		if Input.is_action_just_pressed("back"):
			Globals.save_settings()
			tab_container.hide()
			start_button.grab_focus()
		var input_axis = Input.get_axis("tab_left", "tab_right")
		var previous_tab = tab_container.current_tab
		tab_container.current_tab = clamp(tab_container.current_tab + round(input_axis), 0, tab_container.get_child_count())
		if previous_tab != tab_container.current_tab:
			if tab_container.current_tab == 0:
				mouse_h_slider.grab_focus()
			elif tab_container.current_tab == 1:
				audio_h_slider.grab_focus()
				

func _on_start_button_pressed():
	get_tree().paused = true
	await LevelTransition.fade_to_black()
	get_tree().change_scene_to_file("res://scenes/level_select_screen.tscn")

func _on_quit_button_pressed():
	get_tree().quit()

func _on_settings_button_pressed():
	mouse_h_slider.value = Globals.settings["mouse_sensitivity"] * 1000.0
	joystick_h_slider.value = Globals.settings["joystick_sensitivity"] * 1000.0
	audio_h_slider.value = Globals.settings["volume"]
	tab_container.show()
	mouse_h_slider.grab_focus()

func _on_mouse_h_slider_value_changed(value):
	Globals.settings["mouse_sensitivity"] = value / 1000.0

func _on_joystick_h_slider_value_changed(value):
	Globals.settings["joystick_sensitivity"] = value / 1000.0

func _on_default_button_pressed():
	restore_default()

func _on_audio_h_slider_value_changed(value):
	Globals.settings["volume"] = value

func restore_default():
	Globals.restore_default_settings()
	mouse_h_slider.value = Globals.settings["mouse_sensitivity"] * 1000.0
	joystick_h_slider.value = Globals.settings["joystick_sensitivity"] * 1000.0
	audio_h_slider.value = Globals.settings["volume"]
