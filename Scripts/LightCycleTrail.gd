extends Node3D

var frame_counter: int = 0
@export var update_frequency: int = 5

var trail_points: Array = []
@export var maximum_trail_points: int = 100

@export var trail_width: float = 0.1
@export var trail_height: float = 0.5

@onready var trail_elements: Node3D = $LightCycleTrailElements
@onready var trail_collision: Area3D = $LightCycleTrailCollider

func update_trail(bike_position: Vector3) -> void:
	frame_counter += 1
	if frame_counter % update_frequency != 0:
		return

	frame_counter = 0 
	
	var flat_position = Vector3(bike_position.x, 0, bike_position.z)

	if trail_points.size() <= 1:
		trail_points.append(flat_position)
		return

	trail_points.append(flat_position)
	draw_trail()

func turn(bike_position: Vector3) -> void:
	var flat_position = Vector3(bike_position.x, 0, bike_position.z)
	
	trail_points.append(flat_position)
	draw_trail()

func draw_trail():
	draw_trail_path()
	draw_trail_collision_path()

func draw_trail_collision_path():
   # Ensure there are enough points to form a segment
	if trail_points.size() < 2:
		return

	# Get the last two points
	var current_point = trail_points[trail_points.size() - 2]
	var next_point = trail_points[trail_points.size() - 1]
	
	 # Calculate midpoint and orientation
	var midpoint = (current_point + next_point) / 2
	var direction = (next_point - current_point).normalized()
	var basis = Basis().looking_at(direction, Vector3.UP)
	var shape_transform = Transform3D(basis, midpoint)

	# Create and configure the collision shape
	var box_shape = BoxShape3D.new()
	box_shape.size = Vector3(trail_width * 2, trail_height, (next_point - current_point).length())

	# Create a new StaticBody3D for this segment
	var collision_segment = StaticBody3D.new()
	var collision_shape = CollisionShape3D.new()
	collision_shape.shape = box_shape
	collision_segment.add_child(collision_shape)
	collision_segment.transform = shape_transform

	# Add the segment to the scene tree
	trail_collision.add_child(collision_segment)

	# Remove old collision segments if needed
	if trail_collision.get_child_count() > maximum_trail_points:
		trail_collision.get_child(0).queue_free()

func draw_trail_path():
	# Ensure we have enough points to form a segment
	if trail_points.size() < 2:
		return

	# Get the last two points
	var current_point = trail_points[trail_points.size() - 2]
	var next_point = trail_points[trail_points.size() - 1]

	# Direction vector between points & Perpendicular vector for trail width
	var direction = (next_point - current_point).normalized()
	var perpendicular = Vector3(-direction.z, 0, direction.x) * trail_width

	# Commit the mesh
	var st = generate_mesh(current_point, next_point, perpendicular)
	var trail_mesh = st.commit()

	# Create a new MeshInstance3D
	var segment_instance = MeshInstance3D.new()
	segment_instance.mesh = trail_mesh
	segment_instance.name = "TrailSegment"

	 #Add the segment to the scene
	trail_elements.add_child(segment_instance)
	
	# Remove old segments if there are too many
	if trail_elements.get_child_count() > maximum_trail_points:
		trail_elements.get_child(0).queue_free()

func generate_mesh(current_point, next_point, perpendicular):
	var vertical_offset = Vector3(0, trail_height, 0)
	
	# Define the 8 vertices of the rectangular segment
	var bottom_left_start = current_point + perpendicular
	var bottom_right_start = current_point - perpendicular
	var bottom_left_end = next_point + perpendicular
	var bottom_right_end = next_point - perpendicular

	var top_left_start = bottom_left_start + vertical_offset
	var top_right_start = bottom_right_start + vertical_offset
	var top_left_end = bottom_left_end + vertical_offset
	var top_right_end = bottom_right_end + vertical_offset

	# Create the new mesh
	var st = SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)

	# Add the vertices for one segment
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
	
	return st
