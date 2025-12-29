extends Level


const BUTTONS = {
	"UP": "move_up",
	"DOWN": "move_down",
	"LEFT": "move_left",
	"RIGHT": "move_right",
	"SPACE": "action1",
	"ENTER": "action2",
}


var LETTERS = "PDONLEFTIGHTSPCEENTE"
const DIFFICULTIES = [0.25, 0.5, 0.75]
const UP_LEFT = Vector2i.UP + Vector2i.LEFT
const UP_RIGHT = Vector2i.UP + Vector2i.RIGHT
const DOWN_LEFT = Vector2i.DOWN + Vector2i.LEFT
const DOWN_RIGHT = Vector2i.DOWN + Vector2i.RIGHT


var action :String


func _ready() -> void:
	var button = BUTTONS.keys().pick_random()
	action = BUTTONS[button]
	var mode = 0
	while mode < len(DIFFICULTIES) and difficulty > DIFFICULTIES[mode]:
		mode += 1
	for i in 4-mode:
		LETTERS += "_X"
	var dir_description = randi_range(0, mode)
	match dir_description:
		0: setup_orthogonal(Vector2i.RIGHT, button)
		1: setup_orthogonal(Vector2i.DOWN, button)
		2: setup_diagonal(DOWN_RIGHT, button)
		3: setup_diagonal(DOWN_LEFT, button)
	randomize_unfilled()


func setup_orthogonal(direction :Vector2i, button :String) -> void:
	var line = randi_range(0, 4)
	var start = randi_range(0, 5-len(button))
	if direction.x == 0:
		var pos = Vector2i(line, start if direction.y > 0 else start + len(button) - 1)
		for i in len(button):
			(get_node("%GridContainer/Label" + str(line) + str(pos.y)) as Label).text = button[i]
			pos += direction
	else:
		var pos = Vector2i(start if direction.x > 0 else start + len(button) - 1, line)
		for i in len(button):
			(get_node("%GridContainer/Label" + str(pos.x) + str(line)) as Label).text = button[i]
			pos += direction


func setup_diagonal(direction :Vector2i, button :String) -> void:
	var max_diagonal = 5 - len(button)
	var diagonal = randi_range(-max_diagonal, max_diagonal)
	var start = randi_range(0, 5 - abs(diagonal) - len(button))
	var pos :Vector2i
	match direction:
		UP_LEFT: pos = Vector2i(4, 4)
		UP_RIGHT: pos = Vector2i(0, 4)
		DOWN_LEFT: pos = Vector2i(4, 0)
		DOWN_RIGHT: pos = Vector2i(0, 0)
	if diagonal > 0:
		pos += diagonal * direction.x * Vector2i.RIGHT
	else:
		pos -= diagonal * direction.y * Vector2i.DOWN
	pos += start * direction
	for i in len(button):
		(get_node("%GridContainer/Label" + str(pos.x) + str(pos.y)) as Label).text = button[i]
		pos += direction


func randomize_unfilled() -> void:
	for node in %GridContainer.get_children():
		if node.text == "_":
			node.text = LETTERS[randi_range(0, len(LETTERS)-1)]


func _input(event: InputEvent) -> void:
	for a in BUTTONS.values():
		if event.is_action_pressed(a):
			# INFO manno win.emit(a == action)
			if a == action: win.emit()
			else: lose.emit()
