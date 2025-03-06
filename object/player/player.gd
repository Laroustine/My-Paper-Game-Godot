extends CharacterBody3D
class_name Player

@export var SPEED = 4.0
@export var SPEED_ROTATE = 8.0
@export var JUMP_VELOCITY = 6.0
const SPEED_CAMERA_CENTER = Vector3(0.95, 2.25, 1)

var PREV_DIR = Vector3(1,0,0)
var ROTATE_DIR = Vector3(0, 0, 0)
var PREV_VELOCITY = Vector3(0, 0, 0)
var DEFAULT_CAM_POS = Vector3(0, 0, 0)

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

func _ready():
	$AnimationPlayer.play("idle")
	DEFAULT_CAM_POS = $Camera3D.position

func _process(delta):
	if Input.is_action_pressed("debug_main_menu"):
		get_tree().change_scene_to_file("res://object/menu/Main Menu.tscn")
	if abs($Sprite3D.get_rotation().y - ROTATE_DIR.y) > 0.01:
		$Sprite3D.set_rotation(lerp($Sprite3D.get_rotation(), ROTATE_DIR, SPEED_ROTATE * delta))
	else:
		$Sprite3D.set_rotation(ROTATE_DIR)
	camara_handler(delta)	

func _physics_process(delta):
	# Add the gravity.
	if not is_on_floor():
		velocity.y -= gravity * delta

	# Handle Jump.
#	if Input.is_action_just_pressed("jump") and is_on_floor():
	if Input.is_action_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir = Input.get_vector("move_left", "move_right", "move_back", "move_front")
	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	
	# Check if change side
	if direction.x != 0 and PREV_DIR.x * direction.x < 0:
		if $Sprite3D.get_rotation().y != ROTATE_DIR.y:
			ROTATE_DIR.y = fmod(ROTATE_DIR.y - PI, TAU)
		else:
			ROTATE_DIR.y = fmod($Sprite3D.get_rotation().y - PI, TAU)
		if abs(ROTATE_DIR.y) < 0.01:
			ROTATE_DIR.y = 0
		if abs(ROTATE_DIR.y - PI) < 0.01:
			ROTATE_DIR.y = PI
	# Movement
	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)
	if abs(direction.x) > 0:
		PREV_DIR = direction
	animation_handler()
	move_and_slide()
	PREV_VELOCITY = velocity

func camara_handler(delta):
	match $AnimationPlayer.current_animation:
		"fall":
			$Camera3D.position.y = lerp($Camera3D.position.y, DEFAULT_CAM_POS.y - 2, delta)
		"jump":
			$Camera3D.position.y = lerp($Camera3D.position.y, DEFAULT_CAM_POS.y + 2, delta)
		"run_side":
			if ROTATE_DIR.y == 0:
				$Camera3D.position.x = lerp($Camera3D.position.x, DEFAULT_CAM_POS.x + 1.5, delta)
			else:
				$Camera3D.position.x = lerp($Camera3D.position.x, DEFAULT_CAM_POS.x - 1.5, delta)
			if abs(DEFAULT_CAM_POS.y - $Camera3D.position.y) < 0.01:
				$Camera3D.position.y = DEFAULT_CAM_POS.y
			$Camera3D.position.y = lerp($Camera3D.position.y, DEFAULT_CAM_POS.y, SPEED_CAMERA_CENTER.y * delta)
		"run_front":
			$Camera3D.position.z = lerp($Camera3D.position.z, DEFAULT_CAM_POS.z + 0.3, delta)
			if abs(DEFAULT_CAM_POS.y - $Camera3D.position.y) < 0.01:
				$Camera3D.position.y = DEFAULT_CAM_POS.y
			$Camera3D.position.y = lerp($Camera3D.position.y, DEFAULT_CAM_POS.y, SPEED_CAMERA_CENTER.y * delta)
		"run_back":
			$Camera3D.position.z = lerp($Camera3D.position.z, DEFAULT_CAM_POS.z - 0.3, delta)
			if abs(DEFAULT_CAM_POS.y - $Camera3D.position.y) < 0.01:
				$Camera3D.position.y = DEFAULT_CAM_POS.y
			$Camera3D.position.y = lerp($Camera3D.position.y, DEFAULT_CAM_POS.y, SPEED_CAMERA_CENTER.y * delta)
		_:
			if abs(DEFAULT_CAM_POS.y - $Camera3D.position.y) < 0.01:
				$Camera3D.position.y = DEFAULT_CAM_POS.y
			$Camera3D.position.y = lerp($Camera3D.position.y, DEFAULT_CAM_POS.y, SPEED_CAMERA_CENTER.y * delta)
			if abs(DEFAULT_CAM_POS.x - $Camera3D.position.x) < 0.01:
				$Camera3D.position.x = DEFAULT_CAM_POS.x
			$Camera3D.position.x = lerp($Camera3D.position.x, DEFAULT_CAM_POS.x, SPEED_CAMERA_CENTER.x * delta)
			if abs(DEFAULT_CAM_POS.z - $Camera3D.position.z) < 0.01:
				$Camera3D.position.z = DEFAULT_CAM_POS.z
			$Camera3D.position.z = lerp($Camera3D.position.z, DEFAULT_CAM_POS.z, SPEED_CAMERA_CENTER.z * delta)

func animation_handler():
	if velocity.y > 0:
		if is_on_floor():
			$AnimationPlayer.play("jump")
	elif abs(velocity.y) - abs(PREV_VELOCITY.y) > 0:
		if $AnimationPlayer.current_animation != "fall":
			$AnimationPlayer.play("fall")
	elif velocity.x != 0:
		if $AnimationPlayer.current_animation != "run_side":
			$AnimationPlayer.play("run_side")
	elif velocity.z > 0:
		if $AnimationPlayer.current_animation != "run_front":
			$AnimationPlayer.play("run_front")
	elif velocity.z < 0:
		if $AnimationPlayer.current_animation != "run_back":
			$AnimationPlayer.play("run_back")
	else:
		if $AnimationPlayer.current_animation != "idle":
			$AnimationPlayer.play("idle")
