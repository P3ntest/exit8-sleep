class_name Lamp extends Interactable

@export var light: Light3D
@export var switch_sound: AudioStreamPlayer3D
@export var default_on = false

var on = false

func push_state():
    light.visible = on
    action_text = "Turn off" if on else "Turn on"

func _ready():
    if not light:
        push_error("Lamp requires a Light3D node.")

    if default_on:
        on = true

    push_state()

    on_interact.connect(func ():
        on = not on
        push_state()
        if switch_sound:
            switch_sound.play()
        )

