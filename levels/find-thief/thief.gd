extends Node2D

var found : bool = false

func _on_area_2d_area_entered(area: Area2D) -> void:
	if found:
		return
	found = true
	$AnimatedSprite2D.play("death")
