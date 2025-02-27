class_name GameManager
extends Node3D

@export var level: PackedScene
@export var player: Player
@export var weekday_label: Label
@export var day_text_label: Label

@export var main_menu: PackedScene

@export var nightmares: Array[PackedScene]

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

func get_calendar_day():
	return current_day

var timer: float = 0.0
func _process(delta):
	if current_day != 0:
		timer += delta

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
var enabled_anomalies: Array[Anomaly] = []
func enable_random_anomaly() -> void:
	enabled_anomalies.clear()
	if DEV_ALL_ANOMALIES:
		for anomaly in get_anomalies():
			anomaly.enable()
			enabled_anomalies.append(anomaly)
		return
	var anomaly = get_anomalies().pick_random()
	anomaly.enable()
	enabled_anomalies.append(anomaly)
	used_anomalies.append(anomaly.get_path().get_concatenated_names())

func restart():
	await end_round()
	start_round()

func on_lost():
	current_day = 1

func on_sleep():
	if not can_go_sleep():
		return

	if current_day == 0:
		current_day = 1
		restart()
	elif round_has_anomaly:
		restart()
	else:
		on_lost()
		restart()

func on_complete_nightmare():
	next_day()

func next_day():
	current_day += 1
	if current_day == len(days):
		weekday_label.text = "You won!"
		day_text_label.text = "It took you " + str(int(timer)) + " seconds to survive the week."
		await get_tree().create_timer(5.0).timeout
		get_tree().change_scene_to_packed(main_menu)
		pass
	restart()

func on_exit():
	if current_day == 0:
		return
	elif not round_has_anomaly:
		next_day()
	else:
		print("lost due to anomaly not found")
		for anomaly in enabled_anomalies:
			print(anomaly.get_path().get_concatenated_names())
			print(anomaly.name)
		on_lost()
		restart()

var current_level: Node = null

var current_day: int = 0:
	set(value):
		current_day = value
		anomaly_rounds = randi_range(0, 8)
var round_has_anomaly = false

func end_round() -> void:
	player.frozen = true
	# animation_player.play("darken")
	# await animation_player.animation_finished
	return

func can_go_sleep() -> bool:
	for anomaly in enabled_anomalies:
		if not anomaly.can_go_sleep:
			return false
	return true

var grace_round = true
var anomaly_rounds = 0
func start_round() -> void:
	print('starting round')
	print('remaining anomaly rounds:', anomaly_rounds)
	round_has_anomaly = anomaly_rounds > 0
	if round_has_anomaly:
		anomaly_rounds -= 1
	
	print('round has anomaly:', round_has_anomaly)

	if grace_round:
		print("never mind, grace round")
		grace_round = false
		round_has_anomaly = false

	var nightmare_chance = randf() < 0.1

	var is_nightmare = round_has_anomaly and nightmare_chance and nightmares.size() > 0
	var nightmare = nightmares.pick_random() if is_nightmare else null
	if nightmare:
		nightmares.erase(nightmare)

	# Spawning the level
	if current_level:
		current_level.free()
	var level_instance = (level if not is_nightmare else nightmare).instantiate()
	add_child(level_instance)
	current_level = level_instance

	# Spawning player
	player.tp_to_spawn()

	# Spawning anomaly
	if round_has_anomaly and not is_nightmare:
		enable_random_anomaly()

	# animation_player.play("lighten")
	# await animation_player.animation_finished
	player.frozen = false
