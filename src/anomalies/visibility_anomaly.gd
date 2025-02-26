class_name VisibilityAnomaly extends Anomaly

@export var targets: Array[Node]
@export var anti_targets: Array[Node]
@export var normal_visible = false

func _ready():
    if targets.is_empty():
        targets.append(get_parent())
    super._ready()
    for target in targets:
        target.visible = normal_visible
    for target in anti_targets:
        target.visible = not normal_visible
    
func enable():
    enabled = true
    for target in targets:
        target.visible = not normal_visible
    for target in anti_targets:
        target.visible = normal_visible