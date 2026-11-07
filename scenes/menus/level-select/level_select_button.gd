extends Button

var level : int = 1
var is_unlocked : bool = false
var levelPath : String = "res://scenes/levels/"

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	level = get_index() + 1
	text = str(level)
	is_unlocked = level <= Global.maxLevel
	modulate.a = 1.0 if is_unlocked else 0.5

func _pressed() -> void:
	if is_unlocked:
		Global.currentLevel = level
		Global.game_controller.change_world_scene(levelPath+str(level)+ ".tscn")
