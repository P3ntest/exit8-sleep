extends Anomaly

@export var targets: Array[Node3D]

func _ready():
	super._ready()
	if (not targets)or targets.is_empty():
		targets = []
		for child in get_children():
			if child is Node3D:
				targets.append(child)
	
	prints("Targets", targets)

func enable():
	super.enable()
	# we want to switch around the position of the targets
	# It is very important, that the final order cannot be the same as the initial order
	prints("Switching positions of targets", targets)
	var initial_positions = []
	for target in targets:
		initial_positions.append(target.global_transform.origin)
	var final_positions = initial_positions.duplicate()
	while final_positions[0] == initial_positions[0]:
		final_positions.shuffle()

	
	for i in range(targets.size()):
		targets[i].global_transform.origin = final_positions[i]
