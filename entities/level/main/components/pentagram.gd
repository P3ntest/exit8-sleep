extends Node3D

@export var anim_player: AnimationPlayer
@export var player_suction: Marker3D
@export var anomaly: Anomaly
@export var whispers: Array[AudioStreamPlayer3D]

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	anomaly.can_go_sleep = false

var going = false
var done = false

var played_audio = false

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if not anomaly.enabled:
		return

	if not played_audio:
		for whisper in whispers:
			whisper.play()
		played_audio = true

	if done:
		return
	var player: Player = get_tree().get_first_node_in_group("player")

	if not going:
		if player.global_position.distance_to(player_suction.global_position) < 0.5:
			going = true
			anim_player.play("demon_spawn")

	if going:
		player.global_position.x = lerp(player.global_position.x, player_suction.global_position.x, 5.0 * delta)
		player.global_position.z = lerp(player.global_position.z, player_suction.global_position.z, 5.0 * delta)

func anim_finish():
	done = true
	anomaly.can_go_sleep = true
	for whisper in whispers:
		whisper.stop()
