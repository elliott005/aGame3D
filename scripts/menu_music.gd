extends AudioStreamPlayer

@onready var animation_player = $AnimationPlayer

func _ready():
	volume_db = Globals.settings["volume"]

func fade_in_music():
	animation_player.play("fade_in_music")
	await animation_player.animation_finished

func fade_out_music():
	animation_player.play("fade_out_music")
	await animation_player.animation_finished
