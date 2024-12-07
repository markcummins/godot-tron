extends Node3D

var spin_speed = -1000.0
 
@onready var wheel_back: MeshInstance3D = $"wheel back"
@onready var wheel_front: MeshInstance3D = $"wheel front"

func _process(delta):
	wheel_back.rotate_z(deg_to_rad(spin_speed * delta))
	wheel_front.rotate_z(deg_to_rad(spin_speed * delta))
