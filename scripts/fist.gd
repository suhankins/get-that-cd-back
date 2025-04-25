class_name Fist extends TextureRect

@export var return_fist_cooldown: float = 0.2
@export var idle_frame: Texture2D
@export var punch_frame: Texture2D
@onready var cooldown = $Cooldown


func throw_punch() -> void:
	if (cooldown.time_left > 0):
		return
	self.texture = punch_frame
	cooldown.start(return_fist_cooldown)


func _on_cooldown_timeout() -> void:
	self.texture = idle_frame
