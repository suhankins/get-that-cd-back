extends AnimatedSprite3D

@export var animation_name: StringName = "default"

func _ready() -> void:
	play(animation_name)
