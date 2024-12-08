extends LightCycleBase

class_name LightCycleBot

var turn = false

func _ready():
	random_turn()
	ready_extend()

func random_turn():
	while true:
		await get_tree().create_timer(randf_range(2.0, 7.0)).timeout
		turn = true
	
func _process(delta: float) -> void:
	var input_vector = 0.0
	
	velocity = lerp(velocity, clamp(input_vector * max_speed, min_speed, max_speed), acceleration * delta)
#
	if input_vector == 0.0:
		velocity = lerp(velocity, min_speed, friction * delta)
#
	translate(Vector3(0, 0, velocity * delta))
	
	if(turn):
		turn_left(delta) if randi() % 2 == 0 else turn_right(delta)
		turn = false

	process_extend(delta)
	
