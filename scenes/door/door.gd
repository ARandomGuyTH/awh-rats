extends Node3D

var bodieCount = 0
@export var level : int
var players = []
@onready var area = $Area3D
var leaving : bool = false

var x = 0
# Called when the node enters the scene tree for the first time.
func _physics_process(delta: float) -> void:
	if leaving:
		for bo in area.get_overlapping_bodies():
			if bo is Player:
				bo.look_at(bo.global_position - Vector3.BACK, Vector3.UP)
				bo.global_position += -Vector3.BACK * delta * 300

func _on_area_3d_body_entered(body: Node3D) -> void:
	if body is Player:
		bodieCount += 1
	if bodieCount == 2:
		leaving = true
		Global.updateMaxLevel(level)
		Global.game_controller.change_ui_scene("res://scenes/menus/level-select/levelSelectMenu.tscn")
		
func _on_area_3d_body_exited(body: Node3D) -> void:
	if body is Player:
		bodieCount -= 1
