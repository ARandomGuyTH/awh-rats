class_name GameController extends Node

@export var world : Node3D
@export var UI : Control

var current_world
var current_UI

func change_ui_scene(new_scene : String, delete : bool=true, keep_running=false) -> void:
	if (current_UI != null):
		if (delete):
			current_UI.queue_free() #removes node
		elif (keep_running):
			current_UI.visible = false #hides node
		else:
			UI.remove_child(current_UI) # keeps in memory, does not run
	var new = load(new_scene).instantiate()
	UI.add_child(new)
	current_UI = new

func change_world_scene(new_scene : String, delete : bool=true, keep_running=false) -> void:
	if (current_world != null):
		if (delete):
			current_world.queue_free() #removes node
		elif (keep_running):
			current_world.visible = false #hides node
		else:
			world.remove_child(current_world) # keeps in memory, does not run
	var new = load(new_scene).instantiate()
	world.add_child(new)
	current_world = new
	world.reset()
	
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Global.game_controller = self
	change_ui_scene("res://scenes/menus/main-menu/mainMenu.tscn")
	change_world_scene("res://scenes/levels/test_level.tscn")
