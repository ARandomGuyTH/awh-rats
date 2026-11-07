class_name Model extends Node3D

@onready var animationPlayer = $AnimationPlayer

func run() -> void:
	animationPlayer.play("run")

func idle() -> void:
	pass

func fall() -> void:
	pass
