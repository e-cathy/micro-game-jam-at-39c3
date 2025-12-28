extends Node
class_name GameManager

## Use this when you have only one level
@export var levels: Array[PackedScene]
## Whether the mouse should be captured while in a level
var is_mouse_captured_in_level: bool = true

@onready var pause_menu: Control = %PauseMenu
@onready var menu_layer: CanvasLayer = %MenuLayer

var level = 0
var score = 0
var current_level_node: Node
var max_health = 3
var health: int = 3:
	set(new_health):
		health = new_health
		for i in range(0, max_health):
			var heart = $MenuLayer/GameUI/HeartsContainer.get_child(i)
			if i < health:
				heart.get_node("Heart").frame = 0
			else:
				heart.get_node("Heart").frame = 1
			
func _ready() -> void:
	# Setup common UI
	$MenuLayer/GameUI.visible = false
	const HEART = preload("uid://c2gmgkuxdi2co")
	for i in range(0, max_health):
		$MenuLayer/GameUI/HeartsContainer.add_child(HEART.instantiate())
	
	Global.set_game_manager(self)
	DebugGlobal.debug_label = %DebugLabel
	
	# Settings
	var user_settings = UserDefinedSettings.new()
	user_settings._register_settings()
	Settings.load_config()

	# Connect to InputManager
	InputManager.game_pause.connect(pause)
	InputManager.game_unpause.connect(resume)
	InputManager.set_is_in_game(false)
	InputManager.set_is_paused(false)
	
	_show_title_screen()
	
func _start_game() -> void:
	level = 0
	score = 0
	_show_controls()

func _process(_delta: float) -> void:
	%TimerLabel.text = str(round(%Timer.time_left * 10) / 10)
	#%HealthLabel.text = str(health)

#region Pausing

func pause():
	InputManager.set_is_paused(true)
	move_child(menu_layer, -1)
	pause_menu.move_to_front()
	pause_menu.show()
	get_tree().paused = true
	
func resume():
	InputManager.set_is_paused(false)
	print("resume")
	pause_menu.hide()
	pause_menu.reset()
	get_tree().paused = false
#endregion

#region Level Loading
func _next_level() -> void:
	$MenuLayer/GameUI.visible = true
	%Timer.stop()
	InputManager.set_is_in_game(true)
	level += 1
	if current_level_node:
		current_level_node.queue_free()
		current_level_node = null
	_show_level()

func _show_level() -> void:
	InputManager.set_is_in_game(true)
	var next_level: Level = levels.pick_random().instantiate()
	next_level.win.connect(_win_level)
	next_level.lose.connect(_lose_level)
	add_child(next_level)
	%Timer.start(next_level.timeout)
	current_level_node = next_level

func _win_level() -> void:
	print("Win")
	score = score + 1
	_next_level()

func _lose_level() -> void:
	print("Lose")
	%Timer.stop()
	health = health - 1
	if current_level_node:
		current_level_node.queue_free()
		current_level_node = null
	if health == 0:
		_show_lose_screen()
	else:
		_next_level()

#endregion

#region Showing Different GUI views 


func _show_lose_screen() -> void:
	InputManager.set_is_in_game(false)
	var win_screen: Control = load("res://ui/screens/win-screen/win_screen.tscn").instantiate()
	win_screen.tree_exited.connect(_show_title_screen)
	add_child(win_screen)
	win_screen.set_score(score)
	for child in get_children():
		if child is Level:
			child.queue_free()
			current_level_node = null
	
func _show_credits() -> void:
	var credits: Node = load("res://ui/screens/credit-screen/credit_screen.tscn").instantiate()
	credits.tree_exited.connect(_show_title_screen)
	menu_layer.add_child(credits)
	
func _show_title_screen() -> void:
	health = max_health
	$MenuLayer/GameUI.visible = false
	InputManager.set_is_in_game(false)
	var title_screen: Node = load("res://ui/screens/title-screen/title_screen.tscn").instantiate()
	title_screen.start_game.connect(_start_game)
	title_screen.show_credits.connect(_show_credits)
	title_screen.show_settings_screen.connect(_show_settings_screen)
	title_screen.quit.connect(_quit_game)
	menu_layer.add_child(title_screen)
	
func _show_settings_screen() -> void:
	var settings_screen: Node = load("res://ui/screens/settings-screen/settings_screen.tscn").instantiate()
	settings_screen.exit.connect(_show_title_screen)
	menu_layer.add_child(settings_screen)
	
func _show_controls() -> void:
	var controls: Node = load("res://ui/screens/control-screen/control_screen.tscn").instantiate()
	controls.tree_exited.connect(_next_level)
	menu_layer.add_child(controls)

func _return_to_title_screen() -> void:
	get_tree().paused = false
	InputManager.set_is_paused(false)
	InputManager.set_is_in_game(false)
	%Timer.stop()
	# Destroy level
	if current_level_node != null:
		current_level_node.queue_free()
		current_level_node = null
	# Clean up any remaining level nodes
	for child in get_children():
		if child is Level:
			child.queue_free()
	pause_menu.hide()
	pause_menu.reset()
	_show_title_screen()
#endregion

func _quit_game() -> void:
	get_tree().paused = false
	get_tree().quit()
	
func set_world_environment(env: Environment):
	$WorldEnvironment.environment = env

func _on_timer_timeout() -> void:
	_lose_level()
