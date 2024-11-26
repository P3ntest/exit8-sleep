class_name Anomaly extends Node3D

@export var anomaly_name: String
@export var enabled = false

func _ready():
    add_to_group("anomalies")

func enable():
    enabled = true
    push_error("Anomaly.enable() must be overridden.")
    pass