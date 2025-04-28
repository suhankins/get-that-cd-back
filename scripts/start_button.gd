extends Button


func _on_pressed() -> void:
	get_tree().get_first_node_in_group("game_root").switch_level(1)
