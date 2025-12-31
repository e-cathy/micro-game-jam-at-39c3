extends TileMapLayer

const Pipes = preload("res://levels/blind-pipes/pipes.gd")
@export var pipes: Pipes

var target: float
func _ready() -> void:
	var start = randi_range(0, pipes.pipes - 1)
	var end = (start + randi_range(1, pipes.pipes - 2))
	if end >= pipes.pipes:
		end -= pipes.pipes
	global_position.x = pipes.coord(Vector2(pipes.get_pipe_x(start), 0)).x - 18
	target = pipes.coord(Vector2(pipes.get_pipe_x(end), 0)).x - 18

var wait_time = 1.0
func _process(delta: float) -> void:
	if wait_time > 0:
		wait_time -= delta
	else:
		global_position.x = (global_position.x - target) * pow(0.5, delta) + target
