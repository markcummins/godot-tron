extends Node3D

var frame_counter: int = 0
@export var update_frequency: int = 5

var current_pos_start: Vector3
var current_pos_end: Vector3

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

	current_pos_start = current_pos_end
	current_pos_end = flat_position
	
	if(current_pos_end != Vector3.ZERO):
		draw_trail()

func draw_trail():
	draw_trail_path()
	draw_trail_collision_path()

func draw_trail_collision_path():
	 # Calculate midpoint and orientation
	var midpoint = (current_pos_start + current_pos_end) / 2
	var direction = (current_pos_end - current_pos_start).normalized()
	var basis = Basis().looking_at(direction, Vector3.UP)
	var shape_transform = Transform3D(basis, midpoint)

	# Create and configure the collision shape
	var box_shape = BoxShape3D.new()
	box_shape.size = Vector3(trail_width * 2, trail_height, (current_pos_end - current_pos_start).length())

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
	# Direction vector between points & Perpendicular vector for trail width
	var direction = (current_pos_end - current_pos_start).normalized()
	var perpendicular = Vector3(-direction.z, 0, direction.x) * trail_width

	# Commit the mesh
	var st = generate_mesh(current_pos_start, current_pos_end, perpendicular)
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
