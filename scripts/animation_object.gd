class_name AnimationObject extends Node

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@export var animation_name: StringName
@export var play_on_ready = false
@export var delay: float = 0.0

signal animation_finished

func _ready() -> void:
	if (play_on_ready):
		play_animation()

func play_animation():
	await get_tree().create_timer(delay).timeout
	_play_animation()
	
func _play_animation():
	animation_player.play(animation_name)

func _on_animation_player_animation_finished(_anim_name: StringName) -> void:
	animation_finished.emit()
