extends Level

var thief_found : bool = false

func _ready() -> void:
	timeout = 6
	%player.found_thief.connect(_win)
	%occlusion_rect.visible = true

func _timeout():
	if thief_found:
		win.emit()
	else:
		lose.emit()

func _win() -> void:
	thief_found = true
	%windelay.start(1)

func _on_windelay_timeout() -> void:
	win.emit()
