class_name resettable extends Node3D

func reset() -> void:
	for child in get_children():
		child.reset()
	Global.t = 0.0
	Global.banding = 1.0
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
