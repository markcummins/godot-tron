extends LightCycleBase

class_name LightCycleBot

@onready var ray_cast_front: RayCast3D = $Node3D/RayCastFront

@onready var ray_cast_left: RayCast3D = $Node3D/RayCastLeft
@onready var ray_cast_right: RayCast3D = $Node3D/RayCastRight

@onready var ray_cast_back_left: RayCast3D = $Node3D/RayCastBackLeft
@onready var ray_cast_back_right: RayCast3D = $Node3D/RayCastBackRight

@onready var lightcycle_bot: LightCycleBot = $"."
@onready var lightcycle_path = str(lightcycle_bot.get_parent().get_path())

var do_random_turn = false
var enemies_in_range: int = 0

var turn_distance: float = 0.0

var attack_direction: TURN_DIR = TURN_DIR.NONE

func _ready():
	ready_extend()
	set_random_turn_timer()

func _process(delta: float) -> void:
	random_turn_controller(delta)
	acceleration_controller(delta)
	oncoming_object_controller(delta)
	
	side_attack_controller(delta)
	behind_attack_controller(delta)

	process_extend(delta)
	
func side_attack_controller(delta):
	if attack_direction != TURN_DIR.NONE:
		turn(attack_direction, delta)
		attack_direction = TURN_DIR.NONE

func behind_attack_controller(delta):
	if(enemies_in_range == 0):
		return
		
	if(is_collision_detected(ray_cast_back_left) and !is_collision_detected(ray_cast_left)):
		turn(TURN_DIR.LEFT, delta)

	if(is_collision_detected(ray_cast_back_right) and !is_collision_detected(ray_cast_right)):
		turn(TURN_DIR.RIGHT, delta)

func random_turn_controller(delta):
	if(do_random_turn):
		auto_turn(delta)
		do_random_turn = false

func acceleration_controller(delta):
	if (!is_grounded()):
		input_vector += 1.0
		velocity = lerp(velocity, max_speed, 5.0 * delta)
		
	elif(enemies_in_range > 0):
		input_vector += 1.0
		velocity = lerp(velocity, max_speed, acceleration * delta)
	
	else:
		input_vector = 0.0
		velocity = lerp(velocity, min_speed, friction * delta)
	
	translate(Vector3(0, 0, velocity * delta))

func oncoming_object_controller(delta: float) -> void:
	if(is_turning):
		return

	if(!ray_cast_front.is_colliding()):
		return
		
	# Get the collider
	var collider = ray_cast_front.get_collider()
		
	## Wall Collision Coming Up
	if collider && collider is Node:
		if collider.name == "WallCollision":
			var collision_point = ray_cast_front.get_collision_point()
			var ray_origin = ray_cast_front.global_transform.origin
			var distance = ray_origin.distance_to(collision_point)
			
			if(distance < get_turn_distance()):
				auto_turn(delta)

		if collider.get_parent() && collider.get_parent().name == "LightCycleTrailCollider": 
			var collision_point = ray_cast_front.get_collision_point()
			var ray_origin = ray_cast_front.global_transform.origin
			var distance = ray_origin.distance_to(collision_point)
			
			if(distance < get_turn_distance()):
				auto_turn(delta)
			
			elif(distance < 35.0):
				jump()

func auto_turn(delta):
	var lt_distance_left = get_lighttrail_collision_distance(ray_cast_left)
	var lt_distance_right = get_lighttrail_collision_distance(ray_cast_right)
	
	# Clear on Both Sides
	if(!lt_distance_right && !lt_distance_left):
		var turn_dir = TURN_DIR.LEFT if randf() < 0.5 else TURN_DIR.RIGHT
		turn(turn_dir, delta)
	
	# Clear Left
	elif(lt_distance_right && !lt_distance_left):
		turn(TURN_DIR.LEFT, delta)
		
	# Clear Right
	elif(lt_distance_left && !lt_distance_right):
		turn(TURN_DIR.RIGHT, delta)

func _on_light_cycle_collider_direction_area_entered(area: Area3D) -> void:
	if(area.name == 'LightCycleNoseCollider'):
		var self_forward = -self.global_transform.basis.z
		var area_forward = -area.global_transform.basis.z
		
		# Check if the angle is approximately 90 degrees
		var angle = rad_to_deg(self_forward.angle_to(area_forward))
		if !abs(angle - 90) < 0.1:  # Allow for a small tolerance
			return
			
		var relative_position = area.global_transform.origin - self.global_transform.origin
		var self_right = self.global_transform.basis.x
		var side = self_right.dot(relative_position.normalized())
		
		attack_direction = TURN_DIR.RIGHT if side > 0 else TURN_DIR.LEFT

func _on_light_cycle_collider_velocity_area_entered(area: Area3D) -> void:
	var current_path = str(area.get_path())	
	if(area.name != 'LightCycleNoseCollider'):
		return

	if current_path.contains(lightcycle_path):
		return
	
	enemies_in_range += 1

func is_collision_detected(ray_cast):
	if(!ray_cast.get_collider()):
		return false
	
	if(!ray_cast.get_collider().get_parent() && ray_cast.get_collider().get_parent().name == 'LightCycleTrailCollider'):
		return false
		
	return true

func _on_light_cycle_collider_velocity_area_exited(area: Area3D) -> void:
	if(area.name != 'LightCycleNoseCollider'):
		return

	enemies_in_range -= 1

func set_random_turn_timer():
	while true:
		await get_tree().create_timer(randf_range(2.0, 4.0)).timeout
		do_random_turn = true
		
func get_turn_distance():
	if (turn_distance == 0.0):
		turn_distance = randf() * 50 + 45
		
	return turn_distance

func get_lighttrail_collision_distance(ray_cast):
	if(!ray_cast.get_collider()):
		return
		
	if(!ray_cast.get_collider().get_parent() && ray_cast.get_collider().get_parent().name == 'LightCycleTrailCollider'):
		return
		
	var collision_point = ray_cast_left.get_collision_point()
	var ray_origin = ray_cast_left.global_transform.origin
	var distance = ray_origin.distance_to(collision_point)
		
	return distance

func _on_light_cycle_nose_collider_body_entered(body: Node3D) -> void:
	if(body.name == "WallCollision"):
		kaboom()
		
	if(body.get_parent() &&body.get_parent().name == "LightCycleTrailCollider"):
		kaboom()
