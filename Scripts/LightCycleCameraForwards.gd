extends Camera3D

@export var target: Node3D
@export var follow_speed: float = 5.0
@export var rotation_speed: float = 5.0
@export var offset: Vector3 = Vector3(0, 5, -10) # Offset in the target's local space

func _process(delta):
	if target:
		# Calculate the target's position in global space, including the local offset
		var target_position = target.global_transform.origin + (target.global_transform.basis * offset)

		# Smoothly update the camera's position
		global_transform.origin = global_transform.origin.lerp(target_position, follow_speed * delta)

		# Calculate the target's rotation with a 180-degree flip
		var flipped_basis = target.global_transform.basis.rotated(Vector3.UP, deg_to_rad(180))

		# Smoothly update the camera's rotation
		global_transform.basis = global_transform.basis.slerp(flipped_basis, rotation_speed * delta)
