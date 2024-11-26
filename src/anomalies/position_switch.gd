extends Anomaly

@export var targets: Array[Node3D]

func enable():
    # we want to switch around the position of the targets
    # It is very important, that the final order cannot be the same as the initial order
    var initial_positions = []
    for target in targets:
        initial_positions.append(target.global_transform.origin)
    var final_positions = initial_positions.duplicate()
    while final_positions[0] == initial_positions[0]:
        final_positions.shuffle()
    
    for i in range(targets.size()):
        targets[i].global_transform.origin = final_positions[i]