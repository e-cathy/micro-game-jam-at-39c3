extends Level

@onready var blocks: Array[Node3D];

var size: int = 0

func _ready() -> void:
	self.build_cube(3) #round(self.difficulty * 3 + 1))
	pass

func build_cube(n: int) -> void:
	const BLOCK = preload("res://levels/puzzle-cube/block.tscn")
	self.size = n
	var offset = Vector3(-(n - 1) * 0.5, -(n - 1) * 0.5, -(n - 1) * 0.5)
	for z in range(n):
		for y in range(n):
			for x in range(n):
				var block = BLOCK.instantiate()
				block.global_position = Vector3(x, y, z) + offset
				block.set_occluded_directions(
					x == 0, x == n - 1,
					y == 0, y == n - 1,
					z == 0, z == n - 1
				)
				blocks.append(block)
				add_child(block)

	var rot_x = 0
	var rot_y = 0
	var spins = 2
	for _i in range(spins):
		if randi() % 2 == 0:
			rotate_slice_x(randi() % n, false)
			rot_x += 1
		else:
			rotate_slice_y(randi() % n, false)
			rot_y += 1
	if rot_x == 0:
		rotate_slice_x(randi() % n, false)
	if rot_y == 0:
		rotate_slice_y(randi() % n, false)
	@warning_ignore("integer_division")
	selection = n / 2
	update_selection()

func get_block(x, y, z) -> Node3D:
	var offset = Vector3(-(size - 1) * 0.5, -(size - 1) * 0.5, -(size - 1) * 0.5)
	for block in blocks:
		var pos = block.global_position - offset
		if round(pos.x) == x and round(pos.y) == y and round(pos.z) == z:
			return block
	assert(false)
	return null

func rotate_block() -> void:
	for block in blocks:
		block.global_transform = block.global_transform.rotated(Vector3(0, 1, 0), deg_to_rad(90))

func rotate_slice_x(column: int, reverse: bool, animated: bool = false) -> void:
	var new_transforms = []
	for z in range(size):
		for y in range(size):
			var block = get_block(column, y, z)
			new_transforms.append(block)
			new_transforms.append(block.global_transform)
			new_transforms.append(Vector3(1, 0, 0))
			new_transforms.append(-deg_to_rad(90) if reverse else deg_to_rad(90))

	apply_transforms(new_transforms, animated)

func rotate_slice_y(column: int, reverse: bool, animated: bool = false) -> void:
	var new_transforms = []
	for z in range(size):
		for x in range(size):
			var block = get_block(x, column, z)
			new_transforms.append(block)
			new_transforms.append(block.global_transform)
			new_transforms.append(Vector3(0, 1, 0))
			new_transforms.append(-deg_to_rad(90) if reverse else deg_to_rad(90))

	apply_transforms(new_transforms, animated)

func rotate_slice_z(column: int, reverse: bool, animated: bool = false) -> void:
	var new_transforms = []
	for y in range(size):
		for x in range(size):
			var block = get_block(x, y, column)
			new_transforms.append(block)
			new_transforms.append(block.global_transform)
			new_transforms.append(Vector3(0, 0, 1))
			new_transforms.append(-deg_to_rad(90) if reverse else deg_to_rad(90))

	apply_transforms(new_transforms, animated)

func apply_transforms(transforms, animated: bool) -> void:
	if animated:
		assert(animating >= 1)
		animating = 0.0
		animating_transforms = transforms
	else:
		@warning_ignore("integer_division")
		for idx in range(len(transforms) / 4):
			var block = transforms[idx * 4]
			var xform: Transform3D = transforms[idx * 4 + 1]
			var taxis: Vector3 = transforms[idx * 4 + 2]
			var angle = transforms[idx * 4 + 3]
			block.global_transform = xform.rotated(taxis, angle)

