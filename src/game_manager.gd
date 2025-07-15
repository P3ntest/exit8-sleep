class_name GameManager
extends Node3D

@export var level: PackedScene
@export var player: Player
@export var weekday_label: Label
@export var day_text_label: Label

@export var main_menu: PackedScene

@export var nightmares: Array[PackedScene]

@export var game_over_slept: PackedScene

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

var goto_slept_game_over = false
var timer: float = 0.0
func _process(delta):
	if current_day != 0:
		timer += delta

	if goto_slept_game_over:
		goto_slept_game_over = false
		get_tree().change_scene_to_packed(game_over_slept)

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

const DEV_ALL_ANOMALIES = false
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
		await end_round()
		goto_slept_game_over = true
		

func on_complete_nightmare():
	restart()

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
		enter_nightmare()

var current_level: Node = null

var current_day: int = 0:
	set(value):
		current_day = value
		anomaly_rounds = randi_range(0, 0)
var round_has_anomaly = false

func end_round() -> void:
	player.frozen = true
	player.title_label.text = ""
	player.subtitle_label.text = ""
	player.animation_player.play("sleep")
	await player.animation_player.animation_finished
	return

func can_go_sleep() -> bool:
	for anomaly in enabled_anomalies:
		if not anomaly.can_go_sleep:
			return false
	return true

func enter_nightmare():
	player.frozen = true
	player.title_label.text = "You were still dreaming."
	player.subtitle_label.text = "Escape the nightmare to continue"
	player.animation_player.play("nightmare")
	await player.animation_player.animation_finished
	player.animation_player.play("RESET")
	await player.animation_player.animation_finished
	set_level_to(nightmares.pick_random())
	player.tp_to_spawn()
	player.animation_player.play("wake_up")
	await player.animation_player.animation_finished
	player.frozen = false
	
func set_level_to(new_level: PackedScene) -> void:
	if current_level:
		current_level.free()
	current_level = new_level.instantiate()
	add_child(current_level)

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

	# Spawning the level
	set_level_to(level)

	# on sunday (day 0) the lights are on
	var lights_on = current_day == 0
	if lights_on:
		for lamp in get_tree().get_nodes_in_group("lamp"):
			lamp.turn_on_silent()

	# Spawning player
	player.tp_to_spawn()

	# Spawning anomaly
	if round_has_anomaly:
		enable_random_anomaly()

	await get_tree().create_timer(1.0).timeout

	player.title_label.text = get_day_name(current_day)
	player.subtitle_label.text = "Am I dreaming?" 
	player.animation_player.play("wake_up")
	await player.animation_player.animation_finished
	player.frozen = false

func get_day_name(day: int) -> String:
	if day < 0 or day >= len(days):
		return "Invalid Day"
	return days[day]
