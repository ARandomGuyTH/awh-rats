class_name reverseplank extends StaticBody3D

## Direction the object moves per unit of Global.t. (0,-1,0) = fall downward.
@export var direction : Vector3 = Vector3(0, -1, 0)

## How far below the object the floor-detection ray reaches.
@export var ray_length : float = 1.0

var startpos := Vector3.ZERO
var floort : float = 0.0

@onready var floorRay : RayCast3D = $floorRay

func reset() -> void:
	global_position = startpos
	floort = 0.0

func _ready() -> void:
	startpos = global_position
	if floorRay == null:
		push_error("Reversable '%s': missing child RayCast3D named 'floorRay'" % name)
		return
	# Configure the ray so it never hits its own body.
	floorRay.target_position = Vector3(0, -ray_length, 0)
	floorRay.exclude_parent = true
	floorRay.enabled = true

func _physics_process(delta: float) -> void:
	if floorRay == null:
		return

	if !floorRay.is_colliding():
		# Free: follow time.
		global_position = Global.t * direction + startpos
		floort = Global.t
	else:
		# Landed: freeze, unless time rewinds past the landing moment.
		if Global.t < floort:
			global_position = Global.t * direction + startpos
