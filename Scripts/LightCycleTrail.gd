extends Node3D

var frame_counter: int = 0
var trail_points: Array = []
var st: SurfaceTool = SurfaceTool.new()

@export var update_frequency: int = 5
@export var minimum_trail_points: int = 100

@export var trail_width: float = 0.1
@export var trail_height: float = 1.0

@onready var light_trail: MeshInstance3D = $MeshInstance3D

func _ready():
	var lt_material = load("res://Materials/LightTrall.tres")
	if lt_material:
		light_trail.material_override = lt_material

func update_trail(bike_position: Vector3) -> void:
	frame_counter += 1
	if frame_counter % update_frequency != 0:
		return

	frame_counter = 0 
	
	var flat_position = Vector3(bike_position.x, 0, bike_position.z)

	if trail_points.size() <= 1:
		trail_points.append(flat_position)
		draw_trail()
		return

	var is_moving_x = trail_points[-1].x == flat_position.x
	var is_moving_y = trail_points[-1].z == flat_position.z
	#
	if is_moving_x or is_moving_y:
		trail_points.pop_back()
		
	trail_points.append(flat_position)
	draw_trail()

func turn(bike_position: Vector3) -> void:
	var flat_position = Vector3(bike_position.x, 0, bike_position.z)
	
	trail_points.append(flat_position)
	draw_trail()

func draw_trail():
	# Ensure we have enough points to form a trail
	if trail_points.size() < 2:
		return
		
	# Performance
	if trail_points.size() > minimum_trail_points && Performance.get_monitor(Performance.TIME_FPS) < 75:
		trail_points = trail_points.slice(5, trail_points.size() - 5)

	st.clear() 
	st.begin(Mesh.PRIMITIVE_TRIANGLES)

	for i in range(trail_points.size() - 1):
		var current_point = trail_points[i]
		var next_point = trail_points[i + 1]

		# Direction vector between points
		var direction = (next_point - current_point).normalized()

		# Perpendicular vector for trail width
		var perpendicular = Vector3(-direction.z, 0, direction.x) * trail_width

		# Vertical offset for trail height
		var vertical_offset = Vector3(0, trail_height, 0)

		# Define the 8 vertices of the rectangular segment
		# Bottom face
		var bottom_left_start = current_point + perpendicular
		var bottom_right_start = current_point - perpendicular
		var bottom_left_end = next_point + perpendicular
		var bottom_right_end = next_point - perpendicular

		# Top face
		var top_left_start = bottom_left_start + vertical_offset
		var top_right_start = bottom_right_start + vertical_offset
		var top_left_end = bottom_left_end + vertical_offset
		var top_right_end = bottom_right_end + vertical_offset

		# Top face
		st.add_vertex(top_left_start)
		st.add_vertex(top_right_start)
		st.add_vertex(top_left_end)

		st.add_vertex(top_left_end)
		st.add_vertex(top_right_start)
		st.add_vertex(top_right_end)
		
		# Left side
		st.add_vertex(bottom_left_start)
		st.add_vertex(bottom_left_end)
		st.add_vertex(top_left_start)

		st.add_vertex(top_left_start)
		st.add_vertex(bottom_left_end)
		st.add_vertex(top_left_end)

		# Right side
		st.add_vertex(bottom_right_start)
		st.add_vertex(top_right_start)
		st.add_vertex(bottom_right_end)

		st.add_vertex(bottom_right_end)
		st.add_vertex(top_right_start)
		st.add_vertex(top_right_end)

	var trail_mesh = st.commit()
	light_trail.mesh = trail_mesh
	
