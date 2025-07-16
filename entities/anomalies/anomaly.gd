class_name Anomaly extends Node3D

@export var anomaly_name: String
@export var enabled = false

@export var debug_enabled = false

var can_go_sleep = true

func _ready():
    add_to_group("anomalies")

    if debug_enabled:
        enable()

func enable():
    enabled = true
    push_error("Anomaly.enable() must be overridden.")
    pass