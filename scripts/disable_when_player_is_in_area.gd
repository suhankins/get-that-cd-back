extends Area3D

@export var object_to_be_disabled: Node3D


func _on_body_entered(body: Node3D) -> void:
	object_to_be_disabled.hide()


func _on_body_exited(body: Node3D) -> void:
	object_to_be_disabled.show()
