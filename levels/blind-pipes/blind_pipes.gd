extends Level

func _ready() -> void:
	$CenterContainer/ViewBlocker/AnimationPlayer.play("move_right")

func _on_ball_dropped() -> void:
	$CenterContainer/ViewBlocker/AnimationPlayer.play("move_away")

func _on_ball_caught() -> void:
	win.emit()

func _on_ball_lost() -> void:
	lose.emit()

func _timeout():
	$CenterContainer/Grabber.drop()
