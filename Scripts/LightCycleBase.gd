extends Node3D

class_name LightCycleBase

@export var max_speed: float = 90.0
@export var min_speed: float = 60.0
@export var friction: float = 2.0
@export var acceleration: float = 0.5
@export var turn_speed: float = 8

@onready var light_cycle_scene: Node3D = $".."

@onready var trail_parent: Node3D = $"../LightCycleTrail"

@onready var audio_stream_engine: AudioStreamPlayer3D = $Audio/AudioStreamEngine
@onready var audio_stream_explosion: AudioStreamPlayer3D = $Audio/AudioStreamExplosion

# Jump Force
@export var jump_force: float = 25
@export var gravity: float = -60.0

var is_jumping: bool = false
var vertical_velocity: float = 0.0

# Bounce parameters
@export var bounce_damping: float = 0.5
@export var min_bounce_velocity: float = 2.0

# Rotation parameters
@export var default_rotation_angle: float = 0.0
@export var jump_rotation_angle: float = 0.5
@export var jump_rotation_speed: float = 5.0
@export var jump_max_height: float = 5.0

# Cached rotation
var current_rotation: float = 0.0

@onready var light_cycle_model: Node3D = $LightCycleModel

enum TURN_DIR {LEFT, RIGHT, NONE}

var velocity: float = 0.0
var input_vector: float = 0.0

var is_turning: bool = false
var rotation_to: float = 0.0

func ready_extend():
	audio_stream_engine.stream.loop = true
	audio_stream_engine.play()

func process_extend(delta):
	trail_parent.call("update_trail", transform.origin)
	
	lc_rotate(delta)
	jump_controller(delta)
	engine_pitch_adjust()

func jump_controller(delta):
	jump_handle_gravity(delta)
	jump_update_rotation(delta)
	jump_handle_bounce()
	jump_apply_movement(delta)
	
func jump_handle_gravity(delta):
	if not is_grounded():
		vertical_velocity += gravity * delta

func jump_handle_bounce():
	if is_grounded() and vertical_velocity < 0:
		vertical_velocity = -vertical_velocity * bounce_damping

		if abs(vertical_velocity) < min_bounce_velocity:
			vertical_velocity = 0.0

func jump_update_rotation(delta):
	if(is_grounded()):
		return default_rotation_angle;
		
	var height_ratio = clamp(position.y / jump_max_height, 0.0, 1.0)
	var target_rotation = lerp(default_rotation_angle, jump_rotation_angle, height_ratio)
	current_rotation = lerp_angle(current_rotation, target_rotation, jump_rotation_speed * delta)
	light_cycle_model.rotation.z = current_rotation

func jump_apply_movement(delta):
	if is_jumping:
		vertical_velocity = jump_force
		is_jumping = false

	translate(Vector3(0, vertical_velocity * delta, 0))

func is_grounded() -> bool:
	return position.y <= 0

func turn(dir: int, delta: float):	
	if !is_grounded() || is_turning:
		return

	is_turning = true
	
	if dir == TURN_DIR.LEFT:
		rotation_to = wrapf(rotation.y + deg_to_rad(90), -PI, PI)
	else:
		rotation_to = wrapf(rotation.y - deg_to_rad(90), -PI, PI)

func lc_rotate(delta):
	if not is_turning:
		return

	# Calculate shortest angular distance
	var angle_difference = wrapf(rotation_to - rotation.y, -PI, PI)
	var turn_direction = sign(angle_difference)
	
	# Rotate with a constant angular velocity
	rotation.y += turn_direction * turn_speed * delta

	# Check if the turn is complete
	var snap_radius = clamp(2, 45, turn_speed)
	if abs(angle_difference) < deg_to_rad(snap_radius):
		rotation.y = rotation_to
		is_turning = false

func jump():
	if is_grounded():
		is_jumping = true

func kaboom():
	# Move the audio stream to the root node
	audio_stream_explosion.get_parent().remove_child(audio_stream_explosion)
	get_tree().root.add_child(audio_stream_explosion)
	
	# Play the audio
	audio_stream_explosion.play()
	
	# Free the parent node
	get_parent().queue_free()

func engine_pitch_adjust():
	var l1 = 3.0
	var l2 = 3.05
	var weight = velocity
	
	audio_stream_engine.pitch_scale = lerp(l1, l2, weight)
