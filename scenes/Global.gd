extends Node
var banding : float = 1.0
var game_controller : GameController
var t : float = 0.0
var maxLevel : int = 1
var currentLevel : int = 1

var player1pos := Vector3.ZERO
var player2pos := Vector3.ZERO

var player1vel := Vector3.ZERO
var player2vel := Vector3.ZERO

func updateMaxLevel(level : int):
	maxLevel = maxi(level, maxLevel)

func updatePos(player : String, position : Vector3, velocity : Vector3):
	match player:
		"player1":
			player1pos = position
			player1vel = velocity
		"player2":
			player2pos = position
			player2vel = velocity

func _process(delta: float) -> void:
	if player2vel.x > 0 and player1vel.x > 0:
		t += max(player2vel.x, player1vel.x) * delta
	elif player2vel.x <= 0 and player1vel.x <= 0:
		t += min(player2vel.x, player1vel.x) * delta * banding
	else:
		if player1vel.x+player2vel.x <= 0:
			t += (player1vel.x+player2vel.x) * delta
		else:
			t += (player1vel.x+player2vel.x) * delta
	
	t = max(t, 0.0)
	
	if Input.is_action_pressed("unlockLevels"):
		maxLevel = 10
