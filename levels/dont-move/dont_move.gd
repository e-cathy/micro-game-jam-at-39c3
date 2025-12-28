extends Level

func _ready() -> void:
	timeout = 10 
	"""
	this is the default timeout that lets you lose when running out.
	we dont want this since this level is won by not doing any input for a specific amount of time
	"""

func _unhandled_key_input(event):
	if event.is_pressed():
		lose.emit()

func _on_timer_timeout() -> void:
	# this is the timer that lets us win if it runs out
	win.emit()
