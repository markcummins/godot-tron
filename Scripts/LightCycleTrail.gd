extends Node3D

@export var max_trail_length: int = 20

var trail_points: Array = []

@onready var trail_path: Path3D = $TrailPath
@onready var trail_mesh: CSGPolygon3D = $TrailMesh

func update_trail(bike_position: Vector3) -> void:
	var flat_position = Vector3(bike_position.x, 0, bike_position.z)

	# Set the First Point
	if trail_points.size() <= 1:
		trail_points.append(flat_position)
		update_curve();
		return
			
	var is_moving_x = trail_points[-1].x == flat_position.x
	var is_moving_y = trail_points[-1].z == flat_position.z
	
	if (is_moving_x || is_moving_y):
		trail_points.pop_back()
		trail_points.append(flat_position)
		update_curve()

func turn(bike_position: Vector3) -> void:
	var flat_position = Vector3(bike_position.x, 0, bike_position.z)
	
	trail_points.append(flat_position)
	update_curve()

func update_curve():
	# Limit trail length
	if trail_points.size() > max_trail_length:
		trail_points.pop_front()
		
	# Update the trail path with the new points
	trail_path.curve.clear_points()
	for point in trail_points:
		trail_path.curve.add_point(point)
