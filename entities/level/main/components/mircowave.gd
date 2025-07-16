extends Node3D


# Called when the node enters the scene tree for the first time.
var open = false
func _ready() -> void:
	$Interactable.on_interact.connect(func (): 
		if open:
			$AnimationPlayer.play_backwards("open")
		else:
			$AnimationPlayer.play("open")
		open = not open
		)
