extends Camera3D

var startpos : Vector3 = Vector3.ZERO

@export var position_smooth_speed: float = 5.0
@export var zoom_smooth_speed: float = 1.0

func reset() -> void:
	position = startpos

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	startpos = position


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	var centre = (Global.player1pos + Global.player2pos) / 2
	var target = Vector3(centre.x, centre.y, startpos.z)
	if target.y < 0:
		target.y = 0
	position = lerp(position, target, position_smooth_speed*delta)
	
	var target_zoom = absf((Global.player1pos - Global.player2pos).length()) * 5
	target_zoom = clampf(target_zoom, 75.0, 120.0)
	
	fov = lerp(fov, target_zoom, zoom_smooth_speed * delta)
