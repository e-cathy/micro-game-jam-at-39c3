extends Node3D

func set_occluded_directions(xneg, xpos, yneg, ypos, zneg, zpos) -> void:
	var dir1 = Vector3(
		1 if not xpos else 0,
		1 if not ypos else 0,
		1 if not zpos else 0,
	)
	var dir2 = Vector3(
		-1 if not xneg else 0,
		-1 if not yneg else 0,
		-1 if not zneg else 0,
	)

	var material: ShaderMaterial = $Cube.get_surface_override_material(0)
	var newmat = material.duplicate()
	newmat.set_shader_parameter("black_out_direction1", dir1)
	newmat.set_shader_parameter("black_out_direction2", dir2)
	$Cube.set_surface_override_material(0, newmat)

func get_orientation() -> int:
	# this could probably be done better but I can't wrap my head around it
	# (my other attempts failed whenever the transforms resulted in the result being rotated 90 degrees on Y without Y rotations (through combinations of X and Z, resulting in a flipped cube)
	return get_side(Vector3(1, 0, 0)) \
		| get_side(Vector3(-1, 0, 0)) << 4 \
		| get_side(Vector3(0, 1, 0)) << 8 \
		| get_side(Vector3(0, -1, 0)) << 12 \
		| get_side(Vector3(0, 0, 1)) << 16 \
		| get_side(Vector3(0, 0, -1)) << 20

func get_side(global: Vector3) -> int:
	var side = basis.inverse() * global
	if side.dot(Vector3(1, 0, 0)) > 0.9:
		return 0
	elif side.dot(Vector3(-1, 0, 0)) > 0.9:
		return 1
	elif side.dot(Vector3(0, 1, 0)) > 0.9:
		return 2
	elif side.dot(Vector3(0, -1, 0)) > 0.9:
		return 3
	elif side.dot(Vector3(0, 0, 1)) > 0.9:
		return 4
	elif side.dot(Vector3(0, 0, -1)) > 0.9:
		return 5
	else:
		assert(false)
		return -1
