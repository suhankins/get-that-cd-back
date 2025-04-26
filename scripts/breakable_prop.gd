extends Area3D

@export var hp: int = 4
@export var invincible: bool = false
@export var explosion_scene: PackedScene

signal broke

func _ready() -> void:
	assert(explosion_scene != null)

func damage(_side: String) -> void:
	if (invincible):
		return
	hp -= 1
	if (hp <= 0):
		broke.emit()
		var explosion = explosion_scene.instantiate()
		get_tree().get_nodes_in_group("level_root")[0].add_child(explosion)
		explosion.global_position = self.global_position
		self.queue_free()
