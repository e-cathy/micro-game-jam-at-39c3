extends Level

func _ready() -> void:
	timeout = 2

func _unhandled_key_input(event):
	if event.is_pressed():
		lose.emit()

func _timeout():
	win.emit()
