class_name NewDoor extends Node3D

@export var reverse: bool = false
@export var open_speed: float = 300.0
@export var open_angle: float = 90.0
@export_group("Nodes")
@export var hinge: Node3D
@export var sound: AudioStreamPlayer3D
@export var interactable: Interactable

var open = false

func _ready() -> void:
    interactable.on_interact.connect(on_change)
    update_interactable_text()

func update_interactable_text():
    interactable.action_text = "Close Door" if open else "Open Door"

func on_change():
    open = not open
    update_interactable_text()
    sound.play()

func _process(delta):
    var target = (open_angle if open else 0.0) * (-1.0 if reverse else 1.0)
    hinge.rotation_degrees.y = move_toward(hinge.rotation_degrees.y, target, open_speed * delta)