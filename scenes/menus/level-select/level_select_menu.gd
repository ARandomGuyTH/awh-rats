extends Control

@onready var back_button: Button = %BackButton

func _ready() -> void:
	back_button.pressed.connect(_on_back_pressed)

func _on_back_pressed() -> void:
	Global.game_controller.change_ui_scene("res://scenes/menus/main-menu/mainMenu.tscn")
