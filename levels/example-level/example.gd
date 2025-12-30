extends Level # IMPORTANT: Levels must extend Level


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$Difficulty.text = $Difficulty.text.replace("$$", str(difficulty))


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("move_up"):
		win.emit()
		
	if event.is_action_pressed("move_down"):
		lose.emit()
