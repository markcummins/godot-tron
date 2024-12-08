extends Node3D

class_name LightCycleBase

@export var max_speed: float = 60.0
@export var min_speed: float = 40.0
@export var friction: float = 2.0
@export var acceleration: float = 10.0
@export var turn_speed: float = 5.0

@onready var light_cycle_scene: Node3D = $".."

@onready var trail_parent: Node3D = $"../LightCycleTrail"

@onready var audio_stream_player_3d: AudioStreamPlayer3D = $AudioStreamPlayer3D

var velocity: float = 0.0
var target_rotation: float = 0.0

func ready_extend():
	audio_stream_player_3d.stream.loop = true
	audio_stream_player_3d.play()

func process_extend(delta):
	translate(Vector3(0, 0, velocity * delta))
	rotation.y = lerp_angle(rotation.y, target_rotation, turn_speed * delta)
		
	trail_parent.call("update_trail", transform.origin)
	
	engine_pitch_adjust()

func turn_left(delta):
	target_rotation += deg_to_rad(90)
	
func turn_right(delta):
	target_rotation -= deg_to_rad(90)
	rotation.y = lerp_angle(rotation.y, target_rotation, turn_speed * delta)

func kaboom():
	print('kablam')
	queue_free()

func engine_pitch_adjust():
	var l1 = 3.0
	var l2 = 3.05
	var weight = velocity
	
	audio_stream_player_3d.pitch_scale = lerp(l1, l2, weight)
