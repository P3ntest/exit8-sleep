extends Node3D

@onready var anomaly_666: Anomaly = $Anomaly666
@onready var anomaly_fast: Anomaly = $AnomalyFast

@onready var label: Label3D = $Label3D

# Called when the node enters the scene tree for the first time.
var day: int
func _ready() -> void:
	day = get_tree().get_first_node_in_group("game_manager").current_day
	time = (18 * 60 + 36) if day == 0 else  7 * 60

	if day != 0:
		$AudioStreamPlayer3D.play()


# Called every frame. 'delta' is the elapsed time since the previous frame.
var time: float = 7 * 60
func _process(delta: float) -> void:
	time += delta / (60.0 if not anomaly_fast.enabled else 0.2)
	var hours = int(time / 60)
	var minutes = int(int(time) % 60)

	if anomaly_666.enabled:
		label.text = "666 AM"
	else:
		label.text = str(hours).pad_zeros(2) + ":" + str(minutes).pad_zeros(2) + " " + ("AM" if hours < 12 else "PM")
