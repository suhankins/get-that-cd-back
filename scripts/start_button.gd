extends Button

@export var level: int = 1

func _on_pressed() -> void:
	get_tree().get_first_node_in_group("game_root").switch_level(level)
