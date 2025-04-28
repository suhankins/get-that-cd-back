extends AnimationObject

@export var props: Array[BreakableProp]
@export var invincible = true

func _play_animation():
	for prop in props:
		prop.invincible = invincible
