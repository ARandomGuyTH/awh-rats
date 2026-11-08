extends CollisionShape3D
var startpos : Vector3
var spatula : bool = false
func _physics_process(delta: float) -> void:
	if !spatula:
		scale = Global.t*Vector3(0.0, 0.0, 6.0) + Vector3(1.0, 1.0, 1.0)
	

func _ready() -> void:
	startpos = position


func _on_area_3d_body_entered(body: Node3D) -> void:
	if body is Player:
		spatula = true
		scale = Vector3(1.0,1.0,1.0)
