extends Control

@export var play_button: Button
@export var main_game: PackedScene

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	play_button.pressed.connect(func (): 
		get_tree().change_scene_to_packed(main_game)
		)
