extends AnimationObject

func _play_animation():
	get_tree().get_first_node_in_group("player").drop_cd()
