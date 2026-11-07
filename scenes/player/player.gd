class_name Player extends CharacterBody3D

# This enum lists all the possible states the character can be in.
enum States {IDLE, RUNNING, JUMPING, FALLING}

@export var player : String
@export var model : Model

# This variable keeps track of the character's current state.
var state: States = States.IDLE
var startpos : Vector3 = Vector3.ZERO

const SPEED = 400.0
const JUMP_VELOCITY = 10.0
const lerp_speed = 0.7

func reset() -> void:
	position = startpos
	velocity = Vector3.ZERO

func set_state(new_state : int) -> void:
	var previous_state := state
	state = new_state

func _physics_process(delta: float) -> void:
	Global.updatePos(player, position, velocity)
	
	var target_dir = Vector3.ZERO
	if Input.is_action_pressed(player + "right"):
		target_dir += Vector3(1,0,0)
	if Input.is_action_pressed(player + "left"):
		target_dir += Vector3(-1,0,0)	
	# Smoothly interpolate horizontal movement direction
	var direction : Vector3 = lerp(velocity.normalized(), target_dir, lerp_speed * 0.9)
	if (direction.length() <= 0.4):
		model.idle()
		direction = Vector3.ZERO
	else:
		model.run()
	if model.global_position != target_dir:
		model.look_at(model.global_position + target_dir, Vector3.UP)
	# Apply movement
	velocity.x = direction.x * SPEED * delta
	velocity.z = direction.z * SPEED * delta

	# Add the gravity.
	if not is_on_floor():
		model.fall()
		velocity += get_gravity() * delta

	# Handle jump.
	if Input.is_action_pressed(player + "up") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	move_and_slide()

func _process(delta: float) -> void:
	pass
	
func _ready() -> void:
	startpos = position
