extends Level

const WHITE := Vector2i(0,0)
const BLACK := Vector2i(1,0)
const BORDER_RIGHT := 19
const BORDER_BOTTOM := 10

var snake_head := Vector2i(5,5)
var snake_body: Array[Vector2i] = [Vector2i(4,5),Vector2i(3,5),Vector2i(2,5)]
var snake_dir := Vector2i.RIGHT
var has_eaten := false
var next_dir := Vector2i.ZERO

var apples: Array[Vector2i] = []

@onready var tilemap := $TileMapLayer

var tick := 0
var every_th_tick := 8

func _ready() -> void:
	for i in 4:
		var apple_position := get_random_position()
		while !is_valid_apple_position(apple_position):
			apple_position = get_random_position()
		apples.append(apple_position)

# more explicit with ifs to make conditions more readable
func is_valid_apple_position(apple_position: Vector2i) -> bool:
	# Let's block off the area inside and immediately in front of the snake
	if apple_position.y == snake_head.y:
		return false
	# We also don't want overlapping apples
	if apple_position in apples:
		return false
	return true

func get_random_position() -> Vector2i:
	var x := randi() % (BORDER_RIGHT - 1) + 1 # 1-18
	var y := randi() % (BORDER_BOTTOM - 1) + 1 # 1-9
	return Vector2i(x, y)

func _physics_process(_delta: float) -> void:
	tick = tick + 1
	if tick % every_th_tick == 0:
		process_snake_move()
		check_collision()
		check_win()

func process_snake_move() -> void:
	# avoid from turning snake inward, and don't change dir if no change was made
	if next_dir != Vector2i.ZERO and snake_dir + next_dir != Vector2i.ZERO:
		snake_dir = next_dir
		next_dir = Vector2i.ZERO
	if not has_eaten:
		snake_body.resize(snake_body.size() - 1)
	snake_body.push_front(snake_head)
	snake_head = snake_head + snake_dir
	has_eaten = false

func check_collision() -> void:
	if snake_head.x == BORDER_RIGHT or snake_head.x == 0 or snake_head.y == BORDER_BOTTOM or snake_head.y == 0:
		lose.emit()
	elif snake_head in snake_body:
		lose.emit()
	elif snake_head in apples:
		apples.erase(snake_head)
		has_eaten = true
		
func check_win() -> void:
	if apples.is_empty():
		win.emit()

func _process(_delta: float) -> void:
	clear_board()
	draw_snake()
	draw_apples()

func clear_board() -> void:
	for x in range(1,BORDER_RIGHT):
		for y in range(1,BORDER_BOTTOM):
			tilemap.set_cell(Vector2i(x,y), 0, BLACK)

func draw_snake() -> void:
	tilemap.set_cell(snake_head, 0, WHITE)
	for cell in snake_body:
		tilemap.set_cell(cell, 0, WHITE)

func draw_apples() -> void:
	for cell in apples:
		tilemap.set_cell(cell, 0, WHITE)
		
func _input(event: InputEvent) -> void:
	if event.is_action_pressed("move_up"):
		next_dir = Vector2i.UP
	elif event.is_action_pressed("move_down"):
		next_dir = Vector2i.DOWN
	elif event.is_action_pressed("move_left"):
		next_dir = Vector2i.LEFT
	elif event.is_action_pressed("move_right"):
		next_dir = Vector2i.RIGHT
