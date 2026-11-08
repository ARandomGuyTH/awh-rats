extends Control

# Set these to your real paths
const MAIN_MENU_SCENE := "res://scenes/menus/main-menu/mainMenu.tscn"
const LEVEL_SELECT_SCENE := "res://scenes/menus/level-select/levelSelectMenu.tscn"
const MENU_WORLD_SCENE := "res://scenes/levels/test_level.tscn" 
const OPTIONS_SCENE := preload("res://scenes/menus/options-menu/optionsMenu.tscn")
  
@onready var menu_content: Control = %Center
@onready var resume_button: Button = %ResumeButton
@onready var restart_button: Button = %RestartButton
@onready var options_button: Button = %OptionsButton
@onready var level_select_button: Button = %LevelSelectButton
@onready var main_menu_button: Button = %MainMenuButton

var options_instance: Node = null
var previous_mouse_mode := Input.MOUSE_MODE_VISIBLE
var hidden_huds: Array[Node] = []


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	visible = false

	resume_button.pressed.connect(resume)
	restart_button.pressed.connect(_on_restart_pressed)
	options_button.pressed.connect(_on_options_pressed)
	level_select_button.pressed.connect(_on_level_select_pressed)
	main_menu_button.pressed.connect(_on_main_menu_pressed)


func _unhandled_input(event: InputEvent) -> void:
	if not event.is_action_pressed("ui_cancel"):
		return
	# Don't allow pausing while a menu is showing (see Global note below)
	if Global.get("in_menu"):
		return

	if options_instance != null:
		options_instance.queue_free()
	elif visible:
		resume()
	else:
		pause()
	get_viewport().set_input_as_handled()


func pause() -> void:
	previous_mouse_mode = Input.mouse_mode
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	_hide_huds()
	visible = true
	get_tree().paused = true
	resume_button.grab_focus()


func resume() -> void:
	_leave_pause()


# Shared cleanup before resuming or leaving the level
func _leave_pause() -> void:
	_restore_huds()
	Input.mouse_mode = previous_mouse_mode
	visible = false
	get_tree().paused = false


func _hide_huds() -> void:
	hidden_huds.clear()
	for hud in get_tree().get_nodes_in_group("hud"):
		if hud.visible:
			hud.visible = false
			hidden_huds.append(hud)


func _restore_huds() -> void:
	for hud in hidden_huds:
		if is_instance_valid(hud):
			hud.visible = true
	hidden_huds.clear()


func _on_restart_pressed() -> void:
	var gc = Global.game_controller
	var level_path: String = gc.current_world.scene_file_path
	_leave_pause()
	gc.change_world_scene(level_path)
	# This node is freed by the line above, so nothing may touch self after it


func _on_level_select_pressed() -> void:
	var gc = Global.game_controller
	_leave_pause()
	gc.change_ui_scene(LEVEL_SELECT_SCENE)
	gc.change_world_scene(MENU_WORLD_SCENE)


func _on_main_menu_pressed() -> void:
	var gc = Global.game_controller
	_leave_pause()
	gc.change_ui_scene(MAIN_MENU_SCENE)
	gc.change_world_scene(MENU_WORLD_SCENE)


func _on_options_pressed() -> void:
	options_instance = OPTIONS_SCENE.instantiate()
	# If your options script has an overlay flag, set it here before add_child
	add_child(options_instance)
	menu_content.visible = false
	options_instance.tree_exited.connect(_on_options_closed)


func _on_options_closed() -> void:
	options_instance = null
	menu_content.visible = true
	options_button.grab_focus()
