extends Control

func _on_start_button_pressed() -> void:
	Global.game_controller.change_ui_scene("res://scenes/menus/HUD/HUD.tscn")
	Global.game_controller.change_world_scene("res://scenes/levels/test_level.tscn")

func _on_options_button_pressed() -> void:
	Global.game_controller.change_ui_scene("res://scenes/menus/options-menu/optionsMenu.tscn")

func _on_quit_button_pressed() -> void:
	get_tree().quit()
