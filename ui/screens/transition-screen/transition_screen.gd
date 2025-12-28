extends Control

@export var transition_time : float = 1

signal transition_done

func _ready() -> void:
	visible = false
	$AnimationPlayer.play("RESET")

func transition(type: GameManager.TransitionType) -> void:
	match(type):
		GameManager.TransitionType.WIN: 
			$CenterContainer/CommentLbl.text = "NICE!"
			$CenterContainer/CommentLbl.modulate = Color.GREEN
			$GPUParticles2D.emitting = true
			$GPUParticles2D2.emitting = true
		GameManager.TransitionType.LOSE: 
			$CenterContainer/CommentLbl.text = "YOU SUCK!"
			$CenterContainer/CommentLbl.modulate = Color.RED
		GameManager.TransitionType.START: 
			$CenterContainer/CommentLbl.text = ""
	
	
	visible = true
	$AnimationPlayer.play("ready_set_go")
	"""
	after step 1, display ready
	step 2, set
	step 3, go
	step 4 we are done
	"""

func _on_done() -> void:
	$AnimationPlayer.play("RESET")
	visible = false
	transition_done.emit()
