class_name AnimationObject extends Node

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@export var animation_name: StringName
@export var play_on_ready = false
@export var delay: float = 0.0

func _ready() -> void:
	if (play_on_ready):
		play_animation()

func play_animation():
	await get_tree().create_timer(delay).timeout
	animation_player.play(animation_name)