func update_selection():
	if axis == "x":
		$Selection.size = Vector3(1, size, size)
		$Selection.position = Vector3(selection - (size - 1) * 0.5, 0, 0)
	elif axis == "z":
		$Selection.size = Vector3(size, size, 1)
		$Selection.position = Vector3(0, 0, selection - (size - 1) * 0.5)
	else:
		$Selection.size = Vector3(size, 1, size)
		$Selection.position = Vector3(0, selection - (size - 1) * 0.5, 0)

func check_solved():
	var check_orientation = blocks[0].get_orientation()
	for block in blocks:
		if block.get_orientation() != check_orientation:
			return false
	return true

func win_solved():
	if check_solved():
		win.emit()

func _timeout():
	# finish queued inputs, then win or lose
	ending = true

var ending = false
var animating_transforms = []
var animating = 1.0
var queued_inputs = []
var axis = "x"
var selection = 1
var double_click_timeout = 0
var double_click_key = ""
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if double_click_timeout > 0:
		double_click_timeout -= delta
	if len(queued_inputs) > 0:
		if animating >= 1.0:
			var input = queued_inputs.pop_front()
			if axis == "x":
				rotate_slice_x(input[2], input[1], true)
			elif axis == "y":
				rotate_slice_y(input[2], input[1], true)
			else:
				rotate_slice_z(input[2], input[1], true)
	elif ending:
		if animating >= 1.0:
			if check_solved():
				win.emit()
			else:
				lose.emit()
	
	if len(animating_transforms) > 0 and animating < 1.0:
		animating += delta / 0.25
		@warning_ignore("integer_division")
		for idx in range(len(animating_transforms) / 4):
			var block = animating_transforms[idx * 4]
			var xform: Transform3D = animating_transforms[idx * 4 + 1]
			var taxis: Vector3 = animating_transforms[idx * 4 + 2]
			var angle = animating_transforms[idx * 4 + 3]
			block.global_transform = xform.rotated(taxis, angle * easing(min(animating, 1.0)))
		if animating >= 1.0:
			win_solved()

func easing(x: float) -> float:
	return 1 - pow(1 - x, 3)

var saved_axes = {"x": 1, "y" : 1, "z": 1}
var last_xz = "x"
func swap_axis(new_axis):
	if axis == "x" or axis == "z":
		last_xz = axis
	saved_axes[axis] = selection
	axis = new_axis
	selection = saved_axes[new_axis]

func double_click_swap_axis(action, new_axis):
	if double_click_key == action and double_click_timeout > 0:
		axis = new_axis
		return true
	else:
		double_click_key = action
		double_click_timeout = 0.5
		return false

func _input(event: InputEvent) -> void:
	if ending:
		return

	if axis == "x":
		if event.is_action_pressed("move_left"):
			selection += 1
			if selection >= size:
				selection = 0 if double_click_swap_axis("move_left", "z") else size - 1
		if event.is_action_pressed("move_right"):
			selection -= 1
			if selection < 0:
				selection = 0
		if event.is_action_pressed("move_up"):
			swap_axis("y")
		if event.is_action_pressed("move_down"):
			swap_axis("y")
	elif axis == "z":
		if event.is_action_pressed("move_left"):
			selection += 1
			if selection >= size:
				selection = size - 1
		if event.is_action_pressed("move_right"):
			selection -= 1
			if selection < 0:
				selection = size - 1 if double_click_swap_axis("move_right", "x") else 0
		if event.is_action_pressed("move_up"):
			swap_axis("y")
		if event.is_action_pressed("move_down"):
			swap_axis("y")
	else:
		if event.is_action_pressed("move_up"):
			selection += 1
			if selection >= size:
				selection = size - 1
		if event.is_action_pressed("move_down"):
			selection -= 1
			if selection < 0:
				selection = 0
		if event.is_action_pressed("move_left"):
			swap_axis(last_xz)
		if event.is_action_pressed("move_right"):
			swap_axis(last_xz)
	
	if event.is_action_pressed("action1") or event.is_action_pressed("action2"):
		var reverse = event.is_action_pressed("action1")
		if axis == "x":
			reverse = not reverse
		queued_inputs.push_back([axis, reverse, selection])

	update_selection()
