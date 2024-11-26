class_name AnimationTriggerZone extends Area3D

@export var animation_player: AnimationPlayer
@export var animation_name: String
@export var retriggers = false

@export var retrigger_area: Area3D

func _ready():
    body_entered.connect(on_body_entered)
    if retrigger_area:
        retrigger_area.body_entered.connect(func (body):
            if body.is_in_group("player"):
                triggered = false
        )
    
var triggered = false
func on_body_entered(body: Node) -> void:
    if not is_visible_in_tree():
        return
    if body.is_in_group("player"):
        if not triggered or retriggers:
            triggered = true
            animation_player.play(animation_name)