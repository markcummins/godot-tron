extends LightCycleBase

class_name LightCyclePlayer

signal on_player_died

@onready var camera_forwards: Camera3D = $CameraController/CameraTarget/CameraForwards
@onready var camera_backwards: Camera3D = $CameraBackwards

@onready var ray_cast_front: RayCast3D = $Node3D/RayCastFront
@onready var ray_cast_left: RayCast3D = $Node3D/RayCastLeft
@onready var ray_cast_right: RayCast3D = $Node3D/RayCastRight

@onready var audio_stream_warning: AudioStreamPlayer3D = $WarningSystem/AudioStreamWarning

@export var warning_min_pitch = 0.8  
@export var warning_max_pitch = 1.2  
@export var warning_min_distance = 5.0 
@export var warning_max_distance = 30.0 

func _ready():
	ready_extend()

func adjust_audio_pitch(distance: float) -> void:
	# Clamp and remap the distance to a pitch scale
	var normalized_distance = clamp(distance, warning_min_distance, warning_max_distance)
	var pitch = lerp(warning_max_pitch, warning_min_pitch, normalized_distance / warning_max_distance)

	# Apply the pitch to the audio stream
	audio_stream_warning.pitch_scale = pitch

	# Play the audio if not already playing
	if not audio_stream_warning.is_playing():
		audio_stream_warning.play()
		
func warning_system() -> void:
	var raycasts = [
		ray_cast_left, 
		ray_cast_right,
		ray_cast_front
	]

	var closest_raycast = null
	var smallest_distance = INF

	for ray_cast in raycasts:
		if ray_cast.is_colliding():
			var collider = ray_cast.get_collider()
			
			if collider && collider.name == "FloorCollider":
				print(collider.name)
				
			if collider && collider.get_parent() and collider.get_parent().name == "LightCycleTrailCollider":
				var collision_point = ray_cast.get_collision_point()
				var ray_origin = ray_cast.global_transform.origin
				var distance = ray_origin.distance_to(collision_point)
				
				# Check if this raycast has the smallest distance
				if distance < smallest_distance:
					smallest_distance = distance
					closest_raycast = ray_cast

	if closest_raycast != null:
		adjust_audio_pitch(smallest_distance)

func _process(delta: float) -> void:
	warning_system()
	
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
		turn(TURN_DIR.LEFT, delta)
	if Input.is_action_just_pressed("turn_right"):
		turn(TURN_DIR.RIGHT, delta)
		
	if Input.is_action_just_pressed("jump"):
		jump()

	process_extend(delta)
	#camera_position_update()
	
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

func _on_light_cycle_collider_body_entered(body: Node3D) -> void:
	if body.get_parent() and body.get_parent().name == "LightCycleTrailCollider":
		on_player_died.emit()
