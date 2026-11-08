extends Node3D

var rotating : bool = false

func _process(delta : float) -> void:
	if rotating:
		rotation = lerp(rotation, Vector3(0.0,0.0,PI/2), 0.3)

func _on_area_3d_body_entered(body: Node3D) -> void:
	if body is Player:
		rotating = true
