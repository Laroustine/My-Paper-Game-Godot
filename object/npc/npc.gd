extends CharacterBody3D

@export_category("Info")
@export var NAME: String = "NPC"
@export var HEIGHT: float = 1.0
@export_category("Texture")
@export var SPRITE: Texture
@export var IS_NEAREST: bool = true
@export_enum("idle", "run_front") var ANIMATION: String = "idle"
@export_category("Interact")
@export var INTERACT: Node3D = null
@export_category("Voice")
@export_multiline var TEXT = ""
@export_dir var VOICE = null
@export var VOICE_SPEED = 0.1

@onready var TIMER = $TextBox/Timer
@onready var SOUND = $TextBox/Voice

const BASE_SIZE: Vector2 = Vector2(48.0, 48.0)
const BASE_SCALE: Vector2 = Vector2(3.0, 3.0)
var VOICE_DIC = {}

var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")
var name_opacity = 0.0
var target_name_op = 0.0
var text_opacity = 0.0
var target_text_op = 0.0


func _ready():
#	Voice
	$TextBox.modulate = Color(1.0, 1.0, 1.0, 0.0)
	$TextBox/Text.text = ""
	if VOICE and DirAccess.dir_exists_absolute(VOICE):
		TIMER.wait_time = VOICE_SPEED
		for letter in "abcdefghijklmnopqrstuvwxyz":
			VOICE_DIC[letter] = load(VOICE + "/" + letter + ".wav")
#	Name
	$NameDisplay.modulate = Color(1.0, 1.0, 1.0, 0.0)
	$NameDisplay/Name.set_text(NAME)
#	Sprite
	if ANIMATION in $AnimationPlayer.get_animation_list():
		$AnimationPlayer.play(ANIMATION)
	if SPRITE:
		$Sprite.texture = SPRITE
		var scaler = $Sprite.get_texture().get_size() / Vector2(float($Sprite.hframes), float($Sprite.vframes))
		scaler = (BASE_SCALE / (scaler / BASE_SIZE))
		$Sprite.scale = Vector3(scaler.x, scaler.y, 1.0)
	if IS_NEAREST:
		$Sprite.set_texture_filter(BaseMaterial3D.TextureFilter.TEXTURE_FILTER_NEAREST)
	$Sprite.scale *= HEIGHT
	$Hitbox.scale *= HEIGHT
	$Interact.scale *= HEIGHT

func _process(_delta):
	if INTERACT and Input.is_action_just_pressed("talk") and $Interact.get_overlapping_bodies().has(INTERACT):
		if $TextBox.modulate.a > 0.0:
			if $TextBox/Text.text != TEXT:
				$TextBox/Text.text = TEXT
			else:
				target_text_op = 0.0
			_stop_text()
		else:
			target_text_op = 1.0
			$TextBox/Text.text = ""
			TIMER.start()
	if $TextBox/Text.text == TEXT:
		TIMER.stop()
	if target_name_op != name_opacity:
		if abs(target_name_op - name_opacity) < 0.01:
			name_opacity = target_name_op
		else:
			name_opacity = lerp(name_opacity, target_name_op, 3.0 * _delta)
		$NameDisplay.modulate = Color(1.0, 1.0, 1.0, name_opacity)
	if target_text_op != text_opacity:
		if abs(target_text_op - text_opacity) < 0.01:
			text_opacity = target_text_op
		elif target_text_op == 1.0:
			text_opacity = lerp(text_opacity, target_text_op, 12.0 * _delta)			
		else:
			text_opacity = lerp(text_opacity, target_text_op, 7.0 * _delta)
		$TextBox.modulate = Color(1.0, 1.0, 1.0, text_opacity)

func _physics_process(delta):
	if not is_on_floor():
		velocity.y -= gravity * delta
	move_and_slide()

func _stop_text():
	TIMER.stop()

func _player_enter(body):
	if INTERACT and body == INTERACT:
		target_name_op = 1.0

func _player_leave(body):
	if INTERACT and body == INTERACT:
		target_name_op = 0.0
		target_text_op = 0.0
		_stop_text()

func _on_timer_timeout():
	if $TextBox/Text.text != TEXT:
		var letter = TEXT[len($TextBox/Text.text)]
		$TextBox/Text.text += letter
		letter = letter.to_lower()
		SOUND.stop()
		if VOICE_DIC and letter >= "a" and letter <= "z":
			SOUND.set_stream(VOICE_DIC[letter])
			SOUND.play()
