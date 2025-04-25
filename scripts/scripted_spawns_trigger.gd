extends Area3D

@export var animation_objects: Array[AnimationObject]
@export var enemies: Array[Enemy]


func _on_body_entered(_body: Node3D) -> void:
	assert(animation_objects.size() > 0 or enemies.size() > 0, "No enemies or animated objects set")
	for animation_object in animation_objects:
		animation_object.play_animation()
	for enemy in enemies:
		enemy.walk_a_few_meters_forward()
	self.call_deferred("queue_free")
