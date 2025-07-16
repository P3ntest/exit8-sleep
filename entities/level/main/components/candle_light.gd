extends OmniLight3D



var target = 1.0

func _process(delta: float) -> void:
	if randf() < 4.0 * delta:
		target = randf_range(0.2, 4.0)
		# light flickering
	light_energy = lerp(light_energy, target, 7 * delta)
