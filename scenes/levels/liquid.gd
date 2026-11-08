extends MeshInstance3D
var startpos := Vector3.ZERO

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	scale = Global.t*Vector3(0.5, 1.0, 0.0) + Vector3(1.0, 1.0, 1.0)
	#position = startpos-Global.t*Vector3(0.0,1.0,0.0)

func _ready() -> void:
	startpos = position
