extends Area3D

@export var speed: float = 3.0
@onready var sprite: Sprite3D = $LegalPaperSprite
var hit_wall = false
@onready var audio_player: AudioStreamPlayer3D = $AudioStreamPlayer3D
@export var wall_hit_sound: AudioStream

func _process(delta: float) -> void:
	if (hit_wall):
		return
	sprite.rotation.z -= PI * 2.0 * delta
	translate(Vector3(0, 0, -delta * speed))

func damage(_side: String):
	queue_free()

func _on_body_entered(body: Node3D) -> void:
	_on_wall_hit()
	if (body is Player):
		body.damage(1)
		queue_free()
	else:
		reparent(body)


func _on_area_entered(area: Area3D) -> void:
	reparent(area)
	_on_wall_hit()

func _on_wall_hit():
	set_deferred("monitoring", false)
	hit_wall = true
	audio_player.stop()
	audio_player.stream = wall_hit_sound
	audio_player.play()
