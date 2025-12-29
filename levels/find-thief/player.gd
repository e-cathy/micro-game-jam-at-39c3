extends Node2D

@export var speed : float = 600

@onready var thief: Node2D = %thief
@onready var color_rect: ColorRect = %occlusion_rect
var rect_material : ShaderMaterial
var	thief_found : bool = false


signal found_thief

func _ready() -> void:
	rect_material = color_rect.material as ShaderMaterial
	
	# place the thief somewhere not too close to us
	var thief_position : Vector2 = position
	while (thief_position.distance_to(position) <= 100):
		thief_position = _get_random_position_on_screen()
	%thief.position = thief_position

func _process(delta: float) -> void:
	if thief_found:
		return
	var input_vector: Vector2 = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	position += input_vector * delta * speed
	if input_vector.is_zero_approx():
		$AnimatedSprite2D.play("idle")
	else:
		$AnimatedSprite2D.play("run")
		if input_vector.x < 0:
			$AnimatedSprite2D.flip_h = true
		else:
			$AnimatedSprite2D.flip_h = false
	rect_material.set_shader_parameter("circle_screen_pos", position * get_viewport().get_stretch_transform())

func _get_random_position_on_screen() -> Vector2:
	var screen_size = get_viewport().get_visible_rect().size
	var x : float = randf_range(0, screen_size.x)
	var y : float = randf_range(0, screen_size.y)
	return Vector2(x, y)

func _on_area_2d_area_entered(_area: Area2D) -> void:
	thief_found = true
	%occlusion_rect.visible = false
	%Label.visible = false
	$AnimatedSprite2D.play("idle")
	found_thief.emit()
