extends Node3D


@onready var animation_player = $AnimationPlayer
const anim_name = "open"

var open = false

func _on_interactable_on_interact() -> void:
	$AudioStreamPlayer3D.play()
	if open:
		animation_player.play_backwards(anim_name)
	else:
		animation_player.play(anim_name)
	open = not open
