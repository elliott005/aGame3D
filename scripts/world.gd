extends Node3D

@onready var timer_label = %TimerLabel
@onready var countdown_color_rect = %CountdownColorRect
@onready var animation_player = $AnimationPlayer
@onready var countdown_label = %CountdownLabel
@onready var level_completed = $LevelCompleted
@onready var music = $Music

@export var which_level: float

var start_time: int

func _ready():
	MenuMusic.stop()
	Events.level_finished.connect(level_finished)
	music.volume_db = Globals.settings["volume"]
	await LevelTransition.fade_from_black()
	countdown_color_rect.show()
	countdown_label.show()
	animation_player.play("start_countdown")
	await animation_player.animation_finished
	countdown_color_rect.hide()
	countdown_label.hide()
	get_tree().paused = false
	start_time = Time.get_ticks_msec()

func _process(delta):
	var current_time = Time.get_ticks_msec() - start_time
	timer_label.text = str(current_time / 1000.0)

func level_finished():
	get_tree().paused = true
	var current_time = Time.get_ticks_msec() - start_time
	level_completed.time = current_time / 1000.0
	level_completed.show()
