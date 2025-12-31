extends TileMapLayer

const Pipes = preload("res://levels/blind-pipes/pipes.gd")
const Ball = preload("res://levels/blind-pipes/ball.gd")

@export var pipes: Pipes
@export var ball: Ball

var target_pos: float = 0
var x: int:
	get:
		return x
	set(value):
		x = value
		target_pos = pipes.coord(Vector2i(pipes.get_pipe_x(x), 0)).x + 18

var dropping: bool = false
var dropped: bool = false

func _ready() -> void:
	@warning_ignore("integer_division")
	x = pipes.pipes / 2

func _process(delta: float) -> void:
	var gx = global_position.x
	if abs(gx - target_pos) < 3:
		global_position.x = target_pos
		if dropping and not dropped:
			dropped = true
			_start_drop()
	elif abs(gx - target_pos) > 1:
		global_position.x = round((gx - target_pos) * pow(0.6, delta * 30) + target_pos);

func drop():
	dropping = true

func _start_drop():
	ball.drop(x)

func _input(event: InputEvent) -> void:
	if dropping:
		return
	if event.is_action_pressed("move_left"):
		if x > 0:
			x -= 1
	elif event.is_action_pressed("move_right"):
		if x + 1 < pipes.pipes:
			x += 1
	elif event.is_action_pressed("action1") or event.is_action_pressed("action2"):
		drop()
