class_name Player
extends CharacterBody3D

@export var debug: bool = false

const SPEED = 2.5
const JUMP_VELOCITY = 3.0

const MOUSE_SENSITIVITY = 0.002

var frozen = true

@onready var head: Node3D = $Head
@onready var camera: Camera3D = $Head/CameraMount/Camera3D
@onready var camera_pivot: Node3D = $Head/CameraMount
@onready var interactable_cast: RayCast3D = $Head/CameraMount/RayCast3D

@export_group("Nodes")
@export var interactable_popup: Control
@export var interactable_label: Label
@export var game_manager: GameManager
@export var sprint_meter: ProgressBar
@export var animation_player: AnimationPlayer
@export var title_label: Label
@export var subtitle_label: Label

func _ready():
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	add_to_group("player")

	if debug:
		frozen = false
		animation_player.play("wake_up")

func tp_to_spawn() -> void:
	var spawn = get_tree().get_first_node_in_group("player_spawn")
	global_position = spawn.global_position
	rotation.y = spawn.rotation.y

var cam_target_origin: Transform3D
var cam_target_transform: Transform3D:
	set(value):
		cam_target_transform = value
		cam_target_origin = camera_pivot.global_transform
var cam_transition_amount: float = 0.0

func can_look_around():
	return not frozen and cam_transition_amount == 0.0

# func _process(delta):
# 	cam_transition_amount = move_toward(cam_transition_amount, 1.0 if cam_target_transform else 0.0, 2 * delta)

# 	if cam_transition_amount > 0.0:
# 		camera_pivot.global_transform = cam_target_origin.interpolate_with(cam_target_transform, cam_transition_amount)

func _unhandled_input(event: InputEvent) -> void:
	if not can_look_around():
		return
	if event is InputEventMouseMotion: 
		rotate_y(-event.relative.x * MOUSE_SENSITIVITY)
		camera_pivot.rotate_x(-event.relative.y * MOUSE_SENSITIVITY)
		camera_pivot.rotation.x = clamp(camera_pivot.rotation.x, deg_to_rad(-89), deg_to_rad(89))

var bob_intensity = 0.0
var bob_position = 0.0
var footstep_charge = 0.0

var stamina = 1.0
var stamina_cooldown = 0.0
const sprint_regen = 0.5

func update_sprint_meter():
	if stamina == 1.0:
		sprint_meter.visible = false
		return
	sprint_meter.visible = true
	sprint_meter.value = stamina

func _physics_process(delta: float) -> void:
	if frozen:
		return
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta
	if is_on_floor() and Input.is_action_just_pressed("jump"):
		velocity.y = JUMP_VELOCITY

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

	# Handle sprinting.
	var speed = SPEED
	stamina_cooldown -= delta
	if Input.is_action_pressed("sprint") and stamina > 0.0:
		stamina = move_toward(stamina, 0.0, sprint_regen * delta)
		if stamina == 0.0:
			stamina_cooldown = 1.5
		speed *= 2.0
	else:
		if stamina_cooldown <= 0.0:
			stamina = move_toward(stamina, 1.0, sprint_regen * delta)
	update_sprint_meter()

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir := Input.get_vector("left", "right", "forward", "backward")
	var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	velocity.x = lerp(velocity.x, direction.x * speed, 10 * delta)
	velocity.z = lerp(velocity.z, direction.z * speed, 10 * delta)

	bob_position  += get_real_velocity().length() * delta * 4
	bob_intensity = lerp(bob_intensity, 1.0 if get_real_velocity().length() > 0.1 else 0.0, 3 * delta)
	camera_pivot.position.y = sin(bob_position) * bob_intensity * 0.04
	footstep_charge += get_real_velocity().length() * delta
	if footstep_charge > 2:
		footstep_charge = 0
		$Footstep.play()

	move_and_slide()
