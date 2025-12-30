extends Control
	
@export var score_gradient: Gradient
@export var score_gradient_end_number : int

var display_score: int = 0:
	set(score):
		display_score = score
		$ScoreLbl.text = str(score)
		$ScoreLbl.modulate = score_gradient.sample(float(score)/score_gradient_end_number)

var animation_finished = false

func _ready() -> void:
	$ReturnToMainMenu.visible = false 

func set_score(score: int) -> void:
	$ReturnToMainMenu.visible = false 
	animation_finished = false
	score_gradient_end_number = score
	var t = create_tween().tween_property(self, "display_score", score, 2.0).set_trans(Tween.TRANS_CUBIC).from(0)
	await t.finished
	$ScoreLbl.modulate = Color.GREEN
	await get_tree().create_timer(1.0).timeout
	$ReturnToMainMenu.visible = true 
	animation_finished = true

func _input(event: InputEvent) -> void:
	if not event.is_action_type():
		return
	if not animation_finished:
		return

	queue_free()
