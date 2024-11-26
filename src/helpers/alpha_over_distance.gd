extends Node3D

@export var material: StandardMaterial3D

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta) -> void:
	var player = get_tree().get_first_node_in_group("player")
	var distance = global_transform.origin.distance_to(player.global_transform.origin)
	material.albedo_color.a = clamp((distance - 8) / 10, 0, 1)
