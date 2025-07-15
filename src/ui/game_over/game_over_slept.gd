extends Control

func to_main_menu() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	get_tree().change_scene_to_file("res://src/ui/main_menu.tscn")