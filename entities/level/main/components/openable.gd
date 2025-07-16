class_name Openable
extends Node3D

@export var item_name: String = ""
@export var open_degrees: float = 90.0
@export var doors: Array[Node3D]
@export var interactable: Interactable
@export var speed: float = 90.0

@export var sound: AudioStreamPlayer3D

@export_group("Effects")
@export var scare_sound: AudioStreamPlayer3D
@export var anomaly: Anomaly

var opened = false

var state = false

func _ready() -> void:
	update_action_text()

	interactable.on_interact.connect(func () -> void:
		state = not state
		if not opened:
			opened = true
			if anomaly:
				if anomaly.enabled:
					if scare_sound:
						print("playing scare sound")
						scare_sound.play()
		update_action_text()
		if sound:
			if state:
				sound.play()
			else:
				sound.stop()
	)

func update_action_text():
	interactable.action_text = ("Close" if state else "Open") + " " + item_name

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	var target = (open_degrees if state else 0.0)
	for i in range(doors.size()):
		doors[i].rotation_degrees.z = move_toward(doors[i].rotation_degrees.z, target, speed * delta)
