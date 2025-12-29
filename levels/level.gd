class_name Level
extends Node

## Emit this signal, when the level is won
signal win
## Emit this signal, when the level is lost
signal lose

func _timeout():
	# you are responsible of calling lose or win on or after timeout!
	# You may choose to call win or lose after an animation or other behavior too
	lose.emit()

## Timer for the current level. On timeout, the player automatically loses
@export var timeout: float = 10
## Difficulty is a value between 0.1 and 0.9. It is automatically set as part of a difficulty curve. You may include this value in your gameplay, but are not required to.
@export_range(0.1, 0.9) var difficulty: float =  0.1
