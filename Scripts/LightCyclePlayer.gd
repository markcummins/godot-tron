extends LightCycleBase

class_name LightCyclePlayer

@onready var camera_forwards: Camera3D = $CameraController/CameraTarget/CameraForwards
@onready var camera_backwards: Camera3D = $CameraBackwards

func _ready():
	ready_extend()
	
func _process(delta: float) -> void:
	if (Input.is_action_pressed("look_back")):
		camera_back()
	elif(camera_forwards.current == false):
		camera_forward()

	var input_vector = 0.0
	if Input.is_action_pressed("move_forward"):
		input_vector += 1.0
	
	## Apply acceleration and deceleration
	velocity = lerp(velocity, clamp(input_vector * max_speed, min_speed, max_speed), acceleration * delta)
#
	if input_vector == 0.0:
		velocity = lerp(velocity, min_speed, friction * delta)
#
	translate(Vector3(0, 0, velocity * delta))
	
	if Input.is_action_just_pressed("turn_left"):
		turn_left(delta)
	if Input.is_action_just_pressed("turn_right"):
		turn_right(delta)

	process_extend(delta)
	camera_position_update()
	
func camera_position_update():
	$CameraController.position = lerp($CameraController.position, position, 0.25)
	
	var target_basis = global_transform.basis
	var current_rotation_quat = Quaternion($CameraController.global_transform.basis)
	var target_rotation_quat = Quaternion(target_basis)
	
	$CameraController.global_transform.basis = target_basis

func camera_back():
	camera_forwards.current = false
	camera_backwards.current = true
	
func camera_forward():
	camera_forwards.current = true
	camera_backwards.current = false

signal on_player_died

func _on_light_cycle_collider_area_entered(area: Area3D) -> void:
	if(area.name  == "LightCycleTrailCollider"):
		on_player_died.emit()
