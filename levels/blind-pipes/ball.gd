extends Sprite2D

const Pipes = preload("res://levels/blind-pipes/pipes.gd")

@export var pipes: Pipes
@export var target_node: CollisionShape2D
@export var particles: GPUParticles2D

signal dropped
signal caught
signal lost

func drop(pipe: int) -> void:
	dropped.emit()
	step = 1
	pos = Vector2i(pipes.get_pipe_x(pipe), -12)
	global_position = pipes.coord(pos) - Vector2(0, 18)

var t: float = 0.5
var step: int:
	get:
		return step
	set(value):
		velocity = 0
		step = value
		t = 0.5

var velocity: float = 0.0
var pos = Vector2i(0, 0)
var direction = 0 # down, left, right

func _process(delta: float) -> void:
	if step == 1:
		if t > 0:
			t -= delta
			velocity += delta
			global_position += Vector2(0, velocity * 8)
		else:
			step = 2
	elif step == 2:
		if t > 0:
			t -= delta
		elif not _next_stop():
			step = 3
	elif step == 3:
		velocity += delta
		velocity *= pow(0.99, delta)
		var rect = target_node.shape.get_rect()
		var ball_radius = 25.0;
		rect = Rect2(rect.position + target_node.global_position, rect.size)
		global_position += Vector2(0, velocity * 8)
		if rect.has_point(global_position + Vector2(0, ball_radius)):
			velocity = 0
			global_position.y = rect.position.y - ball_radius
			caught.emit()
		if global_position.y > 800:
			step = 4
			lost.emit()

func _next_stop():
	if direction == 0:
		pos.y += 1
		while pos.y < 0 and pipes.is_corner(pos) == 0:
			pos.y += 1
		if pos.y >= 0:
			return false
		direction = pipes.is_corner(pos)
	else:
		@warning_ignore("shadowed_variable_base_class")
		var offset = -1 if direction == 1 else 1
		pos.x += offset
		while pos.x > -100 and pos.x < 100 and pipes.is_corner(pos) == 0:
			pos.x += offset
		direction = 0
	var gpos = pipes.coord(pos)
	global_position = gpos
	var particles2 = particles.duplicate()
	get_parent().add_child(particles2)
	particles2.global_position = gpos
	particles2.emitting = true
	t = 0.5
	return true
