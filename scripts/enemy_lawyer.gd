@tool
class_name Enemy extends CharacterBody3D

@onready var animation_player: AnimationPlayer = $Lawyer/AnimationPlayer
@onready var vision_raycast: RayCast3D = $VisionRaycast
@onready var player: Player = get_tree().get_nodes_in_group('player')[0]
@onready var time_to_hit_timer: Timer = $TimeToHit
@onready var time_to_change_state_timer: Timer = $TimerToChangeState
@onready var audio_player: AudioStreamPlayer3D = $AudioStreamPlayer3D
@onready var paper_spawn_point: Node3D = $PaperSpawnPoint

@export_category("scripted spawn")
@export var delay: float = 0.0
## If true, enemy won't say "show me what you got"
@export var seen_player = false
@export var walk_for_seconds: float = 1.0

@export_category("suit")
@export var suits: Array[Material]
@export var chosen_suit: int = 0:
	set(new_color):
		if (new_color < 0 or new_color > suits.size() - 1):
			return
		chosen_suit = new_color
		$Lawyer/in_skeleton/Skeleton3D/in.set_surface_override_material(1, suits[new_color])

@export_category("npc properties")
@export var detection_radius: float = 5.0
@export var squared_punch_range: float = 1.6
@export var hp: int = 8
@export var walking_speed: float = 2
@export var can_do_ranged_attack: bool = false
@export var projectile_scene: PackedScene

const PUNCH_TIME_TO_HIT: float = 0.7
const THROW_TIME_TO_HIT: float = 1.7

@export_category("sounds")
@export var punch_sound: AudioStream
@export var throw_sound: AudioStream
@export var spotted_sounds: Array[AudioStream]
@export var hurt_sounds: Array[AudioStream]
@export var dying_sounds: Array[AudioStream]

var state: STATE = STATE.UNALERTED
enum STATE {
	UNALERTED,
	IDLE,
	WALKING,
	PUNCHING,
	GETTING_HIT,
	THROWING,
	WALK_A_FEW_METERS_FORWARD,
	WAITING_TO_WALK_A_FEW_METERS,
	DEAD
}

signal died

func _process(_delta: float) -> void:
	if Engine.is_editor_hint():
		return
	
	if (state == STATE.DEAD or state == STATE.WAITING_TO_WALK_A_FEW_METERS):
		return
	if (state == STATE.UNALERTED):
		if (_sees_player()):
			if (!seen_player):
				audio_player.stream = spotted_sounds.pick_random()
				audio_player.play()
				seen_player = true
			animation_player.play("idle")
			state = STATE.IDLE
			time_to_change_state_timer.start(0.5)
		return
	if (state == STATE.WALKING):
		_look_at_player()
		_walk_forward()
		if (not _sees_player()):
			state = STATE.UNALERTED
			return
		if (_in_punching_distance()):
			state = STATE.IDLE
			time_to_change_state_timer.start(0.2)
			return
		return
	if (state == STATE.PUNCHING or state == STATE.THROWING or state == STATE.IDLE):
		_look_at_player()
		return
	if (state == STATE.WALK_A_FEW_METERS_FORWARD):
		_walk_forward()
		return

func walk_a_few_meters_forward() -> void:
	if (delay > 0.0):
		state = STATE.WAITING_TO_WALK_A_FEW_METERS
		time_to_change_state_timer.start(delay)
	else:
		state = STATE.WALK_A_FEW_METERS_FORWARD
		time_to_change_state_timer.start(walk_for_seconds)

func _look_at_player():
	look_at(player.position)
	rotation.x = 0
	rotation.z = 0

func _walk_forward():
	animation_player.play("walk")
	velocity = transform.basis * Vector3(0, 0, -walking_speed)
	move_and_slide()

func _in_punching_distance() -> bool:
	return position.distance_squared_to(player.position) <= squared_punch_range

func _sees_player() -> bool:
	vision_raycast.target_position.z = -detection_radius
	vision_raycast.look_at(player.position + Vector3.UP)
	vision_raycast.force_raycast_update()
	return vision_raycast.get_collider() == player

func damage(side: String):
	animation_player.stop()
	hp -= 1
	if (hp <= 0):
		audio_player.stream = dying_sounds.pick_random()
		audio_player.play()
		animation_player.play("death")
		state = STATE.DEAD
		collision_layer = 0
		died.emit()
		return
		
	audio_player.stream = hurt_sounds.pick_random()
	audio_player.play()
	
	if (side == "left"):
		animation_player.play("hit_left")
	else:
		animation_player.play("hit_right")
	state = STATE.GETTING_HIT
	time_to_change_state_timer.start(0.4)

func _on_timer_to_change_state_timeout() -> void:
	if (state == STATE.IDLE):
		if (_in_punching_distance()):
			animation_player.play(["punch", "punch_2"].pick_random())
			time_to_hit_timer.start(PUNCH_TIME_TO_HIT)
			time_to_change_state_timer.start(1.0)
			state = STATE.PUNCHING
		elif (can_do_ranged_attack and _sees_player()):
			animation_player.play("throw")
			time_to_hit_timer.start(THROW_TIME_TO_HIT)
			time_to_change_state_timer.start(2.2)
			state = STATE.THROWING
		else:
			state = STATE.WALKING
		return
	if (state == STATE.PUNCHING):
		time_to_change_state_timer.start(0.5)
		state = STATE.IDLE
		return
	if (state == STATE.WALK_A_FEW_METERS_FORWARD):
		state = STATE.UNALERTED
		return
	if (state == STATE.GETTING_HIT):
		time_to_change_state_timer.start(0.2)
		state = STATE.IDLE
		return
	if (state == STATE.THROWING):
		time_to_change_state_timer.start(0.2 + randf_range(0.0, 0.2))
		state = STATE.IDLE
		return
	if (state == STATE.WAITING_TO_WALK_A_FEW_METERS):
		delay = 0
		walk_a_few_meters_forward()
		return

func _on_time_to_hit_timeout() -> void:
	if (state == STATE.PUNCHING):
		audio_player.stream = punch_sound
		audio_player.play()
		if (_in_punching_distance()):
			player.damage(1)
		return
	if (state == STATE.THROWING):
		assert(projectile_scene != null)
		if (randf() > 0.5):
			audio_player.stream = throw_sound
			audio_player.play()
		var projectile = projectile_scene.instantiate()
		get_tree().get_nodes_in_group("level_root")[0].add_child(projectile)
		projectile.global_rotation = paper_spawn_point.global_rotation
		projectile.global_position = paper_spawn_point.global_position
		return
