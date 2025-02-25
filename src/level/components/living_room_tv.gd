extends Node3D

@export var shatter_sound: AudioStreamPlayer3D
@export var shatter_light: Light3D

@export var switch_sound: AudioStreamPlayer3D
@export var static_sound: AudioStreamPlayer3D

@export var off_material: Material
@export var on_material: Material

@export var anomaly: Anomaly
@export var video_player: VideoStreamPlayer
@export var video_display: MeshInstance3D

@export var TV: MeshInstance3D

var state = false

func set_material(material: Material):
	TV.set_surface_override_material(1, material)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	set_material(off_material)

func update_material():
	set_material(on_material if state else off_material)
	if state:
		static_sound.play()
	else:
		static_sound.stop()

var activated_video = false

func _on_interactable_on_interact() -> void:
	if anomaly.enabled:
		switch_sound.play()

		if activated_video:
			return
		activated_video = true

		get_tree().create_timer(3.0).timeout.connect(func ():
			shatter_sound.play()
			shatter_light.light_energy = 0
			)

		video_player.play()
		video_display.show()
		return


	state = not state
	update_material()
	switch_sound.play()
