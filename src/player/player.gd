class_name Player
extends CharacterBody3D


const SPEED = 2.8
const JUMP_VELOCITY = 4.5

const MOUSE_SENSITIVITY = 0.002

var frozen = true

@onready var head: Node3D = $Head
@onready var camera: Camera3D = $Head/Camera3D
@onready var interactable_cast: RayCast3D = $Head/Camera3D/RayCast3D

@export_group("Nodes")
@export var interactable_popup: Control
@export var interactable_label: Label
@export var game_manager: GameManager

func _ready():
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	add_to_group("player")

func tp_to_spawn() -> void:
	var spawn = get_tree().get_first_node_in_group("player_spawn")
	global_position = spawn.global_position
	rotation.y = spawn.rotation.y

func _unhandled_input(event: InputEvent) -> void:
	if frozen:
		return
	if event is InputEventMouseMotion: 
		rotate_y(-event.relative.x * MOUSE_SENSITIVITY)
		camera.rotate_x(-event.relative.y * MOUSE_SENSITIVITY)
		camera.rotation.x = clamp(camera.rotation.x, deg_to_rad(-89), deg_to_rad(89))

var bob_intensity = 0.0
var bob_position = 0.0
var footstep_charge = 0.0

func _physics_process(delta: float) -> void:
	if frozen:
		return
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	if interactable_cast.is_colliding() and interactable_cast.get_collider() is Interactable:
		var interactable = interactable_cast.get_collider() as Interactable
		interactable_popup.visible = true
		interactable_label.text = interactable.action_text
		if Input.is_action_just_pressed("interact"):
			interactable_popup.visible = false
			interactable.interact()
			if interactable.game_event == Interactable.GameEvent.SLEEP:
				game_manager.on_sleep()
			elif interactable.game_event == Interactable.GameEvent.EXIT:
				game_manager.on_exit()
		
	else:
		interactable_popup.visible = false

	# Handle jump.
	# if Input.is_action_just_pressed("ui_accept") and is_on_floor():
	# 	velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir := Input.get_vector("left", "right", "forward", "backward")
	var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	velocity.x = lerp(velocity.x, direction.x * SPEED, 10 * delta)
	velocity.z = lerp(velocity.z, direction.z * SPEED, 10 * delta)

	bob_position  += get_real_velocity().length() * delta * 4
	bob_intensity = lerp(bob_intensity, 1.0 if get_real_velocity().length() > 0.1 else 0.0, 3 * delta)
	camera.position.y = sin(bob_position) * bob_intensity * 0.04
	footstep_charge += get_real_velocity().length() * delta
	if footstep_charge > 2:
		footstep_charge = 0
		$Footstep.play()

	move_and_slide()
