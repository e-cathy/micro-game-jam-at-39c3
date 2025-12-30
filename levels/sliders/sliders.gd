extends Level # IMPORTANT: Levels must extend Level

@onready var slider_container: VBoxContainer = %SliderContainer
@onready var correct_positions_label: Label = %CorrectPositionsLabel
@onready var help_label: Label = %HelpLabel



var slider_scene = preload("res://levels/sliders/slider.tscn")

var number_of_slides : int = 4
var positions_starts_correct : Array = [true, true, false, false]

func _ready() -> void:

	if difficulty > 0.5:
		number_of_slides = 5
		positions_starts_correct.append(false)

	elif difficulty > 0.8:
		number_of_slides = 6
		positions_starts_correct.append_array([true, false])

	var counter = 0
	for i in range(0, number_of_slides):
		counter += 1
		var slider = slider_scene.instantiate()
		positions_starts_correct.shuffle()

		slider.initialise(positions_starts_correct.pop_back())
		slider.text = str(counter)
		slider_container.add_child(slider)

	slider_container.get_child(0).grab_focus()
	help_label.text = "Find out which toggles need to be turned on!"

func _process(delta: float) -> void:
	var number_correct_positions : int = 0
	for slider in slider_container.get_children():
		if slider is not MicroSlider:
			continue
		if slider.is_in_correct_position():
			number_correct_positions += 1
	correct_positions_label.text = "Correct toggles: " + str(number_correct_positions) + "/" + str(number_of_slides)
	if number_correct_positions == number_of_slides:
		win.emit()

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("move_up"):
		var up_event = InputEventAction.new()
		up_event.action = "ui_up"
		up_event.pressed = true
		Input.parse_input_event(up_event)

	if event.is_action_pressed("move_down"):
		var down_event = InputEventAction.new()
		down_event.action = "ui_down"
		down_event.pressed = true
		Input.parse_input_event(down_event)
