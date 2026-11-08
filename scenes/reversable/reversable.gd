class_name Reversable extends StaticBody3D

@export var direction : Vector3
var startpos := Vector3.ZERO
var floort : float = 0.0

@onready var floorRay : RayCast3D = $floorRay

func reset() -> void:
	position = startpos

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	startpos = position
	if floorRay == null:
		push_error("Reversable '%s': missing child RayCast3D named 'floorRay'" % name)
		Global.t = 5.0

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	if floorRay == null:
		return
	if !floorRay.is_colliding():
		position = Global.t*direction+startpos
		floort = Global.t
	else:
		if Global.t < floort:
			position = Global.t*direction+startpos
		
