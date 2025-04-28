extends Node

@export var level_index: int = 0

func switch_level_with_one_argument(_a):
	switch_level()

func switch_level():
	print('LEVEL TRANSITION REQUESTED')
	get_tree().get_first_node_in_group("game_root").switch_level(level_index)
