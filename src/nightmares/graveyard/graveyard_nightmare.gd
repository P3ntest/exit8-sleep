extends Node3D

@export var pumpkin: PackedScene

@export var pumpkins_label: Label

@export var crow: Scarecrow

var pumpkins_instances: Array[Interactable] = []
var collected = 0
var pumpkin_amount = 10

func update_pumpkins_label() -> void:
	pumpkins_label.text = "Pumpkins: " + str(collected) + "/" + str(pumpkins_instances.size() + collected)

func spawn_pumpkins():
	var spawns = get_tree().get_nodes_in_group("pumpkin_spawn")
	if spawns.size() < pumpkin_amount:
		push_error("Not enough pumpkin spawns")
		return

	for i in range(pumpkin_amount):
		var spawn = spawns.pick_random()
		spawn_pumpkin(spawn.global_transform.origin)
		spawns.erase(spawn)
	
	update_pumpkins_label()

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	spawn_pumpkins()


func spawn_pumpkin(spawn_position: Vector3) -> void:
	var pumpkin_instance = pumpkin.instantiate() as Interactable
	pumpkin_instance.global_transform.origin = spawn_position
	add_child(pumpkin_instance)
	pumpkins_instances.append(pumpkin_instance)

	pumpkin_instance.on_interact.connect(func ():
		collected += 1
		pumpkins_instances.erase(pumpkin_instance)
		pumpkin_instance.queue_free()
		update_pumpkins_label()
		check_win_condition()

		crow._player_collected_pumpkin(spawn_position)
	)

func check_win_condition() -> void:
	if collected == pumpkin_amount:
		get_tree().get_first_node_in_group("game_manager").on_complete_nightmare()
