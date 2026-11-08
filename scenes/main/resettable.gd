class_name Resettable extends Node3D

var startpos : Vector3 = Vector3.ZERO
#sonion
func reset() -> void:
	position = startpos

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	startpos = position
