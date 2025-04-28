class_name Player extends CharacterBody3D

@export var enabled = true

@export_subgroup("Properties")
@export var movement_speed = 5
@export var jump_strength = 8

@export_subgroup("Sounds")
@export var throw_punch_sound: AudioStream
@export var land_punch_sound: AudioStream
@export var hurt_sound: AudioStream


@onready var hand_holding_cd: TextureRect = $"Fists/HandHoldingCD"
@onready var fists: Array[Fist] = [$"Fists/LeftFist", $"Fists/RightFist"]
var last_fist_thrown: int = 0
var can_attack = true

var mouse_sensitivity = 700
var gamepad_sensitivity := 0.075

var mouse_captured := true

var movement_velocity: Vector3
var rotation_target: Vector3

var input_mouse: Vector2

var health: int = 4
var gravity := 0.0

var previously_floored := false

signal health_updated(health: int)

@onready var camera = $Head/Camera
@onready var raycast = $Head/Camera/RayCast
@onready var sound_footsteps = $SoundFootsteps
@onready var punch_cooldown = $PunchCooldown
@onready var fists_container = $Fists
@onready var damaged_screen = $DamagedScreen

# Functions

func _ready():
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	rotation_target.x = camera.global_rotation.x
	rotation_target.y = camera.global_rotation.y
	rotation_target.z = camera.global_rotation.z

func _physics_process(delta):
	_mouse_capture_handling()
	# Movement sound
	if (!sound_footsteps.playing):
		sound_footsteps.play()

	sound_footsteps.stream_paused = true
	
	if is_on_floor():
		if abs(velocity.x) > 1 or abs(velocity.z) > 1:
			sound_footsteps.stream_paused = false
	
	if (!enabled):
		return
	
	# Handle functions
	
	handle_controls(delta)
	handle_gravity(delta)
	
	# Movement
	handle_movement(delta)
	
	# Rotation
	
	camera.rotation.z = lerp_angle(camera.rotation.z, -input_mouse.x * 25 * delta, delta * 5)	
	
	camera.rotation.x = lerp_angle(camera.rotation.x, rotation_target.x, delta * 25)
	rotation.y = lerp_angle(rotation.y, rotation_target.y, delta * 25)
		
	# Landing after jump or falling
	
	camera.position.y = lerp(camera.position.y, 0.0, delta * 5)
	
	if is_on_floor() and gravity > 1 and !previously_floored: # Landed
		camera.position.y = -0.1
	
	previously_floored = is_on_floor()
	
	if position.y < -10:
		get_tree().reload_current_scene()


func handle_movement(delta: float) -> void:
	var applied_velocity: Vector3
	
	movement_velocity = transform.basis * movement_velocity # Move forward
	
	applied_velocity = velocity.lerp(movement_velocity, delta * 10)
	applied_velocity.y = -gravity
	
	velocity = applied_velocity
	move_and_slide()


# Mouse movement

func _input(event):
	if event is InputEventMouseMotion and mouse_captured:
		
		input_mouse = event.relative / mouse_sensitivity
		
		rotation_target.y -= event.relative.x / mouse_sensitivity
		rotation_target.x -= event.relative.y / mouse_sensitivity

func _mouse_capture_handling():
	if Input.is_action_just_pressed("mouse_capture"):
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
		mouse_captured = true
	
	if Input.is_action_just_pressed("mouse_capture_exit"):
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		mouse_captured = false
		
		input_mouse = Vector2.ZERO

func handle_controls(_delta):
	# Movement
	
	var input := Input.get_vector("move_left", "move_right", "move_forward", "move_back")
	
	movement_velocity = Vector3(input.x, 0, input.y).normalized() * movement_speed
	
	# Rotation
	
	var rotation_input := Input.get_vector("camera_right", "camera_left", "camera_down", "camera_up")
	
	rotation_target -= Vector3(-rotation_input.y, -rotation_input.x, 0).limit_length(1.0) * gamepad_sensitivity
	rotation_target.x = clamp(rotation_target.x, deg_to_rad(-90), deg_to_rad(90))
	
	# Shooting
	
	action_shoot()

# Handle gravity

func handle_gravity(delta):
	
	gravity += 20 * delta
	
	if gravity > 0 and is_on_floor():
		
		gravity = 0


func take_cd():
	can_attack = false
	for fist in fists:
		fist.hide()
	hand_holding_cd.show()

func drop_cd():
	hand_holding_cd.hide()

# Shooting

func action_shoot():
	if (!can_attack):
		return
	if Input.is_action_pressed("shoot"):
		if (punch_cooldown.time_left > 0):
			return
		fists[last_fist_thrown].throw_punch()
		last_fist_thrown += 1
		if (last_fist_thrown >= fists.size()):
			last_fist_thrown = 0
		
		punch_cooldown.start()
		
		Audio.play_stream(throw_punch_sound)
		
		raycast.force_raycast_update()
			
		if !raycast.is_colliding():
			return
		
		Audio.play_stream(land_punch_sound)
		
		var collider = raycast.get_collider()
		if collider.has_method("damage"):
			collider.damage("right" if last_fist_thrown == 0 else "left")

		var impact = preload("res://objects/impact.tscn")
		var impact_instance = impact.instantiate()

		impact_instance.play("shot")

		get_tree().root.add_child(impact_instance)

		impact_instance.position = raycast.get_collision_point() + (raycast.get_collision_normal() / 10)
		impact_instance.look_at(camera.global_transform.origin, Vector3.UP, true) 

func enable() -> void:
	self.enabled = true

func disable() -> void:
	velocity = Vector3.ZERO
	self.enabled = false

func damage(amount):
	health -= amount
	health_updated.emit(health) # Update health on HUD
	Audio.play_stream(hurt_sound)
	
	if health < 0:
		get_tree().reload_current_scene() # Reset when out of health
	else:
		damaged_screen.show()
		await get_tree().create_timer(0.5).timeout
		damaged_screen.hide()
