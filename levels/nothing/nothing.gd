extends Level # IMPORTANT: Levels must extend Level

var randn = 0
var buttons = ['W', 'A', 'S', 'D', 'SPACE', 'ENTER']
var actions = ["move_up", "move_down", "move_left", "move_right", "action1", "action2"]

var buttons_sometime_later = {
	'W': "move_up",
	'A': "move_down",
	'S': "move_left",
	'D': "move_right",
	'SPACE': "action1",
	'ENTER': "action2",
}

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$Difficulty.text = $Difficulty.text.replace("$$", str(difficulty))
	
	randn = randi_range(0, buttons.size()-1)
	$HBoxContainer/WinHintLabel.text = 'Press ' + buttons[randn] + ' to Win'
	$HBoxContainer/LoseHintLabel.text = 'Press ' + buttons[(randn+1)%(buttons.size()-1)] + ' to Lose'


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _input(event: InputEvent) -> void:
	if event.is_action_pressed(actions[randn]):
		win.emit()
		
	if event.is_action_pressed(actions[(randn+1)%(buttons.size()-1)]):
		lose.emit()
