extends CheckButton
class_name MicroSlider

var correct_postion : bool = false

func initialise(initial_position_correct : bool):
	var initial_values = [true, false]
	initial_values.shuffle()
	var initial_position : bool = initial_values.pop_back()

	if initial_position_correct:
		correct_postion = initial_position
	else:
		correct_postion = bool(not initial_position)
	set_pressed(initial_position)


func is_in_correct_position() -> bool:
	return bool(button_pressed == correct_postion)
