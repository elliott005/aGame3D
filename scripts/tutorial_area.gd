extends Area3D

@onready var label = %Label
@onready var collision_shape_3d = $CollisionShape3D

@export var text: String

func _ready():
	label.text = text
	label.hide()

func _on_body_entered(body):
	if body.is_in_group("Player"):
		label.show()


func _on_body_exited(body):
	if body.is_in_group("Player"):
		label.hide()
