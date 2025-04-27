extends Node3D

@export var speed = 1.0

func _process(delta: float) -> void:
	self.rotation.y += delta * speed
