class_name GameManager
extends Node3D

@export var level: PackedScene
@export var player: Player
@export var weekday_label: Label
@export var day_text_label: Label

@onready var animation_player = $AnimationPlayer

const days: Dictionary = {
	0: "Sunday",
	1: "Monday",
	2: "Tuesday",
	3: "Wednesday",
	4: "Thursday",
	5: "Friday",
}

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	add_to_group("game_manager")
	start_round()

var used_anomalies: Array[String] = []
func get_anomalies() -> Array[Anomaly]:
	var anomalies: Array[Anomaly] = []
	for anomaly in get_tree().get_nodes_in_group("anomalies"):
		if not used_anomalies.has(anomaly.get_path().get_concatenated_names()):
			anomalies.append(anomaly as Anomaly)
	if not used_anomalies.is_empty() and anomalies.is_empty():
		used_anomalies.clear()
		return get_anomalies()
	return anomalies

const DEV_ALL_ANOMALIES = true
func enable_random_anomaly() -> void:
	if DEV_ALL_ANOMALIES:
		for anomaly in get_anomalies():
			anomaly.enable()
		return
	var anomaly = get_anomalies().pick_random()
	anomaly.enable()
	used_anomalies.append(anomaly.get_path().get_concatenated_names())

func restart():
	await end_round()
	start_round()

func on_lost():
	current_day = 1

func on_sleep():
	if current_day == 0:
		current_day = 1
		restart()
	elif round_has_anomaly:
		restart()
	else:
		on_lost()
		restart()

func on_exit():
	if current_day == 0:
		return
	elif not round_has_anomaly:
		current_day += 1
		if current_day == len(days):
			# Game over, player won
			pass
		restart()
	else:
		on_lost()
		restart()

var current_level: Node = null

var current_day = 0 # = Monday
var round_has_anomaly = false

func end_round() -> void:
	player.frozen = true
	animation_player.play("darken")
	await animation_player.animation_finished
	return


var grace_round = true
func start_round() -> void:
	weekday_label.text = days[current_day]
	day_text_label.text = "I should go to sleep soon." if current_day == 0 else "Am I dreaming?"
	round_has_anomaly = randf() > 0.18
	if grace_round:
		grace_round = false
		round_has_anomaly = false

	# Spawning the level
	if current_level:
		current_level.free()
	var level_instance = level.instantiate()
	add_child(level_instance)
	current_level = level_instance

	# Spawning player
	player.tp_to_spawn()

	# Spawning anomaly
	if round_has_anomaly:
		enable_random_anomaly()

	animation_player.play("lighten")
	await animation_player.animation_finished
	player.frozen = false
