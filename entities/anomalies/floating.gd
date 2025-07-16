@icon("res://icon.svg")
extends Anomaly

@export var targets: Array[Node3D]

func enable():
	for target in targets:
		target.global_translate(Vector3(0, 0.3, 0))
