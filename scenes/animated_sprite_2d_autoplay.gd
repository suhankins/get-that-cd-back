extends AnimatedSprite2D

@export var animation_name: StringName = "default"

func _ready() -> void:
	play(animation_name)


func _on_frame_changed() -> void:
	if (frame == sprite_frames.get_frame_count("default") - 1):
		frame = 0
