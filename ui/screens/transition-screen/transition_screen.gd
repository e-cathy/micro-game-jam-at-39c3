extends Control

@export var transition_time : float

signal transition_done

func _ready() -> void:
	visible = false
	$AnimationPlayer.speed_scale=(1.0/transition_time)*5.0
	$AnimationPlayer.play("RESET")

func transition(type: GameManager.TransitionType) -> void:
	match(type):
		GameManager.TransitionType.WIN: 
			$CenterContainer/CommentLbl.text = ["NICE", "GREAT", "WOW", "SOO GOOD", "AMAZING", "PERFECT", "EXCELLENT", "FANTASTIC", "SUPERB", "BRILLIANT"].pick_random()
			$CenterContainer/CommentLbl.modulate = Color.GREEN
			$GPUParticles2D.emitting = true
			$GPUParticles2D2.emitting = true
		GameManager.TransitionType.LOSE: 
			$CenterContainer/CommentLbl.text = ["YOU SUCK", "LOOSER", "IDIOT", "...", "NOT GOOD!", "*FACEPALM*", "TRY AGAIN", "FAILURE", "FAIL", "SO SAD"].pick_random()
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
