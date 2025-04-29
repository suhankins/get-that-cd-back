class_name LevelSwitcher extends Node

@export var levels: Array[PackedScene]
var current_level_index: int = 0
var current_level: Node
@onready var animation_player: AnimationPlayer = $AnimationPlayer

func _ready() -> void:
	_load_current_level()

func switch_level(index: int) -> void:
	animation_player.play("fade_in")
	await animation_player.animation_finished
	current_level_index = index
	_load_current_level()

func _remove_old_level() -> void:
	if (current_level != null):
		current_level.queue_free()

func restart_current_level() -> void:
	_load_current_level()
	for node in get_tree().get_nodes_in_group("delete_on_restart"):
		node.queue_free()

func _load_current_level() -> void:
	_remove_old_level()
	current_level = levels[current_level_index].instantiate()
	add_child(current_level)
	move_child(current_level, 0)
	animation_player.play("fade_out")
