extends TileMapLayer

@export var pipe_origin: Vector2i = Vector2i(11, 3)
@export var pipe_drain: Vector2i = Vector2i(16, 4)
@export var pipes: int = 4
@export var space_between: int = 2
@export var height: int = 10

func _ready() -> void:
	regenerate()

func regenerate() -> void:
	assert(height >= pipes, "not enough height to randomize pipe locations")
	assert(pipes > 2, "need at least 3 pipes")
	
	@warning_ignore("integer_division")
	var offset = -(pipes + space_between * (pipes - 1)) / 2
	var width = (pipes - 1) * (space_between + 1) + 1
	
	var pipe_vertical = pipe_origin + Vector2i(0, 1)
	var pipe_horizontal = pipe_origin + Vector2i(2, 3)
	var pipe_cross_1 = pipe_origin + Vector2i(5, 2)
	var pipe_cross_2 = pipe_origin + Vector2i(5, 3)
	var pipe_corner_se = pipe_origin + Vector2i(1, 1)
	var pipe_corner_sw = pipe_origin + Vector2i(2, 1)
	var pipe_corner_ne = pipe_origin + Vector2i(1, 2)
	var pipe_corner_nw = pipe_origin + Vector2i(2, 2)
	
	while true:
		clear()

		# fill sockets
		var pipe_locs: Array[int] = []
		var unchanged = range(pipes)
		for pipe in range(pipes):
			var x = pipe * (space_between + 1) + offset
			pipe_locs.append(x)
			self.set_cell(Vector2i(x, -height - 1), 0, pipe_origin)
			self.set_cell(Vector2i(x, 0), 0, pipe_drain)

		var cross_locs: Array[Vector2i] = []
		var last_pipe = -1
		@warning_ignore("integer_division")
		for y in range(-height, -pipes / 2):
			var pipe = randi_range(0, pipes - 1)
			if last_pipe == pipe and randf() < 0.8:
				pipe = randi_range(0, pipes - 1)
			for other in range(pipes):
				if other != pipe:
					self.set_cell(Vector2i(pipe_locs[other], y), 0, pipe_vertical)

			var found = false
			for _retry in range(20):
				var old_x = pipe_locs[pipe]
				var next_x = randi_range(0, width - 1) + offset
				var overlaps = false
				for other in range(pipes):
					# check all pipes, also self, to reject same position!
					if pipe_locs[other] == next_x:
						overlaps = true
						break
				if overlaps:
					continue
				var crossed = false
				# old_x and next_x (and by extension min_x and max_x) are guaranteed
				# to be different due to the overlap check above
				var min_x = min(old_x, next_x)
				var max_x = max(old_x, next_x)
				for other in range(pipes):
					if other != pipe:
						var other_loc = pipe_locs[other]
						if other_loc > min_x and other_loc < max_x:
							cross_locs.append(Vector2i(other_loc, y))
							crossed = true
				if not crossed:
					continue
				var right_corner = pipe_corner_nw if next_x < old_x else pipe_corner_sw
				var left_corner = pipe_corner_se if next_x < old_x else pipe_corner_ne
				for x in range(min_x + 1, max_x):
					self.set_cell(Vector2i(x, y), 0, pipe_horizontal)
				self.set_cell(Vector2i(min_x, y), 0, left_corner)
				self.set_cell(Vector2i(max_x, y), 0, right_corner)
				pipe_locs[pipe] = next_x
				unchanged.erase(pipe)
				found = true
				break
			if not found:
				self.set_cell(Vector2i(pipe_locs[pipe], y), 0, pipe_vertical)

		var pipe_indices: Array = range(pipes)
		var missing_sockets: Array = range(pipes)
		for pipe in pipe_indices:
			if is_x_on_socket(pipe_locs[pipe]):
				missing_sockets.erase(get_socket_by_x(pipe_locs[pipe]))
		# resolve missing in the last few tiles (retry entire algorithm if we don't fit everything)
		@warning_ignore("integer_division")
		for y in range(-pipes / 2, 0):
			pipe_indices.shuffle()
			missing_sockets.shuffle()
			for other in range(pipes):
				self.set_cell(Vector2i(pipe_locs[other], y), 0, pipe_vertical)

			if len(missing_sockets) > 0:
				for pipe in pipe_indices:
					if is_x_on_socket(pipe_locs[pipe]):
						continue
					var connect_to_socket = missing_sockets.pop_front()
					var next_x = get_pipe_x(connect_to_socket)
					var old_x = pipe_locs[pipe]
					# next_x and old_x can't be the same, since missing_socket would
					# not contain this pipe anymore if it's already on same X.
					var min_x = min(old_x, next_x)
					var max_x = max(old_x, next_x)
					for other in range(pipes):
						if other != pipe:
							var other_loc = pipe_locs[other]
							if other_loc > min_x and other_loc < max_x:
								cross_locs.append(Vector2i(other_loc, y))
					var right_corner = pipe_corner_nw if next_x < old_x else pipe_corner_sw
					var left_corner = pipe_corner_se if next_x < old_x else pipe_corner_ne
					for x in range(min_x + 1, max_x):
						self.set_cell(Vector2i(x, y), 0, pipe_horizontal)
					self.set_cell(Vector2i(min_x, y), 0, left_corner)
					self.set_cell(Vector2i(max_x, y), 0, right_corner)
					pipe_locs[pipe] = next_x
					unchanged.erase(pipe)
					break

		if len(missing_sockets) > 0 or len(cross_locs) == 0 or len(unchanged) > max(1, pipes * 0.3) or unchanged.has(0) or unchanged.has(pipes - 1):
			# retry, it's possible (although unlikely) that we reach this, since for always guaranteed
			# pipe generation we need at least `pipes` amount of height where we resolve
			#
			# Also retry if there weren't any crossed pipes
			#
			# Also retry if there is more than one pipe directly connected to the end
			#
			# Also retry if an unchanged pipe is at start or end
			continue

		for loc in cross_locs:
			self.set_cell(loc, 0, pipe_cross_1 if randi_range(0, 1) == 0 else pipe_cross_2)
		break

func is_corner(pos: Vector2i) -> int: # 0 == no corner, 1 == left facing, 2 == right facing
	var texture = get_cell_atlas_coords(pos)
	var pipe_corner_se = pipe_origin + Vector2i(1, 1)
	var pipe_corner_sw = pipe_origin + Vector2i(2, 1)
	var pipe_corner_ne = pipe_origin + Vector2i(1, 2)
	var pipe_corner_nw = pipe_origin + Vector2i(2, 2)
	if texture == pipe_corner_se or texture == pipe_corner_ne:
		return 2
	elif texture == pipe_corner_sw or texture == pipe_corner_nw:
		return 1
	else:
		return 0

func get_pipe_x(pipe: int) -> int:
	@warning_ignore("integer_division")
	var offset = -(pipes + space_between * (pipes - 1)) / 2
	return pipe * (space_between + 1) + offset

func is_x_on_socket(x: int) -> bool:
	@warning_ignore("integer_division")
	var offset = -(pipes + space_between * (pipes - 1)) / 2
	return (x - offset) % (space_between + 1) == 0

func get_socket_by_x(x: int) -> int:
	@warning_ignore("integer_division")
	var offset = -(pipes + space_between * (pipes - 1)) / 2
	@warning_ignore("integer_division")
	return (x - offset) / (space_between + 1)

@warning_ignore("shadowed_variable")
func coord(pos: Vector2i) -> Vector2:
	return self.to_global(self.map_to_local(pos))
