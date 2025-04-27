extends Node

func _ready():
	get_tree().get_first_node_in_group("player").take_cd()
	self.queue_free()
