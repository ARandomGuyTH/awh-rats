extends Node3D
var startpos := Vector3.ZERO
var startrot : Vector3

func reset() -> void:
	position = startpos

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	startpos = position
	startrot = rotation

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	if Global.t*0.2 < PI/4:
		rotation =  Global.t*Vector3(0.0,0.0,0.2) + startrot
