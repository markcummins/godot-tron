extends Node3D

@export var max_speed: float = 60.0
@export var min_speed: float = 40.0
@export var friction: float = 2.0
@export var acceleration: float = 10.0

var velocity: float = 0.0
var target_rotation: float = 0.0 # Target Y rotation in radians

@onready var trail_parent: Node3D = $"../LightCycleTrail"
@onready var mesh_instance_3d: MeshInstance3D = $MeshInstance3D

func _process(delta: float) -> void:
	# Movement logic
	var input_vector = 0.0
	if Input.is_action_pressed("move_forward"):
		input_vector += 1.0
	if Input.is_action_pressed("move_backward"):
		input_vector -= 1.0

	# Apply acceleration and deceleration
	velocity = lerp(velocity, clamp(input_vector * max_speed, min_speed, max_speed), acceleration * delta)

	if input_vector == 0.0:
		velocity = lerp(velocity, min_speed, friction * delta)

	translate(Vector3(0, 0, velocity * delta))

	if Input.is_action_just_pressed("turn_left"):
		target_rotation += deg_to_rad(90)
		rotation.y = target_rotation
		trail_parent.call("turn", global_transform.origin)
		return
		
	if Input.is_action_just_pressed("turn_right"):
		target_rotation -= deg_to_rad(90)
		rotation.y = target_rotation
		trail_parent.call("turn", global_transform.origin)
		return

	trail_parent.call("update_trail", global_transform.origin)

#extends Node3D
#
#@export var max_speed: float = 60.0
#@export var min_speed: float = 40.0
#@export var friction: float = 2.0
#@export var acceleration: float = 10.0
#@export var turn_speed: float = 50.0
#
#var velocity: float = 0.0
#var target_rotation: float = 0.0 # Target Y rotation in radians
#
#@onready var trail_parent: Node3D = $"../TrailParent"
#@onready var mesh_instance_3d: MeshInstance3D = $MeshInstance3D
#
#func _process(delta: float) -> void:
	## Movement logic
	#var input_vector = 0.0
	#if Input.is_action_pressed("move_forward"):
		#input_vector += 1.0
	#if Input.is_action_pressed("move_backward"):
		#input_vector -= 1.0
#
	## Apply acceleration and deceleration
	#velocity = lerp(velocity, clamp(input_vector * max_speed, min_speed, max_speed), acceleration * delta)
#
	#if input_vector == 0.0:
		#velocity = lerp(velocity, min_speed, friction * delta)
#
	#translate(Vector3(0, 0, velocity * delta))
#
	#if Input.is_action_just_pressed("turn_left"):
		#target_rotation += deg_to_rad(90)
	#if Input.is_action_just_pressed("turn_right"):
		#target_rotation -= deg_to_rad(90)
#
	#rotation.y = lerp_angle(rotation.y, target_rotation, turn_speed * delta)
#
	## Update the trail with the bike's current position
	#trail_parent.call("update_trail", global_transform.origin)