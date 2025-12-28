extends Level

var arrow_scene: PackedScene = load("res://levels/arrow-mashing/arrow_up.tscn")
var arrow_array: Array[Node2D] = []
var direction_array: Array[int] = []
var colors: Array[Color] = [Color.FIREBRICK, Color.SEA_GREEN, Color.ROYAL_BLUE, Color.LIGHT_YELLOW]

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("move_up"):
		_compare_input(0)
	elif event.is_action_pressed("move_right"):
		_compare_input(1)
	elif event.is_action_pressed("move_down"):
		_compare_input(2)
	elif event.is_action_pressed("move_left"):
		_compare_input(3)

func _ready() -> void:
	var arrow_amount = 7 + floor(timeout * difficulty)
	for i in range(arrow_amount):
		var dir = randi() % 4
		var arrow: Node2D = arrow_scene.instantiate()
		arrow.modulate = colors[dir]
		arrow.rotation_degrees = dir * 90
		$Center.add_child(arrow)
		arrow.position.y = 110 * i
		arrow_array.append(arrow)
		direction_array.append(dir)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _compare_input(dir: int):
	if dir == direction_array[0]:
		print("match")
		arrow_array[0].visible = false
		arrow_array.pop_front()
		direction_array.pop_front()
		$Center.position.y = $Center.position.y - 110
		if direction_array.size() == 0:
			win.emit()
	else:
		lose.emit()
