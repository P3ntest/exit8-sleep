extends Node3D

@export_group("Messages")
@export var day_one_dad: AudioStream
@export var day_one_doctor: AudioStream

@export_group("Sounds")
@export var unheard_messages_beeper: AudioStreamPlayer3D
@export var message_speaker: AudioStreamPlayer3D
@export var phone_beep: AudioStreamPlayer3D
@export var busy_tone: AudioStreamPlayer3D

func get_messages_for_day(day: int) -> Array:
	if day == 0:
		return [day_one_dad, day_one_doctor]
	return []

var currently_playing = false

func beep() -> void:
	phone_beep.play()
	await phone_beep.finished

var messages_today: Array = []
func _ready() -> void:
	var game_manager: GameManager = get_tree().get_first_node_in_group("game_manager")
	messages_today = get_messages_for_day(game_manager.current_day)

	$Timer.timeout.connect(func ():
		if messages_today.size() > 0 and not currently_playing:
			unheard_messages_beeper.play()
	)

	$Interactable.on_interact.connect(func ():
		if currently_playing:
			return
		if messages_today.size() == 0:
			currently_playing = true
			busy_tone.play()
			await busy_tone.finished
			currently_playing = false
			return
		currently_playing = true
		for message in messages_today:
			await beep()
			message_speaker.stream = message
			message_speaker.play()
			await message_speaker.finished
		await beep()
		currently_playing = false
		)
