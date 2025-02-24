class_name Scarecrow
extends CharacterBody3D

@onready var nav: NavigationAgent3D = $NavigationAgent3D
@onready var raycast: ShapeCast3D = $ShapeCast3D

func _player_collected_pumpkin(position: Vector3):
	if state == States.CHASE:
		return
	state = States.INVESTIGATE
	investigate_target = position
	$PlayerCollectsSound.play()

var investigate_target: Vector3
var state = States.IDLE

enum States {
	IDLE,
	INVESTIGATE,
	CHASE
}

func get_player():
	return get_tree().get_first_node_in_group("player") as Player


func _ready():
	tp_to_spawn()

var player_seen_ago = 0.0

func tp_to_spawn():
	global_position = get_tree().get_nodes_in_group("crow_spawn").pick_random().global_transform.origin

signal kill_player()

func _process(delta):
	var player = get_player()
	var player_cast_pos = player.global_transform.origin + Vector3(0, 1, 0)
	raycast.target_position = (player_cast_pos - raycast.global_transform.origin) * 2 # Look at the player
	raycast.force_shapecast_update()
	# var sees_player = raycast.is_colliding() and raycast.get_collider() == player
	var sees_player = raycast.is_colliding() and raycast.get_collider(0) == player

	$LookAt.look_at(player.global_transform.origin, Vector3.UP)

	if sees_player:
		player_seen_ago = 0.0
	else:
		player_seen_ago += delta

	if state == States.CHASE and player_seen_ago > 5.0:
		state = States.IDLE
		$ChasingSound.stop()

	if sees_player and not state == States.CHASE:
		state = States.CHASE
		$StartsChaseSound.play()
		$ChasingSound.play()

	if state == States.IDLE:
		return

	var destination = player.global_transform.origin if state == States.CHASE else investigate_target

	if destination.distance_to(global_position) < 1.0:
		if state == States.CHASE:
			state = States.IDLE
			kill_player.emit()
			tp_to_spawn()
			player.tp_to_spawn()
			$ChasingSound.stop()
			$DeathSound.play()
		else:
			state = States.IDLE

	nav.target_position = destination

	var SPEED = 3.0 if state == States.CHASE else 1.5
	var next_position = nav.get_next_path_position()
	velocity = (next_position - global_position).normalized() * SPEED
	velocity.y = 0

	move_and_slide()