extends Control

func _on_continue_pressed() -> void:
	queue_free()

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("action1") or event.is_action_pressed("action2"):
		queue_free()
